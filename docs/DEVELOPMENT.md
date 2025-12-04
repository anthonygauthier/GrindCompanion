# Development Guide

## Architecture

The addon is built with a three-layer testable architecture that separates concerns:

### Directory Structure

```
GrindCompanion/
├── core/                      # Pure Lua business logic (testable)
│   ├── formatting/           # String formatting (no WoW API)
│   │   └── Formatter.lua
│   ├── calculations/         # Math and statistics (no WoW API)
│   │   └── Statistics.lua
│   └── aggregation/          # Data processing (no WoW API)
│       ├── MobStats.lua
│       └── SessionData.lua
│
├── game/                      # WoW API-dependent code
│   └── adapters/             # WoW API wrappers
│       └── GameAdapter.lua
│
├── tests/                     # Automated test suite
│   ├── core/                 # Tests for core logic
│   ├── fixtures/             # Sample test data
│   └── mocks/                # Mock implementations
│       └── TestAdapter.lua
│
├── Core.lua          - Core framework and integration
├── Session.lua       - Session state management
├── Display.lua       - Main UI frame and windows
├── Analysis.lua      - Analytics and visualizations
├── Loot.lua          - Loot tracking
├── Combat.lua        - Combat log parsing
├── Commands.lua      - Slash command handlers
├── Events.lua        - Event registration and routing
├── Options.lua       - Configuration panel
├── Minimap.lua       - Minimap button
└── integrations/     - Addon integrations
    └── auctionator/  - Auctionator integration
```

### Architectural Layers

1. **Core Logic Layer** (`/core`): Pure Lua functions with no WoW API dependencies. Fully testable.
2. **Game Adapter Layer** (`/game/adapters`): Wraps WoW API calls, provides clean interfaces, handles errors.
3. **Integration Layer** (root files): Coordinates between layers, handles events, manages UI.

**Key Principle**: Core logic never calls WoW API directly. All game data flows through adapters.

For detailed refactoring patterns and migration examples, see [MIGRATION_GUIDE.md](MIGRATION_GUIDE.md).

---

## Data Structure

Session data is stored in `GrindCompanionDB.sessions` with the following structure:

```lua
{
  character = {
    name = "CharName",
    realm = "RealmName",
    startingLevel = 58,
    endingLevel = 59,
    race = "Human",
    class = "WARRIOR"
  },
  startedAt = 1234567890,        -- Unix timestamp
  endedAt = 1234571490,          -- Unix timestamp
  duration = 3600,               -- Seconds
  totalXP = 150000,
  killCount = 250,
  currencyCopper = 50000,        -- Direct coin drops
  grayCopper = 25000,            -- Gray item vendor value
  potentialAHCopper = 75000,     -- AH value (requires Auctionator)
  wasMaxLevel = false,           -- Whether player was max level
  loot = {
    [2] = 15,                    -- Green items
    [3] = 3,                     -- Blue items
    [4] = 1                      -- Purple items
  },
  lootedItems = {                -- Detailed item list
    { link = "itemLink", quality = 3, quantity = 2 },
    ...
  },
  zones = { "Burning Steppes", "Searing Gorge" },
  mobs = {
    ["Mob Name"] = {
      kills = 50,
      currency = 10000,          -- Includes gray items
      xp = 30000,
      loot = { [2] = 5, [3] = 1, [4] = 0 },
      itemCount = 6,
      highestQualityDrop = {
        quality = 3,
        link = "itemLink",
        quantity = 1
      }
    }
  },
  mobSummary = {                 -- Aggregate mob statistics
    totalKills = 250,
    totalCurrency = 50000,
    totalXP = 150000,
    totalItems = { [2] = 15, [3] = 3, [4] = 1 },
    uniqueMobs = 12
  }
}
```

---

## Technical Notes

### API Compatibility
- Built for WoW Classic Era (Interface 11502)
- Uses only Classic-compatible API calls
- No retail-specific features

### Performance
- Lightweight design with minimal memory footprint
- Efficient event handling (no polling)
- Display updates throttled to 1 second intervals
- Loot slot caching to reduce API calls

### Persistence
- All session data saved to SavedVariables (`GrindCompanionDB`)
- Auto-save on logout/reload
- Settings saved per account

### Event-Driven Architecture
- `COMBAT_LOG_EVENT_UNFILTERED` - Mob kill tracking
- `CHAT_MSG_COMBAT_XP_GAIN` - XP tracking
- `LOOT_OPENED` / `LOOT_CLOSED` - Loot tracking
- `ZONE_CHANGED_NEW_AREA` - Zone tracking
- `PLAYER_LOGOUT` - Auto-save

### Combat Log Integration
- Parses `UNIT_DIED` and `PARTY_KILL` events
- Extracts mob names from combat log
- Handles max-level kill counting

### Loot Slot Caching
- Pre-caches loot slots on `LOOT_OPENED`
- Ensures accurate tracking with fast looting
- Handles item quality detection

### Dynamic UI
- Automatically adapts between leveling and max-level modes
- Hides/shows rows based on player level
- Respects user visibility preferences

### Graph Rendering
- Custom line graph implementation using texture segments
- Stacked bar charts for loot quality
- Clickable data points with hover tooltips
- Automatic scaling and axis formatting

---

## Contributing

Contributions are welcome! Please ensure:

### Code Style
- Follow existing conventions (modular architecture, clear function names)
- Document functions with clear comments
- Use descriptive variable names
- Maintain consistent indentation (tabs)

### Compatibility
- Maintain compatibility with WoW Classic Era API (Interface 11502)
- No external dependencies beyond optional Auctionator
- Test on actual Classic Era client

### UI Guidelines
- Use Blizzard's template patterns (PortraitFrameTemplate, InsetFrameTemplate3, etc.)
- Follow WoW's standard color schemes
- Maintain consistent visual style
- Ensure accessibility (readable fonts, clear contrast)

### Performance
- Event handling must be efficient
- Avoid polling or frequent updates
- Test with large session databases
- Profile memory usage

### Testing
- Test all features thoroughly
- Verify session saving/loading
- Check edge cases (max level, no loot, etc.)
- Test with and without Auctionator
- Run automated test suite: `busted tests/`
- Ensure all tests pass before submitting PR
- Follow testable architecture patterns (see [MIGRATION_GUIDE.md](MIGRATION_GUIDE.md))
- Write tests for new core logic modules

### Pull Requests
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit PR with clear description

---

## Development Setup

### Prerequisites
- World of Warcraft Classic Era client
- Text editor or IDE with Lua support
- Git for version control

### Local Development
1. Clone repository to AddOns folder:
   ```
   cd "World of Warcraft\_classic_era_\Interface\AddOns"
   git clone https://github.com/anthonygauthier/GrindCompanion.git
   ```

2. Make changes to Lua files

3. Test in-game:
   - Launch WoW Classic Era
   - Type `/reload` to reload UI
   - Test your changes

4. Check for errors:
   - Install BugSack addon to catch Lua errors
   - Monitor chat for error messages

### Debugging
- Use `print()` for debug output
- Check `/gc debug` mode for pricing issues
- Use BugSack or similar for error tracking
- Test with SavedVariables disabled for clean state

---

## Release Process

Releases are fully automated via GitHub Actions when commits are pushed to the `main` branch:

1. Commit messages are analyzed to determine version bump
2. Version is updated in `GrindCompanion.toc` and `package.json`
3. `CHANGELOG.md` is generated/updated
4. Addon is packaged as a zip file
5. Git tag and GitHub release are created
6. Release assets are uploaded to GitHub
7. Addon is automatically uploaded to CurseForge

See [CONTRIBUTING.md](../CONTRIBUTING.md) for commit message conventions.

---

## Testing

GrindCompanion includes an automated test suite for core business logic. Tests run independently of the WoW client, enabling rapid development and continuous integration.

### Test Infrastructure

The test suite is located in the `tests/` directory:

```
tests/
├── core/                    # Tests for core logic modules
│   ├── formatting/         # Formatter module tests
│   ├── calculations/       # Statistics module tests
│   └── aggregation/        # MobStats and SessionData tests
├── fixtures/               # Sample test data
│   ├── sample_sessions.lua
│   └── sample_mob_stats.lua
├── mocks/                  # Mock implementations
│   └── TestAdapter.lua     # Mock GameAdapter for testing
├── test_helper.lua         # Common test utilities
└── README.md              # Detailed testing documentation
```

### Running Tests Locally

**Prerequisites:**
- Lua 5.3+ (`lua -v` to check)
- LuaRocks (`luarocks --version` to check)
- Busted testing framework (`luarocks install busted`)
- lua-quickcheck for property-based testing (`luarocks install lua-quickcheck`)

**Run all tests:**
```bash
busted tests/
```

**Run specific test file:**
```bash
busted tests/core/formatting/Formatter_spec.lua
```

**Run with verbose output:**
```bash
busted tests/ --verbose
```

**Run with coverage:**
```bash
busted tests/ --coverage
```

See `tests/README.md` for detailed testing documentation, examples, and best practices.

### Continuous Integration

Tests run automatically on every push and pull request via GitHub Actions:
- Installs Lua and test dependencies
- Runs full test suite
- Reports coverage
- Prevents merge on test failure

View test status: [![Tests](https://github.com/anthonygauthier/GrindCompanion/workflows/Tests/badge.svg)](https://github.com/anthonygauthier/GrindCompanion/actions)

### Writing Tests

#### Unit Test Example

Test specific examples and edge cases:

```lua
describe("Formatter", function()
    local Formatter = require("core.formatting.Formatter")
    
    describe("FormatCoin", function()
        it("formats zero copper correctly", function()
            assert.equals("0c", Formatter:FormatCoin(0))
        end)
        
        it("formats gold amounts", function()
            assert.equals("1g 0s 0c", Formatter:FormatCoin(10000))
        end)
        
        it("handles negative values", function()
            assert.equals("0c", Formatter:FormatCoin(-100))
        end)
    end)
end)
```

#### Property-Based Test Example

Test universal properties across many random inputs:

```lua
describe("Statistics", function()
    local Statistics = require("core.calculations.Statistics")
    local lqc = require("lua-quickcheck")
    
    -- **Feature: testable-architecture, Property 7: Rate calculations are correct**
    it("calculates rates correctly for any positive inputs", function()
        local prop = lqc.property(
            lqc.positive_number(),
            lqc.positive_number(),
            function(amount, duration)
                local rate = Statistics:CalculatePerHour(amount, duration)
                local expected = (amount / duration) * 3600
                return math.abs(rate - expected) < 0.01
            end
        )
        lqc.check(prop, { numtests = 100 })
    end)
end)
```

**Note**: Property-based tests must include a comment tag referencing the design document property.

#### Using TestAdapter

Mock WoW API calls for testing:

```lua
describe("Core Logic", function()
    local TestAdapter = require("tests.mocks.TestAdapter")
    local adapter
    
    before_each(function()
        adapter = TestAdapter:new()
        adapter:SetPlayerLevel(58)
        adapter:SetCurrentTime(1000)
    end)
    
    it("uses adapter data correctly", function()
        local info = adapter:GetPlayerInfo()
        assert.equals(58, info.level)
        
        local time = adapter:GetCurrentTime()
        assert.equals(1000, time)
    end)
end)
```

### Test-Driven Development

When adding new features:
1. **Write tests first** - Define expected behavior with tests
2. **Implement the feature** - Write code to make tests pass
3. **Run tests** - Verify correctness (`busted tests/`)
4. **Refactor** - Improve code with confidence (tests catch regressions)

### Adding New Testable Features

Follow this workflow for new features:

1. **Design**: Identify core logic vs. WoW API dependencies
2. **Create core module**: Pure Lua in `/core` directory
3. **Write tests**: Unit tests and property tests
4. **Implement**: Make tests pass
5. **Add adapter methods**: If WoW API data needed
6. **Integrate**: Update main files to use new module
7. **Update TOC**: Add new files in correct load order

**Example workflow**:
```bash
# 1. Create core module
touch core/calculations/NewFeature.lua

# 2. Write tests
touch tests/core/calculations/NewFeature_spec.lua

# 3. Run tests (they should fail)
busted tests/core/calculations/NewFeature_spec.lua

# 4. Implement feature (make tests pass)
# ... edit NewFeature.lua ...

# 5. Run tests again (they should pass)
busted tests/core/calculations/NewFeature_spec.lua

# 6. Update GrindCompanion.toc
# Add: core\calculations\NewFeature.lua
```

For detailed refactoring patterns, before/after examples, and best practices, see [MIGRATION_GUIDE.md](MIGRATION_GUIDE.md).

---

## Refactoring Patterns

The codebase follows specific patterns to maintain testability. When modifying or adding code, follow these patterns:

### Pattern 1: Extract Pure Calculations

Move calculation logic to `/core` modules with no WoW API dependencies:

```lua
-- BAD: Mixed concerns
function GrindCompanion:CalculateRate(amount)
    local elapsed = GetTime() - self.startTime  -- WoW API call
    return (amount / elapsed) * 3600
end

-- GOOD: Separated concerns
-- In core/calculations/Statistics.lua
function Statistics:CalculatePerHour(amount, durationSeconds)
    if durationSeconds == 0 then return 0 end
    return (amount / durationSeconds) * 3600
end

-- In Core.lua
function GrindCompanion:CalculateRate(amount)
    local elapsed = self.adapter:GetCurrentTime() - self.startTime
    return Statistics:CalculatePerHour(amount, elapsed)
end
```

### Pattern 2: Use Game Adapter for WoW API

All WoW API calls go through the GameAdapter:

```lua
-- BAD: Direct WoW API call
local level = UnitLevel("player")

-- GOOD: Through adapter
local level = self.adapter:GetPlayerLevel()
```

### Pattern 3: Pass State as Parameters

Core logic receives state as parameters, doesn't access globals:

```lua
-- BAD: Accesses self
function CoreModule:Calculate()
    return self.value * 2
end

-- GOOD: Receives parameters
function CoreModule:Calculate(value)
    return value * 2
end
```

### Pattern 4: Return New State

Prefer returning new state over mutation:

```lua
-- ACCEPTABLE: Documented mutation
function MobStats:RecordKill(mobName, xp, mobStatsTable)
    -- Modifies mobStatsTable in place
    mobStatsTable[mobName] = mobStatsTable[mobName] or {}
    mobStatsTable[mobName].xp = (mobStatsTable[mobName].xp or 0) + xp
    return mobStatsTable
end
```

For comprehensive examples and detailed patterns, see [MIGRATION_GUIDE.md](MIGRATION_GUIDE.md).

---

## Auctionator Integration

### API Detection
```lua
if Auctionator and Auctionator.API and Auctionator.API.v1 then
    -- Auctionator is available
end
```

### Price Lookup
```lua
local price = Auctionator.API.v1.GetAuctionPriceByItemLink("GrindCompanion", itemLink)
```

### Item Filtering
Tracks prices for:
- Quality 2+ (uncommon, rare, epic)
- Armor class 4, subclass 1 (cloth armor)
- Trade goods class 7, subclass 5 (cloth trade goods)

---

## Future Enhancements

Potential features for future versions:

- Session deletion from UI
- Export to CSV/JSON
- Comparison mode (side-by-side sessions)
- Custom notes per session
- Alerts for rare drops
- Integration with other addons
- Localization support
- Retail/TBC/Wrath support

Contributions welcome for any of these features!
