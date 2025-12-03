# GrindCalculator

Lightweight WoW Classic Era addon to track grinding sessions, predict time-to-level, and summarize coins/loot (including vendor value of gray items). Sessions are persisted so you can compare runs over time.

## Commands
- `/gc start` – begin tracking.
- `/gc stop` – stop, print a session summary, and save it to history.
- `/gc stats` – print the current session stats (or last session if paused).

## Display behavior
- **Leveling:** shows ETA to next level, kills remaining, currency, and notable loot counts.
- **Max level:** swaps to a loot-focused view; only currency and item-quality counts are shown.

## Persistence
- SavedVariables: `GrindCalculatorDB.sessions` keeps session snapshots (start/end, duration, XP, kills, coins including gray-vendor value, loot counts, levels).

## Development layout
- `Core.lua` – addon bootstrap, constants, helpers (formatting, coin parsing, vendor value, saved vars).
- `Session.lua` – session state, time/XP math, snapshots, history persistence.
- `Display.lua` – movable UI frame, mode switching, live updates.
- `Loot.lua` – loot parsing, gray vendor crediting, quality counting.
- `Combat.lua` – XP gain handling, per-level summaries.
- `Commands.lua` – slash command handlers, print/stats/start/stop logic.
- `Events.lua` – event wiring and registration.
- `Pricing.lua` – optional Auctionator hook for AH values (cloth + uncommon/rare/epic items).

## Notes
- Gray (poor quality) items automatically add their vendor value into the currency total.
- If Auctionator is installed, the addon will use its pricing API to track potential AH value of cloth and uncommon/rare/epic drops; otherwise the AH value line will stay at 0.
- If you adjust code, keep ASCII and respect Blizzard API availability in Classic Era.
