# KOTOR File Types Reference

Complete reference for Knights of the Old Republic file formats, conflict risks, and modding implications.

## Overview

KOTOR uses various proprietary and standard file formats inherited from BioWare's Aurora Engine (used in Neverwinter Nights). Understanding these file types is essential for mod compatibility checking and conflict resolution.

## File Type Categories

### 1. Texture Files

#### .tpc (Texture Packed)
**Purpose:** KOTOR's proprietary compressed texture format
**Conflict Risk:** **LOW**
**Conflict Type:** Filename-based replacement
**Typical Size:** 100 KB - 22 MB per file

**Details:**
- Proprietary format specific to KOTOR
- DXT1/DXT5 compression
- Supports mipmaps for LOD (Level of Detail)
- Can include alpha channels for transparency
- Naming conventions:
  - `C_*` - Creature textures
  - `L*_*` - Location textures (LDA = Dantooine, LTA = Taris, etc.)
  - `N_*` - NPC faction textures
  - `P*` - Player character textures

**Modding Implications:**
- Multiple mods can include .tpc files with same names
- Last installed mod wins (simple overwrite)
- No merging required or possible
- Visual-only impact - no crashes or save corruption
- Users can mix and match by manually selecting files

**Tools:**
- KOTOR Tool (Windows) - Convert .tpc ↔ .tga
- tpcview - View .tpc files
- xoreos-tools - Command-line conversion

**Example Conflict:**
```
Mod A: C_Droid01.tpc (high-res droid texture)
Mod B: C_Droid01.tpc (alternate color scheme)
Result: Last installed texture appears in-game
Risk: None (just different visuals)
```

#### .tga (Targa Image)
**Purpose:** Uncompressed texture format
**Conflict Risk:** **LOW**
**Conflict Type:** Filename-based replacement
**Typical Size:** 500 KB - 50 MB per file

**Details:**
- Standard Targa image format
- Uncompressed (larger than .tpc)
- Game can use .tga directly (no conversion needed)
- Often used by modders for easier editing
- Game prefers .tpc if both .tga and .tpc exist with same name

**Modding Implications:**
- Same as .tpc - last installed wins
- Can coexist with .tpc of same name (game uses .tpc)
- Larger file sizes than .tpc equivalents
- Safe for mod conflicts

#### .txi (Texture Information)
**Purpose:** Texture metadata and shader properties
**Conflict Risk:** **LOW**
**Conflict Type:** Filename-based replacement
**Typical Size:** <1 KB (plain text)

**Details:**
- Plain text file format
- Defines texture properties:
  - Shader effects (envmapping, bumpiness)
  - Animation parameters
  - Blending modes
  - Texture filtering
- Example content:
  ```
  envmaptexture CM_Baremetal
  bumpyshinytexture CM_Baremetal
  bumpmaptexture C_HK47N
  ```

**Modding Implications:**
- Rarely causes conflicts
- Usually accompanies texture mods
- Last installed wins if conflict
- Minimal impact - affects texture rendering only

---

### 2. Data Tables

#### .2da (2-Dimensional Array)
**Purpose:** Game data tables
**Conflict Risk:** **VERY HIGH**
**Conflict Type:** Row/column conflicts
**Typical Size:** 1 KB - 500 KB (plain text)

**Details:**
- Tab-separated values format (TSV-like)
- Contains critical game data:
  - `baseitems.2da` - Item definitions
  - `feat.2da` - Character feats/abilities
  - `spells.2da` - Force powers
  - `appearance.2da` - Character models
  - `heads.2da` - Character head models
  - `globalcat.2da` - Global categories
  - `pazaakdecks.2da` - Pazaak card decks
- Format structure:
  ```
  2DA V2.0

              Label       Name
  0           row0_label  value
  1           row1_label  value
  ```

**Why High Risk:**
- Multiple mods often need to modify same .2da files
- Simple overwrite loses previous mod's changes
- Can cause crashes if structure is invalid
- Can corrupt saves if item/feat IDs change

**Conflict Scenarios:**

**Scenario 1: Both mods add new rows**
```
Mod A adds row 500 to baseitems.2da (new lightsaber)
Mod B adds row 501 to baseitems.2da (new armor)
Conflict: If both mods include entire baseitems.2da
Resolution: TSLPatcher can merge by appending rows
Risk: MEDIUM (TSLPatcher handles this)
```

**Scenario 2: Both mods modify same row**
```
Mod A changes row 10 of feat.2da (rebalance)
Mod B changes row 10 of feat.2da (different rebalance)
Conflict: Cannot both apply simultaneously
Resolution: Manual merging or choose one mod
Risk: HIGH (incompatible changes)
```

**Scenario 3: Column structure changes**
```
Mod A adds new column to spells.2da
Mod B expects vanilla column structure
Conflict: Mod B may break with Mod A's structure
Resolution: Complex manual merging
Risk: VERY HIGH (potential crashes)
```

**TSLPatcher Merging:**
- TSLPatcher can intelligently merge .2da files
- Can append new rows without conflicts
- Can modify specific cells without overwriting entire file
- Reads current .2da state and applies changes
- This is why complex mods REQUIRE TSLPatcher

**Detection Strategy:**
```python
# Parse .2da files from both mods
mod_a_2da = parse_2da("mod_a/baseitems.2da")
mod_b_2da = parse_2da("mod_b/baseitems.2da")

# Check for conflicts
if mod_a_2da.modified_rows & mod_b_2da.modified_rows:
    # Rows conflict - HIGH RISK
    conflict = True
elif mod_a_2da.new_rows and mod_b_2da.new_rows:
    # Both add rows - MEDIUM RISK (TSLPatcher can merge)
    mergeable = True
```

**Modding Implications:**
- Always use TSLPatcher for .2da modifications
- Never directly overwrite .2da files when installing multiple mods
- Check changes.ini from TSLPatcher mods to see what's modified
- Foundation mods should install first (they establish baseline)
- Texture-only mods are safe last because they avoid .2da files

---

### 3. Script Files

#### .ncs (Compiled NWScript)
**Purpose:** Compiled game scripts
**Conflict Risk:** **MEDIUM**
**Conflict Type:** Filename-based replacement + logic conflicts
**Typical Size:** 100 bytes - 50 KB (binary)

**Details:**
- BioWare's NWScript bytecode
- Controls game logic, events, conversations
- Binary format (not human-readable)
- Executes game behaviors:
  - Quest progression
  - Dialog outcomes
  - Item rewards
  - AI behavior
  - Trigger events

**Common Script Naming:**
- `k_*.ncs` - Core game scripts
- `k1r_*.ncs` - K1R Restoration scripts
- `a_*.ncs` - Action scripts
- `c_*.ncs` - Conditional scripts

**Why Medium Risk:**
- If two mods replace same script: last wins, first mod's logic lost
- Can break quests if critical script is overwritten
- Can cause unintended behavior if incompatible logic
- NOT immediately crash-inducing (unlike .2da conflicts)
- Impact depends on which script conflicts

**Conflict Example:**
```
Mod A: k_ptar_duelrew.ncs (new reward for Taris duel)
Mod B: k_ptar_duelrew.ncs (different reward for Taris duel)
Result: Only Mod B's reward works, Mod A's logic lost
Risk: Mod A's feature broken, but game won't crash
```

**Detection:**
- Simple filename matching detects conflicts
- Cannot easily determine if logic actually conflicts
- Requires source code (.nss) to analyze

#### .nss (NWScript Source)
**Purpose:** Script source code
**Conflict Risk:** **MEDIUM**
**Conflict Type:** Filename-based replacement + logic conflicts
**Typical Size:** 100 bytes - 20 KB (plain text)

**Details:**
- Human-readable C-like scripting language
- Source code that compiles to .ncs
- Sometimes included by mod authors for transparency
- Can be manually merged by experienced modders

**Example Script:**
```nwscript
void main() {
    object oPC = GetFirstPC();
    GiveXPToCreature(oPC, 1000);
    GiveGoldToCreature(oPC, 500);
    CreateItemOnObject("g_w_lghtsbr01", oPC);
}
```

**Modding Implications:**
- If both .nss and .ncs present: game uses .ncs
- .nss included for reference/modification
- Advanced users can merge .nss files and recompile
- Requires nwnnsscomp compiler

**Manual Merging Process:**
```
1. Extract .nss from both mods
2. Compare differences
3. Manually combine logic
4. Recompile to .ncs using nwnnsscomp
5. Install merged .ncs
```

---

### 4. Dialog Files

#### .dlg (Dialog)
**Purpose:** Conversation trees
**Conflict Risk:** **HIGH**
**Conflict Type:** Node-based conflicts, entry point conflicts
**Typical Size:** 1 KB - 200 KB (binary GFF)

**Details:**
- GFF (Generic File Format) structure
- Binary tree structure of conversation nodes
- Contains:
  - Dialog text
  - NPC responses
  - Player responses
  - Script triggers
  - Conditional branches
  - Quest variables

**Why High Risk:**
- Complex tree structure difficult to merge
- Multiple mods may modify same conversation
- Node ID conflicts
- Script references may break
- Can completely break conversations/quests

**Conflict Scenarios:**

**Scenario 1: Different mods edit same conversation**
```
Mod A: Adds new dialog branch to Bastila.dlg
Mod B: Fixes typo in Bastila.dlg
Conflict: Both modify same file
Resolution: Extremely difficult - requires DLG editor
Risk: HIGH (one mod's changes lost)
```

**Scenario 2: Node ID collisions**
```
Mod A assigns node ID 150 for new branch
Mod B assigns node ID 150 for different branch
Result: Unpredictable behavior, broken conversation
```

**Tools:**
- DLG Editor (tk102) - Windows tool for editing
- K-GFF Editor - Generic GFF file editor
- Very complex to merge manually

**Modding Implications:**
- Avoid installing mods that edit same .dlg files
- TSLPatcher can modify .dlg but merging is complex
- Often marks mods as incompatible
- Test conversations in-game after installing

---

### 5. Template Files (GFF Format)

#### .utc (Creature Template)
**Purpose:** NPC/creature definitions
**Conflict Risk:** **MEDIUM**
**Conflict Type:** Filename-based replacement
**Typical Size:** 1 KB - 10 KB (binary GFF)

**Details:**
- Defines creature properties:
  - Stats (STR, DEX, CON, etc.)
  - Inventory items
  - Equipped items
  - AI behavior
  - Faction
  - Appearance

**Conflict Example:**
```
Mod A: n_mandalorian01.utc (stronger Mandalorians)
Mod B: n_mandalorian01.utc (different equipment)
Result: Last mod wins
Risk: MEDIUM (one mod's changes lost)
```

#### .uti (Item Template)
**Purpose:** Item definitions
**Conflict Risk:** **MEDIUM**
**Conflict Type:** Filename-based replacement
**Typical Size:** 500 bytes - 5 KB (binary GFF)

**Details:**
- Defines item properties:
  - Name and description
  - Stats/bonuses
  - Cost
  - Model appearance
  - Usability restrictions

#### .utp (Placeable Template)
**Purpose:** Placeable object definitions
**Conflict Risk:** **MEDIUM**
**Conflict Type:** Filename-based replacement

**Details:**
- Defines placeables (containers, doors, etc.)
- Inventory contents
- Lockable/unlockable
- Triggers

**Modding Implications (All Template Files):**
- Filename-based conflicts
- Last installed wins
- Cannot merge templates
- Choose one mod or the other
- Usually specific to particular NPCs/items/locations

---

### 6. Module Files

#### .rim (Module Archive)
**Purpose:** Location/area data archives
**Conflict Risk:** **VERY HIGH**
**Conflict Type:** Entire module replacement
**Typical Size:** 100 KB - 50 MB

**Details:**
- BioWare's ERF/RIM archive format
- Contains entire area/module:
  - .git (Area information)
  - .are (Area properties)
  - .ifo (Module information)
  - All area-specific resources
- Examples:
  - `danm14aa.rim` - Dantooine Jedi Enclave
  - `tar_m02aa.rim` - Taris Upper City

**Why Very High Risk:**
- Entire module replacement
- Two mods editing same module = incompatible
- Cannot merge module files
- One mod completely overwrites the other's changes

**Conflict Detection:**
```
Mod A includes: tar_m02aa.rim (restored content)
Mod B includes: tar_m02aa.rim (visual enhancements)
Result: INCOMPATIBLE - cannot both install
Resolution: Choose one or find compatible versions
```

#### .mod (Module File)
**Purpose:** Alternative module archive format
**Conflict Risk:** **VERY HIGH**
**Conflict Type:** Entire module replacement

**Details:**
- Similar to .rim but different usage
- Often used for custom modules
- Same incompatibility issues as .rim

**Modding Implications:**
- Red flag for mod compatibility
- Check if mods modify same modules
- Usually makes mods incompatible
- Requires mod author coordination to resolve

---

## Conflict Detection Priority

When analyzing mod conflicts, prioritize checking in this order:

### 1. Module Files (Highest Priority)
- Check for .rim/.mod conflicts first
- If found: Mark mods as likely INCOMPATIBLE
- These are showstoppers

### 2. .2da Files
- Parse and compare .2da files
- Check if both mods include same .2da
- Analyze if changes conflict:
  - Same rows modified? CONFLICT
  - Only new rows? TSLPatcher can merge
  - Column structure changes? CONFLICT

### 3. Dialog Files (.dlg)
- Check for same .dlg filename conflicts
- Mark as HIGH risk if both include same .dlg
- Rarely mergeable

### 4. Scripts (.ncs/.nss)
- Check for same script filename
- Mark as MEDIUM risk
- May be manually mergeable if .nss provided

### 5. Templates (.utc/.uti/.utp)
- Check filename conflicts
- Mark as MEDIUM risk
- Last installed wins

### 6. Textures (.tpc/.tga)
- Check filename conflicts
- Mark as LOW risk
- Last installed wins, visual only

## File Extension Risk Summary Table

| Extension | Risk Level | Mergeable? | Impact if Conflict | Auto-Resolve? |
|-----------|------------|------------|-------------------|---------------|
| .tpc | LOW | No | Visual only | Yes (last wins) |
| .tga | LOW | No | Visual only | Yes (last wins) |
| .txi | LOW | No | Visual only | Yes (last wins) |
| .2da | VERY HIGH | Yes (TSLPatcher) | Crashes, corruption | TSLPatcher only |
| .ncs | MEDIUM | No | Logic/quest issues | No (choose one) |
| .nss | MEDIUM | Yes (manual) | Source reference only | Manual merge |
| .dlg | HIGH | Complex | Broken conversations | Rarely |
| .utc | MEDIUM | No | NPC behavior | No (choose one) |
| .uti | MEDIUM | No | Item properties | No (choose one) |
| .utp | MEDIUM | No | Placeable properties | No (choose one) |
| .rim | VERY HIGH | No | Area/module | No (incompatible) |
| .mod | VERY HIGH | No | Area/module | No (incompatible) |

## Compatibility Checking Algorithm

```
For each file in Mod A:
  For each file in Mod B:
    If filenames match:
      risk_level = get_risk_level(file_extension)

      If risk_level == "VERY HIGH":
        If is_2da_file(file):
          Parse and compare modifications
          If modifications conflict:
            Report: INCOMPATIBLE
          Else:
            Report: TSLPatcher can merge
        Else:
          Report: INCOMPATIBLE (module conflict)

      ElseIf risk_level == "HIGH":
        Report: CONFLICT - manual resolution required

      ElseIf risk_level == "MEDIUM":
        Report: WARNING - one mod's changes will be lost

      ElseIf risk_level == "LOW":
        Report: INFO - visual conflict, last installed wins
```

## Installation Best Practices

1. **Install mods modifying .2da/.dlg files FIRST** (use TSLPatcher)
2. **Install texture mods LAST** (safe overwrites)
3. **Check for module conflicts BEFORE starting** (deal-breakers)
4. **Test after each major mod** (isolate issues)
5. **Keep backups** (Override folder snapshots)

## Additional File Types

### Audio Files
- `.wav` - Sound effects, voice files (LOW risk, last wins)
- `.mp3` - Music files (LOW risk, last wins)

### Model Files
- `.mdl` - 3D model geometry (LOW risk, last wins)
- `.mdx` - Model animation (LOW risk, last wins)

### UI Files
- `.gui` - UI layout definitions (MEDIUM risk)

### Other
- `.lyt` - Area layout (MEDIUM risk)
- `.vis` - Visibility data (MEDIUM risk)
- `.pth` - Pathfinding data (MEDIUM risk)

## Tools Reference

- **KOTOR Tool** - All-purpose modding tool (Windows only)
- **K-GFF Editor** - Edit GFF files (.utc, .uti, .utp, .dlg, etc.)
- **DLG Editor** - Specialized dialog tree editor
- **TSLPatcher** - Install complex mods with .2da merging (Windows)
- **KOTORModSync** - Modern mod manager with native macOS support
- **nwnnsscomp** - NWScript compiler
- **DeNCS** - Script decompiler
- **ERF Editor** - Edit mod archives
- **xoreos-tools** - Command-line modding utilities

## Conclusion

Understanding KOTOR file types is essential for:
- Accurate conflict detection
- Risk assessment
- Installation order planning
- Troubleshooting mod issues
- Advising users on compatibility

The risk levels in this guide should inform conflict reporting and user warnings.
