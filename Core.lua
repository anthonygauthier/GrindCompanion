local addonName = ...

local GrindCompanion = CreateFrame("Frame")
_G.GrindCompanion = GrindCompanion

-- Load core modules
local Formatter = require("core.formatting.Formatter")
local MobStats = require("core.aggregation.MobStats")

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
    return MobStats:CopyQualityCounts(source, target)
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
    -- Get quality colors from WoW API
    local qualityColors = {}
    for quality in pairs(self.QUALITY_LABELS) do
        if ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[quality] and ITEM_QUALITY_COLORS[quality].hex then
            qualityColors[quality] = ITEM_QUALITY_COLORS[quality].hex
        else
            qualityColors[quality] = self.QUALITY_COLOR_FALLBACK[quality]
        end
    end
    
    return Formatter:FormatQualitySummary(counts, self.QUALITY_LABELS, qualityColors)
end

function GrindCompanion:FormatTime(seconds)
    return Formatter:FormatTime(seconds)
end

function GrindCompanion:FormatCoin(copper, options)
    return Formatter:FormatCoin(copper, options, self.COIN_COLORS)
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

function GrindCompanion:ProcessPendingGrayItems()
    if not self.pendingGrayItems or #self.pendingGrayItems == 0 then
        return
    end
    
    local remaining = {}
    for _, item in ipairs(self.pendingGrayItems) do
        local sellPrice = select(11, GetItemInfo(item.link))
        if sellPrice and sellPrice > 0 then
            local total = sellPrice * item.quantity
            self.grayCopper = (self.grayCopper or 0) + total
            self.levelGrayCopper = (self.levelGrayCopper or 0) + total
        else
            -- Still not cached, keep for next attempt
            table.insert(remaining, item)
        end
    end
    
    self.pendingGrayItems = remaining
end

function GrindCompanion:ProcessPendingLootItems()
    if not self.pendingLootItems or #self.pendingLootItems == 0 then
        return
    end
    
    local remaining = {}
    for _, item in ipairs(self.pendingLootItems) do
        local quality = select(3, GetItemInfo(item.link))
        if quality then
            quality = tonumber(quality)
            -- Now we know the quality, process it
            if quality == 0 then
                local sellPrice = select(11, GetItemInfo(item.link))
                if sellPrice and sellPrice > 0 then
                    local itemValue = sellPrice * item.quantity
                    self.grayCopper = (self.grayCopper or 0) + itemValue
                    self.levelGrayCopper = (self.levelGrayCopper or 0) + itemValue
                    
                    -- Track for current mob
                    local currentMob = self.currentMobForLoot
                    if currentMob and self.mobStats and self.mobStats[currentMob] then
                        self.mobStats[currentMob].currency = self.mobStats[currentMob].currency + itemValue
                    end
                end
            end
            
            self:AddAuctionValue(item.link, item.quantity, quality)
            self:RecordQualityLoot(quality, item.quantity, item.link)
        else
            -- Still not cached, keep for next attempt
            table.insert(remaining, item)
        end
    end
    
    self.pendingLootItems = remaining
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
