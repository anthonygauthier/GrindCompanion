# GrindCompanion

<div align="center">

<img src="./assets/images/logo.png" alt="GrindCompanion Logo" width="200"/>

**A comprehensive World of Warcraft Classic Era addon for tracking grinding sessions, analyzing efficiency, and maximizing your farming profits.**

[![WoW Classic Era](https://img.shields.io/badge/WoW-Classic%20Era-orange.svg)](https://worldofwarcraft.com/en-us/wowclassic)
[![Version](https://img.shields.io/github/v/release/anthonygauthier/GrindCompanion?label=version)](https://github.com/anthonygauthier/GrindCompanion/releases)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Tests](https://github.com/anthonygauthier/GrindCompanion/workflows/Tests/badge.svg)](https://github.com/anthonygauthier/GrindCompanion/actions)

</div>

---

## 📋 Overview

GrindCompanion is a lightweight yet powerful addon for WoW Classic Era that helps you optimize grinding sessions. Track XP/hour, gold/hour, mob statistics, and loot in real-time with interactive graphs and comprehensive session history.

### Key Features

- **Real-Time Tracking** - Live ETA to level, kills remaining, and currency earned
- **Interactive Analytics** - Four graph types with clickable data points and trend analysis
- **Session History** - Unlimited persistent storage with advanced filtering
- **Mob Statistics** - Per-mob tracking with currency, XP, and highest quality drops
- **Multi-Character Support** - Filter by character, class, race, and realm
- **Smart Loot Tracking** - Automatic vendor values and customizable AH pricing (with Auctionator)

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

## 🚀 Quick Start

### Installation

1. Download the latest release
2. Extract to `World of Warcraft\_classic_era_\Interface\AddOns\`
3. Restart WoW or `/reload`
4. Look for the minimap button or type `/gc`

### Basic Usage

```
/gc start           - Begin tracking
/gc stop            - End session and save
/gc sessions        - View history and analytics
/gc                 - Show current stats
/gc toggle          - Toggle grind summary window (show/hide)
/gc toggle on       - Show grind summary window
/gc toggle off      - Hide grind summary window
/gc minimap         - Toggle minimap button visibility
/gc debug           - Toggle pricing debug mode
/gc testah          - Test Auctionator integration
/gc select-ah start - Enable shift+click to add AH items
/gc select-ah stop  - Disable shift+click mode
/gc ah-items        - List tracked AH items
```

**Minimap Button:** Left-click for quick-access menu, drag to reposition
- Sessions History - Open the full session browser
- Start/Stop Session - Begin or end tracking
- Add AH Item - Quick access to item picker
- Hide Minimap Button - Remove button (use `/gc minimap` to restore)

For detailed command examples and workflows, see [Commands Reference](docs/COMMANDS.md).

---

## 📊 What Makes It Different?

| Feature | GrindCompanion | Basic Trackers |
|---------|----------------|----------------|
| Interactive Graphs | ✅ 4 types with clickable points | ❌ Text only |
| Per-Mob Analytics | ✅ Detailed stats + highest drops | ❌ Aggregate only |
| Session History | ✅ Unlimited with filtering | ⚠️ Limited |
| Multi-Character | ✅ Filter by class/race/realm | ⚠️ Basic |
| AH Integration | ✅ Auctionator API | ❌ Manual |
| Adaptive UI | ✅ Leveling/max-level modes | ❌ Static |

---

## 📚 Documentation

- **[Features Guide](docs/FEATURES.md)** - Detailed feature descriptions and UI elements
- **[Commands Reference](docs/COMMANDS.md)** - Complete command list and usage examples
- **[Troubleshooting](docs/TROUBLESHOOTING.md)** - Common issues and solutions
- **[Development](docs/DEVELOPMENT.md)** - Architecture, data structures, and contributing
- **[FAQ](docs/FAQ.md)** - Frequently asked questions

---

## 🔌 Integration

**Auctionator Support (Optional):** Install [Auctionator](https://www.curseforge.com/wow/addons/auctionator) for automatic AH price estimates. You can customize which items to track for AH value using `/gc select-ah start` (shift+click items) or through the Options panel.

---

## 🎯 Use Cases

- **Gold Farming** - Compare spots by gold/hour, track mob returns, monitor AH values
- **Leveling** - Optimize routes with XP/hour trends, real-time ETA, zone comparisons
- **Rare Farming** - Track highest drops per mob, analyze loot quality trends
- **Multi-Character** - Compare efficiency across characters and classes

---

## 🛠️ Configuration

Press `Esc` → Interface → AddOns → GrindCompanion to:
- Toggle visibility of display rows
- Hide/show minimap button
- Customize AH item tracking (add/remove items from bags)
- Adjust your tracking experience

---

## 📜 License

MIT License - see [LICENSE](LICENSE) file for details.

---

## 📞 Support

- **Issues/Features:** [GitHub Issues](https://github.com/anthonygauthier/GrindCompanion/issues)
- **Contributing:** See [CONTRIBUTING.md](CONTRIBUTING.md)

**Enjoying GrindCompanion?** Star the repo and share with fellow grinders!
