# GrindCompanion

<div align="center">

**A comprehensive World of Warcraft Classic Era addon for tracking grinding sessions, analyzing efficiency, and maximizing your farming profits.**

[![WoW Classic Era](https://img.shields.io/badge/WoW-Classic%20Era-orange.svg)](https://worldofwarcraft.com/en-us/wowclassic)
[![Version](https://img.shields.io/badge/version-1.0-blue.svg)](https://github.com/anthonygauthier/GrindCompanion)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

</div>

---

## 📋 Overview

GrindCompanion is a lightweight yet powerful addon designed for players who want to optimize their grinding sessions in WoW Classic Era. Whether you're farming gold, leveling up, or hunting rare drops, GrindCompanion provides real-time tracking, detailed analytics, and historical session comparisons to help you maximize efficiency.

### Key Features

- **Real-Time Session Tracking** - Live ETA to next level, kills remaining, and currency earned with dynamic display
- **Comprehensive Analytics** - Detailed statistics including XP/hour, gold/hour, and kills per minute with interactive graphs
- **Session History** - Persistent storage of all grinding sessions with advanced filtering by character, class, race, and realm
- **Visual Analytics** - Four interactive graph types: Currency Per Hour, XP Per Hour, Loot Quality Distribution, and Kills Per Minute
- **Detailed Mob Statistics** - Track individual mob performance including kills, average currency/XP per kill, and highest quality drops
- **Smart Loot Tracking** - Automatic vendor value calculation for gray items and AH price estimation (with Auctionator integration)
- **Multi-Character Support** - Comprehensive character tracking with race/class icons and realm information
- **Customizable Display** - Toggle visibility of individual UI rows and configure display preferences
- **Minimap Button** - Quick access menu with drag-to-reposition functionality

### Screenshots

<div align="center">

**Live Session Tracking - Leveling Mode**

![Current Grind - Leveling](assets/images/current_grind_leveling.png)

*Real-time display showing XP tracking, estimated time to level, and kills remaining*

---

**Live Session Tracking - Max Level Mode**

![Current Grind - Max Level](assets/images/current_grind_max_level.png)

*Max level display focusing on currency and loot tracking*

---

**Session History & Analytics**

![Session Summary](assets/images/session_summary.png)

*Comprehensive session browser with interactive graphs and detailed statistics*

---

**Detailed Mob Tracking**

![Session Mob Tracking](assets/images/session_mob_tracking.png)

*Per-mob statistics showing kills, currency, XP, and highest quality drops*

---

**Multi-Character Support**

![Multi-Character Support](assets/images/multi_character_support.png)

*Filter and compare sessions across multiple characters with race/class icons*

</div>

---

## 🚀 Getting Started

### Installation

1. Download the latest release
2. Extract the `GrindCompanion` folder to your `World of Warcraft\_classic_era_\Interface\AddOns\` directory
3. Restart World of Warcraft or reload your UI (`/reload`)
4. Look for the GrindCompanion minimap button or type `/gc` to verify installation
5. (Optional) Install [Auctionator](https://www.curseforge.com/wow/addons/auctionator) for AH price tracking

### Quick Start

1. Click the minimap button or type `/gc start` to begin tracking
2. Kill mobs and loot as normal - the addon tracks everything automatically
3. View live statistics in the main display window
4. Type `/gc stop` when finished to save the session
5. Type `/gc sessions` to view history and analytics

## 💻 Commands

| Command | Description |
|---------|-------------|
| `/gc` or `/gc stats` | Display statistics for current or last session in chat |
| `/gc start` | Start tracking a new grinding session |
| `/gc stop` | Stop tracking, display summary, and save to history |
| `/gc sessions` | Open the session history browser with analytics and graphs |
| `/gc minimap` | Toggle minimap button visibility |
| `/gc debug` | Toggle pricing debug mode (for troubleshooting Auctionator) |
| `/gc testah` | Test Auctionator integration status |

### Minimap Button

The minimap button provides quick access to common functions:
- **Left-click** - Open quick-access menu
- **Drag** - Reposition button around minimap edge
- **Menu Options:**
  - Sessions History - Open the full session browser
  - Start Session - Begin tracking
  - Stop Session - End tracking and save
  - Hide Minimap Button - Remove button (use `/gc minimap` to restore)

---

## 📊 Features in Detail

### Live Session Display

The main display window shows real-time information during your grinding session with a sleek, loot-slot-styled interface:

- **Session Time** - Live timer showing elapsed session duration (HH:MM:SS or MM:SS format)
- **Currency Earned** - Direct coin drops from mobs with coin icons
- **Gray Vendor Value** - Automatic calculation of gray item vendor prices
- **Notable Items** - Count of green, blue, and purple quality drops (clickable to view item details)
- **AH Value** - Estimated auction house value (requires Auctionator)
- **Total** - Combined value of all currency sources with legendary orange border
- **Estimated Time** - Calculated time remaining to reach next level (pre-max level only)
- **Kills Remaining** - Estimated mobs needed to level (pre-max level only)

The display automatically adapts between leveling mode (showing XP/ETA) and max-level mode (focusing on loot/currency). Each row features quality-based border colors and can be individually toggled in the options panel.

### Session History & Analytics

Access comprehensive session data through the history window (`/gc sessions`):

#### Interactive Trend Graphs
Four tabbed graph views with clickable data points:
- **Currency Per Hour** - Track gold farming efficiency over time with gold-colored line graph
- **XP Per Hour** - Monitor leveling speed across sessions (excludes max-level sessions)
- **Loot Quality** - Stacked bar chart showing green/blue/purple distribution by session
- **Kills Per Minute** - Measure combat efficiency trends with red line graph

All graphs feature:
- Hover tooltips showing session details and exact values
- Click-to-select functionality that highlights the session in the list
- Automatic scaling and formatting (gold icons for currency, K/M notation for large numbers)
- Visual highlighting of selected data points

#### Summary Statistics Panel
Real-time aggregate statistics for filtered sessions:
- Total sessions and combined time
- Average currency per hour
- Best currency per hour achieved
- Average and best XP per hour (for non-max-level sessions)

#### Advanced Filtering
- Real-time search by character name
- Filter by class (all 10 classes supported)
- Filter by race (all playable races)
- Filter by realm (dynamically populated from your sessions)
- Filters apply to both graphs and session list

#### Detailed Session View
Two-tabbed detail panel for each session:

**Summary Tab:**
- Character information with race/class icons
- Start/end timestamps and duration
- Zone(s) visited during session
- Session summary (total kills, unique mobs, mob currency, mob XP, notable items)
- XP statistics (total, per kill, per hour) for non-max-level sessions
- Complete currency breakdown (direct, gray items, AH value, total, per hour)
- Notable loot summary by quality

**Mobs Tab:**
- Top 10 most-killed mobs sorted by kill count
- Per-mob statistics: kills, total/average currency, total/average XP
- Highest quality drop for each mob with item link
- Notable item counts (purple/blue/green) per mob
- Remaining mob count indicator if more than 10 unique mobs

### Mob Statistics

Comprehensive per-mob tracking during sessions:
- Total kills per mob type
- Total and average currency per kill (includes gray item vendor value)
- Total and average XP per kill (for non-max-level sessions)
- Notable item drops by quality (green/blue/purple counts)
- Highest quality drop recorded with item link and quantity
- Automatic mob name detection from combat log
- Session summary aggregates: total kills, unique mobs, total currency, total XP, total items

### Level Summaries

Automatic chat summaries when you level up:
- Time spent on the level
- Total XP gained and kills
- XP per kill and XP per hour
- Currency earned (coins) during the level
- Notable loot summary (green/blue/purple counts)
- Separate tracking for level-specific stats that reset on level-up

### Item Detail Window

Click the "Notable Items" row in the main display to open a detailed item list:
- All green, blue, and purple items looted during the session
- Sorted by quality (descending) then by name
- Shows item icon, name (with quality color), and quantity
- Hover for full item tooltip
- Automatically updates as you loot items
- Quality-based icon borders matching item rarity

### UI Design Philosophy

GrindCompanion uses Blizzard's native UI templates for a seamless, authentic WoW experience:
- **Loot Slot Style** - Main display rows mimic the familiar loot window aesthetic
- **Portrait Frames** - Windows use classic portrait frame templates with proper borders
- **Quality Colors** - All item qualities use WoW's standard color scheme
- **Coin Icons** - Currency displays use actual gold/silver/copper coin textures
- **Race/Class Icons** - Session history shows authentic race and class icons
- **Inset Panels** - Detail panels use Blizzard's inset frame style for consistency
- **Hover Tooltips** - Standard GameTooltip integration for familiar interactions

---

## ✨ What Makes GrindCompanion Different?

Unlike simple session timers or basic loot trackers, GrindCompanion provides:

| Feature | GrindCompanion | Basic Trackers |
|---------|----------------|----------------|
| **Interactive Graphs** | ✅ 4 graph types with clickable data points | ❌ Text-only stats |
| **Per-Mob Analytics** | ✅ Detailed stats per mob type with highest drops | ❌ Aggregate only |
| **Session History** | ✅ Unlimited persistent history with filtering | ⚠️ Limited or session-only |
| **Multi-Character** | ✅ Filter by character, class, race, realm | ⚠️ Basic or none |
| **AH Integration** | ✅ Auctionator API with smart item filtering | ❌ Manual pricing |
| **Visual Analytics** | ✅ Trend analysis with comparative statistics | ❌ Current session only |
| **Auto-Save** | ✅ Saves on logout/reload automatically | ⚠️ Manual save required |
| **Adaptive UI** | ✅ Switches between leveling/max-level modes | ❌ Static display |
| **Zone Tracking** | ✅ Tracks all zones visited during session | ❌ Not tracked |
| **Item Details** | ✅ Clickable item list with tooltips | ⚠️ Count only |

---

## 🔧 Configuration

Access addon settings through the Interface Options panel:

1. Press `Esc` → Interface → AddOns → GrindCompanion
2. Toggle visibility of individual display rows:
   - Currency Earned
   - Gray Vendor Value
   - Notable Items
   - AH Value (Experimental)
   - Total
   - Estimated Time (non-max level)
   - Kills Remaining (non-max level)
3. Hide/show minimap button
4. Settings are saved per account and persist across sessions

---

## 🎯 Use Cases

### Gold Farming
- Compare different farming spots by gold/hour using the Currency Per Hour graph
- Track which mobs provide the best returns with detailed mob statistics
- Monitor AH value of drops for optimal selling strategies (with Auctionator)
- Identify best sessions and replicate successful farming routes
- Track gray item vendor value separately from direct coin drops

### Leveling
- Optimize grinding routes with XP/hour tracking and trend analysis
- Estimate time investment for level goals with real-time ETA
- Compare efficiency across different zones with zone tracking
- Monitor XP per kill to find optimal mob levels
- View level-by-level summaries in chat

### Rare Farming
- Track highest quality drops per mob type
- Monitor session duration and kills per minute efficiency
- Analyze loot quality trends across sessions with bar chart visualization
- View detailed item lists with quality-based sorting
- Compare loot distribution across different farming locations

### Multi-Character Farming
- Filter sessions by character, class, race, or realm
- Compare farming efficiency across different characters
- Track which classes/specs perform best in specific zones
- View aggregate statistics for specific character types

---

## 🔌 Integration

### Auctionator Support

GrindCompanion integrates seamlessly with [Auctionator](https://www.curseforge.com/wow/addons/auctionator) to provide auction house price estimates:

**What's Tracked:**
- All uncommon (green), rare (blue), and epic (purple) quality items
- Cloth items (armor class 4, subclass 1)
- Trade goods cloth (class 7, subclass 5)

**Features:**
- Automatic price lookup using Auctionator's API
- Real-time AH value calculation during sessions
- Per-session AH value totals and per-hour rates
- Debug mode (`/gc debug`) for troubleshooting price lookups
- Test command (`/gc testah`) to verify Auctionator detection

**Note:** AH values will show as 0 without Auctionator installed. The addon will notify you on load if Auctionator is not detected.

---

## 📁 Architecture

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

## 🛠️ Development

### Data Structure

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

### Contributing

Contributions are welcome! Please ensure:
- Code follows existing style conventions (modular architecture, clear function names)
- Functions are documented with clear comments
- Changes maintain compatibility with WoW Classic Era API (Interface 11502)
- No external dependencies beyond optional Auctionator
- UI elements follow Blizzard's template patterns (PortraitFrameTemplate, InsetFrameTemplate3, etc.)
- Event handling is efficient and doesn't impact game performance

---

## 📝 Technical Notes

- **API Compatibility** - Built for WoW Classic Era (Interface 11502)
- **Performance** - Lightweight design with minimal memory footprint and efficient event handling
- **Persistence** - All session data saved to SavedVariables (`GrindCompanionDB`)
- **Event-Driven** - Efficient event handling for combat log, loot, XP, zone changes, and logout
- **Combat Log Integration** - Uses `COMBAT_LOG_EVENT_UNFILTERED` for accurate mob tracking
- **Loot Slot Caching** - Pre-caches loot slots to ensure accurate tracking even with fast looting
- **Auto-Save** - Sessions automatically saved on logout/reload to prevent data loss
- **Dynamic UI** - Display automatically adapts between leveling and max-level modes
- **Graph Rendering** - Custom line graph and bar chart implementations using texture segments
- **Localization** - Currently supports English (contributions welcome)

---

## 🐛 Known Issues & Limitations

- **AH Pricing** - Requires Auctionator addon to function; values show as 0 without it
- **Mob Name Detection** - Mob names may show as "Unknown" if target is cleared before XP message or combat log event
- **Short Sessions** - Very short sessions (< 1 minute) may show inaccurate ETA projections
- **Max Level Tracking** - At max level, kill counting relies on combat log events (UNIT_DIED, PARTY_KILL) instead of XP messages
- **Graph Rendering** - Line graphs use texture segments to approximate lines (WoW API limitation)
- **Item Info Caching** - Item names/icons may not display immediately if not in client cache; will populate after viewing item once

---

## 🔧 Troubleshooting

### AH Values Show as 0
1. Verify Auctionator is installed and enabled
2. Type `/gc testah` to check integration status
3. Visit the auction house to populate Auctionator's price database
4. Enable debug mode with `/gc debug` to see price lookup details

### Mob Names Show as "Unknown"
- This happens when you kill mobs very quickly or clear target before XP message
- The addon will still track kills and loot correctly
- Try keeping target selected until XP message appears

### Display Window Not Showing
1. Type `/gc start` to begin tracking
2. Check Interface Options → AddOns → GrindCompanion to ensure rows are enabled
3. Try `/reload` to reset the UI

### Minimap Button Missing
- Type `/gc minimap` to toggle visibility
- Check Interface Options → AddOns → GrindCompanion settings
- Button position is saved and persists across sessions

### Session Not Saving
- Sessions auto-save when you type `/gc stop` or logout
- Check that you started tracking with `/gc start`
- Verify SavedVariables are enabled in your WoW settings

---

## ❓ FAQ

**Q: Does this work with retail WoW or other Classic versions?**  
A: Currently designed for Classic Era (Interface 11502). May work on other versions but not officially supported.

**Q: Will this slow down my game?**  
A: No. The addon uses efficient event handling and only updates the display once per second. Memory footprint is minimal.

**Q: Can I track multiple characters?**  
A: Yes! All sessions are saved with character information and can be filtered by character, class, race, or realm.

**Q: Do I need Auctionator?**  
A: No, it's optional. Without Auctionator, AH values will show as 0, but all other features work normally.

**Q: How do I delete old sessions?**  
A: Currently, sessions are stored permanently. You can manually edit the SavedVariables file or use filtering to focus on recent sessions.

**Q: Can I export session data?**  
A: Session data is stored in `WTF/Account/[AccountName]/SavedVariables/GrindCompanion.lua` and can be parsed externally.

**Q: Does this work in dungeons/raids?**  
A: Yes, but it's optimized for solo grinding. Group content may show inaccurate per-player statistics.

**Q: How accurate is the time-to-level estimate?**  
A: Very accurate after ~5 minutes of grinding. It calculates based on your current XP/hour rate and adjusts in real-time.

---

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 📞 Support & Feedback

- **Bug Reports**: Open an issue on GitHub with detailed steps to reproduce
- **Feature Requests**: Suggestions and ideas are welcome via GitHub Issues
- **Questions**: Check the FAQ and Troubleshooting sections first
- **Contributions**: Pull requests welcome! See Contributing section for guidelines

**Enjoying GrindCompanion?** Consider starring the repository and sharing with fellow grinders!
