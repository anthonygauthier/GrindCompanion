-- Tests for Formatter module
describe("Formatter", function()
    local Formatter
    
    setup(function()
        -- Add project root to package path
        package.path = package.path .. ";./?.lua;./?/init.lua"
        Formatter = require("core.formatting.Formatter")
    end)
    
    describe("Property Tests", function()
        -- **Feature: testable-architecture, Property 3: Coin formatting produces valid output**
        -- **Validates: Requirements 4.1**
        describe("FormatCoin", function()
            it("produces valid output for any non-negative copper amount", function()
                -- Run 100 iterations with random inputs
                for i = 1, 100 do
                    local copper = math.random(0, 1000000000)
                    local result = Formatter:FormatCoin(copper)
                    
                    -- Verify result is a non-empty string
                    assert.is_string(result)
                    assert.is_true(#result > 0)
                    
                    -- Verify output contains at least one of the suffixes
                    local hasGold = string.find(result, "g") ~= nil
                    local hasSilver = string.find(result, "s") ~= nil
                    local hasCopper = string.find(result, "c") ~= nil
                    
                    assert.is_true(hasGold or hasSilver or hasCopper, 
                        "Result should contain g, s, or c suffix: " .. result)
                end
            end)
        end)
        
        -- **Feature: testable-architecture, Property 4: Time formatting produces valid output**
        -- **Validates: Requirements 4.2**
        describe("FormatTime", function()
            it("produces valid output for any non-negative seconds value", function()
                -- Run 100 iterations with random inputs
                for i = 1, 100 do
                    local seconds = math.random(0, 86400 * 7)  -- 0 to 7 days in seconds
                    local result = Formatter:FormatTime(seconds)
                    
                    -- Verify result is a non-empty string
                    assert.is_string(result)
                    assert.is_true(#result > 0)
                    
                    -- Verify output contains at least one of the suffixes
                    local hasHours = string.find(result, "h") ~= nil
                    local hasMinutes = string.find(result, "m") ~= nil
                    local hasSeconds = string.find(result, "s") ~= nil
                    
                    assert.is_true(hasHours or hasMinutes or hasSeconds,
                        "Result should contain h, m, or s suffix: " .. result)
                end
            end)
        end)
        
        -- **Feature: testable-architecture, Property 5: Quality summary formatting produces valid output**
        -- **Validates: Requirements 4.3**
        describe("FormatQualitySummary", function()
            it("produces valid output for any quality count table", function()
                -- Run 100 iterations with random inputs
                for i = 1, 100 do
                    local greenCount = math.random(0, 1000)
                    local blueCount = math.random(0, 1000)
                    local purpleCount = math.random(0, 1000)
                    
                    local counts = {
                        [2] = greenCount,
                        [3] = blueCount,
                        [4] = purpleCount,
                    }
                    
                    local result = Formatter:FormatQualitySummary(counts)
                    
                    -- Verify result is a non-empty string
                    assert.is_string(result)
                    assert.is_true(#result > 0)
                    
                    -- Verify output contains quality labels
                    local hasGreen = string.find(result, "Green") ~= nil
                    local hasBlue = string.find(result, "Blue") ~= nil
                    local hasPurple = string.find(result, "Purple") ~= nil
                    
                    assert.is_true(hasGreen and hasBlue and hasPurple,
                        "Result should contain Green, Blue, and Purple labels: " .. result)
                end
            end)
        end)
    end)
    
    describe("Unit Tests - Edge Cases", function()
        describe("FormatCoin", function()
            it("formats zero copper correctly", function()
                local result = Formatter:FormatCoin(0)
                assert.is_string(result)
                assert.is_true(string.find(result, "0c") ~= nil)
            end)
            
            it("handles negative values by clamping to zero", function()
                local result = Formatter:FormatCoin(-100)
                assert.is_string(result)
                assert.is_true(string.find(result, "0c") ~= nil)
            end)
            
            it("handles nil values", function()
                local result = Formatter:FormatCoin(nil)
                assert.is_string(result)
                assert.is_true(string.find(result, "0c") ~= nil)
            end)
            
            it("formats gold amounts correctly", function()
                local result = Formatter:FormatCoin(10000)  -- 1 gold
                assert.is_string(result)
                assert.is_true(string.find(result, "1g") ~= nil)
            end)
            
            it("formats mixed amounts correctly", function()
                local result = Formatter:FormatCoin(12345)  -- 1g 23s 45c
                assert.is_string(result)
                assert.is_true(string.find(result, "1g") ~= nil)
                assert.is_true(string.find(result, "23s") ~= nil)
                assert.is_true(string.find(result, "45c") ~= nil)
            end)
            
            it("respects showZeros option", function()
                local result = Formatter:FormatCoin(45, { showZeros = true })
                assert.is_string(result)
                assert.is_true(string.find(result, "0g") ~= nil)
                assert.is_true(string.find(result, "0s") ~= nil)
                assert.is_true(string.find(result, "45c") ~= nil)
            end)
        end)
        
        describe("FormatTime", function()
            it("formats zero seconds correctly", function()
                local result = Formatter:FormatTime(0)
                assert.equals("0s", result)
            end)
            
            it("handles negative values by clamping to zero", function()
                local result = Formatter:FormatTime(-100)
                assert.equals("0s", result)
            end)
            
            it("handles nil values", function()
                local result = Formatter:FormatTime(nil)
                assert.equals("0s", result)
            end)
            
            it("formats seconds only", function()
                local result = Formatter:FormatTime(45)
                assert.equals("45s", result)
            end)
            
            it("formats minutes and seconds", function()
                local result = Formatter:FormatTime(125)  -- 2m 5s
                assert.equals("2m 5s", result)
            end)
            
            it("formats hours, minutes, and seconds", function()
                local result = Formatter:FormatTime(3665)  -- 1h 1m 5s
                assert.equals("1h 1m 5s", result)
            end)
            
            it("formats hours and seconds without minutes", function()
                local result = Formatter:FormatTime(3605)  -- 1h 0m 5s
                assert.equals("1h 0m 5s", result)
            end)
        end)
        
        describe("FormatQualitySummary", function()
            it("handles empty quality counts", function()
                local result = Formatter:FormatQualitySummary({})
                assert.is_string(result)
                -- Check for the labels with color codes
                assert.is_true(string.find(result, "Green") ~= nil)
                assert.is_true(string.find(result, "Blue") ~= nil)
                assert.is_true(string.find(result, "Purple") ~= nil)
                assert.is_true(string.find(result, ": 0") ~= nil)
            end)
            
            it("handles nil quality counts", function()
                local result = Formatter:FormatQualitySummary(nil)
                assert.is_string(result)
                assert.is_true(string.find(result, "Green") ~= nil)
                assert.is_true(string.find(result, ": 0") ~= nil)
            end)
            
            it("formats quality counts correctly", function()
                local counts = {
                    [2] = 5,
                    [3] = 3,
                    [4] = 1,
                }
                local result = Formatter:FormatQualitySummary(counts)
                assert.is_string(result)
                -- Check for the labels and values (color codes are present)
                assert.is_true(string.find(result, "Green") ~= nil)
                assert.is_true(string.find(result, "Blue") ~= nil)
                assert.is_true(string.find(result, "Purple") ~= nil)
                assert.is_true(string.find(result, ": 5") ~= nil)
                assert.is_true(string.find(result, ": 3") ~= nil)
                assert.is_true(string.find(result, ": 1") ~= nil)
            end)
        end)
        
        describe("FormatNumber", function()
            it("formats zero correctly", function()
                assert.equals("0", Formatter:FormatNumber(0))
            end)
            
            it("handles nil values", function()
                assert.equals("0", Formatter:FormatNumber(nil))
            end)
            
            it("formats small numbers as-is", function()
                assert.equals("999", Formatter:FormatNumber(999))
            end)
            
            it("formats thousands with K suffix", function()
                assert.equals("1.0K", Formatter:FormatNumber(1000))
                assert.equals("5.5K", Formatter:FormatNumber(5500))
            end)
            
            it("formats millions with M suffix", function()
                assert.equals("1.0M", Formatter:FormatNumber(1000000))
                assert.equals("2.5M", Formatter:FormatNumber(2500000))
            end)
        end)
    end)
end)
