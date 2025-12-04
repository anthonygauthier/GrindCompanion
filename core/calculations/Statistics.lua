local Statistics = {}

-- Calculate elapsed time between start and end times
-- @param startTime number - Start time in seconds
-- @param endTime number - End time in seconds (optional, defaults to 0)
-- @param isTracking boolean - Whether tracking is currently active
-- @return number - Elapsed time in seconds
function Statistics:CalculateElapsedTime(startTime, endTime, isTracking)
    if not startTime then
        return 0
    end
    
    -- If tracking, use endTime as current time
    if isTracking then
        return (endTime or 0) - startTime
    end
    
    -- If stopped, use the difference
    if endTime then
        return endTime - startTime
    end
    
    return 0
end

-- Calculate rate per hour
-- @param amount number - Total amount (XP, copper, etc.)
-- @param durationSeconds number - Duration in seconds
-- @return number - Amount per hour
function Statistics:CalculatePerHour(amount, durationSeconds)
    if not amount or not durationSeconds or durationSeconds <= 0 then
        return 0
    end
    
    return (amount / durationSeconds) * 3600
end

-- Calculate estimated time to level
-- @param currentXP number - Current XP amount
-- @param maxXP number - Maximum XP for current level
-- @param totalXPGained number - Total XP gained in session
-- @param elapsedSeconds number - Elapsed time in seconds
-- @return number|nil - Estimated seconds to level, or nil if cannot calculate
function Statistics:CalculateTimeToLevel(currentXP, maxXP, totalXPGained, elapsedSeconds)
    if not elapsedSeconds or elapsedSeconds <= 0 or not totalXPGained or totalXPGained <= 0 then
        return nil
    end
    
    local xpRemaining = (maxXP or 0) - (currentXP or 0)
    if xpRemaining <= 0 then
        return nil
    end
    
    local xpPerSecond = totalXPGained / elapsedSeconds
    if xpPerSecond <= 0 then
        return nil
    end
    
    return xpRemaining / xpPerSecond
end

-- Calculate estimated kills remaining to level
-- @param currentXP number - Current XP amount
-- @param maxXP number - Maximum XP for current level
-- @param totalXPGained number - Total XP gained in session
-- @param totalKills number - Total kills in session
-- @return number|nil - Estimated kills remaining, or nil if cannot calculate
function Statistics:CalculateKillsRemaining(currentXP, maxXP, totalXPGained, totalKills)
    if not totalKills or totalKills <= 0 or not totalXPGained or totalXPGained <= 0 then
        return nil
    end
    
    local xpRemaining = (maxXP or 0) - (currentXP or 0)
    if xpRemaining <= 0 then
        return nil
    end
    
    local xpPerKill = totalXPGained / totalKills
    if xpPerKill <= 0 then
        return nil
    end
    
    return math.ceil(xpRemaining / xpPerKill)
end

_G.GC_Statistics = Statistics
return Statistics
