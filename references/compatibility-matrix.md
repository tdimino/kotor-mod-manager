# KOTOR Mod Compatibility Matrix

Comprehensive guide to mod compatibility patterns, known conflicts, and safe combinations for KOTOR 1 and 2 modding.

## Overview

This reference documents:
- Known compatible mod combinations
- Known incompatible mods
- Popular mod builds (Reddit builds)
- Installation order requirements
- Compatibility patterns to recognize

## Compatibility Principles

### Foundation Mod Concept

**Foundation mods** must be installed FIRST before any other mods:
- They modify core game files extensively
- Later mods may depend on their changes
- Cannot be installed after other mods without reinstalling everything

**KOTOR 1 Foundation Mods:**
- K1R (KOTOR 1 Restoration)
- KOTOR 1 Community Patch (K1CP)
- Major overhaul mods

**KOTOR 2 Foundation Mods:**
- TSLRCM (The Sith Lords Restored Content Mod)
- M4-78 Enhancement Project
- Extended Enclave

### Safe Combination Patterns

#### Pattern 1: Texture-Only Mods

**Always Safe** to combine multiple texture mods:
- Different textures → No conflict
- Same textures → Last installed wins (user choice)
- No gameplay impact
- Cannot break saves or cause crashes

**Examples:**
- Vurt's Visual Resurgence + High Quality Skyboxes ✓
- Character texture overhauls + environment textures ✓
- Multiple weapon texture mods ✓

**Exception:** If two mods replace the exact same texture, only one will appear.

#### Pattern 2: Non-Overlapping Content Mods

Mods that add entirely different content:
- New items in different categories
- Different companion modifications
- Different quest mods
- Different planet enhancements

**Usually Safe** if they don't modify same .2da tables or modules.

#### Pattern 3: Complementary Mods

Mods designed to work together or address different aspects:
- Bug fixes + content restoration ✓
- Visual enhancements + gameplay tweaks ✓
- UI mods + texture mods ✓

### Conflict Patterns

#### Pattern 1: Same System Modifications

Mods that modify the same game system:
- Two rebalance mods ✗
- Two companion overhauls (same companion) ✗
- Two UI replacements ✗
- Multiple restoration mods ✗

#### Pattern 2: Module Conflicts

Mods that modify the same game modules:
- Both edit Dantooine Enclave module ✗
- Both edit Taris Upper City module ✗
- Extremely difficult to merge

#### Pattern 3: .2da Table Conflicts

Mods that modify same rows in .2da tables:
- Both modify item ID 42 in baseitems.2da ✗
- Both modify feat ID 100 in feat.2da ✗
- May require TSLPatcher merging

## KOTOR 1 Mod Compatibility

### K1R 1.2 (KOTOR 1 Restoration)

**Type:** Foundation mod, content restoration
**Install Method:** TSLPatcher
**Install Order:** **MUST BE FIRST**

**What It Modifies:**
- Core .2da files (baseitems, feat, spells, globalcat, etc.)
- 143+ script files
- Multiple dialog files
- Module files (restored content)

**Compatible With:**
- ✓ Texture mods (all)
- ✓ Music/sound mods
- ✓ Model replacements
- ✓ UI mods
- ✓ Weapon/item texture mods
- ✓ Character appearance mods (textures)
- ✓ Kainzorus Prime's NPC Overhaul (if installed BEFORE K1R)

**Incompatible With:**
- ✗ Other restoration mods
- ✗ Mods that edit same .2da files (unless using TSLPatcher after)
- ✗ Mods that modify same dialog files
- ✗ Mods that replace same scripts

**Installation Notes:**
- Install K1R FIRST, then everything else
- Exception: KP NPC Overhaul can be installed first
- Optional components can be installed selectively
- dialog.tlk replacement is optional

### Vurt's Visual Resurgence

**Type:** Texture overhaul
**Install Method:** Override folder
**Install Order:** Late (after content mods)

**What It Modifies:**
- 2,411 .tpc texture files
- Characters, creatures, environments
- No .2da, scripts, or dialogs

**Compatible With:**
- ✓ K1R Restoration
- ✓ Most other mods (texture-only)
- ✓ Can be partially installed (pick textures)

**Incompatible With:**
- ⚠ Other texture mods replacing same files (last wins)
- ⚠ High Quality Skyboxes (some sky textures overlap)
- ⚠ Specific character texture mods (overlapping textures)

**Installation Notes:**
- Install AFTER content mods
- Can coexist with other texture mods (user chooses which textures)
- Large download (2.7 GB)

### Kainzorus Prime's NPC Overhaul

**Type:** Character appearance overhaul
**Install Method:** TSLPatcher
**Install Order:** BEFORE K1R or AFTER K1R (different versions)

**Compatible With:**
- ✓ K1R (if correct install order)
- ✓ Texture mods
- ✓ Other appearance mods (non-overlapping)

**Incompatible With:**
- ✗ Other mods that change same character appearances

**Installation Notes:**
- Check documentation for K1R compatibility
- Different versions for different install scenarios

## KOTOR 2 Mod Compatibility

### TSLRCM (The Sith Lords Restored Content Mod)

**Type:** Foundation mod, content restoration
**Install Method:** TSLPatcher
**Install Order:** **MUST BE FIRST**

**What It Modifies:**
- Hundreds of game files
- Restored cut content
- Bug fixes
- Extended endings

**Compatible With:**
- ✓ M4-78 Enhancement Project (designed to work together)
- ✓ Texture mods
- ✓ Most visual mods
- ✓ Weapon mods

**Incompatible With:**
- ✗ Other restoration mods (unless specifically designed for TSLRCM)
- ✗ Mods not updated for TSLRCM

**Installation Notes:**
- Always install first
- Check if other mods are "TSLRCM compatible"
- Most modern K2 mods assume TSLRCM

### M4-78 Enhancement Project

**Type:** Restored planet mod
**Install Method:** TSLPatcher
**Install Order:** AFTER TSLRCM

**Compatible With:**
- ✓ TSLRCM (designed for it)
- ✓ Most texture mods
- ✓ Most non-content mods

**Incompatible With:**
- ✗ Other planet mods
- ✗ Mods that modify droid planet content

## Reddit Mod Builds

### KOTOR 1 Spoiler-Free Build

**Source:** https://kotor.neocities.org/

**Philosophy:**
- Restored content
- Bug fixes
- Visual enhancements
- No spoilers for first playthrough

**Core Mods (Example Selection):**
1. K1R 1.2 (Foundation)
2. K1 Community Patch
3. High Quality Skyboxes
4. Character texture improvements
5. HD UI
6. Weapon texture improvements
7. Sound effect improvements

**Installation Order:**
1. K1R first
2. Patches and bug fixes
3. Content additions
4. Visual improvements
5. Textures last

**Compatibility:** Pre-tested by community, all mods verified compatible

### KOTOR 1 Full Build

**Philosophy:**
- Everything from spoiler-free build
- Additional enhancements
- Quality of life improvements
- Difficulty tweaks

**Additional Mods:**
- Gameplay rebalances
- Additional restored content
- Extended endings
- Companion enhancements

### KOTOR 2 Full Build (TSLRCM-based)

**Core Sequence:**
1. TSLRCM
2. M4-78 (optional)
3. Extended Enclave (optional)
4. PartySwap
5. Visual mods
6. Texture mods

## Installation Order Templates

### Safe KOTOR 1 Installation Sequence

```
Phase 1: Foundation (Choose One)
├── K1R 1.2 (most popular)
└── OR K1 Community Patch only (if not using K1R)

Phase 2: Bugfixes & Patches
├── Bugfix compilation mods
└── Dialog fix mods

Phase 3: Content Additions
├── New item mods (using TSLPatcher)
├── New quest mods
└── Restored content (beyond K1R)

Phase 4: Gameplay Modifications
├── Rebalance mods
├── Difficulty adjustments
└── Feat modifications

Phase 5: Visual Enhancements
├── Model replacements
├── Lighting improvements
└── Effect enhancements

Phase 6: UI Modifications
├── UI texture replacements
├── Font improvements
└── Menu enhancements

Phase 7: Textures (LAST)
├── Environment textures
├── Character textures
├── Item textures
└── Final texture overwrites
```

### Safe KOTOR 2 Installation Sequence

```
Phase 1: Foundation
└── TSLRCM (MANDATORY FIRST)

Phase 2: Major Content
├── M4-78 Enhancement Project (optional)
└── Extended Enclave (optional)

Phase 3: Gameplay & Content
├── PartySwap
├── Bug fixes
└── Additional content

Phase 4: Visual & Textures
├── Visual improvements
├── Model replacements
└── Texture overhauls
```

## Compatibility Testing Checklist

When testing mod compatibility:

1. **File Overlap Check**
   - Extract both mods
   - Compare file lists
   - Note overlapping files

2. **File Type Analysis**
   - Check extension of conflicts
   - Assess risk level (see file-types.md)

3. **.2da Deep Dive**
   - Parse conflicting .2da files
   - Compare modified rows
   - Check for column additions

4. **Module Check**
   - Look for .rim/.mod files
   - Note which modules modified
   - Flag if same module in both

5. **Script Analysis**
   - Check conflicting .ncs/.nss files
   - Note critical scripts (quest-related)
   - Assess impact

6. **Documentation Review**
   - Read both mods' README files
   - Look for compatibility notes
   - Check install order requirements

7. **Community Research**
   - Search Deadlystream forums
   - Check Reddit mod build compatibility
   - Look for user reports

## Compatibility Database Schema

```json
{
  "mod_id": {
    "name": "Mod Name",
    "version": "1.0",
    "game": "kotor1|kotor2",
    "type": "foundation|content|visual|bugfix|gameplay",
    "install_method": "override|tslpatcher",
    "install_order": "first|early|middle|late|last",

    "modifies": {
      "2da_files": ["baseitems.2da", "feat.2da"],
      "modules": ["danm14aa.rim"],
      "scripts": ["k_ptar_duelrew.ncs"],
      "dialogs": ["bastila.dlg"],
      "textures": ["C_*.tpc", "LDA_*.tpc"]
    },

    "compatibility": {
      "requires": ["k1r-1.2"],
      "compatible_with": ["vurts-visual", "texture-mod-*"],
      "incompatible_with": ["other-restoration-mod"],
      "conflicts_with": {
        "some-mod-id": {
          "severity": "high|medium|low",
          "reason": "Both modify baseitems.2da row 42",
          "resolution": "Choose one or manual merge"
        }
      }
    },

    "installation_notes": [
      "Must install before K1R",
      "Optional components available"
    ],

    "tested_combinations": [
      {
        "mods": ["k1r-1.2", "vurts-visual"],
        "status": "compatible",
        "notes": "Install K1R first"
      }
    ]
  }
}
```

## Common Compatibility Questions

### Q: Can I install multiple texture mods?
**A:** Yes, but files with the same name will overwrite. Last installed wins.

### Q: Can I install K1R after other mods?
**A:** No. K1R must be first. Reinstall everything with K1R first.

### Q: Will this weapon mod work with K1R?
**A:** Check if it modifies .2da files. If yes, install after K1R using TSLPatcher.

### Q: Can I remove a mod mid-playthrough?
**A:** Risky. Texture mods: usually safe. Content mods: likely breaks save.

### Q: Two mods modify baseitems.2da. Incompatible?
**A:** Depends. If both add new rows: TSLPatcher can merge. If both modify same rows: incompatible.

### Q: How do I know if mods are compatible?
**A:** Check this guide, search Deadlystream forums, or use the skill's compatibility checker.

## Mod Author Compatibility Notes

When mod authors provide compatibility info:

**Look for these phrases:**
- "Install before X" - Order dependency
- "Install after Y" - Order dependency
- "Incompatible with Z" - Hard incompatibility
- "Requires TSLRCM" - Dependency
- "Do not install with [mod]" - Incompatibility
- "Can be installed in any order" - No conflicts

**Red flags:**
- "Overwrites [file]" - Potential conflict
- "Replaces [module]" - High conflict risk
- "Completely overhauls [system]" - Likely conflicts with similar mods

## Advanced: Manual Compatibility Resolution

For experienced users:

### Merging .2da Files

1. Extract both mods' .2da files
2. Open in text editor
3. Compare row by row
4. Manually merge:
   - Add new rows from both
   - Choose which modifications for conflicting rows
   - Ensure row IDs don't conflict
5. Test in-game

### Merging Scripts (.nss)

1. Extract .nss source from both mods
2. Compare logic
3. Manually combine:
   - Merge function calls
   - Avoid duplicate code
   - Test logic flow
4. Recompile using nwnnsscomp
5. Install merged .ncs

**Warning:** Advanced techniques. Most users should choose one mod or the other.

## Conclusion

Key principles for KOTOR mod compatibility:

1. **Foundation mods first** - K1R or TSLRCM before everything else
2. **Texture mods last** - Safe overwrites, install late
3. **Check file types** - .2da/.dlg/.rim are high risk
4. **Read documentation** - Mod authors provide compatibility info
5. **Test incrementally** - Install one mod, test, then next
6. **Use compatibility checker** - This skill automates detection
7. **When in doubt, ask** - Deadlystream community is helpful

Use this reference when implementing compatibility checking logic and advising users on mod combinations.
