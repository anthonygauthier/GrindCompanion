# Requirements Document

## Introduction

This document specifies the requirements for refactoring the GrindCompanion WoW addon to support automated testing through architectural separation. The refactoring will isolate game-dependent code from pure business logic, enabling continuous testing in CI/CD pipelines without requiring a WoW game client.

## Glossary

- **Core Logic**: Pure Lua functions and modules that perform calculations, data transformations, and business logic without direct WoW API dependencies
- **Game Adapter**: Interface layer that wraps WoW API calls and provides data to core logic
- **Test Suite**: Collection of automated tests that validate core logic behavior
- **CI/CD Pipeline**: Continuous Integration/Continuous Deployment automation that runs tests on code changes
- **WoW API**: World of Warcraft game client API functions (e.g., GetTime, UnitLevel, GetItemInfo)
- **Lua Test Framework**: Testing library for Lua (e.g., busted, luaunit)
- **Mock**: Test double that simulates WoW API behavior for testing purposes

## Requirements

### Requirement 1

**User Story:** As a developer, I want to separate core business logic from WoW API dependencies, so that I can test logic independently of the game client.

#### Acceptance Criteria

1. WHEN core logic modules are created THEN the system SHALL contain no direct WoW API calls within those modules
2. WHEN a function requires game data THEN the system SHALL receive that data through function parameters or dependency injection
3. WHEN core logic performs calculations THEN the system SHALL use only standard Lua functions and passed parameters
4. WHEN organizing code THEN the system SHALL place all core logic files in a `/core` directory
5. WHEN organizing code THEN the system SHALL place all WoW API-dependent files in a `/game` directory

### Requirement 2

**User Story:** As a developer, I want a game adapter layer, so that I can provide consistent interfaces between game APIs and core logic.

#### Acceptance Criteria

1. WHEN the game adapter is initialized THEN the system SHALL provide methods that wrap all required WoW API calls
2. WHEN core logic needs game data THEN the system SHALL request it through the game adapter interface
3. WHEN the game adapter retrieves data THEN the system SHALL transform WoW API responses into simple Lua data structures
4. WHEN testing core logic THEN the system SHALL allow replacement of the game adapter with a test implementation
5. WHEN the game adapter encounters API errors THEN the system SHALL handle them gracefully and return safe default values

### Requirement 3

**User Story:** As a developer, I want to write automated tests for core logic, so that I can verify correctness and prevent regressions.

#### Acceptance Criteria

1. WHEN tests are executed THEN the system SHALL run without requiring a WoW game client
2. WHEN testing calculations THEN the system SHALL verify outputs match expected values for given inputs
3. WHEN tests are organized THEN the system SHALL place all test files in a `/tests` directory
4. WHEN tests run THEN the system SHALL use a standard Lua testing framework
5. WHEN tests complete THEN the system SHALL report pass/fail status and any failures with details

### Requirement 4

**User Story:** As a developer, I want to refactor existing formatting functions, so that they can be tested independently.

#### Acceptance Criteria

1. WHEN FormatCoin is refactored THEN the system SHALL accept copper amount as a parameter and return formatted string
2. WHEN FormatTime is refactored THEN the system SHALL accept seconds as a parameter and return formatted string
3. WHEN FormatQualitySummary is refactored THEN the system SHALL accept quality counts as a parameter and return formatted string
4. WHEN formatting functions execute THEN the system SHALL not call any WoW API functions directly
5. WHEN color codes are needed THEN the system SHALL accept them as parameters or use constants

### Requirement 5

**User Story:** As a developer, I want to refactor session calculation logic, so that I can test statistics independently.

#### Acceptance Criteria

1. WHEN calculating elapsed time THEN the system SHALL accept start time and end time as parameters
2. WHEN calculating XP per hour THEN the system SHALL accept total XP and duration as parameters
3. WHEN calculating copper per hour THEN the system SHALL accept total copper and duration as parameters
4. WHEN calculating kills remaining THEN the system SHALL accept current XP, max XP, total XP, and kill count as parameters
5. WHEN calculation functions execute THEN the system SHALL not access global state or WoW API directly

### Requirement 6

**User Story:** As a developer, I want to refactor mob statistics tracking, so that I can test aggregation logic independently.

#### Acceptance Criteria

1. WHEN recording a mob kill THEN the system SHALL accept mob name, XP amount, and existing stats as parameters
2. WHEN aggregating mob statistics THEN the system SHALL accept a collection of mob stats and return summary data
3. WHEN calculating mob totals THEN the system SHALL sum kills, currency, XP, and items across all mobs
4. WHEN tracking highest quality drops THEN the system SHALL compare quality values and update records accordingly
5. WHEN mob stat functions execute THEN the system SHALL operate on passed data structures without global state access

### Requirement 7

**User Story:** As a developer, I want to integrate tests into CI/CD, so that tests run automatically on every code change.

#### Acceptance Criteria

1. WHEN code is pushed to the repository THEN the system SHALL trigger automated test execution
2. WHEN tests run in CI THEN the system SHALL execute using a standard Lua interpreter
3. WHEN tests fail in CI THEN the system SHALL prevent merge or deployment
4. WHEN tests pass in CI THEN the system SHALL allow the workflow to continue
5. WHEN CI runs THEN the system SHALL report test results and coverage metrics

### Requirement 8

**User Story:** As a developer, I want clear migration patterns, so that I can refactor remaining code systematically.

#### Acceptance Criteria

1. WHEN identifying refactoring candidates THEN the system SHALL document functions that mix logic and API calls
2. WHEN refactoring a function THEN the system SHALL follow established patterns for separation
3. WHEN migration is documented THEN the system SHALL provide examples of before and after code
4. WHEN new code is written THEN the system SHALL follow the established architecture patterns
5. WHEN reviewing code THEN the system SHALL verify adherence to separation principles
