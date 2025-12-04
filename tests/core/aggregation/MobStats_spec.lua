-- Tests for MobStats module
describe("MobStats", function()
    local MobStats
    local lqc
    local property
    local check
    
    setup(function()
        -- Add project root to package path
        package.path = package.path .. ";./?.lua;./?/init.lua"
        MobStats = require("core.aggregation.MobStats")
        lqc = require("lqc")
        property = lqc.property
        check = lqc.check
    end)
    
    -- Generators
    local function gen_mob_name()
        return lqc.oneof({
            lqc.string(),
            lqc.elements({"Boar", "Wolf", "Spider", "Bandit", "Kobold", "Murloc"})
        })
    end
    
    local function gen_positive_number()
        return lqc.int(1, 10000)
    end
    
    local function gen_optional_positive_number()
        return lqc.oneof({
            lqc.int(1, 10000),
            lqc.elements({nil})
        })
    end
    
    describe("RecordKill", function()
        -- **Feature: testable-architecture, Property 9: Recording mob kills updates stats correctly**
        it("increments kill count and adds XP/currency for any valid mob kill", function()
            local prop = property(
                gen_mob_name(),
                gen_optional_positive_number(),
                gen_optional_positive_number(),
                function(mobName, xpAmount, currencyAmount)
                    -- Skip empty mob names
                    if not mobName or mobName == "" then
                        return true
                    end
                    
                    local mobStats = {}
                    
                    -- Record the kill
                    MobStats:RecordKill(mobName, xpAmount, currencyAmount, mobStats)
                    
                    -- Verify mob entry was created
                    if not mobStats[mobName] then
                        return false, "Mob entry not created"
                    end
                    
                    -- Verify kill count incremented
                    if mobStats[mobName].kills ~= 1 then
                        return false, string.format("Expected kills=1, got %d", mobStats[mobName].kills)
                    end
                    
                    -- Verify XP was added if provided
                    if xpAmount then
                        if mobStats[mobName].xp ~= xpAmount then
                            return false, string.format("Expected xp=%d, got %d", xpAmount, mobStats[mobName].xp)
                        end
                    else
                        if mobStats[mobName].xp ~= 0 then
                            return false, string.format("Expected xp=0 when nil, got %d", mobStats[mobName].xp)
                        end
                    end
                    
                    -- Verify currency was added if provided
                    if currencyAmount then
                        if mobStats[mobName].currency ~= currencyAmount then
                            return false, string.format("Expected currency=%d, got %d", currencyAmount, mobStats[mobName].currency)
                        end
                    else
                        if mobStats[mobName].currency ~= 0 then
                            return false, string.format("Expected currency=0 when nil, got %d", mobStats[mobName].currency)
                        end
                    end
                    
                    return true
                end
            )
            check(prop, { numtests = 100 })
        end)
        
        it("accumulates stats for multiple kills of the same mob", function()
            local prop = property(
                gen_mob_name(),
                lqc.int(1, 10),  -- number of kills
                gen_positive_number(),  -- xp per kill
                gen_positive_number(),  -- currency per kill
                function(mobName, numKills, xpPerKill, currencyPerKill)
                    -- Skip empty mob names
                    if not mobName or mobName == "" then
                        return true
                    end
                    
                    local mobStats = {}
                    
                    -- Record multiple kills
                    for i = 1, numKills do
                        MobStats:RecordKill(mobName, xpPerKill, currencyPerKill, mobStats)
                    end
                    
                    -- Verify accumulated stats
                    if mobStats[mobName].kills ~= numKills then
                        return false, string.format("Expected kills=%d, got %d", numKills, mobStats[mobName].kills)
                    end
                    
                    local expectedXP = xpPerKill * numKills
                    if mobStats[mobName].xp ~= expectedXP then
                        return false, string.format("Expected xp=%d, got %d", expectedXP, mobStats[mobName].xp)
                    end
                    
                    local expectedCurrency = currencyPerKill * numKills
                    if mobStats[mobName].currency ~= expectedCurrency then
                        return false, string.format("Expected currency=%d, got %d", expectedCurrency, mobStats[mobName].currency)
                    end
                    
                    return true
                end
            )
            check(prop, { numtests = 100 })
        end)
    end)
end)

    describe("CalculateTotals", function()
        -- **Feature: testable-architecture, Property 10: Mob aggregation sums correctly**
        it("returns correct sums for any collection of mob stats", function()
            local prop = property(
                lqc.int(1, 10),  -- number of different mobs
                function(numMobs)
                    local mobStats = {}
                    local expectedKills = 0
                    local expectedXP = 0
                    local expectedCurrency = 0
                    local expectedItems = {
                        [2] = 0,
                        [3] = 0,
                        [4] = 0,
                    }
                    
                    -- Generate random mob stats
                    for i = 1, numMobs do
                        local mobName = "Mob" .. i
                        local kills = math.random(1, 100)
                        local xp = math.random(0, 1000)
                        local currency = math.random(0, 5000)
                        local loot = {
                            [2] = math.random(0, 10),
                            [3] = math.random(0, 5),
                            [4] = math.random(0, 2),
                        }
                        
                        mobStats[mobName] = {
                            kills = kills,
                            xp = xp,
                            currency = currency,
                            loot = loot,
                        }
                        
                        expectedKills = expectedKills + kills
                        expectedXP = expectedXP + xp
                        expectedCurrency = expectedCurrency + currency
                        expectedItems[2] = expectedItems[2] + loot[2]
                        expectedItems[3] = expectedItems[3] + loot[3]
                        expectedItems[4] = expectedItems[4] + loot[4]
                    end
                    
                    -- Calculate totals
                    local totals = MobStats:CalculateTotals(mobStats)
                    
                    -- Verify all sums are correct
                    if totals.totalKills ~= expectedKills then
                        return false, string.format("Expected totalKills=%d, got %d", expectedKills, totals.totalKills)
                    end
                    
                    if totals.totalXP ~= expectedXP then
                        return false, string.format("Expected totalXP=%d, got %d", expectedXP, totals.totalXP)
                    end
                    
                    if totals.totalCurrency ~= expectedCurrency then
                        return false, string.format("Expected totalCurrency=%d, got %d", expectedCurrency, totals.totalCurrency)
                    end
                    
                    if totals.totalItems[2] ~= expectedItems[2] then
                        return false, string.format("Expected totalItems[2]=%d, got %d", expectedItems[2], totals.totalItems[2])
                    end
                    
                    if totals.totalItems[3] ~= expectedItems[3] then
                        return false, string.format("Expected totalItems[3]=%d, got %d", expectedItems[3], totals.totalItems[3])
                    end
                    
                    if totals.totalItems[4] ~= expectedItems[4] then
                        return false, string.format("Expected totalItems[4]=%d, got %d", expectedItems[4], totals.totalItems[4])
                    end
                    
                    return true
                end
            )
            check(prop, { numtests = 100 })
        end)
        
        it("handles empty mob stats collection", function()
            local totals = MobStats:CalculateTotals({})
            assert.equals(0, totals.totalKills)
            assert.equals(0, totals.totalXP)
            assert.equals(0, totals.totalCurrency)
            assert.equals(0, totals.totalItems[2])
            assert.equals(0, totals.totalItems[3])
            assert.equals(0, totals.totalItems[4])
        end)
        
        it("handles nil mob stats", function()
            local totals = MobStats:CalculateTotals(nil)
            assert.equals(0, totals.totalKills)
            assert.equals(0, totals.totalXP)
            assert.equals(0, totals.totalCurrency)
        end)
    end)

    describe("UpdateHighestQualityDrop", function()
        -- **Feature: testable-architecture, Property 11: Highest quality drop tracking is correct**
        it("tracks the highest quality drop for any sequence of drops", function()
            local prop = property(
                lqc.int(1, 20),  -- number of drops
                function(numDrops)
                    local mobStats = {
                        kills = 1,
                        currency = 0,
                        xp = 0,
                        loot = {},
                        highestQualityDrop = nil,
                    }
                    
                    local maxQuality = 0
                    local maxQualityLink = nil
                    local maxQualityQuantity = 0
                    
                    -- Generate random drops
                    for i = 1, numDrops do
                        local quality = math.random(0, 4)
                        local link = "|cff" .. string.format("%06x", math.random(0, 16777215)) .. "[Item" .. i .. "]|r"
                        local quantity = math.random(1, 5)
                        
                        MobStats:UpdateHighestQualityDrop(mobStats, quality, link, quantity)
                        
                        -- Track what we expect the highest to be
                        if quality > maxQuality then
                            maxQuality = quality
                            maxQualityLink = link
                            maxQualityQuantity = quantity
                        end
                    end
                    
                    -- Verify highest quality drop is correct
                    if maxQuality == 0 then
                        -- No quality drops, should be nil
                        return mobStats.highestQualityDrop == nil
                    else
                        if not mobStats.highestQualityDrop then
                            return false, "Expected highestQualityDrop to be set"
                        end
                        
                        if mobStats.highestQualityDrop.quality ~= maxQuality then
                            return false, string.format("Expected quality=%d, got %d", maxQuality, mobStats.highestQualityDrop.quality)
                        end
                        
                        if mobStats.highestQualityDrop.link ~= maxQualityLink then
                            return false, "Link mismatch"
                        end
                        
                        if mobStats.highestQualityDrop.quantity ~= maxQualityQuantity then
                            return false, string.format("Expected quantity=%d, got %d", maxQualityQuantity, mobStats.highestQualityDrop.quantity)
                        end
                    end
                    
                    return true
                end
            )
            check(prop, { numtests = 100 })
        end)
        
        it("updates only when new drop has higher quality", function()
            local mobStats = {
                kills = 1,
                currency = 0,
                xp = 0,
                loot = {},
                highestQualityDrop = nil,
            }
            
            -- Add a blue item (quality 3)
            MobStats:UpdateHighestQualityDrop(mobStats, 3, "|cff0070dd[Blue Item]|r", 1)
            assert.equals(3, mobStats.highestQualityDrop.quality)
            assert.equals("|cff0070dd[Blue Item]|r", mobStats.highestQualityDrop.link)
            
            -- Add a green item (quality 2) - should not update
            MobStats:UpdateHighestQualityDrop(mobStats, 2, "|cff1eff00[Green Item]|r", 1)
            assert.equals(3, mobStats.highestQualityDrop.quality)
            assert.equals("|cff0070dd[Blue Item]|r", mobStats.highestQualityDrop.link)
            
            -- Add a purple item (quality 4) - should update
            MobStats:UpdateHighestQualityDrop(mobStats, 4, "|cffa335ee[Purple Item]|r", 1)
            assert.equals(4, mobStats.highestQualityDrop.quality)
            assert.equals("|cffa335ee[Purple Item]|r", mobStats.highestQualityDrop.link)
        end)
    end)

    describe("CopyQualityCounts", function()
        it("copies quality counts correctly", function()
            local source = {
                [2] = 5,
                [3] = 3,
                [4] = 1,
            }
            
            local target = MobStats:CopyQualityCounts(source)
            
            assert.equals(5, target[2])
            assert.equals(3, target[3])
            assert.equals(1, target[4])
        end)
        
        it("handles empty source table", function()
            local target = MobStats:CopyQualityCounts({})
            assert.is_table(target)
        end)
        
        it("handles nil source", function()
            local target = MobStats:CopyQualityCounts(nil)
            assert.is_table(target)
        end)
        
        it("clears existing target data", function()
            local source = {
                [2] = 5,
            }
            
            local target = {
                [2] = 10,
                [3] = 20,
            }
            
            MobStats:CopyQualityCounts(source, target)
            
            assert.equals(5, target[2])
            assert.is_nil(target[3])  -- Should be cleared
        end)
    end)
    
    describe("Edge Cases", function()
        it("handles nil values in RecordKill", function()
            local mobStats = {}
            MobStats:RecordKill("TestMob", nil, nil, mobStats)
            
            assert.equals(1, mobStats["TestMob"].kills)
            assert.equals(0, mobStats["TestMob"].xp)
            assert.equals(0, mobStats["TestMob"].currency)
        end)
        
        it("handles recording kills for same mob multiple times", function()
            local mobStats = {}
            
            MobStats:RecordKill("Boar", 100, 50, mobStats)
            MobStats:RecordKill("Boar", 100, 50, mobStats)
            MobStats:RecordKill("Boar", 100, 50, mobStats)
            
            assert.equals(3, mobStats["Boar"].kills)
            assert.equals(300, mobStats["Boar"].xp)
            assert.equals(150, mobStats["Boar"].currency)
        end)
        
        it("handles UpdateHighestQualityDrop with nil mobStats", function()
            -- Should not error
            MobStats:UpdateHighestQualityDrop(nil, 3, "|cff0070dd[Item]|r", 1)
        end)
        
        it("handles UpdateHighestQualityDrop with nil quality", function()
            local mobStats = {
                highestQualityDrop = nil,
            }
            
            MobStats:UpdateHighestQualityDrop(mobStats, nil, "|cff0070dd[Item]|r", 1)
            
            -- Should not update
            assert.is_nil(mobStats.highestQualityDrop)
        end)
        
        it("handles UpdateHighestQualityDrop with nil link", function()
            local mobStats = {
                highestQualityDrop = nil,
            }
            
            MobStats:UpdateHighestQualityDrop(mobStats, 3, nil, 1)
            
            -- Should not update
            assert.is_nil(mobStats.highestQualityDrop)
        end)
        
        it("handles CalculateTotals with missing loot tables", function()
            local mobStats = {
                ["Mob1"] = {
                    kills = 5,
                    xp = 100,
                    currency = 50,
                    -- No loot table
                },
            }
            
            local totals = MobStats:CalculateTotals(mobStats)
            
            assert.equals(5, totals.totalKills)
            assert.equals(100, totals.totalXP)
            assert.equals(50, totals.totalCurrency)
            assert.equals(0, totals.totalItems[2])
            assert.equals(0, totals.totalItems[3])
            assert.equals(0, totals.totalItems[4])
        end)
    end)
end)
