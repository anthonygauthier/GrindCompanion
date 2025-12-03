local GrindCalculator = _G.GrindCalculator

function GrindCalculator:InitializeDisplayFrame()
    if self.displayFrame then
        return
    end

    local frame = CreateFrame("Frame", "GrindCalculatorFrame", UIParent, "PortraitFrameTemplate")
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

    local inset = CreateFrame("Frame", nil, frame, "InsetFrameTemplate3")
    inset:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -74)
    inset:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 12)
    frame.inset = inset

    self.displayRows = {}
    self.rowOrder = {
        "currency",
        "gray",
        "items",
        "ah",
        "total",
        "eta",
        "kills",
    }

    local function createRow(key, labelText, iconTexture)
        local index = #self.displayRows + 1
        local name = "GrindCalculatorLootRow" .. index
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

    createRow("currency", "Currency Earned", "Interface\\Icons\\INV_Misc_Coin_01")
    createRow("gray", "Gray Vendor Value", "Interface\\Icons\\INV_Misc_Coin_03")
    createRow("items", "Notable Items", "Interface\\Icons\\INV_Misc_Bag_08")
    createRow("ah", "AH Value", "Interface\\Icons\\INV_Misc_Coin_02")
    createRow("total", "Total", "Interface\\Icons\\INV_Misc_Coin_06")
    createRow("eta", "Estimated Time", "Interface\\Icons\\INV_Misc_PocketWatch_02")
    createRow("kills", "Kills Remaining", "Interface\\Icons\\INV_Sword_04")
    
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
            self:RefreshDisplay()
        end
    end)

    frame:Hide()

    self.displayFrame = frame
    self:SetDisplayMode("progress")
end

function GrindCalculator:ApplyRowVisibility()
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

function GrindCalculator:SetDisplayMode(mode)
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

function GrindCalculator:UpdateRowLayout()
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
            
            y = y + row:GetHeight() + 4
            visibleCount = visibleCount + 1
        end
    end

    -- Dynamic frame height based on visible rows
    -- 64 = title bar height, 12 = bottom padding, 16 = inset padding (8 top + 8 bottom)
    local contentHeight = (visibleCount * 40) + ((visibleCount - 1) * 4) + 16
    local frameHeight = 64 + contentHeight + 12
    self.displayFrame:SetHeight(frameHeight)
end

function GrindCalculator:RefreshDisplay()
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
    if self.displayRows.currency then
        applyRow("currency", self:FormatCoinWithIcons(self.currencyCopper), { borderColor = defaultBorder, color = highlightColor })
    end
    if self.displayRows.gray then
        applyRow("gray", self:FormatCoinWithIcons(self.grayCopper or 0), { color = grayColor, borderColor = grayColor })
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
        
        applyRow("items", itemText, { borderColor = defaultBorder, color = highlightColor, count = totalItems > 0 and totalItems or nil })
    end
    if self.displayRows.ah then
        applyRow("ah", self:FormatCoinWithIcons(self.potentialAHCopper or 0), { borderColor = defaultBorder, color = highlightColor })
    end
    if self.displayRows.total then
        applyRow("total", self:FormatCoinWithIcons(total), { borderColor = defaultBorder, color = highlightColor })
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

    self:UpdateRowLayout()
end

function GrindCalculator:InitializeItemDetailWindow()
    if self.itemDetailFrame then
        return
    end

    local frame = CreateFrame("Frame", "GrindCalculatorItemDetailFrame", UIParent, "PortraitFrameTemplate")
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

function GrindCalculator:ToggleItemDetailWindow()
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

function GrindCalculator:RefreshItemDetailWindow()
    if not self.itemDetailFrame then
        return
    end

    local scrollChild = self.itemDetailFrame.scrollChild
    
    -- Clear existing buttons
    if scrollChild.itemButtons then
        for _, btn in ipairs(scrollChild.itemButtons) do
            btn:Hide()
            btn:ClearAllPoints()
        end
    else
        scrollChild.itemButtons = {}
    end

    local items = self.lootedItems or {}
    
    -- Sort items by quality (descending) then by name
    local sortedItems = {}
    for _, item in ipairs(items) do
        table.insert(sortedItems, item)
    end
    table.sort(sortedItems, function(a, b)
        if a.quality ~= b.quality then
            return a.quality > b.quality
        end
        local nameA = GetItemInfo(a.link) or ""
        local nameB = GetItemInfo(b.link) or ""
        return nameA < nameB
    end)

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

function GrindCalculator:InitializeTrendsPanel()
    if not self.sessionsFrame then
        return
    end
    
    local frame = self.sessionsFrame
    
    -- Create trends panel frame with InsetFrameTemplate3
    local trendsPanel = CreateFrame("Frame", nil, frame, "InsetFrameTemplate3")
    trendsPanel:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -64)
    trendsPanel:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -10, -64)
    trendsPanel:SetHeight(250)
    
    -- Create summary statistics frame at top of panel
    local summaryFrame = CreateFrame("Frame", nil, trendsPanel)
    summaryFrame:SetPoint("TOPLEFT", trendsPanel, "TOPLEFT", 10, -10)
    summaryFrame:SetPoint("TOPRIGHT", trendsPanel, "TOPRIGHT", -10, -10)
    summaryFrame:SetHeight(60)
    trendsPanel.summaryFrame = summaryFrame
    
    -- Add font strings for summary statistics
    -- Total sessions (top left)
    summaryFrame.totalSessionsText = summaryFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    summaryFrame.totalSessionsText:SetPoint("TOPLEFT", summaryFrame, "TOPLEFT", 0, 0)
    summaryFrame.totalSessionsText:SetText("Total Sessions: 0")
    summaryFrame.totalSessionsText:SetJustifyH("LEFT")
    if HIGHLIGHT_FONT_COLOR then
        summaryFrame.totalSessionsText:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
    end
    
    -- Total time (top right)
    summaryFrame.totalTimeText = summaryFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    summaryFrame.totalTimeText:SetPoint("TOPRIGHT", summaryFrame, "TOPRIGHT", 0, 0)
    summaryFrame.totalTimeText:SetText("Total Time: 0h")
    summaryFrame.totalTimeText:SetJustifyH("RIGHT")
    if HIGHLIGHT_FONT_COLOR then
        summaryFrame.totalTimeText:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
    end
    
    -- Average copper per hour (bottom left)
    summaryFrame.avgCopperPerHourText = summaryFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    summaryFrame.avgCopperPerHourText:SetPoint("BOTTOMLEFT", summaryFrame, "BOTTOMLEFT", 0, 0)
    summaryFrame.avgCopperPerHourText:SetText("Avg: 0c/hr")
    summaryFrame.avgCopperPerHourText:SetJustifyH("LEFT")
    if HIGHLIGHT_FONT_COLOR then
        summaryFrame.avgCopperPerHourText:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
    end
    
    -- Best copper per hour (bottom right)
    summaryFrame.bestCopperPerHourText = summaryFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    summaryFrame.bestCopperPerHourText:SetPoint("BOTTOMRIGHT", summaryFrame, "BOTTOMRIGHT", 0, 0)
    summaryFrame.bestCopperPerHourText:SetText("Best: 0c/hr")
    summaryFrame.bestCopperPerHourText:SetJustifyH("RIGHT")
    if HIGHLIGHT_FONT_COLOR then
        summaryFrame.bestCopperPerHourText:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
    end
    
    -- Create tab buttons container
    local tabContainer = CreateFrame("Frame", nil, trendsPanel)
    tabContainer:SetPoint("TOPLEFT", summaryFrame, "BOTTOMLEFT", 0, -10)
    tabContainer:SetPoint("TOPRIGHT", summaryFrame, "BOTTOMRIGHT", 0, -10)
    tabContainer:SetHeight(30)
    trendsPanel.tabContainer = tabContainer
    
    -- Create graph container frame (no scroll frame)
    local graphContainer = CreateFrame("Frame", nil, trendsPanel)
    graphContainer:SetPoint("TOPLEFT", tabContainer, "BOTTOMLEFT", 0, -5)
    graphContainer:SetPoint("BOTTOMRIGHT", trendsPanel, "BOTTOMRIGHT", -10, 10)
    trendsPanel.graphContainer = graphContainer
    
    -- Create tabs
    local tabs = {}
    local tabNames = {"Currency", "XP", "Loot Quality"}
    local tabWidth = 100
    
    for i, tabName in ipairs(tabNames) do
        local tab = CreateFrame("Button", nil, tabContainer)
        tab:SetSize(tabWidth, 28)
        tab:SetPoint("LEFT", tabContainer, "LEFT", (i - 1) * (tabWidth + 5), 0)
        
        -- Tab background
        tab.bg = tab:CreateTexture(nil, "BACKGROUND")
        tab.bg:SetAllPoints(tab)
        tab.bg:SetColorTexture(0.2, 0.2, 0.2, 0.8)
        
        -- Tab text
        tab.text = tab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        tab.text:SetPoint("CENTER", tab, "CENTER", 0, 0)
        tab.text:SetText(tabName)
        
        -- Tab highlight
        tab:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
        local ht = tab:GetHighlightTexture()
        if ht then
            ht:SetAllPoints(tab)
            ht:SetBlendMode("ADD")
            ht:SetAlpha(0.3)
        end
        
        tab.tabIndex = i
        tab:SetScript("OnClick", function(self)
            GrindCalculator:SelectGraphTab(self.tabIndex)
        end)
        
        tabs[i] = tab
    end
    
    trendsPanel.tabs = tabs
    trendsPanel.activeTab = 1
    
    -- Store reference in sessionsFrame
    frame.trendsPanel = trendsPanel
end

function GrindCalculator:InitializeSessionsWindow()
    if self.sessionsFrame then
        return
    end

    local frame = CreateFrame("Frame", "GrindCalculatorSessionsFrame", UIParent, "PortraitFrameTemplate")
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
    
    -- Initialize filter state
    frame.filterText = ""
    frame.filterClass = "All"
    frame.filterRace = "All"
    frame.filterRealm = "All"

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
        GrindCalculator:ApplySessionFilters()
    end)
    searchBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    filterFrame.searchBox = searchBox
    
    local searchLabel = filterFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    searchLabel:SetPoint("BOTTOMLEFT", searchBox, "TOPLEFT", 0, 2)
    searchLabel:SetText("Search:")
    
    -- Class dropdown (first row)
    local classDropdown = CreateFrame("Frame", "GCSessionClassDropdown", filterFrame, "UIDropDownMenuTemplate")
    classDropdown:SetPoint("TOPLEFT", searchBox, "BOTTOMLEFT", -15, -8)
    UIDropDownMenu_SetWidth(classDropdown, 130)
    UIDropDownMenu_SetText(classDropdown, "All Classes")
    
    UIDropDownMenu_Initialize(classDropdown, function(self, level)
        local info = UIDropDownMenu_CreateInfo()
        local classes = {"All", "Warrior", "Paladin", "Hunter", "Rogue", "Priest", "Shaman", "Mage", "Warlock", "Druid", "Death Knight"}
        for _, class in ipairs(classes) do
            info.text = class == "All" and "All Classes" or class
            info.value = class
            info.func = function()
                frame.filterClass = class
                UIDropDownMenu_SetText(classDropdown, info.text)
                GrindCalculator:ApplySessionFilters()
            end
            info.checked = (frame.filterClass == class)
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    filterFrame.classDropdown = classDropdown
    
    -- Race dropdown (second row, below class)
    local raceDropdown = CreateFrame("Frame", "GCSessionRaceDropdown", filterFrame, "UIDropDownMenuTemplate")
    raceDropdown:SetPoint("TOPLEFT", classDropdown, "BOTTOMLEFT", 0, 2)
    UIDropDownMenu_SetWidth(raceDropdown, 130)
    UIDropDownMenu_SetText(raceDropdown, "All Races")
    
    UIDropDownMenu_Initialize(raceDropdown, function(self, level)
        local info = UIDropDownMenu_CreateInfo()
        local races = {"All", "Human", "Orc", "Dwarf", "Night Elf", "Undead", "Tauren", "Gnome", "Troll", "Blood Elf", "Draenei"}
        for _, race in ipairs(races) do
            info.text = race == "All" and "All Races" or race
            info.value = race
            info.func = function()
                frame.filterRace = race
                UIDropDownMenu_SetText(raceDropdown, info.text)
                GrindCalculator:ApplySessionFilters()
            end
            info.checked = (frame.filterRace == race)
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    filterFrame.raceDropdown = raceDropdown
    
    -- Realm dropdown (third row, below race)
    local realmDropdown = CreateFrame("Frame", "GCSessionRealmDropdown", filterFrame, "UIDropDownMenuTemplate")
    realmDropdown:SetPoint("TOPLEFT", raceDropdown, "BOTTOMLEFT", 0, 2)
    UIDropDownMenu_SetWidth(realmDropdown, 130)
    UIDropDownMenu_SetText(realmDropdown, "All Realms")
    
    UIDropDownMenu_Initialize(realmDropdown, function(self, level)
        -- Get unique realms from sessions
        local realms = {"All"}
        local realmSet = {}
        GrindCalculator:EnsureSavedVariables()
        local sessions = GrindCalculatorDB.sessions or {}
        for _, session in ipairs(sessions) do
            if session.character and session.character.realm then
                local realm = session.character.realm
                if not realmSet[realm] then
                    realmSet[realm] = true
                    table.insert(realms, realm)
                end
            end
        end
        table.sort(realms, function(a, b)
            if a == "All" then return true end
            if b == "All" then return false end
            return a < b
        end)
        
        local info = UIDropDownMenu_CreateInfo()
        for _, realm in ipairs(realms) do
            info.text = realm == "All" and "All Realms" or realm
            info.value = realm
            info.func = function()
                frame.filterRealm = realm
                UIDropDownMenu_SetText(realmDropdown, info.text)
                GrindCalculator:ApplySessionFilters()
            end
            info.checked = (frame.filterRealm == realm)
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

    local detailScroll = CreateFrame("ScrollFrame", nil, detailPanel, "UIPanelScrollFrameTemplate")
    detailScroll:SetPoint("TOPLEFT", detailPanel, "TOPLEFT", 6, -6)
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

function GrindCalculator:SelectGraphTab(tabIndex)
    if not self.sessionsFrame or not self.sessionsFrame.trendsPanel then
        return
    end
    
    local trendsPanel = self.sessionsFrame.trendsPanel
    trendsPanel.activeTab = tabIndex
    
    -- Update tab visuals
    for i, tab in ipairs(trendsPanel.tabs) do
        if i == tabIndex then
            tab.bg:SetColorTexture(0.4, 0.6, 0.8, 1.0)  -- Active tab color
            if HIGHLIGHT_FONT_COLOR then
                tab.text:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
            end
        else
            tab.bg:SetColorTexture(0.2, 0.2, 0.2, 0.8)  -- Inactive tab color
            tab.text:SetTextColor(1, 1, 1)
        end
    end
    
    -- Show/hide graphs based on active tab
    local graphContainer = trendsPanel.graphContainer
    if graphContainer then
        if graphContainer.currencyGraph then
            if tabIndex == 1 then
                graphContainer.currencyGraph:Show()
            else
                graphContainer.currencyGraph:Hide()
            end
        end
        
        if graphContainer.xpGraph then
            if tabIndex == 2 then
                graphContainer.xpGraph:Show()
            else
                graphContainer.xpGraph:Hide()
            end
        end
        
        if graphContainer.lootChart then
            if tabIndex == 3 then
                graphContainer.lootChart:Show()
            else
                graphContainer.lootChart:Hide()
            end
        end
    end
end

function GrindCalculator:ToggleSessionsWindow()
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

function GrindCalculator:RefreshSessionsList()
    if not self.sessionsFrame then
        return
    end

    self:EnsureSavedVariables()
    local sessions = GrindCalculatorDB.sessions or {}
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
            local raceIcon = self:GetRaceIconString(session.character.race)
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

function GrindCalculator:DisplaySessionDetails(sessionNum, session)
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
                local raceIcon = self:GetRaceIconString(session.character.race)
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
    
    table.insert(lines, "")
    
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
            table.insert(lines, "|cffffd700Mob Statistics:|r")
            
            for i, mob in ipairs(mobList) do
                if i <= 10 then -- Show top 10 mobs
                    local avgCopper = mob.stats.kills > 0 and (mob.stats.currency / mob.stats.kills) or 0
                    local lootCount = (mob.stats.loot[2] or 0) + (mob.stats.loot[3] or 0) + (mob.stats.loot[4] or 0)
                    
                    table.insert(lines, string.format("  |cffaaaaaa%s|r", mob.name))
                    table.insert(lines, string.format("    Kills: %d | Avg: %s", 
                        mob.stats.kills, 
                        self:FormatCoin(avgCopper)))
                    
                    if lootCount > 0 then
                        local lootParts = {}
                        if mob.stats.loot[4] and mob.stats.loot[4] > 0 then
                            table.insert(lootParts, string.format("|cffa335ee%d|r", mob.stats.loot[4]))
                        end
                        if mob.stats.loot[3] and mob.stats.loot[3] > 0 then
                            table.insert(lootParts, string.format("|cff0070dd%d|r", mob.stats.loot[3]))
                        end
                        if mob.stats.loot[2] and mob.stats.loot[2] > 0 then
                            table.insert(lootParts, string.format("|cff1eff00%d|r", mob.stats.loot[2]))
                        end
                        table.insert(lines, string.format("    Notable: %s", table.concat(lootParts, " ")))
                    end
                end
            end
            
            if #mobList > 10 then
                table.insert(lines, string.format("  |cff888888... and %d more|r", #mobList - 10))
            end
        end
    end
    
    local fullText = table.concat(lines, "\n")
    text:SetText(fullText)
    
    -- Update scroll height
    local textHeight = text:GetStringHeight()
    detailChild:SetHeight(math.max(textHeight + 16, 1))
end

function GrindCalculator:FormatNumber(num)
    num = tonumber(num) or 0
    if num >= 1000000 then
        return string.format("%.1fM", num / 1000000)
    elseif num >= 1000 then
        return string.format("%.1fK", num / 1000)
    else
        return tostring(num)
    end
end

function GrindCalculator:GetRaceIconString(race)
    if not race then return nil end
    
    -- Use individual race icon files
    local raceIcons = {
        Human = "Interface\\Icons\\Achievement_Character_Human_Male",
        Orc = "Interface\\Icons\\Achievement_Character_Orc_Male",
        Dwarf = "Interface\\Icons\\Achievement_Character_Dwarf_Male",
        NightElf = "Interface\\Icons\\Achievement_Character_Nightelf_Male",
        Scourge = "Interface\\Icons\\Achievement_Character_Undead_Male",
        Tauren = "Interface\\Icons\\Achievement_Character_Tauren_Male",
        Gnome = "Interface\\Icons\\Achievement_Character_Gnome_Male",
        Troll = "Interface\\Icons\\Achievement_Character_Troll_Male",
        Goblin = "Interface\\Icons\\Achievement_Character_Goblin_Male",
        BloodElf = "Interface\\Icons\\Achievement_Character_Bloodelf_Male",
        Draenei = "Interface\\Icons\\Achievement_Character_Draenei_Male",
        Worgen = "Interface\\Icons\\Achievement_Character_Worgen_Male",
        Pandaren = "Interface\\Icons\\Achievement_Character_Pandaren_Female",
    }
    
    local iconPath = raceIcons[race]
    if iconPath then
        return string.format("|T%s:16:16:0:0:64:64:4:60:4:60|t", iconPath)
    end
    
    return nil
end

function GrindCalculator:GetClassIconString(class)
    if not class then return nil end
    
    -- Use individual class icon files
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
        DEATHKNIGHT = "Interface\\Icons\\ClassIcon_DeathKnight",
        MONK = "Interface\\Icons\\ClassIcon_Monk",
        DEMONHUNTER = "Interface\\Icons\\ClassIcon_DemonHunter",
    }
    
    local iconPath = classIcons[class]
    if iconPath then
        return string.format("|T%s:16:16:0:0:64:64:4:60:4:60|t", iconPath)
    end
    
    return nil
end

-- Graph Data Preparation Functions

function GrindCalculator:PrepareGraphData(sessions, metricFunc)
    -- Handle empty sessions array
    if not sessions or #sessions == 0 then
        return {
            dataPoints = {},
            minValue = 0,
            maxValue = 0,
        }
    end
    
    local dataPoints = {}
    local minValue = nil
    local maxValue = nil
    
    -- Extract data points from sessions using the provided metric function
    for i, session in ipairs(sessions) do
        -- Call the metric function to get the value for this session
        local value, shouldInclude = metricFunc(session, i)
        
        -- Only include the data point if the metric function says so
        if shouldInclude then
            local timestamp = session.startedAt or 0
            
            -- Create label for tooltip
            local label = string.format("Session #%d", i)
            if session.character and session.character.name then
                label = label .. " - " .. session.character.name
            end
            
            -- Add data point
            table.insert(dataPoints, {
                sessionIndex = i,
                value = value,
                timestamp = timestamp,
                label = label,
            })
            
            -- Track min/max values
            if minValue == nil or value < minValue then
                minValue = value
            end
            if maxValue == nil or value > maxValue then
                maxValue = value
            end
        end
    end
    
    -- Sort data points by timestamp (chronological order)
    table.sort(dataPoints, function(a, b)
        return a.timestamp < b.timestamp
    end)
    
    -- Set defaults if no data points
    if #dataPoints == 0 then
        minValue = 0
        maxValue = 0
    end
    
    return {
        dataPoints = dataPoints,
        minValue = minValue or 0,
        maxValue = maxValue or 0,
    }
end

-- Line Graph Rendering Functions

function GrindCalculator:CreateLineGraph(parent, width, height, title, isCurrencyGraph)
    -- Create the main graph frame
    local graph = CreateFrame("Frame", nil, parent)
    graph:SetSize(width, height)
    graph.isCurrencyGraph = isCurrencyGraph or false
    
    -- Create title font string
    graph.title = graph:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    graph.title:SetPoint("TOP", graph, "TOP", 0, -5)
    graph.title:SetText(title or "Graph")
    if HIGHLIGHT_FONT_COLOR then
        graph.title:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
    end
    
    -- Create canvas frame for drawing surface
    local canvas = CreateFrame("Frame", nil, graph)
    canvas:SetPoint("TOPLEFT", graph, "TOPLEFT", 30, -25)
    canvas:SetPoint("BOTTOMRIGHT", graph, "BOTTOMRIGHT", -10, 15)
    
    -- Add background to canvas
    canvas.bg = canvas:CreateTexture(nil, "BACKGROUND")
    canvas.bg:SetAllPoints(canvas)
    canvas.bg:SetColorTexture(0, 0, 0, 0.3)
    
    graph.canvas = canvas
    
    -- Create Y-axis label
    graph.yAxisLabel = graph:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    graph.yAxisLabel:SetPoint("BOTTOMLEFT", canvas, "TOPLEFT", -25, 5)
    graph.yAxisLabel:SetText("0")
    graph.yAxisLabel:SetJustifyH("RIGHT")
    
    -- Create X-axis label
    graph.xAxisLabel = graph:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    graph.xAxisLabel:SetPoint("BOTTOMLEFT", canvas, "BOTTOMLEFT", 0, -12)
    graph.xAxisLabel:SetText("")
    graph.xAxisLabel:SetJustifyH("LEFT")
    
    -- Initialize storage for textures and metadata
    graph.dataPointTextures = {}
    graph.lineTextures = {}
    graph.dataPointMetadata = {}
    
    return graph
end

function GrindCalculator:RenderLineGraph(graph, dataPoints, color)
    if not graph or not graph.canvas then
        return
    end
    
    -- Clear existing textures
    for _, texture in ipairs(graph.dataPointTextures or {}) do
        texture:Hide()
    end
    for _, texture in ipairs(graph.lineTextures or {}) do
        texture:Hide()
    end
    
    graph.dataPointTextures = {}
    graph.lineTextures = {}
    graph.dataPointMetadata = {}
    
    -- Handle empty data
    if not dataPoints or #dataPoints == 0 then
        if graph.yAxisLabel then
            graph.yAxisLabel:SetText("0")
        end
        if graph.xAxisLabel then
            graph.xAxisLabel:SetText("No data")
        end
        return
    end
    
    local canvas = graph.canvas
    local canvasWidth = canvas:GetWidth()
    local canvasHeight = canvas:GetHeight()
    
    -- Calculate max value for Y-axis scaling
    local maxValue = 0
    for _, point in ipairs(dataPoints) do
        if point.value > maxValue then
            maxValue = point.value
        end
    end
    
    -- Avoid division by zero
    if maxValue == 0 then
        maxValue = 1
    end
    
    -- Calculate Y-axis scale factor
    local yScale = canvasHeight / maxValue
    
    -- Calculate X-axis spacing
    local pointCount = #dataPoints
    local xSpacing = canvasWidth / math.max(pointCount - 1, 1)
    
    -- If only one point, center it
    if pointCount == 1 then
        xSpacing = canvasWidth / 2
    end
    
    -- Set default color if not provided
    local r, g, b = 1, 1, 1
    if color then
        r, g, b = color.r or 1, color.g or 1, color.b or 1
    end
    
    -- Render data points and connecting lines
    for i, point in ipairs(dataPoints) do
        -- Calculate position
        local x = (i == 1 and pointCount == 1) and (canvasWidth / 2) or ((i - 1) * xSpacing)
        local y = point.value * yScale
        
        -- Create data point texture (4x4 pixel colored square)
        local dotTexture = canvas:CreateTexture(nil, "ARTWORK")
        dotTexture:SetSize(4, 4)
        dotTexture:SetColorTexture(r, g, b, 1)
        dotTexture:SetPoint("BOTTOMLEFT", canvas, "BOTTOMLEFT", x - 2, y - 2)
        table.insert(graph.dataPointTextures, dotTexture)
        
        -- Store metadata for interaction handling
        graph.dataPointMetadata[i] = {
            sessionIndex = point.sessionIndex,
            value = point.value,
            label = point.label,
            x = x,
            y = y,
        }
        
        -- Create line to previous point
        if i > 1 then
            local prevPoint = dataPoints[i - 1]
            local prevX = (i == 2 and pointCount == 1) and (canvasWidth / 2) or ((i - 2) * xSpacing)
            local prevY = prevPoint.value * yScale
            
            -- Calculate line parameters
            local dx = x - prevX
            local dy = y - prevY
            local distance = math.sqrt(dx * dx + dy * dy)
            
            -- Create multiple small segments to approximate the line
            -- This works around WoW's lack of arbitrary texture rotation
            local segments = math.max(math.ceil(distance / 3), 1)
            
            for seg = 0, segments - 1 do
                local t = seg / segments
                local segX = prevX + (dx * t)
                local segY = prevY + (dy * t)
                
                local lineTexture = canvas:CreateTexture(nil, "ARTWORK")
                lineTexture:SetSize(3, 3)
                lineTexture:SetColorTexture(r, g, b, 0.7)
                lineTexture:SetPoint("BOTTOMLEFT", canvas, "BOTTOMLEFT", segX - 1.5, segY - 1.5)
                
                table.insert(graph.lineTextures, lineTexture)
            end
        end
    end
    
    -- Update Y-axis label with max value
    if graph.yAxisLabel then
        if graph.isCurrencyGraph then
            -- Convert copper to gold for currency graphs
            local goldValue = maxValue / 10000
            graph.yAxisLabel:SetText(string.format("%.0fg", goldValue))
        else
            graph.yAxisLabel:SetText(self:FormatNumber(maxValue))
        end
    end
    
    -- Update X-axis label
    if graph.xAxisLabel then
        if pointCount == 1 then
            graph.xAxisLabel:SetText("1 session")
        else
            graph.xAxisLabel:SetText(string.format("%d sessions", pointCount))
        end
    end
end

-- Graph Interaction Functions

function GrindCalculator:SetupGraphInteractions(graph, dataPoints)
    if not graph or not graph.canvas or not dataPoints then
        return
    end
    
    -- Clear existing interaction buttons
    if graph.interactionButtons then
        for _, btn in ipairs(graph.interactionButtons) do
            btn:Hide()
            btn:SetParent(nil)
        end
    end
    graph.interactionButtons = {}
    
    local canvas = graph.canvas
    
    -- Create invisible button frames over each data point
    for i, metadata in ipairs(graph.dataPointMetadata or {}) do
        local btn = CreateFrame("Button", nil, canvas)
        btn:SetSize(12, 12)  -- Larger clickable area than the 4x4 dot
        btn:SetPoint("BOTTOMLEFT", canvas, "BOTTOMLEFT", metadata.x - 6, metadata.y - 6)
        
        -- Set OnEnter script to show GameTooltip with session info
        btn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(metadata.label, 1, 1, 1)
            
            -- Format the value based on graph type
            local valueText
            if graph.isCurrencyGraph then
                -- Show as gold with coin icons
                valueText = GrindCalculator:FormatCoinWithIcons(metadata.value)
            else
                valueText = GrindCalculator:FormatNumber(metadata.value)
            end
            GameTooltip:AddLine(valueText, nil, nil, nil, true)
            
            GameTooltip:Show()
        end)
        
        -- Set OnLeave script to hide GameTooltip
        btn:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
        
        -- Set OnClick script to select session in list and update detail panel
        btn:SetScript("OnClick", function()
            GrindCalculator:SelectSessionFromGraph(metadata.sessionIndex)
        end)
        
        table.insert(graph.interactionButtons, btn)
    end
end

function GrindCalculator:HighlightDataPoint(graph, sessionIndex)
    if not graph or not graph.dataPointTextures or not graph.dataPointMetadata then
        return
    end
    
    -- Reset all data points to normal size and alpha
    for i, texture in ipairs(graph.dataPointTextures) do
        texture:SetSize(4, 4)
        texture:SetAlpha(1.0)
    end
    
    -- Find and highlight the data point for the selected session
    for i, metadata in ipairs(graph.dataPointMetadata) do
        if metadata.sessionIndex == sessionIndex then
            local texture = graph.dataPointTextures[i]
            if texture then
                -- Make the selected point larger and brighter
                texture:SetSize(8, 8)
                texture:SetAlpha(1.0)
                -- Reposition to keep it centered
                texture:ClearAllPoints()
                texture:SetPoint("BOTTOMLEFT", graph.canvas, "BOTTOMLEFT", metadata.x - 4, metadata.y - 4)
            end
            break
        end
    end
end

function GrindCalculator:SelectSessionFromGraph(sessionIndex)
    if not self.sessionsFrame then
        return
    end
    
    -- Ensure saved variables exist
    self:EnsureSavedVariables()
    local sessions = GrindCalculatorDB.sessions or {}
    
    if sessionIndex < 1 or sessionIndex > #sessions then
        return
    end
    
    local session = sessions[sessionIndex]
    
    -- Display session details
    self:DisplaySessionDetails(sessionIndex, session)
    
    -- Update session list selection visual
    local listChild = self.sessionsFrame.listChild
    if listChild and listChild.sessionButtons then
        for _, btn in ipairs(listChild.sessionButtons) do
            if btn.Background then
                btn.Background:SetColorTexture(0.1, 0.1, 0.1, 0.5)
            end
        end
        
        -- Find the button for this session (sessions are displayed in reverse order)
        local buttonIndex = #sessions - sessionIndex + 1
        local selectedBtn = listChild.sessionButtons[buttonIndex]
        if selectedBtn and selectedBtn.Background then
            selectedBtn.Background:SetColorTexture(0.2, 0.4, 0.6, 0.7)
        end
    end
    
    -- Highlight data points on all graphs
    local graphContainer = self.sessionsFrame.trendsPanel and self.sessionsFrame.trendsPanel.graphContainer
    if graphContainer then
        if graphContainer.currencyGraph then
            self:HighlightDataPoint(graphContainer.currencyGraph, sessionIndex)
        end
        if graphContainer.xpGraph then
            self:HighlightDataPoint(graphContainer.xpGraph, sessionIndex)
        end
    end
end

-- Bar Chart Rendering Functions

function GrindCalculator:CreateBarChart(parent, width, height, title)
    -- Create the main chart frame
    local chart = CreateFrame("Frame", nil, parent)
    chart:SetSize(width, height)
    
    -- Create title font string
    chart.title = chart:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    chart.title:SetPoint("TOP", chart, "TOP", 0, -5)
    chart.title:SetText(title or "Chart")
    if HIGHLIGHT_FONT_COLOR then
        chart.title:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
    end
    
    -- Create canvas frame for drawing surface
    local canvas = CreateFrame("Frame", nil, chart)
    canvas:SetPoint("TOPLEFT", chart, "TOPLEFT", 30, -25)
    canvas:SetPoint("BOTTOMRIGHT", chart, "BOTTOMRIGHT", -10, 15)
    
    -- Add background to canvas
    canvas.bg = canvas:CreateTexture(nil, "BACKGROUND")
    canvas.bg:SetAllPoints(canvas)
    canvas.bg:SetColorTexture(0, 0, 0, 0.3)
    
    chart.canvas = canvas
    
    -- Initialize storage for bar segments and metadata
    chart.barSegments = {}
    chart.sessionMetadata = {}
    
    return chart
end

function GrindCalculator:RenderBarChart(chart, sessions)
    if not chart or not chart.canvas then
        return
    end
    
    -- Clear existing bar segments
    for _, segment in ipairs(chart.barSegments or {}) do
        segment:Hide()
    end
    
    chart.barSegments = {}
    chart.sessionMetadata = {}
    
    -- Handle empty sessions
    if not sessions or #sessions == 0 then
        return
    end
    
    local canvas = chart.canvas
    local canvasWidth = canvas:GetWidth()
    local canvasHeight = canvas:GetHeight()
    
    -- Calculate max total loot count for Y-axis scaling
    local maxTotalLoot = 0
    for _, session in ipairs(sessions) do
        if session.loot then
            local total = (session.loot[2] or 0) + (session.loot[3] or 0) + (session.loot[4] or 0)
            if total > maxTotalLoot then
                maxTotalLoot = total
            end
        end
    end
    
    -- Avoid division by zero
    if maxTotalLoot == 0 then
        maxTotalLoot = 1
    end
    
    -- Calculate bar width based on session count and available space
    local sessionCount = #sessions
    local barSpacing = 2
    local totalSpacing = barSpacing * (sessionCount + 1)
    local availableWidth = canvasWidth - totalSpacing
    local barWidth = math.max(math.floor(availableWidth / sessionCount), 1)
    
    -- Get quality colors from WoW's ITEM_QUALITY_COLORS
    local qualityColors = ITEM_QUALITY_COLORS or {}
    local greenColor = qualityColors[2] or { r = 0.12, g = 1.0, b = 0.0 }
    local blueColor = qualityColors[3] or { r = 0.0, g = 0.44, b = 0.87 }
    local purpleColor = qualityColors[4] or { r = 0.64, g = 0.21, b = 0.93 }
    
    -- Render bars for each session
    for i, session in ipairs(sessions) do
        local loot = session.loot or {}
        local greenCount = loot[2] or 0
        local blueCount = loot[3] or 0
        local purpleCount = loot[4] or 0
        local totalLoot = greenCount + blueCount + purpleCount
        
        -- Calculate bar position
        local barX = barSpacing + ((i - 1) * (barWidth + barSpacing))
        
        -- Store session metadata for interaction handling
        chart.sessionMetadata[i] = {
            sessionIndex = i,
            session = session,
            x = barX,
            width = barWidth,
            greenCount = greenCount,
            blueCount = blueCount,
            purpleCount = purpleCount,
        }
        
        -- Only render if there's loot to display
        if totalLoot > 0 then
            local currentY = 0
            
            -- Create stacked bar segments (green, blue, purple from bottom to top)
            -- Green segment (bottom)
            if greenCount > 0 then
                local segmentHeight = (greenCount / maxTotalLoot) * canvasHeight
                local greenSegment = canvas:CreateTexture(nil, "ARTWORK")
                greenSegment:SetSize(barWidth, segmentHeight)
                greenSegment:SetColorTexture(greenColor.r, greenColor.g, greenColor.b, 0.8)
                greenSegment:SetPoint("BOTTOMLEFT", canvas, "BOTTOMLEFT", barX, currentY)
                table.insert(chart.barSegments, greenSegment)
                currentY = currentY + segmentHeight
            end
            
            -- Blue segment (middle)
            if blueCount > 0 then
                local segmentHeight = (blueCount / maxTotalLoot) * canvasHeight
                local blueSegment = canvas:CreateTexture(nil, "ARTWORK")
                blueSegment:SetSize(barWidth, segmentHeight)
                blueSegment:SetColorTexture(blueColor.r, blueColor.g, blueColor.b, 0.8)
                blueSegment:SetPoint("BOTTOMLEFT", canvas, "BOTTOMLEFT", barX, currentY)
                table.insert(chart.barSegments, blueSegment)
                currentY = currentY + segmentHeight
            end
            
            -- Purple segment (top)
            if purpleCount > 0 then
                local segmentHeight = (purpleCount / maxTotalLoot) * canvasHeight
                local purpleSegment = canvas:CreateTexture(nil, "ARTWORK")
                purpleSegment:SetSize(barWidth, segmentHeight)
                purpleSegment:SetColorTexture(purpleColor.r, purpleColor.g, purpleColor.b, 0.8)
                purpleSegment:SetPoint("BOTTOMLEFT", canvas, "BOTTOMLEFT", barX, currentY)
                table.insert(chart.barSegments, purpleSegment)
            end
        end
    end
end

-- Trends Panel Refresh Function

function GrindCalculator:GetFilteredSessions()
    self:EnsureSavedVariables()
    local sessions = GrindCalculatorDB.sessions or {}
    
    if not self.sessionsFrame then
        return sessions
    end
    
    local filterText = self.sessionsFrame.filterText or ""
    local filterClass = self.sessionsFrame.filterClass or "All"
    local filterRace = self.sessionsFrame.filterRace or "All"
    local filterRealm = self.sessionsFrame.filterRealm or "All"
    
    -- If no filters applied, return all sessions
    if filterText == "" and filterClass == "All" and filterRace == "All" and filterRealm == "All" then
        return sessions
    end
    
    -- Apply filters
    local filtered = {}
    for _, session in ipairs(sessions) do
        local charName = (session.character and session.character.name or "Unknown"):lower()
        local charClass = session.character and session.character.class or ""
        local charRace = session.character and session.character.race or ""
        local charRealm = session.character and session.character.realm or ""
        
        local matchesText = filterText == "" or charName:find(filterText, 1, true)
        local matchesClass = filterClass == "All" or charClass == filterClass
        local matchesRace = filterRace == "All" or charRace == filterRace
        local matchesRealm = filterRealm == "All" or charRealm == filterRealm
        
        if matchesText and matchesClass and matchesRace and matchesRealm then
            table.insert(filtered, session)
        end
    end
    
    return filtered
end

function GrindCalculator:ApplySessionFilters()
    self:RefreshSessionsList()
    self:RefreshTrendsPanel()
end

function GrindCalculator:RefreshTrendsPanel()
    if not self.sessionsFrame or not self.sessionsFrame.trendsPanel then
        return
    end
    
    local trendsPanel = self.sessionsFrame.trendsPanel
    local summaryFrame = trendsPanel.summaryFrame
    local graphContainer = trendsPanel.graphContainer
    
    -- Get filtered sessions
    local sessions = self:GetFilteredSessions()
    
    -- Handle empty sessions case
    if #sessions == 0 then
        -- Update summary statistics to show "No data available"
        if summaryFrame.totalSessionsText then
            summaryFrame.totalSessionsText:SetText("No data available")
        end
        if summaryFrame.totalTimeText then
            summaryFrame.totalTimeText:SetText("")
        end
        if summaryFrame.avgCopperPerHourText then
            summaryFrame.avgCopperPerHourText:SetText("")
        end
        if summaryFrame.bestCopperPerHourText then
            summaryFrame.bestCopperPerHourText:SetText("")
        end
        
        -- Hide all graphs and tabs
        if graphContainer.currencyGraph then
            graphContainer.currencyGraph:Hide()
        end
        if graphContainer.xpGraph then
            graphContainer.xpGraph:Hide()
        end
        if graphContainer.lootChart then
            graphContainer.lootChart:Hide()
        end
        
        -- Hide tabs when no data
        if self.sessionsFrame.trendsPanel.tabContainer then
            self.sessionsFrame.trendsPanel.tabContainer:Hide()
        end
        
        return
    end
    
    -- Show tabs when there is data
    if self.sessionsFrame.trendsPanel.tabContainer then
        self.sessionsFrame.trendsPanel.tabContainer:Show()
    end
    
    -- Call CalculateTrendStatistics with filtered sessions
    local stats = self:CalculateTrendStatistics(sessions)
    
    -- Update summary statistics font strings with formatted values
    if summaryFrame.totalSessionsText then
        summaryFrame.totalSessionsText:SetText(string.format("Total Sessions: %d", stats.totalSessions))
    end
    
    if summaryFrame.totalTimeText then
        summaryFrame.totalTimeText:SetText(string.format("Total Time: %s", self:FormatTime(stats.totalDuration)))
    end
    
    if summaryFrame.avgCopperPerHourText then
        local avgText = self:FormatCoinWithIcons(stats.avgCopperPerHour) .. "/hr"
        summaryFrame.avgCopperPerHourText:SetText("Avg: " .. avgText)
    end
    
    if summaryFrame.bestCopperPerHourText then
        local bestText = self:FormatCoinWithIcons(stats.bestCopperPerHour) .. "/hr"
        summaryFrame.bestCopperPerHourText:SetText("Best: " .. bestText)
    end
    
    -- Prepare and render currency per hour graph
    local currencyMetricFunc = function(session, index)
        local duration = session.duration or 0
        if duration == 0 then
            return 0, false  -- Exclude sessions with zero duration
        end
        
        local currency = (session.currencyCopper or 0) + (session.grayCopper or 0) + (session.potentialAHCopper or 0)
        local durationHours = duration / 3600
        local copperPerHour = currency / durationHours
        
        return copperPerHour, true
    end
    
    local currencyGraphData = self:PrepareGraphData(sessions, currencyMetricFunc)
    
    -- Create currency graph if it doesn't exist
    if not graphContainer.currencyGraph then
        local graphWidth = graphContainer:GetWidth() - 20
        local graphHeight = graphContainer:GetHeight() - 20
        graphContainer.currencyGraph = self:CreateLineGraph(graphContainer, graphWidth, graphHeight, "Currency Per Hour", true)
        graphContainer.currencyGraph:SetPoint("TOPLEFT", graphContainer, "TOPLEFT", 10, -10)
        graphContainer.currencyGraph:SetPoint("BOTTOMRIGHT", graphContainer, "BOTTOMRIGHT", -10, 10)
    end
    
    -- Render currency graph
    local currencyColor = { r = 1, g = 0.82, b = 0 }  -- Gold color
    self:RenderLineGraph(graphContainer.currencyGraph, currencyGraphData.dataPoints, currencyColor)
    self:SetupGraphInteractions(graphContainer.currencyGraph, currencyGraphData.dataPoints)
    
    -- Prepare and render XP per hour graph (filtered for non-max-level sessions)
    local xpMetricFunc = function(session, index)
        -- Filter out max-level sessions
        if session.wasMaxLevel then
            return 0, false
        end
        
        local duration = session.duration or 0
        if duration == 0 then
            return 0, false  -- Exclude sessions with zero duration
        end
        
        local xp = session.totalXP or 0
        local durationHours = duration / 3600
        local xpPerHour = xp / durationHours
        
        return xpPerHour, true
    end
    
    local xpGraphData = self:PrepareGraphData(sessions, xpMetricFunc)
    
    -- Create XP graph if it doesn't exist
    if not graphContainer.xpGraph then
        local graphWidth = graphContainer:GetWidth() - 20
        local graphHeight = graphContainer:GetHeight() - 20
        graphContainer.xpGraph = self:CreateLineGraph(graphContainer, graphWidth, graphHeight, "XP Per Hour")
        graphContainer.xpGraph:SetPoint("TOPLEFT", graphContainer, "TOPLEFT", 10, -10)
        graphContainer.xpGraph:SetPoint("BOTTOMRIGHT", graphContainer, "BOTTOMRIGHT", -10, 10)
    end
    
    -- Render XP graph
    local xpColor = { r = 0.5, g = 0.5, b = 1 }  -- Blue color
    self:RenderLineGraph(graphContainer.xpGraph, xpGraphData.dataPoints, xpColor)
    self:SetupGraphInteractions(graphContainer.xpGraph, xpGraphData.dataPoints)
    
    -- Create loot quality chart if it doesn't exist
    if not graphContainer.lootChart then
        local chartWidth = graphContainer:GetWidth() - 20
        local chartHeight = graphContainer:GetHeight() - 20
        graphContainer.lootChart = self:CreateBarChart(graphContainer, chartWidth, chartHeight, "Loot Quality by Session")
        graphContainer.lootChart:SetPoint("TOPLEFT", graphContainer, "TOPLEFT", 10, -10)
        graphContainer.lootChart:SetPoint("BOTTOMRIGHT", graphContainer, "BOTTOMRIGHT", -10, 10)
    end
    
    -- Render loot quality chart
    self:RenderBarChart(graphContainer.lootChart, sessions)
    
    -- Show only the active tab's graph
    self:SelectGraphTab(self.sessionsFrame.trendsPanel.activeTab or 1)
end
