local GrindCompanion = _G.GrindCompanion

-- ============================================================================
-- Curated Item Database for AH Tracking
-- Common farmable items organized by category
-- ============================================================================

GrindCompanion.FarmableItems = {
    -- Herbs (Classic Era)
    { id = 765, name = "Silverleaf" },
    { id = 785, name = "Mageroyal" },
    { id = 2447, name = "Peacebloom" },
    { id = 2449, name = "Earthroot" },
    { id = 2450, name = "Briarthorn" },
    { id = 2452, name = "Swiftthistle" },
    { id = 2453, name = "Bruiseweed" },
    { id = 3355, name = "Wild Steelbloom" },
    { id = 3356, name = "Kingsblood" },
    { id = 3357, name = "Liferoot" },
    { id = 3358, name = "Khadgar's Whisker" },
    { id = 3369, name = "Grave Moss" },
    { id = 3818, name = "Fadeleaf" },
    { id = 3819, name = "Dragon's Teeth" },
    { id = 3820, name = "Stranglekelp" },
    { id = 3821, name = "Goldthorn" },
    { id = 4625, name = "Firebloom" },
    { id = 8831, name = "Purple Lotus" },
    { id = 8836, name = "Arthas' Tears" },
    { id = 8838, name = "Sungrass" },
    { id = 8839, name = "Blindweed" },
    { id = 8845, name = "Ghost Mushroom" },
    { id = 8846, name = "Gromsblood" },
    { id = 13463, name = "Dreamfoil" },
    { id = 13464, name = "Golden Sansam" },
    { id = 13465, name = "Mountain Silversage" },
    { id = 13466, name = "Plaguebloom" },
    { id = 13467, name = "Icecap" },
    { id = 13468, name = "Black Lotus" },
    
    -- Ore & Bars
    { id = 2770, name = "Copper Ore" },
    { id = 2771, name = "Tin Ore" },
    { id = 2772, name = "Iron Ore" },
    { id = 2775, name = "Silver Ore" },
    { id = 2776, name = "Gold Ore" },
    { id = 3858, name = "Mithril Ore" },
    { id = 7911, name = "Truesilver Ore" },
    { id = 10620, name = "Thorium Ore" },
    { id = 12359, name = "Thorium Bar" },
    { id = 12360, name = "Arcanite Bar" },
    { id = 12361, name = "Blue Sapphire" },
    { id = 12364, name = "Huge Emerald" },
    { id = 12799, name = "Large Opal" },
    { id = 12800, name = "Azerothian Diamond" },
    { id = 2840, name = "Copper Bar" },
    { id = 2841, name = "Bronze Bar" },
    { id = 3575, name = "Iron Bar" },
    { id = 3576, name = "Tin Bar" },
    { id = 3577, name = "Gold Bar" },
    { id = 3859, name = "Steel Bar" },
    { id = 3860, name = "Mithril Bar" },
    { id = 6037, name = "Truesilver Bar" },
    
    -- Gems & Stones
    { id = 774, name = "Malachite" },
    { id = 818, name = "Tigerseye" },
    { id = 1206, name = "Moss Agate" },
    { id = 1210, name = "Shadowgem" },
    { id = 1529, name = "Jade" },
    { id = 1705, name = "Lesser Moonstone" },
    { id = 3864, name = "Citrine" },
    { id = 5498, name = "Small Lustrous Pearl" },
    { id = 7909, name = "Aquamarine" },
    { id = 7910, name = "Star Ruby" },
    { id = 12363, name = "Arcane Crystal" },
    
    -- Leather & Hides
    { id = 2318, name = "Light Leather" },
    { id = 2319, name = "Medium Leather" },
    { id = 4234, name = "Heavy Leather" },
    { id = 4304, name = "Thick Leather" },
    { id = 8170, name = "Rugged Leather" },
    { id = 2934, name = "Ruined Leather Scraps" },
    { id = 4231, name = "Cured Light Hide" },
    { id = 4232, name = "Medium Hide" },
    { id = 4235, name = "Heavy Hide" },
    { id = 8169, name = "Thick Hide" },
    { id = 8171, name = "Rugged Hide" },
    { id = 15407, name = "Cured Rugged Hide" },
    { id = 15408, name = "Heavy Scorpid Scale" },
    { id = 15410, name = "Scale of Onyxia" },
    { id = 15412, name = "Green Dragonscale" },
    { id = 15414, name = "Red Dragonscale" },
    { id = 15415, name = "Blue Dragonscale" },
    { id = 15416, name = "Black Dragonscale" },
    { id = 17012, name = "Core Leather" },
    
    -- Cloth
    { id = 2589, name = "Linen Cloth" },
    { id = 2592, name = "Wool Cloth" },
    { id = 4306, name = "Silk Cloth" },
    { id = 4338, name = "Mageweave Cloth" },
    { id = 14047, name = "Runecloth" },
    { id = 2996, name = "Bolt of Linen Cloth" },
    { id = 2997, name = "Bolt of Woolen Cloth" },
    { id = 4305, name = "Bolt of Silk Cloth" },
    { id = 4339, name = "Bolt of Mageweave" },
    { id = 14048, name = "Bolt of Runecloth" },
    
    -- Essences & Dusts (Enchanting)
    { id = 10938, name = "Lesser Magic Essence" },
    { id = 10939, name = "Greater Magic Essence" },
    { id = 10940, name = "Strange Dust" },
    { id = 10998, name = "Lesser Astral Essence" },
    { id = 11082, name = "Greater Astral Essence" },
    { id = 11083, name = "Soul Dust" },
    { id = 11084, name = "Large Glimmering Shard" },
    { id = 11134, name = "Lesser Mystic Essence" },
    { id = 11135, name = "Greater Mystic Essence" },
    { id = 11137, name = "Vision Dust" },
    { id = 11138, name = "Small Glowing Shard" },
    { id = 11139, name = "Large Glowing Shard" },
    { id = 11174, name = "Lesser Nether Essence" },
    { id = 11175, name = "Greater Nether Essence" },
    { id = 11176, name = "Dream Dust" },
    { id = 11177, name = "Small Radiant Shard" },
    { id = 11178, name = "Large Radiant Shard" },
    { id = 16202, name = "Lesser Eternal Essence" },
    { id = 16203, name = "Greater Eternal Essence" },
    { id = 16204, name = "Illusion Dust" },
    { id = 14343, name = "Small Brilliant Shard" },
    { id = 14344, name = "Large Brilliant Shard" },
    { id = 20725, name = "Nexus Crystal" },
    
    -- Elemental Materials
    { id = 7067, name = "Elemental Earth" },
    { id = 7068, name = "Elemental Fire" },
    { id = 7069, name = "Elemental Air" },
    { id = 7070, name = "Elemental Water" },
    { id = 7075, name = "Core of Earth" },
    { id = 7076, name = "Essence of Earth" },
    { id = 7077, name = "Heart of Fire" },
    { id = 7078, name = "Essence of Fire" },
    { id = 7079, name = "Globe of Water" },
    { id = 7080, name = "Essence of Water" },
    { id = 7081, name = "Breath of Wind" },
    { id = 7082, name = "Essence of Air" },
    { id = 12803, name = "Living Essence" },
    { id = 12808, name = "Essence of Undeath" },
    { id = 12809, name = "Guardian Stone" },
    
    -- Meat & Cooking
    { id = 2672, name = "Stringy Wolf Meat" },
    { id = 2673, name = "Coyote Meat" },
    { id = 2674, name = "Crawler Meat" },
    { id = 2675, name = "Crawler Claw" },
    { id = 2677, name = "Boar Ribs" },
    { id = 3667, name = "Tender Crocolisk Meat" },
    { id = 3712, name = "Turtle Meat" },
    { id = 3731, name = "Lion Meat" },
    { id = 5465, name = "Small Spider Leg" },
    { id = 5466, name = "Scorpid Stinger" },
    { id = 5467, name = "Kodo Meat" },
    { id = 12037, name = "Mystery Meat" },
    { id = 12184, name = "Raptor Flesh" },
    { id = 12202, name = "Tiger Meat" },
    { id = 12203, name = "Red Wolf Meat" },
    { id = 12204, name = "Heavy Kodo Meat" },
    { id = 12205, name = "White Spider Meat" },
    
    -- Fish
    { id = 6289, name = "Raw Longjaw Mud Snapper" },
    { id = 6291, name = "Raw Brilliant Smallfish" },
    { id = 6303, name = "Raw Slitherskin Mackerel" },
    { id = 6308, name = "Raw Bristle Whisker Catfish" },
    { id = 6317, name = "Raw Loch Frenzy" },
    { id = 6358, name = "Oily Blackmouth" },
    { id = 6359, name = "Firefin Snapper" },
    { id = 6361, name = "Raw Rainbow Fin Albacore" },
    { id = 6362, name = "Raw Rockscale Cod" },
    { id = 8365, name = "Raw Mithril Head Trout" },
    { id = 13754, name = "Raw Glossy Mightfish" },
    { id = 13755, name = "Winter Squid" },
    { id = 13756, name = "Raw Summer Bass" },
    { id = 13758, name = "Raw Redgill" },
    { id = 13759, name = "Raw Nightfin Snapper" },
    { id = 13760, name = "Raw Sunscale Salmon" },
    
    -- Potions & Alchemy
    { id = 765, name = "Silverleaf" },
    { id = 2453, name = "Bruiseweed" },
    { id = 3820, name = "Stranglekelp" },
    { id = 118, name = "Minor Healing Potion" },
    { id = 858, name = "Lesser Healing Potion" },
    { id = 929, name = "Healing Potion" },
    { id = 1710, name = "Greater Healing Potion" },
    { id = 3928, name = "Superior Healing Potion" },
    { id = 13446, name = "Major Healing Potion" },
    { id = 2459, name = "Swiftness Potion" },
    { id = 3387, name = "Limited Invulnerability Potion" },
    { id = 5631, name = "Rage Potion" },
    { id = 9172, name = "Invisibility Potion" },
    { id = 13442, name = "Mighty Rage Potion" },
    { id = 13444, name = "Major Mana Potion" },
    { id = 13445, name = "Elixir of Superior Defense" },
    { id = 13447, name = "Elixir of the Mongoose" },
    { id = 13452, name = "Elixir of the Mongoose" },
    { id = 13453, name = "Elixir of Brute Force" },
    { id = 13454, name = "Greater Arcane Elixir" },
    { id = 13455, name = "Greater Nature Protection Potion" },
    { id = 13457, name = "Greater Fire Protection Potion" },
    { id = 13458, name = "Greater Frost Protection Potion" },
    { id = 13459, name = "Greater Shadow Protection Potion" },
    { id = 13461, name = "Greater Arcane Protection Potion" },
    
    -- Misc Reagents
    { id = 3470, name = "Rough Grinding Stone" },
    { id = 3478, name = "Coarse Grinding Stone" },
    { id = 3486, name = "Heavy Grinding Stone" },
    { id = 3575, name = "Iron Bar" },
    { id = 6037, name = "Truesilver Bar" },
    { id = 7912, name = "Solid Stone" },
    { id = 12644, name = "Dense Grinding Stone" },
    { id = 12655, name = "Enchanted Thorium Bar" },
    { id = 14047, name = "Runecloth" },
    { id = 17010, name = "Fiery Core" },
    { id = 17011, name = "Lava Core" },
    { id = 17012, name = "Core Leather" },
}

-- ============================================================================
-- Item Caching System
-- ============================================================================

function GrindCompanion:InitializeItemCache()
    self.itemCache = self.itemCache or {
        items = {},
        loading = {},
        loaded = false,
    }
    
    -- Register for item data loaded event (only exists in retail)
    if not self.itemCacheEventRegistered then
        -- Check if event exists before registering (Classic Era doesn't have this event)
        local eventExists = pcall(function()
            local frame = CreateFrame("Frame")
            frame:RegisterEvent("ITEM_DATA_LOADED")
            frame:UnregisterEvent("ITEM_DATA_LOADED")
        end)
        
        if eventExists then
            self:RegisterEvent("ITEM_DATA_LOADED")
        end
        self.itemCacheEventRegistered = true
    end
end

function GrindCompanion:CacheFarmableItems()
    self:InitializeItemCache()
    
    if self.itemCache.loaded then
        return
    end
    
    local itemsToCache = {}
    for _, item in ipairs(self.FarmableItems) do
        table.insert(itemsToCache, item.id)
    end
    
    -- Cache items in batches to avoid lag
    local batchSize = 50
    local currentBatch = 1
    
    local function cacheBatch()
        local startIdx = (currentBatch - 1) * batchSize + 1
        local endIdx = math.min(currentBatch * batchSize, #itemsToCache)
        
        for i = startIdx, endIdx do
            local itemID = itemsToCache[i]
            if C_Item and C_Item.RequestLoadItemDataByID then
                C_Item.RequestLoadItemDataByID(itemID)
            end
            self.itemCache.loading[itemID] = true
        end
        
        currentBatch = currentBatch + 1
        
        if endIdx < #itemsToCache then
            C_Timer.After(0.5, cacheBatch)
        else
            self.itemCache.loaded = true
        end
    end
    
    cacheBatch()
end

function GrindCompanion:OnItemDataLoaded(itemID)
    if self.itemCache and self.itemCache.loading[itemID] then
        self.itemCache.loading[itemID] = nil
        
        -- Cache the item info
        local name, link, quality, _, _, _, _, _, _, texture = GetItemInfo(itemID)
        if name then
            self.itemCache.items[itemID] = {
                id = itemID,
                name = name,
                link = link,
                quality = quality,
                texture = texture,
                nameLower = string.lower(name),
            }
        end
    end
end

function GrindCompanion:SearchCachedItems(searchText)
    if not searchText or searchText == "" then
        return {}
    end
    
    searchText = string.lower(searchText)
    local results = {}
    
    -- Search cached items
    for _, item in pairs(self.itemCache.items) do
        if string.find(item.nameLower, searchText, 1, true) then
            table.insert(results, item)
        end
    end
    
    -- Sort by relevance (starts with search text first, then alphabetically)
    table.sort(results, function(a, b)
        local aStarts = string.sub(a.nameLower, 1, #searchText) == searchText
        local bStarts = string.sub(b.nameLower, 1, #searchText) == searchText
        
        if aStarts and not bStarts then
            return true
        elseif not aStarts and bStarts then
            return false
        else
            return a.name < b.name
        end
    end)
    
    return results
end
