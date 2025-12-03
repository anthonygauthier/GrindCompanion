# Commands Reference

## Basic Commands

| Command | Description |
|---------|-------------|
| `/gc` or `/gc stats` | Display statistics for current or last session in chat |
| `/gc start` | Start tracking a new grinding session |
| `/gc stop` | Stop tracking, display summary, and save to history |
| `/gc sessions` | Open the session history browser with analytics and graphs |
| `/gc minimap` | Toggle minimap button visibility |
| `/gc debug` | Toggle pricing debug mode (for troubleshooting Auctionator) |
| `/gc testah` | Test Auctionator integration status |
| `/gc select-ah start` | Enable shift+click mode to add items to AH tracking |
| `/gc select-ah stop` | Disable shift+click mode for AH tracking |
| `/gc ah-items` | List all items currently tracked for AH value |

---

## Command Examples

### Starting a Session

```
/gc start
```

Begins tracking XP, kills, loot, and currency. The main display window appears automatically.

### Viewing Current Stats

```
/gc
/gc stats
```

Displays session statistics in chat without stopping the session.

### Stopping a Session

```
/gc stop
```

Ends tracking, shows a summary in chat, and saves the session to history.

### Opening Session History

```
/gc sessions
```

Opens the full session browser with:
- Interactive graphs
- Session list with filtering
- Detailed session view
- Aggregate statistics

### Minimap Button

```
/gc minimap
```

Toggles minimap button visibility. If hidden, use this command to restore it.

### Troubleshooting Auctionator

```
/gc testah
```

Tests Auctionator integration and displays detection status.

```
/gc debug
```

Enables debug mode to see detailed price lookup information in chat.

---

## Minimap Button

The minimap button provides quick access without typing commands:

- **Left-click** - Open quick-access menu
- **Drag** - Reposition button around minimap edge

**Menu Options:**
- Sessions History - Open the full session browser
- Start Session - Begin tracking
- Stop Session - End tracking and save
- Add AH Item - Quick access to item picker for AH tracking
- Hide Minimap Button - Remove button (use `/gc minimap` to restore)

---

## Workflow Examples

### Quick Grinding Session

```
1. /gc start
2. Grind mobs and loot
3. /gc stop
```

### Checking Progress Mid-Session

```
1. /gc start
2. Grind for a while
3. /gc (check stats without stopping)
4. Continue grinding
5. /gc stop
```

### Analyzing Past Sessions

```
1. /gc sessions
2. Use filters to find specific sessions
3. Click sessions to view details
4. Click graph data points to highlight sessions
```

### Troubleshooting AH Prices

```
1. /gc testah (verify Auctionator is detected)
2. /gc debug (enable debug mode)
3. Loot items to see price lookup details
4. /gc debug (disable debug mode when done)
```

### Customizing AH Item Tracking

```
1. /gc select-ah start
2. Shift+click items in your bags to add them
3. /gc select-ah stop
4. /gc ah-items (view tracked items)
```

Or use the Options panel:
```
1. ESC > Interface > AddOns > GrindCompanion > AH Tracking
2. Click "Add Item from Bags"
3. Select items to track
```
