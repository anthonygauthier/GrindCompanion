local addonName = ...

local GrindCompanion = CreateFrame("Frame")
_G.GrindCompanion = GrindCompanion

GrindCompanion.COPPER_PER_GOLD = 10000
GrindCompanion.COPPER_PER_SILVER = 100

GrindCompanion.COIN_COLORS = {
    gold = "|cffffd700",
    silver = "|cffc7c7cf",
    copper = "|cffb87333",
}

GrindCompanion.QUALITY_LABELS = {
    [2] = "Green",
    [3] = "Blue",
    [4] = "Purple",
}

GrindCompanion.QUALITY_COLOR_FALLBACK = {
    [2] = "|cff1eff00",
    [3] = "|cff0070dd",
    [4] = "|cffa335ee",
}

function GrindCompanion:GetAddonName()
    return addonName
end

function GrindCompanion:GetMaxPlayerLevelSafe()
    if type(GetMaxPlayerLevel) == "function" then
        local ok, level = pcall(GetMaxPlayerLevel)
        if ok and level then
            return level
        end
    end
    return MAX_PLAYER_LEVEL or 60
end

-- Optimized: Reuse table to avoid allocations
function GrindCompanion:CopyQualityCounts(source, target)
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

function GrindCompanion:ColorizeQualityLabel(quality, label)
    if not label then
        return ""
    end
    local colorCode = self.QUALITY_COLOR_FALLBACK[quality]
    if ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[quality] and ITEM_QUALITY_COLORS[quality].hex then
        colorCode = ITEM_QUALITY_COLORS[quality].hex
    end
    colorCode = colorCode or "|cffffffff"
    return string.format("%s%s|r", colorCode, label)
end

function GrindCompanion:FormatQualitySummary(counts)
    local parts = {}
    for quality, label in pairs(self.QUALITY_LABELS) do
        local amount = counts and counts[quality] or 0
        local coloredLabel = self:ColorizeQualityLabel(quality, label)
        table.insert(parts, string.format("%s: %d", coloredLabel, amount))
    end
    return table.concat(parts, " | ")
end

function GrindCompanion:FormatTime(seconds)
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

function GrindCompanion:FormatCoin(copper, options)
    options = options or {}
    copper = math.floor(copper or 0)
    local gold = math.floor(copper / self.COPPER_PER_GOLD)
    local silver = math.floor((copper % self.COPPER_PER_GOLD) / self.COPPER_PER_SILVER)
    local remainingCopper = copper % self.COPPER_PER_SILVER
    local segments = {}
    local separator = options.separator or ""
    local showZeros = options.showZeros

    if gold > 0 or showZeros then
        table.insert(segments, string.format("%s%dg|r", self.COIN_COLORS.gold, gold))
    end
    if silver > 0 or gold > 0 or showZeros then
        table.insert(segments, string.format("%s%ds|r", self.COIN_COLORS.silver, silver))
    end
    table.insert(segments, string.format("%s%dc|r", self.COIN_COLORS.copper, remainingCopper))

    return table.concat(segments, separator)
end

function GrindCompanion:FormatCoinWithIcons(copper)
    copper = math.floor(copper or 0)
    local gold = math.floor(copper / self.COPPER_PER_GOLD)
    local silver = math.floor((copper % self.COPPER_PER_GOLD) / self.COPPER_PER_SILVER)
    local remainingCopper = copper % self.COPPER_PER_SILVER
    local segments = {}
    
    local goldIcon = "|TInterface\\MoneyFrame\\UI-GoldIcon:0:0:2:0|t"
    local silverIcon = "|TInterface\\MoneyFrame\\UI-SilverIcon:0:0:2:0|t"
    local copperIcon = "|TInterface\\MoneyFrame\\UI-CopperIcon:0:0:2:0|t"

    if gold > 0 then
        table.insert(segments, string.format("%s%d%s|r", self.COIN_COLORS.gold, gold, goldIcon))
    end
    if silver > 0 or gold > 0 then
        table.insert(segments, string.format("%s%d%s|r", self.COIN_COLORS.silver, silver, silverIcon))
    end
    table.insert(segments, string.format("%s%d%s|r", self.COIN_COLORS.copper, remainingCopper, copperIcon))

    return table.concat(segments, " ")
end

function GrindCompanion:ParseCoinFromMessage(message)
    local total = 0
    local gold = message:match("(%d+)%s-[Gg]old")
    local silver = message:match("(%d+)%s-[Ss]ilver")
    local copper = message:match("(%d+)%s-[Cc]opper")

    if gold then
        total = total + tonumber(gold) * self.COPPER_PER_GOLD
    end
    if silver then
        total = total + tonumber(silver) * self.COPPER_PER_SILVER
    end
    if copper then
        total = total + tonumber(copper)
    end

    return total
end

function GrindCompanion:PrintMessage(text)
    DEFAULT_CHAT_FRAME:AddMessage(string.format("|cff33ff99GrindCompanion:|r %s", text))
end

function GrindCompanion:AddGrayVendorValue(link, quantity)
    if not link then
        return
    end
    quantity = math.max(1, tonumber(quantity) or 1)
    local sellPrice = select(11, GetItemInfo(link))
    if not sellPrice or sellPrice <= 0 then
        return
    end
    local total = sellPrice * quantity
    self.grayCopper = (self.grayCopper or 0) + total
    self.levelGrayCopper = (self.levelGrayCopper or 0) + total
end

function GrindCompanion:FormatCopperPerHour(copper, duration)
    copper = tonumber(copper) or 0
    duration = tonumber(duration) or 0
    
    if duration <= 0 then
        return "N/A"
    end
    
    local copperPerHour = math.floor((copper / duration) * 3600)
    return self:FormatCoin(copperPerHour) .. "/hr"
end

function GrindCompanion:FormatXPPerHour(xp, duration)
    xp = tonumber(xp) or 0
    duration = tonumber(duration) or 0
    
    if duration <= 0 then
        return "N/A"
    end
    
    local xpPerHour = math.floor((xp / duration) * 3600)
    return self:FormatNumber(xpPerHour) .. "/hr"
end

function GrindCompanion:EnsureSavedVariables()
    GrindCompanionDB = GrindCompanionDB or {}
    GrindCompanionDB.sessions = GrindCompanionDB.sessions or {}
end
