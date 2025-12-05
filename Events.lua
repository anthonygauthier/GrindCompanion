local GrindCompanion = _G.GrindCompanion

function GrindCompanion:OnEvent(event, ...)
    if event == "ADDON_LOADED" then
        local name = ...
        if name ~= self:GetAddonName() then
            return
        end

        SlashCmdList["GRINDCALC"] = function(msg)
            self:HandleSlashCommand(msg)
        end
        SLASH_GRINDCALC1 = "/gc"

        self:EnsureSavedVariables()
        self:LoadSettings()
        self:InitializeOptions()
        self:InitializeAHTracking()
        self:InitializeItemCache()
        self:CacheFarmableItems()
        self:CreateAHOptionsPanel()
        self:InitializeMinimapButton()
        self:UpdatePricingProvider()
        if not self.hasAuctionatorPricing then
            self:PrintMessage("Auctionator not detected. AH values will stay at 0 until it's installed.")
        end
        self:InitializeDisplayFrame()
        self:PrintMessage("Loaded. Use /gc start to begin tracking.")
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
    elseif event == "PLAYER_LOGOUT" or event == "PLAYER_ENTERING_WORLD" then
        if self.isTracking and self.startTime then
            -- Auto-save session on logout/reload
            local snapshot, index = self:PersistSessionHistory()
            if snapshot and event == "PLAYER_LOGOUT" then
                self:PrintMessage("Session auto-saved on logout.")
            end
        end
    elseif event == "ZONE_CHANGED_NEW_AREA" or event == "ZONE_CHANGED" or event == "ZONE_CHANGED_INDOORS" then
        if self.isTracking then
            self:TrackCurrentZone()
        end
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        if self.isTracking then
            self:HandleCombatLogEvent()
        end
    elseif event == "ITEM_DATA_LOADED" then
        local itemID = ...
        self:OnItemDataLoaded(itemID)
    end
end

GrindCompanion:RegisterEvent("ADDON_LOADED")
GrindCompanion:RegisterEvent("CHAT_MSG_COMBAT_XP_GAIN")
GrindCompanion:RegisterEvent("CHAT_MSG_LOOT")
GrindCompanion:RegisterEvent("CHAT_MSG_MONEY")
GrindCompanion:RegisterEvent("PLAYER_LEVEL_UP")
GrindCompanion:RegisterEvent("LOOT_READY")
GrindCompanion:RegisterEvent("LOOT_OPENED")
GrindCompanion:RegisterEvent("LOOT_SLOT_CLEARED")
GrindCompanion:RegisterEvent("LOOT_CLOSED")
GrindCompanion:RegisterEvent("PLAYER_LOGOUT")
GrindCompanion:RegisterEvent("PLAYER_ENTERING_WORLD")
GrindCompanion:RegisterEvent("ZONE_CHANGED_NEW_AREA")
GrindCompanion:RegisterEvent("ZONE_CHANGED")
GrindCompanion:RegisterEvent("ZONE_CHANGED_INDOORS")
GrindCompanion:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
GrindCompanion:SetScript("OnEvent", function(self, event, ...)
    self:OnEvent(event, ...)
end)
