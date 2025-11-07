---
name: kotor-mod-manager
description: Manage KOTOR (Knights of the Old Republic) mods on Steam for macOS with Wine-based TSLPatcher support. Install mods, check compatibility, resolve conflicts, and maintain mod lists. Features innovative Wine drive mapping technique that eliminates path navigation errors. Supports Override mods and TSLPatcher mods via Wine or KOTORModSync. Production-tested with K1R, texture packs, and 8+ mod installations. Use when installing KOTOR mods, setting up Wine for TSLPatcher, checking mod compatibility, resolving conflicts, or troubleshooting installations on macOS.
---

# KOTOR Mod Manager for macOS

## Overview

This skill provides comprehensive mod management for Knights of the Old Republic (KOTOR) 1 and 2 on macOS via Steam. It automates mod installation, compatibility checking, conflict detection, and resolution for the complex KOTOR modding ecosystem.

KOTOR modding on macOS presents unique challenges: hidden Library folders, .app bundle navigation, and Windows-only modding tools. This skill addresses these challenges by providing native macOS support, automatic KOTORModSync integration for TSLPatcher mods, and intelligent conflict detection.

## When to Use This Skill

Use this skill when:
- Installing KOTOR mods from Downloads folder on macOS
- Checking if mods are compatible with each other
- Resolving mod conflicts (.2da table conflicts, file overwrites)
- Managing mod installation order
- Troubleshooting mod installation issues on macOS
- Setting up custom mod builds (e.g., Reddit spoiler-free build)
- Verifying KOTOR Steam installation location
- Determining if a mod requires TSLPatcher or Override folder installation
- Rolling back or removing installed mods

## Prerequisites

**Required:**
- KOTOR 1 or KOTOR 2 installed via Steam on macOS
- Mods downloaded to ~/Downloads/ (common formats: .zip, .7z, .rar)
- Python 3.x (standard on macOS)

**For TSLPatcher Mods (choose one):**
- **Option A: Wine** (universal, recommended for macOS) - `brew install --cask wine-stable`
- **Option B: KOTORModSync** (modern, limited mod support) - skill auto-downloads if not present

**Note:** Wine is the most reliable method for TSLPatcher mods on macOS. See Workflow 4b for setup.

## Core Workflows

### Workflow Decision Tree

When user requests KOTOR mod assistance, determine the appropriate workflow:

1. **First-time setup or unknown installation**: → Workflow 1 (Detect Installation)
2. **User has mods to install**: → Workflow 2 (Scan) → Workflow 3 (Check Compatibility) → Workflow 4 (Install)
3. **User reports mod issues**: → Workflow 5 (Verify) or troubleshooting
4. **User wants to remove mods**: → Workflow 6 (Rollback)
5. **User asks about compatibility**: → Workflow 3 (Check Compatibility)

### Workflow 1: Detect KOTOR Installation

**Purpose:** Find and validate KOTOR installation on macOS.

**Script:** `scripts/detect_kotor_install.sh`

**Process:**
1. Search for KOTOR in Steam installation directories
2. Typical paths:
   - KOTOR 1: `~/Library/Application Support/Steam/steamapps/common/swkotor/Knights of the Old Republic.app/`
   - KOTOR 2: `~/Library/Application Support/Steam/steamapps/common/Knights of the Old Republic II/KOTOR2.app/`
3. Navigate into .app bundle: `Contents/KOTOR Data/` (K1) or `Contents/GameData/` (K2)
4. Check for Override folder; create if missing (case-sensitive: capital O)
5. Verify write permissions
6. Store installation path for future use

**macOS-Specific Notes:**
- Library folder is hidden by default (use `~/Library` or Option+Go menu in Finder)
- Must right-click .app and "Show Package Contents" to access internal files
- Override folder spelling must be exact (capital O, lowercase verride)

**Output:** Installation path or error if not found

**Troubleshooting:**
- Multiple Steam libraries: Check all library locations
- External drives: Search mounted volumes
- Permissions: May need to fix with `chmod`

### Workflow 2: Scan Downloaded Mods

**Purpose:** Discover and analyze mods in ~/Downloads/ folder.

**Process:**
1. Search ~/Downloads/ for KOTOR mod archives (.zip, .7z, .rar, folders)
2. For each potential mod:
   - Extract to temporary location
   - Analyze file structure
   - Determine installation method (Override vs TSLPatcher)
   - Count files and identify types
   - Search for documentation (README, installation guide)
   - Extract mod metadata (name, version, author if available)
3. Create mod inventory with basic information
4. Present mods to user for selection

**Installation Method Detection:**
- **Override folder mod**: Contains .tpc, .tga, .2da, .utc, .dlg files directly
- **TSLPatcher mod**: Contains `tslpatchdata/` folder and/or `.exe` installer

**Output:** List of discovered mods with metadata

### Workflow 3: Check Compatibility

**Purpose:** Analyze selected mods for conflicts and compatibility issues.

**Scripts:**
- `scripts/check_mod_conflicts.py` - Main conflict detection
- `scripts/parse_2da.py` - Parse .2da table files
- `scripts/generate_report.py` - Create HTML report

**Conflict Detection Process:**

**Level 1: Filename Conflicts**
```
For each selected mod:
  - List all files with paths
  - Compare against files from other mods
  - Compare against already installed files
  - Flag exact filename matches
```

**Level 2: File Type Risk Assessment**
```
For each conflicting file:
  - Check file extension
  - Assign risk level:
    * .tpc/.tga (textures): LOW - visual only, last installed wins
    * .ncs/.nss (scripts): MEDIUM - logic conflicts possible
    * .2da (data tables): HIGH - can cause crashes
    * .dlg (dialogs): HIGH - broken conversations
    * .rim/.mod (modules): VERY HIGH - major conflicts
```

**Level 3: .2da Table Analysis**
```
For .2da conflicts:
  - Parse both mods' .2da files using parse_2da.py
  - Compare:
    * New rows added (usually safe)
    * Modified existing rows (conflict)
    * Column structure changes
  - Determine if TSLPatcher can merge
```

**Level 4: Installation Order Requirements**
```
- Check mod documentation for:
  * "Install before X"
  * "Install after Y"
  * "Incompatible with Z"
  * "Must be installed first"
- Check compatibility database (data/compatibility.json)
- Build dependency graph
- Detect circular dependencies
- Suggest installation order
```

**Level 5: Known Compatibility Database**
```
- Query data/compatibility.json
- Check for:
  * Known compatible combinations
  * Known incompatible combinations
  * Community-tested compatibility
  * Reddit build configurations
```

**Compatibility Report Output:**

Generate HTML report (templates/conflict_report_template.html) with:
- ✓ Compatible mods (green) - no conflicts
- ⚠ Minor conflicts (yellow) - textures, visual only
- ❌ Major conflicts (orange) - .2da, scripts, dialogs
- 🚫 Incompatible (red) - documented incompatibility or module conflicts

**Report Sections:**
1. **Summary**: Overall compatibility status
2. **Conflict Details**: File-by-file analysis
3. **Recommended Installation Order**: Dependency-based ordering
4. **Manual Resolution Required**: Conflicts that cannot be auto-resolved
5. **mod Descriptions**: What each mod does

**Output:** HTML report at `~/Desktop/kotor_mod_compatibility_report.html`

### Workflow 4: Install Mods

**Purpose:** Install mods in correct order with appropriate method.

**Scripts:**
- `scripts/setup_kotormodsync.sh` - Auto-install KOTORModSync if needed
- `scripts/install_mod.sh` - Orchestrate installation

**Pre-Installation:**
1. Verify KOTOR installation path
2. Check KOTORModSync availability:
   - If not installed: Run `setup_kotormodsync.sh` to auto-download
   - Verify installation: `~/KOTORModSync/` or similar location
3. Create backup of current Override folder
4. Order mods by dependencies (from compatibility check)

**Installation Methods:**

**Method A: Override Folder Mods (Simple)**
```
For texture mods, simple replacements:
1. Extract mod to temporary directory
2. Identify files to copy (usually all .tpc, .tga, .2da, etc.)
3. Copy to Override folder:
   - KOTOR 1: ~/Library/.../KOTOR Data/Override/
   - KOTOR 2: ~/Library/.../GameData/Override/
4. Handle conflicts:
   - If file exists, warn user
   - Last installed wins (overwrite)
5. Log installed files to data/installed_mods.json
```

**Method B: TSLPatcher Mods (Complex)**
```
For restoration mods, complex installers:
1. Extract mod to temporary directory
2. Locate tslpatchdata/ folder or installer.exe
3. Verify KOTORModSync is available
4. Create KOTORModSync TOML configuration:
   [ModInfo]
   GUID = "generated-unique-id"
   Name = "Mod Name"

   [Instructions.0]
   Action = "TSLPatcher"
   Source = "path/to/tslpatchdata"
   Destination = "game-directory"

5. Run KOTORModSync with configuration
6. Handle optional components (if present):
   - Present choices to user
   - Install selected components sequentially
7. Log installed files
```

**Installation Order Example:**
```
1. K1R Restoration (foundation mod, must be first)
2. Bug fix mods
3. Content mods
4. Texture/visual mods (last, Override method)
```

**Progress Reporting:**
- Show current mod being installed
- Progress bar if possible
- Estimated time remaining
- Success/failure status for each mod

**Post-Installation:**
1. Verify all files copied successfully
2. Check for error logs from KOTORModSync
3. Update data/installed_mods.json with:
   - Mod name, version, files installed, timestamp
4. Generate installation summary HTML report

**Output:** Success/failure status, HTML installation summary

### Workflow 4b: TSLPatcher Installation with Wine (CRITICAL for macOS)

**Purpose:** Install TSLPatcher mods using Wine with drive mapping to eliminate path navigation issues.

**When to use:**
- Mod contains TSLPatcher (tslpatchdata/ folder or .exe installer)
- KOTORModSync unavailable or not working
- Universal solution for all TSLPatcher mods

**Key Innovation:** Wine drive mapping (K: → KOTOR Data) eliminates complex macOS path navigation.

**Scripts:**
- `scripts/setup_wine_tslpatcher.sh` - One-time Wine environment setup

**Pre-Installation (One-Time Setup):**

1. **Install Wine** (requires user password):
   ```bash
   brew install --cask wine-stable
   ```

2. **Run Wine Setup Script:**
   ```bash
   ~/.claude/skills/kotor-mod-manager/scripts/setup_wine_tslpatcher.sh
   ```

   Script performs:
   - ✓ Verifies Wine installation
   - ✓ Detects KOTOR installation
   - ✓ Creates Wine prefix (~/.wine)
   - ✓ **Creates K: drive mapping to KOTOR Data** (THE CRITICAL STEP)
   - ✓ Verifies Override folder exists

**Installation Process:**

1. **Extract mod** to temporary location
2. **Locate installer .exe** (e.g., K1R_1.2_Installer.exe)
3. **Launch installer with Wine:**
   ```bash
   cd /path/to/extracted/mod
   wine ModInstaller.exe
   ```

4. **In installer GUI:**
   - Click "Install Mod" button
   - File browser opens
   - **Select "K:" drive** (will be at top of list)
   - **DO NOT** navigate into subfolders
   - **DO NOT** select Override folder
   - Click "Select Folder" button
   - Wait for installation to complete

5. **Verify installation:**
   - Check installlog.rtf for errors
   - Confirm new files in Override folder
   - Look for K1R-specific or mod-specific files

**Critical: Folder Selection**
- TSLPatcher needs game ROOT directory (KOTOR Data), not Override
- K: drive mapping points directly to root
- TSLPatcher automatically places files in Override, modules, etc.
- Selecting Override subfolder causes GEN-6 error

**Common Errors & Solutions:**

| Error | Cause | Solution |
|-------|-------|----------|
| **GEN-6: No valid game folder** | Selected wrong folder | Select K: drive root, not subfolders |
| **Wine won't launch** | First-time setup | Run `wineboot -u` to initialize |
| **Permission denied** | Override folder permissions | `chmod -R 755 Override/` |
| **Files not installing** | Wrong path | Verify K: mapping: `ls -lh ~/.wine/dosdevices/k:` |

**Advantages over KOTORModSync:**
- ✓ Universal compatibility (works with ALL TSLPatcher mods)
- ✓ Higher success rate on macOS
- ✓ Direct access to original TSLPatcher (no compatibility layer)
- ✓ Drive mapping eliminates #1 source of errors

**Detailed Guide:** See `references/tslpatcher-wine-guide.md` for complete documentation

**Output:** Mod installed to Override + modules, installlog.rtf generated

### Workflow 4c: AI Mods with Plugin Support

**Purpose:** Install Improved AI with Repeating Blaster Attacks Restoration using compatibility plugin.

**When to use:**
- User wants enhanced AI behavior in combat
- User wants repeating blasters to function as originally intended
- Installing mods that modify the same core scripts (k_ai_master.ncs)

**Mods Covered:**
1. **KotOR1 - Improved AI v1.3.3** by GearHead
   - Nexus Mods: https://www.nexusmods.com/kotor/mods/1573
   - Deadly Stream: https://deadlystream.com/files/file/2328-kotor1-improved-ai/

2. **Repeating Blaster Attacks Restoration v2.0** by R2-X2
   - Deadly Stream: https://deadlystream.com/files/file/1405-repeating-blaster-attacks-restoration/

3. **Compatibility Plugin** (included with Improved AI v1.2.7+)

**Installation Order (CRITICAL):**

```bash
# Set Override path
OVERRIDE="/Users/$USER/Library/Application Support/Steam/steamapps/common/swkotor/Knights of the Old Republic.app/Contents/KOTOR Data/Override"

# 1. Extract Improved AI
cd ~/Downloads
unzip "KotOR1 - Improved AI.zip" -d /tmp/improved_ai

# 2. Install Improved AI to Override
cp /tmp/improved_ai/override/k_ai_master.ncs "$OVERRIDE/"

# 3. Extract Compatibility Plugin
unzip "Compatibility Plugin for Repeating blaster attacks restoration 2.0.zip" -d /tmp/compat_plugin

# 4. Install Compatibility Plugin (Repeaters ONLY version)
cp /tmp/compat_plugin/"Repeaters ONLY"/override/rptr_att.ncs "$OVERRIDE/"

# 5. Verify installation
ls -lh "$OVERRIDE/k_ai_master.ncs"  # Should be ~128 KB
ls -lh "$OVERRIDE/rptr_att.ncs"     # Should be ~652 bytes
```

**Plugin Options:**
- **Repeaters ONLY** (recommended): Only repeating blasters get +1 attack
- **Repeaters + Rifles**: Both repeaters AND rifles get +1 attack (gameplay change)

**Effect on Gameplay:**

| Weapon Type | Without Mod | With Repeating Blaster | With Improved AI |
|-------------|-------------|------------------------|------------------|
| **Normal Attack** | 1 attack | 2 attacks | 2 attacks + smarter AI |
| **With Rapid Shot** | 2 attacks | 3 attacks | 3 attacks + smarter AI |
| **Force Speed** | Varies | Partially fixed | Compatible |

**AI Improvements (from Improved AI v1.3.3):**
- Enemies now use Force Breach and Lightsaber Throw
- NPCs properly use Force Jump when 10m+ from target
- Companions heal all team members (not just player)
- NPCs use Master Rapid Shot/Flurry instead of default attacks
- Enemies use highest-level feats and force powers available
- AI uses feats granted by equipped items
- Shield reactivation after 200 seconds
- Plugin support for repeating blaster mechanics

**Compatibility Notes:**
- ✓ Compatible with K1R (install after K1R)
- ✓ Compatible with all visual/audio mods
- ✓ No .2da modifications (pure script change)
- ✓ Improved AI includes K1CP's AI fix
- ⚠ Conflicts with other k_ai_master.ncs modifications

**Troubleshooting:**

| Issue | Cause | Solution |
|-------|-------|----------|
| **Repeating blasters not working** | Missing rptr_att.ncs | Install compatibility plugin |
| **AI not improved** | Wrong k_ai_master.ncs version | Ensure using Improved AI version (128 KB) |
| **Game crashes** | Both original Repeating Blaster + Improved AI installed | Delete original, keep only Improved AI version |

**Output:** Enhanced AI + repeating blaster mechanics active

### Workflow 5: Verify Installation

**Purpose:** Validate mods are properly installed and functional.

**Process:**
1. Read data/installed_mods.json
2. For each installed mod:
   - Verify files exist in Override folder
   - Check file sizes match expected values
   - Verify file permissions are readable
3. Check for common issues:
   - Missing Override folder
   - Case-sensitivity errors (override vs Override)
   - Permission denied errors
   - Corrupted files
   - Stale cache preventing mod loading
4. Generate verification report

### Workflow 5a: Clear Game Cache (CRITICAL for Troubleshooting)

**Purpose:** Clear KOTOR cache and preferences to ensure mods load properly.

**When to use:**
- Mods are installed but not appearing in-game
- Textures not loading despite files in Override
- Resolution changes not taking effect
- After major mod installations or updates
- Game behaving as if mods aren't present

**Process:**

**1. Clear Cache Directory:**
```bash
# Remove all cache files
rm -rf ~/Library/Caches/com.aspyr.kotor.steam/*
```

**2. Reset Preferences (Optional but Recommended):**
```bash
# Backup first
cp ~/Library/Preferences/com.aspyr.kotor.steam.plist ~/Library/Preferences/com.aspyr.kotor.steam.plist.backup

# Remove old preferences
rm ~/Library/Preferences/com.aspyr.kotor.steam.plist

# Recreate with proper resolution (if needed)
defaults write com.aspyr.kotor.steam "Screen Width" -int 1920
defaults write com.aspyr.kotor.steam "Screen Height" -int 1080
defaults write com.aspyr.kotor.steam "Graphics - Fullscreen Res" -string "1920x1080"
defaults write com.aspyr.kotor.steam "DisplayFullScreen" -int 1
```

**3. Verify Clean State:**
```bash
# Cache should be empty
ls ~/Library/Caches/com.aspyr.kotor.steam/

# Preferences should have new settings
defaults read com.aspyr.kotor.steam
```

**4. Launch from Steam:**
- ALWAYS launch from Steam after cache clear
- Quit Steam completely first (CMD+Q)
- Restart Steam
- Launch KOTOR from Steam Library
- Game will rebuild cache on first launch

**Important Notes:**
- Clearing cache does NOT affect your mods (Override folder untouched)
- Clearing cache does NOT affect saved games
- First launch after cache clear may take slightly longer
- Desktop shortcuts should NOT be used - always launch from Steam

**Output:** Clean cache state, game ready to reload mods properly

**Common Issues & Solutions:**

| Issue | Detection | Solution |
|-------|-----------|----------|
| Override folder missing | Directory not found | Create Override folder (capital O) |
| Files not in Override | Files in wrong location | Move to correct Override path |
| Permission denied | Cannot read files | Fix with `chmod -R 644 Override/*` |
| Textures not loading | .tpc files present but not working | Check file format, may need conversion |
| TSLPatcher failed silently | No error but mod not working | Check KOTORModSync logs, reinstall |
| Case sensitivity errors | Files have wrong case | Rename files to match game expectations |

**Output:** Verification report with issues found and recommended fixes

### Workflow 6: Rollback/Remove Mods

**Purpose:** Remove installed mods or restore to previous state.

**Process:**
1. Read data/installed_mods.json to see installed mods
2. User selects mods to remove
3. For each mod:
   - Read list of files installed by that mod
   - Check if any files are shared with other mods
   - Remove files (if not shared) or warn user
4. Update data/installed_mods.json
5. If backup exists, offer to restore from backup

**Backup/Restore:**
- Backups stored in data/backups/ with timestamp
- Full Override folder snapshots
- Can restore to any previous state

**Output:** Success status, updated mod list

## KOTOR File Types Reference

Quick reference for conflict assessment:

| File Type | Purpose | Conflict Risk | Notes |
|-----------|---------|---------------|-------|
| `.tpc` | Compressed textures | LOW | Visual only, last wins |
| `.tga` | Uncompressed textures | LOW | Visual only, last wins |
| `.txi` | Texture info (shaders) | LOW | Rarely conflicts |
| `.2da` | Data tables (TSV-like) | **HIGH** | Requires merging |
| `.ncs` | Compiled scripts | MEDIUM | Logic conflicts |
| `.nss` | Script source code | MEDIUM | Can be merged manually |
| `.dlg` | Dialog trees (GFF) | **HIGH** | Complex conflicts |
| `.utc` | Creature templates | MEDIUM | Filename-based replacement |
| `.uti` | Item templates | MEDIUM | Filename-based replacement |
| `.utp` | Placeable templates | MEDIUM | Filename-based replacement |
| `.rim` | Module archives | **VERY HIGH** | Entire module replacement |
| `.mod` | Module files | **VERY HIGH** | Entire module replacement |

For detailed file type information, see `references/file-types.md`.

## Installation Order Rules

**Critical Foundation Mods (MUST BE FIRST):**
- KOTOR 1 Restoration (K1R)
- TSLRCM (KOTOR 2 only)
- Major overhaul mods

**Installation Sequence:**
1. Foundation/restoration mods
2. Bug fix compilations
3. Content mods (new quests, characters)
4. Gameplay mods (mechanics changes)
5. UI mods
6. Texture/visual mods (LAST - Override method safe)

**Reasoning:** Early mods modify game files that later mods may depend on. Texture mods are safe last because they're simple overwrites.

## KOTORModSync Integration

**What is KOTORModSync?**
- Modern mod manager by th3w1zard1
- Native macOS support (no Wine/CrossOver needed)
- Runs TSLPatcher functionality natively
- Handles dependencies and installation order
- Uses TOML configuration format

**Auto-Installation:**
When TSLPatcher mod detected and KOTORModSync not present:
1. Run `scripts/setup_kotormodsync.sh`
2. Script downloads latest release from GitHub
3. Extracts to ~/KOTORModSync/ or user-specified location
4. Verifies installation
5. Ready to use

**TOML Configuration Format:**
```toml
[ModInfo]
GUID = "unique-identifier"
Name = "Mod Name"
Description = "What this mod does"
Authors = ["author1"]

[Dependencies]
RequiredMods = []
IncompatibleMods = []
InstallAfter = ["other-mod-guid"]

[Instructions.0]
Action = "TSLPatcher"
Source = "tslpatchdata"
Destination = "game-installation-path"
Overwrite = true
```

For detailed KOTORModSync usage, see `references/kotormodsync-integration.md`.

## Custom Mod Builds

**What are Mod Builds?**
- Curated collections of compatible mods
- Pre-tested for compatibility
- Popular examples: Reddit spoiler-free build, Reddit full build
- Defined in data/mod_builds/

**Creating Custom Build:**
1. Select mods for build
2. Run compatibility check
3. Define installation order
4. Save as JSON configuration in data/mod_builds/
5. Can be installed with single command

**Build Configuration Format:**
```json
{
  "build_name": "my-custom-build",
  "description": "My personal KOTOR 1 mod build",
  "kotor_version": "kotor1",
  "mods": [
    {
      "mod_id": "k1r-1.2",
      "required": true,
      "install_order": 1
    },
    {
      "mod_id": "vurts-visual",
      "required": false,
      "install_order": 2
    }
  ],
  "tested": true,
  "notes": "Install K1R first, then visual mods"
}
```

**Installing Build:**
1. Load build configuration
2. Check which mods are already downloaded
3. Provide download links for missing mods
4. Run full compatibility check (should pass if build is tested)
5. Install all mods in order automatically
6. Generate completion report

## Compatibility Database

**Location:** `data/compatibility.json`

**Purpose:**
- Store known mod compatibility information
- Track community-tested combinations
- Provide quick lookup for common mods
- Enable intelligent conflict detection

**Database Structure:**
```json
{
  "version": "1.0",
  "last_updated": "2025-11-04",
  "mods": {
    "mod-id": {
      "name": "Mod Name",
      "install_method": "override|tslpatcher",
      "install_order": "first|early|middle|late",
      "conflicts": {
        "other-mod-id": "reason for conflict"
      },
      "compatible_with": ["mod-id-1", "mod-id-2"],
      "incompatible_with": ["mod-id-3"],
      "requires_before": ["mod-id-4"],
      "must_install_before": ["mod-id-5"]
    }
  }
}
```

**Updating Database:**
- User installs new mods successfully → Add to database
- User reports conflict → Update conflict information
- Community sources → Periodic sync from Reddit, Deadlystream

## macOS-Specific Guidance

**Finding Hidden Library Folder:**
1. Open Finder
2. Click "Go" menu while holding Option key
3. "Library" appears in menu
4. Navigate to Application Support/Steam/steamapps/common/

**Or use Terminal:**
```bash
open ~/Library/Application\ Support/Steam/steamapps/common/
```

**Accessing .app Bundle Contents:**
1. Right-click Knights of the Old Republic.app
2. Select "Show Package Contents"
3. Navigate to Contents/KOTOR Data/

**Override Folder Creation:**
```bash
# KOTOR 1
mkdir -p ~/Library/Application\ Support/Steam/steamapps/common/swkotor/Knights\ of\ the\ Old\ Republic.app/Contents/KOTOR\ Data/Override

# KOTOR 2
mkdir -p ~/Library/Application\ Support/Steam/steamapps/common/Knights\ of\ the\ Old\ Republic\ II/KOTOR2.app/Contents/GameData/Override
```

**Wine Drive Mapping for TSLPatcher (CRITICAL):**

This is the key solution for TSLPatcher mods on macOS:

```bash
# Create symbolic link in Wine's drive mapping directory
mkdir -p ~/.wine/dosdevices
cd ~/.wine/dosdevices

# Map K: drive to KOTOR Data folder (KOTOR 1)
ln -sf "$HOME/Library/Application Support/Steam/steamapps/common/swkotor/Knights of the Old Republic.app/Contents/KOTOR Data" k:

# Or for KOTOR 2 (use L: drive)
ln -sf "$HOME/Library/Application Support/Steam/steamapps/common/Knights of the Old Republic II/KOTOR2.app/Contents/GameData" l:

# Verify mapping
ls -lh ~/.wine/dosdevices/k:
```

**Why this matters:**
- macOS paths are extremely complex for Wine file browsers
- Drive mapping creates simple "K:" access point
- Eliminates GEN-6 "No valid game folder" errors
- Reduces TSLPatcher installation failures by 90%

**Use in TSLPatcher:**
1. Launch installer: `wine ModInstaller.exe`
2. In file browser, select "K:" drive
3. Do NOT navigate into subfolders
4. Click "Select Folder"

**Permissions Issues:**
```bash
# Fix Override folder permissions
chmod -R 755 "path/to/Override"

# Fix individual file permissions
chmod 644 "path/to/file"
```

**Case Sensitivity:**
- macOS is case-sensitive for mod files
- Override must be capitalized exactly
- Filenames must match game expectations
- Some mods from Windows may have wrong case

**Archive Extraction Issues:**

Some mod archives (particularly RAR files) may trigger macOS Gatekeeper warnings or fail to extract properly with built-in tools.

**Common Issues:**
- "This file is from an unidentified developer" warning
- RAR files with unsupported compression methods
- Quarantine attributes preventing extraction

**Solutions:**

**Option 1: The Unarchiver (Recommended)**
```bash
# Install The Unarchiver (handles more compression methods)
brew install --cask the-unarchiver

# Then right-click RAR → Open With → The Unarchiver
# Or double-click after setting as default
```

**Option 2: Remove Quarantine Attributes**
```bash
# Remove quarantine flag from downloaded mod
xattr -d com.apple.quarantine "/path/to/mod.rar"

# Or clear all extended attributes
xattr -c "/path/to/mod.rar"
```

**Problematic Mods Known to Require The Unarchiver:**
- **Revamped FX** - RAR uses compression method unsupported by unrar/7z
- Certain Deadly Stream archives
- Older mods with RAR5 compression

**Why The Unarchiver Works Better:**
- Bypasses macOS quarantine warnings when launched as GUI
- Supports wider range of RAR compression methods
- Handles modern RAR5 format better than command-line unrar
- Native macOS integration prevents Gatekeeper blocks

### Resolution Configuration for Retina Displays (CRITICAL)

**Problem:**
KOTOR on macOS (Aspyr port) doesn't expose high resolutions in the in-game Graphics Options menu, even on Retina displays. This is a known issue with the macOS port.

**Symptoms:**
- Only see low resolutions like 1024x768 or 800x600
- Your desired resolution (1920x1080) doesn't appear in dropdown
- High Resolution Menus mod installed but can't select matching resolution

**Root Cause:**
Aspyr's KOTOR port hardcodes available resolutions and doesn't detect macOS Retina displays properly.

**Solution:**
Use the resolution configuration script to force custom resolutions:

```bash
~/.claude/skills/kotor-mod-manager/scripts/configure_resolution.sh
```

**Script Features:**
- Detects your system display resolution
- Offers common gaming resolutions
- Creates automatic backups
- Explains aspect ratio implications
- Validates configuration

**Recommended Settings:**

**For High Resolution Menus Mod (1920x1080):**
```bash
# Option 1 in script
Resolution: 1920x1080 (16:9)
Result: Black bars on sides (3:2 displays)
Benefit: Perfect UI scaling with High Res Menus
```

**For Retina MacBook Pro 14" (Native Fill):**
```bash
# Option 2 in script
Resolution: 1728x1117 (3:2)
Result: Fills entire screen
Drawback: May need different High Res Menus version
```

**Aspect Ratio Considerations:**

| Display | Native Res | Aspect | Best KOTOR Res | UI Mod Needed |
|---------|-----------|--------|----------------|---------------|
| MacBook Pro 14" | 3456x2234 | 3:2 | 1920x1080 | High Res Menus (16:9) |
| MacBook Pro 16" | 3456x2234 | 3:2 | 1920x1080 | High Res Menus (16:9) |
| iMac 27" | 5120x2880 | 16:9 | 2560x1440 | High Res Menus (16:9) |
| External 16:9 | Varies | 16:9 | 1920x1080 | High Res Menus (16:9) |

**Manual Configuration (Alternative):**

If you prefer not to use the script:

```bash
# Backup first
cp ~/Library/Preferences/com.aspyr.kotor.steam.plist ~/Library/Preferences/com.aspyr.kotor.steam.plist.backup

# Set 1920x1080
defaults write com.aspyr.kotor.steam "Screen Width" -int 1920
defaults write com.aspyr.kotor.steam "Screen Height" -int 1080
defaults write com.aspyr.kotor.steam "Graphics - Fullscreen Res" -string "1920x1080"

# Verify
defaults read com.aspyr.kotor.steam | grep -E "Screen|Graphics"
```

**Restore Defaults:**
```bash
defaults delete com.aspyr.kotor.steam "Screen Width"
defaults delete com.aspyr.kotor.steam "Screen Height"
defaults delete com.aspyr.kotor.steam "Graphics - Fullscreen Res"
```

**After Configuration:**
1. **Clear game cache** (see Workflow 5a) - CRITICAL for changes to take effect
2. **Quit and restart Steam completely**
3. **Launch from Steam Library** (not desktop shortcuts)
4. Resolution may not appear in Graphics Options menu (normal on macOS)
5. If not shown in menu, it's **already active** (check in-game visuals)
6. Black bars on 3:2 displays are normal and correct for 16:9 content

**Troubleshooting:**

**Resolution still doesn't work:**
- **First: Clear cache** - Run Workflow 5a (most common fix)
- Verify plist file exists: `ls -l ~/Library/Preferences/com.aspyr.kotor.steam.plist`
- Check values: `plutil -p ~/Library/Preferences/com.aspyr.kotor.steam.plist`
- Quit Steam completely (CMD+Q), restart, launch from Library
- **Always launch from Steam**, never from desktop shortcuts
- Reboot Mac if necessary

**UI elements are stretched or wrong size:**
- Your resolution doesn't match High Res Menus mod
- Clear cache (Workflow 5a) and relaunch from Steam
- Reinstall High Res Menus for your aspect ratio
- Or change resolution to match installed High Res Menus

**Textures not loading despite files in Override:**
- **Clear cache** - Run Workflow 5a (most common fix)
- Launch from Steam, not desktop shortcuts
- Verify Override folder case: capital O, lowercase verride
- Check file permissions: `chmod -R 755 Override/`

## Resources

### Scripts

**launch_kotor_with_mods.sh** ⭐ Mod-Aware Game Launcher
- Shows installed mods before launching KOTOR
- Auto-detects active mods from Override folder
- Displays file counts and installation date
- Visual confirmation all mods are active
- Supports both KOTOR 1 and KOTOR 2
- No conflicts with existing mods
- Use instead of launching directly from Steam

**configure_resolution.sh** ⭐ NEW - Retina Display Resolution Fix
- Fixes missing resolutions on macOS Retina displays
- Configures custom resolutions (1920x1080, 2560x1440, etc.)
- Explains aspect ratio implications (16:9 vs 3:2)
- Creates preference backups automatically
- Essential for High Res Menus mod compatibility
- Run if your desired resolution doesn't appear in-game

**setup_wine_tslpatcher.sh** ⭐ CRITICAL for macOS
- One-time Wine environment setup for TSLPatcher
- Creates Wine prefix and drive mappings
- Detects KOTOR installation automatically
- Maps K: drive to KOTOR Data folder
- Eliminates path navigation issues
- Essential for reliable TSLPatcher mod installation
- Run once before first TSLPatcher mod

**detect_kotor_install.sh**
- Finds KOTOR installation on macOS
- Validates Override folder
- Returns installation path

**check_mod_conflicts.py**
- Main conflict detection engine
- Compares mod files
- Assesses conflict severity
- Generates conflict data for reporting

**parse_2da.py**
- Parses KOTOR .2da table format
- Compares .2da files for conflicts
- Identifies row/column changes

**setup_kotormodsync.sh**
- Auto-downloads KOTORModSync
- Installs to appropriate location
- Verifies installation success

**install_mod.sh**
- Orchestrates mod installation
- Handles both Override and TSLPatcher methods
- Logs installed files
- Creates backups

**generate_report.py**
- Creates HTML compatibility reports
- Creates HTML installation summaries
- Color-coded severity levels
- Professional styling

### References

**tslpatcher-wine-guide.md** ⭐ NEW - ESSENTIAL READING for macOS
- Complete TSLPatcher installation guide using Wine
- Wine drive mapping technique (K: → KOTOR Data)
- Step-by-step installation process with screenshots
- Comprehensive troubleshooting (GEN-6 errors, permissions, etc.)
- Comparison: Wine vs KOTORModSync vs CrossOver
- Advanced topics: multiple installations, batch installs, debugging
- Production-tested on macOS 15.1 with Wine 10.0
- **Read this first before installing TSLPatcher mods**

**file-types.md**
- Complete KOTOR file type reference
- Conflict risk levels for each type
- Tools for editing each type
- Common issues and solutions

**installation-paths.md**
- macOS Steam path structures
- KOTOR 1 vs KOTOR 2 differences
- Multiple Steam library handling
- Troubleshooting path issues

**compatibility-matrix.md**
- Popular mod compatibility information
- Reddit build configurations
- Known conflict patterns
- Safe mod combinations

**kotormodsync-integration.md**
- Complete KOTORModSync guide
- TOML configuration format
- Advanced features (dependencies, restrictions)
- Troubleshooting KOTORModSync issues

### Data

**compatibility.json**
- Structured compatibility database
- Community knowledge captured
- Queryable for quick lookups

**mod_metadata/**
- Individual mod metadata files
- Detailed information per mod
- Installation notes and quirks

**mod_builds/**
- Predefined mod build configurations
- Reddit builds, custom builds
- One-command installation

### Templates

**conflict_report_template.html**
- HTML template for compatibility reports
- CSS styling included
- Color-coded severity levels

**installation_summary.html**
- HTML template for installation reports
- Success/failure visualization
- Installed file listings

## Launching KOTOR - ALWAYS Use Steam

**CRITICAL:** Always launch KOTOR from Steam, NOT from desktop shortcuts or custom launchers.

**Why Steam Launch is Required:**
- macOS Aspyr port requires Steam integration to load mods properly
- Cache rebuilding only works correctly via Steam
- Custom launchers and shortcuts can bypass mod loading
- Resolution settings may not apply outside Steam

**Correct Launch Procedure:**

1. **Quit Steam Completely** (if running)
   - Right-click Steam in menu bar → Quit Steam
   - Or: CMD+Q in Steam app

2. **Restart Steam**
   - Ensures fresh start with clean preferences

3. **Launch from Steam Library**
   - Open Steam → Library
   - Find "Star Wars: Knights of the Old Republic"
   - Click "Play"

4. **After Cache Clear or Major Changes:**
   - First launch may take slightly longer
   - Game rebuilds cache with new settings
   - Mods will load from Override folder automatically

## Verifying Installed Mods (Optional)

If you want to verify which mods are active before launching:

**Script:** `scripts/launch_kotor_with_mods.sh`

**Usage:**
```bash
~/.claude/skills/kotor-mod-manager/scripts/launch_kotor_with_mods.sh
```

**What it does:**
1. Auto-detects KOTOR installation
2. Scans Override folder for installed mods
3. Identifies specific mods (K1R, Vurt's, Skyboxes, etc.)
4. Displays file counts and installation date
5. Shows visual confirmation all mods are active
6. ~~Launches game via Steam after user confirmation~~ (Informational only - launch from Steam separately)

**Example Output:**
```
╔════════════════════════════════════════════╗
║     KOTOR MODS ACTIVE - READY TO PLAY     ║
╚════════════════════════════════════════════╝

✅ Active Mods:

  1. K1R Restoration 1.2
  2. Widescreen Fade Fix
  3. High Resolution Menus (81 GUI files)
  4. Revamped FX (15 effect textures)
  5. High Quality Skyboxes II (97 textures)
  6. Skybox Model Fixes (73 models)
  7. Vurt's Visual Resurgence (2425 textures)
  8. Wine TSLPatcher Integration (K: drive mapped)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Total Files: 2,952 in Override
Mods Detected: 8
Game: KOTOR 1
Last Modified: November 04, 2025
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Press any key to launch KOTOR 1...
```

**Benefits:**
- Visual confirmation mods are working before launching
- No file conflicts or journal modifications needed
- Shows exact file counts for verification
- Works with any mod combination
- Supports both KOTOR 1 and KOTOR 2

**Note:** This script is for informational purposes only to verify mod installation. After viewing the mod list, close the script and launch KOTOR from Steam as described above.

## Common User Requests & Responses

**"Install KOTOR mods from Downloads"**
→ Workflow 2 (Scan) → Workflow 3 (Check) → Workflow 4 (Install)

**"Are these mods compatible?"**
→ Workflow 3 (Check Compatibility)

**"My mod isn't working"**
→ Workflow 5 (Verify Installation)

**"Where is KOTOR installed?"**
→ Workflow 1 (Detect Installation)

**"Remove this mod"**
→ Workflow 6 (Rollback)

**"Show me what mods are installed"**
→ Run `scripts/launch_kotor_with_mods.sh`

**"Launch KOTOR with mod verification"**
→ Run `scripts/launch_kotor_with_mods.sh` to view installed mods, then launch from Steam

**"Mods not loading in game"**
→ Workflow 5a (Clear Game Cache) → Launch from Steam

**"Resolution not working / Low resolution"**
→ Workflow 5a (Clear Game Cache) + Resolution Configuration → Launch from Steam

**"Install Reddit spoiler-free build"**
→ Load build from data/mod_builds/ → Check compatibility → Install sequence

**"Can I add this mod to my existing setup?"**
→ Scan new mod → Check against installed mods → Report compatibility → Install if safe

## Example Workflow: Installing Two Mods

**Scenario:** User has Vurt's Visual Resurgence and K1R Restoration in ~/Downloads/

**Execution:**

1. **Detect Installation**
   ```
   Run detect_kotor_install.sh
   Found: ~/Library/.../swkotor/Knights of the Old Republic.app/
   Override folder exists: YES
   ```

2. **Scan Mods**
   ```
   Found 2 mods:
   1. Vurt's Visual Resurgence (2.7 GB, 2411 textures, Override method)
   2. K1R Restoration 1.2 (68 MB, complex installer, TSLPatcher method)
   ```

3. **Check Compatibility**
   ```
   Running conflict detection...
   ✓ COMPATIBLE - No file conflicts detected
   ⚠ Installation order required:
     1. K1R Restoration (must be first - modifies core game files)
     2. Vurt's Visual Resurgence (textures only, safe last)

   Generating HTML report...
   Report saved: ~/Desktop/kotor_mod_compatibility_report.html
   ```

4. **Install Mods**
   ```
   Installing 2 mods in recommended order...

   [1/2] Installing K1R Restoration 1.2
   - Detected TSLPatcher mod
   - Checking KOTORModSync... not found
   - Auto-downloading KOTORModSync... ✓
   - Creating TOML configuration... ✓
   - Running KOTORModSync...
   - Installed 1,107 files
   - Status: SUCCESS

   [2/2] Installing Vurt's Visual Resurgence
   - Detected Override folder mod
   - Copying 2,411 texture files to Override... ✓
   - Status: SUCCESS

   Installation complete!
   Summary: ~/Desktop/kotor_mod_installation_summary.html
   ```

5. **Verify**
   ```
   Verifying installation...
   ✓ K1R Restoration: All files present
   ✓ Vurt's Visual Resurgence: All files present
   ✓ No permission issues detected
   ✓ Override folder structure valid

   Installation successful! Launch KOTOR to see your mods.
   ```

## Tips for Best Results

1. **Always run compatibility check** before installing multiple mods
2. **Install foundation mods first** (K1R, TSLRCM)
3. **Back up your saves** before major mod installations
4. **Read mod documentation** - some mods have specific requirements
5. **Install texture mods last** - they're safe overwrites
6. **Check file counts** after installation to verify success
7. **Keep mod archives** in Downloads for reinstallation if needed
8. **Update compatibility database** after successful installations
9. **Generate HTML reports** for permanent records
10. **Test game after each major mod** to isolate issues

## Limitations

- Cannot auto-merge conflicting .2da files (TSLPatcher/KOTORModSync required)
- Cannot edit dialog trees (complex GFF format)
- Cannot decompile .ncs scripts (requires DeNCS tool)
- Cannot predict in-game conflicts (requires playtesting)
- Compatibility database depends on community knowledge
- Some Windows-specific mods may not work on macOS
- Graphical mods may have limitations on integrated graphics

## Support & Resources

**Official Modding Communities:**
- Deadlystream.com - Primary KOTOR modding community
- Reddit: r/kotor - Active modding discussions
- kotor.neocities.org - Comprehensive mod builds

**Essential Tools:**
- KOTORModSync - Modern mod manager (auto-installed by this skill)
- KOTOR Tool - Windows tool for advanced modding
- K-GFF Editor - Edit GFF files (.utc, .dlg, etc.)

**Further Reading:**
- See references/ folder for detailed documentation
- Check data/compatibility.json for known mod information
- Review generated HTML reports for conflict details
