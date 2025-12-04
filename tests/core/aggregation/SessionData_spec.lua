-- Tests for SessionData module
describe("SessionData", function()
    local SessionData
    
    setup(function()
        -- Add project root to package path
        package.path = package.path .. ";./?.lua;./?/init.lua"
        SessionData = require("core.aggregation.SessionData")
    end)
    
    describe("BuildSnapshot", function()
        it("builds snapshot with various session states", function()
            local sessionState = {
                startTime = 1000,
                elapsedTime = 3600,
                startTimestamp = 1234567890,
                endTimestamp = 1234571490,
                totalXP = 5000,
                killCount = 50,
                currencyCopper = 10000,
                grayCopper = 2000,
                potentialAHCopper = 5000,
                lootQualityCount = {
                    [2] = 10,
                    [3] = 5,
                    [4] = 1,
                },
            }
            
            local characterInfo = {
                name = "TestPlayer",
                realm = "TestRealm",
                startingLevel = 58,
                level = 59,
                race = "Human",
                class = "Warrior",
                gender = 2,
                wasMaxLevel = false,
            }
            
            local zoneList = {"Elwynn Forest", "Westfall"}
            local mobStats = {
                ["Boar"] = {
                    kills = 30,
                    currency = 5000,
                    xp = 3000,
                    loot = {
                        [2] = 5,
                        [3] = 2,
                    },
                    highestQualityDrop = {
                        quality = 3,
                        link = "|cff0070dd[Blue Item]|r",
                        quantity = 1,
                    },
                },
                ["Wolf"] = {
                    kills = 20,
                    currency = 3000,
                    xp = 2000,
                    loot = {
                        [2] = 5,
                        [3] = 3,
                        [4] = 1,
                    },
                },
            }
            
            local lootedItems = {
                {link = "|cff1eff00[Green Item]|r", quality = 2, quantity = 1},
                {link = "|cff0070dd[Blue Item]|r", quality = 3, quantity = 1},
            }
            
            local snapshot = SessionData:BuildSnapshot(
                sessionState,
                characterInfo,
                zoneList,
                mobStats,
                lootedItems
            )
            
            -- Verify character info
            assert.equals("TestPlayer", snapshot.character.name)
            assert.equals("TestRealm", snapshot.character.realm)
            assert.equals(58, snapshot.character.startingLevel)
            assert.equals(59, snapshot.character.endingLevel)
            assert.equals("Human", snapshot.character.race)
            assert.equals("Warrior", snapshot.character.class)
            assert.equals(2, snapshot.character.gender)
            
            -- Verify session data
            assert.equals(1234567890, snapshot.startedAt)
            assert.equals(1234571490, snapshot.endedAt)
            assert.equals(3600, snapshot.duration)
            assert.equals(5000, snapshot.totalXP)
            assert.equals(50, snapshot.killCount)
            assert.equals(10000, snapshot.currencyCopper)
            assert.equals(2000, snapshot.grayCopper)
            assert.equals(5000, snapshot.potentialAHCopper)
            assert.is_false(snapshot.wasMaxLevel)
            
            -- Verify loot quality counts
            assert.equals(10, snapshot.loot[2])
            assert.equals(5, snapshot.loot[3])
            assert.equals(1, snapshot.loot[4])
            
            -- Verify zones
            assert.equals(2, #snapshot.zones)
            assert.equals("Elwynn Forest", snapshot.zones[1])
            assert.equals("Westfall", snapshot.zones[2])
            
            -- Verify mob stats
            assert.equals(30, snapshot.mobs["Boar"].kills)
            assert.equals(5000, snapshot.mobs["Boar"].currency)
            assert.equals(3000, snapshot.mobs["Boar"].xp)
            assert.equals(3, snapshot.mobs["Boar"].highestQualityDrop.quality)
            
            assert.equals(20, snapshot.mobs["Wolf"].kills)
            assert.equals(3000, snapshot.mobs["Wolf"].currency)
            assert.equals(2000, snapshot.mobs["Wolf"].xp)
            
            -- Verify mob summary
            assert.equals(50, snapshot.mobSummary.totalKills)
            assert.equals(8000, snapshot.mobSummary.totalCurrency)
            assert.equals(5000, snapshot.mobSummary.totalXP)
            assert.equals(2, snapshot.mobSummary.uniqueMobs)
            assert.equals(10, snapshot.mobSummary.totalItems[2])
            assert.equals(5, snapshot.mobSummary.totalItems[3])
            assert.equals(1, snapshot.mobSummary.totalItems[4])
            
            -- Verify looted items
            assert.equals(2, #snapshot.lootedItems)
            assert.equals("|cff1eff00[Green Item]|r", snapshot.lootedItems[1].link)
            assert.equals(2, snapshot.lootedItems[1].quality)
        end)
        
        it("builds snapshot for max level character", function()
            local sessionState = {
                startTime = 1000,
                elapsedTime = 1800,
                startTimestamp = 1234567890,
                endTimestamp = 1234569690,
                totalXP = 0,
                killCount = 25,
                currencyCopper = 15000,
                grayCopper = 3000,
                potentialAHCopper = 8000,
                lootQualityCount = {
                    [2] = 5,
                    [3] = 2,
                },
            }
            
            local characterInfo = {
                name = "MaxPlayer",
                realm = "TestRealm",
                startingLevel = 60,
                level = 60,
                race = "Orc",
                class = "Shaman",
                gender = 2,
                wasMaxLevel = true,
            }
            
            local snapshot = SessionData:BuildSnapshot(
                sessionState,
                characterInfo,
                {},
                {},
                {}
            )
            
            assert.is_true(snapshot.wasMaxLevel)
            assert.equals(60, snapshot.character.startingLevel)
            assert.equals(60, snapshot.character.endingLevel)
            assert.equals(0, snapshot.totalXP)
        end)
        
        it("handles empty mob stats and loot", function()
            local sessionState = {
                startTime = 1000,
                elapsedTime = 600,
                startTimestamp = 1234567890,
                endTimestamp = 1234568490,
                totalXP = 1000,
                killCount = 10,
                currencyCopper = 500,
                grayCopper = 100,
                potentialAHCopper = 200,
                lootQualityCount = {},
            }
            
            local characterInfo = {
                name = "EmptyPlayer",
                realm = "TestRealm",
                startingLevel = 10,
                level = 10,
                race = "Dwarf",
                class = "Paladin",
                gender = 2,
                wasMaxLevel = false,
            }
            
            local snapshot = SessionData:BuildSnapshot(
                sessionState,
                characterInfo,
                {},
                {},
                {}
            )
            
            assert.equals(0, #snapshot.zones)
            assert.equals(0, #snapshot.lootedItems)
            assert.equals(0, snapshot.mobSummary.totalKills)
            assert.equals(0, snapshot.mobSummary.uniqueMobs)
        end)
        
        it("tracks zones correctly", function()
            local sessionState = {
                startTime = 1000,
                elapsedTime = 3600,
                startTimestamp = 1234567890,
                endTimestamp = 1234571490,
                totalXP = 5000,
                killCount = 50,
                currencyCopper = 10000,
                grayCopper = 2000,
                potentialAHCopper = 5000,
                lootQualityCount = {},
            }
            
            local characterInfo = {
                name = "ZonePlayer",
                realm = "TestRealm",
                startingLevel = 20,
                level = 21,
                race = "NightElf",
                class = "Druid",
                gender = 3,
                wasMaxLevel = false,
            }
            
            local zoneList = {"Darkshore", "Ashenvale", "Stonetalon Mountains"}
            
            local snapshot = SessionData:BuildSnapshot(
                sessionState,
                characterInfo,
                zoneList,
                {},
                {}
            )
            
            assert.equals(3, #snapshot.zones)
            assert.equals("Darkshore", snapshot.zones[1])
            assert.equals("Ashenvale", snapshot.zones[2])
            assert.equals("Stonetalon Mountains", snapshot.zones[3])
        end)
        
        it("returns nil when startTime is missing", function()
            local sessionState = {
                -- No startTime
                elapsedTime = 3600,
            }
            
            local characterInfo = {
                name = "TestPlayer",
                level = 10,
            }
            
            local snapshot = SessionData:BuildSnapshot(
                sessionState,
                characterInfo,
                {},
                {},
                {}
            )
            
            assert.is_nil(snapshot)
        end)
        
        it("returns nil when sessionState is nil", function()
            local snapshot = SessionData:BuildSnapshot(
                nil,
                {},
                {},
                {},
                {}
            )
            
            assert.is_nil(snapshot)
        end)
    end)

    describe("CalculateTrendStatistics", function()
        it("calculates statistics with multiple sessions", function()
            local sessions = {
                {
                    duration = 3600,
                    currencyCopper = 10000,
                    grayCopper = 2000,
                    potentialAHCopper = 3000,
                    totalXP = 5000,
                    wasMaxLevel = false,
                },
                {
                    duration = 1800,
                    currencyCopper = 5000,
                    grayCopper = 1000,
                    potentialAHCopper = 1500,
                    totalXP = 2500,
                    wasMaxLevel = false,
                },
                {
                    duration = 7200,
                    currencyCopper = 20000,
                    grayCopper = 4000,
                    potentialAHCopper = 6000,
                    totalXP = 0,
                    wasMaxLevel = true,
                },
            }
            
            local stats = SessionData:CalculateTrendStatistics(sessions)
            
            assert.equals(3, stats.totalSessions)
            assert.equals(12600, stats.totalDuration)  -- 3600 + 1800 + 7200
            assert.equals(52500, stats.totalCurrency)  -- Sum of all currency
            assert.equals(7500, stats.totalXP)  -- Sum of all XP
            
            -- Average copper per hour: 52500 / (12600 / 3600) = 15000
            assert.is_true(math.abs(stats.avgCopperPerHour - 15000) < 1)
            
            -- Best copper per hour should be from session 1: 15000 / 1 = 15000
            assert.is_true(stats.bestCopperPerHour > 0)
            
            -- Average XP per hour (only non-max-level sessions): 7500 / (5400 / 3600) = 5000
            assert.is_true(math.abs(stats.avgXPPerHour - 5000) < 1)
            
            -- Best XP per hour should be from session 1: 5000 / 1 = 5000
            assert.is_true(stats.bestXPPerHour > 0)
        end)
        
        it("handles empty session list", function()
            local stats = SessionData:CalculateTrendStatistics({})
            
            assert.equals(0, stats.totalSessions)
            assert.equals(0, stats.totalDuration)
            assert.equals(0, stats.avgCopperPerHour)
            assert.equals(0, stats.bestCopperPerHour)
            assert.equals(0, stats.avgXPPerHour)
            assert.equals(0, stats.bestXPPerHour)
            assert.equals(0, stats.totalCurrency)
            assert.equals(0, stats.totalXP)
        end)
        
        it("handles nil sessions", function()
            local stats = SessionData:CalculateTrendStatistics(nil)
            
            assert.equals(0, stats.totalSessions)
            assert.equals(0, stats.totalDuration)
            assert.equals(0, stats.avgCopperPerHour)
            assert.equals(0, stats.bestCopperPerHour)
            assert.equals(0, stats.avgXPPerHour)
            assert.equals(0, stats.bestXPPerHour)
            assert.equals(0, stats.totalCurrency)
            assert.equals(0, stats.totalXP)
        end)
        
        it("handles mix of max level and leveling sessions", function()
            local sessions = {
                {
                    duration = 3600,
                    currencyCopper = 10000,
                    grayCopper = 0,
                    potentialAHCopper = 0,
                    totalXP = 5000,
                    wasMaxLevel = false,
                },
                {
                    duration = 3600,
                    currencyCopper = 15000,
                    grayCopper = 0,
                    potentialAHCopper = 0,
                    totalXP = 0,
                    wasMaxLevel = true,
                },
                {
                    duration = 3600,
                    currencyCopper = 10000,
                    grayCopper = 0,
                    potentialAHCopper = 0,
                    totalXP = 3000,
                    wasMaxLevel = false,
                },
            }
            
            local stats = SessionData:CalculateTrendStatistics(sessions)
            
            assert.equals(3, stats.totalSessions)
            assert.equals(8000, stats.totalXP)  -- Only from non-max-level sessions
            
            -- Average XP per hour should only consider non-max-level sessions
            -- 8000 XP over 7200 seconds (2 hours) = 4000 XP/hr
            assert.is_true(math.abs(stats.avgXPPerHour - 4000) < 1)
        end)
        
        it("verifies averages and totals are calculated correctly", function()
            local sessions = {
                {
                    duration = 1800,  -- 0.5 hours
                    currencyCopper = 5000,
                    grayCopper = 1000,
                    potentialAHCopper = 2000,
                    totalXP = 2000,
                    wasMaxLevel = false,
                },
                {
                    duration = 3600,  -- 1 hour
                    currencyCopper = 10000,
                    grayCopper = 2000,
                    potentialAHCopper = 4000,
                    totalXP = 4000,
                    wasMaxLevel = false,
                },
            }
            
            local stats = SessionData:CalculateTrendStatistics(sessions)
            
            -- Total currency: (5000+1000+2000) + (10000+2000+4000) = 24000
            assert.equals(24000, stats.totalCurrency)
            
            -- Total XP: 2000 + 4000 = 6000
            assert.equals(6000, stats.totalXP)
            
            -- Total duration: 1800 + 3600 = 5400 seconds = 1.5 hours
            assert.equals(5400, stats.totalDuration)
            
            -- Average copper per hour: 24000 / 1.5 = 16000
            assert.is_true(math.abs(stats.avgCopperPerHour - 16000) < 1)
            
            -- Average XP per hour: 6000 / 1.5 = 4000
            assert.is_true(math.abs(stats.avgXPPerHour - 4000) < 1)
        end)
        
        it("handles sessions with zero duration", function()
            local sessions = {
                {
                    duration = 0,
                    currencyCopper = 10000,
                    grayCopper = 0,
                    potentialAHCopper = 0,
                    totalXP = 5000,
                    wasMaxLevel = false,
                },
                {
                    duration = 3600,
                    currencyCopper = 10000,
                    grayCopper = 0,
                    potentialAHCopper = 0,
                    totalXP = 3000,
                    wasMaxLevel = false,
                },
            }
            
            local stats = SessionData:CalculateTrendStatistics(sessions)
            
            -- Should not crash and should calculate correctly for valid sessions
            assert.equals(2, stats.totalSessions)
            assert.equals(3600, stats.totalDuration)
            assert.equals(20000, stats.totalCurrency)
            assert.equals(8000, stats.totalXP)
        end)
    end)

    describe("FilterSessions", function()
        local testSessions
        
        before_each(function()
            testSessions = {
                {
                    character = {
                        name = "Alice",
                        realm = "Realm1",
                        class = "Warrior",
                        race = "Human",
                    },
                    duration = 3600,
                },
                {
                    character = {
                        name = "Bob",
                        realm = "Realm1",
                        class = "Mage",
                        race = "Gnome",
                    },
                    duration = 1800,
                },
                {
                    character = {
                        name = "Charlie",
                        realm = "Realm2",
                        class = "Warrior",
                        race = "Orc",
                    },
                    duration = 7200,
                },
                {
                    character = {
                        name = "Diana",
                        realm = "Realm2",
                        class = "Priest",
                        race = "Undead",
                    },
                    duration = 5400,
                },
            }
        end)
        
        it("filters by character name", function()
            local filters = {
                text = "alice",
            }
            
            local filtered = SessionData:FilterSessions(testSessions, filters)
            
            assert.equals(1, #filtered)
            assert.equals("Alice", filtered[1].character.name)
        end)
        
        it("filters by class", function()
            local filters = {
                classes = {"Warrior"},
            }
            
            local filtered = SessionData:FilterSessions(testSessions, filters)
            
            assert.equals(2, #filtered)
            assert.equals("Alice", filtered[1].character.name)
            assert.equals("Charlie", filtered[2].character.name)
        end)
        
        it("filters by multiple classes", function()
            local filters = {
                classes = {"Warrior", "Mage"},
            }
            
            local filtered = SessionData:FilterSessions(testSessions, filters)
            
            assert.equals(3, #filtered)
        end)
        
        it("filters by race", function()
            local filters = {
                races = {"Human"},
            }
            
            local filtered = SessionData:FilterSessions(testSessions, filters)
            
            assert.equals(1, #filtered)
            assert.equals("Alice", filtered[1].character.name)
        end)
        
        it("filters by multiple races", function()
            local filters = {
                races = {"Orc", "Undead"},
            }
            
            local filtered = SessionData:FilterSessions(testSessions, filters)
            
            assert.equals(2, #filtered)
            assert.equals("Charlie", filtered[1].character.name)
            assert.equals("Diana", filtered[2].character.name)
        end)
        
        it("filters by realm", function()
            local filters = {
                realms = {"Realm1"},
            }
            
            local filtered = SessionData:FilterSessions(testSessions, filters)
            
            assert.equals(2, #filtered)
            assert.equals("Alice", filtered[1].character.name)
            assert.equals("Bob", filtered[2].character.name)
        end)
        
        it("filters by multiple realms", function()
            local filters = {
                realms = {"Realm1", "Realm2"},
            }
            
            local filtered = SessionData:FilterSessions(testSessions, filters)
            
            assert.equals(4, #filtered)
        end)
        
        it("filters by multiple criteria", function()
            local filters = {
                classes = {"Warrior"},
                realms = {"Realm1"},
            }
            
            local filtered = SessionData:FilterSessions(testSessions, filters)
            
            assert.equals(1, #filtered)
            assert.equals("Alice", filtered[1].character.name)
        end)
        
        it("returns empty when no sessions match", function()
            local filters = {
                classes = {"Druid"},
            }
            
            local filtered = SessionData:FilterSessions(testSessions, filters)
            
            assert.equals(0, #filtered)
        end)
        
        it("returns all sessions when all match", function()
            local filters = {
                classes = {"Warrior", "Mage", "Priest"},
            }
            
            local filtered = SessionData:FilterSessions(testSessions, filters)
            
            assert.equals(4, #filtered)
        end)
        
        it("returns all sessions when no filters provided", function()
            local filtered = SessionData:FilterSessions(testSessions, {})
            
            assert.equals(4, #filtered)
        end)
        
        it("returns all sessions when filters is nil", function()
            local filtered = SessionData:FilterSessions(testSessions, nil)
            
            assert.equals(4, #filtered)
        end)
        
        it("handles nil sessions", function()
            local filtered = SessionData:FilterSessions(nil, {classes = {"Warrior"}})
            
            assert.equals(0, #filtered)
        end)
        
        it("handles sessions with missing character data", function()
            local sessionsWithMissing = {
                {
                    character = {
                        name = "Alice",
                        class = "Warrior",
                    },
                },
                {
                    -- No character data
                },
                {
                    character = nil,
                },
            }
            
            local filters = {
                classes = {"Warrior"},
            }
            
            local filtered = SessionData:FilterSessions(sessionsWithMissing, filters)
            
            assert.equals(1, #filtered)
            assert.equals("Alice", filtered[1].character.name)
        end)
        
        it("performs case-insensitive text search", function()
            local filters = {
                text = "ALICE",
            }
            
            local filtered = SessionData:FilterSessions(testSessions, filters)
            
            assert.equals(1, #filtered)
            assert.equals("Alice", filtered[1].character.name)
        end)
        
        it("handles exact name match only", function()
            local filters = {
                text = "ali",  -- Partial match
            }
            
            local filtered = SessionData:FilterSessions(testSessions, filters)
            
            -- Should not match "Alice" because it's exact match only
            assert.equals(0, #filtered)
        end)
        
        it("combines all filter types", function()
            local filters = {
                text = "charlie",
                classes = {"Warrior"},
                races = {"Orc"},
                realms = {"Realm2"},
            }
            
            local filtered = SessionData:FilterSessions(testSessions, filters)
            
            assert.equals(1, #filtered)
            assert.equals("Charlie", filtered[1].character.name)
        end)
        
        it("returns empty when combined filters don't match", function()
            local filters = {
                classes = {"Warrior"},
                races = {"Gnome"},  -- No Warrior Gnomes in test data
            }
            
            local filtered = SessionData:FilterSessions(testSessions, filters)
            
            assert.equals(0, #filtered)
        end)
    end)
end)
