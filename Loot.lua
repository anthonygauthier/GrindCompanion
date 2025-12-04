local GrindCompanion = _G.GrindCompanion
local MobStats = _G.GC_MobStats

-- OPTIMIZED: Reduce table lookups and linear searches
function GrindCompanion:RecordQualityLoot(quality, quantity, itemLink)
    if not quality or not self.QUALITY_LABELS[quality] then
        return
    end

    local amount = math.max(1, tonumber(quantity) or 1)
    
    -- Cache table references
    local lootCount = self.lootQualityCount
    lootCount[quality] = (lootCount[quality] or 0) + amount
    
    local levelCount = self.levelLootQualityCount
    if levelCount then
        levelCount[quality] = (levelCount[quality] or 0) + amount
    end
    
    -- Track individual items for detail view (quality 2+)
    if not itemLink or quality < 2 then
        return
    end
    
    local lootedItems = self.lootedItems
    if not lootedItems then
        lootedItems = {}
        self.lootedItems = lootedItems
    end
    
    -- Use hash map for O(1) lookup instead of O(n) linear search
    local itemMap = self._lootedItemsMap
    if not itemMap then
        itemMap = {}
        self._lootedItemsMap = itemMap
    end
    
    local existingItem = itemMap[itemLink]
    if existingItem then
        existingItem.quantity = existingItem.quantity + amount
    else
        local newItem = {
            link = itemLink,
            quality = quality,
            quantity = amount,
        }
        lootedItems[#lootedItems + 1] = newItem
        itemMap[itemLink] = newItem
    end
end

-- OPTIMIZED: Reduce API calls and table allocations
function GrindCompanion:CacheLootSlots()
    if not self.isTracking then
        return
    end

    local cache = self.lootSlotCache
    if not cache then
        cache = {}
        self.lootSlotCache = cache
    else
        wipe(cache)
    end

    local numLootItems = GetNumLootItems() or 0
    for slot = 1, numLootItems do
        if LootSlotHasItem(slot) then
            local slotType = GetLootSlotType and GetLootSlotType(slot)
            if not slotType or slotType == LOOT_SLOT_ITEM then
                local _, _, quantity, quality = GetLootSlotInfo(slot)
                local link = GetLootSlotLink(slot)
                
                -- Only call GetItemInfoInstant if needed
                if link and (not quality or not self.QUALITY_LABELS[quality]) then
                    quality = select(3, GetItemInfoInstant(link)) or quality
                end
                
                cache[slot] = {
                    quality = quality,
                    quantity = quantity or 1,
                    link = link,
                }
            end
        end
    end
end

function GrindCompanion:HandleLootSlotCleared(slot)
    if not self.isTracking or not self.lootSlotCache then
        return
    end

    local slotData = self.lootSlotCache[slot]
    if not slotData then
        return
    end

    self.lootSlotCache[slot] = nil
end

-- OPTIMIZED: Reduce string operations and API calls
function GrindCompanion:HandleLootMessage(message)
    if not message then
        return
    end

    -- Faster pattern check (single find with pattern)
    local isPlayerLoot = message:find("^You") or message:find("^Your share")
    if not isPlayerLoot then
        return
    end

    local copper = self:ParseCoinFromMessage(message)
    if copper > 0 then
        self.currencyCopper = (self.currencyCopper or 0) + copper
        self.levelCurrencyCopper = (self.levelCurrencyCopper or 0) + copper
        
        -- Cache mob stats lookup
        local currentMob = self.currentMobForLoot
        if currentMob then
            local mobStats = self.mobStats
            if mobStats and mobStats[currentMob] then
                mobStats[currentMob].currency = mobStats[currentMob].currency + copper
            end
        end
    end

    local itemLink = message:match("(|c%x+|Hitem:.-|h.-|h|r)")
    if not itemLink then
        return
    end
    
    local quantity = tonumber(message:match("x(%d+)")) or 1
    
    -- Get quality with single API call when possible
    local quality = select(3, GetItemInfoInstant(itemLink))
    if not quality then
        quality = select(3, GetItemInfo(itemLink))
    end
    quality = tonumber(quality)
    
    -- If quality is still unknown, queue for later processing
    if not quality then
        if not self.pendingLootItems then
            self.pendingLootItems = {}
        end
        table.insert(self.pendingLootItems, {link = itemLink, quantity = quantity, message = message})
        return
    end

    local itemValue = 0
    
    if quality == 0 then
        -- Try to get sell price immediately
        local sellPrice = select(11, GetItemInfo(itemLink))
        if sellPrice and sellPrice > 0 then
            itemValue = sellPrice * quantity
            self.grayCopper = (self.grayCopper or 0) + itemValue
            self.levelGrayCopper = (self.levelGrayCopper or 0) + itemValue
        else
            -- Item info not cached yet, queue for later processing
            if not self.pendingGrayItems then
                self.pendingGrayItems = {}
            end
            table.insert(self.pendingGrayItems, {link = itemLink, quantity = quantity})
        end
    end
    
    self:AddAuctionValue(itemLink, quantity, quality)
    self:RecordQualityLoot(quality, quantity, itemLink)
    
    -- Track loot for current mob (cached lookup)
    local currentMob = self.currentMobForLoot
    if currentMob then
        local mobStats = self.mobStats
        if mobStats and mobStats[currentMob] then
            local mobData = mobStats[currentMob]
            
            if quality >= 2 and quality <= 4 then
                mobData.loot[quality] = (mobData.loot[quality] or 0) + quantity
                
                -- Use MobStats module to update highest quality drop
                MobStats:UpdateHighestQualityDrop(mobData, quality, itemLink, quantity)
            end
            
            if itemValue > 0 then
                mobData.currency = mobData.currency + itemValue
            end
        end
    end
end
