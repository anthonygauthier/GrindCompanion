# Addon Integrations

This folder contains all third-party addon integrations for GrindCompanion.

## Structure

Each integration should be organized in its own subfolder with related functionality grouped together:

```
integrations/
├── auctionator/
│   ├── pricing.lua    - Price lookup functionality
│   ├── tracking.lua   - Item tracking system
│   ├── options.lua    - UI options panel
│   └── commands.lua   - Command handlers
└── [future-integration]/
```

## Auctionator Integration

The Auctionator integration provides auction house price tracking for items looted during grinding sessions.

### Files

- **pricing.lua** - Core pricing functionality using Auctionator API
- **tracking.lua** - Item tracking system with custom item selection
- **options.lua** - UI panels for managing tracked items
- **commands.lua** - Slash command handlers for AH features

### Features

- Automatic AH price lookup for quality items and cloth
- Custom item tracking (add any item to track its AH value)
- Shift+click selection mode
- Options panel for managing tracked items
- Integration with GrindCompanion's session tracking

## Adding New Integrations

When adding a new addon integration:

1. Create a new subfolder under `integrations/`
2. Organize related functionality into separate files
3. Update `GrindCompanion.toc` to load the new files
4. Document the integration in this README
5. Ensure the integration gracefully handles the addon not being installed
