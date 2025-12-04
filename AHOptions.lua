local GrindCompanion = _G.GrindCompanion

-- ============================================================================
-- AH Tracking Options Panel
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
    instructions:SetText("Add items to track their auction house value during grinding sessions.\n\nMethods to add items:\n• Use the button below to add items from your bags\n• Use /gc select-ah start to shift+click items\n• Use the minimap menu 'Add AH Item' option")
    
    -- Add Item Button
    local addButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    addButton:SetSize(200, 24)
    addButton:SetPoint("TOPLEFT", instructions, "BOTTOMLEFT", 0, -16)
    addButton:SetText("Add Item from Bags")
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
-- Item Picker Dialog
-- ============================================================================

function GrindCompanion:ShowAHItemPicker()
    if not self.ahItemPickerFrame then
        self:CreateAHItemPickerFrame()
    end
    
    self:PopulateAHItemPicker()
    self.ahItemPickerFrame:Show()
end

function GrindCompanion:CreateAHItemPickerFrame()
    local frame = CreateFrame("Frame", "GrindCompanionAHItemPicker", UIParent, "BackdropTemplate")
    frame:SetSize(400, 500)
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
    title:SetText("Select Items from Bags")
    
    -- Close button
    local closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", -5, -5)
    closeBtn:SetScript("OnClick", function()
        frame:Hide()
    end)
    
    -- Scroll frame for items
    local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 20, -50)
    scrollFrame:SetSize(350, 400)
    
    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetSize(330, 1)
    scrollFrame:SetScrollChild(scrollChild)
    
    frame.scrollFrame = scrollFrame
    frame.scrollChild = scrollChild
    frame.itemButtons = {}
    
    self.ahItemPickerFrame = frame
end

function GrindCompanion:PopulateAHItemPicker()
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
    
    -- Scan bags for items (compatible with Classic and Retail)
    local items = {}
    local GetContainerNumSlots = C_Container and C_Container.GetContainerNumSlots or GetContainerNumSlots
    local GetContainerItemInfo = C_Container and C_Container.GetContainerItemInfo or GetContainerItemInfo
    
    for bag = 0, NUM_BAG_SLOTS do
        local numSlots = GetContainerNumSlots(bag)
        for slot = 1, numSlots do
            local info
            if C_Container then
                info = GetContainerItemInfo(bag, slot)
            else
                local texture, itemCount, locked, quality, readable, lootable, itemLink = GetContainerItemInfo(bag, slot)
                if itemLink then
                    info = {
                        hyperlink = itemLink,
                        quality = quality,
                    }
                end
            end
            
            if info and info.hyperlink then
                local itemID = select(1, GetItemInfoInstant(info.hyperlink))
                if itemID and not items[itemID] then
                    items[itemID] = {
                        link = info.hyperlink,
                        itemID = itemID,
                        quality = info.quality,
                    }
                end
            end
        end
    end
    
    -- Convert to array and sort
    local itemArray = {}
    for _, item in pairs(items) do
        table.insert(itemArray, item)
    end
    
    table.sort(itemArray, function(a, b)
        if a.quality ~= b.quality then
            return a.quality > b.quality
        end
        local nameA = GetItemInfo(a.link) or ""
        local nameB = GetItemInfo(b.link) or ""
        return nameA < nameB
    end)
    
    -- Create buttons
    local yOffset = -4
    for i, item in ipairs(itemArray) do
        local btn = self:CreateAHPickerItemButton(frame.scrollChild, item, i)
        btn:SetPoint("TOPLEFT", frame.scrollChild, "TOPLEFT", 4, yOffset)
        table.insert(frame.itemButtons, btn)
        yOffset = yOffset - 32
    end
    
    -- Update scroll height
    local totalHeight = math.max(1, #itemArray * 32 + 8)
    frame.scrollChild:SetHeight(totalHeight)
end

function GrindCompanion:CreateAHPickerItemButton(parent, item, index)
    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetSize(320, 28)
    
    -- Background
    local bg = btn:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.1, 0.1, 0.1, 0.5)
    
    btn:SetScript("OnEnter", function(self)
        bg:SetColorTexture(0.2, 0.2, 0.2, 0.7)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetHyperlink(item.link)
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
    local texture = select(10, GetItemInfo(item.link))
    if texture then
        icon:SetTexture(texture)
    end
    
    -- Name
    local name = btn:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    name:SetPoint("LEFT", icon, "RIGHT", 6, 0)
    name:SetPoint("RIGHT", -80, 0)
    name:SetJustifyH("LEFT")
    name:SetText(item.link)
    
    -- Add button
    local addBtn = CreateFrame("Button", nil, btn, "UIPanelButtonTemplate")
    addBtn:SetSize(60, 22)
    addBtn:SetPoint("RIGHT", -4, 0)
    addBtn:SetText("Add")
    
    -- Check if already tracked
    if GrindCompanion:IsItemTrackedForAH(item.itemID) then
        addBtn:SetText("Added")
        addBtn:Disable()
    end
    
    addBtn:SetScript("OnClick", function()
        local success, result = GrindCompanion:AddTrackedAHItem(item.link)
        if success then
            GrindCompanion:PrintMessage(string.format("Added to AH tracking: %s", item.link))
            addBtn:SetText("Added")
            addBtn:Disable()
            
            -- Refresh options panel if open
            if GrindCompanion.ahOptionsPanel and GrindCompanion.ahOptionsPanel:IsShown() then
                GrindCompanion:RefreshAHItemsList(GrindCompanion.ahOptionsPanel)
            end
        else
            GrindCompanion:PrintMessage(string.format("Failed to add: %s", result))
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
