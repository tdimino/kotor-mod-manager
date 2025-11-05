# KOTORModSync Integration Guide

Complete guide to using KOTORModSync, the modern KOTOR mod manager with native macOS support.

## Overview

**KOTORModSync** is a revolutionary mod manager for KOTOR created by th3w1zard1 that solves the critical macOS modding problem: TSLPatcher is Windows-only, but KOTORModSync provides native TSLPatcher functionality on macOS without Wine/CrossOver.

### Key Features

- **Native macOS Support** - No Wine, CrossOver, or Windows emulation needed
- **TSLPatcher Integration** - Runs TSLPatcher functionality natively using PyKotor + HoloPatcher
- **Dependency Management** - Automatic handling of mod dependencies and installation order
- **Multi-Mod Installation** - Install 200+ mods automatically (Reddit builds in ~20 minutes)
- **TOML Configuration** - Human-readable, user-friendly instruction format
- **GUI Editor** - Visual tool for creating mod instructions
- **Compatibility Checking** - Built-in incompatibility detection

### Why KOTORModSync is Essential for macOS

**The Problem:**
- TSLPatcher.exe is Windows-only
- TSLPatcher is required for complex mods (K1R, TSLRCM, etc.)
- macOS users historically needed CrossOver ($60) or Wine (complex setup)

**The Solution:**
- KOTORModSync includes HoloPatcher (native TSLPatcher implementation)
- Works natively on macOS, Linux, and Windows
- Free and open source

## Installation

### Method 1: Auto-Installation (Recommended for this Skill)

```bash
#!/bin/bash
# setup_kotormodsync.sh

INSTALL_DIR="$HOME/KOTORModSync"
REPO="th3w1zard1/KOTORModSync"
RELEASE_URL="https://api.github.com/repos/$REPO/releases/latest"

echo "Downloading KOTORModSync..."

# Get latest release
DOWNLOAD_URL=$(curl -s "$RELEASE_URL" | grep "browser_download_url.*macos" | cut -d '"' -f 4)

# Download
curl -L "$DOWNLOAD_URL" -o /tmp/kotormodsync.zip

# Extract
unzip /tmp/kotormodsync.zip -d "$INSTALL_DIR"

# Make executable
chmod +x "$INSTALL_DIR/KOTORModSync"

echo "KOTORModSync installed to: $INSTALL_DIR"
```

### Method 2: Manual Installation

1. Visit https://github.com/th3w1zard1/KOTORModSync/releases
2. Download latest macOS release (`.dmg` or `.zip`)
3. Extract to desired location (e.g., `~/KOTORModSync/`)
4. Verify executable: `./KOTORModSync --version`

### Method 3: From Source

```bash
git clone https://github.com/th3w1zard1/KOTORModSync.git
cd KOTORModSync
# Follow build instructions in README
```

## TOML Instruction Format

KOTORModSync uses TOML (Tom's Obvious, Minimal Language) for mod instructions.

### Basic Structure

```toml
[ModInfo]
GUID = "unique-identifier"
Name = "Mod Name"
Description = "What this mod does"
DownloadLinks = ["https://example.com/mod.zip"]
Authors = ["Author Name"]

[Dependencies]
RequiredMods = []
IncompatibleMods = []
InstallAfter = []
InstallBefore = []

[Instructions.0]
Action = "Copy"
Source = ["file1.tpc", "file2.tpc"]
Destination = "Override"
Overwrite = true

[Instructions.1]
Action = "TSLPatcher"
Source = "tslpatchdata"
Destination = "game-directory"
```

### ModInfo Section

```toml
[ModInfo]
GUID = "k1r-restoration-1.2"  # Unique identifier
Name = "KOTOR 1 Restoration 1.2"
Description = "Restores cut content to KOTOR 1"
DownloadLinks = [
    "https://deadlystream.com/files/download/1234-k1r/",
    "https://nexusmods.com/kotor/mods/5678"  # Fallback
]
Authors = ["K1R Team", "Fair Strides"]
```

**Fields:**
- `GUID` - Unique ID for this mod (used for dependencies)
- `Name` - Display name
- `Description` - What the mod does
- `DownloadLinks` - Where to get the mod (array, first is primary)
- `Authors` - Mod creators (array)

### Dependencies Section

```toml
[Dependencies]
RequiredMods = ["k1cp-community-patch"]  # Must be installed
IncompatibleMods = ["other-restoration-mod"]  # Cannot install together
InstallAfter = ["texture-pack-1"]  # Install after these mods
InstallBefore = ["final-overwrite-mod"]  # Install before these mods
```

**Dependency Types:**

**RequiredMods:**
- Mods that MUST be installed first
- Installation will fail if not present
- Example: Mod requires TSLRCM

**IncompatibleMods:**
- Mods that conflict
- Installation will be blocked if detected
- Example: Two restoration mods

**InstallAfter:**
- Mod should be installed after these
- Ensures correct installation order
- Example: Texture mod after content mod

**InstallBefore:**
- Mod should be installed before these
- Opposite of InstallAfter
- Example: Foundation mod before everything

### Instructions Section

Multiple instruction blocks, numbered sequentially: `[Instructions.0]`, `[Instructions.1]`, etc.

#### Action: Copy

```toml
[Instructions.0]
Action = "Copy"
Source = ["C_Droid01.tpc", "C_Droid02.tpc"]
Destination = "Override"
Overwrite = true
```

Copies files to destination.

**Parameters:**
- `Source` - Files to copy (array or single string, supports wildcards)
- `Destination` - Where to copy (`Override`, `modules`, etc.)
- `Overwrite` - Whether to overwrite existing files (default: false)

#### Action: Move

```toml
[Instructions.1]
Action = "Move"
Source = ["temp_file.2da"]
Destination = "Override"
```

Moves files (deletes from source).

#### Action: Rename

```toml
[Instructions.2]
Action = "Rename"
Source = "old_name.tpc"
Destination = "new_name.tpc"
```

Renames a file.

#### Action: Delete

```toml
[Instructions.3]
Action = "Delete"
Source = ["unnecessary_file.txt"]
```

Deletes files.

#### Action: TSLPatcher

```toml
[Instructions.4]
Action = "TSLPatcher"
Source = "tslpatchdata"  # Folder containing changes.ini
Destination = "game-directory"
Namespace = "Main"  # Optional: which install option to use
```

Runs TSLPatcher functionality (HoloPatcher).

**Parameters:**
- `Source` - Path to `tslpatchdata` folder
- `Destination` - Game installation directory
- `Namespace` - Optional install option from namespaces.ini (e.g., "Main", "Optional1")

**How It Works:**
1. Reads `changes.ini` from Source folder
2. Applies modifications using HoloPatcher (native TSLPatcher)
3. Merges .2da files intelligently
4. Modifies .dlg files as needed
5. Copies files to game directory

#### Action: Extract

```toml
[Instructions.5]
Action = "Extract"
Source = "inner_archive.zip"
Destination = "temp_folder"
```

Extracts nested archives.

#### Action: DelDuplicate

```toml
[Instructions.6]
Action = "DelDuplicate"
Source = ["Override"]
Extensions = [".tpc", ".tga"]
```

Removes duplicate files by extension (if both .tpc and .tga exist, keeps .tpc).

#### Action: Execute

```toml
[Instructions.7]
Action = "Execute"
Source = "custom_script.sh"
Arguments = ["--install", "--path", "game-directory"]
```

Executes a program or script.

**Warning:** Security risk if running untrusted scripts.

## Example TOML Files

### Example 1: Simple Texture Mod

```toml
[ModInfo]
GUID = "vurts-visual-resurgence"
Name = "Vurt's Visual Resurgence"
Description = "High-resolution texture overhaul for KOTOR 1"
DownloadLinks = ["https://deadlystream.com/files/file/1730-vurts-kotor-visual-resurgence/"]
Authors = ["Vurt"]

[Dependencies]
RequiredMods = []
IncompatibleMods = []
InstallAfter = ["k1r-restoration"]  # Install after content mods

[Instructions.0]
Action = "Copy"
Source = ["*.tpc"]  # All .tpc files
Destination = "Override"
Overwrite = true
```

### Example 2: TSLPatcher Mod (K1R)

```toml
[ModInfo]
GUID = "k1r-restoration-1.2"
Name = "K1R Restoration 1.2"
Description = "Restores cut content and fixes bugs in KOTOR 1"
DownloadLinks = ["https://deadlystream.com/files/file/54-k1r-1-2/"]
Authors = ["K1R Team"]

[Dependencies]
RequiredMods = []
IncompatibleMods = ["other-restoration-mods"]
InstallAfter = []
InstallBefore = ["*"]  # Must be installed before everything

[Instructions.0]
Action = "TSLPatcher"
Source = "tslpatchdata"
Destination = "game-directory"
Namespace = "Main"

[Instructions.1]
Action = "TSLPatcher"
Source = "tslpatchdata"
Destination = "game-directory"
Namespace = "Iriaz"  # Optional component

[Instructions.2]
Action = "TSLPatcher"
Source = "tslpatchdata"
Destination = "game-directory"
Namespace = "Vulkars"  # Optional component
```

### Example 3: Complex Mod with Multiple Actions

```toml
[ModInfo]
GUID = "complex-mod-example"
Name = "Complex Mod"
Description = "Demonstrates multiple action types"
DownloadLinks = ["https://example.com/mod.zip"]
Authors = ["Modder"]

[Dependencies]
RequiredMods = ["k1r-restoration"]
IncompatibleMods = []
InstallAfter = ["k1r-restoration"]

[Instructions.0]
Action = "Extract"
Source = "nested.zip"
Destination = "temp"

[Instructions.1]
Action = "TSLPatcher"
Source = "temp/tslpatchdata"
Destination = "game-directory"

[Instructions.2]
Action = "Copy"
Source = ["temp/textures/*.tpc"]
Destination = "Override"
Overwrite = true

[Instructions.3]
Action = "Delete"
Source = ["temp"]  # Cleanup
```

## Using KOTORModSync

### Command-Line Usage

```bash
# Install a single mod
./KOTORModSync install --mod mod_instructions.toml --game-path "/path/to/kotor"

# Install mod build (multiple mods)
./KOTORModSync install --build reddit_spoiler_free.toml --game-path "/path/to/kotor"

# Verify installation
./KOTORModSync verify --game-path "/path/to/kotor"

# List installed mods
./KOTORModSync list --game-path "/path/to/kotor"

# Remove mod
./KOTORModSync remove --mod "mod-guid" --game-path "/path/to/kotor"
```

### GUI Usage

```bash
# Launch GUI
./KOTORModSync
```

**GUI Features:**
- Visual mod selection
- Dependency graph visualization
- Conflict detection warnings
- Progress tracking
- Installation log viewer

### Programmatic Usage (Python)

```python
from kotormodsync import ModInstaller

installer = ModInstaller(game_path="/path/to/kotor")

# Load mod instruction
installer.load_mod("k1r-restoration.toml")

# Check dependencies
if installer.check_dependencies():
    # Install
    installer.install()
    print("Installation complete")
else:
    print("Dependencies not met")
```

## Integration with KOTOR Mod Manager Skill

### Auto-Installation Flow

```python
def ensure_kotormodsync():
    """Ensure KOTORModSync is installed, install if not"""
    kotormodsync_path = os.path.expanduser("~/KOTORModSync/KOTORModSync")

    if os.path.exists(kotormodsync_path):
        print("✓ KOTORModSync found")
        return kotormodsync_path
    else:
        print("KOTORModSync not found, installing...")
        subprocess.run(["bash", "scripts/setup_kotormodsync.sh"])
        return kotormodsync_path
```

### Generating TOML from Mod Analysis

```python
def generate_toml(mod_info, output_path):
    """Generate TOML instruction file from analyzed mod"""
    toml_content = f"""
[ModInfo]
GUID = "{mod_info['guid']}"
Name = "{mod_info['name']}"
Description = "{mod_info['description']}"
Authors = [{', '.join(f'"{a}"' for a in mod_info['authors'])}]

[Dependencies]
RequiredMods = []
IncompatibleMods = []
InstallAfter = {mod_info.get('install_after', [])}

"""

    # Add instructions based on mod type
    if mod_info['install_method'] == 'tslpatcher':
        toml_content += """
[Instructions.0]
Action = "TSLPatcher"
Source = "tslpatchdata"
Destination = "game-directory"
"""
    else:  # Override folder mod
        toml_content += """
[Instructions.0]
Action = "Copy"
Source = ["*"]
Destination = "Override"
Overwrite = true
"""

    with open(output_path, 'w') as f:
        f.write(toml_content)
```

### Installing Mod via KOTORModSync

```python
def install_mod_kotormodsync(mod_toml, game_path):
    """Install mod using KOTORModSync"""
    kotormodsync = ensure_kotormodsync()

    cmd = [
        kotormodsync,
        "install",
        "--mod", mod_toml,
        "--game-path", game_path
    ]

    result = subprocess.run(cmd, capture_output=True, text=True)

    if result.returncode == 0:
        print(f"✓ Mod installed successfully")
        return True
    else:
        print(f"✗ Installation failed: {result.stderr}")
        return False
```

## Handling Optional Components

Many TSLPatcher mods have optional components (namespaces):

### Detecting Optional Components

```python
def detect_namespaces(tslpatchdata_path):
    """Parse namespaces.ini to find optional components"""
    namespaces_file = os.path.join(tslpatchdata_path, "namespaces.ini")

    if not os.path.exists(namespaces_file):
        return ["Main"]  # Only main installation

    # Parse namespaces.ini
    namespaces = []
    with open(namespaces_file, 'r') as f:
        for line in f:
            if line.strip() and not line.startswith(';'):
                # Extract namespace name
                if '=' in line:
                    namespace = line.split('=')[0].strip()
                    namespaces.append(namespace)

    return namespaces
```

### Prompting User for Components

```python
def prompt_optional_components(namespaces):
    """Ask user which optional components to install"""
    print("This mod has optional components:")
    for i, ns in enumerate(namespaces):
        print(f"{i+1}. {ns}")

    print("\nEnter numbers to install (comma-separated), or 'all':")
    selection = input("> ")

    if selection.lower() == 'all':
        return namespaces

    selected_indices = [int(x.strip()) - 1 for x in selection.split(',')]
    return [namespaces[i] for i in selected_indices]
```

### Installing Multiple Components

```toml
# Generate separate instruction blocks for each component
[Instructions.0]
Action = "TSLPatcher"
Source = "tslpatchdata"
Destination = "game-directory"
Namespace = "Main"

[Instructions.1]
Action = "TSLPatcher"
Source = "tslpatchdata"
Destination = "game-directory"
Namespace = "Iriaz"

[Instructions.2]
Action = "TSLPatcher"
Source = "tslpatchdata"
Destination = "game-directory"
Namespace = "Vulkars"
```

## Troubleshooting

### Issue: KOTORModSync not found

**Solution:**
```bash
# Check if installed
ls -la ~/KOTORModSync/

# Reinstall
bash scripts/setup_kotormodsync.sh
```

### Issue: TSLPatcher action fails

**Possible causes:**
1. Invalid `changes.ini` format
2. Missing source files
3. Incorrect game path
4. Permission issues

**Debug:**
```bash
# Check KOTORModSync logs
cat ~/KOTORModSync/logs/latest.log

# Verify tslpatchdata folder
ls -la /path/to/mod/tslpatchdata/

# Check game directory permissions
ls -la "/path/to/game/Override"
```

### Issue: Dependency not met

**Solution:**
```bash
# Check installed mods
./KOTORModSync list --game-path "/path/to/kotor"

# Install required mod first
./KOTORModSync install --mod required_mod.toml --game-path "/path/to/kotor"
```

### Issue: Incompatible mods detected

**Solution:**
- Choose one mod or the other
- Check if community patches exist for compatibility
- Manually resolve if experienced

## Advanced: Creating Mod Builds

A mod build is a collection of TOML files that installs multiple mods:

```toml
# reddit_spoiler_free_build.toml

[BuildInfo]
Name = "Reddit Spoiler-Free Build"
Description = "Community-curated mod collection for first playthrough"
Game = "KOTOR1"
Version = "2.0"

[Mods]
ModList = [
    "k1r-restoration-1.2",
    "k1cp-community-patch",
    "high-quality-skyboxes",
    "hd-ui-menus",
    "vurts-visual-resurgence",
    "weapon-texture-improvements"
]

# Each mod ID corresponds to a .toml file
```

**Installation:**
```bash
./KOTORModSync install --build reddit_spoiler_free_build.toml --game-path "/path/to/kotor"
```

KOTORModSync will:
1. Load all mod TOML files
2. Resolve dependencies
3. Order by InstallAfter/InstallBefore
4. Check for incompatibilities
5. Install sequentially
6. Track progress (~20 minutes for full build)

## Conclusion

KOTORModSync is the key to macOS KOTOR modding:

**For This Skill:**
- Auto-install KOTORModSync when needed
- Generate TOML files from analyzed mods
- Use for all TSLPatcher mods
- Leverage dependency management
- Handle optional components

**Benefits:**
- No Wine/CrossOver needed
- Reliable .2da merging
- Automatic dependency handling
- Build system for mod collections
- Native macOS performance

**Resources:**
- GitHub: https://github.com/th3w1zard1/KOTORModSync
- Documentation: https://github.com/th3w1zard1/KOTORModSync/wiki
- Issues: https://github.com/th3w1zard1/KOTORModSync/issues

Use this guide when implementing KOTORModSync integration in the KOTOR Mod Manager skill.
