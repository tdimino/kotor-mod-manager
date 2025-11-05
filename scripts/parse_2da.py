#!/usr/bin/env python3

"""
parse_2da.py
Parse and analyze KOTOR .2da (2-Dimensional Array) files for conflict detection
"""

import sys
import re
from typing import Dict, List, Set, Tuple, Optional
from pathlib import Path


class TwoDAFile:
    """Represents a parsed .2da file"""

    def __init__(self, filepath: str):
        self.filepath = Path(filepath)
        self.version = None
        self.default_value = "****"
        self.columns = []
        self.rows = {}
        self.labels = {}
        self.parse()

    def parse(self):
        """Parse .2da file format"""
        with open(self.filepath, 'r', encoding='utf-8', errors='ignore') as f:
            lines = [line.rstrip() for line in f.readlines()]

        if not lines:
            raise ValueError(f"Empty .2da file: {self.filepath}")

        # Line 0: Version (e.g., "2DA V2.0" or "2DA V2.b")
        self.version = lines[0].strip()
        if not self.version.startswith("2DA"):
            raise ValueError(f"Invalid .2da format: {self.filepath}")

        # Line 1: Usually blank or default value
        if len(lines) > 1 and lines[1].strip():
            self.default_value = lines[1].strip()

        # Line 2: Column headers
        if len(lines) < 3:
            raise ValueError(f"Incomplete .2da file: {self.filepath}")

        header_line = lines[2].strip()
        self.columns = header_line.split()

        # Lines 3+: Data rows
        for i, line in enumerate(lines[3:], start=0):
            line = line.strip()
            if not line:
                continue

            parts = line.split()
            if len(parts) < 1:
                continue

            row_id = parts[0]
            label = parts[1] if len(parts) > 1 else ""
            values = parts[2:] if len(parts) > 2 else []

            # Pad values to match column count
            while len(values) < len(self.columns):
                values.append(self.default_value)

            self.rows[row_id] = values
            self.labels[row_id] = label

    def get_value(self, row_id: str, column: str) -> Optional[str]:
        """Get value at specific row and column"""
        if row_id not in self.rows:
            return None
        if column not in self.columns:
            return None

        col_index = self.columns.index(column)
        values = self.rows[row_id]

        if col_index < len(values):
            return values[col_index]
        return self.default_value

    def get_modified_rows(self, original: 'TwoDAFile') -> Set[str]:
        """Compare to original and find modified rows"""
        modified = set()

        for row_id in self.rows:
            if row_id not in original.rows:
                # New row
                continue

            # Compare values
            our_values = self.rows[row_id]
            their_values = original.rows[row_id]

            if our_values != their_values:
                modified.add(row_id)

        return modified

    def get_new_rows(self, original: 'TwoDAFile') -> Set[str]:
        """Find rows that don't exist in original"""
        return set(self.rows.keys()) - set(original.rows.keys())

    def has_new_columns(self, original: 'TwoDAFile') -> List[str]:
        """Find columns that don't exist in original"""
        return [col for col in self.columns if col not in original.columns]


def compare_2da_files(file1_path: str, file2_path: str) -> Dict:
    """
    Compare two .2da files and return conflict analysis

    Returns:
        dict with keys:
        - conflict: bool
        - severity: "none", "low", "medium", "high"
        - details: dict with conflict details
    """
    try:
        file1 = TwoDAFile(file1_path)
        file2 = TwoDAFile(file2_path)
    except Exception as e:
        return {
            "conflict": True,
            "severity": "error",
            "details": {
                "error": f"Failed to parse: {str(e)}"
            }
        }

    # Assume file1 is the vanilla/earlier mod, file2 is the new mod
    result = {
        "conflict": False,
        "severity": "none",
        "details": {}
    }

    # Check for new columns
    new_columns = file2.has_new_columns(file1)
    if new_columns:
        result["details"]["new_columns"] = new_columns
        result["details"]["column_conflict"] = True
        result["conflict"] = True
        result["severity"] = "high"
        return result

    # Check for modified rows
    modified_rows = file2.get_modified_rows(file1)
    if modified_rows:
        result["details"]["modified_rows"] = list(modified_rows)
        result["details"]["modified_count"] = len(modified_rows)
        result["conflict"] = True
        result["severity"] = "high"

    # Check for new rows
    new_rows = file2.get_new_rows(file1)
    if new_rows:
        result["details"]["new_rows"] = list(new_rows)
        result["details"]["new_count"] = len(new_rows)

        if not result["conflict"]:
            # Only new rows, no modifications - TSLPatcher can merge
            result["conflict"] = True
            result["severity"] = "medium"  # Mergeable with TSLPatcher
            result["details"]["tslpatcher_mergeable"] = True

    if not result["conflict"]:
        result["severity"] = "none"
        result["details"]["identical"] = True

    return result


def analyze_2da_conflict(file1_path: str, file2_path: str, json_output: bool = False):
    """Analyze and report .2da file conflicts"""
    result = compare_2da_files(file1_path, file2_path)

    if json_output:
        import json
        print(json.dumps(result, indent=2))
        return

    filename = Path(file1_path).name
    print(f"\n.2da Analysis: {filename}")
    print("=" * 60)

    if result["severity"] == "error":
        print(f"❌ ERROR: {result['details']['error']}")
        return

    if result["severity"] == "none":
        print("✓ No conflicts - files are identical or compatible")
        return

    details = result["details"]

    if "column_conflict" in details:
        print(f"❌ HIGH CONFLICT: Column structure changes")
        print(f"   New columns: {', '.join(details['new_columns'])}")
        print(f"   Resolution: Manual merging required or choose one mod")
        return

    if "modified_rows" in details:
        print(f"❌ HIGH CONFLICT: {details['modified_count']} rows modified")
        print(f"   Modified row IDs: {', '.join(details['modified_rows'][:10])}")
        if len(details['modified_rows']) > 10:
            print(f"   ... and {len(details['modified_rows']) - 10} more")
        print(f"   Resolution: Choose one mod or manual merge")

    if "new_rows" in details:
        severity = "⚠" if details.get("tslpatcher_mergeable") else "❌"
        print(f"{severity}  MEDIUM CONFLICT: {details['new_count']} new rows")
        print(f"   New row IDs: {', '.join(details['new_rows'][:10])}")
        if len(details['new_rows']) > 10:
            print(f"   ... and {len(details['new_rows']) - 10} more")

        if details.get("tslpatcher_mergeable"):
            print(f"   Resolution: TSLPatcher can merge these changes")
        else:
            print(f"   Resolution: Manual merging may be required")


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: parse_2da.py <file1.2da> <file2.2da> [--json]")
        print("")
        print("Compare two .2da files for conflicts")
        print("")
        print("Examples:")
        print("  parse_2da.py vanilla/baseitems.2da mod/baseitems.2da")
        print("  parse_2da.py file1.2da file2.2da --json")
        sys.exit(1)

    file1 = sys.argv[1]
    file2 = sys.argv[2]
    json_mode = "--json" in sys.argv

    if not Path(file1).exists():
        print(f"Error: File not found: {file1}")
        sys.exit(1)

    if not Path(file2).exists():
        print(f"Error: File not found: {file2}")
        sys.exit(1)

    analyze_2da_conflict(file1, file2, json_output=json_mode)
