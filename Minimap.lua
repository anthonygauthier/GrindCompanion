local GrindCompanion = _G.GrindCompanion

-- ============================================================================
-- Minimap Button
-- ============================================================================

function GrindCompanion:InitializeMinimapButton()
    if self.minimapButton then
        return
    end

    local button = CreateFrame("Button", "GrindCompanionMinimapButton", Minimap)
    button:SetSize(32, 32)
    button:SetFrameStrata("MEDIUM")
    button:SetFrameLevel(8)
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    button:RegisterForDrag("LeftButton")
    button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    
    -- Icon
    local icon = button:CreateTexture(nil, "BACKGROUND")
    icon:SetSize(20, 20)
    icon:SetPoint("CENTER", 0, 0)
    icon:SetTexture("Interface\\Icons\\INV_Misc_Coin_01")
    icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    button.icon = icon
    
    -- Border
    local overlay = button:CreateTexture(nil, "OVERLAY")
    overlay:SetSize(52, 52)
    overlay:SetPoint("TOPLEFT", 0, 0)
    overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    button.overlay = overlay
    
    -- Drag functionality
    button:SetScript("OnDragStart", function(self)
        self:LockHighlight()
        self.isMoving = true
    end)
    
    button:SetScript("OnDragStop", function(self)
        self:UnlockHighlight()
        self.isMoving = false
    end)
    
    button:SetScript("OnUpdate", function(self)
        if self.isMoving then
            local mx, my = Minimap:GetCenter()
            local px, py = GetCursorPosition()
            local scale = Minimap:GetEffectiveScale()
            px, py = px / scale, py / scale
            
            local angle = math.atan2(py - my, px - mx)
            GrindCompanion.settings.minimapAngle = angle
            GrindCompanion:UpdateMinimapButtonPosition()
        end
    end)
    
    -- Click handler
    button:SetScript("OnClick", function(self, btn)
        if btn == "LeftButton" then
            GrindCompanion:ToggleMinimapMenu()
        elseif btn == "RightButton" then
            GrindCompanion:ToggleMinimapMenu()
        end
    end)
    
    -- Tooltip
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText("GrindCompanion", 1, 1, 1)
        GameTooltip:AddLine("Left-click: Open menu", 0.8, 0.8, 0.8)
        GameTooltip:AddLine("Drag: Move button", 0.8, 0.8, 0.8)
        GameTooltip:Show()
    end)
    
    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    
    self.minimapButton = button
    
    -- Set initial position
    if not self.settings.minimapAngle then
        self.settings.minimapAngle = math.rad(225) -- Default to bottom-left
    end
    self:UpdateMinimapButtonPosition()
    
    -- Show/hide based on settings
    if self.settings.hideMinimapButton then
        button:Hide()
    else
        button:Show()
    end
end

function GrindCompanion:UpdateMinimapButtonPosition()
    if not self.minimapButton then
        return
    end
    
    local angle = self.settings.minimapAngle or math.rad(225)
    local x = math.cos(angle) * 80
    local y = math.sin(angle) * 80
    
    self.minimapButton:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

function GrindCompanion:ToggleMinimapButton()
    if not self.minimapButton then
        self:InitializeMinimapButton()
    end
    
    if self.settings.hideMinimapButton then
        self.settings.hideMinimapButton = false
        self.minimapButton:Show()
    else
        self.settings.hideMinimapButton = true
        self.minimapButton:Hide()
    end
    
    self:SaveSettings()
end

-- ============================================================================
-- Minimap Menu
-- ============================================================================

function GrindCompanion:InitializeMinimapMenu()
    if self.minimapMenu then
        return
    end
    
    local menu = CreateFrame("Frame", "GrindCompanionMinimapMenu", UIParent, "BackdropTemplate")
    menu:SetFrameStrata("DIALOG")
    menu:SetFrameLevel(100)
    
    menu:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    
    menu:SetBackdropColor(0, 0, 0, 0.9)
    menu:EnableMouse(true)
    menu:Hide()
    
    -- Create menu buttons
    local buttons = {}
    local buttonHeight = 24
    local buttonSpacing = 4
    local topPadding = 18
    local bottomPadding = 18
    local yOffset = -topPadding
    
    local function createMenuButton(text, onClick)
        local btn = CreateFrame("Button", nil, menu, "UIPanelButtonTemplate")
        btn:SetSize(150, buttonHeight)
        btn:SetPoint("TOP", menu, "TOP", 0, yOffset)
        btn:SetText(text)
        btn:SetScript("OnClick", function()
            onClick()
            menu:Hide()
        end)
        table.insert(buttons, btn)
        yOffset = yOffset - buttonHeight - buttonSpacing
        return btn
    end
    
    -- Sessions History button
    createMenuButton("Sessions History", function()
        GrindCompanion:ToggleSessionsWindow()
    end)
    
    -- Start Session button
    createMenuButton("Start Session", function()
        GrindCompanion:StartTracking()
    end)
    
    -- Stop Session button
    createMenuButton("Stop Session", function()
        GrindCompanion:StopTracking()
    end)
    
    -- Add AH Item button
    createMenuButton("Add AH Item", function()
        GrindCompanion:ShowAHItemPicker()
    end)
    
    -- Hide Minimap Button
    createMenuButton("Hide Minimap Button", function()
        GrindCompanion:ToggleMinimapButton()
        GrindCompanion:PrintMessage("Minimap button hidden. Use /gc minimap to show it again.")
    end)
    
    -- Calculate dynamic height based on number of buttons
    local numButtons = #buttons
    local totalHeight = topPadding + (numButtons * buttonHeight) + ((numButtons - 1) * buttonSpacing) + bottomPadding
    menu:SetSize(180, totalHeight)
    
    menu.buttons = buttons
    self.minimapMenu = menu
    
    -- Close menu when clicking outside
    menu:SetScript("OnShow", function()
        self.minimapMenuCloseFrame = self.minimapMenuCloseFrame or CreateFrame("Frame", nil, UIParent)
        self.minimapMenuCloseFrame:SetAllPoints()
        self.minimapMenuCloseFrame:SetFrameStrata("DIALOG")
        self.minimapMenuCloseFrame:SetFrameLevel(99)
        self.minimapMenuCloseFrame:EnableMouse(true)
        self.minimapMenuCloseFrame:SetScript("OnMouseDown", function()
            menu:Hide()
        end)
        self.minimapMenuCloseFrame:Show()
    end)
    
    menu:SetScript("OnHide", function()
        if self.minimapMenuCloseFrame then
            self.minimapMenuCloseFrame:Hide()
        end
    end)
end

function GrindCompanion:ToggleMinimapMenu()
    if not self.minimapMenu then
        self:InitializeMinimapMenu()
    end
    
    if self.minimapMenu:IsShown() then
        self.minimapMenu:Hide()
    else
        -- Position menu near the minimap button with smart edge detection
        local button = self.minimapButton
        if button then
            self.minimapMenu:ClearAllPoints()
            
            -- Get button edges on screen
            local buttonLeft = button:GetLeft()
            local buttonRight = button:GetRight()
            local buttonTop = button:GetTop()
            local buttonBottom = button:GetBottom()
            
            -- Get screen dimensions
            local screenWidth = GetScreenWidth()
            local screenHeight = GetScreenHeight()
            
            -- Get menu dimensions
            local menuWidth = self.minimapMenu:GetWidth()
            local menuHeight = self.minimapMenu:GetHeight()
            
            -- Determine horizontal position
            local anchorH = "LEFT"
            local relativeH = "LEFT"
            local xOffset = 0
            
            -- Check if menu fits to the right of button
            if buttonRight + menuWidth > screenWidth then
                -- Try left side instead
                if buttonLeft - menuWidth >= 0 then
                    anchorH = "RIGHT"
                    relativeH = "LEFT"
                    xOffset = -5
                else
                    -- Doesn't fit either side, align to right edge of button
                    anchorH = "RIGHT"
                    relativeH = "RIGHT"
                    xOffset = 0
                end
            else
                -- Fits on right side
                xOffset = 5
            end
            
            -- Determine vertical position
            local anchorV = "TOP"
            local relativeV = "BOTTOM"
            local yOffset = -5
            
            -- Check if menu fits below button
            if buttonBottom - menuHeight < 0 then
                -- Position above button instead
                anchorV = "BOTTOM"
                relativeV = "TOP"
                yOffset = 5
            end
            
            -- Combine anchor points
            local anchorPoint = anchorV .. anchorH
            local relativePoint = relativeV .. relativeH
            
            self.minimapMenu:SetPoint(anchorPoint, button, relativePoint, xOffset, yOffset)
        end
        self.minimapMenu:Show()
    end
end
