-- Sample mob statistics data for testing

local SampleMobStats = {}

-- Single mob stats
SampleMobStats.singleMob = {
    ["Fel Orc"] = {
        kills = 50,
        currency = 25000,
        xp = 15000,
        loot = {
            [0] = 20,
            [1] = 25,
            [2] = 4,
            [3] = 1,
        },
        highestQualityDrop = {
            quality = 3,
            link = "|cff0070dd[Rare Sword]|r",
            quantity = 1,
        },
    },
}

-- Multiple mob stats
SampleMobStats.multipleMobs = {
    ["Fel Orc"] = {
        kills = 50,
        currency = 25000,
        xp = 15000,
        loot = {
            [0] = 20,
            [1] = 25,
            [2] = 4,
            [3] = 1,
        },
        highestQualityDrop = {
            quality = 3,
            link = "|cff0070dd[Rare Sword]|r",
            quantity = 1,
        },
    },
    ["Hellboar"] = {
        kills = 30,
        currency = 10000,
        xp = 8000,
        loot = {
            [0] = 15,
            [1] = 12,
            [2] = 2,
        },
        highestQualityDrop = {
            quality = 2,
            link = "|cff1eff00[Uncommon Hide]|r",
            quantity = 3,
        },
    },
    ["Ravager"] = {
        kills = 40,
        currency = 18000,
        xp = 12000,
        loot = {
            [0] = 18,
            [1] = 20,
            [2] = 1,
        },
        highestQualityDrop = {
            quality = 2,
            link = "|cff1eff00[Uncommon Claw]|r",
            quantity = 1,
        },
    },
    ["Felguard"] = {
        kills = 25,
        currency = 30000,
        xp = 18000,
        loot = {
            [0] = 10,
            [1] = 12,
            [2] = 2,
            [3] = 1,
        },
        highestQualityDrop = {
            quality = 3,
            link = "|cff0070dd[Rare Armor]|r",
            quantity = 1,
        },
    },
    ["Warp Stalker"] = {
        kills = 35,
        currency = 15000,
        xp = 10000,
        loot = {
            [0] = 12,
            [1] = 18,
            [2] = 4,
        },
        highestQualityDrop = {
            quality = 2,
            link = "|cff1eff00[Uncommon Meat]|r",
            quantity = 5,
        },
    },
}

-- Empty mob stats
SampleMobStats.empty = {}

-- Mob with no loot
SampleMobStats.noLoot = {
    ["Training Dummy"] = {
        kills = 10,
        currency = 0,
        xp = 0,
        loot = {},
        highestQualityDrop = nil,
    },
}

-- Mob with only gray items
SampleMobStats.grayOnly = {
    ["Boar"] = {
        kills = 20,
        currency = 5000,
        xp = 2000,
        loot = {
            [0] = 20,
        },
        highestQualityDrop = {
            quality = 0,
            link = "|cff9d9d9d[Boar Meat]|r",
            quantity = 10,
        },
    },
}

-- Mob with epic drop
SampleMobStats.epicDrop = {
    ["Rare Elite"] = {
        kills = 1,
        currency = 50000,
        xp = 25000,
        loot = {
            [0] = 1,
            [1] = 2,
            [2] = 1,
            [4] = 1,
        },
        highestQualityDrop = {
            quality = 4,
            link = "|cffa335ee[Epic Weapon]|r",
            quantity = 1,
        },
    },
}

-- Expected totals for multipleMobs
SampleMobStats.multiplemobsExpectedTotals = {
    totalKills = 180,
    totalCurrency = 98000,
    totalXP = 63000,
    totalItems = {
        [0] = 75,
        [1] = 87,
        [2] = 13,
        [3] = 2,
    },
    uniqueMobs = 5,
}

return SampleMobStats
