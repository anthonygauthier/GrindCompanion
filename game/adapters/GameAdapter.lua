-- GameAdapter: Wraps WoW API calls and provides clean interfaces to core logic
-- This layer isolates WoW API dependencies from pure business logic

local GameAdapter = {}

-- Time functions
function GameAdapter:GetCurrentTime()
    local ok, result = pcall(GetTime)
    if ok and result then
        return result
    end
    return 0
end

function GameAdapter:GetTimestamp()
    local ok, result = pcall(time)
    if ok and result then
        return result
    end
    return 0
end

-- Player functions
function GameAdapter:GetPlayerLevel()
    local ok, level = pcall(UnitLevel, "player")
    if ok and level then
        return level
    end
    return 0
end

function GameAdapter:GetPlayerMaxLevel()
    if type(GetMaxPlayerLevel) == "function" then
        local ok, level = pcall(GetMaxPlayerLevel)
        if ok and level then
            return level
        end
    end
    -- Fallback to global constant
    if MAX_PLAYER_LEVEL then
        return MAX_PLAYER_LEVEL
    end
    return 60
end

function GameAdapter:GetPlayerName()
    local ok, name = pcall(UnitName, "player")
    if ok and name then
        return name
    end
    return "Unknown"
end

function GameAdapter:GetPlayerRealm()
    if type(GetRealmName) == "function" then
        local ok, realm = pcall(GetRealmName)
        if ok and realm then
            return realm
        end
    end
    return "Unknown"
end

function GameAdapter:GetPlayerInfo()
    local info = {
        name = "Unknown",
        realm = "Unknown",
        level = 0,
        race = "Unknown",
        class = "Unknown",
        gender = 0,
        currentXP = 0,
        maxXP = 1,
    }
    
    -- Get name
    local ok, name = pcall(UnitName, "player")
    if ok and name then
        info.name = name
    end
    
    -- Get realm
    if type(GetRealmName) == "function" then
        ok, name = pcall(GetRealmName)
        if ok and name then
            info.realm = name
        end
    end
    
    -- Get level
    ok, name = pcall(UnitLevel, "player")
    if ok and name then
        info.level = name
    end
    
    -- Get race
    ok, name = pcall(UnitRace, "player")
    if ok and name then
        info.race = select(2, UnitRace("player")) or "Unknown"
    end
    
    -- Get class
    ok, name = pcall(UnitClass, "player")
    if ok and name then
        info.class = select(2, UnitClass("player")) or "Unknown"
    end
    
    -- Get gender
    ok, name = pcall(UnitSex, "player")
    if ok and name then
        info.gender = name
    end
    
    -- Get XP
    ok, name = pcall(UnitXP, "player")
    if ok and name then
        info.currentXP = name
    end
    
    ok, name = pcall(UnitXPMax, "player")
    if ok and name then
        info.maxXP = name
    end
    
    return info
end

-- Item functions
function GameAdapter:GetItemInfo(itemLink)
    if not itemLink then
        return {
            name = nil,
            link = nil,
            quality = nil,
            texture = nil,
            sellPrice = nil,
        }
    end
    
    local ok, name, link, quality, _, _, _, _, _, texture, sellPrice = pcall(GetItemInfo, itemLink)
    if ok then
        return {
            name = name,
            link = link,
            quality = quality,
            texture = texture,
            sellPrice = sellPrice,
        }
    end
    
    return {
        name = nil,
        link = nil,
        quality = nil,
        texture = nil,
        sellPrice = nil,
    }
end

function GameAdapter:GetItemQuality(itemLink)
    if not itemLink then
        return nil
    end
    
    -- Try GetItemInfoInstant first (faster)
    if type(GetItemInfoInstant) == "function" then
        local ok, _, _, quality = pcall(GetItemInfoInstant, itemLink)
        if ok and quality then
            return quality
        end
    end
    
    -- Fallback to GetItemInfo
    local ok, _, _, quality = pcall(GetItemInfo, itemLink)
    if ok and quality then
        return quality
    end
    
    return nil
end

-- Zone functions
function GameAdapter:GetCurrentZone()
    local zoneName = "Unknown"
    
    -- Try GetZoneText first
    if type(GetZoneText) == "function" then
        local ok, zone = pcall(GetZoneText)
        if ok and zone and zone ~= "" then
            zoneName = zone
        end
    end
    
    -- Fallback to GetRealZoneText
    if zoneName == "Unknown" and type(GetRealZoneText) == "function" then
        local ok, zone = pcall(GetRealZoneText)
        if ok and zone and zone ~= "" then
            zoneName = zone
        end
    end
    
    return zoneName
end

-- Color functions
function GameAdapter:GetQualityColor(quality)
    if not quality then
        return "|cffffffff"
    end
    
    -- Try to get from ITEM_QUALITY_COLORS
    if ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[quality] then
        local ok, hex = pcall(function() return ITEM_QUALITY_COLORS[quality].hex end)
        if ok and hex then
            return hex
        end
    end
    
    -- Fallback colors
    local fallbacks = {
        [0] = "|cff9d9d9d", -- Poor (gray)
        [1] = "|cffffffff", -- Common (white)
        [2] = "|cff1eff00", -- Uncommon (green)
        [3] = "|cff0070dd", -- Rare (blue)
        [4] = "|cffa335ee", -- Epic (purple)
        [5] = "|cffff8000", -- Legendary (orange)
    }
    
    return fallbacks[quality] or "|cffffffff"
end

-- Unit functions
function GameAdapter:GetUnitName(unit)
    if not unit then
        return nil
    end
    
    local ok, name = pcall(UnitName, unit)
    if ok and name and name ~= "" then
        return name
    end
    
    return nil
end

function GameAdapter:IsUnitDead(unit)
    if not unit then
        return false
    end
    
    local ok, isDead = pcall(UnitIsDead, unit)
    if ok then
        return isDead or false
    end
    
    return false
end

function GameAdapter:IsUnitPlayer(unit)
    if not unit then
        return false
    end
    
    local ok, isPlayer = pcall(UnitIsPlayer, unit)
    if ok then
        return isPlayer or false
    end
    
    return false
end

function GameAdapter:GetUnitGUID(unit)
    if not unit then
        return nil
    end
    
    local ok, guid = pcall(UnitGUID, unit)
    if ok and guid then
        return guid
    end
    
    return nil
end

-- Combat Log functions
function GameAdapter:GetCombatLogEvent()
    if not CombatLogGetCurrentEventInfo then
        return nil
    end
    
    local ok, timestamp, subevent, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags = pcall(CombatLogGetCurrentEventInfo)
    if ok then
        return {
            timestamp = timestamp,
            subevent = subevent,
            sourceGUID = sourceGUID,
            sourceName = sourceName,
            destGUID = destGUID,
            destName = destName,
            destFlags = destFlags,
        }
    end
    
    return nil
end

-- Chat functions
function GameAdapter:PrintMessage(text)
    if not text then
        return
    end
    
    if DEFAULT_CHAT_FRAME and type(DEFAULT_CHAT_FRAME.AddMessage) == "function" then
        local ok = pcall(function()
            DEFAULT_CHAT_FRAME:AddMessage(string.format("|cff33ff99GrindCompanion:|r %s", text))
        end)
        if ok then
            return
        end
    end
    
    -- Fallback to print if chat frame not available
    print(string.format("GrindCompanion: %s", text))
end

_G.GC_GameAdapter = GameAdapter
return GameAdapter
