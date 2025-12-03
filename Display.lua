local GrindCompanion = _G.GrindCompanion

-- ============================================================================
-- Main Display Frame
-- ============================================================================

function GrindCompanion:InitializeDisplayFrame()
    if self.displayFrame then
        return
    end

    local frame = CreateFrame("Frame", "GrindCompanionFrame", UIParent, "PortraitFrameTemplate")
    frame:SetSize(240, 420)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

    frame.TitleText:SetText("Grind Summary")
    SetPortraitToTexture(frame.portrait, "Interface\\LootFrame\\LootPanel-Icon")

    -- Sessions button (below close button)
    local sessionsBtn = CreateFrame("Button", nil, frame)
    local iconSize = 18
    local borderSize = 54
    local clickableSize = 32
    sessionsBtn:SetSize(clickableSize, clickableSize)
    sessionsBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -18, -38)
    
    -- Background mask (circular)
    sessionsBtn.background = sessionsBtn:CreateTexture(nil, "BACKGROUND")
    sessionsBtn.background:SetSize(22, 22)
    sessionsBtn.background:SetPoint("CENTER", sessionsBtn, "CENTER", 0, 0)
    sessionsBtn.background:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
    
    -- Icon
    sessionsBtn.icon = sessionsBtn:CreateTexture(nil, "ARTWORK")
    sessionsBtn.icon:SetSize(iconSize, iconSize)
    sessionsBtn.icon:SetPoint("CENTER", sessionsBtn, "CENTER", 0, 0)
    sessionsBtn.icon:SetTexture("Interface\\Icons\\INV_Misc_Book_09")
    sessionsBtn.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    
    -- Border ring
    sessionsBtn.border = sessionsBtn:CreateTexture(nil, "OVERLAY")
    sessionsBtn.border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    sessionsBtn.border:SetSize(borderSize, borderSize)
    sessionsBtn.border:SetPoint("CENTER", sessionsBtn, "CENTER", 11, -11)
    
    sessionsBtn:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    local ht = sessionsBtn:GetHighlightTexture()
    if ht then
        ht:SetAllPoints(sessionsBtn)
        ht:SetBlendMode("ADD")
    end
    
    sessionsBtn:SetScript("OnClick", function()
        self:ToggleSessionsWindow()
    end)
    
    sessionsBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText("Session History", 1, 1, 1)
        GameTooltip:AddLine("View all saved grinding sessions", nil, nil, nil, true)
        GameTooltip:Show()
    end)
    
    sessionsBtn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    
    frame.sessionsBtn = sessionsBtn

    -- Stop button (to the left of sessions button)
    local stopBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    stopBtn:SetSize(90, 22)
    stopBtn:SetPoint("RIGHT", sessionsBtn, "LEFT", -8, 0)
    stopBtn:SetText("Stop Session")
    
    stopBtn:SetScript("OnClick", function()
        self:StopTracking()
    end)
    
    frame.stopBtn = stopBtn

    local inset = CreateFrame("Frame", nil, frame, "InsetFrameTemplate3")
    inset:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -74)
    inset:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 12)
    frame.inset = inset

    self.displayRows = {}
    self.rowOrder = {
        "timer",
        "eta",
        "kills",
        "currency",
        "gray",
        "items",
        "ah",
        "total",
    }

    local function createRow(key, labelText, iconTexture)
        local index = #self.displayRows + 1
        local name = "GrindCompanionLootRow" .. index
        local row = CreateFrame("Button", name, inset)
        row:SetHeight(40)
        
        -- Background texture
        row.Background = row:CreateTexture(nil, "BACKGROUND")
        row.Background:SetAllPoints(row)
        row.Background:SetTexture("Interface\\LootFrame\\UI-LootSlot-Background")
        row.Background:SetTexCoord(0, 0.640625, 0, 0.625)
        
        -- Icon
        row.Icon = row:CreateTexture(nil, "ARTWORK")
        row.Icon:SetTexture(iconTexture or "Interface\\Icons\\INV_Misc_QuestionMark")
        row.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        row.Icon:SetSize(32, 32)
        row.Icon:SetPoint("LEFT", row, "LEFT", 8, 0)
        
        -- Icon border
        row.IconBorder = row:CreateTexture(nil, "OVERLAY")
        row.IconBorder:SetTexture("Interface\\Common\\WhiteIconFrame")
        row.IconBorder:SetSize(42, 42)
        row.IconBorder:SetPoint("CENTER", row.Icon, "CENTER", 0, 0)
        row.IconBorder:SetVertexColor(0.7, 0.7, 0.7)
        
        -- Count text (on icon)
        row.Count = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        row.Count:SetPoint("BOTTOMRIGHT", row.Icon, "BOTTOMRIGHT", 0, 2)
        row.Count:Hide()
        
        -- Label text (top line)
        row.Label = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        row.Label:SetPoint("TOPLEFT", row.Icon, "TOPRIGHT", 6, -4)
        row.Label:SetPoint("TOPRIGHT", row, "TOPRIGHT", -6, -4)
        row.Label:SetText(labelText)
        row.Label:SetJustifyH("LEFT")
        row.Label:SetWordWrap(false)
        if HIGHLIGHT_FONT_COLOR then
            row.Label:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
        end
        
        -- Value text (bottom line)
        row.Value = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        row.Value:SetPoint("BOTTOMLEFT", row.Icon, "BOTTOMRIGHT", 6, 4)
        row.Value:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", -6, 4)
        row.Value:SetText("")
        row.Value:SetJustifyH("LEFT")
        row.Value:SetWordWrap(false)
        
        -- Highlight texture
        row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
        local ht = row:GetHighlightTexture()
        if ht then
            ht:SetAllPoints(row)
            ht:SetBlendMode("ADD")
            ht:SetAlpha(0.25)
        end
        
        row:Hide()
        row.key = key
        self.displayRows[key] = row
    end

    createRow("timer", "Session Time", "Interface\\Icons\\INV_Misc_PocketWatch_01")
    createRow("eta", "ETA to Level", "Interface\\Icons\\INV_Misc_PocketWatch_02")
    createRow("kills", "Kills Remaining", "Interface\\Icons\\INV_Sword_04")
    createRow("currency", "Currency Earned", "Interface\\Icons\\INV_Misc_Coin_01")
    createRow("gray", "Gray Vendor Value", "Interface\\Icons\\INV_Misc_Pelt_Wolf_Ruin_01")
    createRow("items", "Notable Items", "Interface\\Icons\\INV_Misc_Bag_08")
    createRow("ah", "AH Value", "Interface\\Icons\\INV_Misc_Coin_02")
    createRow("total", "Total", "Interface\\Icons\\INV_Misc_Bag_10_Green")
    
    -- Set up click handler for items row
    if self.displayRows.items then
        self.displayRows.items:SetScript("OnClick", function()
            self:ToggleItemDetailWindow()
        end)
    end

    frame:SetScript("OnUpdate", function(_, elapsed)
        self.elapsedSinceUpdate = (self.elapsedSinceUpdate or 0) + elapsed
        if self.elapsedSinceUpdate >= 1 then
            self.elapsedSinceUpdate = 0
            self:ProcessPendingLootItems()
            self:ProcessPendingGrayItems()
            self:RefreshDisplay()
        end
    end)

    frame:Hide()

    self.displayFrame = frame
    self:SetDisplayMode("progress")
end


function GrindCompanion:ApplyRowVisibility()
    if not self.displayFrame then
        return
    end

    local frame = self.displayFrame
    local isMaxLevel = (frame.mode == "loot")
    
    for key, row in pairs(self.displayRows or {}) do
        local showRow = true
        
        -- Check user settings first
        if not self:ShouldShowRow(key) then
            showRow = false
        elseif key == "eta" or key == "kills" then
            -- Only hide ETA/Kills at max level if user hasn't disabled them
            showRow = not isMaxLevel
        end
        
        if row then
            if showRow then row:Show() else row:Hide() end
        end
    end
    self:UpdateRowLayout()
end

function GrindCompanion:SetDisplayMode(mode)
    if not self.displayFrame then
        return
    end

    if self.displayFrame.mode == mode then
        return
    end

    local frame = self.displayFrame
    frame.mode = mode

    if frame.TitleText then
        frame.TitleText:SetText("Grind Summary")
    end
    
    self:ApplyRowVisibility()
end

function GrindCompanion:UpdateRowLayout()
    if not self.displayRows or not self.displayFrame or not self.displayFrame.inset then
        return
    end

    local inset = self.displayFrame.inset
    local y = 8
    local visibleCount = 0
    local insetWidth = inset:GetWidth()
    
    for _, key in ipairs(self.rowOrder or {}) do
        local row = self.displayRows[key]
        if row and row:IsShown() then
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", inset, "TOPLEFT", 6, -y)
            row:SetPoint("TOPRIGHT", inset, "TOPRIGHT", -6, -y)
            row:SetHeight(40)
            
            -- Ensure the row width is properly constrained
            local rowWidth = insetWidth - 12
            row:SetWidth(rowWidth)
            
            y = y + row:GetHeight() + 8
            visibleCount = visibleCount + 1
        end
    end

    -- Dynamic frame height based on visible rows
    -- 64 = title bar height, 20 = bottom padding, 16 = inset padding (8 top + 8 bottom)
    local contentHeight = (visibleCount * 40) + ((visibleCount - 1) * 8) + 16
    local frameHeight = 64 + contentHeight + 20
    self.displayFrame:SetHeight(frameHeight)
end


function GrindCompanion:FormatTimeDynamic(seconds)
    seconds = math.max(0, math.floor(seconds or 0))
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60
    
    if hours > 0 then
        return string.format("%d:%02d:%02d", hours, minutes, secs)
    else
        return string.format("%d:%02d", minutes, secs)
    end
end

function GrindCompanion:GetCurrencyBorderColor(copper)
    copper = copper or 0
    if copper >= self.COPPER_PER_GOLD then
        -- Gold
        return { r = 1.0, g = 0.84, b = 0.0 }
    elseif copper >= self.COPPER_PER_SILVER then
        -- Silver
        return { r = 0.78, g = 0.78, b = 0.78 }
    else
        -- Copper
        return { r = 0.72, g = 0.45, b = 0.2 }
    end
end

function GrindCompanion:GetHighestItemQuality(lootCounts)
    if not lootCounts then
        return nil
    end
    
    -- Check from highest to lowest quality
    if (lootCounts[4] or 0) > 0 then
        return 4 -- Epic
    elseif (lootCounts[3] or 0) > 0 then
        return 3 -- Rare
    elseif (lootCounts[2] or 0) > 0 then
        return 2 -- Uncommon
    end
    
    return nil
end

function GrindCompanion:RefreshDisplay()
    if not self.displayFrame or not self.displayFrame:IsShown() then
        return
    end

    local qualityColors = ITEM_QUALITY_COLORS or {}
    local highlightColor = HIGHLIGHT_FONT_COLOR or { r = 1, g = 0.82, b = 0 }
    local grayColor = GRAY_FONT_COLOR or { r = 0.62, g = 0.62, b = 0.62 }
    local defaultBorder = { r = 0.7, g = 0.7, b = 0.7 }

    local isMaxLevel = self:IsPlayerMaxLevel()
    self:SetDisplayMode(isMaxLevel and "loot" or "progress")

    local function applyRow(key, valueText, options)
        local row = self.displayRows and self.displayRows[key]
        if not row then
            return
        end

        row.Value:SetText(valueText or "")

        local valueColor = (options and options.color) or { r = 1, g = 1, b = 1 }
        if row.Value.SetTextColor then
            row.Value:SetTextColor(valueColor.r, valueColor.g, valueColor.b)
        end

        if row.Count then
            local count = options and options.count
            if count and count > 0 then
                row.Count:SetText(count)
                row.Count:Show()
            else
                row.Count:Hide()
            end
        end

        if row.IconBorder then
            local borderColor = (options and options.borderColor) or defaultBorder
            row.IconBorder:SetVertexColor(borderColor.r, borderColor.g, borderColor.b)
            row.IconBorder:Show()
        end
    end

    local total = (self.currencyCopper or 0) + (self.potentialAHCopper or 0) + (self.grayCopper or 0)
    
    if self.displayRows.timer then
        local elapsed = self:GetElapsedTime()
        local timeText = self:FormatTimeDynamic(elapsed)
        local timerColor = self.isTracking and highlightColor or grayColor
        local timerBorder = { r = 1.0, g = 1.0, b = 1.0 }
        applyRow("timer", timeText, { borderColor = timerBorder, color = timerColor })
    end

    if self.displayRows.kills then
        local killsRemaining = self:CalculateKillsRemaining()
        if killsRemaining and killsRemaining > 0 then
            local label = (killsRemaining == 1) and "1 mob" or (killsRemaining .. " mobs")
            applyRow("kills", label, { borderColor = defaultBorder, color = highlightColor })
        else
            applyRow("kills", "Need data", { borderColor = defaultBorder, color = highlightColor })
        end
    end

    if self.displayRows.eta then
        if not self.isTracking then
            applyRow("eta", "Paused", { borderColor = defaultBorder, color = highlightColor })
        else
            local eta = self:CalculateTimeToLevel()
            if not eta then
                applyRow("eta", "Gathering data...", { borderColor = defaultBorder, color = highlightColor })
            elseif eta <= 0 then
                applyRow("eta", "Level up!", { borderColor = defaultBorder, color = highlightColor })
            else
                applyRow("eta", self:FormatTime(eta), { borderColor = defaultBorder, color = highlightColor })
            end
        end
    end
    
    if self.displayRows.currency then
        local currencyBorder = self:GetCurrencyBorderColor(self.currencyCopper)
        applyRow("currency", self:FormatCoinWithIcons(self.currencyCopper), { borderColor = currencyBorder, color = highlightColor })
    end
    if self.displayRows.gray then
        local grayBorder = { r = 0.62, g = 0.62, b = 0.62 }
        applyRow("gray", self:FormatCoinWithIcons(self.grayCopper or 0), { color = grayColor, borderColor = grayBorder })
    end
    if self.displayRows.items then
        local purple = self.lootQualityCount and (self.lootQualityCount[4] or 0) or 0
        local blue = self.lootQualityCount and (self.lootQualityCount[3] or 0) or 0
        local green = self.lootQualityCount and (self.lootQualityCount[2] or 0) or 0
        local totalItems = purple + blue + green
        
        local purpleColor = qualityColors[4] or { r = 0.64, g = 0.21, b = 0.93 }
        local blueColor = qualityColors[3] or { r = 0.0, g = 0.44, b = 0.87 }
        local greenColor = qualityColors[2] or { r = 0.12, g = 1.0, b = 0.0 }
        
        local itemText = string.format(
            "|cff%02x%02x%02x%d|r |cff%02x%02x%02x%d|r |cff%02x%02x%02x%d|r",
            purpleColor.r * 255, purpleColor.g * 255, purpleColor.b * 255, purple,
            blueColor.r * 255, blueColor.g * 255, blueColor.b * 255, blue,
            greenColor.r * 255, greenColor.g * 255, greenColor.b * 255, green
        )
        
        -- Dynamic border based on highest quality item
        local highestQuality = self:GetHighestItemQuality(self.lootQualityCount)
        local itemBorder = defaultBorder
        if highestQuality and qualityColors[highestQuality] then
            itemBorder = qualityColors[highestQuality]
        end
        
        applyRow("items", itemText, { borderColor = itemBorder, color = highlightColor, count = totalItems > 0 and totalItems or nil })
    end
    if self.displayRows.ah then
        applyRow("ah", self:FormatCoinWithIcons(self.potentialAHCopper or 0), { borderColor = defaultBorder, color = highlightColor })
    end
    if self.displayRows.total then
        local legendaryOrange = { r = 1.0, g = 0.5, b = 0.0 }
        applyRow("total", self:FormatCoinWithIcons(total), { borderColor = legendaryOrange, color = highlightColor })
    end

    self:UpdateRowLayout()
end

-- ============================================================================
-- Item Detail Window
-- ============================================================================

function GrindCompanion:InitializeItemDetailWindow()
    if self.itemDetailFrame then
        return
    end

    local frame = CreateFrame("Frame", "GrindCompanionItemDetailFrame", UIParent, "PortraitFrameTemplate")
    frame:SetSize(300, 400)
    frame:SetPoint("LEFT", self.displayFrame, "RIGHT", 10, 0)
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetFrameStrata("DIALOG")

    frame.TitleText:SetText("Notable Items")
    SetPortraitToTexture(frame.portrait, "Interface\\Icons\\INV_Misc_Bag_08")

    local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -64)
    scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 12)

    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetSize(260, 1)
    scrollFrame:SetScrollChild(scrollChild)
    frame.scrollChild = scrollChild

    frame:Hide()
    self.itemDetailFrame = frame
end

function GrindCompanion:ToggleItemDetailWindow()
    if not self.itemDetailFrame then
        self:InitializeItemDetailWindow()
    end

    if self.itemDetailFrame:IsShown() then
        self.itemDetailFrame:Hide()
    else
        self:RefreshItemDetailWindow()
        self.itemDetailFrame:Show()
    end
end


-- OPTIMIZED: Avoid unnecessary table copies and reduce sorting overhead
function GrindCompanion:RefreshItemDetailWindow()
    if not self.itemDetailFrame then
        return
    end

    local scrollChild = self.itemDetailFrame.scrollChild
    
    -- Reuse button array
    local buttons = scrollChild.itemButtons
    if buttons then
        for i = 1, #buttons do
            buttons[i]:Hide()
        end
    else
        buttons = {}
        scrollChild.itemButtons = buttons
    end

    local items = self.lootedItems
    if not items or #items == 0 then
        return
    end
    
    -- Sort in-place instead of copying (items are already ours)
    table.sort(items, function(a, b)
        if a.quality ~= b.quality then
            return a.quality > b.quality
        end
        -- Cache item names to avoid repeated API calls
        if not a._cachedName then
            a._cachedName = GetItemInfo(a.link) or ""
        end
        if not b._cachedName then
            b._cachedName = GetItemInfo(b.link) or ""
        end
        return a._cachedName < b._cachedName
    end)
    
    local sortedItems = items

    local y = 0
    for i, item in ipairs(sortedItems) do
        local btn = scrollChild.itemButtons[i]
        if not btn then
            btn = CreateFrame("Button", nil, scrollChild)
            btn:SetSize(260, 40)
            
            btn.Background = btn:CreateTexture(nil, "BACKGROUND")
            btn.Background:SetAllPoints(btn)
            btn.Background:SetTexture("Interface\\LootFrame\\UI-LootSlot-Background")
            btn.Background:SetTexCoord(0, 0.640625, 0, 0.625)
            
            btn.Icon = btn:CreateTexture(nil, "ARTWORK")
            btn.Icon:SetSize(32, 32)
            btn.Icon:SetPoint("LEFT", btn, "LEFT", 8, 0)
            btn.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
            
            btn.IconBorder = btn:CreateTexture(nil, "OVERLAY")
            btn.IconBorder:SetTexture("Interface\\Common\\WhiteIconFrame")
            btn.IconBorder:SetSize(36, 36)
            btn.IconBorder:SetPoint("CENTER", btn.Icon, "CENTER", 0, 0)
            
            btn.Name = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            btn.Name:SetPoint("LEFT", btn.Icon, "RIGHT", 6, 8)
            btn.Name:SetPoint("RIGHT", btn, "RIGHT", -6, 8)
            btn.Name:SetJustifyH("LEFT")
            btn.Name:SetWordWrap(false)
            
            btn.Count = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            btn.Count:SetPoint("LEFT", btn.Icon, "RIGHT", 6, -8)
            btn.Count:SetJustifyH("LEFT")
            
            btn:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
            local ht = btn:GetHighlightTexture()
            if ht then
                ht:SetAllPoints(btn)
                ht:SetBlendMode("ADD")
                ht:SetAlpha(0.25)
            end
            
            scrollChild.itemButtons[i] = btn
        end

        local itemName, itemLink, itemQuality, _, _, _, _, _, _, itemTexture = GetItemInfo(item.link)
        if not itemTexture then
            itemTexture = select(5, GetItemInfoInstant(item.link))
        end
        
        btn.Icon:SetTexture(itemTexture or "Interface\\Icons\\INV_Misc_QuestionMark")
        
        local qualityColor = ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[item.quality]
        if qualityColor then
            btn.IconBorder:SetVertexColor(qualityColor.r, qualityColor.g, qualityColor.b)
            if itemName then
                btn.Name:SetText(string.format("|cff%02x%02x%02x%s|r", 
                    qualityColor.r * 255, qualityColor.g * 255, qualityColor.b * 255, itemName))
            else
                btn.Name:SetText(item.link)
            end
        else
            btn.IconBorder:SetVertexColor(0.7, 0.7, 0.7)
            btn.Name:SetText(itemName or item.link)
        end
        
        btn.Count:SetText("x" .. item.quantity)
        
        btn.itemLink = item.link
        btn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetHyperlink(self.itemLink)
            GameTooltip:Show()
        end)
        btn:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
        
        btn:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, -y)
        btn:Show()
        
        y = y + 44
    end

    scrollChild:SetHeight(math.max(y, 1))
end


-- ============================================================================
-- Sessions Window
-- ============================================================================

function GrindCompanion:InitializeSessionsWindow()
    if self.sessionsFrame then
        return
    end

    local frame = CreateFrame("Frame", "GrindCompanionSessionsFrame", UIParent, "PortraitFrameTemplate")
    frame:SetSize(600, 720)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetFrameStrata("DIALOG")

    frame.TitleText:SetText("Session History")
    SetPortraitToTexture(frame.portrait, "Interface\\Icons\\INV_Misc_Book_09")

    -- Store reference before calling InitializeTrendsPanel
    self.sessionsFrame = frame
    
    -- Initialize filter state (multi-select arrays)
    frame.filterText = ""
    frame.filterClasses = {}  -- Empty means "All"
    frame.filterRaces = {}    -- Empty means "All"
    frame.filterRealms = {}   -- Empty means "All"

    -- Initialize trends panel at the top
    self:InitializeTrendsPanel()
    
    -- Create filter controls below trends panel
    local filterFrame = CreateFrame("Frame", nil, frame)
    filterFrame:SetPoint("TOPLEFT", frame.trendsPanel, "BOTTOMLEFT", 0, -8)
    filterFrame:SetPoint("TOPRIGHT", frame.trendsPanel, "BOTTOMRIGHT", 0, -8)
    filterFrame:SetHeight(130)
    frame.filterFrame = filterFrame
    
    -- Search box
    local searchBox = CreateFrame("EditBox", nil, filterFrame, "InputBoxTemplate")
    searchBox:SetSize(140, 20)
    searchBox:SetPoint("TOPLEFT", filterFrame, "TOPLEFT", 20, -5)
    searchBox:SetAutoFocus(false)
    searchBox:SetScript("OnTextChanged", function(self)
        frame.filterText = self:GetText():lower()
        GrindCompanion:ApplySessionFilters()
    end)
    searchBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    filterFrame.searchBox = searchBox
    
    local searchLabel = filterFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    searchLabel:SetPoint("BOTTOMLEFT", searchBox, "TOPLEFT", 0, 2)
    searchLabel:SetText("Search:")
    
    -- Class dropdown (first row) - Multi-select
    local classDropdown = CreateFrame("Frame", "GCSessionClassDropdown", filterFrame, "UIDropDownMenuTemplate")
    classDropdown:SetPoint("TOPLEFT", searchBox, "BOTTOMLEFT", -15, -8)
    UIDropDownMenu_SetWidth(classDropdown, 130)
    UIDropDownMenu_SetText(classDropdown, "All Classes")
    
    UIDropDownMenu_Initialize(classDropdown, function(self, level)
        local classes = {"Warrior", "Paladin", "Hunter", "Rogue", "Priest", "Shaman", "Mage", "Warlock", "Druid"}
        
        -- "All Classes" option
        local info = UIDropDownMenu_CreateInfo()
        info.text = "All Classes"
        info.value = "All"
        info.func = function()
            wipe(frame.filterClasses)
            UIDropDownMenu_SetText(classDropdown, "All Classes")
            GrindCompanion:ApplySessionFilters()
        end
        info.checked = (#frame.filterClasses == 0)
        info.keepShownOnClick = false
        UIDropDownMenu_AddButton(info, level)
        
        -- Individual class options
        for _, class in ipairs(classes) do
            info = UIDropDownMenu_CreateInfo()
            info.text = class
            info.value = class
            info.func = function()
                local filterClasses = frame.filterClasses
                local found = false
                for i, c in ipairs(filterClasses) do
                    if c == class then
                        table.remove(filterClasses, i)
                        found = true
                        break
                    end
                end
                if not found then
                    table.insert(filterClasses, class)
                end
                
                -- Update dropdown text
                if #filterClasses == 0 then
                    UIDropDownMenu_SetText(classDropdown, "All Classes")
                elseif #filterClasses == 1 then
                    UIDropDownMenu_SetText(classDropdown, filterClasses[1])
                else
                    UIDropDownMenu_SetText(classDropdown, string.format("%d Classes", #filterClasses))
                end
                
                GrindCompanion:ApplySessionFilters()
            end
            info.checked = false
            for _, c in ipairs(frame.filterClasses) do
                if c == class then
                    info.checked = true
                    break
                end
            end
            info.keepShownOnClick = true
            info.isNotRadio = true
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    filterFrame.classDropdown = classDropdown
    
    -- Race dropdown (second row, below class) - Multi-select
    local raceDropdown = CreateFrame("Frame", "GCSessionRaceDropdown", filterFrame, "UIDropDownMenuTemplate")
    raceDropdown:SetPoint("TOPLEFT", classDropdown, "BOTTOMLEFT", 0, 2)
    UIDropDownMenu_SetWidth(raceDropdown, 130)
    UIDropDownMenu_SetText(raceDropdown, "All Races")
    
    UIDropDownMenu_Initialize(raceDropdown, function(self, level)
        local races = {"Human", "Orc", "Dwarf", "Night Elf", "Undead", "Tauren", "Gnome", "Troll"}
        
        -- "All Races" option
        local info = UIDropDownMenu_CreateInfo()
        info.text = "All Races"
        info.value = "All"
        info.func = function()
            wipe(frame.filterRaces)
            UIDropDownMenu_SetText(raceDropdown, "All Races")
            GrindCompanion:ApplySessionFilters()
        end
        info.checked = (#frame.filterRaces == 0)
        info.keepShownOnClick = false
        UIDropDownMenu_AddButton(info, level)
        
        -- Individual race options
        for _, race in ipairs(races) do
            info = UIDropDownMenu_CreateInfo()
            info.text = race
            info.value = race
            info.func = function()
                local filterRaces = frame.filterRaces
                local found = false
                for i, r in ipairs(filterRaces) do
                    if r == race then
                        table.remove(filterRaces, i)
                        found = true
                        break
                    end
                end
                if not found then
                    table.insert(filterRaces, race)
                end
                
                -- Update dropdown text
                if #filterRaces == 0 then
                    UIDropDownMenu_SetText(raceDropdown, "All Races")
                elseif #filterRaces == 1 then
                    UIDropDownMenu_SetText(raceDropdown, filterRaces[1])
                else
                    UIDropDownMenu_SetText(raceDropdown, string.format("%d Races", #filterRaces))
                end
                
                GrindCompanion:ApplySessionFilters()
            end
            info.checked = false
            for _, r in ipairs(frame.filterRaces) do
                if r == race then
                    info.checked = true
                    break
                end
            end
            info.keepShownOnClick = true
            info.isNotRadio = true
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    filterFrame.raceDropdown = raceDropdown
    
    -- Realm dropdown (third row, below race) - Multi-select
    local realmDropdown = CreateFrame("Frame", "GCSessionRealmDropdown", filterFrame, "UIDropDownMenuTemplate")
    realmDropdown:SetPoint("TOPLEFT", raceDropdown, "BOTTOMLEFT", 0, 2)
    UIDropDownMenu_SetWidth(realmDropdown, 130)
    UIDropDownMenu_SetText(realmDropdown, "All Realms")
    
    UIDropDownMenu_Initialize(realmDropdown, function(self, level)
        -- Get unique realms from sessions
        local realms = {}
        local realmSet = {}
        GrindCompanion:EnsureSavedVariables()
        local sessions = GrindCompanionDB.sessions or {}
        for _, session in ipairs(sessions) do
            if session.character and session.character.realm then
                local realm = session.character.realm
                if not realmSet[realm] then
                    realmSet[realm] = true
                    table.insert(realms, realm)
                end
            end
        end
        table.sort(realms)
        
        -- "All Realms" option
        local info = UIDropDownMenu_CreateInfo()
        info.text = "All Realms"
        info.value = "All"
        info.func = function()
            wipe(frame.filterRealms)
            UIDropDownMenu_SetText(realmDropdown, "All Realms")
            GrindCompanion:ApplySessionFilters()
        end
        info.checked = (#frame.filterRealms == 0)
        info.keepShownOnClick = false
        UIDropDownMenu_AddButton(info, level)
        
        -- Individual realm options
        for _, realm in ipairs(realms) do
            info = UIDropDownMenu_CreateInfo()
            info.text = realm
            info.value = realm
            info.func = function()
                local filterRealms = frame.filterRealms
                local found = false
                for i, r in ipairs(filterRealms) do
                    if r == realm then
                        table.remove(filterRealms, i)
                        found = true
                        break
                    end
                end
                if not found then
                    table.insert(filterRealms, realm)
                end
                
                -- Update dropdown text
                if #filterRealms == 0 then
                    UIDropDownMenu_SetText(realmDropdown, "All Realms")
                elseif #filterRealms == 1 then
                    UIDropDownMenu_SetText(realmDropdown, filterRealms[1])
                else
                    UIDropDownMenu_SetText(realmDropdown, string.format("%d Realms", #filterRealms))
                end
                
                GrindCompanion:ApplySessionFilters()
            end
            info.checked = false
            for _, r in ipairs(frame.filterRealms) do
                if r == realm then
                    info.checked = true
                    break
                end
            end
            info.keepShownOnClick = true
            info.isNotRadio = true
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    filterFrame.realmDropdown = realmDropdown

    -- Left panel for session list (positioned below filter frame)
    local listPanel = CreateFrame("Frame", nil, frame, "InsetFrameTemplate3")
    listPanel:SetPoint("TOPLEFT", filterFrame, "BOTTOMLEFT", 0, -8)
    listPanel:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 10, 12)
    listPanel:SetWidth(180)
    frame.listPanel = listPanel

    local listScroll = CreateFrame("ScrollFrame", nil, listPanel, "UIPanelScrollFrameTemplate")
    listScroll:SetPoint("TOPLEFT", listPanel, "TOPLEFT", 6, -6)
    listScroll:SetPoint("BOTTOMRIGHT", listPanel, "BOTTOMRIGHT", -26, 6)

    local listChild = CreateFrame("Frame", nil, listScroll)
    listChild:SetSize(140, 1)
    listScroll:SetScrollChild(listChild)
    frame.listChild = listChild

    -- Right panel for session details (positioned below trends panel)
    local detailPanel = CreateFrame("Frame", nil, frame, "InsetFrameTemplate3")
    detailPanel:SetPoint("TOPLEFT", frame.trendsPanel, "BOTTOMRIGHT", -390, -8)
    detailPanel:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 12)
    frame.detailPanel = detailPanel
    
    -- Create tabs
    local tabHeight = 24
    local tabWidth = 80
    
    local tab1 = CreateFrame("Button", nil, detailPanel, "UIPanelButtonTemplate")
    tab1:SetSize(tabWidth, tabHeight)
    tab1:SetPoint("TOPLEFT", detailPanel, "TOPLEFT", 10, -8)
    tab1:SetText("Summary")
    
    local tab2 = CreateFrame("Button", nil, detailPanel, "UIPanelButtonTemplate")
    tab2:SetSize(tabWidth, tabHeight)
    tab2:SetPoint("LEFT", tab1, "RIGHT", 4, 0)
    tab2:SetText("Mobs")
    
    detailPanel.tab1 = tab1
    detailPanel.tab2 = tab2
    detailPanel.activeTab = 1
    
    -- Set initial state
    tab1:Disable()
    tab2:Enable()
    
    tab1:SetScript("OnClick", function()
        if detailPanel.activeTab ~= 1 then
            detailPanel.activeTab = 1
            tab1:Disable()
            tab2:Enable()
            self:RefreshSessionDetailTab()
        end
    end)
    
    tab2:SetScript("OnClick", function()
        if detailPanel.activeTab ~= 2 then
            detailPanel.activeTab = 2
            tab1:Enable()
            tab2:Disable()
            self:RefreshSessionDetailTab()
        end
    end)

    local detailScroll = CreateFrame("ScrollFrame", nil, detailPanel, "UIPanelScrollFrameTemplate")
    detailScroll:SetPoint("TOPLEFT", detailPanel, "TOPLEFT", 6, -36)
    detailScroll:SetPoint("BOTTOMRIGHT", detailPanel, "BOTTOMRIGHT", -26, 6)

    local detailChild = CreateFrame("Frame", nil, detailScroll)
    detailChild:SetSize(360, 1)
    detailScroll:SetScrollChild(detailChild)
    frame.detailChild = detailChild

    -- Detail text
    detailChild.text = detailChild:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    detailChild.text:SetPoint("TOPLEFT", detailChild, "TOPLEFT", 8, -8)
    detailChild.text:SetPoint("TOPRIGHT", detailChild, "TOPRIGHT", -8, -8)
    detailChild.text:SetJustifyH("LEFT")
    detailChild.text:SetJustifyV("TOP")
    detailChild.text:SetWordWrap(true)
    detailChild.text:SetText("Select a session to view details")

    frame:Hide()
end

function GrindCompanion:ToggleSessionsWindow()
    if not self.sessionsFrame then
        self:InitializeSessionsWindow()
    end

    if self.sessionsFrame:IsShown() then
        self.sessionsFrame:Hide()
    else
        self:RefreshSessionsList()
        self:RefreshTrendsPanel()
        self.sessionsFrame:Show()
    end
end


function GrindCompanion:RefreshSessionsList()
    if not self.sessionsFrame then
        return
    end

    self:EnsureSavedVariables()
    local sessions = GrindCompanionDB.sessions or {}
    local listChild = self.sessionsFrame.listChild

    -- Clear existing buttons
    if listChild.sessionButtons then
        for _, btn in ipairs(listChild.sessionButtons) do
            btn:Hide()
            btn:ClearAllPoints()
        end
    else
        listChild.sessionButtons = {}
    end

    if #sessions == 0 then
        if not listChild.noDataText then
            listChild.noDataText = listChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            listChild.noDataText:SetPoint("TOP", listChild, "TOP", 0, -10)
            listChild.noDataText:SetTextColor(0.6, 0.6, 0.6)
        end
        listChild.noDataText:SetText("No sessions yet")
        listChild.noDataText:Show()
        return
    end

    if listChild.noDataText then
        listChild.noDataText:Hide()
    end
    
    -- Apply filters
    local filteredSessions = {}
    local filterText = self.sessionsFrame.filterText or ""
    local filterClass = self.sessionsFrame.filterClass or "All"
    local filterRace = self.sessionsFrame.filterRace or "All"
    local filterRealm = self.sessionsFrame.filterRealm or "All"
    
    for i = #sessions, 1, -1 do
        local session = sessions[i]
        local charName = (session.character and session.character.name or "Unknown"):lower()
        local charClass = session.character and session.character.class or ""
        local charRace = session.character and session.character.race or ""
        local charRealm = session.character and session.character.realm or ""
        
        local matchesText = filterText == "" or charName:find(filterText, 1, true)
        local matchesClass = filterClass == "All" or charClass == filterClass
        local matchesRace = filterRace == "All" or charRace == filterRace
        local matchesRealm = filterRealm == "All" or charRealm == filterRealm
        
        if matchesText and matchesClass and matchesRace and matchesRealm then
            table.insert(filteredSessions, {index = i, session = session})
        end
    end
    
    if #filteredSessions == 0 then
        if not listChild.noDataText then
            listChild.noDataText = listChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            listChild.noDataText:SetPoint("TOP", listChild, "TOP", 0, -10)
            listChild.noDataText:SetTextColor(0.6, 0.6, 0.6)
        end
        listChild.noDataText:SetText("No matching sessions")
        listChild.noDataText:Show()
        return
    end

    local y = 0
    for btnIndex, data in ipairs(filteredSessions) do
        local i = data.index
        local session = data.session
        local btn = listChild.sessionButtons[btnIndex]
        
        if not btn then
            btn = CreateFrame("Button", nil, listChild)
            btn:SetSize(140, 60)
            
            btn.Background = btn:CreateTexture(nil, "BACKGROUND")
            btn.Background:SetAllPoints(btn)
            btn.Background:SetColorTexture(0.1, 0.1, 0.1, 0.5)
            
            btn.Title = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            btn.Title:SetPoint("TOPLEFT", btn, "TOPLEFT", 6, -6)
            btn.Title:SetPoint("TOPRIGHT", btn, "TOPRIGHT", -6, -6)
            btn.Title:SetJustifyH("LEFT")
            btn.Title:SetWordWrap(false)
            
            btn.Subtitle = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            btn.Subtitle:SetPoint("TOPLEFT", btn.Title, "BOTTOMLEFT", 0, -2)
            btn.Subtitle:SetPoint("TOPRIGHT", btn.Title, "BOTTOMRIGHT", 0, -2)
            btn.Subtitle:SetJustifyH("LEFT")
            btn.Subtitle:SetWordWrap(true)
            btn.Subtitle:SetMaxLines(2)
            
            btn:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
            local ht = btn:GetHighlightTexture()
            if ht then
                ht:SetAllPoints(btn)
                ht:SetBlendMode("ADD")
                ht:SetAlpha(0.3)
            end
            
            table.insert(listChild.sessionButtons, btn)
        end

        local sessionNum = i
        local charName = session.character and session.character.name or "Unknown"
        local charRealm = session.character and session.character.realm or ""
        
        -- Build title with race/class icons
        local titleText = string.format("#%d - %s", sessionNum, charName)
        if session.character then
            local raceIcon = self:GetRaceIconString(session.character.race, session.character.gender)
            local classIcon = self:GetClassIconString(session.character.class)
            if raceIcon or classIcon then
                titleText = titleText .. " " .. (raceIcon or "") .. (classIcon or "")
            end
        end
        
        -- Build subtitle with realm and date
        local subtitleText = ""
        if charRealm ~= "" then
            subtitleText = charRealm
        end
        local dateStr = session.startedAt and date("%m/%d %H:%M", session.startedAt) or "Unknown"
        if subtitleText ~= "" then
            subtitleText = subtitleText .. "\n" .. dateStr
        else
            subtitleText = dateStr
        end
        
        btn.Title:SetText(titleText)
        btn.Subtitle:SetText(subtitleText)
        
        btn:SetScript("OnClick", function()
            self:DisplaySessionDetails(sessionNum, session)
            -- Update selection visual
            for _, b in ipairs(listChild.sessionButtons) do
                if b.Background then
                    b.Background:SetColorTexture(0.1, 0.1, 0.1, 0.5)
                end
            end
            btn.Background:SetColorTexture(0.2, 0.4, 0.6, 0.7)
            
            -- Highlight data points on all graphs
            local graphContainer = self.sessionsFrame.trendsPanel and self.sessionsFrame.trendsPanel.graphContainer
            if graphContainer then
                if graphContainer.currencyGraph then
                    self:HighlightDataPoint(graphContainer.currencyGraph, sessionNum)
                end
                if graphContainer.xpGraph then
                    self:HighlightDataPoint(graphContainer.xpGraph, sessionNum)
                end
            end
        end)
        
        btn:SetPoint("TOPLEFT", listChild, "TOPLEFT", 0, -y)
        btn:Show()
        
        y = y + 64
    end

    listChild:SetHeight(math.max(y, 1))
end


function GrindCompanion:DisplaySessionDetails(sessionNum, session)
    if not self.sessionsFrame or not session then
        return
    end
    
    -- Store current session for tab switching
    self.sessionsFrame.currentSessionNum = sessionNum
    self.sessionsFrame.currentSession = session
    
    -- Refresh the active tab
    self:RefreshSessionDetailTab()
end

function GrindCompanion:RefreshSessionDetailTab()
    if not self.sessionsFrame or not self.sessionsFrame.currentSession then
        return
    end
    
    local activeTab = self.sessionsFrame.detailPanel.activeTab or 1
    local sessionNum = self.sessionsFrame.currentSessionNum
    local session = self.sessionsFrame.currentSession
    
    if activeTab == 1 then
        self:DisplaySessionSummary(sessionNum, session)
    else
        self:DisplaySessionMobs(sessionNum, session)
    end
end

function GrindCompanion:DisplaySessionSummary(sessionNum, session)
    if not self.sessionsFrame or not session then
        return
    end

    local detailChild = self.sessionsFrame.detailChild
    local text = detailChild.text
    
    local lines = {}
    
    -- Header
    table.insert(lines, string.format("|cffffd700Session #%d|r\n", sessionNum))
    
    -- Character info
    if session.character then
        local charName = session.character.name or "Unknown"
        local realm = session.character.realm
        local fullName = realm and (charName .. "-" .. realm) or charName
        table.insert(lines, string.format("|cff00ff00Character:|r %s", fullName))
        
        if session.character.startingLevel and session.character.endingLevel then
            local levelText = ""
            
            -- Show level range if they leveled up
            if session.character.startingLevel ~= session.character.endingLevel then
                levelText = string.format("Level %d → %d |cff00ff00(+1)|r", 
                    session.character.startingLevel, session.character.endingLevel)
            else
                levelText = string.format("Level %d", session.character.endingLevel)
            end
            
            -- Add race icon
            if session.character.race then
                local raceIcon = self:GetRaceIconString(session.character.race, session.character.gender)
                if raceIcon then
                    levelText = levelText .. " " .. raceIcon
                end
            end
            
            -- Add class icon
            if session.character.class then
                local classIcon = self:GetClassIconString(session.character.class)
                if classIcon then
                    levelText = levelText .. " " .. classIcon
                end
            end
            
            table.insert(lines, levelText)
        end
    end
    
    table.insert(lines, "")
    
    -- Time info
    if session.startedAt then
        table.insert(lines, string.format("|cff00ff00Started:|r %s", date("%Y-%m-%d %H:%M:%S", session.startedAt)))
    end
    if session.endedAt then
        table.insert(lines, string.format("|cff00ff00Ended:|r %s", date("%Y-%m-%d %H:%M:%S", session.endedAt)))
    end
    if session.duration then
        table.insert(lines, string.format("|cff00ff00Duration:|r %s", self:FormatTime(session.duration)))
    end
    
    table.insert(lines, "")
    
    -- Zones
    if session.zones and #session.zones > 0 then
        if #session.zones == 1 then
            table.insert(lines, string.format("|cff00ff00Zone:|r %s", session.zones[1]))
        else
            table.insert(lines, "|cff00ff00Zones:|r")
            for _, zone in ipairs(session.zones) do
                table.insert(lines, string.format("  • %s", zone))
            end
        end
        table.insert(lines, "")
    end
    
    -- Session Summary
    if session.mobSummary then
        table.insert(lines, "|cffffd700Session Summary:|r")
        if session.mobSummary.totalKills and session.mobSummary.totalKills > 0 then
            table.insert(lines, string.format("  Total Kills: %d", session.mobSummary.totalKills))
        end
        if session.mobSummary.uniqueMobs and session.mobSummary.uniqueMobs > 0 then
            table.insert(lines, string.format("  Unique Mobs: %d", session.mobSummary.uniqueMobs))
        end
        if session.mobSummary.totalCurrency and session.mobSummary.totalCurrency > 0 then
            table.insert(lines, string.format("  Mob Currency: %s", self:FormatCoin(session.mobSummary.totalCurrency)))
        end
        if not session.wasMaxLevel and session.mobSummary.totalXP and session.mobSummary.totalXP > 0 then
            table.insert(lines, string.format("  Mob XP: %s", self:FormatNumber(session.mobSummary.totalXP)))
        end
        if session.mobSummary.totalItems then
            local totalItems = (session.mobSummary.totalItems[2] or 0) + 
                              (session.mobSummary.totalItems[3] or 0) + 
                              (session.mobSummary.totalItems[4] or 0)
            if totalItems > 0 then
                table.insert(lines, string.format("  Notable Items: %d", totalItems))
            end
        end
        table.insert(lines, "")
    end
    
    -- XP and kills
    if not session.wasMaxLevel then
        if session.totalXP and session.totalXP > 0 then
            table.insert(lines, string.format("|cff00ff00Total XP:|r %s", self:FormatNumber(session.totalXP)))
        end
        if session.killCount and session.killCount > 0 then
            table.insert(lines, string.format("|cff00ff00Kills:|r %d", session.killCount))
        end
        if session.totalXP and session.killCount and session.killCount > 0 then
            local xpPerKill = math.floor(session.totalXP / session.killCount)
            table.insert(lines, string.format("|cff00ff00XP per Kill:|r %d", xpPerKill))
        end
        if session.totalXP and session.duration and session.duration > 0 then
            local xpPerHour = math.floor((session.totalXP / session.duration) * 3600)
            table.insert(lines, string.format("|cff00ff00XP per Hour:|r %s", self:FormatNumber(xpPerHour)))
        end
        table.insert(lines, "")
    end
    
    -- Currency
    table.insert(lines, "|cffffd700Currency Earned:|r")
    if session.currencyCopper then
        table.insert(lines, string.format("  Direct: %s", self:FormatCoin(session.currencyCopper)))
    end
    if session.grayCopper then
        table.insert(lines, string.format("  Gray Items: %s", self:FormatCoin(session.grayCopper)))
    end
    if session.potentialAHCopper then
        table.insert(lines, string.format("  AH Value: %s", self:FormatCoin(session.potentialAHCopper)))
    end
    
    local totalCopper = (session.currencyCopper or 0) + (session.grayCopper or 0) + (session.potentialAHCopper or 0)
    table.insert(lines, string.format("  |cffffd700Total: %s|r", self:FormatCoin(totalCopper)))
    
    if session.duration and session.duration > 0 then
        local copperPerHour = math.floor((totalCopper / session.duration) * 3600)
        table.insert(lines, string.format("  Per Hour: %s", self:FormatCoin(copperPerHour)))
    end
    
    table.insert(lines, "")
    
    -- Loot
    if session.loot then
        local purple = session.loot[4] or 0
        local blue = session.loot[3] or 0
        local green = session.loot[2] or 0
        
        if purple > 0 or blue > 0 or green > 0 then
            table.insert(lines, "|cffffd700Notable Loot:|r")
            if purple > 0 then
                table.insert(lines, string.format("  |cffa335eePurple:|r %d", purple))
            end
            if blue > 0 then
                table.insert(lines, string.format("  |cff0070ddBlue:|r %d", blue))
            end
            if green > 0 then
                table.insert(lines, string.format("  |cff1eff00Green:|r %d", green))
            end
        else
            table.insert(lines, "|cffffd700Notable Loot:|r None")
        end
    end
    
    
    local fullText = table.concat(lines, "\n")
    text:SetText(fullText)
    
    -- Update scroll height
    local textHeight = text:GetStringHeight()
    detailChild:SetHeight(math.max(textHeight + 16, 1))
end

function GrindCompanion:DisplaySessionMobs(sessionNum, session)
    if not self.sessionsFrame or not session then
        return
    end

    local detailChild = self.sessionsFrame.detailChild
    local text = detailChild.text
    
    local lines = {}
    
    -- Header
    table.insert(lines, string.format("|cffffd700Session #%d - Mob Statistics|r\n", sessionNum))
    
    -- Mob statistics
    if session.mobs then
        local mobList = {}
        for mobName, stats in pairs(session.mobs) do
            table.insert(mobList, {name = mobName, stats = stats})
        end
        
        -- Sort by kill count (descending)
        table.sort(mobList, function(a, b)
            return a.stats.kills > b.stats.kills
        end)
        
        if #mobList > 0 then
            table.insert(lines, string.format("  |cff888888Showing %d unique mob%s|r\n", #mobList, #mobList == 1 and "" or "s"))
            
            for i, mob in ipairs(mobList) do
                if i <= 10 then -- Show top 10 mobs
                    local avgCopper = mob.stats.kills > 0 and (mob.stats.currency / mob.stats.kills) or 0
                    local totalCopper = mob.stats.currency or 0
                    local totalXP = mob.stats.xp or 0
                    local avgXP = mob.stats.kills > 0 and totalXP > 0 and (totalXP / mob.stats.kills) or 0
                    local lootCount = (mob.stats.loot[2] or 0) + (mob.stats.loot[3] or 0) + (mob.stats.loot[4] or 0)
                    
                    table.insert(lines, string.format("  |cffaaaaaa%s|r", mob.name))
                    table.insert(lines, string.format("    Kills: %d | Currency: %s (avg %s)", 
                        mob.stats.kills,
                        self:FormatCoin(totalCopper),
                        self:FormatCoin(avgCopper)))
                    
                    -- Show XP stats if not max level session
                    if not session.wasMaxLevel and totalXP > 0 then
                        table.insert(lines, string.format("    XP: %s total (avg %s per kill)", 
                            self:FormatNumber(totalXP),
                            self:FormatNumber(avgXP)))
                    end
                    
                    -- Show highest quality drop
                    if mob.stats.highestQualityDrop then
                        local drop = mob.stats.highestQualityDrop
                        local itemName = GetItemInfo(drop.link) or drop.link
                        local qualityColor = ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[drop.quality]
                        if qualityColor then
                            itemName = string.format("|cff%02x%02x%02x%s|r", 
                                qualityColor.r * 255, qualityColor.g * 255, qualityColor.b * 255, itemName)
                        end
                        local qtyText = drop.quantity > 1 and (" x" .. drop.quantity) or ""
                        table.insert(lines, string.format("    Best Drop: %s%s", itemName, qtyText))
                    end
                    
                    if lootCount > 0 then
                        local lootParts = {}
                        if mob.stats.loot[4] and mob.stats.loot[4] > 0 then
                            table.insert(lootParts, string.format("|cffa335eePurple: %d|r", mob.stats.loot[4]))
                        end
                        if mob.stats.loot[3] and mob.stats.loot[3] > 0 then
                            table.insert(lootParts, string.format("|cff0070ddBlue: %d|r", mob.stats.loot[3]))
                        end
                        if mob.stats.loot[2] and mob.stats.loot[2] > 0 then
                            table.insert(lootParts, string.format("|cff1eff00Green: %d|r", mob.stats.loot[2]))
                        end
                        table.insert(lines, string.format("    Items: %s", table.concat(lootParts, ", ")))
                    end
                    
                    if i < math.min(10, #mobList) then
                        table.insert(lines, "")
                    end
                end
            end
            
            if #mobList > 10 then
                table.insert(lines, "")
                table.insert(lines, string.format("  |cff888888... and %d more mob%s not shown|r", #mobList - 10, (#mobList - 10) == 1 and "" or "s"))
            end
        else
            table.insert(lines, "No mobs killed during this session.")
        end
    else
        table.insert(lines, "No mob data available for this session.")
    end
    
    local fullText = table.concat(lines, "\n")
    text:SetText(fullText)
    
    -- Update scroll height
    local textHeight = text:GetStringHeight()
    detailChild:SetHeight(math.max(textHeight + 16, 1))
end

-- ============================================================================
-- Helper Functions
-- ============================================================================

function GrindCompanion:FormatNumber(num)
    num = tonumber(num) or 0
    if num >= 1000000 then
        return string.format("%.1fM", num / 1000000)
    elseif num >= 1000 then
        return string.format("%.1fK", num / 1000)
    else
        return tostring(num)
    end
end

function GrindCompanion:GetRaceIconString(race, gender)
    if not race then return nil end
    
    -- UnitSex returns: 1 = Unknown, 2 = Male, 3 = Female
    local isFemale = (gender == 3)
    local suffix = isFemale and "Female" or "Male"
    
    -- Use individual race icon files with gender (Classic Era races only)
    local raceIcons = {
        Human = "Interface\\Icons\\Achievement_Character_Human_" .. suffix,
        Orc = "Interface\\Icons\\Achievement_Character_Orc_" .. suffix,
        Dwarf = "Interface\\Icons\\Achievement_Character_Dwarf_" .. suffix,
        NightElf = "Interface\\Icons\\Achievement_Character_Nightelf_" .. suffix,
        Scourge = "Interface\\Icons\\Achievement_Character_Undead_" .. suffix,
        Tauren = "Interface\\Icons\\Achievement_Character_Tauren_" .. suffix,
        Gnome = "Interface\\Icons\\Achievement_Character_Gnome_" .. suffix,
        Troll = "Interface\\Icons\\Achievement_Character_Troll_" .. suffix,
    }
    
    local iconPath = raceIcons[race]
    if iconPath then
        return string.format("|T%s:16:16:0:0:64:64:4:60:4:60|t", iconPath)
    end
    
    return nil
end

function GrindCompanion:GetClassIconString(class)
    if not class then return nil end
    
    -- Use individual class icon files (Classic Era classes only)
    local classIcons = {
        WARRIOR = "Interface\\Icons\\ClassIcon_Warrior",
        MAGE = "Interface\\Icons\\ClassIcon_Mage",
        ROGUE = "Interface\\Icons\\ClassIcon_Rogue",
        DRUID = "Interface\\Icons\\ClassIcon_Druid",
        HUNTER = "Interface\\Icons\\ClassIcon_Hunter",
        SHAMAN = "Interface\\Icons\\ClassIcon_Shaman",
        PRIEST = "Interface\\Icons\\ClassIcon_Priest",
        WARLOCK = "Interface\\Icons\\ClassIcon_Warlock",
        PALADIN = "Interface\\Icons\\ClassIcon_Paladin",
    }
    
    local iconPath = classIcons[class]
    if iconPath then
        return string.format("|T%s:16:16:0:0:64:64:4:60:4:60|t", iconPath)
    end
    
    return nil
end
