local GrindCompanion = _G.GrindCompanion

function GrindCompanion:InitializeOptions()
    -- Use Settings API (available in Classic Era)
    local panel = CreateFrame("Frame", nil, SettingsPanel)
    panel.name = "GrindCompanion"
    
    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("GrindCompanion Options")
    
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
    
    local yOffset = -50
    
    -- Section 1: Interface Settings
    local interfaceHeader = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    interfaceHeader:SetPoint("TOPLEFT", 16, yOffset)
    interfaceHeader:SetText("Interface")
    yOffset = yOffset - 30
    
    -- Hide Minimap Button
    local minimapCheckbox = CreateFrame("CheckButton", "GrindCompanionOption_hideMinimapButton", panel, "InterfaceOptionsCheckButtonTemplate")
    minimapCheckbox:SetPoint("TOPLEFT", 20, yOffset)
    minimapCheckbox.Text:SetText(rowLabels["hideMinimapButton"])
    minimapCheckbox:SetChecked(self.settings["hideMinimapButton"])
    
    minimapCheckbox:SetScript("OnClick", function(self)
        local isChecked = self:GetChecked()
        GrindCompanion.settings["hideMinimapButton"] = isChecked
        GrindCompanion:SaveSettings()
        
        if GrindCompanion.minimapButton then
            if isChecked then
                GrindCompanion.minimapButton:Hide()
            else
                GrindCompanion.minimapButton:Show()
            end
        end
    end)
    
    checkboxes["hideMinimapButton"] = minimapCheckbox
    yOffset = yOffset - 50
    
    -- Section 2: Display Rows
    local displayHeader = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    displayHeader:SetPoint("TOPLEFT", 16, yOffset)
    displayHeader:SetText("Summary Window Rows")
    yOffset = yOffset - 30
    
    local rowOrder = {
        "showCurrency",
        "showGray",
        "showItems",
        "showAH",
        "showTotal",
        "showETA",
        "showKills",
    }
    
    for _, key in ipairs(rowOrder) do
        local checkbox = CreateFrame("CheckButton", "GrindCompanionOption_" .. key, panel, "InterfaceOptionsCheckButtonTemplate")
        checkbox:SetPoint("TOPLEFT", 20, yOffset)
        checkbox.Text:SetText(rowLabels[key])
        checkbox:SetChecked(self.settings[key])
        
        checkbox:SetScript("OnClick", function(self)
            local isChecked = self:GetChecked()
            GrindCompanion.settings[key] = isChecked
            GrindCompanion:SaveSettings()
            GrindCompanion:ApplyRowVisibility()
        end)
        
        checkboxes[key] = checkbox
        yOffset = yOffset - 30
    end
    
    panel.checkboxes = checkboxes
    
    -- Add to Interface Options using Settings API
    panel.OnCommit = function() end
    panel.OnDefault = function() end
    panel.OnRefresh = function() end
    
    local category = Settings.RegisterCanvasLayoutCategory(panel, "GrindCompanion")
    category.ID = "GrindCompanion"
    Settings.RegisterAddOnCategory(category)
    
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




