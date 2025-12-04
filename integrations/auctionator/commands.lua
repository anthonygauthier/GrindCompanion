local GrindCompanion = _G.GrindCompanion

-- ============================================================================
-- Auctionator Integration - Command Handlers
-- ============================================================================

function GrindCompanion:HandleAuctionatorTestCommand()
    self:UpdatePricingProvider()
    if self.hasAuctionatorPricing then
        self:PrintMessage("Auctionator detected and available!")
        
        -- List available API methods
        if Auctionator and Auctionator.API and Auctionator.API.v1 then
            local api = Auctionator.API.v1
            self:PrintMessage("Available Auctionator API methods:")
            for key, value in pairs(api) do
                if type(value) == "function" then
                    self:PrintMessage(string.format("  - %s", key))
                end
            end
        end
    else
        self:PrintMessage("Auctionator NOT detected. Make sure it's installed and loaded.")
    end
end

function GrindCompanion:ShowAHItemsStatus()
    local count = self:GetTrackedAHItemCount()
    if count == 0 then
        self:PrintMessage("No items tracked for AH. Use /gc select-ah start or open options to add items.")
        return
    end
    
    self:PrintMessage(string.format("Tracking %d item%s for AH value:", count, count == 1 and "" or "s"))
    
    local items = {}
    if self.ahTracking and self.ahTracking.trackedItems then
        for _, item in pairs(self.ahTracking.trackedItems) do
            table.insert(items, item)
        end
    end
    
    table.sort(items, function(a, b)
        return (a.name or "") < (b.name or "")
    end)
    
    for _, item in ipairs(items) do
        self:PrintMessage(string.format("  %s", item.link or item.name))
    end
end
