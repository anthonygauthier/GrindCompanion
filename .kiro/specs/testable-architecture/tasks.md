# Implementation Plan

- [x] 1. Set up testing infrastructure





  - Create directory structure for tests
  - Set up test helper utilities
  - Create TestAdapter mock implementation
  - Document how to run tests locally
  - _Requirements: 3.3, 3.4_

- [x] 1.1 Configure GitHub Actions workflow for CI/CD


  - Create `.github/workflows/test.yml` with Lua and testing dependencies
  - Configure workflow to run on push and pull requests
  - Add test status badge to README
  - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5_

- [x] 2. Extract and test Formatter module





  - Create `/core/formatting/Formatter.lua` with FormatCoin, FormatTime, FormatQualitySummary, and FormatNumber functions
  - Move formatting logic from Core.lua to Formatter module
  - Remove WoW API dependencies by accepting color codes as parameters
  - Update Core.lua to use Formatter module with wrapper functions
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5_

- [x] 2.1 Write property test for coin formatting


  - **Property 3: Coin formatting produces valid output**
  - **Validates: Requirements 4.1**
  - Test that FormatCoin returns valid formatted strings for any non-negative copper amount
  - Verify output contains 'g', 's', or 'c' suffixes
  - _Requirements: 4.1_

- [x] 2.2 Write property test for time formatting


  - **Property 4: Time formatting produces valid output**
  - **Validates: Requirements 4.2**
  - Test that FormatTime returns valid formatted strings for any non-negative seconds value
  - Verify output contains 'h', 'm', or 's' suffixes
  - _Requirements: 4.2_

- [x] 2.3 Write property test for quality summary formatting


  - **Property 5: Quality summary formatting produces valid output**
  - **Validates: Requirements 4.3**
  - Test that FormatQualitySummary returns valid formatted strings for any quality count table
  - Verify output contains quality labels
  - _Requirements: 4.3_

- [x] 2.4 Write unit tests for Formatter edge cases


  - Test zero values, negative values (should be clamped), nil values
  - Test empty quality counts
  - Test various formatting options
  - _Requirements: 4.1, 4.2, 4.3_

- [x] 3. Extract and test Statistics module





  - Create `/core/calculations/Statistics.lua` with calculation functions
  - Move CalculatePerHour, CalculateTimeToLevel, CalculateKillsRemaining, CalculateElapsedTime from Session.lua
  - Remove dependencies on GetTime() and global state
  - Update Session.lua to use Statistics module
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_

- [x] 3.1 Write property test for elapsed time calculation


  - **Property 6: Elapsed time calculation is correct**
  - **Validates: Requirements 5.1**
  - Test that CalculateElapsedTime returns correct difference for any valid start/end times
  - _Requirements: 5.1_

- [x] 3.2 Write property test for rate calculations


  - **Property 7: Rate calculations are correct**
  - **Validates: Requirements 5.2, 5.3**
  - Test that CalculatePerHour returns correct rate for any positive amount and duration
  - Verify formula: (amount / duration) * 3600
  - _Requirements: 5.2, 5.3_

- [x] 3.3 Write property test for kills remaining calculation


  - **Property 8: Kills remaining calculation is correct**
  - **Validates: Requirements 5.4**
  - Test that CalculateKillsRemaining returns positive number for valid inputs
  - Test edge cases: zero kills, zero XP, at max XP
  - _Requirements: 5.4_

- [x] 3.4 Write unit tests for Statistics edge cases


  - Test division by zero handling (duration = 0)
  - Test negative value handling
  - Test nil parameter handling
  - Test boundary conditions (currentXP = maxXP, etc.)
  - _Requirements: 5.1, 5.2, 5.3, 5.4_

- [x] 4. Extract and test MobStats module





  - Create `/core/aggregation/MobStats.lua` with mob tracking functions
  - Move RecordMobKill, CalculateTotals, UpdateHighestQualityDrop, CopyQualityCounts logic
  - Remove dependencies on self.mobStats global state
  - Update Combat.lua to use MobStats module with explicit state passing
  - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_

- [x] 4.1 Write property test for recording mob kills


  - **Property 9: Recording mob kills updates stats correctly**
  - **Validates: Requirements 6.1**
  - Test that RecordKill increments kill count and adds XP/currency correctly
  - Verify stats table is updated properly for any valid mob kill data
  - _Requirements: 6.1_

- [x] 4.2 Write property test for mob aggregation


  - **Property 10: Mob aggregation sums correctly**
  - **Validates: Requirements 6.2, 6.3**
  - Test that CalculateTotals returns correct sums for any collection of mob stats
  - Verify totalKills, totalXP, totalCurrency, totalItems are summed correctly
  - _Requirements: 6.2, 6.3_


- [x] 4.3 Write property test for highest quality drop tracking

  - **Property 11: Highest quality drop tracking is correct**
  - **Validates: Requirements 6.4**
  - Test that highest quality drop has maximum quality value for any sequence of drops
  - Verify updates only occur when new drop has higher quality
  - _Requirements: 6.4_

- [x] 4.4 Write unit tests for MobStats edge cases


  - Test empty mob stats collection
  - Test nil values in mob data
  - Test quality count copying with empty tables
  - Test recording kills for same mob multiple times
  - _Requirements: 6.1, 6.2, 6.3, 6.4_

- [ ] 5. Extract and test SessionData module



  - Create `/core/aggregation/SessionData.lua` with session processing functions
  - Move BuildSessionSnapshot, CalculateTrendStatistics, FilterSessions logic
  - Remove dependencies on global state and WoW API calls
  - Update Session.lua to use SessionData module
  - _Requirements: 1.1, 1.2, 1.3_

- [ ] 5.1 Write unit tests for session snapshot building
  - Test BuildSnapshot with various session states
  - Test with max level vs leveling characters
  - Test with empty mob stats and loot
  - Test zone tracking
  - _Requirements: 1.1, 1.2, 1.3_

- [ ] 5.2 Write unit tests for trend statistics
  - Test CalculateTrendStatistics with multiple sessions
  - Test with empty session list
  - Test with mix of max level and leveling sessions
  - Verify averages and totals are calculated correctly
  - _Requirements: 1.1, 1.2, 1.3_

- [ ] 5.3 Write unit tests for session filtering
  - Test FilterSessions with various filter criteria
  - Test filtering by character, realm, class, race
  - Test with no matching sessions
  - Test with all sessions matching
  - _Requirements: 1.1, 1.2, 1.3_

- [ ] 6. Create GameAdapter layer
  - Create `/game/adapters/GameAdapter.lua` with WoW API wrapper functions
  - Implement GetCurrentTime, GetPlayerInfo, GetItemInfo, GetCurrentZone, GetQualityColor, PrintMessage
  - Add error handling with pcall for all WoW API calls
  - Create TestAdapter in `/tests/mocks/TestAdapter.lua` with same interface
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_

- [ ] 6.1 Write property test for adapter data transformation
  - **Property 1: Game adapter returns structured data**
  - **Validates: Requirements 2.3**
  - Test that adapter transforms WoW API responses into simple Lua tables
  - Verify no function references in returned data
  - _Requirements: 2.3_

- [ ] 6.2 Write property test for adapter error handling
  - **Property 2: Game adapter handles errors gracefully**
  - **Validates: Requirements 2.5**
  - Test that adapter returns valid defaults for any error condition
  - Verify no errors are raised to caller
  - _Requirements: 2.5_

- [ ] 6.3 Write unit tests for GameAdapter
  - Test each wrapper function returns expected data structure
  - Test error handling for missing WoW API functions
  - Test default value returns
  - _Requirements: 2.1, 2.3, 2.5_

- [ ] 6.4 Write unit tests for TestAdapter
  - Test state manipulation methods
  - Test that TestAdapter implements same interface as GameAdapter
  - Test predictable behavior for testing scenarios
  - _Requirements: 2.4_

- [ ] 7. Update Core.lua to use new architecture
  - Update Core.lua to require and use Formatter, Statistics, MobStats, SessionData, and GameAdapter modules
  - Replace direct WoW API calls with GameAdapter calls
  - Maintain backward compatibility with existing public API
  - Update wrapper functions to delegate to core modules
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5_

- [ ] 8. Update Session.lua to use new architecture
  - Update Session.lua to use Statistics, SessionData, and GameAdapter modules
  - Remove direct WoW API calls
  - Update session tracking to use adapter for time and player info
  - Maintain existing functionality
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5_

- [ ] 9. Update Combat.lua to use new architecture
  - Update Combat.lua to use MobStats and GameAdapter modules
  - Remove direct WoW API calls
  - Update mob tracking to use MobStats functions
  - Maintain existing combat tracking functionality
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5_

- [ ] 10. Update GrindCompanion.toc with new file structure
  - Add core module files in correct load order
  - Add game adapter files
  - Ensure dependencies load before dependent files
  - Test that addon loads correctly in WoW
  - _Requirements: 1.4, 1.5_

- [ ] 11. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 12. Create migration documentation
  - Document refactoring patterns used
  - Create before/after examples for common patterns
  - Document how to add new testable features
  - Update DEVELOPMENT.md with testing instructions
  - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5_

- [ ] 13. Final integration testing
  - Run full test suite locally
  - Test addon in WoW client to verify all features work
  - Verify session tracking, mob tracking, formatting, and calculations
  - Test with various scenarios (leveling, max level, different zones)
  - _Requirements: 1.1, 1.2, 1.3_

- [ ] 14. Final Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.
