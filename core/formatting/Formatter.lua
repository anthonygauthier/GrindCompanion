-- Formatter Module
-- Pure Lua formatting functions with no WoW API dependencies
-- All color codes and constants are passed as parameters

local Formatter = {}

-- Constants
Formatter.COPPER_PER_GOLD = 10000
Formatter.COPPER_PER_SILVER = 100

Formatter.DEFAULT_COIN_COLORS = {
    gold = "|cffffd700",
    silver = "|cffc7c7cf",
    copper = "|cffb87333",
}

Formatter.DEFAULT_QUALITY_LABELS = {
    [2] = "Green",
    [3] = "Blue",
    [4] = "Purple",
}

Formatter.DEFAULT_QUALITY_COLORS = {
    [2] = "|cff1eff00",
    [3] = "|cff0070dd",
    [4] = "|cffa335ee",
}

-- Format copper amount into gold/silver/copper string
-- @param copper: number - Amount in copper
-- @param options: table - Optional formatting options (separator, showZeros)
-- @param colorCodes: table - Optional color codes for gold/silver/copper
-- @return string - Formatted coin string
function Formatter:FormatCoin(copper, options, colorCodes)
    options = options or {}
    colorCodes = colorCodes or self.DEFAULT_COIN_COLORS
    copper = math.max(0, math.floor(copper or 0))
    
    local gold = math.floor(copper / self.COPPER_PER_GOLD)
    local silver = math.floor((copper % self.COPPER_PER_GOLD) / self.COPPER_PER_SILVER)
    local remainingCopper = copper % self.COPPER_PER_SILVER
    local segments = {}
    local separator = options.separator or ""
    local showZeros = options.showZeros

    if gold > 0 or showZeros then
        table.insert(segments, string.format("%s%dg|r", colorCodes.gold, gold))
    end
    if silver > 0 or gold > 0 or showZeros then
        table.insert(segments, string.format("%s%ds|r", colorCodes.silver, silver))
    end
    table.insert(segments, string.format("%s%dc|r", colorCodes.copper, remainingCopper))

    return table.concat(segments, separator)
end

-- Format time in seconds into hours/minutes/seconds string
-- @param seconds: number - Time in seconds
-- @return string - Formatted time string
function Formatter:FormatTime(seconds)
    seconds = math.max(0, math.floor(seconds or 0))
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60
    local parts = {}

    if hours > 0 then
        table.insert(parts, hours .. "h")
    end
    if minutes > 0 or (hours > 0 and secs > 0) then
        table.insert(parts, minutes .. "m")
    end
    table.insert(parts, secs .. "s")

    return table.concat(parts, " ")
end

-- Format quality counts into a summary string
-- @param counts: table - Quality counts {[quality] = count}
-- @param qualityLabels: table - Quality labels {[quality] = label}
-- @param qualityColors: table - Quality color codes {[quality] = colorCode}
-- @return string - Formatted quality summary
function Formatter:FormatQualitySummary(counts, qualityLabels, qualityColors)
    qualityLabels = qualityLabels or self.DEFAULT_QUALITY_LABELS
    qualityColors = qualityColors or self.DEFAULT_QUALITY_COLORS
    counts = counts or {}
    
    local parts = {}
    for quality, label in pairs(qualityLabels) do
        local amount = counts[quality] or 0
        local colorCode = qualityColors[quality] or "|cffffffff"
        local coloredLabel = string.format("%s%s|r", colorCode, label)
        table.insert(parts, string.format("%s: %d", coloredLabel, amount))
    end
    return table.concat(parts, " | ")
end

-- Format large numbers with K/M suffixes
-- @param num: number - Number to format
-- @return string - Formatted number string
function Formatter:FormatNumber(num)
    num = tonumber(num) or 0
    if num >= 1000000 then
        return string.format("%.1fM", num / 1000000)
    elseif num >= 1000 then
        return string.format("%.1fK", num / 1000)
    else
        return tostring(num)
    end
end

_G.GC_Formatter = Formatter
return Formatter
