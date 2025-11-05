#!/usr/bin/env python3

"""
check_mod_conflicts.py
Detect conflicts between KOTOR mods by analyzing file overlaps and types
"""

import sys
import json
import zipfile
import tarfile
from pathlib import Path
from collections import defaultdict
from typing import Dict, List, Set, Tuple

# File extension risk levels
RISK_LEVELS = {
    '.tpc': 'LOW',      # Textures
    '.tga': 'LOW',      # Textures
    '.txi': 'LOW',      # Texture info
    '.2da': 'VERY HIGH', # Data tables
    '.ncs': 'MEDIUM',   # Compiled scripts
    '.nss': 'MEDIUM',   # Script source
    '.dlg': 'HIGH',     # Dialogs
    '.utc': 'MEDIUM',   # Creature templates
    '.uti': 'MEDIUM',   # Item templates
    '.utp': 'MEDIUM',   # Placeable templates
    '.rim': 'VERY HIGH', # Modules
    '.mod': 'VERY HIGH', # Modules
    '.wav': 'LOW',      # Audio
    '.mp3': 'LOW',      # Audio
    '.mdl': 'LOW',      # Models
    '.mdx': 'LOW',      # Model animations
}


def extract_file_list(archive_path: str) -> List[str]:
    """Extract list of files from archive"""
    path = Path(archive_path)
    files = []

    try:
        if path.suffix == '.zip' or path.name.endswith('.7z'):
            with zipfile.ZipFile(archive_path, 'r') as zf:
                files = zf.namelist()
        elif path.suffix in ['.tar', '.gz', '.bz2', '.xz']:
            with tarfile.open(archive_path, 'r:*') as tf:
                files = tf.getnames()
        elif path.is_dir():
            files = [str(p.relative_to(path)) for p in path.rglob('*') if p.is_file()]
    except Exception as e:
        print(f"Warning: Could not extract file list from {archive_path}: {e}", file=sys.stderr)

    return files


def categorize_files(files: List[str]) -> Dict[str, List[str]]:
    """Categorize files by type"""
    categories = {
        'textures': [],
        '2da_tables': [],
        'scripts': [],
        'dialogs': [],
        'templates': [],
        'modules': [],
        'audio': [],
        'models': [],
        'tslpatcher': [],
        'other': []
    }

    for file in files:
        path = Path(file)
        ext = path.suffix.lower()
        name = path.name.lower()

        # Check for TSLPatcher indicators
        if 'tslpatchdata' in path.parts or name in ['changes.ini', 'namespaces.ini']:
            categories['tslpatcher'].append(file)
            continue

        # Categorize by extension
        if ext in ['.tpc', '.tga', '.txi']:
            categories['textures'].append(file)
        elif ext == '.2da':
            categories['2da_tables'].append(file)
        elif ext in ['.ncs', '.nss']:
            categories['scripts'].append(file)
        elif ext == '.dlg':
            categories['dialogs'].append(file)
        elif ext in ['.utc', '.uti', '.utp']:
            categories['templates'].append(file)
        elif ext in ['.rim', '.mod']:
            categories['modules'].append(file)
        elif ext in ['.wav', '.mp3']:
            categories['audio'].append(file)
        elif ext in ['.mdl', '.mdx']:
            categories['models'].append(file)
        else:
            categories['other'].append(file)

    return categories


def detect_install_method(categories: Dict[str, List[str]]) -> str:
    """Determine if mod uses Override or TSLPatcher installation"""
    if categories['tslpatcher']:
        return 'tslpatcher'
    return 'override'


def find_conflicts(mod1_files: List[str], mod2_files: List[str]) -> Dict[str, List[str]]:
    """Find filename conflicts between two mods"""
    # Normalize to filename only (ignore paths within mods)
    mod1_basenames = {Path(f).name: f for f in mod1_files}
    mod2_basenames = {Path(f).name: f for f in mod2_files}

    conflicts_by_risk = defaultdict(list)

    for basename in set(mod1_basenames.keys()) & set(mod2_basenames.keys()):
        ext = Path(basename).suffix.lower()
        risk = RISK_LEVELS.get(ext, 'UNKNOWN')

        conflicts_by_risk[risk].append({
            'filename': basename,
            'mod1_path': mod1_basenames[basename],
            'mod2_path': mod2_basenames[basename],
            'extension': ext
        })

    return dict(conflicts_by_risk)


def analyze_mods(mod_paths: List[str]) -> Dict:
    """Analyze multiple mods for conflicts"""
    mods = []

    # Extract file lists for each mod
    for i, mod_path in enumerate(mod_paths):
        print(f"Analyzing mod {i+1}: {Path(mod_path).name}...", file=sys.stderr)

        files = extract_file_list(mod_path)
        categories = categorize_files(files)
        install_method = detect_install_method(categories)

        mod_info = {
            'path': mod_path,
            'name': Path(mod_path).stem,
            'files': files,
            'file_count': len(files),
            'categories': {k: len(v) for k, v in categories.items() if v},
            'install_method': install_method
        }

        mods.append(mod_info)

    # Find conflicts between all pairs
    conflicts = []
    for i in range(len(mods)):
        for j in range(i + 1, len(mods)):
            mod1 = mods[i]
            mod2 = mods[j]

            conflict_data = find_conflicts(mod1['files'], mod2['files'])

            if conflict_data:
                conflicts.append({
                    'mod1': mod1['name'],
                    'mod2': mod2['name'],
                    'conflicts': conflict_data
                })

    # Overall assessment
    has_high_risk = any(
        any(risk in ['VERY HIGH', 'HIGH'] for risk in c['conflicts'].keys())
        for c in conflicts
    )

    has_medium_risk = any(
        'MEDIUM' in c['conflicts'].keys()
        for c in conflicts
    )

    if not conflicts:
        overall_status = 'compatible'
    elif has_high_risk:
        overall_status = 'major_conflicts'
    elif has_medium_risk:
        overall_status = 'minor_conflicts'
    else:
        overall_status = 'compatible_with_warnings'

    return {
        'mods': mods,
        'conflicts': conflicts,
        'overall_status': overall_status,
        'summary': {
            'total_mods': len(mods),
            'total_conflicts': len(conflicts),
            'has_high_risk_conflicts': has_high_risk,
            'has_medium_risk_conflicts': has_medium_risk
        }
    }


def print_report(analysis: Dict):
    """Print human-readable conflict report"""
    print("\n" + "=" * 70)
    print("KOTOR MOD COMPATIBILITY ANALYSIS")
    print("=" * 70)

    print(f"\nMods analyzed: {analysis['summary']['total_mods']}")
    for mod in analysis['mods']:
        install_indicator = "🔧 TSLPatcher" if mod['install_method'] == 'tslpatcher' else "📁 Override"
        print(f"  • {mod['name']} ({mod['file_count']} files) {install_indicator}")

    print(f"\n Overall Status: {analysis['overall_status'].upper()}")

    if not analysis['conflicts']:
        print("\n✓ No conflicts detected! These mods are compatible.")
        return

    print(f"\n Conflicts found: {analysis['summary']['total_conflicts']} mod pairs")

    for conflict_pair in analysis['conflicts']:
        print(f"\n{'─' * 70}")
        print(f"Conflict: {conflict_pair['mod1']} ↔ {conflict_pair['mod2']}")
        print(f"{'─' * 70}")

        for risk_level in ['VERY HIGH', 'HIGH', 'MEDIUM', 'LOW', 'UNKNOWN']:
            if risk_level in conflict_pair['conflicts']:
                conflicts = conflict_pair['conflicts'][risk_level]
                icon = {
                    'VERY HIGH': '🚫',
                    'HIGH': '❌',
                    'MEDIUM': '⚠️ ',
                    'LOW': 'ℹ️ ',
                    'UNKNOWN': '❓'
                }.get(risk_level, '')

                print(f"\n  {icon} {risk_level} Risk: {len(conflicts)} files")

                # Show first 5 conflicts
                for conflict in conflicts[:5]:
                    print(f"     • {conflict['filename']}")

                if len(conflicts) > 5:
                    print(f"     ... and {len(conflicts) - 5} more")

    # Recommendations
    print(f"\n{'═' * 70}")
    print("RECOMMENDATIONS")
    print(f"{'═' * 70}")

    if analysis['overall_status'] == 'major_conflicts':
        print("\n❌ MAJOR CONFLICTS DETECTED")
        print("   These mods have serious compatibility issues:")
        print("   • Conflicting .2da files (data tables)")
        print("   • Conflicting .dlg files (dialogs)")
        print("   • Conflicting module files (.rim/.mod)")
        print("\n   Actions:")
        print("   1. Choose one mod over the other")
        print("   2. Check if mods can be installed in specific order")
        print("   3. Look for compatibility patches")
        print("   4. Manual merging (advanced users only)")

    elif analysis['overall_status'] == 'minor_conflicts':
        print("\n⚠️  MINOR CONFLICTS DETECTED")
        print("   These mods have conflicts that may be resolvable:")
        print("   • Script conflicts")
        print("   • Template conflicts")
        print("\n   Actions:")
        print("   1. Last installed mod will win for conflicting files")
        print("   2. Consider installation order")
        print("   3. Test in-game to verify functionality")

    else:
        print("\nℹ️  LOW-RISK CONFLICTS ONLY")
        print("   Texture/audio conflicts - last installed wins")
        print("   Safe to install; choose preferred visuals/sounds")


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: check_mod_conflicts.py <mod1> <mod2> [mod3 ...] [--json]")
        print("")
        print("Analyze conflicts between KOTOR mods")
        print("")
        print("Supported formats: .zip, .7z, .tar.gz, .tar.bz2, directories")
        print("")
        print("Examples:")
        print("  check_mod_conflicts.py mod1.zip mod2.zip")
        print("  check_mod_conflicts.py /path/to/mod1 /path/to/mod2 --json")
        sys.exit(1)

    json_output = '--json' in sys.argv
    mod_paths = [arg for arg in sys.argv[1:] if arg != '--json']

    # Validate paths
    for path in mod_paths:
        if not Path(path).exists():
            print(f"Error: Path not found: {path}", file=sys.stderr)
            sys.exit(1)

    # Analyze
    analysis = analyze_mods(mod_paths)

    # Output
    if json_output:
        print(json.dumps(analysis, indent=2))
    else:
        print_report(analysis)

    # Exit code based on conflicts
    if analysis['overall_status'] == 'major_conflicts':
        sys.exit(2)
    elif analysis['overall_status'] in ['minor_conflicts', 'compatible_with_warnings']:
        sys.exit(1)
    else:
        sys.exit(0)
