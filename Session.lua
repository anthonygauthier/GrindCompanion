local GrindCompanion = _G.GrindCompanion
local Statistics = require("core.calculations.Statistics")
local MobStats = require("core.aggregation.MobStats")

function GrindCompanion:CountTableKeys(tbl)
    if not tbl then
        return 0
    end
    
    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end
    return count
end

function GrindCompanion:ResetLevelStats()
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

function GrindCompanion:ResetStats()
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
    -- Clear hash map for O(1) loot lookups
    if self._lootedItemsMap then
        wipe(self._lootedItemsMap)
    end
    self:ResetLevelStats()
end

function GrindCompanion:TrackCurrentZone()
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

function GrindCompanion:IsPlayerMaxLevel()
    local playerLevel = UnitLevel("player") or 0
    local maxLevel = self:GetMaxPlayerLevelSafe()
    return playerLevel >= maxLevel, maxLevel
end

function GrindCompanion:GetElapsedTime()
    return Statistics:CalculateElapsedTime(self.startTime, self.stopTime or GetTime(), self.isTracking)
end

function GrindCompanion:CalculateTimeToLevel()
    local elapsed = self:GetElapsedTime()
    local currentXP = UnitXP("player")
    local maxXP = UnitXPMax("player")
    return Statistics:CalculateTimeToLevel(currentXP, maxXP, self.totalXP, elapsed)
end

function GrindCompanion:CalculateKillsRemaining()
    local currentXP = UnitXP("player")
    local maxXP = UnitXPMax("player")
    return Statistics:CalculateKillsRemaining(currentXP, maxXP, self.totalXP, self.killCount)
end

function GrindCompanion:BuildSessionSnapshot()
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
    
    -- Copy mob stats with detailed tracking
    local mobs = {}
    
    if self.mobStats then
        for mobName, stats in pairs(self.mobStats) do
            local mobCurrency = stats.currency or 0
            local mobXP = stats.xp or 0
            local mobLoot = MobStats:CopyQualityCounts(stats.loot)
            local mobItemCount = 0
            
            -- Count total items from this mob
            for quality, count in pairs(mobLoot) do
                mobItemCount = mobItemCount + count
            end
            
            -- Copy highest quality drop info
            local highestDrop = nil
            if stats.highestQualityDrop then
                highestDrop = {
                    quality = stats.highestQualityDrop.quality,
                    link = stats.highestQualityDrop.link,
                    quantity = stats.highestQualityDrop.quantity,
                }
            end
            
            mobs[mobName] = {
                kills = stats.kills or 0,
                currency = mobCurrency,
                xp = mobXP,
                loot = mobLoot,
                itemCount = mobItemCount,
                highestQualityDrop = highestDrop,
            }
        end
    end
    
    -- Use MobStats module to calculate totals
    local mobTotals = MobStats:CalculateTotals(self.mobStats)
    
    -- Copy looted items list
    local lootedItems = {}
    if self.lootedItems then
        for _, item in ipairs(self.lootedItems) do
            table.insert(lootedItems, {
                link = item.link,
                quality = item.quality,
                quantity = item.quantity,
            })
        end
    end

    -- Get race and class info
    local _, race = UnitRace("player")
    local _, class = UnitClass("player")
    local gender = UnitSex("player") -- 2 = Male, 3 = Female
    
    return {
        character = {
            name = playerName,
            realm = realm,
            startingLevel = self.sessionStartLevel or endingLevel,
            endingLevel = endingLevel,
            race = race,
            class = class,
            gender = gender,
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
        lootedItems = lootedItems,
        wasMaxLevel = wasMaxLevel,
        zones = zones,
        mobs = mobs,
        mobSummary = {
            totalKills = mobTotals.totalKills,
            totalCurrency = mobTotals.totalCurrency,
            totalXP = mobTotals.totalXP,
            totalItems = mobTotals.totalItems,
            uniqueMobs = self:CountTableKeys(mobs),
        },
    }
end

function GrindCompanion:PersistSessionHistory()
    local snapshot = self:BuildSessionSnapshot()
    if not snapshot then
        return
    end

    self:EnsureSavedVariables()
    table.insert(GrindCompanionDB.sessions, snapshot)
    self.lastSavedSession = snapshot
    return snapshot, #GrindCompanionDB.sessions
end

function GrindCompanion:PrintSessionSaved(snapshot, index)
    if not snapshot then
        return
    end

    local totalCopper = (snapshot.currencyCopper or 0) + (snapshot.grayCopper or 0) + (snapshot.potentialAHCopper or 0)
    local mobSummary = snapshot.mobSummary or {}
    local totalKills = mobSummary.totalKills or snapshot.killCount or 0
    
    if snapshot.wasMaxLevel then
        self:PrintMessage(string.format(
            "Session #%d saved - %s | %d kills | %s total",
            index or 0,
            self:FormatTime(snapshot.duration or 0),
            totalKills,
            self:FormatCoin(totalCopper)
        ))
    else
        self:PrintMessage(string.format(
            "Session #%d saved - %s | %d kills | %s XP | %s total",
            index or 0,
            self:FormatTime(snapshot.duration or 0),
            totalKills,
            self:FormatNumber(snapshot.totalXP or 0),
            self:FormatCoin(totalCopper)
        ))
    end
end

-- OPTIMIZED: Single-pass calculation with minimal branching
function GrindCompanion:CalculateTrendStatistics(filteredSessions)
    local sessions = filteredSessions or (function()
        self:EnsureSavedVariables()
        return GrindCompanionDB.sessions or {}
    end)()
    
    local totalSessions = #sessions
    if totalSessions == 0 then
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
    
    -- Single-pass accumulation
    local totalDuration = 0
    local totalCurrency = 0
    local totalXP = 0
    local bestCopperPerHour = 0
    local totalXPNonMaxLevel = 0
    local totalDurationNonMaxLevel = 0
    local bestXPPerHour = 0
    local inv3600 = 1 / 3600  -- Pre-calculate division constant
    
    for i = 1, totalSessions do
        local session = sessions[i]
        local duration = session.duration or 0
        local currency = (session.currencyCopper or 0) + (session.grayCopper or 0) + (session.potentialAHCopper or 0)
        local xp = session.totalXP or 0
        
        totalDuration = totalDuration + duration
        totalCurrency = totalCurrency + currency
        totalXP = totalXP + xp
        
        if duration > 0 then
            local durationHours = duration * inv3600
            local copperPerHour = currency / durationHours
            
            if copperPerHour > bestCopperPerHour then
                bestCopperPerHour = copperPerHour
            end
            
            if not session.wasMaxLevel then
                local xpPerHour = xp / durationHours
                if xpPerHour > bestXPPerHour then
                    bestXPPerHour = xpPerHour
                end
                totalXPNonMaxLevel = totalXPNonMaxLevel + xp
                totalDurationNonMaxLevel = totalDurationNonMaxLevel + duration
            end
        end
    end
    
    -- Calculate averages (avoid division by zero)
    local avgCopperPerHour = totalDuration > 0 and (totalCurrency / (totalDuration * inv3600)) or 0
    local avgXPPerHour = totalDurationNonMaxLevel > 0 and (totalXPNonMaxLevel / (totalDurationNonMaxLevel * inv3600)) or 0
    
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
