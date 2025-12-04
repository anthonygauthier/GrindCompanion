# GrindCompanion Test Suite

This directory contains the automated test suite for GrindCompanion's core logic modules.

## Overview

The test suite validates core business logic independently of the WoW game client, enabling:
- Continuous Integration/Continuous Deployment (CI/CD) testing
- Rapid development feedback
- Regression prevention
- Property-based testing for correctness guarantees

## Directory Structure

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
└── README.md              # This file
```

## Prerequisites

To run tests locally, you need:

1. **Lua 5.3 or higher**
   - Windows: Download from https://luabinaries.sourceforge.net/
   - Linux: `sudo apt-get install lua5.3`
   - macOS: `brew install lua`

2. **LuaRocks** (Lua package manager)
   - Windows: Download from https://luarocks.org/
   - Linux: `sudo apt-get install luarocks`
   - macOS: `brew install luarocks`

3. **Busted** (Testing framework)
   ```bash
   luarocks install busted
   ```

4. **lua-quickcheck** (Property-based testing)
   ```bash
   luarocks install lua-quickcheck
   ```

## Running Tests

### Run All Tests

From the project root directory:

```bash
busted tests/
```

### Run Specific Test File

```bash
busted tests/core/formatting/Formatter_spec.lua
```

### Run Tests with Verbose Output

```bash
busted tests/ --verbose
```

### Run Tests with Coverage

```bash
busted tests/ --coverage
```

### Run Tests in Watch Mode (auto-rerun on file changes)

```bash
busted tests/ --watch
```

## Writing Tests

### Unit Test Example

```lua
describe("Formatter", function()
    local Formatter = require("core.formatting.Formatter")
    
    describe("FormatCoin", function()
        it("formats zero copper correctly", function()
            assert.equals("0c", Formatter:FormatCoin(0))
        end)
        
        it("formats gold amounts correctly", function()
            assert.equals("1g 0s 0c", Formatter:FormatCoin(10000))
        end)
    end)
end)
```

### Property-Based Test Example

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

### Using TestAdapter

```lua
describe("GameAdapter Integration", function()
    local TestAdapter = require("tests.mocks.TestAdapter")
    local adapter
    
    before_each(function()
        adapter = TestAdapter:new()
    end)
    
    it("provides player info", function()
        adapter:SetPlayerLevel(58)
        local info = adapter:GetPlayerInfo()
        assert.equals(58, info.level)
    end)
end)
```

## Test Fixtures

Sample data is available in `tests/fixtures/`:

```lua
local SampleSessions = require("tests.fixtures.sample_sessions")
local SampleMobStats = require("tests.fixtures.sample_mob_stats")

-- Use in tests
local session = SampleSessions.levelingSession
local mobs = SampleMobStats.multipleMobs
```

## Test Helper Utilities

Common utilities are available in `test_helper.lua`:

```lua
local TestHelper = require("tests.test_helper")

-- Assertion helpers
TestHelper.assertTableEquals(expected, actual)
TestHelper.assertAlmostEquals(3.14159, 3.14, 0.01)
TestHelper.assertInRange(value, 0, 100)
TestHelper.assertContains("hello world", "world")

-- Data generation
local randomInt = TestHelper.randomInt(1, 100)
local randomFloat = TestHelper.randomFloat(0.0, 1.0)
local randomString = TestHelper.randomString(10)

-- Deep copy for test isolation
local copy = TestHelper.deepCopy(originalTable)
```

## Continuous Integration

Tests run automatically on every push and pull request via GitHub Actions. See `.github/workflows/test.yml` for configuration.

The CI pipeline:
1. Installs Lua and LuaRocks
2. Installs test dependencies (busted, lua-quickcheck)
3. Runs the full test suite
4. Reports results and prevents merge on failure

## Troubleshooting

### "module not found" errors

Make sure you're running tests from the project root directory, or adjust your `LUA_PATH`:

```bash
export LUA_PATH="./?.lua;./?/init.lua;;"
busted tests/
```

### Tests pass locally but fail in CI

Check that:
- All dependencies are listed in the CI workflow
- File paths use forward slashes (not backslashes)
- No WoW API calls exist in core logic modules

### Property tests are flaky

Property-based tests use random generation. If a test fails intermittently:
1. Note the failing seed/example from the output
2. Add that case as a specific unit test
3. Adjust the property or generator to handle the edge case

## Best Practices

1. **Test core logic only** - Don't test WoW API wrappers directly
2. **Use TestAdapter** - Mock all game dependencies
3. **Keep tests fast** - Unit tests should run in milliseconds
4. **Test edge cases** - Zero, negative, nil, empty collections
5. **Use descriptive names** - Test names should explain what's being tested
6. **One assertion per test** - Makes failures easier to diagnose
7. **Property tests for algorithms** - Use PBT for calculations and transformations
8. **Unit tests for examples** - Use unit tests for specific scenarios

## Contributing

When adding new features:
1. Write tests first (TDD approach)
2. Ensure all tests pass before committing
3. Maintain test coverage above 80%
4. Add property tests for new calculations
5. Update this README if adding new test patterns

## Resources

- [Busted Documentation](https://lunarmodules.github.io/busted/)
- [lua-quickcheck Documentation](https://github.com/luc-tielen/lua-quickcheck)
- [Property-Based Testing Guide](https://fsharpforfunandprofit.com/posts/property-based-testing/)
