local GrindCompanion = _G.GrindCompanion

-- ============================================================================
-- Auctionator Integration - Options Panel
-- ============================================================================

function GrindCompanion:CreateAHOptionsPanel()
    -- Use Settings API (available in Classic Era)
    local panel = CreateFrame("Frame", nil, SettingsPanel)
    panel.name = "AH Tracking"
    panel.parent = "GrindCompanion"
    
    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("Auction House Item Tracking")
    
    local subtitle = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    subtitle:SetText("Track specific items for AH value calculation")
    
    -- Instructions
    local instructions = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    instructions:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", 0, -16)
    instructions:SetWidth(550)
    instructions:SetJustifyH("LEFT")
    instructions:SetText("Add items to track their auction house value during grinding sessions.\n\nMethods to add items:\n• Use the button below to search farmable items\n• Use /gc select-ah start to shift+click items\n• Use the minimap menu 'Add AH Item' option")
    
    -- Add Item Button
    local addButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    addButton:SetSize(200, 24)
    addButton:SetPoint("TOPLEFT", instructions, "BOTTOMLEFT", 0, -16)
    addButton:SetText("Search & Add Items")
    addButton:SetScript("OnClick", function()
        GrindCompanion:ShowAHItemPicker()
    end)
    
    -- Clear All Button
    local clearButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    clearButton:SetSize(120, 24)
    clearButton:SetPoint("LEFT", addButton, "RIGHT", 8, 0)
    clearButton:SetText("Clear All")
    clearButton:SetScript("OnClick", function()
        StaticPopup_Show("GRINDCOMPANION_CLEAR_AH_ITEMS")
    end)
    
    -- Tracked Items List
    local listLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    listLabel:SetPoint("TOPLEFT", addButton, "BOTTOMLEFT", 0, -16)
    listLabel:SetText("Tracked Items:")
    
    -- Scroll Frame for tracked items
    local scrollFrame = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", listLabel, "BOTTOMLEFT", 0, -8)
    scrollFrame:SetSize(550, 300)
    
    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetSize(530, 1)
    scrollFrame:SetScrollChild(scrollChild)
    scrollFrame.scrollChild = scrollChild
    
    -- Background for scroll area
    local scrollBg = scrollFrame:CreateTexture(nil, "BACKGROUND")
    scrollBg:SetAllPoints(scrollFrame)
    scrollBg:SetColorTexture(0, 0, 0, 0.3)
    
    panel.scrollFrame = scrollFrame
    panel.scrollChild = scrollChild
    panel.itemRows = {}
    
    -- Refresh function
    panel.refresh = function()
        GrindCompanion:RefreshAHItemsList(panel)
    end
    
    -- Hook into panel show
    panel:SetScript("OnShow", function()
        panel.refresh()
    end)
    
    -- Add to Interface Options using Settings API
    panel.OnCommit = function() end
    panel.OnDefault = function() end
    panel.OnRefresh = function() end
    
    -- Get parent category by name (like AceConfig does)
    local parentCategory = Settings.GetCategory("GrindCompanion")
    if not parentCategory then
        error("Parent category 'GrindCompanion' not found")
    end
    
    local subcategory = Settings.RegisterCanvasLayoutSubcategory(parentCategory, panel, "AH Tracking")
    Settings.RegisterAddOnCategory(subcategory)
    
    self.ahOptionsPanel = panel
    return panel
end

function GrindCompanion:RefreshAHItemsList(panel)
    if not panel or not panel.scrollChild then
        return
    end
    
    -- Clear existing rows
    for _, row in ipairs(panel.itemRows) do
        row:Hide()
        row:SetParent(nil)
    end
    panel.itemRows = {}
    
    -- Get tracked items
    local items = {}
    if self.ahTracking and self.ahTracking.trackedItems then
        for _, item in pairs(self.ahTracking.trackedItems) do
            table.insert(items, item)
        end
    end
    
    -- Sort by name
    table.sort(items, function(a, b)
        return (a.name or "") < (b.name or "")
    end)
    
    -- Create rows
    local yOffset = -4
    for i, item in ipairs(items) do
        local row = self:CreateAHItemRow(panel.scrollChild, item, i)
        row:SetPoint("TOPLEFT", panel.scrollChild, "TOPLEFT", 4, yOffset)
        table.insert(panel.itemRows, row)
        yOffset = yOffset - 28
    end
    
    -- Update scroll child height
    local totalHeight = math.max(1, #items * 28 + 8)
    panel.scrollChild:SetHeight(totalHeight)
    
    -- Show empty message if no items
    if #items == 0 then
        if not panel.emptyLabel then
            panel.emptyLabel = panel.scrollChild:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
            panel.emptyLabel:SetPoint("TOP", panel.scrollChild, "TOP", 0, -20)
            panel.emptyLabel:SetText("No items tracked. Add items using the button above.")
        end
        panel.emptyLabel:Show()
    else
        if panel.emptyLabel then
            panel.emptyLabel:Hide()
        end
    end
end

function GrindCompanion:CreateAHItemRow(parent, item, index)
    local row = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    row:SetSize(520, 24)
    
    -- Alternating background
    local bg = row:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    if index % 2 == 0 then
        bg:SetColorTexture(0.1, 0.1, 0.1, 0.3)
    else
        bg:SetColorTexture(0.15, 0.15, 0.15, 0.3)
    end
    
    -- Item icon
    local icon = row:CreateTexture(nil, "ARTWORK")
    icon:SetSize(20, 20)
    icon:SetPoint("LEFT", 4, 0)
    
    -- Get item texture
    local texture = select(10, GetItemInfo(item.link))
    if texture then
        icon:SetTexture(texture)
    end
    
    -- Item name (clickable link)
    local nameButton = CreateFrame("Button", nil, row)
    nameButton:SetSize(350, 20)
    nameButton:SetPoint("LEFT", icon, "RIGHT", 4, 0)
    
    local nameText = nameButton:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    nameText:SetPoint("LEFT")
    nameText:SetText(item.link or item.name)
    nameText:SetJustifyH("LEFT")
    
    nameButton:SetScript("OnClick", function()
        if IsShiftKeyDown() and ChatEdit_GetActiveWindow() then
            ChatEdit_InsertLink(item.link)
        end
    end)
    
    nameButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetHyperlink(item.link)
        GameTooltip:Show()
    end)
    
    nameButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    
    -- Remove button
    local removeBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
    removeBtn:SetSize(60, 20)
    removeBtn:SetPoint("RIGHT", -4, 0)
    removeBtn:SetText("Remove")
    removeBtn:SetScript("OnClick", function()
        local success, name = GrindCompanion:RemoveTrackedAHItem(item.itemID)
        if success then
            GrindCompanion:PrintMessage(string.format("Removed from AH tracking: %s", name))
            GrindCompanion:RefreshAHItemsList(GrindCompanion.ahOptionsPanel)
        end
    end)
    
    row:Show()
    return row
end

-- ============================================================================
-- Item Picker Dialog with Search
-- ============================================================================

function GrindCompanion:ShowAHItemPicker()
    if not self.ahItemPickerFrame then
        self:CreateAHItemPickerFrame()
    end
    
    -- Clear search and show all items
    if self.ahItemPickerFrame.searchBox then
        self.ahItemPickerFrame.searchBox:SetText("")
    end
    self:UpdateAHItemPickerResults("")
    self.ahItemPickerFrame:Show()
end

function GrindCompanion:CreateAHItemPickerFrame()
    local frame = CreateFrame("Frame", "GrindCompanionAHItemPicker", UIParent, "BackdropTemplate")
    frame:SetSize(450, 550)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG")
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    frame:SetBackdropColor(0, 0, 0, 0.95)
    
    -- Title
    local title = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -20)
    title:SetText("Add Items to Track")
    
    -- Close button
    local closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", -5, -5)
    closeBtn:SetScript("OnClick", function()
        frame:Hide()
    end)
    
    -- Search box label
    local searchLabel = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    searchLabel:SetPoint("TOPLEFT", 20, -50)
    searchLabel:SetText("Search Items:")
    
    -- Search box
    local searchBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
    searchBox:SetSize(350, 30)
    searchBox:SetPoint("TOPLEFT", searchLabel, "BOTTOMLEFT", 5, -5)
    searchBox:SetAutoFocus(false)
    searchBox:SetMaxLetters(50)
    
    searchBox:SetScript("OnTextChanged", function(self)
        local text = self:GetText()
        GrindCompanion:UpdateAHItemPickerResults(text)
    end)
    
    searchBox:SetScript("OnEnterPressed", function(self)
        self:ClearFocus()
    end)
    
    searchBox:SetScript("OnEscapePressed", function(self)
        self:SetText("")
        self:ClearFocus()
    end)
    
    frame.searchBox = searchBox
    
    -- Instructions
    local instructions = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    instructions:SetPoint("TOPLEFT", searchBox, "BOTTOMLEFT", -5, -8)
    instructions:SetWidth(400)
    instructions:SetJustifyH("LEFT")
    instructions:SetText("Type to search farmable items, or paste an item link/ID")
    
    -- Scroll frame for results
    local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", instructions, "BOTTOMLEFT", 0, -10)
    scrollFrame:SetSize(400, 360)
    
    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetSize(380, 1)
    scrollFrame:SetScrollChild(scrollChild)
    
    -- Background for scroll area
    local scrollBg = scrollFrame:CreateTexture(nil, "BACKGROUND")
    scrollBg:SetAllPoints(scrollFrame)
    scrollBg:SetColorTexture(0, 0, 0, 0.3)
    
    frame.scrollFrame = scrollFrame
    frame.scrollChild = scrollChild
    frame.itemButtons = {}
    
    self.ahItemPickerFrame = frame
end

function GrindCompanion:UpdateAHItemPickerResults(searchText)
    local frame = self.ahItemPickerFrame
    if not frame then
        return
    end
    
    -- Clear existing buttons
    for _, btn in ipairs(frame.itemButtons) do
        btn:Hide()
        btn:SetParent(nil)
    end
    frame.itemButtons = {}
    
    local results = {}
    
    -- Check if search text is an item link or ID
    if searchText and searchText ~= "" then
        -- Try to parse as item link
        local itemID = tonumber(searchText:match("item:(%d+)"))
        if not itemID then
            -- Try as direct item ID
            itemID = tonumber(searchText)
        end
        
        if itemID then
            -- Direct item ID or link provided
            local name, link, quality, _, _, _, _, _, _, texture = GetItemInfo(itemID)
            if name then
                table.insert(results, {
                    id = itemID,
                    name = name,
                    link = link,
                    quality = quality,
                    texture = texture,
                })
            else
                -- Item not cached, request it
                if C_Item and C_Item.RequestLoadItemDataByID then
                    C_Item.RequestLoadItemDataByID(itemID)
                end
            end
        else
            -- Text search
            results = self:SearchCachedItems(searchText)
        end
    else
        -- No search text, show all cached items
        for _, item in pairs(self.itemCache.items) do
            table.insert(results, item)
        end
        
        -- Sort alphabetically
        table.sort(results, function(a, b)
            return a.name < b.name
        end)
    end
    
    -- Limit results to prevent lag
    local maxResults = 100
    if #results > maxResults then
        local temp = {}
        for i = 1, maxResults do
            table.insert(temp, results[i])
        end
        results = temp
    end
    
    -- Create buttons
    local yOffset = -4
    for i, item in ipairs(results) do
        local btn = self:CreateAHPickerItemButton(frame.scrollChild, item, i)
        btn:SetPoint("TOPLEFT", frame.scrollChild, "TOPLEFT", 4, yOffset)
        table.insert(frame.itemButtons, btn)
        yOffset = yOffset - 32
    end
    
    -- Show empty message if no results
    if #results == 0 then
        if not frame.emptyLabel then
            frame.emptyLabel = frame.scrollChild:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
            frame.emptyLabel:SetPoint("TOP", frame.scrollChild, "TOP", 0, -20)
        end
        
        if searchText and searchText ~= "" then
            frame.emptyLabel:SetText("No items found. Try a different search or paste an item link.")
        else
            frame.emptyLabel:SetText("Loading items...")
        end
        frame.emptyLabel:Show()
    else
        if frame.emptyLabel then
            frame.emptyLabel:Hide()
        end
    end
    
    -- Update scroll height
    local totalHeight = math.max(300, #results * 32 + 8)
    frame.scrollChild:SetHeight(totalHeight)
end

function GrindCompanion:CreateAHPickerItemButton(parent, item, index)
    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetSize(370, 28)
    
    -- Background
    local bg = btn:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.1, 0.1, 0.1, 0.5)
    
    btn:SetScript("OnEnter", function(self)
        bg:SetColorTexture(0.2, 0.2, 0.2, 0.7)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        if item.link then
            GameTooltip:SetHyperlink(item.link)
        elseif item.id then
            GameTooltip:SetItemByID(item.id)
        end
        GameTooltip:Show()
    end)
    
    btn:SetScript("OnLeave", function()
        bg:SetColorTexture(0.1, 0.1, 0.1, 0.5)
        GameTooltip:Hide()
    end)
    
    -- Icon
    local icon = btn:CreateTexture(nil, "ARTWORK")
    icon:SetSize(24, 24)
    icon:SetPoint("LEFT", 4, 0)
    if item.texture then
        icon:SetTexture(item.texture)
    end
    
    -- Name with quality color
    local name = btn:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    name:SetPoint("LEFT", icon, "RIGHT", 6, 0)
    name:SetPoint("RIGHT", -80, 0)
    name:SetJustifyH("LEFT")
    
    if item.link then
        name:SetText(item.link)
    elseif item.name then
        -- Apply quality color
        local r, g, b = 1, 1, 1
        if item.quality then
            local color = ITEM_QUALITY_COLORS[item.quality]
            if color then
                r, g, b = color.r, color.g, color.b
            end
        end
        name:SetTextColor(r, g, b)
        name:SetText(item.name)
    end
    
    -- Add button
    local addBtn = CreateFrame("Button", nil, btn, "UIPanelButtonTemplate")
    addBtn:SetSize(60, 22)
    addBtn:SetPoint("RIGHT", -4, 0)
    addBtn:SetText("Add")
    
    -- Check if already tracked
    local itemID = item.id or item.itemID
    if itemID and GrindCompanion:IsItemTrackedForAH(itemID) then
        addBtn:SetText("Added")
        addBtn:Disable()
    end
    
    addBtn:SetScript("OnClick", function()
        local linkToAdd = item.link
        if not linkToAdd and itemID then
            -- Generate link from item ID
            linkToAdd = select(2, GetItemInfo(itemID))
        end
        
        if linkToAdd then
            local success, result = GrindCompanion:AddTrackedAHItem(linkToAdd)
            if success then
                GrindCompanion:PrintMessage(string.format("Added to AH tracking: %s", linkToAdd))
                addBtn:SetText("Added")
                addBtn:Disable()
                
                -- Refresh options panel if open
                if GrindCompanion.ahOptionsPanel and GrindCompanion.ahOptionsPanel:IsShown() then
                    GrindCompanion:RefreshAHItemsList(GrindCompanion.ahOptionsPanel)
                end
            else
                GrindCompanion:PrintMessage(string.format("Failed to add: %s", result))
            end
        end
    end)
    
    btn:Show()
    return btn
end

-- ============================================================================
-- Static Popup for Clear Confirmation
-- ============================================================================

StaticPopupDialogs["GRINDCOMPANION_CLEAR_AH_ITEMS"] = {
    text = "Are you sure you want to clear all tracked AH items?",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function()
        GrindCompanion:ClearAllTrackedAHItems()
        GrindCompanion:PrintMessage("Cleared all tracked AH items.")
        if GrindCompanion.ahOptionsPanel then
            GrindCompanion:RefreshAHItemsList(GrindCompanion.ahOptionsPanel)
        end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}
