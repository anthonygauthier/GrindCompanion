local GrindCalculator = _G.GrindCalculator

function GrindCalculator:ResetLevelStats()
    self.levelStartTime = GetTime()
    self.levelXP = 0
    self.levelKillCount = 0
    self.levelCurrencyCopper = 0
    self.levelGrayCopper = 0
    self.levelPotentialAHCopper = 0
    self.levelLootQualityCount = {
        [2] = 0,
        [3] = 0,
        [4] = 0,
    }
end

function GrindCalculator:ResetStats()
    self.startTime = GetTime()
    self.stopTime = nil
    self.totalXP = 0
    self.killCount = 0
    self.currencyCopper = 0
    self.grayCopper = 0
    self.potentialAHCopper = 0
    self.lootWindowOpen = false
    self.sessionStartTimestamp = time()
    self.sessionStartLevel = UnitLevel("player") or 0
    self.sessionZones = {}
    self.mobStats = {}
    self.currentMobForLoot = nil
    self.lastCombatTarget = nil
    self:TrackCurrentZone()
    if self.lootSlotCache then
        wipe(self.lootSlotCache)
    end
    self.lootQualityCount = {
        [2] = 0,
        [3] = 0,
        [4] = 0,
    }
    self.lootedItems = {}
    self:ResetLevelStats()
end

function GrindCalculator:TrackCurrentZone()
    local zoneName = GetZoneText() or GetRealZoneText() or "Unknown"
    if zoneName == "" then
        zoneName = "Unknown"
    end
    
    if not self.sessionZones then
        self.sessionZones = {}
    end
    
    -- Only add if not already in the list
    local alreadyTracked = false
    for _, zone in ipairs(self.sessionZones) do
        if zone == zoneName then
            alreadyTracked = true
            break
        end
    end
    
    if not alreadyTracked then
        table.insert(self.sessionZones, zoneName)
    end
end

function GrindCalculator:IsPlayerMaxLevel()
    local playerLevel = UnitLevel("player") or 0
    local maxLevel = self:GetMaxPlayerLevelSafe()
    return playerLevel >= maxLevel, maxLevel
end

function GrindCalculator:GetElapsedTime()
    if not self.startTime then
        return 0
    end

    if self.isTracking then
        return GetTime() - self.startTime
    end

    if self.stopTime then
        return self.stopTime - self.startTime
    end

    return 0
end

function GrindCalculator:CalculateTimeToLevel()
    local elapsed = self:GetElapsedTime()
    if elapsed <= 0 or (self.totalXP or 0) <= 0 then
        return nil
    end

    local xpRemaining = UnitXPMax("player") - UnitXP("player")
    if xpRemaining <= 0 then
        return nil
    end

    local xpPerSecond = self.totalXP / elapsed
    if xpPerSecond <= 0 then
        return nil
    end

    return xpRemaining / xpPerSecond
end

function GrindCalculator:CalculateKillsRemaining()
    if (self.killCount or 0) <= 0 or (self.totalXP or 0) <= 0 then
        return nil
    end

    local xpRemaining = UnitXPMax("player") - UnitXP("player")
    if xpRemaining <= 0 then
        return nil
    end

    local xpPerKill = self.totalXP / self.killCount
    if xpPerKill <= 0 then
        return nil
    end

    return math.ceil(xpRemaining / xpPerKill)
end

function GrindCalculator:BuildSessionSnapshot()
    if not self.startTime then
        return nil
    end

    local now = time()
    local elapsed = self:GetElapsedTime()
    local playerName = UnitName("player") or "Unknown"
    local realm = GetRealmName and GetRealmName() or nil
    local endingLevel = UnitLevel("player") or 0
    local wasMaxLevel = self:IsPlayerMaxLevel()
    
    -- Make sure current zone is tracked
    self:TrackCurrentZone()
    
    -- Copy zones array
    local zones = {}
    if self.sessionZones then
        for _, zone in ipairs(self.sessionZones) do
            table.insert(zones, zone)
        end
    end
    
    -- Copy mob stats
    local mobs = {}
    if self.mobStats then
        for mobName, stats in pairs(self.mobStats) do
            mobs[mobName] = {
                kills = stats.kills,
                currency = stats.currency,
                loot = self:CopyQualityCounts(stats.loot),
            }
        end
    end

    -- Get race and class info
    local _, race = UnitRace("player")
    local _, class = UnitClass("player")
    
    return {
        character = {
            name = playerName,
            realm = realm,
            startingLevel = self.sessionStartLevel or endingLevel,
            endingLevel = endingLevel,
            race = race,
            class = class,
        },
        startedAt = self.sessionStartTimestamp or now,
        endedAt = now,
        duration = elapsed,
        totalXP = self.totalXP or 0,
        killCount = self.killCount or 0,
        currencyCopper = self.currencyCopper or 0,
        grayCopper = self.grayCopper or 0,
        potentialAHCopper = self.potentialAHCopper or 0,
        loot = self:CopyQualityCounts(self.lootQualityCount),
        wasMaxLevel = wasMaxLevel,
        zones = zones,
        mobs = mobs,
    }
end

function GrindCalculator:PersistSessionHistory()
    local snapshot = self:BuildSessionSnapshot()
    if not snapshot then
        return
    end

    self:EnsureSavedVariables()
    table.insert(GrindCalculatorDB.sessions, snapshot)
    self.lastSavedSession = snapshot
    return snapshot, #GrindCalculatorDB.sessions
end

function GrindCalculator:PrintSessionSaved(snapshot, index)
    if not snapshot then
        return
    end

    local startLabel = (snapshot.startedAt and date("%m/%d %H:%M", snapshot.startedAt)) or "session"
    local lootText = self:FormatQualitySummary(snapshot.loot)
    local hasLoot = false
    for _, amount in pairs(snapshot.loot or {}) do
        if (amount or 0) > 0 then
            hasLoot = true
            break
        end
    end

    self:PrintMessage(string.format(
        "Saved session #%d (%s) - Coins: %s | Gray: %s | AH: %s | Total: %s | Loot: %s",
        index or 0,
        startLabel,
        self:FormatCoin(snapshot.currencyCopper or 0),
        self:FormatCoin(snapshot.grayCopper or 0),
        self:FormatCoin(snapshot.potentialAHCopper or 0),
        self:FormatCoin((snapshot.currencyCopper or 0) + (snapshot.grayCopper or 0) + (snapshot.potentialAHCopper or 0)),
        hasLoot and lootText or "No notable items yet"
    ))
end

function GrindCalculator:CalculateTrendStatistics(filteredSessions)
    -- Use provided sessions or get all sessions
    local sessions = filteredSessions or (function()
        self:EnsureSavedVariables()
        return GrindCalculatorDB.sessions or {}
    end)()
    
    -- Handle empty sessions array
    if #sessions == 0 then
        return {
            totalSessions = 0,
            totalDuration = 0,
            avgCopperPerHour = 0,
            bestCopperPerHour = 0,
            avgXPPerHour = 0,
            bestXPPerHour = 0,
            totalCurrency = 0,
            totalXP = 0,
        }
    end
    
    -- Initialize accumulators
    local totalSessions = #sessions
    local totalDuration = 0
    local totalCurrency = 0
    local totalXP = 0
    local bestCopperPerHour = 0
    
    -- For XP calculations (non-max-level sessions only)
    local nonMaxLevelSessions = 0
    local totalXPNonMaxLevel = 0
    local totalDurationNonMaxLevel = 0
    local bestXPPerHour = 0
    
    -- Iterate through all sessions
    for _, session in ipairs(sessions) do
        local duration = session.duration or 0
        local currency = (session.currencyCopper or 0) + (session.grayCopper or 0) + (session.potentialAHCopper or 0)
        local xp = session.totalXP or 0
        
        -- Accumulate totals
        totalDuration = totalDuration + duration
        totalCurrency = totalCurrency + currency
        totalXP = totalXP + xp
        
        -- Calculate per-hour rates for sessions with non-zero duration
        if duration > 0 then
            local durationHours = duration / 3600
            
            -- Currency per hour
            local copperPerHour = currency / durationHours
            if copperPerHour > bestCopperPerHour then
                bestCopperPerHour = copperPerHour
            end
            
            -- XP per hour (only for non-max-level sessions)
            if not session.wasMaxLevel then
                local xpPerHour = xp / durationHours
                if xpPerHour > bestXPPerHour then
                    bestXPPerHour = xpPerHour
                end
                
                nonMaxLevelSessions = nonMaxLevelSessions + 1
                totalXPNonMaxLevel = totalXPNonMaxLevel + xp
                totalDurationNonMaxLevel = totalDurationNonMaxLevel + duration
            end
        end
    end
    
    -- Calculate averages
    local avgCopperPerHour = 0
    if totalDuration > 0 then
        avgCopperPerHour = totalCurrency / (totalDuration / 3600)
    end
    
    local avgXPPerHour = 0
    if totalDurationNonMaxLevel > 0 then
        avgXPPerHour = totalXPNonMaxLevel / (totalDurationNonMaxLevel / 3600)
    end
    
    return {
        totalSessions = totalSessions,
        totalDuration = totalDuration,
        avgCopperPerHour = avgCopperPerHour,
        bestCopperPerHour = bestCopperPerHour,
        avgXPPerHour = avgXPPerHour,
        bestXPPerHour = bestXPPerHour,
        totalCurrency = totalCurrency,
        totalXP = totalXP,
    }
end
