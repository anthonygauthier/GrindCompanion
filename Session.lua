local GrindCompanion = _G.GrindCompanion
local Statistics = require("core.calculations.Statistics")
local MobStats = require("core.aggregation.MobStats")
local SessionData = require("core.aggregation.SessionData")
local GameAdapter = require("game.adapters.GameAdapter")

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
    self.levelStartTime = GameAdapter:GetCurrentTime()
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
    self.startTime = GameAdapter:GetCurrentTime()
    self.stopTime = nil
    self.totalXP = 0
    self.killCount = 0
    self.currencyCopper = 0
    self.grayCopper = 0
    self.potentialAHCopper = 0
    self.lootWindowOpen = false
    self.sessionStartTimestamp = GameAdapter:GetTimestamp()
    self.sessionStartLevel = GameAdapter:GetPlayerLevel()
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
    local zoneName = GameAdapter:GetCurrentZone()
    
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
    local playerLevel = GameAdapter:GetPlayerLevel()
    local maxLevel = self:GetMaxPlayerLevelSafe()
    return playerLevel >= maxLevel, maxLevel
end

function GrindCompanion:GetElapsedTime()
    return Statistics:CalculateElapsedTime(self.startTime, self.stopTime or GameAdapter:GetCurrentTime(), self.isTracking)
end

function GrindCompanion:CalculateTimeToLevel()
    local elapsed = self:GetElapsedTime()
    local playerInfo = GameAdapter:GetPlayerInfo()
    return Statistics:CalculateTimeToLevel(playerInfo.currentXP, playerInfo.maxXP, self.totalXP, elapsed)
end

function GrindCompanion:CalculateKillsRemaining()
    local playerInfo = GameAdapter:GetPlayerInfo()
    return Statistics:CalculateKillsRemaining(playerInfo.currentXP, playerInfo.maxXP, self.totalXP, self.killCount)
end

function GrindCompanion:BuildSessionSnapshot()
    if not self.startTime then
        return nil
    end

    local now = GameAdapter:GetTimestamp()
    local elapsed = self:GetElapsedTime()
    local playerInfo = GameAdapter:GetPlayerInfo()
    local wasMaxLevel = self:IsPlayerMaxLevel()
    
    -- Make sure current zone is tracked
    self:TrackCurrentZone()
    
    -- Prepare session state
    local sessionState = {
        startTime = self.startTime,
        elapsedTime = elapsed,
        startTimestamp = self.sessionStartTimestamp or now,
        endTimestamp = now,
        totalXP = self.totalXP,
        killCount = self.killCount,
        currencyCopper = self.currencyCopper,
        grayCopper = self.grayCopper,
        potentialAHCopper = self.potentialAHCopper,
        lootQualityCount = self.lootQualityCount,
    }
    
    -- Prepare character info
    local characterInfo = {
        name = playerInfo.name,
        realm = playerInfo.realm,
        startingLevel = self.sessionStartLevel or playerInfo.level,
        level = playerInfo.level,
        race = playerInfo.race,
        class = playerInfo.class,
        gender = playerInfo.gender,
        wasMaxLevel = wasMaxLevel,
    }
    
    -- Use SessionData module to build snapshot
    return SessionData:BuildSnapshot(
        sessionState,
        characterInfo,
        self.sessionZones,
        self.mobStats,
        self.lootedItems
    )
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
    
    -- Use SessionData module to calculate trend statistics
    return SessionData:CalculateTrendStatistics(sessions)
end
