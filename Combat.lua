local GrindCompanion = _G.GrindCompanion
local MobStats = require("core.aggregation.MobStats")
local GameAdapter = require("game.adapters.GameAdapter")

function GrindCompanion:HandleCombatXPGain(message)
    local gainedXP = message:match("(%d+)%s+experience")
    if not gainedXP then
        return
    end

    local xpAmount = tonumber(gainedXP)
    self.totalXP = (self.totalXP or 0) + xpAmount
    self.killCount = (self.killCount or 0) + 1
    self.levelXP = (self.levelXP or 0) + xpAmount
    self.levelKillCount = (self.levelKillCount or 0) + 1
    
    -- Track mob kill with XP
    local mobName = self:GetLastKilledMobName()
    if mobName then
        self:RecordMobKill(mobName, xpAmount)
    end
end

function GrindCompanion:GetLastKilledMobName()
    -- Try to get the mob name from the combat log or target
    -- The XP message doesn't include the mob name, so we need to track it
    if self.lastCombatTarget then
        return self.lastCombatTarget
    end
    
    -- Fallback: check if we have a dead target
    local adapter = self.gameAdapter or GameAdapter
    if adapter:IsUnitDead("target") and not adapter:IsUnitPlayer("target") then
        local name = adapter:GetUnitName("target")
        if name and name ~= "" then
            return name
        end
    end
    
    return "Unknown"
end

function GrindCompanion:RecordMobKill(mobName, xpAmount)
    if not self.mobStats then
        self.mobStats = {}
    end
    
    -- Track XP only if provided and player is not max level
    local xpToRecord = nil
    if xpAmount and not self:IsPlayerMaxLevel() then
        xpToRecord = xpAmount
    end
    
    -- Use MobStats module to record the kill
    MobStats:RecordKill(mobName, xpToRecord, nil, self.mobStats)
    
    self.currentMobForLoot = mobName
end

function GrindCompanion:PrintLevelSummary(completedLevel)
    if not self.levelStartTime then
        return
    end

    local adapter = self.gameAdapter or GameAdapter
    local elapsed = math.max(0, adapter:GetCurrentTime() - self.levelStartTime)
    local xpPerKill = (self.levelKillCount > 0 and math.floor(self.levelXP / self.levelKillCount) or 0)
    local xpPerHour = (elapsed > 0 and math.floor((self.levelXP / elapsed) * 3600) or 0)
    local levelLabel = completedLevel or math.max((adapter:GetPlayerLevel() or 1) - 1, 0)
    local lootSummary = self:FormatQualitySummary(self.levelLootQualityCount)

    self:PrintMessage(string.format(
        "Level %d summary - Time: %s | XP: %d | Kills: %d | XP/Kill: %d | XP/Hr: %d",
        levelLabel,
        self:FormatTime(elapsed),
        self.levelXP or 0,
        self.levelKillCount or 0,
        xpPerKill,
        xpPerHour
    ))

    self:PrintMessage(string.format(
        "Level %d loot - Coins: %s | %s",
        levelLabel,
        self:FormatCoin(self.levelCurrencyCopper or 0),
        lootSummary
    ))
end

function GrindCompanion:HandleLevelUp(newLevel)
    local adapter = self.gameAdapter or GameAdapter
    local completedLevel = (tonumber(newLevel) or (adapter:GetPlayerLevel() or 1)) - 1
    if completedLevel < 1 then
        completedLevel = math.max(completedLevel, 0)
    end

    self:PrintLevelSummary(completedLevel)
    self:ResetLevelStats()
end

function GrindCompanion:HandleCombatLogEvent()
    local adapter = self.gameAdapter or GameAdapter
    local event = adapter:GetCombatLogEvent()
    
    if not event then
        return
    end
    
    local subevent = event.subevent
    local sourceGUID = event.sourceGUID
    local destName = event.destName
    local destFlags = event.destFlags
    
    local playerGUID = adapter:GetUnitGUID("player")
    
    -- Track when player damages a mob
    if subevent == "SWING_DAMAGE" or subevent == "SPELL_DAMAGE" or subevent == "RANGE_DAMAGE" then
        if sourceGUID == playerGUID and destName then
            -- Check if it's a hostile NPC
            if bit.band(destFlags or 0, COMBATLOG_OBJECT_REACTION_HOSTILE) > 0 and
               bit.band(destFlags or 0, COMBATLOG_OBJECT_CONTROL_NPC) > 0 then
                self.lastCombatTarget = destName
            end
        end
    -- Track when a mob dies (killed by player)
    elseif subevent == "UNIT_DIED" then
        if destName and self.lastCombatTarget == destName then
            -- Check if it's a hostile NPC
            if bit.band(destFlags or 0, COMBATLOG_OBJECT_REACTION_HOSTILE) > 0 and
               bit.band(destFlags or 0, COMBATLOG_OBJECT_CONTROL_NPC) > 0 then
                -- At max level, there's no XP message, so track kill here
                if self:IsPlayerMaxLevel() then
                    self.killCount = (self.killCount or 0) + 1
                    self.levelKillCount = (self.levelKillCount or 0) + 1
                    self:RecordMobKill(destName, nil)
                end
            end
        end
    elseif subevent == "PARTY_KILL" then
        if sourceGUID == playerGUID and destName then
            -- Check if it's a hostile NPC
            if bit.band(destFlags or 0, COMBATLOG_OBJECT_REACTION_HOSTILE) > 0 and
               bit.band(destFlags or 0, COMBATLOG_OBJECT_CONTROL_NPC) > 0 then
                -- At max level, there's no XP message, so track kill here
                if self:IsPlayerMaxLevel() then
                    self.killCount = (self.killCount or 0) + 1
                    self.levelKillCount = (self.levelKillCount or 0) + 1
                    self:RecordMobKill(destName, nil)
                end
            end
        end
    end
end
