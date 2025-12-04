-- Sample session data for testing

local SampleSessions = {}

-- Basic leveling session
SampleSessions.levelingSession = {
    character = {
        name = "TestWarrior",
        realm = "TestRealm",
        startingLevel = 58,
        endingLevel = 59,
        race = "Human",
        class = "Warrior",
        gender = 2,
    },
    startedAt = 1638360000,
    endedAt = 1638363600,
    duration = 3600, -- 1 hour
    totalXP = 50000,
    killCount = 150,
    currencyCopper = 125000,
    grayCopper = 25000,
    potentialAHCopper = 100000,
    loot = {
        [0] = 50, -- Poor
        [1] = 80, -- Common
        [2] = 15, -- Uncommon
        [3] = 3,  -- Rare
    },
    lootedItems = {},
    wasMaxLevel = false,
    zones = {"Hellfire Peninsula"},
    mobs = {},
    mobSummary = {
        totalKills = 150,
        totalCurrency = 125000,
        totalXP = 50000,
        totalItems = {
            [0] = 50,
            [1] = 80,
            [2] = 15,
            [3] = 3,
        },
        uniqueMobs = 5,
    },
}

-- Max level farming session
SampleSessions.maxLevelSession = {
    character = {
        name = "TestMage",
        realm = "TestRealm",
        startingLevel = 60,
        endingLevel = 60,
        race = "Gnome",
        class = "Mage",
        gender = 3,
    },
    startedAt = 1638370000,
    endedAt = 1638373600,
    duration = 3600, -- 1 hour
    totalXP = 0,
    killCount = 200,
    currencyCopper = 250000,
    grayCopper = 50000,
    potentialAHCopper = 200000,
    loot = {
        [0] = 100, -- Poor
        [1] = 75,  -- Common
        [2] = 20,  -- Uncommon
        [3] = 4,   -- Rare
        [4] = 1,   -- Epic
    },
    lootedItems = {},
    wasMaxLevel = true,
    zones = {"Stratholme"},
    mobs = {},
    mobSummary = {
        totalKills = 200,
        totalCurrency = 250000,
        totalXP = 0,
        totalItems = {
            [0] = 100,
            [1] = 75,
            [2] = 20,
            [3] = 4,
            [4] = 1,
        },
        uniqueMobs = 8,
    },
}

-- Short session
SampleSessions.shortSession = {
    character = {
        name = "TestRogue",
        realm = "TestRealm",
        startingLevel = 45,
        endingLevel = 45,
        race = "Undead",
        class = "Rogue",
        gender = 2,
    },
    startedAt = 1638380000,
    endedAt = 1638380900,
    duration = 900, -- 15 minutes
    totalXP = 5000,
    killCount = 25,
    currencyCopper = 15000,
    grayCopper = 5000,
    potentialAHCopper = 10000,
    loot = {
        [0] = 10,
        [1] = 12,
        [2] = 2,
    },
    lootedItems = {},
    wasMaxLevel = false,
    zones = {"Tanaris"},
    mobs = {},
    mobSummary = {
        totalKills = 25,
        totalCurrency = 15000,
        totalXP = 5000,
        totalItems = {
            [0] = 10,
            [1] = 12,
            [2] = 2,
        },
        uniqueMobs = 3,
    },
}

-- Multi-zone session
SampleSessions.multiZoneSession = {
    character = {
        name = "TestPaladin",
        realm = "TestRealm",
        startingLevel = 55,
        endingLevel = 56,
        race = "Dwarf",
        class = "Paladin",
        gender = 2,
    },
    startedAt = 1638390000,
    endedAt = 1638397200,
    duration = 7200, -- 2 hours
    totalXP = 80000,
    killCount = 300,
    currencyCopper = 200000,
    grayCopper = 40000,
    potentialAHCopper = 160000,
    loot = {
        [0] = 120,
        [1] = 150,
        [2] = 25,
        [3] = 5,
    },
    lootedItems = {},
    wasMaxLevel = false,
    zones = {"Western Plaguelands", "Eastern Plaguelands"},
    mobs = {},
    mobSummary = {
        totalKills = 300,
        totalCurrency = 200000,
        totalXP = 80000,
        totalItems = {
            [0] = 120,
            [1] = 150,
            [2] = 25,
            [3] = 5,
        },
        uniqueMobs = 12,
    },
}

-- Collection of all sample sessions
SampleSessions.all = {
    SampleSessions.levelingSession,
    SampleSessions.maxLevelSession,
    SampleSessions.shortSession,
    SampleSessions.multiZoneSession,
}

return SampleSessions
