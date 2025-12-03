# Development Guide

## Architecture

The addon is built with a modular architecture for maintainability and extensibility:

```
GrindCompanion/
├── Core.lua          - Core framework, constants, and utility functions
│                       (coin formatting, time formatting, quality colors)
├── Session.lua       - Session state management, persistence, and statistics
│                       (session snapshots, trend calculations, zone tracking)
├── Display.lua       - Main UI frame, session history window, and item detail window
│                       (live display, session list, detail panels, tabs)
├── Analysis.lua      - Analytics, interactive graphs, and trend visualizations
│                       (line graphs, bar charts, data point interactions)
├── Loot.lua          - Loot tracking, quality detection, and item recording
│                       (loot slot caching, quality counting, item lists)
├── Combat.lua        - XP gain, mob kill tracking, and combat log parsing
│                       (mob name detection, kill counting, level-up handling)
├── Commands.lua      - Slash command handlers and session control
│                       (start/stop, stats display, window toggles)
├── Events.lua        - Event registration, routing, and auto-save
│                       (combat events, loot events, zone changes, logout)
├── Options.lua       - Configuration panel, settings persistence
│                       (row visibility toggles, minimap button settings)
├── Minimap.lua       - Minimap button and quick-access menu
│                       (drag-to-reposition, context menu, button management)
└── Pricing.lua       - Auctionator integration for AH pricing
                        (API detection, price lookups, item filtering)
```

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
