local GrindCompanion = _G.GrindCompanion

local function isAuctionatorAvailable()
    return Auctionator and Auctionator.API and Auctionator.API.v1
end

function GrindCompanion:UpdatePricingProvider()
    self.hasAuctionatorPricing = isAuctionatorAvailable() and true or false
end

function GrindCompanion:GetAuctionPriceForItem(link)
    if not link then
        return nil
    end

    if self.hasAuctionatorPricing == nil then
        self:UpdatePricingProvider()
    end
    if not self.hasAuctionatorPricing then
        if self.debugPricing then
            self:PrintMessage("Auctionator not available")
        end
        return nil
    end

    local itemID = select(1, GetItemInfoInstant(link))
    if not itemID then
        if self.debugPricing then
            self:PrintMessage("Could not get item ID from link")
        end
        return nil
    end
    
    if self.debugPricing then
        self:PrintMessage(string.format("Checking price for: %s (ID: %s)", link, tostring(itemID)))
    end

    local callerID = "GrindCompanion"
    local api = Auctionator.API.v1
    local itemPrice = nil

    -- Method 1: GetAuctionPriceByItemLink (correct signature with callerID)
    if api.GetAuctionPriceByItemLink then
        local ok, value = pcall(api.GetAuctionPriceByItemLink, callerID, link)
        if self.debugPricing then
            self:PrintMessage(string.format("GetAuctionPriceByItemLink: ok=%s, value=%s", tostring(ok), tostring(value)))
        end
        if ok and value and tonumber(value) and tonumber(value) > 0 then
            itemPrice = tonumber(value)
        end
    end

    -- Method 2: GetAuctionPriceByItemID (correct signature with callerID)
    if not itemPrice and api.GetAuctionPriceByItemID then
        local ok, value = pcall(api.GetAuctionPriceByItemID, callerID, itemID)
        if self.debugPricing then
            self:PrintMessage(string.format("GetAuctionPriceByItemID: ok=%s, value=%s", tostring(ok), tostring(value)))
        end
        if ok and value and tonumber(value) and tonumber(value) > 0 then
            itemPrice = tonumber(value)
        end
    end
    
    -- Method 3: Direct database access as fallback
    if not itemPrice and Auctionator and Auctionator.Database then
        local ok, value = pcall(function()
            return Auctionator.Database:GetPrice(tostring(itemID))
        end)
        if self.debugPricing then
            self:PrintMessage(string.format("Direct Database:GetPrice: ok=%s, value=%s", tostring(ok), tostring(value)))
        end
        if ok and value and tonumber(value) and tonumber(value) > 0 then
            itemPrice = tonumber(value)
        end
    end
    
    if self.debugPricing then
        if itemPrice then
            self:PrintMessage(string.format("SUCCESS: Price for %s = %s", tostring(itemID), self:FormatCoin(itemPrice)))
        else
            self:PrintMessage(string.format("FAILED: No price found for %s", tostring(itemID)))
        end
    end

    return itemPrice
end

function GrindCompanion:ShouldTrackAHValue(quality, subType, classID, subClassID)
    local numericQuality = tonumber(quality)
    
    -- Always track quality 2+ (green, blue, epic)
    if numericQuality and numericQuality >= 2 then
        return true
    end

    -- For lower quality items, check if it's cloth or trade goods
    local numClass = tonumber(classID)
    local numSubClass = tonumber(subClassID)
    if numClass and numSubClass then
        -- Armor (cloth) = class 4, subclass 1
        -- Trade Goods (cloth) = class 7, subclass 5
        if (numClass == 4 and numSubClass == 1) or (numClass == 7 and numSubClass == 5) then
            return true
        end
    end

    -- Fallback: check subType string
    if subType and type(subType) == "string" and subType:lower() == "cloth" then
        return true
    end

    return false
end

function GrindCompanion:AddAuctionValue(link, quantity, quality)
    if not link then
        return
    end

    local name, _, infoQuality, _, _, _, subType, _, _, _, _, classID, subClassID = GetItemInfo(link)
    if not classID or not subClassID then
        classID, subClassID = select(12, GetItemInfoInstant(link))
    end
    local effectiveQuality = tonumber(quality) or infoQuality
    
    if not self:ShouldTrackAHValue(effectiveQuality, subType, classID, subClassID) then
        return
    end

    local pricePer = self:GetAuctionPriceForItem(link)
    if not pricePer or pricePer <= 0 then
        -- Debug: print when no price found
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
    
    -- Debug: print when price is added
    if self.debugPricing then
        self:PrintMessage(string.format("Added AH value: %s x%d = %s", 
            name or "unknown", quantity, self:FormatCoin(total)))
    end
end
