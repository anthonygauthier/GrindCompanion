local addonName = ...
local GrindCalculator = CreateFrame("Frame")

local COPPER_PER_GOLD = 10000
local COPPER_PER_SILVER = 100

local COIN_COLORS = {
    gold = "|cffffd700",
    silver = "|cffc7c7cf",
    copper = "|cffb87333",
}

local QUALITY_LABELS = {
    [2] = "Green",
    [3] = "Blue",
    [4] = "Purple",
}

local QUALITY_COLOR_FALLBACK = {
    [2] = "|cff1eff00",
    [3] = "|cff0070dd",
    [4] = "|cffa335ee",
}

local function colorizeQualityLabel(quality, label)
    if not label then
        return ""
    end
    local colorCode = QUALITY_COLOR_FALLBACK[quality]
    if ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[quality] and ITEM_QUALITY_COLORS[quality].hex then
        colorCode = ITEM_QUALITY_COLORS[quality].hex
    end
    colorCode = colorCode or "|cffffffff"
    return string.format("%s%s|r", colorCode, label)
end

local function formatTime(seconds)
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

local function formatCoin(copper, options)
    options = options or {}
    copper = math.floor(copper or 0)
    local gold = math.floor(copper / COPPER_PER_GOLD)
    local silver = math.floor((copper % COPPER_PER_GOLD) / COPPER_PER_SILVER)
    local remainingCopper = copper % COPPER_PER_SILVER
    local segments = {}
    local separator = options.separator or ""
    local showZeros = options.showZeros

    if gold > 0 or showZeros then
        table.insert(segments, string.format("%s%dg|r", COIN_COLORS.gold, gold))
    end
    if silver > 0 or gold > 0 or showZeros then
        table.insert(segments, string.format("%s%ds|r", COIN_COLORS.silver, silver))
    end
    table.insert(segments, string.format("%s%dc|r", COIN_COLORS.copper, remainingCopper))

    return table.concat(segments, separator)
end

local function parseCoinFromMessage(message)
    local total = 0
    local gold = message:match("(%d+)%s-[Gg]old")
    local silver = message:match("(%d+)%s-[Ss]ilver")
    local copper = message:match("(%d+)%s-[Cc]opper")

    if gold then
        total = total + tonumber(gold) * COPPER_PER_GOLD
    end
    if silver then
        total = total + tonumber(silver) * COPPER_PER_SILVER
    end
    if copper then
        total = total + tonumber(copper)
    end

    return total
end

local function printMessage(text)
    DEFAULT_CHAT_FRAME:AddMessage(string.format("|cff33ff99GrindCalculator:|r %s", text))
end

function GrindCalculator:InitializeDisplayFrame()
    if self.displayFrame then
        return
    end

    local backdropTemplate = BackdropTemplateMixin and "BackdropTemplate" or nil
    local frame = CreateFrame("Frame", "GrindCalculatorFrame", UIParent, backdropTemplate)
    frame:SetSize(240, 200)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 14,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    frame:SetBackdropColor(0.015, 0.015, 0.015, 0.98)
    frame:SetBackdropBorderColor(0, 0.78, 1, 1)

    local header = frame:CreateTexture(nil, "OVERLAY")
    header:SetColorTexture(0.04, 0.04, 0.04, 1)
    header:SetPoint("TOPLEFT", frame, "TOPLEFT", 5, -5)
    header:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)
    header:SetHeight(22)

    local accent = frame:CreateTexture(nil, "OVERLAY")
    accent:SetColorTexture(0, 0.8, 1, 0.9)
    accent:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -1)
    accent:SetPoint("TOPRIGHT", header, "BOTTOMRIGHT", 0, -1)
    accent:SetHeight(2)

    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.title:SetPoint("CENTER", header, "CENTER", 0, -1)
    frame.title:SetText("|cff00ffffGrind ETA|r")

    frame.timeLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.timeLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -36)
    frame.timeLabel:SetText("Estimated Time")
    frame.timeLabel:SetTextColor(0.85, 0.95, 1)

    frame.timeText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    frame.timeText:SetFont("Fonts\\ARIALN.TTF", 20, "OUTLINE")
    frame.timeText:SetPoint("TOPLEFT", frame.timeLabel, "BOTTOMLEFT", 0, -6)
    frame.timeText:SetJustifyH("LEFT")
    frame.timeText:SetText("Waiting...")
    frame.timeText:SetTextColor(1, 1, 1)
    frame.timeText:SetShadowColor(0, 0, 0, 1)
    frame.timeText:SetShadowOffset(1, -1)

    local timeBackdrop = frame:CreateTexture(nil, "BACKGROUND")
    timeBackdrop:SetColorTexture(0, 0, 0, 0.85)
    timeBackdrop:SetPoint("TOPLEFT", frame.timeText, "TOPLEFT", -12, 8)
    timeBackdrop:SetPoint("BOTTOMRIGHT", frame.timeText, "BOTTOMRIGHT", 12, -8)
    timeBackdrop:SetDrawLayer("BACKGROUND", 2)

    frame.currencyLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.currencyLabel:SetPoint("TOPLEFT", frame.timeText, "BOTTOMLEFT", 0, -14)
    frame.currencyLabel:SetText("Currency Earned")
    frame.currencyLabel:SetTextColor(0.85, 0.95, 1)

    frame.currencyText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    frame.currencyText:SetFont("Fonts\\ARIALN.TTF", 16, "OUTLINE")
    frame.currencyText:SetPoint("TOPLEFT", frame.currencyLabel, "BOTTOMLEFT", 0, -6)
    frame.currencyText:SetJustifyH("LEFT")
    frame.currencyText:SetText(formatCoin(0, { separator = " " }))
    frame.currencyText:SetTextColor(1, 1, 1)
    frame.currencyText:SetShadowColor(0, 0, 0, 1)
    frame.currencyText:SetShadowOffset(1, -1)

    local currencyBackdrop = frame:CreateTexture(nil, "BACKGROUND")
    currencyBackdrop:SetColorTexture(0, 0, 0, 0.75)
    currencyBackdrop:SetPoint("TOPLEFT", frame.currencyText, "TOPLEFT", -10, 6)
    currencyBackdrop:SetPoint("BOTTOMRIGHT", frame.currencyText, "BOTTOMRIGHT", 10, -6)
    currencyBackdrop:SetDrawLayer("BACKGROUND", 2)

    frame.mobLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.mobLabel:SetPoint("TOPLEFT", frame.currencyText, "BOTTOMLEFT", 0, -14)
    frame.mobLabel:SetText("Estimated Kills Remaining")
    frame.mobLabel:SetTextColor(0.85, 0.95, 1)

    frame.mobText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    frame.mobText:SetFont("Fonts\\ARIALN.TTF", 16, "OUTLINE")
    frame.mobText:SetPoint("TOPLEFT", frame.mobLabel, "BOTTOMLEFT", 0, -6)
    frame.mobText:SetJustifyH("LEFT")
    frame.mobText:SetText("N/A")
    frame.mobText:SetTextColor(1, 1, 1)
    frame.mobText:SetShadowColor(0, 0, 0, 1)
    frame.mobText:SetShadowOffset(1, -1)

    local killsBackdrop = frame:CreateTexture(nil, "BACKGROUND")
    killsBackdrop:SetColorTexture(0, 0, 0, 0.75)
    killsBackdrop:SetPoint("TOPLEFT", frame.mobText, "TOPLEFT", -10, 6)
    killsBackdrop:SetPoint("BOTTOMRIGHT", frame.mobText, "BOTTOMRIGHT", 10, -6)
    killsBackdrop:SetDrawLayer("BACKGROUND", 2)

    frame:SetScript("OnUpdate", function(_, elapsed)
        self.elapsedSinceUpdate = (self.elapsedSinceUpdate or 0) + elapsed
        if self.elapsedSinceUpdate >= 1 then
            self.elapsedSinceUpdate = 0
            self:RefreshDisplay()
        end
    end)

    frame:Hide()

    self.displayFrame = frame
end

function GrindCalculator:ResetStats()
    self.startTime = GetTime()
    self.stopTime = nil
    self.totalXP = 0
    self.killCount = 0
    self.currencyCopper = 0
    self.lootWindowOpen = false
    if self.lootSlotCache then
        wipe(self.lootSlotCache)
    end
    self.lootQualityCount = {
        [2] = 0,
        [3] = 0,
        [4] = 0,
    }
    self:ResetLevelStats()
end

function GrindCalculator:ResetLevelStats()
    self.levelStartTime = GetTime()
    self.levelXP = 0
    self.levelKillCount = 0
    self.levelCurrencyCopper = 0
    self.levelLootQualityCount = {
        [2] = 0,
        [3] = 0,
        [4] = 0,
    }
end

function GrindCalculator:StartTracking()
    if self.isTracking then
        printMessage("Already tracking. Use /gc stats to see the current run.")
        return
    end

    self.isTracking = true
    self:ResetStats()
    if self.displayFrame then
        self.displayFrame:Show()
    end
    self.elapsedSinceUpdate = 0
    self:RefreshDisplay()
    printMessage("Tracking started. Go grind some mobs!")
end

function GrindCalculator:StopTracking()
    if not self.isTracking then
        printMessage("Tracking is not running. Use /gc start first.")
        return
    end

    self.isTracking = false
    self.stopTime = GetTime()
    if self.displayFrame then
        self.displayFrame:Hide()
    end
    printMessage("Tracking paused. Use /gc stats to review the session.")
end

function GrindCalculator:GetElapsedTime()
    if not self.startTime then
        return 0
    end

    if self.isTracking then
        return GetTime() - self.startTime
    end

    if self.stopTime then
        return self.stopTime - self.startTime
    end

    return 0
end

function GrindCalculator:CalculateTimeToLevel()
    local elapsed = self:GetElapsedTime()
    if elapsed <= 0 or (self.totalXP or 0) <= 0 then
        return nil
    end

    local xpRemaining = UnitXPMax("player") - UnitXP("player")
    if xpRemaining <= 0 then
        return nil
    end

    local xpPerSecond = self.totalXP / elapsed
    if xpPerSecond <= 0 then
        return nil
    end

    return xpRemaining / xpPerSecond
end

function GrindCalculator:CalculateKillsRemaining()
    if (self.killCount or 0) <= 0 or (self.totalXP or 0) <= 0 then
        return nil
    end

    local xpRemaining = UnitXPMax("player") - UnitXP("player")
    if xpRemaining <= 0 then
        return nil
    end

    local xpPerKill = self.totalXP / self.killCount
    if xpPerKill <= 0 then
        return nil
    end

    return math.ceil(xpRemaining / xpPerKill)
end

function GrindCalculator:PrintStats()
    if not self.startTime then
        printMessage("No session data. Use /gc start to begin tracking.")
        return
    end

    local elapsed = self:GetElapsedTime()
    local xpPerKill = (self.killCount > 0 and math.floor(self.totalXP / self.killCount) or 0)
    local xpPerHour = (elapsed > 0 and math.floor((self.totalXP / elapsed) * 3600) or 0)
    local timeToLevel = self:CalculateTimeToLevel()
    local lootSummary = {}

    for quality, label in pairs(QUALITY_LABELS) do
        local amount = self.lootQualityCount[quality] or 0
        local coloredLabel = colorizeQualityLabel(quality, label)
        table.insert(lootSummary, string.format("%s: %d", coloredLabel, amount))
    end

    printMessage(string.format(
        "Elapsed: %s | XP: %d | Kills: %d | XP/Kill: %d | XP/Hr: %d",
        formatTime(elapsed),
        self.totalXP,
        self.killCount,
        xpPerKill,
        xpPerHour
    ))

    if timeToLevel then
        printMessage(string.format("Estimated time to level: %s", formatTime(timeToLevel)))
    else
        printMessage("Need more data to estimate time to level.")
    end

    printMessage(string.format("Coins: %s | %s", formatCoin(self.currencyCopper), table.concat(lootSummary, " | ")))
end

function GrindCalculator:PrintLevelSummary(completedLevel)
    if not self.levelStartTime then
        return
    end

    local elapsed = math.max(0, GetTime() - self.levelStartTime)
    local xpPerKill = (self.levelKillCount > 0 and math.floor(self.levelXP / self.levelKillCount) or 0)
    local xpPerHour = (elapsed > 0 and math.floor((self.levelXP / elapsed) * 3600) or 0)
    local lootSummary = {}

    for quality, label in pairs(QUALITY_LABELS) do
        local amount = (self.levelLootQualityCount and self.levelLootQualityCount[quality]) or 0
        local coloredLabel = colorizeQualityLabel(quality, label)
        table.insert(lootSummary, string.format("%s: %d", coloredLabel, amount))
    end

    printMessage(string.format(
        "Level %d summary - Time: %s | XP: %d | Kills: %d | XP/Kill: %d | XP/Hr: %d",
        completedLevel or math.max((UnitLevel("player") or 1) - 1, 0),
        formatTime(elapsed),
        self.levelXP or 0,
        self.levelKillCount or 0,
        xpPerKill,
        xpPerHour
    ))

    printMessage(string.format(
        "Level %d loot - Coins: %s | %s",
        completedLevel or math.max((UnitLevel("player") or 1) - 1, 0),
        formatCoin(self.levelCurrencyCopper or 0),
        table.concat(lootSummary, " | ")
    ))
end

function GrindCalculator:RefreshDisplay()
    if not self.displayFrame or not self.displayFrame:IsShown() then
        return
    end

    if self.displayFrame.currencyText then
        self.displayFrame.currencyText:SetText(formatCoin(self.currencyCopper, { separator = " " }))
    end

    if self.displayFrame.mobText then
        local killsRemaining = self:CalculateKillsRemaining()
        if killsRemaining then
            local label = (killsRemaining == 1) and "1 mob" or (killsRemaining .. " mobs")
            self.displayFrame.mobText:SetText(label)
        else
            self.displayFrame.mobText:SetText("Need data")
        end
    end

    if not self.isTracking then
        self.displayFrame.timeText:SetText("Paused")
        return
    end

    local eta = self:CalculateTimeToLevel()
    if not eta then
        self.displayFrame.timeText:SetText("Gathering data...")
    elseif eta <= 0 then
        self.displayFrame.timeText:SetText("Level up!")
    else
        self.displayFrame.timeText:SetText(formatTime(eta))
    end
end

function GrindCalculator:HandleCombatXPGain(message)
    local gainedXP = message:match("(%d+)%s+experience")
    if not gainedXP then
        return
    end

    local xpAmount = tonumber(gainedXP)
    self.totalXP = self.totalXP + xpAmount
    self.killCount = self.killCount + 1
    self.levelXP = (self.levelXP or 0) + xpAmount
    self.levelKillCount = (self.levelKillCount or 0) + 1
end

function GrindCalculator:RecordQualityLoot(quality, quantity)
    if not quality or not QUALITY_LABELS[quality] then
        return
    end

    local amount = math.max(1, tonumber(quantity) or 1)
    self.lootQualityCount[quality] = (self.lootQualityCount[quality] or 0) + amount
    if self.levelLootQualityCount then
        self.levelLootQualityCount[quality] = (self.levelLootQualityCount[quality] or 0) + amount
    end
end

function GrindCalculator:CacheLootSlots()
    if not self.isTracking then
        return
    end

    if not self.lootSlotCache then
        self.lootSlotCache = {}
    else
        wipe(self.lootSlotCache)
    end

    local numLootItems = GetNumLootItems() or 0
    for slot = 1, numLootItems do
        local slotType = GetLootSlotType and GetLootSlotType(slot)
        if LootSlotHasItem(slot) and (not slotType or slotType == LOOT_SLOT_ITEM) then
            local _, _, quantity, quality = GetLootSlotInfo(slot)
            local link = GetLootSlotLink(slot)
            if (not quality or not QUALITY_LABELS[quality]) and link then
                local _, _, linkQuality = GetItemInfoInstant(link)
                quality = linkQuality or quality
            end
            self.lootSlotCache[slot] = {
                quality = quality,
                quantity = quantity or 1,
            }
        end
    end
end

function GrindCalculator:HandleLootSlotCleared(slot)
    if not self.isTracking or not self.lootSlotCache then
        return
    end

    local slotData = self.lootSlotCache[slot]
    if not slotData then
        return
    end

    self:RecordQualityLoot(slotData.quality, slotData.quantity)
    self.lootSlotCache[slot] = nil
end

function GrindCalculator:HandleLootMessage(message)
    if not message then
        return
    end

    local isPlayerLoot = message:find("^You") or message:find("^Your share of the loot is")
    if not isPlayerLoot then
        return
    end

    local copper = parseCoinFromMessage(message)
    if copper > 0 then
        self.currencyCopper = self.currencyCopper + copper
        self.levelCurrencyCopper = (self.levelCurrencyCopper or 0) + copper
    end

    local itemLink = message:match("(|c%x+|Hitem:.-|h.-|h|r)")
    if itemLink then
        local _, _, quality = GetItemInfoInstant(itemLink)
        if quality and not self.lootWindowOpen then
            self:RecordQualityLoot(quality, 1)
        end
    end
end

function GrindCalculator:HandleLevelUp(newLevel)
    local completedLevel = (tonumber(newLevel) or (UnitLevel("player") or 1)) - 1
    if completedLevel < 1 then
        completedLevel = math.max(completedLevel, 0)
    end

    self:PrintLevelSummary(completedLevel)
    self:ResetLevelStats()
end

function GrindCalculator:OnEvent(event, ...)
    if event == "ADDON_LOADED" then
        local name = ...
        if name ~= addonName then
            return
        end

        SlashCmdList["GRINDCALC"] = function(msg)
            self:HandleSlashCommand(msg)
        end
        SLASH_GRINDCALC1 = "/gc"

        self:InitializeDisplayFrame()
        printMessage("Loaded. Use /gc start to begin tracking.")
    elseif not self.isTracking then
        return
    elseif event == "CHAT_MSG_COMBAT_XP_GAIN" then
        local message = ...
        self:HandleCombatXPGain(message)
    elseif event == "CHAT_MSG_LOOT" or event == "CHAT_MSG_MONEY" then
        local message = ...
        self:HandleLootMessage(message)
    elseif event == "LOOT_READY" then
        self:CacheLootSlots()
    elseif event == "LOOT_OPENED" then
        self.lootWindowOpen = self.isTracking and true or false
        self:CacheLootSlots()
    elseif event == "LOOT_SLOT_CLEARED" then
        local slot = ...
        self:HandleLootSlotCleared(slot)
    elseif event == "LOOT_CLOSED" then
        self.lootWindowOpen = false
        if self.lootSlotCache then
            wipe(self.lootSlotCache)
        end
    elseif event == "PLAYER_LEVEL_UP" then
        local newLevel = ...
        self:HandleLevelUp(newLevel)
    end
end

function GrindCalculator:HandleSlashCommand(msg)
    msg = (msg or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")

    if msg == "start" then
        self:StartTracking()
    elseif msg == "stop" then
        self:StopTracking()
    elseif msg == "stats" or msg == "" then
        self:PrintStats()
    else
        printMessage("Commands: /gc start, /gc stop, /gc stats")
    end
end

GrindCalculator:RegisterEvent("ADDON_LOADED")
GrindCalculator:RegisterEvent("CHAT_MSG_COMBAT_XP_GAIN")
GrindCalculator:RegisterEvent("CHAT_MSG_LOOT")
GrindCalculator:RegisterEvent("CHAT_MSG_MONEY")
GrindCalculator:RegisterEvent("PLAYER_LEVEL_UP")
GrindCalculator:RegisterEvent("LOOT_READY")
GrindCalculator:RegisterEvent("LOOT_OPENED")
GrindCalculator:RegisterEvent("LOOT_SLOT_CLEARED")
GrindCalculator:RegisterEvent("LOOT_CLOSED")
GrindCalculator:SetScript("OnEvent", function(self, event, ...)
    self:OnEvent(event, ...)
end)
