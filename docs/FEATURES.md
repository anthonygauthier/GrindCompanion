# Features Guide

## Live Session Display

The main display window shows real-time information with a loot-slot-styled interface:

- **Session Time** - Live timer (HH:MM:SS or MM:SS format)
- **Currency Earned** - Direct coin drops with coin icons
- **Gray Vendor Value** - Automatic gray item vendor price calculation
- **Notable Items** - Green/blue/purple drop counts (clickable for details)
- **AH Value** - Estimated auction house value (requires Auctionator)
- **Total** - Combined value with legendary orange border
- **Estimated Time** - Time remaining to next level (pre-max level)
- **Kills Remaining** - Estimated mobs to level (pre-max level)

The display automatically adapts between leveling and max-level modes. Each row can be toggled in options.

---

## Session History & Analytics

Access via `/gc sessions` for comprehensive data:

### Interactive Trend Graphs

Four tabbed graph views with clickable data points:

1. **Currency Per Hour** - Gold farming efficiency with gold-colored line graph
2. **XP Per Hour** - Leveling speed trends (excludes max-level sessions)
3. **Loot Quality** - Stacked bar chart showing green/blue/purple distribution
4. **Kills Per Minute** - Combat efficiency with red line graph

**Graph Features:**
- Hover tooltips with session details and exact values
- Click-to-select highlights session in list
- Automatic scaling and formatting (gold icons, K/M notation)
- Visual highlighting of selected data points

### Summary Statistics Panel

Real-time aggregate stats for filtered sessions:
- Total sessions and combined time
- Average currency per hour
- Best currency per hour achieved
- Average and best XP per hour (non-max-level only)

### Advanced Filtering

- Real-time search by character name
- Filter by class (all 10 classes)
- Filter by race (all playable races)
- Filter by realm (dynamically populated)
- Filters apply to graphs and session list

### Detailed Session View

Two-tabbed detail panel:

**Summary Tab:**
- Character info with race/class icons
- Start/end timestamps and duration
- Zones visited during session
- Session summary (kills, unique mobs, currency, XP, items)
- XP statistics (total, per kill, per hour)
- Complete currency breakdown
- Notable loot summary by quality

**Mobs Tab:**
- Top 10 most-killed mobs by kill count
- Per-mob stats: kills, total/avg currency, total/avg XP
- Highest quality drop with item link
- Notable item counts per mob
- Indicator if more than 10 unique mobs

---

## Mob Statistics

Comprehensive per-mob tracking:
- Total kills per mob type
- Total and average currency per kill (includes gray items)
- Total and average XP per kill
- Notable item drops by quality (green/blue/purple counts)
- Highest quality drop with item link and quantity
- Automatic mob name detection from combat log
- Session aggregates: total kills, unique mobs, currency, XP, items

---

## Level Summaries

Automatic chat summaries on level-up:
- Time spent on the level
- Total XP gained and kills
- XP per kill and XP per hour
- Currency earned during level
- Notable loot summary
- Level-specific stats that reset on level-up

---

## Item Detail Window

Click "Notable Items" row to open detailed list:
- All green/blue/purple items looted
- Sorted by quality (descending) then name
- Shows icon, name (quality colored), and quantity
- Hover for full item tooltip
- Auto-updates as you loot
- Quality-based icon borders

---

## UI Design Philosophy

Uses Blizzard's native UI templates for seamless integration:
- **Loot Slot Style** - Familiar loot window aesthetic
- **Portrait Frames** - Classic frame templates with proper borders
- **Quality Colors** - WoW's standard color scheme
- **Coin Icons** - Actual gold/silver/copper textures
- **Race/Class Icons** - Authentic icons in session history
- **Inset Panels** - Blizzard's inset frame style
- **Hover Tooltips** - Standard GameTooltip integration
