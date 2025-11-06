# Steam Version Configuration for KOTOR Modding

**CRITICAL:** The Steam version of KOTOR requires specific configuration changes before mods will work properly. Follow these steps carefully.

## Why Steam Configuration is Required

Steam's default features can interfere with KOTOR mods:

- **Steam Overlay** - Can cause crashes and conflict with modified executables
- **Cloud Save** - May overwrite or corrupt modded game files
- **Auto-Update** - Can overwrite modified executables and break installed mods
- **Steam Launcher** - Many mods require launching from a modified executable instead

## Required Steps

### 1. Disable Steam Overlay

Steam Overlay must be disabled for KOTOR to prevent crashes and compatibility issues.

**Steps:**
1. Open Steam
2. Right-click on **Star Wars: Knights of the Old Republic** in your Library
3. Select **Properties**
4. Uncheck **Enable Steam Overlay while in-game**
5. Close the Properties window

### 2. Disable Cloud Save

Cloud saves can conflict with modded game saves and cause corruption.

**Steps:**
1. In Steam Library, right-click **Star Wars: Knights of the Old Republic**
2. Select **Properties**
3. Click the **General** tab (or **Updates** tab depending on Steam version)
4. Scroll to **Steam Cloud**
5. Uncheck **Enable Steam Cloud synchronization**

### 3. Disable Auto-Update

Auto-updates can overwrite modified executables installed by mods like K1R.

**Steps:**
1. In Steam Library, right-click **Star Wars: Knights of the Old Republic**
2. Select **Properties**
3. Click the **Updates** tab
4. Under **Automatic Updates**, select:
   - **Only update this game when I launch it** (recommended)
   - OR **High Priority - Always auto-update before others** if you want more control

**Important:** Even with "Only update when I launch it", you should use a desktop shortcut (see below) to bypass Steam's launcher entirely.

### 4. Create Desktop Shortcut to Modified Executable

Many KOTOR mods (especially K1R and TSLPatcher mods) install modified executables. You MUST launch from these executables, not through Steam.

**macOS Instructions:**

1. **Locate the KOTOR executable:**
   ```bash
   cd ~/Library/Application\ Support/Steam/steamapps/common/swkotor
   ```

2. **Find the modified executable:**
   - Original: `Knights of the Old Republic.app`
   - Modified (after K1R/mods): May be `swkotor.exe` or a modified `.app` file

3. **Create an Alias (shortcut):**
   ```bash
   # For .app bundles
   ln -s ~/Library/Application\ Support/Steam/steamapps/common/swkotor/Knights\ of\ the\ Old\ Republic.app ~/Desktop/KOTOR.app

   # For Windows executables (if using Wine/CrossOver)
   ln -s ~/Library/Application\ Support/Steam/steamapps/common/swkotor/swkotor.exe ~/Desktop/KOTOR.exe
   ```

4. **Alternative - Create Finder Alias:**
   - Navigate to KOTOR folder in Finder
   - Right-click the executable
   - Select **Make Alias**
   - Drag alias to Desktop
   - Rename to "KOTOR Modded"

### 5. Do NOT Launch Through Steam

**After installing mods:**

- ❌ **DON'T:** Click "Play" in Steam Library
- ❌ **DON'T:** Use Steam's launch options
- ✅ **DO:** Use the desktop shortcut you created
- ✅ **DO:** Launch directly from the modified executable

## Verification Checklist

Before installing mods, verify all settings:

- [ ] Steam Overlay is DISABLED
- [ ] Cloud Save is DISABLED
- [ ] Auto-Update is set to "Only update when I launch it"
- [ ] Desktop shortcut to game executable is created
- [ ] You know how to launch the game WITHOUT using Steam

## macOS-Specific Notes

### Hidden Library Folder

The Steam games folder is in a hidden directory. To access it:

```bash
# Make Library folder visible temporarily
chflags nohidden ~/Library

# Or use Terminal to navigate directly
cd ~/Library/Application\ Support/Steam/steamapps/common/swkotor
```

### Finding the KOTOR Installation

Use the skill's detection script:

```bash
bash ~/.claude/skills/kotor-mod-manager/scripts/detect_kotor_install.sh
```

### .app Bundle Structure

KOTOR on macOS uses `.app` bundles. The actual game files are inside:

```
Knights of the Old Republic.app/
└── Contents/
    └── KOTOR Data/
        └── Override/    # This is where most mods go
```

## After Installing Mods

### Testing Your Configuration

1. **Install a simple mod first** (texture mod or Override folder mod)
2. **Launch using your desktop shortcut** (not through Steam)
3. **Verify the mod works in-game**
4. **If successful, proceed with complex mods** (TSLPatcher, K1R, etc.)

### If Mods Don't Work

Common issues when Steam configuration is incorrect:

1. **Game crashes on launch** → Steam Overlay not disabled
2. **Mods disappear after restarting** → Cloud Save overwriting files
3. **Modified executable missing** → Auto-update overwrote it
4. **Mods not loading** → Launching through Steam instead of modified executable

### Restoring Modified Executables

If Steam updates overwrote your modded executable:

1. **Verify game integrity in Steam** (to get clean install)
2. **Re-run the mod installers** (TSLPatcher, KOTORModSync)
3. **Create new desktop shortcut** to the newly modified executable

## Advanced: Preventing Future Updates

For complete protection against Steam updates:

### Method 1: Steam Library Settings

Set the game to never update by keeping Steam in offline mode when playing KOTOR.

### Method 2: File Protection (macOS)

Make the executable read-only:

```bash
cd ~/Library/Application\ Support/Steam/steamapps/common/swkotor

# Make executable read-only
chmod 555 "Knights of the Old Republic.app"

# To undo if needed
chmod 755 "Knights of the Old Republic.app"
```

**Warning:** This may cause Steam to think the game is corrupted.

### Method 3: Backup Modified Executable

```bash
# After installing mods, backup the modified executable
cd ~/Library/Application\ Support/Steam/steamapps/common/swkotor
cp -r "Knights of the Old Republic.app" "Knights of the Old Republic.app.modded.backup"

# Restore if Steam overwrites
rm -rf "Knights of the Old Republic.app"
cp -r "Knights of the Old Republic.app.modded.backup" "Knights of the Old Republic.app"
```

## Community Resources

**Steam-Specific Guides:**
- [KOTOR 2025 Mod Guide - Nexus Mods](https://www.nexusmods.com/kotor/mods/1705) - Explicitly mentions Steam configuration requirements
- [Fixing KOTOR Common Problems](https://steamcommunity.com/sharedfiles/filedetails/?id=499460705) - Steam Community guide
- [Prevent Steam Updates](https://steamcommunity.com/sharedfiles/filedetails/?id=3077201809) - How to freeze game versions

**Why These Steps Matter:**

From the KOTOR 2025 Mod Guide community:
> "If you use the Steam version there are specific configuration steps required to disable Steam overlay, cloud save, auto update. Do not launch the game thru Steam as you must use a modified executable."

## Quick Reference Command

```bash
# Check if your KOTOR installation is Steam version
if [ -f ~/Library/Application\ Support/Steam/steamapps/common/swkotor/Knights\ of\ the\ Old\ Republic.app/Contents/MacOS/Knights\ of\ the\ Old\ Republic ]; then
    echo "✅ Steam KOTOR detected"
    echo "📋 Remember to disable: Overlay, Cloud Save, Auto-Update"
    echo "🚀 Launch using desktop shortcut, NOT through Steam"
else
    echo "❌ Steam KOTOR not found in default location"
fi
```

## Support

If you continue having issues after following these steps:

1. Verify KOTOR launches without mods (using desktop shortcut)
2. Check that Override folder exists and has correct permissions
3. Confirm all Steam settings are disabled as described
4. Consult the [r/kotor modding guide](https://reddit.com/r/kotor) or [Deadly Stream forums](https://deadlystream.com)

---

**Remember:** The key to successful KOTOR modding on Steam is **bypassing Steam's launcher and protections** while keeping the game installed through Steam for convenience.
