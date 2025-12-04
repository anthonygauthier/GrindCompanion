# Design Document

## Overview

This design establishes a testable architecture for the GrindCompanion WoW addon by separating pure business logic from WoW API dependencies. The refactoring introduces a three-layer architecture: core logic (pure Lua), game adapters (WoW API wrappers), and tests. This enables automated testing in CI/CD pipelines using standard Lua interpreters without requiring a WoW game client.

## Architecture

### Directory Structure

```
/core                    # Pure Lua business logic (no WoW API calls)
  /formatting           # String formatting functions
  /calculations         # Mathematical and statistical calculations
  /aggregation          # Data aggregation and transformation
  /models               # Data structures and types

/game                    # WoW API-dependent code
  /adapters             # WoW API wrappers
  /ui                   # Frame and UI components
  /events               # Event handlers

/tests                   # Test suite
  /core                 # Tests for core logic
  /fixtures             # Test data and helpers
  /mocks                # Mock implementations of game adapters

/                        # Root level integration files
  Core.lua              # Main addon initialization (updated)
  GrindCompanion.toc    # Addon manifest (updated with new file paths)
```

### Architectural Principles

1. **Dependency Inversion**: Core logic depends on abstractions (interfaces), not concrete WoW API implementations
2. **Pure Functions**: Core logic functions are stateless and deterministic where possible
3. **Data Flow**: Game adapters fetch data → Core logic processes data → Game adapters present results
4. **Testability**: All core logic can be tested with simple input/output verification

## Components and Interfaces

### Core Logic Modules

#### Formatting Module (`/core/formatting/Formatter.lua`)

Handles all string formatting without WoW API dependencies.

```lua
local Formatter = {}

-- Constants (no WoW API dependencies)
Formatter.COPPER_PER_GOLD = 10000
Formatter.COPPER_PER_SILVER = 100

function Formatter:FormatCoin(copper, options)
    -- Pure calculation, returns string
end

function Formatter:FormatTime(seconds)
    -- Pure calculation, returns string
end

function Formatter:FormatQualitySummary(qualityCounts, colorCodes)
    -- Accepts color codes as parameter
end

function Formatter:FormatNumber(num)
    -- Pure formatting
end

return Formatter
```

#### Calculations Module (`/core/calculations/Statistics.lua`)

Performs statistical calculations on session data.

```lua
local Statistics = {}

function Statistics:CalculatePerHour(amount, durationSeconds)
    -- Returns amount per hour
end

function Statistics:CalculateTimeToLevel(currentXP, maxXP, totalXPGained, elapsedSeconds)
    -- Returns estimated seconds to level
end

function Statistics:CalculateKillsRemaining(currentXP, maxXP, totalXPGained, totalKills)
    -- Returns estimated kills remaining
end

function Statistics:CalculateElapsedTime(startTime, endTime, isTracking)
    -- Returns elapsed seconds
end

return Statistics
```

#### Aggregation Module (`/core/aggregation/MobStats.lua`)

Aggregates and processes mob statistics.

```lua
local MobStats = {}

function MobStats:RecordKill(mobName, xpAmount, currencyAmount, mobStatsTable)
    -- Updates mobStatsTable in place, returns updated table
end

function MobStats:CalculateTotals(mobStatsTable)
    -- Returns summary: totalKills, totalXP, totalCurrency, totalItems
end

function MobStats:UpdateHighestQualityDrop(mobStats, quality, link, quantity)
    -- Updates highest quality drop if new drop is better
end

function MobStats:CopyQualityCounts(source, target)
    -- Efficiently copies quality count tables
end

return MobStats
```

#### Session Module (`/core/aggregation/SessionData.lua`)

Processes session snapshots and trend calculations.

```lua
local SessionData = {}

function SessionData:BuildSnapshot(sessionState, characterInfo, zoneList, mobStats, lootedItems)
    -- Builds session snapshot from provided data
    -- Returns snapshot table
end

function SessionData:CalculateTrendStatistics(sessions)
    -- Calculates aggregate statistics across multiple sessions
    -- Returns trends table
end

function SessionData:FilterSessions(sessions, filters)
    -- Filters sessions by character, realm, class, race, etc.
    -- Returns filtered session array
end

return SessionData
```

### Game Adapter Layer

#### GameAdapter (`/game/adapters/GameAdapter.lua`)

Wraps all WoW API calls and provides clean interfaces to core logic.

```lua
local GameAdapter = {}

-- Time functions
function GameAdapter:GetCurrentTime()
    return GetTime()
end

function GameAdapter:GetTimestamp()
    return time()
end

-- Player functions
function GameAdapter:GetPlayerLevel()
    return UnitLevel("player") or 0
end

function GameAdapter:GetPlayerMaxLevel()
    if type(GetMaxPlayerLevel) == "function" then
        local ok, level = pcall(GetMaxPlayerLevel)
        if ok and level then return level end
    end
    return MAX_PLAYER_LEVEL or 60
end

function GameAdapter:GetPlayerName()
    return UnitName("player") or "Unknown"
end

function GameAdapter:GetPlayerInfo()
    return {
        name = UnitName("player") or "Unknown",
        realm = GetRealmName and GetRealmName() or nil,
        level = UnitLevel("player") or 0,
        race = select(2, UnitRace("player")),
        class = select(2, UnitClass("player")),
        gender = UnitSex("player"),
        currentXP = UnitXP("player") or 0,
        maxXP = UnitXPMax("player") or 1,
    }
end

-- Item functions
function GameAdapter:GetItemInfo(itemLink)
    local name, link, quality, _, _, _, _, _, _, texture, sellPrice = GetItemInfo(itemLink)
    return {
        name = name,
        link = link,
        quality = quality,
        texture = texture,
        sellPrice = sellPrice,
    }
end

function GameAdapter:GetItemQuality(itemLink)
    return select(3, GetItemInfoInstant(itemLink)) or select(3, GetItemInfo(itemLink))
end

-- Zone functions
function GameAdapter:GetCurrentZone()
    local zoneName = GetZoneText() or GetRealZoneText() or "Unknown"
    return zoneName ~= "" and zoneName or "Unknown"
end

-- Color functions
function GameAdapter:GetQualityColor(quality)
    if ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[quality] then
        return ITEM_QUALITY_COLORS[quality].hex
    end
    -- Fallback colors
    local fallbacks = {
        [2] = "|cff1eff00",
        [3] = "|cff0070dd",
        [4] = "|cffa335ee",
    }
    return fallbacks[quality] or "|cffffffff"
end

-- Chat functions
function GameAdapter:PrintMessage(text)
    DEFAULT_CHAT_FRAME:AddMessage(string.format("|cff33ff99GrindCompanion:|r %s", text))
end

return GameAdapter
```

#### TestAdapter (`/tests/mocks/TestAdapter.lua`)

Mock implementation for testing.

```lua
local TestAdapter = {}

function TestAdapter:new()
    local instance = {
        currentTime = 0,
        playerInfo = {
            name = "TestPlayer",
            realm = "TestRealm",
            level = 60,
            race = "Human",
            class = "Warrior",
            gender = 2,
            currentXP = 0,
            maxXP = 1000,
        },
        itemCache = {},
    }
    setmetatable(instance, { __index = TestAdapter })
    return instance
end

function TestAdapter:GetCurrentTime()
    return self.currentTime
end

function TestAdapter:SetCurrentTime(time)
    self.currentTime = time
end

function TestAdapter:GetPlayerInfo()
    return self.playerInfo
end

function TestAdapter:SetPlayerInfo(info)
    for k, v in pairs(info) do
        self.playerInfo[k] = v
    end
end

-- ... other mock methods

return TestAdapter
```

## Data Models

### Session State

```lua
{
    startTime = number,           -- Game time when session started
    stopTime = number or nil,     -- Game time when session stopped
    isTracking = boolean,         -- Whether currently tracking
    totalXP = number,             -- Total XP gained
    killCount = number,           -- Total kills
    currencyCopper = number,      -- Currency looted
    grayCopper = number,          -- Gray item value
    potentialAHCopper = number,   -- AH value estimate
    lootQualityCount = table,     -- {[quality] = count}
    mobStats = table,             -- {[mobName] = stats}
    sessionZones = array,         -- List of zone names
    lootedItems = array,          -- List of looted items
}
```

### Mob Statistics

```lua
{
    kills = number,
    currency = number,
    xp = number,
    loot = {[quality] = count},
    highestQualityDrop = {
        quality = number,
        link = string,
        quantity = number,
    } or nil,
}
```

### Session Snapshot

```lua
{
    character = {
        name = string,
        realm = string,
        startingLevel = number,
        endingLevel = number,
        race = string,
        class = string,
        gender = number,
    },
    startedAt = number,           -- Unix timestamp
    endedAt = number,             -- Unix timestamp
    duration = number,            -- Seconds
    totalXP = number,
    killCount = number,
    currencyCopper = number,
    grayCopper = number,
    potentialAHCopper = number,
    loot = {[quality] = count},
    lootedItems = array,
    wasMaxLevel = boolean,
    zones = array,
    mobs = {[mobName] = mobStats},
    mobSummary = {
        totalKills = number,
        totalCurrency = number,
        totalXP = number,
        totalItems = {[quality] = count},
        uniqueMobs = number,
    },
}
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*


### Property Reflection

Looking at the testable properties identified in prework, several can be consolidated:

- Properties 5.2 and 5.3 (XP per hour and copper per hour) are both rate calculations with the same formula - these can be combined into a single "rate calculation" property
- Properties 6.2 and 6.3 (aggregating mob stats and calculating totals) describe the same operation - these should be one property
- Properties 4.1, 4.2, and 4.3 (formatting functions) all test that formatters return non-empty strings, but each has unique validation logic, so they should remain separate

After reflection, we have 11 unique testable properties.

### Testable Properties

Property 1: Game adapter returns structured data
*For any* WoW API response, when the game adapter transforms it, the result should be a simple Lua table with expected fields and no function references
**Validates: Requirements 2.3**

Property 2: Game adapter handles errors gracefully
*For any* error condition in WoW API calls, the game adapter should return valid default values without raising errors
**Validates: Requirements 2.5**

Property 3: Coin formatting produces valid output
*For any* non-negative copper amount, FormatCoin should return a non-empty string containing 'g', 's', or 'c' suffixes
**Validates: Requirements 4.1**

Property 4: Time formatting produces valid output
*For any* non-negative seconds value, FormatTime should return a non-empty string containing 'h', 'm', or 's' suffixes
**Validates: Requirements 4.2**

Property 5: Quality summary formatting produces valid output
*For any* quality count table, FormatQualitySummary should return a non-empty string containing quality labels
**Validates: Requirements 4.3**

Property 6: Elapsed time calculation is correct
*For any* start time and end time where end >= start, CalculateElapsedTime should return end - start
**Validates: Requirements 5.1**

Property 7: Rate calculations are correct
*For any* positive amount and positive duration, the per-hour rate should equal (amount / duration) * 3600
**Validates: Requirements 5.2, 5.3**

Property 8: Kills remaining calculation is correct
*For any* valid XP values where currentXP < maxXP and totalXPGained > 0 and totalKills > 0, CalculateKillsRemaining should return a positive number
**Validates: Requirements 5.4**

Property 9: Recording mob kills updates stats correctly
*For any* mob kill with valid parameters, RecordKill should increment the kill count and add XP/currency to the mob's stats
**Validates: Requirements 6.1**

Property 10: Mob aggregation sums correctly
*For any* collection of mob statistics, CalculateTotals should return sums that equal the sum of individual mob values
**Validates: Requirements 6.2, 6.3**

Property 11: Highest quality drop tracking is correct
*For any* sequence of drops for a mob, the highest quality drop should have the maximum quality value among all drops
**Validates: Requirements 6.4**

## Error Handling

### Core Logic Error Handling

Core logic modules should handle edge cases gracefully:

1. **Division by Zero**: All rate calculations check for zero duration and return 0 or "N/A"
2. **Negative Values**: Formatting functions use `math.max(0, value)` to prevent negative outputs
3. **Nil Values**: All functions provide default values for nil parameters
4. **Empty Tables**: Aggregation functions handle empty collections and return zero values

### Game Adapter Error Handling

The game adapter wraps all WoW API calls in pcall to catch errors:

```lua
function GameAdapter:GetPlayerLevel()
    local ok, level = pcall(UnitLevel, "player")
    if ok and level then
        return level
    end
    return 0  -- Safe default
end
```

### Test Adapter Behavior

The test adapter provides predictable behavior for testing:

1. Returns configured values from its internal state
2. Never raises errors
3. Allows state manipulation for test scenarios

## Testing Strategy

### Testing Framework

We will use **busted** as the Lua testing framework. Busted provides:
- BDD-style test syntax (describe/it blocks)
- Rich assertion library
- Mocking capabilities
- Test coverage reporting
- CI/CD integration

Installation: `luarocks install busted`

### Unit Testing Approach

Unit tests verify specific examples and edge cases:

```lua
describe("Formatter", function()
    local Formatter = require("core.formatting.Formatter")
    
    it("formats zero copper correctly", function()
        assert.equals("0c", Formatter:FormatCoin(0))
    end)
    
    it("formats gold amounts correctly", function()
        assert.equals("1g 0s 0c", Formatter:FormatCoin(10000))
    end)
    
    it("handles negative values", function()
        assert.equals("0c", Formatter:FormatCoin(-100))
    end)
end)
```

### Property-Based Testing Approach

We will use **lua-quickcheck** for property-based testing. This library generates random inputs to verify properties hold across many test cases.

Installation: `luarocks install lua-quickcheck`

Configuration: Each property test should run a minimum of 100 iterations to ensure thorough coverage.

Each property-based test must be tagged with a comment explicitly referencing the correctness property from this design document using this exact format: `**Feature: testable-architecture, Property {number}: {property_text}**`

Example property test:

```lua
describe("Statistics", function()
    local Statistics = require("core.calculations.Statistics")
    local lqc = require("lua-quickcheck")
    local property = lqc.property
    local check = lqc.check
    
    -- **Feature: testable-architecture, Property 7: Rate calculations are correct**
    it("calculates rates correctly for any positive inputs", function()
        local prop = property(
            lqc.positive_number(),
            lqc.positive_number(),
            function(amount, duration)
                local rate = Statistics:CalculatePerHour(amount, duration)
                local expected = (amount / duration) * 3600
                return math.abs(rate - expected) < 0.01
            end
        )
        check(prop, { numtests = 100 })
    end)
end)
```

### Test Organization

```
/tests
  /core
    /formatting
      Formatter_spec.lua
    /calculations
      Statistics_spec.lua
    /aggregation
      MobStats_spec.lua
      SessionData_spec.lua
  /fixtures
    sample_sessions.lua
    sample_mob_stats.lua
  /mocks
    TestAdapter.lua
  test_helper.lua
```

### CI/CD Integration

GitHub Actions workflow (`.github/workflows/test.yml`):

```yaml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Install Lua
        run: sudo apt-get install -y lua5.3 luarocks
      - name: Install dependencies
        run: |
          luarocks install busted
          luarocks install lua-quickcheck
      - name: Run tests
        run: busted tests/
```

### Testing Checklist

For each refactored module:
- [ ] Unit tests for edge cases (zero, negative, nil, empty)
- [ ] Property tests for core calculations
- [ ] Integration test with TestAdapter
- [ ] Verify no WoW API calls in core logic
- [ ] Test passes in CI environment

## Migration Strategy

### Phase 1: Extract Core Formatting (Low Risk)

1. Create `/core/formatting/Formatter.lua`
2. Move formatting functions (FormatCoin, FormatTime, FormatQualitySummary)
3. Update Core.lua to use Formatter module
4. Write tests for formatting functions
5. Verify addon still works in-game

### Phase 2: Extract Calculations (Medium Risk)

1. Create `/core/calculations/Statistics.lua`
2. Move calculation functions (CalculatePerHour, CalculateTimeToLevel, etc.)
3. Update Session.lua to use Statistics module
4. Write tests for calculations
5. Verify session tracking works correctly

### Phase 3: Extract Aggregation Logic (Medium Risk)

1. Create `/core/aggregation/MobStats.lua` and `/core/aggregation/SessionData.lua`
2. Move mob tracking and session snapshot logic
3. Update Combat.lua and Session.lua to use new modules
4. Write tests for aggregation
5. Verify mob tracking and session history work correctly

### Phase 4: Create Game Adapter (High Risk)

1. Create `/game/adapters/GameAdapter.lua`
2. Wrap all WoW API calls
3. Update all modules to use GameAdapter
4. Create TestAdapter for testing
5. Comprehensive testing of all features

### Phase 5: CI/CD Integration

1. Set up GitHub Actions workflow
2. Configure test execution
3. Add test status badges to README
4. Document testing procedures

### Refactoring Pattern Example

**Before** (mixed concerns):
```lua
function GrindCompanion:FormatCoin(copper, options)
    options = options or {}
    copper = math.floor(copper or 0)
    local gold = math.floor(copper / self.COPPER_PER_GOLD)
    -- ... calculation logic ...
    
    -- WoW API dependency for colors
    table.insert(segments, string.format("%s%dg|r", self.COIN_COLORS.gold, gold))
    return table.concat(segments, separator)
end
```

**After** (separated):
```lua
-- Core logic (pure Lua)
function Formatter:FormatCoin(copper, options, colorCodes)
    options = options or {}
    colorCodes = colorCodes or self.DEFAULT_COLORS
    copper = math.floor(copper or 0)
    local gold = math.floor(copper / self.COPPER_PER_GOLD)
    -- ... calculation logic ...
    
    table.insert(segments, string.format("%s%dg|r", colorCodes.gold, gold))
    return table.concat(segments, separator)
end

-- Game integration
function GrindCompanion:FormatCoin(copper, options)
    local colorCodes = {
        gold = self.COIN_COLORS.gold,
        silver = self.COIN_COLORS.silver,
        copper = self.COIN_COLORS.copper,
    }
    return Formatter:FormatCoin(copper, options, colorCodes)
end
```

## Implementation Notes

### Lua Module System

Use standard Lua module pattern:

```lua
-- Module definition
local ModuleName = {}

function ModuleName:FunctionName(params)
    -- implementation
end

return ModuleName

-- Usage
local ModuleName = require("path.to.ModuleName")
ModuleName:FunctionName(args)
```

### TOC File Updates

Update `GrindCompanion.toc` to include new files in correct load order:

```
# Core logic (load first, no dependencies)
core\formatting\Formatter.lua
core\calculations\Statistics.lua
core\aggregation\MobStats.lua
core\aggregation\SessionData.lua

# Game adapters (load second, depends on WoW API)
game\adapters\GameAdapter.lua

# Existing files (load last, depends on core and adapters)
Core.lua
Session.lua
Combat.lua
...
```

### Backward Compatibility

Maintain existing public API during migration:

```lua
-- Wrapper functions maintain compatibility
function GrindCompanion:FormatCoin(copper, options)
    return Formatter:FormatCoin(copper, options, self:GetColorCodes())
end
```

This allows gradual migration without breaking existing code.

## Success Criteria

The refactoring is successful when:

1. All core logic modules have zero WoW API dependencies
2. Test suite runs successfully without WoW client
3. All tests pass in CI/CD pipeline
4. Addon functions identically in-game before and after refactoring
5. Code coverage exceeds 80% for core logic modules
6. New features can be developed with tests-first approach
