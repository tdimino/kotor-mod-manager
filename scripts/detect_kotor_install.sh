#!/bin/bash

# detect_kotor_install.sh
# Detects KOTOR 1 and KOTOR 2 installations on macOS
# Validates Override folders and writes results to JSON

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Output JSON file
OUTPUT_FILE="$HOME/.claude/skills/kotor-mod-manager/data/installation_paths.json"

# Ensure data directory exists
mkdir -p "$(dirname "$OUTPUT_FILE")"

echo "🔍 Detecting KOTOR installations on macOS..."
echo ""

# Function to check if a path exists
path_exists() {
    [ -d "$1" ]
}

# Function to detect KOTOR installation
detect_kotor() {
    local game_name=$1
    local game_key=$2
    local app_path=$3
    local data_subpath=$4

    local result="{"
    result+="\"detected\":false,"
    result+="\"game_name\":\"$game_name\","

    if path_exists "$app_path"; then
        echo -e "${GREEN}✓${NC} Found $game_name"
        echo "  App: $app_path"

        local data_path="$app_path/Contents/$data_subpath"
        local override_path="$data_path/Override"

        result+="\"detected\":true,"
        result+="\"app_path\":\"$app_path\","
        result+="\"data_path\":\"$data_path\","

        # Check Override folder
        if path_exists "$override_path"; then
            echo -e "  Override: ${GREEN}EXISTS${NC}"
            result+="\"override_path\":\"$override_path\","
            result+="\"override_exists\":true"

            # Check permissions
            if [ -w "$override_path" ]; then
                echo -e "  Permissions: ${GREEN}WRITABLE${NC}"
                result+=",\"override_writable\":true"
            else
                echo -e "  Permissions: ${YELLOW}READ-ONLY${NC}"
                echo -e "  ${YELLOW}⚠${NC}  Fix with: chmod -R 755 \"$override_path\""
                result+=",\"override_writable\":false"
            fi
        else
            echo -e "  Override: ${YELLOW}MISSING${NC}"
            echo -e "  ${YELLOW}⚠${NC}  Creating Override folder..."
            mkdir -p "$override_path"
            if [ -d "$override_path" ]; then
                echo -e "  ${GREEN}✓${NC} Override folder created"
                result+="\"override_path\":\"$override_path\","
                result+="\"override_exists\":true,"
                result+="\"override_writable\":true"
            else
                echo -e "  ${RED}✗${NC} Failed to create Override folder"
                result+="\"override_exists\":false,"
                result+="\"override_writable\":false"
            fi
        fi

        # Count existing mods
        local mod_count=0
        if [ -d "$override_path" ]; then
            mod_count=$(find "$override_path" -type f 2>/dev/null | wc -l | tr -d ' ')
            echo "  Files in Override: $mod_count"
            result+=",\"mod_file_count\":$mod_count"
        fi

    else
        echo -e "${RED}✗${NC} $game_name not found"
        result+="\"detected\":false"
    fi

    result+="}"
    echo "$result"
}

# Standard Steam library location
STEAM_LIBRARY="$HOME/Library/Application Support/Steam/steamapps/common"

# Check if Steam library exists
if ! path_exists "$STEAM_LIBRARY"; then
    echo -e "${RED}✗${NC} Steam library not found at: $STEAM_LIBRARY"
    echo ""
    echo "Possible causes:"
    echo "  1. Steam is not installed"
    echo "  2. Steam library is in a different location"
    echo "  3. Games are on an external drive"
    echo ""
    echo "To find Steam libraries, check:"
    echo "  ~/Library/Application Support/Steam/config/libraryfolders.vdf"
    exit 1
fi

# KOTOR 1 paths
KOTOR1_PATH="$STEAM_LIBRARY/swkotor/Knights of the Old Republic.app"

# KOTOR 2 paths
KOTOR2_PATH="$STEAM_LIBRARY/Knights of the Old Republic II/KOTOR2.app"

# Detect installations
echo "Checking standard Steam library: $STEAM_LIBRARY"
echo ""

KOTOR1_JSON=$(detect_kotor "KOTOR 1" "kotor1" "$KOTOR1_PATH" "KOTOR Data")
echo ""

KOTOR2_JSON=$(detect_kotor "KOTOR 2" "kotor2" "$KOTOR2_PATH" "GameData")
echo ""

# Check for additional Steam libraries
echo "Checking for additional Steam library locations..."
LIBRARY_FOLDERS_FILE="$HOME/Library/Application Support/Steam/config/libraryfolders.vdf"

ADDITIONAL_LIBRARIES=()
if [ -f "$LIBRARY_FOLDERS_FILE" ]; then
    # Parse libraryfolders.vdf for additional paths
    while IFS= read -r line; do
        if [[ $line =~ \"path\"[[:space:]]+\"([^\"]+)\" ]]; then
            lib_path="${BASH_REMATCH[1]}/steamapps/common"
            if [ "$lib_path" != "$STEAM_LIBRARY" ] && [ -d "$lib_path" ]; then
                ADDITIONAL_LIBRARIES+=("$lib_path")
            fi
        fi
    done < "$LIBRARY_FOLDERS_FILE"
fi

# Check additional libraries
if [ ${#ADDITIONAL_LIBRARIES[@]} -gt 0 ]; then
for lib in "${ADDITIONAL_LIBRARIES[@]}"; do
    echo "Checking additional library: $lib"

    ALT_KOTOR1="$lib/swkotor/Knights of the Old Republic.app"
    ALT_KOTOR2="$lib/Knights of the Old Republic II/KOTOR2.app"

    if path_exists "$ALT_KOTOR1"; then
        echo "Found KOTOR 1 in additional library!"
        KOTOR1_JSON=$(detect_kotor "KOTOR 1" "kotor1" "$ALT_KOTOR1" "KOTOR Data")
        echo ""
    fi

    if path_exists "$ALT_KOTOR2"; then
        echo "Found KOTOR 2 in additional library!"
        KOTOR2_JSON=$(detect_kotor "KOTOR 2" "kotor2" "$ALT_KOTOR2" "GameData")
        echo ""
    fi
done
fi

# Write JSON output
cat > "$OUTPUT_FILE" <<EOF
{
  "last_detected": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "kotor1": $KOTOR1_JSON,
  "kotor2": $KOTOR2_JSON
}
EOF

echo -e "${GREEN}✓${NC} Detection complete"
echo "Results saved to: $OUTPUT_FILE"
echo ""

# Summary
K1_DETECTED=$(echo "$KOTOR1_JSON" | grep -o '"detected":true' || echo "")
K2_DETECTED=$(echo "$KOTOR2_JSON" | grep -o '"detected":true' || echo "")

echo "Summary:"
if [ -n "$K1_DETECTED" ]; then
    echo -e "  ${GREEN}✓${NC} KOTOR 1: Ready for modding"
else
    echo -e "  ${RED}✗${NC} KOTOR 1: Not found"
fi

if [ -n "$K2_DETECTED" ]; then
    echo -e "  ${GREEN}✓${NC} KOTOR 2: Ready for modding"
else
    echo -e "  ${RED}✗${NC} KOTOR 2: Not found"
fi

# Exit with appropriate code
if [ -n "$K1_DETECTED" ] || [ -n "$K2_DETECTED" ]; then
    exit 0
else
    exit 1
fi
