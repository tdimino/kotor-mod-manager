# KOTOR Installation Paths on macOS

Complete guide to locating and navigating KOTOR installations on macOS, specifically for Steam versions.

## Overview

KOTOR on macOS has unique path challenges compared to Windows:
- Hidden Library folder by default
- .app bundle structure (must navigate inside)
- Case-sensitive filesystem
- Multiple potential Steam library locations
- Spaces in path names requiring careful quoting

This guide provides comprehensive path information for modding KOTOR 1 and 2 on macOS.

## Standard Steam Installation Paths

### Primary Steam Library Location

```bash
~/Library/Application Support/Steam/steamapps/common/
```

**Expanded path:**
```
/Users/[username]/Library/Application Support/Steam/steamapps/common/
```

### KOTOR 1 (Knights of the Old Republic)

**App Bundle:**
```
~/Library/Application Support/Steam/steamapps/common/swkotor/Knights of the Old Republic.app
```

**Game Data Directory (inside .app):**
```
~/Library/Application Support/Steam/steamapps/common/swkotor/Knights of the Old Republic.app/Contents/KOTOR Data/
```

**Override Folder (mod installation location):**
```
~/Library/Application Support/Steam/steamapps/common/swkotor/Knights of the Old Republic.app/Contents/KOTOR Data/Override/
```

**Full Expanded Path:**
```
/Users/[username]/Library/Application Support/Steam/steamapps/common/swkotor/Knights of the Old Republic.app/Contents/KOTOR Data/Override/
```

### KOTOR 2 (The Sith Lords)

**App Bundle:**
```
~/Library/Application Support/Steam/steamapps/common/Knights of the Old Republic II/KOTOR2.app
```

**Game Data Directory (inside .app):**
```
~/Library/Application Support/Steam/steamapps/common/Knights of the Old Republic II/KOTOR2.app/Contents/GameData/
```

**Override Folder:**
```
~/Library/Application Support/Steam/steamapps/common/Knights of the Old Republic II/KOTOR2.app/Contents/GameData/Override/
```

**Note:** KOTOR 2 uses `GameData` instead of `KOTOR Data`

## Key Differences: KOTOR 1 vs KOTOR 2

| Aspect | KOTOR 1 | KOTOR 2 |
|--------|---------|---------|
| Folder name | `swkotor` | `Knights of the Old Republic II` |
| App name | `Knights of the Old Republic.app` | `KOTOR2.app` |
| Internal data folder | `KOTOR Data` | `GameData` |
| Override path | `.../KOTOR Data/Override/` | `.../GameData/Override/` |

## Accessing Hidden Library Folder

macOS hides the Library folder by default. Several methods to access it:

### Method 1: Finder Go Menu (Easiest)

1. Open Finder
2. Click "Go" in the menu bar
3. **Hold down the Option (⌥) key**
4. "Library" appears in the Go menu
5. Click "Library"

### Method 2: Direct Path Navigation

1. Open Finder
2. Press `Cmd+Shift+G` (Go to Folder)
3. Type: `~/Library`
4. Press Enter

### Method 3: Terminal

```bash
open ~/Library
```

This opens the Library folder in Finder.

### Method 4: Show Hidden Files

```bash
defaults write com.apple.finder AppleShowAllFiles YES
killall Finder
```

This shows all hidden files system-wide (can be overwhelming).

To reverse:
```bash
defaults write com.apple.finder AppleShowAllFiles NO
killall Finder
```

## Accessing .app Bundle Contents

macOS .app files are actually directories (bundles) that appear as single files in Finder.

### Method 1: Right-Click (Recommended)

1. Navigate to the KOTOR .app file
2. **Right-click** (or Control-click) on the .app
3. Select **"Show Package Contents"**
4. A new Finder window opens showing Contents folder
5. Navigate to `KOTOR Data` (K1) or `GameData` (K2)

### Method 2: Terminal

```bash
# KOTOR 1
cd ~/Library/Application\ Support/Steam/steamapps/common/swkotor/Knights\ of\ the\ Old\ Republic.app/Contents/KOTOR\ Data/

# KOTOR 2
cd ~/Library/Application\ Support/Steam/steamapps/common/Knights\ of\ the\ Old\ Republic\ II/KOTOR2.app/Contents/GameData/
```

**Important:** Note the escaped spaces (`\ `) in paths.

## Override Folder Management

### Checking if Override Exists

```bash
# KOTOR 1
if [ -d ~/Library/Application\ Support/Steam/steamapps/common/swkotor/Knights\ of\ the\ Old\ Republic.app/Contents/KOTOR\ Data/Override ]; then
    echo "Override folder exists"
else
    echo "Override folder does NOT exist"
fi

# KOTOR 2
if [ -d ~/Library/Application\ Support/Steam/steamapps/common/Knights\ of\ the\ Old\ Republic\ II/KOTOR2.app/Contents/GameData/Override ]; then
    echo "Override folder exists"
else
    echo "Override folder does NOT exist"
fi
```

### Creating Override Folder

**CRITICAL:** The folder name must be exactly `Override` with capital O.

```bash
# KOTOR 1
mkdir -p ~/Library/Application\ Support/Steam/steamapps/common/swkotor/Knights\ of\ the\ Old\ Republic.app/Contents/KOTOR\ Data/Override

# KOTOR 2
mkdir -p ~/Library/Application\ Support/Steam/steamapps/common/Knights\ of\ the\ Old\ Republic\ II/KOTOR2.app/Contents/GameData/Override
```

The `-p` flag creates parent directories if needed and doesn't error if the folder already exists.

### Verifying Override Folder

```bash
# KOTOR 1
ls -la ~/Library/Application\ Support/Steam/steamapps/common/swkotor/Knights\ of\ the\ Old\ Republic.app/Contents/KOTOR\ Data/Override/

# KOTOR 2
ls -la ~/Library/Application\ Support/Steam/steamapps/common/Knights\ of\ the\ Old\ Republic\ II/KOTOR2.app/Contents/GameData/Override/
```

## Multiple Steam Library Locations

Steam allows multiple game library locations. Common scenarios:

### Finding All Steam Libraries

Check `libraryfolders.vdf`:

```bash
cat ~/Library/Application\ Support/Steam/config/libraryfolders.vdf
```

Example output:
```
"libraryfolders"
{
    "0"
    {
        "path"      "/Users/username/Library/Application Support/Steam"
        "label"     ""
        "contentid" "..."
    }
    "1"
    {
        "path"      "/Volumes/ExternalDrive/SteamLibrary"
        "label"     ""
        "contentid" "..."
    }
}
```

### Search Algorithm for KOTOR

```bash
#!/bin/bash

# Parse libraryfolders.vdf for all Steam library paths
# Then check each location for KOTOR

LIBRARY_FILE="$HOME/Library/Application Support/Steam/config/libraryfolders.vdf"

# Common paths to check
PATHS=(
    "$HOME/Library/Application Support/Steam/steamapps/common"
    "/Volumes/*/SteamLibrary/steamapps/common"
    "$HOME/Desktop/SteamLibrary/steamapps/common"
)

for PATH_BASE in "${PATHS[@]}"; do
    # Check for KOTOR 1
    KOTOR1_PATH="$PATH_BASE/swkotor/Knights of the Old Republic.app"
    if [ -d "$KOTOR1_PATH" ]; then
        echo "Found KOTOR 1: $KOTOR1_PATH"
    fi

    # Check for KOTOR 2
    KOTOR2_PATH="$PATH_BASE/Knights of the Old Republic II/KOTOR2.app"
    if [ -d "$KOTOR2_PATH" ]; then
        echo "Found KOTOR 2: $KOTOR2_PATH"
    fi
done
```

## Path Variables for Scripts

When writing bash scripts, define path variables for reusability:

```bash
#!/bin/bash

# KOTOR 1 Paths
STEAM_LIBRARY="$HOME/Library/Application Support/Steam"
KOTOR1_BASE="$STEAM_LIBRARY/steamapps/common/swkotor"
KOTOR1_APP="$KOTOR1_BASE/Knights of the Old Republic.app"
KOTOR1_DATA="$KOTOR1_APP/Contents/KOTOR Data"
KOTOR1_OVERRIDE="$KOTOR1_DATA/Override"

# KOTOR 2 Paths
KOTOR2_BASE="$STEAM_LIBRARY/steamapps/common/Knights of the Old Republic II"
KOTOR2_APP="$KOTOR2_BASE/KOTOR2.app"
KOTOR2_DATA="$KOTOR2_APP/Contents/GameData"
KOTOR2_OVERRIDE="$KOTOR2_DATA/Override"

# Usage
if [ -d "$KOTOR1_OVERRIDE" ]; then
    echo "KOTOR 1 Override: $KOTOR1_OVERRIDE"
fi
```

## File Operations with Paths Containing Spaces

### Copying Files

```bash
# Use quotes around paths
cp "/path/to/mod/file.tpc" "$KOTOR1_OVERRIDE/"

# Or use arrays for multiple files
FILES=(
    "C_Droid01.tpc"
    "C_Droid02.tpc"
    "N_Mandalorian.tpc"
)

for FILE in "${FILES[@]}"; do
    cp "/path/to/mod/$FILE" "$KOTOR1_OVERRIDE/"
done
```

### Listing Files

```bash
# Always quote paths
ls -la "$KOTOR1_OVERRIDE"

# Find specific file types
find "$KOTOR1_OVERRIDE" -name "*.tpc"
```

### Removing Files

```bash
# Remove specific file
rm "$KOTOR1_OVERRIDE/C_Droid01.tpc"

# Remove all .tpc files (be careful!)
rm "$KOTOR1_OVERRIDE"/*.tpc
```

## Permissions

### Checking Permissions

```bash
ls -la "$KOTOR1_DATA"
```

Expected output:
```
drwxr-xr-x  10 username  staff   320 Nov  4 10:30 Override
```

- `drwxr-xr-x` - Directory with read/write/execute for owner
- `username` - Owner of the folder
- `staff` - Group

### Fixing Permission Issues

If you encounter "Permission denied" errors:

```bash
# Fix Override folder permissions
chmod -R 755 "$KOTOR1_OVERRIDE"

# Fix individual file permissions
chmod 644 "$KOTOR1_OVERRIDE/file.tpc"
```

**Permission numbers:**
- `755` - Directories: owner can read/write/execute, others can read/execute
- `644` - Files: owner can read/write, others can read only

### Ownership Issues

If files are owned by wrong user:

```bash
# Change ownership to current user
sudo chown -R $(whoami):staff "$KOTOR1_OVERRIDE"
```

## Case Sensitivity

macOS filesystems can be case-sensitive or case-insensitive depending on the volume format.

### Checking Filesystem Format

```bash
diskutil info / | grep "File System"
```

Output examples:
- `File System Personality: APFS` - Case-insensitive (default)
- `File System Personality: Case-sensitive APFS` - Case-sensitive

### Case Sensitivity for Mods

**Critical:**
- Override folder must be exactly `Override` (capital O)
- File names matter: `C_droid01.tpc` ≠ `C_Droid01.tpc` on case-sensitive systems
- Some mods from Windows may have incorrect case

### Fixing Case Issues

```bash
# Rename folder if incorrect case
mv "$KOTOR1_DATA/override" "$KOTOR1_DATA/Override"

# Batch rename files (example: lowercase to proper case)
cd "$KOTOR1_OVERRIDE"
for FILE in *.TPC; do
    mv "$FILE" "${FILE%.TPC}.tpc"
done
```

## Path Storage for Skill

Store detected paths in JSON for reuse:

```json
{
  "kotor1": {
    "detected": true,
    "base_path": "/Users/username/Library/Application Support/Steam/steamapps/common/swkotor",
    "app_path": "/Users/username/Library/Application Support/Steam/steamapps/common/swkotor/Knights of the Old Republic.app",
    "data_path": "/Users/username/Library/Application Support/Steam/steamapps/common/swkotor/Knights of the Old Republic.app/Contents/KOTOR Data",
    "override_path": "/Users/username/Library/Application Support/Steam/steamapps/common/swkotor/Knights of the Old Republic.app/Contents/KOTOR Data/Override",
    "override_exists": true
  },
  "kotor2": {
    "detected": false
  }
}
```

Save to: `~/.claude/skills/kotor-mod-manager/data/installation_paths.json`

## Common Path Issues & Solutions

### Issue 1: "Library folder not found"

**Cause:** Library folder is hidden
**Solution:** Use Option+Go menu in Finder or `open ~/Library` in Terminal

### Issue 2: "Override folder doesn't exist"

**Cause:** Override folder not created by game
**Solution:** Create manually with `mkdir -p` command

### Issue 3: "Permission denied when copying files"

**Cause:** Insufficient permissions
**Solution:** Fix with `chmod -R 755 "$KOTOR1_OVERRIDE"`

### Issue 4: "No such file or directory" despite path being correct

**Cause:** Spaces in path not escaped properly
**Solution:** Always quote paths: `"$KOTOR1_OVERRIDE"`

### Issue 5: "Override folder spelled 'override' (lowercase)"

**Cause:** User created folder manually with wrong case
**Solution:** Rename: `mv override Override`

### Issue 6: "KOTOR not in standard Steam location"

**Cause:** Multiple Steam libraries or custom install location
**Solution:** Parse `libraryfolders.vdf` to find all locations

### Issue 7: "Cannot navigate into .app bundle"

**Cause:** Not understanding macOS .app structure
**Solution:** Right-click → "Show Package Contents" or use Terminal

## Installation Detection Script Template

```bash
#!/bin/bash

# Detect KOTOR installations on macOS

detect_kotor() {
    local game_name=$1
    local expected_path=$2

    if [ -d "$expected_path" ]; then
        echo "✓ Found $game_name"
        echo "  Path: $expected_path"

        # Check Override folder
        local override_path
        if [ "$game_name" == "KOTOR 1" ]; then
            override_path="$expected_path/Contents/KOTOR Data/Override"
        else
            override_path="$expected_path/Contents/GameData/Override"
        fi

        if [ -d "$override_path" ]; then
            echo "  Override: EXISTS"
        else
            echo "  Override: MISSING (will create)"
            mkdir -p "$override_path"
        fi

        return 0
    else
        echo "✗ $game_name not found"
        return 1
    fi
}

# Check standard locations
STEAM_BASE="$HOME/Library/Application Support/Steam/steamapps/common"
KOTOR1_PATH="$STEAM_BASE/swkotor/Knights of the Old Republic.app"
KOTOR2_PATH="$STEAM_BASE/Knights of the Old Republic II/KOTOR2.app"

echo "Detecting KOTOR installations..."
echo ""

detect_kotor "KOTOR 1" "$KOTOR1_PATH"
echo ""
detect_kotor "KOTOR 2" "$KOTOR2_PATH"
```

## External Paths

### Mod Download Location

Default: `~/Downloads/`

### Temporary Extraction Location

Recommended: `/tmp/kotor_mod_temp/` or `~/Library/Caches/kotor-mod-manager/`

```bash
TEMP_DIR="/tmp/kotor_mod_temp"
mkdir -p "$TEMP_DIR"

# Extract mod
unzip "~/Downloads/mod.zip" -d "$TEMP_DIR"

# Process files
# ...

# Cleanup
rm -rf "$TEMP_DIR"
```

### Backup Location

Recommended: `~/.claude/skills/kotor-mod-manager/data/backups/`

```bash
BACKUP_DIR="$HOME/.claude/skills/kotor-mod-manager/data/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_PATH="$BACKUP_DIR/override_backup_$TIMESTAMP"

mkdir -p "$BACKUP_PATH"
cp -R "$KOTOR1_OVERRIDE"/* "$BACKUP_PATH/"
echo "Backup created: $BACKUP_PATH"
```

## Symlinking (Advanced)

Some users may want Override folders in more accessible locations:

```bash
# Move Override to Desktop
mv "$KOTOR1_OVERRIDE" ~/Desktop/KOTOR_Override

# Create symlink
ln -s ~/Desktop/KOTOR_Override "$KOTOR1_OVERRIDE"
```

**Warning:** Symlinks can cause issues with some games. Not recommended for most users.

## Conclusion

Key takeaways for working with KOTOR paths on macOS:

1. **Library folder is hidden** - Use Option+Go menu
2. **.app bundles are directories** - Right-click to access contents
3. **Override folder is case-sensitive** - Must be `Override` exactly
4. **Always quote paths** - Spaces require proper handling
5. **Multiple Steam libraries** - Check all possible locations
6. **KOTOR 1 ≠ KOTOR 2** - Different folder structures
7. **Permissions matter** - Fix with chmod if needed

Use the scripts and examples in this reference when implementing path detection and file operations in the KOTOR Mod Manager skill.
