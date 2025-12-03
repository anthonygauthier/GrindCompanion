local GrindCalculator = _G.GrindCalculator

function GrindCalculator:OnEvent(event, ...)
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
GrindCalculator:RegisterEvent("PLAYER_LOGOUT")
GrindCalculator:RegisterEvent("PLAYER_ENTERING_WORLD")
GrindCalculator:RegisterEvent("ZONE_CHANGED_NEW_AREA")
GrindCalculator:RegisterEvent("ZONE_CHANGED")
GrindCalculator:RegisterEvent("ZONE_CHANGED_INDOORS")
GrindCalculator:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
GrindCalculator:SetScript("OnEvent", function(self, event, ...)
    self:OnEvent(event, ...)
end)
