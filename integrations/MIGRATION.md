# Integration Folder Migration

## Summary

All Auctionator-related code has been reorganized into the `/integrations/auctionator/` folder for better code organization and maintainability.

## Changes Made

### Files Moved

The following files were moved and refactored:

| Old Location | New Location | Description |
|-------------|--------------|-------------|
| `Pricing.lua` | `integrations/auctionator/pricing.lua` | Price lookup and AH value calculation |
| `AHTracking.lua` | `integrations/auctionator/tracking.lua` | Item tracking system and select mode |
| `AHOptions.lua` | `integrations/auctionator/options.lua` | UI panels and item picker |
| N/A | `integrations/auctionator/commands.lua` | Command handlers (extracted from Commands.lua) |

### Files Updated

- **GrindCompanion.toc** - Updated file load order to use new integration files
- **Commands.lua** - Refactored to call integration command handlers
- **docs/DEVELOPMENT.md** - Updated file structure documentation
- **.luacov** - Updated include patterns for test coverage

### Files Created

- **integrations/README.md** - Documentation for the integrations folder structure
- **integrations/MIGRATION.md** - This migration guide

## Functionality Preserved

All existing functionality has been preserved:

✅ Auctionator price lookups
✅ Custom item tracking
✅ Shift+click selection mode
✅ Options panel for managing tracked items
✅ All slash commands (`/gc testah`, `/gc select-ah`, `/gc ah-items`)
✅ Session tracking integration
✅ Minimap menu integration

## Benefits

1. **Better Organization** - All integration code is now in a dedicated folder
2. **Easier Maintenance** - Related functionality is grouped together
3. **Scalability** - Easy to add new addon integrations in the future
4. **Clear Separation** - Core addon code is separate from integration code

## Future Integrations

The new structure makes it easy to add integrations for other addons:

```
integrations/
├── auctionator/
├── [new-addon]/
│   ├── core.lua
│   ├── ui.lua
│   └── commands.lua
```

Simply create a new subfolder, add your integration files, and update the TOC file.
