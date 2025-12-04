-- Tests for GameAdapter module
describe("GameAdapter", function()
    local TestAdapter
    
    setup(function()
        -- Add project root to package path
        package.path = package.path .. ";./?.lua;./?/init.lua"
        TestAdapter = require("tests.mocks.TestAdapter")
    end)
    
    describe("Property Tests", function()
        -- **Feature: testable-architecture, Property 1: Game adapter returns structured data**
        -- **Validates: Requirements 2.3**
        describe("Data Transformation", function()
            it("transforms WoW API responses into simple Lua tables with no function references", function()
                -- Run property test with 100 random inputs
                for i = 1, 100 do
                    local level = math.random(1, 60)
                    local currentXP = math.random(0, 1000000)
                    local maxXP = math.random(1, 1000000)
                    
                    local adapter = TestAdapter:new()
                    adapter:SetPlayerInfo({
                        level = level,
                        currentXP = currentXP,
                        maxXP = maxXP,
                    })
                    
                    local result = adapter:GetPlayerInfo()
                    
                    -- Verify result is a table
                    assert.is_table(result)
                    
                    -- Verify no function references in returned data
                    for k, v in pairs(result) do
                        assert.is_not_function(v, "Field " .. k .. " should not be a function")
                    end
                    
                    -- Verify expected fields exist and have correct types
                    assert.is_string(result.name)
                    assert.is_string(result.realm)
                    assert.is_number(result.level)
                    assert.is_string(result.race)
                    assert.is_string(result.class)
                    assert.is_number(result.gender)
                    assert.is_number(result.currentXP)
                    assert.is_number(result.maxXP)
                    
                    -- Verify values match what was set
                    assert.equals(level, result.level)
                    assert.equals(currentXP, result.currentXP)
                    assert.equals(maxXP, result.maxXP)
                end
            end)
            
            it("GetItemInfo returns structured data with no function references", function()
                -- Run property test with 100 random inputs
                for i = 1, 100 do
                    local quality = math.random(0, 5)
                    local sellPrice = math.random(0, 100000)
                    
                    local adapter = TestAdapter:new()
                    local itemLink = "|cff0070dd[Test Item]|r"
                    adapter:SetItemInfo(itemLink, {
                        name = "Test Item",
                        link = itemLink,
                        quality = quality,
                        texture = "Interface\\Icons\\INV_Misc_QuestionMark",
                        sellPrice = sellPrice,
                    })
                    
                    local result = adapter:GetItemInfo(itemLink)
                    
                    -- Verify result is a table
                    assert.is_table(result)
                    
                    -- Verify no function references
                    for k, v in pairs(result) do
                        assert.is_not_function(v, "Field " .. k .. " should not be a function")
                    end
                    
                    -- Verify structure - if data exists, verify it matches
                    if result.quality ~= nil then
                        assert.equals(quality, result.quality)
                    end
                    if result.sellPrice ~= nil then
                        assert.equals(sellPrice, result.sellPrice)
                    end
                end
            end)
        end)
        
        -- **Feature: testable-architecture, Property 2: Game adapter handles errors gracefully**
        -- **Validates: Requirements 2.5**
        describe("Error Handling", function()
            it("returns valid defaults for any error condition without raising errors", function()
                -- Run property test with 100 iterations
                for i = 1, 100 do
                    local adapter = TestAdapter:new()
                    
                    -- Test various methods that should never raise errors
                    -- Wrap in pcall to catch any errors
                    local ok, err = pcall(function()
                        -- These should all return valid defaults
                        local time = adapter:GetCurrentTime()
                        assert.is_number(time)
                        
                        local timestamp = adapter:GetTimestamp()
                        assert.is_number(timestamp)
                        
                        local level = adapter:GetPlayerLevel()
                        assert.is_number(level)
                        
                        local name = adapter:GetPlayerName()
                        assert.is_string(name)
                        
                        local zone = adapter:GetCurrentZone()
                        assert.is_string(zone)
                        
                        local color = adapter:GetQualityColor(2)
                        assert.is_string(color)
                        
                        local info = adapter:GetPlayerInfo()
                        assert.is_table(info)
                        
                        -- Test with nil/invalid inputs
                        local itemInfo = adapter:GetItemInfo(nil)
                        assert.is_table(itemInfo)
                        
                        local quality = adapter:GetItemQuality(nil)
                        -- quality can be nil, that's valid
                        
                        -- PrintMessage should not error
                        adapter:PrintMessage("test")
                        adapter:PrintMessage(nil)
                    end)
                    
                    -- Verify no errors were raised
                    assert.is_true(ok, "Adapter should not raise errors: " .. tostring(err))
                end
            end)
        end)
    end)
    
    describe("Unit Tests", function()
        describe("GameAdapter", function()
            -- Note: GameAdapter requires WoW API, so we test the interface contract
            -- Actual WoW API testing would require the game client
            
            it("should have all required methods", function()
                local GameAdapter = require("game.adapters.GameAdapter")
                
                assert.is_function(GameAdapter.GetCurrentTime)
                assert.is_function(GameAdapter.GetTimestamp)
                assert.is_function(GameAdapter.GetPlayerLevel)
                assert.is_function(GameAdapter.GetPlayerMaxLevel)
                assert.is_function(GameAdapter.GetPlayerName)
                assert.is_function(GameAdapter.GetPlayerRealm)
                assert.is_function(GameAdapter.GetPlayerInfo)
                assert.is_function(GameAdapter.GetItemInfo)
                assert.is_function(GameAdapter.GetItemQuality)
                assert.is_function(GameAdapter.GetCurrentZone)
                assert.is_function(GameAdapter.GetQualityColor)
                assert.is_function(GameAdapter.PrintMessage)
                assert.is_function(GameAdapter.GetUnitName)
                assert.is_function(GameAdapter.IsUnitDead)
                assert.is_function(GameAdapter.IsUnitPlayer)
                assert.is_function(GameAdapter.GetUnitGUID)
                assert.is_function(GameAdapter.GetCombatLogEvent)
            end)
        end)
        
        describe("TestAdapter", function()
            local adapter
            
            before_each(function()
                adapter = TestAdapter:new()
            end)
            
            describe("Time functions", function()
                it("returns and updates current time", function()
                    assert.equals(0, adapter:GetCurrentTime())
                    adapter:SetCurrentTime(100)
                    assert.equals(100, adapter:GetCurrentTime())
                end)
                
                it("returns and updates timestamp", function()
                    assert.equals(0, adapter:GetTimestamp())
                    adapter:SetTimestamp(1234567890)
                    assert.equals(1234567890, adapter:GetTimestamp())
                end)
            end)
            
            describe("Player functions", function()
                it("returns player level", function()
                    assert.equals(60, adapter:GetPlayerLevel())
                end)
                
                it("returns max level", function()
                    assert.equals(60, adapter:GetPlayerMaxLevel())
                end)
                
                it("returns player name", function()
                    assert.equals("TestPlayer", adapter:GetPlayerName())
                end)
                
                it("returns player realm", function()
                    assert.equals("TestRealm", adapter:GetPlayerRealm())
                end)
                
                it("returns player info", function()
                    local info = adapter:GetPlayerInfo()
                    assert.equals("TestPlayer", info.name)
                    assert.equals("TestRealm", info.realm)
                    assert.equals(60, info.level)
                    assert.equals("Human", info.race)
                    assert.equals("Warrior", info.class)
                    assert.equals(2, info.gender)
                    assert.equals(0, info.currentXP)
                    assert.equals(1000, info.maxXP)
                end)
                
                it("updates player info", function()
                    adapter:SetPlayerInfo({ level = 50, currentXP = 500 })
                    local info = adapter:GetPlayerInfo()
                    assert.equals(50, info.level)
                    assert.equals(500, info.currentXP)
                end)
                
                it("returns a copy of player info to prevent external modification", function()
                    local info1 = adapter:GetPlayerInfo()
                    info1.level = 99
                    local info2 = adapter:GetPlayerInfo()
                    assert.equals(60, info2.level)
                end)
            end)
            
            describe("Item functions", function()
                it("returns nil item info for unknown items", function()
                    local info = adapter:GetItemInfo("|cff0070dd[Unknown Item]|r")
                    assert.is_nil(info.name)
                    assert.is_nil(info.quality)
                end)
                
                it("returns cached item info", function()
                    local itemLink = "|cff0070dd[Test Item]|r"
                    adapter:SetItemInfo(itemLink, {
                        name = "Test Item",
                        link = itemLink,
                        quality = 3,
                        texture = "Interface\\Icons\\INV_Misc_QuestionMark",
                        sellPrice = 1000,
                    })
                    
                    local info = adapter:GetItemInfo(itemLink)
                    assert.equals("Test Item", info.name)
                    assert.equals(3, info.quality)
                    assert.equals(1000, info.sellPrice)
                end)
                
                it("returns item quality", function()
                    local itemLink = "|cff0070dd[Test Item]|r"
                    adapter:SetItemInfo(itemLink, { quality = 4 })
                    assert.equals(4, adapter:GetItemQuality(itemLink))
                end)
                
                it("returns nil for unknown item quality", function()
                    assert.is_nil(adapter:GetItemQuality("|cff0070dd[Unknown]|r"))
                end)
                
                it("handles nil item link", function()
                    local info = adapter:GetItemInfo(nil)
                    assert.is_table(info)
                    assert.is_nil(info.name)
                    
                    assert.is_nil(adapter:GetItemQuality(nil))
                end)
            end)
            
            describe("Zone functions", function()
                it("returns current zone", function()
                    assert.equals("TestZone", adapter:GetCurrentZone())
                end)
                
                it("updates current zone", function()
                    adapter:SetCurrentZone("NewZone")
                    assert.equals("NewZone", adapter:GetCurrentZone())
                end)
            end)
            
            describe("Color functions", function()
                it("returns quality colors", function()
                    assert.equals("|cff9d9d9d", adapter:GetQualityColor(0))
                    assert.equals("|cffffffff", adapter:GetQualityColor(1))
                    assert.equals("|cff1eff00", adapter:GetQualityColor(2))
                    assert.equals("|cff0070dd", adapter:GetQualityColor(3))
                    assert.equals("|cffa335ee", adapter:GetQualityColor(4))
                    assert.equals("|cffff8000", adapter:GetQualityColor(5))
                end)
                
                it("returns default color for nil quality", function()
                    assert.equals("|cffffffff", adapter:GetQualityColor(nil))
                end)
                
                it("returns default color for unknown quality", function()
                    assert.equals("|cffffffff", adapter:GetQualityColor(99))
                end)
                
                it("allows setting custom quality colors", function()
                    adapter:SetQualityColor(2, "|cffFF0000")
                    assert.equals("|cffFF0000", adapter:GetQualityColor(2))
                end)
            end)
            
            describe("Unit functions", function()
                it("returns unit name", function()
                    adapter:SetUnitName("target", "TestMob")
                    assert.equals("TestMob", adapter:GetUnitName("target"))
                end)
                
                it("returns nil for unknown unit", function()
                    assert.is_nil(adapter:GetUnitName("unknownunit"))
                end)
                
                it("checks if unit is dead", function()
                    adapter:SetUnitDead("target", true)
                    assert.is_true(adapter:IsUnitDead("target"))
                    adapter:SetUnitDead("target", false)
                    assert.is_false(adapter:IsUnitDead("target"))
                end)
                
                it("checks if unit is player", function()
                    adapter:SetUnitPlayer("target", false)
                    assert.is_false(adapter:IsUnitPlayer("target"))
                    adapter:SetUnitPlayer("target", true)
                    assert.is_true(adapter:IsUnitPlayer("target"))
                end)
                
                it("returns unit GUID", function()
                    adapter:SetUnitGUID("player", "Player-1234-56789ABC")
                    assert.equals("Player-1234-56789ABC", adapter:GetUnitGUID("player"))
                end)
                
                it("returns nil for unit with no GUID", function()
                    assert.is_nil(adapter:GetUnitGUID("unknownunit"))
                end)
            end)
            
            describe("Combat Log functions", function()
                it("returns combat log event", function()
                    local event = {
                        timestamp = 12345.67,
                        subevent = "SWING_DAMAGE",
                        sourceGUID = "Player-1234-56789ABC",
                        sourceName = "TestPlayer",
                        destGUID = "Creature-0-1234-5678",
                        destName = "TestMob",
                        destFlags = 0x00000048,
                    }
                    adapter:SetCombatLogEvent(event)
                    
                    local result = adapter:GetCombatLogEvent()
                    assert.equals(event.timestamp, result.timestamp)
                    assert.equals(event.subevent, result.subevent)
                    assert.equals(event.sourceGUID, result.sourceGUID)
                    assert.equals(event.destName, result.destName)
                end)
                
                it("returns nil when no event is set", function()
                    assert.is_nil(adapter:GetCombatLogEvent())
                end)
            end)
            
            describe("Chat functions", function()
                it("stores printed messages", function()
                    adapter:PrintMessage("Hello")
                    adapter:PrintMessage("World")
                    local messages = adapter:GetMessages()
                    assert.equals(2, #messages)
                    assert.equals("Hello", messages[1])
                    assert.equals("World", messages[2])
                end)
                
                it("clears messages", function()
                    adapter:PrintMessage("Test")
                    adapter:ClearMessages()
                    local messages = adapter:GetMessages()
                    assert.equals(0, #messages)
                end)
                
                it("handles nil message", function()
                    adapter:PrintMessage(nil)
                    local messages = adapter:GetMessages()
                    assert.equals(0, #messages)
                end)
            end)
            
            describe("Interface compatibility", function()
                it("implements same interface as GameAdapter", function()
                    local GameAdapter = require("game.adapters.GameAdapter")
                    
                    -- Verify TestAdapter has all the same methods
                    for methodName, _ in pairs(GameAdapter) do
                        if type(GameAdapter[methodName]) == "function" then
                            assert.is_function(adapter[methodName], 
                                "TestAdapter missing method: " .. methodName)
                        end
                    end
                end)
            end)
        end)
    end)
end)

