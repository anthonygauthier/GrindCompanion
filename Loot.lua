local GrindCalculator = _G.GrindCalculator

function GrindCalculator:RecordQualityLoot(quality, quantity, itemLink)
    if not quality or not self.QUALITY_LABELS[quality] then
        return
    end

    local amount = math.max(1, tonumber(quantity) or 1)
    self.lootQualityCount[quality] = (self.lootQualityCount[quality] or 0) + amount
    if self.levelLootQualityCount then
        self.levelLootQualityCount[quality] = (self.levelLootQualityCount[quality] or 0) + amount
    end
    
    -- Track individual items for detail view
    if itemLink and quality >= 2 then
        if not self.lootedItems then
            self.lootedItems = {}
        end
        
        -- Find existing entry or create new one
        local found = false
        for _, item in ipairs(self.lootedItems) do
            if item.link == itemLink then
                item.quantity = item.quantity + amount
                found = true
                break
            end
        end
        
        if not found then
            table.insert(self.lootedItems, {
                link = itemLink,
                quality = quality,
                quantity = amount,
            })
        end
    end
end

function GrindCalculator:CacheLootSlots()
    if not self.isTracking then
        return
    end

    if not self.lootSlotCache then
        self.lootSlotCache = {}
    else
        wipe(self.lootSlotCache)
    end

    local numLootItems = GetNumLootItems() or 0
    for slot = 1, numLootItems do
        local slotType = GetLootSlotType and GetLootSlotType(slot)
        if LootSlotHasItem(slot) and (not slotType or slotType == LOOT_SLOT_ITEM) then
            local _, _, quantity, quality = GetLootSlotInfo(slot)
            local link = GetLootSlotLink(slot)
            if (not quality or not self.QUALITY_LABELS[quality]) and link then
                local _, _, linkQuality = GetItemInfoInstant(link)
                quality = linkQuality or quality
            end
            self.lootSlotCache[slot] = {
                quality = quality,
                quantity = quantity or 1,
                link = link,
            }
        end
    end
end

function GrindCalculator:HandleLootSlotCleared(slot)
    if not self.isTracking or not self.lootSlotCache then
        return
    end

    local slotData = self.lootSlotCache[slot]
    if not slotData then
        return
    end

    self.lootSlotCache[slot] = nil
end

function GrindCalculator:HandleLootMessage(message)
    if not message then
        return
    end

    local isPlayerLoot = message:find("^You") or message:find("^Your share of the loot is")
    if not isPlayerLoot then
        return
    end

    local copper = self:ParseCoinFromMessage(message)
    if copper > 0 then
        self.currencyCopper = (self.currencyCopper or 0) + copper
        self.levelCurrencyCopper = (self.levelCurrencyCopper or 0) + copper
        
        -- Track currency for current mob
        if self.currentMobForLoot and self.mobStats and self.mobStats[self.currentMobForLoot] then
            self.mobStats[self.currentMobForLoot].currency = self.mobStats[self.currentMobForLoot].currency + copper
        end
    end

    local itemLink = message:match("(|c%x+|Hitem:.-|h.-|h|r)")
    if itemLink then
        local _, _, quality = GetItemInfo(itemLink)
        if not quality then
            quality = select(3, GetItemInfoInstant(itemLink))
        end
        quality = tonumber(quality)
        if not quality then
            return
        end

        local quantity = tonumber(message:match("x(%d+)")) or 1
        local itemValue = 0
        
        if quality == 0 then
            self:AddGrayVendorValue(itemLink, quantity)
            -- Get gray item value for mob tracking
            local sellPrice = select(11, GetItemInfo(itemLink))
            if sellPrice and sellPrice > 0 then
                itemValue = sellPrice * quantity
            end
        end
        
        self:AddAuctionValue(itemLink, quantity, quality)
        self:RecordQualityLoot(quality, quantity, itemLink)
        
        -- Track loot for current mob
        if self.currentMobForLoot and self.mobStats and self.mobStats[self.currentMobForLoot] then
            if quality >= 2 and quality <= 4 then
                self.mobStats[self.currentMobForLoot].loot[quality] = 
                    (self.mobStats[self.currentMobForLoot].loot[quality] or 0) + quantity
            end
            -- Add gray item value to mob currency
            if itemValue > 0 then
                self.mobStats[self.currentMobForLoot].currency = 
                    self.mobStats[self.currentMobForLoot].currency + itemValue
            end
        end
    end
end
