# KOTOR Mod Manager for macOS

A comprehensive Claude Code skill for managing Knights of the Old Republic (KOTOR) mods on macOS via Steam.

**Author:** Pnutmaster (TWCenter, Crusader Kings II, Rome II: Total War, Fallout: New Vegas modding communities)

## Features

- **Automatic Installation Detection** - Finds KOTOR 1 & 2 installations on macOS
- **Mod Compatibility Checking** - Analyzes conflicts between mods before installation
- **Native macOS Support** - Handles hidden Library folders, .app bundles, and permissions
- **TSLPatcher Integration** - Auto-installs and uses KOTORModSync for complex mods
- **.2da File Analysis** - Detects data table conflicts and merging requirements
- **HTML Reports** - Generates visual compatibility and installation reports
- **Installation Order Management** - Recommends optimal mod installation sequence
- **Custom Mod Builds** - Support for curated mod collections (Reddit builds)

## Quick Start

### Installation

This skill comes pre-packaged. Simply unzip and place in your Claude Code skills directory:

```bash
unzip kotor-mod-manager.zip
mv kotor-mod-manager ~/.claude/skills/
```

### Usage Examples

**Check Steam Configuration (REQUIRED FIRST!):**
```bash
bash ~/.claude/skills/kotor-mod-manager/scripts/check_steam_config.sh
```

**Detect KOTOR Installation:**
```bash
bash ~/.claude/skills/kotor-mod-manager/scripts/detect_kotor_install.sh
```

**Check Mod Compatibility:**
```bash
python3 ~/.claude/skills/kotor-mod-manager/scripts/check_mod_conflicts.py \
    ~/Downloads/mod1.zip \
    ~/Downloads/mod2.zip
```

**Parse .2da Files:**
```bash
python3 ~/.claude/skills/kotor-mod-manager/scripts/parse_2da.py \
    baseitems.2da \
    baseitems_mod.2da
```

**Setup KOTORModSync:**
```bash
bash ~/.claude/skills/kotor-mod-manager/scripts/setup_kotormodsync.sh
```

## ⚠️ CRITICAL: Steam Version Configuration

**If you're using the Steam version of KOTOR, you MUST configure Steam settings before installing mods, or your mods will not work.**

The Steam version requires these changes:

1. **Disable Steam Overlay** - Prevents crashes and conflicts
2. **Disable Cloud Save** - Prevents save corruption with mods
3. **Disable Auto-Update** - Prevents Steam from overwriting modified executables
4. **Create Desktop Shortcut** - Launch from modded executable, not Steam
5. **Never Launch Through Steam** - Use desktop shortcut only

### Quick Configuration Check

Run this command to verify your Steam configuration:

```bash
bash ~/.claude/skills/kotor-mod-manager/scripts/check_steam_config.sh
```

This interactive script will:
- Detect your Steam KOTOR installation
- Check Steam overlay and cloud save settings
- Verify desktop shortcuts exist
- Guide you through required configuration steps
- Optionally create a desktop shortcut for you

### Why This Matters

From the KOTOR modding community:

> "If you use the Steam version there are specific configuration steps required to disable Steam overlay, cloud save, auto update. Do not launch the game thru Steam as you must use a modified executable."
>
> — [KOTOR 2025 Mod Guide](https://www.nexusmods.com/kotor/mods/1705)

**Common Issues When Steam is Not Configured:**

- ❌ Game crashes on launch (Steam Overlay enabled)
- ❌ Mods disappear after restarting (Cloud Save overwriting)
- ❌ Modified executable missing (Auto-Update overwrote it)
- ❌ Mods not loading (Launching through Steam)

### Detailed Instructions

For complete step-by-step instructions, see:

**[Steam Configuration Guide](references/steam-configuration.md)**

This comprehensive guide includes:
- Detailed steps for disabling each Steam feature
- macOS-specific instructions for hidden folders
- Desktop shortcut creation methods
- Backup strategies for modified executables
- Troubleshooting common Steam-related issues

## How It Works

### When You Say:

**"Install KOTOR mods from Downloads"**

The skill will:
1. Detect your KOTOR installation location
2. Scan ~/Downloads/ for mod archives
3. Analyze each mod's files and installation method
4. Check compatibility between all mods
5. Generate HTML compatibility report
6. Recommend installation order
7. Install mods (Override folder or TSLPatcher via KOTORModSync)
8. Verify installation success

### Supported Mod Types

- **Override Folder Mods** - Texture mods, simple replacements
- **TSLPatcher Mods** - K1R, TSLRCM, complex content mods
- **Hybrid Mods** - Both TSLPatcher and Override components

### Conflict Detection

The skill detects and categorizes conflicts by risk level:

- 🚫 **VERY HIGH** - .2da tables, module files (.rim/.mod)
- ❌ **HIGH** - Dialog files (.dlg), major script conflicts
- ⚠️ **MEDIUM** - Scripts (.ncs), templates (.utc/.uti/.utp)
- ℹ️ **LOW** - Textures (.tpc/.tga), audio, models

## File Structure

```
kotor-mod-manager/
├── SKILL.md                     # Main skill documentation
├── README.md                    # This file
├── scripts/                     # Executable scripts
│   ├── check_steam_config.sh    # Verify Steam configuration (RUN FIRST!)
│   ├── detect_kotor_install.sh  # Find KOTOR on macOS
│   ├── check_mod_conflicts.py   # Conflict detection
│   ├── parse_2da.py             # .2da file parser
│   └── setup_kotormodsync.sh    # Install KOTORModSync
├── references/                  # Reference documentation
│   ├── steam-configuration.md   # Steam setup guide (CRITICAL!)
│   ├── file-types.md            # KOTOR file type reference
│   ├── installation-paths.md    # macOS path guide
│   ├── compatibility-matrix.md  # Known mod compatibility
│   ├── kotormodsync-integration.md  # KOTORModSync guide
│   └── tslpatcher-wine-guide.md # Wine TSLPatcher setup
├── data/                        # Data files
│   ├── compatibility.json       # Compatibility database
│   ├── mod_metadata/            # Individual mod info
│   └── mod_builds/              # Curated mod builds
└── templates/                   # HTML templates
    └── conflict_report_template.html
```

## Requirements

- **macOS** (tested on macOS 14+)
- **Python 3.x** (standard on macOS)
- **Bash** (standard on macOS)
- **KOTOR 1 or 2** installed via Steam
- **Internet connection** (for downloading KOTORModSync)

## Mods in Compatibility Database

The database includes complete metadata for 10 production-tested mods:

**Foundation & Content:**
1. **K1R Restoration 1.2** - Restores cut content (dialog, items, missions, impossible difficulty)

**Gameplay & AI:**
2. **Improved AI v1.3.3** by GearHead - Enhanced combat AI, Force power usage, companion healing
3. **Repeating Blaster Attacks Restoration v2.0** by R2-X2 - Restores +1 attack per round for repeaters

**Resolution & UI:**
4. **High Resolution Menus 1.5** - 1920x1080 UI for modern displays
5. **1080p 60fps Fix** - Proper widescreen and frame rate support
6. **Widescreen Fade Fix** - Fixes transition effects for widescreen

**Visual Enhancements:**
7. **Vurt's Visual Resurgence 0.99a** - 2,411 high-resolution textures
8. **High Quality Skyboxes II 2.2** - Remastered space environments
9. **Skybox Model Fixes 1.0** - Fixes Taris exterior animations
10. **Revamped FX 1.0.1** - Enhanced combat effects, Force powers, explosions

All mods tested together with 2,954 files in Override folder on macOS Sequoia 15.1.

## macOS-Specific Features

- **Hidden Library Folder Navigation** - Guides for accessing hidden folders
- **.app Bundle Handling** - Navigates inside KOTOR .app files
- **Override Folder Management** - Creates and validates Override folders
- **Permission Fixing** - Handles macOS file permission issues
- **Case Sensitivity Support** - Handles both case-sensitive and case-insensitive filesystems

## KOTORModSync Integration

This skill automatically downloads and uses KOTORModSync, the modern KOTOR mod manager:

- **Native macOS TSLPatcher** - No Wine or CrossOver needed
- **Dependency Management** - Automatic mod dependency resolution
- **TOML Configuration** - Human-readable mod instructions
- **Multi-Mod Installation** - Install entire mod builds in one command

## Workflows

### 1. Detect Installation
Find KOTOR on your Mac and validate Override folders.

### 2. Scan Mods
Discover mods in Downloads and analyze their structure.

### 3. Check Compatibility
Detect conflicts and assess risk levels.

### 4. Install Mods
Install in optimal order using appropriate method.

### 5. Verify Installation
Validate all files are correctly installed.

### 6. Rollback/Remove
Remove mods or restore from backups.

## Tips for Best Results

1. **Configure Steam settings BEFORE installing any mods** (see Steam Configuration section)
2. Always run compatibility check before installing multiple mods
3. Install foundation mods (K1R, TSLRCM) first
4. Back up your saves before major mod installations
5. Install texture mods last (safe overwrites)
6. Test game after each major mod to isolate issues
7. **Always launch using desktop shortcut, NEVER through Steam**

## Troubleshooting

### Mods Not Working / Game Crashing

**First, check your Steam configuration!**

```bash
bash ~/.claude/skills/kotor-mod-manager/scripts/check_steam_config.sh
```

Most mod issues are caused by incorrect Steam settings:

- Steam Overlay enabled → Crashes
- Cloud Save enabled → Mods disappear
- Auto-Update enabled → Modified executable overwritten
- Launching through Steam → Mods don't load

See [Steam Configuration Guide](references/steam-configuration.md) for solutions.

### KOTOR Not Found

- Check Steam is installed
- Verify KOTOR is downloaded
- Look for additional Steam library locations

### Override Folder Missing

- Skill will create it automatically with proper capitalization (capital O)

### Permission Denied

```bash
chmod -R 755 "path/to/Override"
```

### KOTORModSync Installation Fails

- Visit <https://github.com/th3w1zard1/KOTORModSync/releases>
- Download macOS version manually
- Extract to ~/KOTORModSync/

### Modified Executable Missing After Steam Update

If Steam overwrote your modded executable:

```bash
# Option 1: Restore from backup (if you made one)
cd ~/Library/Application\ Support/Steam/steamapps/common/swkotor
cp -r "Knights of the Old Republic.app.modded.backup" "Knights of the Old Republic.app"

# Option 2: Re-install mods
# Run your mod installers again (TSLPatcher, KOTORModSync)
```

Then disable auto-update as described in the Steam Configuration Guide.

## Support & Resources

**Comprehensive Mod Guides:**
- [KOTOR 2025 Mod Guide (Nexus Mods)](https://www.nexusmods.com/kotor/mods/1705) - Complete modding guide with automated and manual installation options, tested on multiple systems for ~10 years
- [KOTOR 2025 Mod Guide (Deadly Stream)](https://deadlystream.com/files/file/2689-kotor-2025-mod-guide/) - Restores cut content that Community Patch does not, updates resolution/UI, fixes bugs
- [Nexus Mods - KOTOR](https://www.nexusmods.com/kotor) - Primary mod repository with thousands of mods and active community

**Communities:**
- [Deadly Stream](https://deadlystream.com/) - Premier KOTOR modding community, mod hosting, and technical resources
- [r/kotor](https://reddit.com/r/kotor) - Reddit community with modding guides, spoiler-free builds, and support

**Essential Tools:**
- [KOTORModSync](https://github.com/th3w1zard1/KOTORModSync) - Modern mod manager for macOS/Windows with native TSLPatcher support
- [KOTOR Tool](https://deadlystream.com/files/file/280-kotor-tool/) - Advanced modding suite (Windows only)
- [TSLPatcher](https://deadlystream.com/files/file/1604-tslpatcher-v108b/) - Industry-standard mod installer for complex content mods

**Key Mods Referenced in 2025 Community Guides:**
- **K1R Restoration 1.2** - Restores substantial cut content including dialogue, hidden items, and missions that Community Patch does not restore
- **High Resolution Menus** - 1920x1080 UI upgrade for modern displays
- **Widescreen Fixes** - Proper aspect ratio support and fade fixes
- **HD Texture Packs** - AI-upscaled cutscenes, planetary skyboxes, and character models
- **Community Patch** - Alternative to K1R (incompatible - choose one or the other)

## Version History

### 1.0 (2025-11-04)
- Initial release
- KOTOR 1 & 2 detection on macOS
- Conflict detection for .2da, scripts, textures
- KOTORModSync auto-installation
- HTML report generation
- Compatibility database with 2 example mods

## License

This skill is provided as-is for use with Claude Code. Includes references to community resources and tools.

## Credits

- **Author:** Pnutmaster - Contributing modder from TWCenter, Crusader Kings II, Rome II: Total War, and Fallout: New Vegas communities
- **Created for:** Claude Code users and the KOTOR modding community
- **Research from:** Deadly Stream, Nexus Mods, Reddit r/kotor, KOTOR 2025 Mod Guide community
- **Tools Referenced:** KOTORModSync by th3w1zard1, TSLPatcher by stoffe, Wine compatibility layer
- **Special Thanks:** Hraith (KOTOR 2025 Mod Guide), Deadly Stream modding community, and all KOTOR mod creators who have preserved this classic RPG

---

**May the Force be with your modding journey!** ⚔️
