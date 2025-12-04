local GrindCompanion = _G.GrindCompanion

-- ============================================================================
-- Auctionator Integration - Item Tracking System
-- ============================================================================

function GrindCompanion:InitializeAHTracking()
    self.ahTracking = self.ahTracking or {
        enabled = false,
        selectMode = false,
        trackedItems = {},
    }
    
    -- Load tracked items from saved variables
    self:LoadAHTrackedItems()
end

function GrindCompanion:LoadAHTrackedItems()
    self:EnsureSavedVariables()
    GrindCompanionDB.ahTrackedItems = GrindCompanionDB.ahTrackedItems or {}
    
    -- Convert saved items to runtime format
    self.ahTracking.trackedItems = {}
    for _, item in ipairs(GrindCompanionDB.ahTrackedItems) do
        self.ahTracking.trackedItems[item.itemID] = {
            itemID = item.itemID,
            link = item.link,
            name = item.name,
            addedAt = item.addedAt,
        }
    end
end

function GrindCompanion:SaveAHTrackedItems()
    self:EnsureSavedVariables()
    
    -- Convert runtime format to saved format
    local items = {}
    for _, item in pairs(self.ahTracking.trackedItems) do
        table.insert(items, {
            itemID = item.itemID,
            link = item.link,
            name = item.name,
            addedAt = item.addedAt,
        })
    end
    
    GrindCompanionDB.ahTrackedItems = items
end

function GrindCompanion:IsItemTrackedForAH(itemID)
    if not self.ahTracking or not self.ahTracking.trackedItems then
        return false
    end
    return self.ahTracking.trackedItems[itemID] ~= nil
end

function GrindCompanion:AddTrackedAHItem(link)
    local success, result = pcall(function()
        if not link then
            return false, "Invalid item link"
        end
        
        local itemID = select(1, GetItemInfoInstant(link))
        if not itemID then
            return false, "Could not get item ID"
        end
        
        -- Check if already tracked
        if self:IsItemTrackedForAH(itemID) then
            return false, "Item already tracked"
        end
        
        local name = GetItemInfo(link)
        if not name then
            -- Item not cached yet, queue for later
            C_Timer.After(0.5, function()
                self:AddTrackedAHItem(link)
            end)
            return false, "Item info loading..."
        end
        
        -- Add to tracked items
        self.ahTracking.trackedItems[itemID] = {
            itemID = itemID,
            link = link,
            name = name,
            addedAt = time(),
        }
        
        self:SaveAHTrackedItems()
        return true, name
    end)
    
    if not success then
        self:PrintMessage(string.format("Error adding AH item: %s", tostring(result)))
        return false, "An error occurred"
    end
    
    return result
end

function GrindCompanion:RemoveTrackedAHItem(itemID)
    local success, result = pcall(function()
        if not self.ahTracking.trackedItems[itemID] then
            return false, "Item not tracked"
        end
        
        local name = self.ahTracking.trackedItems[itemID].name
        self.ahTracking.trackedItems[itemID] = nil
        self:SaveAHTrackedItems()
        
        return true, name
    end)
    
    if not success then
        self:PrintMessage(string.format("Error removing AH item: %s", tostring(result)))
        return false, "An error occurred"
    end
    
    return result
end

function GrindCompanion:ClearAllTrackedAHItems()
    self.ahTracking.trackedItems = {}
    self:SaveAHTrackedItems()
end

function GrindCompanion:GetTrackedAHItemCount()
    local count = 0
    for _ in pairs(self.ahTracking.trackedItems) do
        count = count + 1
    end
    return count
end

-- ============================================================================
-- Select Mode (Shift+Click to add items)
-- ============================================================================

function GrindCompanion:StartAHSelectMode()
    local success, err = pcall(function()
        if self.ahTracking.selectMode then
            self:PrintMessage("AH select mode is already active.")
            return
        end
        
        self.ahTracking.selectMode = true
        self:PrintMessage("AH select mode |cff00ff00ACTIVE|r. Shift+click items in your inventory to track them. Use /gc select-ah stop to exit.")
        
        -- Hook into item click
        self:HookAHSelectMode()
    end)
    
    if not success then
        self:PrintMessage(string.format("Error starting AH select mode: %s", tostring(err)))
    end
end

function GrindCompanion:StopAHSelectMode()
    if not self.ahTracking.selectMode then
        self:PrintMessage("AH select mode is not active.")
        return
    end
    
    self.ahTracking.selectMode = false
    self:PrintMessage("AH select mode |cffff0000STOPPED|r.")
end

function GrindCompanion:HookAHSelectMode()
    -- Hook the modified item click handler
    if not self.ahSelectModeHooked then
        hooksecurefunc("HandleModifiedItemClick", function(link)
            if GrindCompanion.ahTracking.selectMode and IsShiftKeyDown() then
                local success, result = GrindCompanion:AddTrackedAHItem(link)
                if success then
                    GrindCompanion:PrintMessage(string.format("Added to AH tracking: %s", link))
                else
                    if result ~= "Item info loading..." and result ~= "Item already tracked" then
                        GrindCompanion:PrintMessage(string.format("Failed to add item: %s", result))
                    end
                end
            end
        end)
        self.ahSelectModeHooked = true
    end
end

-- ============================================================================
-- Enhanced AH Value Calculation
-- ============================================================================

function GrindCompanion:ShouldTrackAHValueEnhanced(link, quality, subType, classID, subClassID)
    -- Initialize if not already done
    if not self.ahTracking then
        self:InitializeAHTracking()
    end
    
    -- First check if item is in tracked list
    local itemID = select(1, GetItemInfoInstant(link))
    if itemID and self:IsItemTrackedForAH(itemID) then
        return true
    end
    
    -- Fall back to original logic
    return self:ShouldTrackAHValue(quality, subType, classID, subClassID)
end

-- Override the original AddAuctionValue to use enhanced tracking
local originalAddAuctionValue = GrindCompanion.AddAuctionValue
function GrindCompanion:AddAuctionValue(link, quantity, quality)
    if not link then
        return
    end

    local name, _, infoQuality, _, _, _, subType, _, _, _, _, classID, subClassID = GetItemInfo(link)
    if not classID or not subClassID then
        classID, subClassID = select(12, GetItemInfoInstant(link))
    end
    local effectiveQuality = tonumber(quality) or infoQuality
    
    -- Use enhanced tracking check
    if not self:ShouldTrackAHValueEnhanced(link, effectiveQuality, subType, classID, subClassID) then
        return
    end

    local pricePer = self:GetAuctionPriceForItem(link)
    if not pricePer or pricePer <= 0 then
        if self.debugPricing then
            self:PrintMessage(string.format("No AH price for %s (quality: %s, class: %s, subclass: %s)", 
                name or "unknown", tostring(effectiveQuality), tostring(classID), tostring(subClassID)))
        end
        return
    end

    quantity = math.max(1, tonumber(quantity) or 1)
    local total = pricePer * quantity
    self.potentialAHCopper = (self.potentialAHCopper or 0) + total
    self.levelPotentialAHCopper = (self.levelPotentialAHCopper or 0) + total
    
    if self.debugPricing then
        self:PrintMessage(string.format("Added AH value: %s x%d = %s", 
            name or "unknown", quantity, self:FormatCoin(total)))
    end
end
