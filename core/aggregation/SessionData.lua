local SessionData = {}

-- Build a session snapshot from provided data
-- This function creates a complete snapshot of the current session state
-- without accessing any global state or WoW API calls
function SessionData:BuildSnapshot(sessionState, characterInfo, zoneList, mobStats, lootedItems)
    if not sessionState or not sessionState.startTime then
        return nil
    end
    
    -- Calculate elapsed time
    local elapsed = sessionState.elapsedTime or 0
    
    -- Copy zones array
    local zones = {}
    if zoneList then
        for _, zone in ipairs(zoneList) do
            table.insert(zones, zone)
        end
    end
    
    -- Copy mob stats with detailed tracking
    local mobs = {}
    local mobTotals = {
        totalKills = 0,
        totalCurrency = 0,
        totalXP = 0,
        totalItems = {},
        uniqueMobs = 0,
    }
    
    if mobStats then
        for mobName, stats in pairs(mobStats) do
            local mobCurrency = stats.currency or 0
            local mobXP = stats.xp or 0
            local mobLoot = {}
            local mobItemCount = 0
            
            -- Copy quality counts
            if stats.loot then
                for quality, count in pairs(stats.loot) do
                    mobLoot[quality] = count
                    mobItemCount = mobItemCount + count
                    mobTotals.totalItems[quality] = (mobTotals.totalItems[quality] or 0) + count
                end
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
            
            -- Accumulate totals
            mobTotals.totalKills = mobTotals.totalKills + (stats.kills or 0)
            mobTotals.totalCurrency = mobTotals.totalCurrency + mobCurrency
            mobTotals.totalXP = mobTotals.totalXP + mobXP
            mobTotals.uniqueMobs = mobTotals.uniqueMobs + 1
        end
    end
    
    -- Copy looted items list
    local lootedItemsCopy = {}
    if lootedItems then
        for _, item in ipairs(lootedItems) do
            table.insert(lootedItemsCopy, {
                link = item.link,
                quality = item.quality,
                quantity = item.quantity,
            })
        end
    end
    
    -- Copy quality counts
    local lootQualityCounts = {}
    if sessionState.lootQualityCount then
        for quality, count in pairs(sessionState.lootQualityCount) do
            lootQualityCounts[quality] = count
        end
    end
    
    return {
        character = {
            name = characterInfo.name or "Unknown",
            realm = characterInfo.realm,
            startingLevel = characterInfo.startingLevel or characterInfo.level or 0,
            endingLevel = characterInfo.level or 0,
            race = characterInfo.race,
            class = characterInfo.class,
            gender = characterInfo.gender,
        },
        startedAt = sessionState.startTimestamp or 0,
        endedAt = sessionState.endTimestamp or 0,
        duration = elapsed,
        totalXP = sessionState.totalXP or 0,
        killCount = sessionState.killCount or 0,
        currencyCopper = sessionState.currencyCopper or 0,
        grayCopper = sessionState.grayCopper or 0,
        potentialAHCopper = sessionState.potentialAHCopper or 0,
        loot = lootQualityCounts,
        lootedItems = lootedItemsCopy,
        wasMaxLevel = characterInfo.wasMaxLevel or false,
        zones = zones,
        mobs = mobs,
        mobSummary = mobTotals,
    }
end

-- Calculate aggregate statistics across multiple sessions
-- Returns trend data including averages and totals
function SessionData:CalculateTrendStatistics(sessions)
    if not sessions or #sessions == 0 then
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
    
    local totalSessions = #sessions
    local totalDuration = 0
    local totalCurrency = 0
    local totalXP = 0
    local bestCopperPerHour = 0
    local totalXPNonMaxLevel = 0
    local totalDurationNonMaxLevel = 0
    local bestXPPerHour = 0
    local inv3600 = 1 / 3600  -- Pre-calculate division constant
    
    -- Single-pass accumulation
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

-- Filter sessions by various criteria
-- Returns a new array containing only sessions that match all provided filters
function SessionData:FilterSessions(sessions, filters)
    if not sessions then
        return {}
    end
    
    if not filters then
        return sessions
    end
    
    local filterText = filters.text or ""
    local filterClasses = filters.classes or {}
    local filterRaces = filters.races or {}
    local filterRealms = filters.realms or {}
    
    -- Early exit if no filters
    if filterText == "" and #filterClasses == 0 and #filterRaces == 0 and #filterRealms == 0 then
        return sessions
    end
    
    local filtered = {}
    local filterTextLower = filterText ~= "" and filterText:lower() or nil
    local count = 0
    
    -- Build lookup tables for multi-select filters
    local classLookup = {}
    for _, class in ipairs(filterClasses) do
        classLookup[class] = true
    end
    
    local raceLookup = {}
    for _, race in ipairs(filterRaces) do
        raceLookup[race] = true
    end
    
    local realmLookup = {}
    for _, realm in ipairs(filterRealms) do
        realmLookup[realm] = true
    end
    
    -- Single-pass filtering with early exits
    for i = 1, #sessions do
        local session = sessions[i]
        local char = session.character
        local shouldInclude = true
        
        -- Multi-select class filter
        if shouldInclude and #filterClasses > 0 then
            shouldInclude = char and classLookup[char.class]
        end
        
        -- Multi-select race filter
        if shouldInclude and #filterRaces > 0 then
            shouldInclude = char and raceLookup[char.race]
        end
        
        -- Multi-select realm filter
        if shouldInclude and #filterRealms > 0 then
            shouldInclude = char and realmLookup[char.realm]
        end
        
        -- Text search last (most expensive) - exact match only
        if shouldInclude and filterTextLower then
            local charName = char and char.name or "Unknown"
            shouldInclude = charName:lower() == filterTextLower
        end
        
        if shouldInclude then
            count = count + 1
            filtered[count] = session
        end
    end
    
    return filtered
end

_G.GC_SessionData = SessionData
return SessionData
