# Frequently Asked Questions

## Compatibility

### Does this work with retail WoW or other Classic versions?

Currently designed for **Classic Era (Interface 11502)**. May work on other versions but not officially supported.

### Will this slow down my game?

No. The addon uses efficient event handling and only updates the display once per second. Memory footprint is minimal.

---

## Features

### Can I track multiple characters?

Yes! All sessions are saved with character information and can be filtered by character, class, race, or realm in the session history window.

### Do I need Auctionator?

No, it's optional. Without Auctionator, AH values will show as 0, but all other features work normally. Install [Auctionator](https://www.curseforge.com/wow/addons/auctionator) for automatic auction house price estimates.

### How accurate is the time-to-level estimate?

Very accurate after ~5 minutes of grinding. It calculates based on your current XP/hour rate and adjusts in real-time as your efficiency changes.

### Does this work in dungeons/raids?

Yes, but it's optimized for solo grinding. Group content may show inaccurate per-player statistics since XP and loot are shared.

---

## Data Management

### How do I delete old sessions?

Currently, sessions are stored permanently. You can:
- Use filtering to focus on recent sessions
- Manually edit the SavedVariables file at `WTF/Account/[AccountName]/SavedVariables/GrindCompanion.lua`

Future versions may include a delete feature.

### Can I export session data?

Session data is stored in `WTF/Account/[AccountName]/SavedVariables/GrindCompanion.lua` as a Lua table. You can:
- Parse it with external tools
- Copy it for backup
- Share it with others

### Where is my data stored?

All session data is saved in:
```
WTF/Account/[AccountName]/SavedVariables/GrindCompanion.lua
```

Settings are saved per account and persist across characters.

### Will I lose data if I crash?

Sessions are saved when you:
- Type `/gc stop`
- Logout normally
- Reload UI

If WoW crashes during a session, that session data will be lost. Use `/gc stop` regularly to prevent data loss.

---

## Usage

### Can I pause a session?

Not directly, but you can:
1. `/gc stop` to end current session
2. Take a break
3. `/gc start` to begin a new session

Each session is tracked separately in history.

### Can I edit session data after it's saved?

Not through the UI. You can manually edit the SavedVariables file, but be careful with the Lua syntax.

### Does it track rested XP?

The addon tracks total XP gained, which includes rested XP. It doesn't distinguish between rested and normal XP.

### Can I track gold from sources other than mobs?

Currently, the addon only tracks:
- Direct coin drops from mobs
- Gray item vendor values
- AH estimates for green/blue/purple items

It doesn't track quest rewards, mail, or auction house sales.

---

## Technical

### Why do some mob names show as "Unknown"?

This happens when you kill mobs very quickly or clear target before the XP message appears. The addon still tracks kills and loot correctly, they're just grouped under "Unknown".

### Why are item icons/names missing?

Item information must be in your client cache. Hover over the item once to cache it, then the name/icon will appear. This is a WoW API limitation.

### Can I customize the UI position?

Yes, the main display window is draggable. Position is saved and persists across sessions. The minimap button can be dragged around the minimap edge.

### Does it support other languages?

Currently English only. The addon uses WoW's localization system, so contributions for other languages are welcome.

---

## Comparison

### How is this different from other session trackers?

GrindCompanion offers:
- **Interactive graphs** with clickable data points
- **Per-mob analytics** with highest quality drops
- **Unlimited session history** with advanced filtering
- **Multi-character support** with class/race/realm filters
- **Adaptive UI** that switches between leveling and max-level modes
- **Zone tracking** for location-based analysis

Most basic trackers only show current session stats without history or analytics.

### Does it replace RestedXP or other leveling guides?

No, it's complementary. GrindCompanion tracks your grinding efficiency, while leveling guides provide route optimization. Use both together for maximum efficiency.

---

## Support

### Where can I report bugs?

Open an issue on [GitHub Issues](https://github.com/anthonygauthier/GrindCompanion/issues) with:
- Detailed steps to reproduce
- Error messages (if any)
- Other addons installed
- WoW version

### Can I request features?

Yes! Feature requests are welcome via GitHub Issues. Please check existing issues first to avoid duplicates.

### How can I contribute?

See [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines on:
- Code contributions
- Bug reports
- Feature requests
- Documentation improvements

### Is there a Discord/community?

Currently, all support and discussion happens through GitHub Issues. A Discord may be created if there's sufficient interest.
