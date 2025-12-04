-- TestAdapter: Mock implementation of GameAdapter for testing
-- Provides predictable, controllable behavior for testing core logic

local TestAdapter = {}
TestAdapter.__index = TestAdapter

-- Create a new TestAdapter instance
function TestAdapter:new()
    local instance = {
        -- Time state
        currentTime = 0,
        timestamp = 0,
        
        -- Player state
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
        
        -- Item cache
        itemCache = {},
        
        -- Zone state
        currentZone = "TestZone",
        
        -- Quality color mappings
        qualityColors = {
            [0] = "|cff9d9d9d", -- Poor (gray)
            [1] = "|cffffffff", -- Common (white)
            [2] = "|cff1eff00", -- Uncommon (green)
            [3] = "|cff0070dd", -- Rare (blue)
            [4] = "|cffa335ee", -- Epic (purple)
            [5] = "|cffff8000", -- Legendary (orange)
        },
        
        -- Message log for testing
        messages = {},
    }
    
    setmetatable(instance, TestAdapter)
    return instance
end

-- Time functions
function TestAdapter:GetCurrentTime()
    return self.currentTime
end

function TestAdapter:SetCurrentTime(time)
    self.currentTime = time
end

function TestAdapter:AdvanceTime(seconds)
    self.currentTime = self.currentTime + seconds
end

function TestAdapter:GetTimestamp()
    return self.timestamp
end

function TestAdapter:SetTimestamp(timestamp)
    self.timestamp = timestamp
end

-- Player functions
function TestAdapter:GetPlayerLevel()
    return self.playerInfo.level
end

function TestAdapter:GetPlayerMaxLevel()
    return 60 -- Default max level for testing
end

function TestAdapter:GetPlayerName()
    return self.playerInfo.name
end

function TestAdapter:GetPlayerInfo()
    -- Return a copy to prevent external modification
    return {
        name = self.playerInfo.name,
        realm = self.playerInfo.realm,
        level = self.playerInfo.level,
        race = self.playerInfo.race,
        class = self.playerInfo.class,
        gender = self.playerInfo.gender,
        currentXP = self.playerInfo.currentXP,
        maxXP = self.playerInfo.maxXP,
    }
end

function TestAdapter:SetPlayerInfo(info)
    for k, v in pairs(info) do
        self.playerInfo[k] = v
    end
end

function TestAdapter:SetPlayerLevel(level)
    self.playerInfo.level = level
end

function TestAdapter:SetPlayerXP(currentXP, maxXP)
    self.playerInfo.currentXP = currentXP
    self.playerInfo.maxXP = maxXP or self.playerInfo.maxXP
end

-- Item functions
function TestAdapter:GetItemInfo(itemLink)
    if self.itemCache[itemLink] then
        return self.itemCache[itemLink]
    end
    
    -- Return default item info if not cached
    return {
        name = "Unknown Item",
        link = itemLink,
        quality = 1,
        texture = "Interface\\Icons\\INV_Misc_QuestionMark",
        sellPrice = 0,
    }
end

function TestAdapter:SetItemInfo(itemLink, itemInfo)
    self.itemCache[itemLink] = itemInfo
end

function TestAdapter:GetItemQuality(itemLink)
    if self.itemCache[itemLink] then
        return self.itemCache[itemLink].quality
    end
    return 1 -- Default to common quality
end

-- Zone functions
function TestAdapter:GetCurrentZone()
    return self.currentZone
end

function TestAdapter:SetCurrentZone(zoneName)
    self.currentZone = zoneName
end

-- Color functions
function TestAdapter:GetQualityColor(quality)
    return self.qualityColors[quality] or "|cffffffff"
end

function TestAdapter:SetQualityColor(quality, colorCode)
    self.qualityColors[quality] = colorCode
end

-- Chat functions
function TestAdapter:PrintMessage(text)
    table.insert(self.messages, text)
end

function TestAdapter:GetMessages()
    return self.messages
end

function TestAdapter:ClearMessages()
    self.messages = {}
end

function TestAdapter:GetLastMessage()
    return self.messages[#self.messages]
end

-- Reset adapter to initial state
function TestAdapter:Reset()
    self.currentTime = 0
    self.timestamp = 0
    self.playerInfo = {
        name = "TestPlayer",
        realm = "TestRealm",
        level = 60,
        race = "Human",
        class = "Warrior",
        gender = 2,
        currentXP = 0,
        maxXP = 1000,
    }
    self.itemCache = {}
    self.currentZone = "TestZone"
    self.messages = {}
end

return TestAdapter
