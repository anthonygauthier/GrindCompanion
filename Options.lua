local GrindCompanion = _G.GrindCompanion

function GrindCompanion:InitializeOptions()
    local panel = CreateFrame("Frame", "GrindCompanionOptionsPanel", UIParent)
    panel.name = "GrindCompanion"
    
    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("GrindCompanion Options")
    
    local subtitle = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    subtitle:SetText("Configure which rows to display in the summary window")
    
    -- Default settings
    self.settings = self.settings or {
        showCurrency = true,
        showGray = true,
        showItems = true,
        showAH = true,
        showTotal = true,
        showETA = true,
        showKills = true,
        hideMinimapButton = false,
    }
    
    local checkboxes = {}
    local rowLabels = {
        showCurrency = "Currency Earned",
        showGray = "Gray Vendor Value",
        showItems = "Notable Items",
        showAH = "AH Value (Auctionator required)",
        showTotal = "Total",
        showETA = "Estimated Time (non-max level)",
        showKills = "Kills Remaining (non-max level)",
        hideMinimapButton = "Hide Minimap Button",
    }
    
    local rowOrder = {
        "showCurrency",
        "showGray",
        "showItems",
        "showAH",
        "showTotal",
        "showETA",
        "showKills",
        "hideMinimapButton",
    }
    
    local yOffset = -80
    for _, key in ipairs(rowOrder) do
        local checkbox = CreateFrame("CheckButton", "GrindCompanionOption_" .. key, panel, "InterfaceOptionsCheckButtonTemplate")
        checkbox:SetPoint("TOPLEFT", 20, yOffset)
        checkbox.Text:SetText(rowLabels[key])
        checkbox:SetChecked(self.settings[key])
        
        checkbox:SetScript("OnClick", function(self)
            local isChecked = self:GetChecked()
            GrindCompanion.settings[key] = isChecked
            GrindCompanion:SaveSettings()
            
            -- Special handling for minimap button
            if key == "hideMinimapButton" then
                if GrindCompanion.minimapButton then
                    if isChecked then
                        GrindCompanion.minimapButton:Hide()
                    else
                        GrindCompanion.minimapButton:Show()
                    end
                end
            else
                GrindCompanion:ApplyRowVisibility()
            end
        end)
        
        checkboxes[key] = checkbox
        yOffset = yOffset - 30
    end
    
    panel.checkboxes = checkboxes
    
    -- Add to Interface Options
    if InterfaceOptions_AddCategory then
        InterfaceOptions_AddCategory(panel)
    elseif Settings and Settings.RegisterCanvasLayoutCategory then
        local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
        Settings.RegisterAddOnCategory(category)
    end
    
    self.optionsPanel = panel
end

function GrindCompanion:LoadSettings()
    self:EnsureSavedVariables()
    if GrindCompanionDB.settings then
        self.settings = GrindCompanionDB.settings
    else
        self.settings = {
            showCurrency = true,
            showGray = true,
            showItems = true,
            showAH = true,
            showTotal = true,
            showETA = true,
            showKills = true,
            hideMinimapButton = false,
        }
    end
end

function GrindCompanion:SaveSettings()
    self:EnsureSavedVariables()
    GrindCompanionDB.settings = self.settings
end

function GrindCompanion:ShouldShowRow(key)
    -- Map row keys to setting keys
    local keyMap = {
        currency = "showCurrency",
        gray = "showGray",
        items = "showItems",
        ah = "showAH",
        total = "showTotal",
        eta = "showETA",
        kills = "showKills",
    }
    
    local settingKey = keyMap[key]
    if settingKey and self.settings and self.settings[settingKey] ~= nil then
        return self.settings[settingKey]
    end
    return true
end
