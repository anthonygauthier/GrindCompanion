-- Tests for Statistics module
describe("Statistics", function()
    local Statistics
    
    setup(function()
        -- Add project root to package path
        package.path = package.path .. ";./?.lua;./?/init.lua"
        Statistics = require("core.calculations.Statistics")
    end)
    
    describe("Property Tests", function()
        local lqc = require("lqc")
        local property = lqc.property
        local check = lqc.check
        
        -- **Feature: testable-architecture, Property 6: Elapsed time calculation is correct**
        -- **Validates: Requirements 5.1**
        describe("CalculateElapsedTime", function()
            it("returns correct difference for any valid start/end times", function()
                local prop = property(
                    lqc.int(0, 1000000),  -- Start time
                    lqc.int(0, 1000000),  -- End time offset
                    function(startTime, offset)
                        local endTime = startTime + offset
                        
                        -- Test when tracking (should use endTime as current time)
                        local result = Statistics:CalculateElapsedTime(startTime, endTime, true)
                        if result ~= offset then
                            return false
                        end
                        
                        -- Test when not tracking but stopped (should use difference)
                        result = Statistics:CalculateElapsedTime(startTime, endTime, false)
                        if result ~= offset then
                            return false
                        end
                        
                        return true
                    end
                )
                check(prop, { numtests = 100 })
            end)
        end)
        
        -- **Feature: testable-architecture, Property 7: Rate calculations are correct**
        -- **Validates: Requirements 5.2, 5.3**
        describe("CalculatePerHour", function()
            it("returns correct rate for any positive amount and duration", function()
                local prop = property(
                    lqc.int(1, 1000000),  -- Positive amount
                    lqc.int(1, 86400),    -- Positive duration (up to 1 day)
                    function(amount, duration)
                        local rate = Statistics:CalculatePerHour(amount, duration)
                        local expected = (amount / duration) * 3600
                        
                        -- Allow small floating point tolerance
                        return math.abs(rate - expected) < 0.01
                    end
                )
                check(prop, { numtests = 100 })
            end)
        end)
        
        -- **Feature: testable-architecture, Property 8: Kills remaining calculation is correct**
        -- **Validates: Requirements 5.4**
        describe("CalculateKillsRemaining", function()
            it("returns positive number for valid inputs", function()
                local prop = property(
                    lqc.int(0, 10000),    -- Current XP
                    lqc.int(1, 10000),    -- Total XP gained (must be positive)
                    lqc.int(1, 1000),     -- Total kills (must be positive)
                    function(currentXP, totalXPGained, totalKills)
                        -- Max XP must be greater than current XP
                        local maxXP = currentXP + math.random(1, 10000)
                        
                        local result = Statistics:CalculateKillsRemaining(currentXP, maxXP, totalXPGained, totalKills)
                        
                        -- Should return a positive number
                        if not result or result <= 0 then
                            return false
                        end
                        
                        -- Should be a whole number (ceiling applied)
                        if result ~= math.floor(result) then
                            return false
                        end
                        
                        return true
                    end
                )
                check(prop, { numtests = 100 })
            end)
        end)
    end)
    
    describe("Unit Tests - Edge Cases", function()
        describe("CalculateElapsedTime", function()
            it("returns 0 when startTime is nil", function()
                local result = Statistics:CalculateElapsedTime(nil, 100, true)
                assert.equals(0, result)
            end)
            
            it("returns 0 when not tracking and no stopTime", function()
                local result = Statistics:CalculateElapsedTime(100, nil, false)
                assert.equals(0, result)
            end)
            
            it("calculates correctly when tracking", function()
                local result = Statistics:CalculateElapsedTime(100, 250, true)
                assert.equals(150, result)
            end)
            
            it("calculates correctly when stopped", function()
                local result = Statistics:CalculateElapsedTime(100, 250, false)
                assert.equals(150, result)
            end)
        end)
        
        describe("CalculatePerHour", function()
            it("returns 0 when duration is 0", function()
                local result = Statistics:CalculatePerHour(1000, 0)
                assert.equals(0, result)
            end)
            
            it("returns 0 when duration is negative", function()
                local result = Statistics:CalculatePerHour(1000, -100)
                assert.equals(0, result)
            end)
            
            it("returns 0 when amount is nil", function()
                local result = Statistics:CalculatePerHour(nil, 100)
                assert.equals(0, result)
            end)
            
            it("returns 0 when duration is nil", function()
                local result = Statistics:CalculatePerHour(1000, nil)
                assert.equals(0, result)
            end)
            
            it("calculates correct rate", function()
                local result = Statistics:CalculatePerHour(3600, 3600)  -- 3600 in 1 hour
                assert.equals(3600, result)
            end)
            
            it("calculates correct rate for partial hour", function()
                local result = Statistics:CalculatePerHour(1800, 1800)  -- 1800 in 30 minutes
                assert.equals(3600, result)
            end)
        end)
        
        describe("CalculateTimeToLevel", function()
            it("returns nil when elapsed time is 0", function()
                local result = Statistics:CalculateTimeToLevel(0, 1000, 100, 0)
                assert.is_nil(result)
            end)
            
            it("returns nil when elapsed time is negative", function()
                local result = Statistics:CalculateTimeToLevel(0, 1000, 100, -100)
                assert.is_nil(result)
            end)
            
            it("returns nil when totalXPGained is 0", function()
                local result = Statistics:CalculateTimeToLevel(0, 1000, 0, 100)
                assert.is_nil(result)
            end)
            
            it("returns nil when totalXPGained is negative", function()
                local result = Statistics:CalculateTimeToLevel(0, 1000, -100, 100)
                assert.is_nil(result)
            end)
            
            it("returns nil when xpRemaining is 0 or negative", function()
                local result = Statistics:CalculateTimeToLevel(1000, 1000, 100, 100)
                assert.is_nil(result)
            end)
            
            it("returns nil when currentXP >= maxXP", function()
                local result = Statistics:CalculateTimeToLevel(1500, 1000, 100, 100)
                assert.is_nil(result)
            end)
            
            it("calculates correct time to level", function()
                -- Current: 500/1000 XP, gained 500 XP in 3600 seconds
                -- Need 500 more XP at rate of 500/3600 = 0.139 XP/sec
                -- Time needed: 500 / 0.139 = 3600 seconds
                local result = Statistics:CalculateTimeToLevel(500, 1000, 500, 3600)
                assert.is_true(math.abs(result - 3600) < 0.01)
            end)
        end)
        
        describe("CalculateKillsRemaining", function()
            it("returns nil when totalKills is 0", function()
                local result = Statistics:CalculateKillsRemaining(0, 1000, 100, 0)
                assert.is_nil(result)
            end)
            
            it("returns nil when totalKills is negative", function()
                local result = Statistics:CalculateKillsRemaining(0, 1000, 100, -10)
                assert.is_nil(result)
            end)
            
            it("returns nil when totalXPGained is 0", function()
                local result = Statistics:CalculateKillsRemaining(0, 1000, 0, 10)
                assert.is_nil(result)
            end)
            
            it("returns nil when totalXPGained is negative", function()
                local result = Statistics:CalculateKillsRemaining(0, 1000, -100, 10)
                assert.is_nil(result)
            end)
            
            it("returns nil when xpRemaining is 0 or negative", function()
                local result = Statistics:CalculateKillsRemaining(1000, 1000, 100, 10)
                assert.is_nil(result)
            end)
            
            it("returns nil when currentXP >= maxXP", function()
                local result = Statistics:CalculateKillsRemaining(1500, 1000, 100, 10)
                assert.is_nil(result)
            end)
            
            it("calculates correct kills remaining", function()
                -- Current: 500/1000 XP, gained 500 XP in 10 kills
                -- Need 500 more XP at rate of 50 XP/kill
                -- Kills needed: ceil(500 / 50) = 10 kills
                local result = Statistics:CalculateKillsRemaining(500, 1000, 500, 10)
                assert.equals(10, result)
            end)
            
            it("rounds up kills remaining", function()
                -- Current: 500/1000 XP, gained 400 XP in 10 kills
                -- Need 500 more XP at rate of 40 XP/kill
                -- Kills needed: ceil(500 / 40) = ceil(12.5) = 13 kills
                local result = Statistics:CalculateKillsRemaining(500, 1000, 400, 10)
                assert.equals(13, result)
            end)
        end)
    end)
end)
