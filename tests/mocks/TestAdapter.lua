-- TestAdapter: Mock implementation of GameAdapter for testing
-- Provides predictable behavior and state manipulation for tests

local TestAdapter = {}

function TestAdapter:new()
    local instance = {
        currentTime = 0,
        timestamp = 0,
        playerInfo = {
            name = "TestPlayer",
            realm = "TestRealm",
            level = 60,
            race = "Human",
            class = "Warrior",
            gender = 2,
            currentXP = 0,
            maxXP = 1000,
        },
        itemCache = {},
        currentZone = "TestZone",
        qualityColors = {
            [0] = "|cff9d9d9d",
            [1] = "|cffffffff",
            [2] = "|cff1eff00",
            [3] = "|cff0070dd",
            [4] = "|cffa335ee",
            [5] = "|cffff8000",
        },
        messages = {},
        units = {},
        combatLogEvent = nil,
    }
    setmetatable(instance, { __index = TestAdapter })
    return instance
end

-- Time functions
function TestAdapter:GetCurrentTime()
    return self.currentTime
end

function TestAdapter:SetCurrentTime(time)
    self.currentTime = time
end

function TestAdapter:GetTimestamp()
    return self.timestamp
end

function TestAdapter:SetTimestamp(time)
    self.timestamp = time
end

-- Player functions
function TestAdapter:GetPlayerLevel()
    return self.playerInfo.level
end

function TestAdapter:GetPlayerMaxLevel()
    return 60
end

function TestAdapter:GetPlayerName()
    return self.playerInfo.name
end

function TestAdapter:GetPlayerRealm()
    return self.playerInfo.realm
end

function TestAdapter:GetPlayerInfo()
    -- Return a copy to prevent external modification
    local copy = {}
    for k, v in pairs(self.playerInfo) do
        copy[k] = v
    end
    return copy
end

function TestAdapter:SetPlayerInfo(info)
    for k, v in pairs(info) do
        self.playerInfo[k] = v
    end
end

-- Item functions
function TestAdapter:GetItemInfo(itemLink)
    if not itemLink then
        return {
            name = nil,
            link = nil,
            quality = nil,
            texture = nil,
            sellPrice = nil,
        }
    end
    
    if self.itemCache[itemLink] then
        return self.itemCache[itemLink]
    end
    
    return {
        name = nil,
        link = nil,
        quality = nil,
        texture = nil,
        sellPrice = nil,
    }
end

function TestAdapter:SetItemInfo(itemLink, info)
    self.itemCache[itemLink] = info
end

function TestAdapter:GetItemQuality(itemLink)
    if not itemLink then
        return nil
    end
    
    if self.itemCache[itemLink] then
        return self.itemCache[itemLink].quality
    end
    
    return nil
end

-- Zone functions
function TestAdapter:GetCurrentZone()
    return self.currentZone
end

function TestAdapter:SetCurrentZone(zone)
    self.currentZone = zone
end

-- Color functions
function TestAdapter:GetQualityColor(quality)
    if not quality then
        return "|cffffffff"
    end
    return self.qualityColors[quality] or "|cffffffff"
end

function TestAdapter:SetQualityColor(quality, color)
    self.qualityColors[quality] = color
end

-- Unit functions
function TestAdapter:GetUnitName(unit)
    if not unit or not self.units[unit] then
        return nil
    end
    return self.units[unit].name
end

function TestAdapter:SetUnitName(unit, name)
    if not self.units[unit] then
        self.units[unit] = {}
    end
    self.units[unit].name = name
end

function TestAdapter:IsUnitDead(unit)
    if not unit or not self.units[unit] then
        return false
    end
    return self.units[unit].isDead or false
end

function TestAdapter:SetUnitDead(unit, isDead)
    if not self.units[unit] then
        self.units[unit] = {}
    end
    self.units[unit].isDead = isDead
end

function TestAdapter:IsUnitPlayer(unit)
    if not unit or not self.units[unit] then
        return false
    end
    return self.units[unit].isPlayer or false
end

function TestAdapter:SetUnitPlayer(unit, isPlayer)
    if not self.units[unit] then
        self.units[unit] = {}
    end
    self.units[unit].isPlayer = isPlayer
end

function TestAdapter:GetUnitGUID(unit)
    if not unit or not self.units[unit] then
        return nil
    end
    return self.units[unit].guid
end

function TestAdapter:SetUnitGUID(unit, guid)
    if not self.units[unit] then
        self.units[unit] = {}
    end
    self.units[unit].guid = guid
end

-- Combat Log functions
function TestAdapter:GetCombatLogEvent()
    return self.combatLogEvent
end

function TestAdapter:SetCombatLogEvent(event)
    self.combatLogEvent = event
end

-- Chat functions
function TestAdapter:PrintMessage(text)
    if text then
        table.insert(self.messages, text)
    end
end

function TestAdapter:GetMessages()
    return self.messages
end

function TestAdapter:ClearMessages()
    self.messages = {}
end

return TestAdapter
