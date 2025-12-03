# Troubleshooting Guide

## Common Issues

### AH Values Show as 0

**Cause:** Auctionator addon not installed or price database empty.

**Solutions:**
1. Verify Auctionator is installed and enabled
2. Type `/gc testah` to check integration status
3. Visit the auction house to populate Auctionator's price database
4. Enable debug mode with `/gc debug` to see price lookup details

**Note:** AH pricing is optional. All other features work without Auctionator.

---

### Mob Names Show as "Unknown"

**Cause:** Target cleared before XP message or combat log event processed.

**Why it happens:**
- Killing mobs very quickly
- Clearing target immediately after kill
- Fast looting with auto-loot enabled

**Impact:** Minimal - kills and loot still tracked correctly, just grouped under "Unknown"

**Solution:** Keep target selected until XP message appears (not always practical)

---

### Display Window Not Showing

**Possible causes and solutions:**

1. **Session not started**
   - Type `/gc start` to begin tracking

2. **Rows disabled in options**
   - Press `Esc` → Interface → AddOns → GrindCompanion
   - Enable desired display rows

3. **UI needs reset**
   - Type `/reload` to reset the UI

4. **Window moved off-screen**
   - Type `/reload` to reset window position

---

### Minimap Button Missing

**Solutions:**
- Type `/gc minimap` to toggle visibility
- Check Interface Options → AddOns → GrindCompanion
- Button position is saved and persists across sessions
- If still missing, try `/reload`

---

### Session Not Saving

**Common causes:**

1. **Session never started**
   - Must use `/gc start` before tracking begins

2. **SavedVariables disabled**
   - Check WoW settings to ensure SavedVariables are enabled
   - Located in game options

3. **Crashed before logout**
   - Sessions only save on `/gc stop` or clean logout
   - Use `/gc stop` regularly to avoid data loss

**Best practice:** Type `/gc stop` before logging out to ensure save.

---

### Inaccurate Time Estimates

**Cause:** Insufficient data for accurate projection.

**Solutions:**
- Wait 5+ minutes for accurate ETA calculations
- Estimates improve as session continues
- Very short sessions (< 1 minute) will show inaccurate projections

**How it works:** ETA calculates based on current XP/hour rate and adjusts in real-time.

---

### Item Names/Icons Not Showing

**Cause:** Item not in client cache yet.

**Solution:**
- Hover over the item once to cache it
- Names/icons will populate automatically after caching
- This is a WoW API limitation, not an addon bug

---

### Max Level Kill Counting Issues

**Cause:** At max level, kill counting relies on combat log events instead of XP messages.

**Impact:** Kills may be missed if:
- Combat log is flooded with events
- Mob dies far away
- Group kills where you don't get credit

**Solution:** This is a WoW API limitation. Most kills are tracked correctly.

---

## Debug Mode

Enable debug mode to troubleshoot issues:

```
/gc debug
```

**What it shows:**
- Auctionator price lookups
- Item quality detection
- Price calculation details
- API call results

**When to use:**
- AH values seem incorrect
- Items not being tracked
- Pricing integration issues

**Disable when done:**
```
/gc debug
```

---

## Performance Issues

**Symptoms:**
- Game lag during grinding
- Slow UI response
- Frame rate drops

**Solutions:**

1. **Check other addons**
   - Disable other addons to isolate issue
   - GrindCompanion is lightweight by design

2. **Reduce UI updates**
   - Display updates once per second
   - This is already optimized

3. **Clear old sessions**
   - Manually edit SavedVariables file
   - Delete old sessions if database is huge (thousands of sessions)

**Note:** GrindCompanion uses efficient event handling and minimal memory. Performance issues are rare.

---

## Data Recovery

### Lost Session Data

**SavedVariables location:**
```
WTF/Account/[AccountName]/SavedVariables/GrindCompanion.lua
```

**Recovery options:**
1. Check for backup files (`.bak` extension)
2. Restore from WoW backup if available
3. Sessions are only saved on `/gc stop` or logout

**Prevention:**
- Use `/gc stop` regularly
- Don't force-quit WoW during sessions
- Enable SavedVariables in game settings

---

## Reporting Issues

If you encounter a bug not covered here:

1. **Gather information:**
   - Exact steps to reproduce
   - Error messages (if any)
   - Other addons installed
   - WoW version

2. **Check existing issues:**
   - Visit GitHub Issues page
   - Search for similar problems

3. **Create new issue:**
   - Provide detailed description
   - Include reproduction steps
   - Attach screenshots if relevant

**GitHub Issues:** https://github.com/anthonygauthier/GrindCompanion/issues
