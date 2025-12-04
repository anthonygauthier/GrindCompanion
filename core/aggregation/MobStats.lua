-- MobStats: Pure Lua module for mob statistics tracking and aggregation
-- No WoW API dependencies - all data passed as parameters

local MobStats = {}

-- Records a mob kill and updates statistics
-- @param mobName string: Name of the mob
-- @param xpAmount number|nil: XP gained from kill (nil if max level)
-- @param currencyAmount number|nil: Currency gained from kill
-- @param mobStatsTable table: Existing mob stats table to update
-- @return table: Updated mob stats table
function MobStats:RecordKill(mobName, xpAmount, currencyAmount, mobStatsTable)
    mobStatsTable = mobStatsTable or {}
    
    if not mobStatsTable[mobName] then
        mobStatsTable[mobName] = {
            kills = 0,
            currency = 0,
            xp = 0,
            loot = {
                [2] = 0,  -- Uncommon
                [3] = 0,  -- Rare
                [4] = 0,  -- Epic
            },
            highestQualityDrop = nil,
        }
    end
    
    mobStatsTable[mobName].kills = mobStatsTable[mobName].kills + 1
    
    if xpAmount then
        mobStatsTable[mobName].xp = (mobStatsTable[mobName].xp or 0) + xpAmount
    end
    
    if currencyAmount then
        mobStatsTable[mobName].currency = (mobStatsTable[mobName].currency or 0) + currencyAmount
    end
    
    return mobStatsTable
end

-- Calculates aggregate totals across all mobs
-- @param mobStatsTable table: Collection of mob statistics
-- @return table: Summary with totalKills, totalXP, totalCurrency, totalItems
function MobStats:CalculateTotals(mobStatsTable)
    if not mobStatsTable then
        return {
            totalKills = 0,
            totalXP = 0,
            totalCurrency = 0,
            totalItems = {
                [2] = 0,
                [3] = 0,
                [4] = 0,
            },
        }
    end
    
    local totalKills = 0
    local totalXP = 0
    local totalCurrency = 0
    local totalItems = {
        [2] = 0,
        [3] = 0,
        [4] = 0,
    }
    
    for mobName, stats in pairs(mobStatsTable) do
        totalKills = totalKills + (stats.kills or 0)
        totalXP = totalXP + (stats.xp or 0)
        totalCurrency = totalCurrency + (stats.currency or 0)
        
        if stats.loot then
            for quality, count in pairs(stats.loot) do
                totalItems[quality] = (totalItems[quality] or 0) + count
            end
        end
    end
    
    return {
        totalKills = totalKills,
        totalXP = totalXP,
        totalCurrency = totalCurrency,
        totalItems = totalItems,
    }
end

-- Updates highest quality drop if new drop has higher quality
-- @param mobStats table: Stats for a specific mob
-- @param quality number: Quality level of the drop
-- @param link string: Item link
-- @param quantity number: Number of items dropped
function MobStats:UpdateHighestQualityDrop(mobStats, quality, link, quantity)
    if not mobStats then
        return
    end
    
    quality = tonumber(quality)
    quantity = tonumber(quantity) or 1
    
    if not quality or not link then
        return
    end
    
    -- Update if no previous drop or new drop has higher quality
    if not mobStats.highestQualityDrop or quality > mobStats.highestQualityDrop.quality then
        mobStats.highestQualityDrop = {
            quality = quality,
            link = link,
            quantity = quantity,
        }
    end
end

-- Efficiently copies quality count tables
-- @param source table: Source quality counts
-- @param target table|nil: Target table (created if nil)
-- @return table: Target table with copied values
function MobStats:CopyQualityCounts(source, target)
    target = target or {}
    
    if not source then
        return target
    end
    
    -- Clear existing data efficiently
    for k in pairs(target) do
        target[k] = nil
    end
    
    -- Copy new data
    for quality, amount in pairs(source) do
        target[quality] = amount
    end
    
    return target
end

_G.GC_MobStats = MobStats
return MobStats
