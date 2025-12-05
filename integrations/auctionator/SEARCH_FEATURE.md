# AH Item Search Feature

## Overview
Enhanced item picker with search functionality for adding items to AH tracking without requiring them to be in your bags.

## Features

### 1. Curated Item Database
- **250+ farmable items** pre-defined in `item_database.lua`
- Categories include:
  - Herbs (Classic Era)
  - Ore & Bars
  - Gems & Stones
  - Leather & Hides
  - Cloth
  - Enchanting Materials
  - Elemental Materials
  - Meat & Cooking
  - Fish
  - Potions & Alchemy
  - Misc Reagents

### 2. Item Caching System
- Items are cached on addon load using `C_Item.RequestLoadItemDataByID()`
- Batched loading (50 items per batch) to prevent lag
- Responds to `ITEM_DATA_LOADED` event to populate cache
- Cached data includes: name, link, quality, texture, lowercase name for search

### 3. Search Functionality
- **Real-time search** - Results update as you type
- **Smart sorting** - Items starting with search term appear first
- **Multiple input methods**:
  - Text search (searches cached item names)
  - Item links (paste from chat/Auctionator)
  - Item IDs (enter numeric ID directly)
- **Result limiting** - Max 100 results to prevent UI lag

### 4. Enhanced UI
- Search box with auto-focus and escape handling
- Scrollable results with quality-colored item names
- Item icons and tooltips on hover
- "Add" button that disables after adding
- Empty state messages for no results

## Technical Implementation

### Files Modified
1. **integrations/auctionator/item_database.lua** (NEW)
   - `GrindCompanion.FarmableItems` - Array of item definitions
   - `InitializeItemCache()` - Sets up cache structure
   - `CacheFarmableItems()` - Batched item loading
   - `OnItemDataLoaded()` - Event handler for caching
   - `SearchCachedItems()` - Search algorithm

2. **integrations/auctionator/options.lua** (MODIFIED)
   - `CreateAHItemPickerFrame()` - Added search box
   - `UpdateAHItemPickerResults()` - Replaced bag scanning with search
   - `CreateAHPickerItemButton()` - Enhanced to handle cached items

3. **Events.lua** (MODIFIED)
   - Added `InitializeItemCache()` and `CacheFarmableItems()` calls on ADDON_LOADED
   - Added `ITEM_DATA_LOADED` event handler

4. **GrindCompanion.toc** (MODIFIED)
   - Added `integrations\auctionator\item_database.lua` to load order

### API Usage
- `C_Item.RequestLoadItemDataByID(itemID)` - Request item data from server
- `GetItemInfo(itemID)` - Retrieve cached item information
- `GetItemInfoInstant(link)` - Parse item ID from link
- `ITEM_DATA_LOADED` event - Fires when item data is available

## Usage

### From Options Panel
1. ESC > Interface > AddOns > GrindCompanion > AH Tracking
2. Click "Search & Add Items"
3. Type item name (e.g., "copper", "silk", "herb")
4. Click "Add" on desired items

### From Minimap Menu
1. Right-click minimap button
2. Select "Add AH Item"
3. Search and add items

### Direct Input
- Paste item link: `[Copper Ore]`
- Enter item ID: `2770`

## Performance Considerations
- Batched loading prevents initial lag spike
- Result limiting (100 max) prevents UI slowdown
- Lowercase search strings for case-insensitive matching
- Smart sorting prioritizes exact matches

## Future Enhancements
- Add more item categories (TBC/WotLK items)
- Category filters in search UI
- Recently added items list
- Import/export tracked item lists
- Suggested items based on player level/zone
