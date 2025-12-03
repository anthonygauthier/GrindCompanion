local GrindCalculator = _G.GrindCalculator

function GrindCalculator:HandleCombatXPGain(message)
    local gainedXP = message:match("(%d+)%s+experience")
    if not gainedXP then
        return
    end

    local xpAmount = tonumber(gainedXP)
    self.totalXP = (self.totalXP or 0) + xpAmount
    self.killCount = (self.killCount or 0) + 1
    self.levelXP = (self.levelXP or 0) + xpAmount
    self.levelKillCount = (self.levelKillCount or 0) + 1
    
    -- Track mob kill
    local mobName = self:GetLastKilledMobName()
    if mobName then
        self:RecordMobKill(mobName)
    end
end

function GrindCalculator:GetLastKilledMobName()
    -- Try to get the mob name from the combat log or target
    -- The XP message doesn't include the mob name, so we need to track it
    if self.lastCombatTarget then
        return self.lastCombatTarget
    end
    
    -- Fallback: check if we have a dead target
    if UnitIsDead("target") and not UnitIsPlayer("target") then
        local name = UnitName("target")
        if name and name ~= "" then
            return name
        end
    end
    
    return "Unknown"
end

function GrindCalculator:RecordMobKill(mobName)
    if not self.mobStats then
        self.mobStats = {}
    end
    
    if not self.mobStats[mobName] then
        self.mobStats[mobName] = {
            kills = 0,
            currency = 0,
            loot = {
                [2] = 0,
                [3] = 0,
                [4] = 0,
            }
        }
    end
    
    self.mobStats[mobName].kills = self.mobStats[mobName].kills + 1
    self.currentMobForLoot = mobName
end

function GrindCalculator:PrintLevelSummary(completedLevel)
    if not self.levelStartTime then
        return
    end

    local elapsed = math.max(0, GetTime() - self.levelStartTime)
    local xpPerKill = (self.levelKillCount > 0 and math.floor(self.levelXP / self.levelKillCount) or 0)
    local xpPerHour = (elapsed > 0 and math.floor((self.levelXP / elapsed) * 3600) or 0)
    local levelLabel = completedLevel or math.max((UnitLevel("player") or 1) - 1, 0)
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

function GrindCalculator:HandleLevelUp(newLevel)
    local completedLevel = (tonumber(newLevel) or (UnitLevel("player") or 1)) - 1
    if completedLevel < 1 then
        completedLevel = math.max(completedLevel, 0)
    end

    self:PrintLevelSummary(completedLevel)
    self:ResetLevelStats()
end

function GrindCalculator:HandleCombatLogEvent()
    local timestamp, subevent, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags = CombatLogGetCurrentEventInfo()
    
    -- Track when player damages a mob
    if subevent == "SWING_DAMAGE" or subevent == "SPELL_DAMAGE" or subevent == "RANGE_DAMAGE" then
        if sourceGUID == UnitGUID("player") and destName and not UnitIsPlayer("target") then
            -- Check if it's a hostile NPC
            if bit.band(destFlags or 0, COMBATLOG_OBJECT_REACTION_HOSTILE) > 0 and
               bit.band(destFlags or 0, COMBATLOG_OBJECT_CONTROL_NPC) > 0 then
                self.lastCombatTarget = destName
            end
        end
    -- Track when a mob dies
    elseif subevent == "UNIT_DIED" or subevent == "PARTY_KILL" then
        if sourceGUID == UnitGUID("player") and destName then
            self.lastCombatTarget = destName
        end
    end
end
