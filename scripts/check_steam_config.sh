#!/bin/bash

# check_steam_config.sh
# Verifies Steam configuration for KOTOR modding on macOS
# Checks for Steam overlay, cloud save, and provides setup guidance

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Emojis
CHECK="✅"
CROSS="❌"
WARNING="⚠️"
INFO="ℹ️"
ROCKET="🚀"

echo -e "${BLUE}======================================${NC}"
echo -e "${BLUE}KOTOR Steam Configuration Checker${NC}"
echo -e "${BLUE}======================================${NC}"
echo ""

# Function to check if KOTOR is installed via Steam
check_steam_install() {
    local kotor_path="$HOME/Library/Application Support/Steam/steamapps/common/swkotor"

    if [ -d "$kotor_path" ]; then
        echo -e "${GREEN}${CHECK} KOTOR Steam installation found${NC}"
        echo -e "   Path: $kotor_path"
        return 0
    else
        echo -e "${RED}${CROSS} KOTOR Steam installation not found${NC}"
        echo -e "   Expected: $kotor_path"
        return 1
    fi
}

# Function to check Steam config files
check_steam_settings() {
    local appid="32370"  # KOTOR 1 App ID
    local steam_userdata="$HOME/Library/Application Support/Steam/userdata"

    echo ""
    echo -e "${YELLOW}${INFO} Checking Steam configuration files...${NC}"

    if [ ! -d "$steam_userdata" ]; then
        echo -e "${RED}${CROSS} Steam userdata folder not found${NC}"
        return 1
    fi

    # Find localconfig.vdf files
    local config_files=$(find "$steam_userdata" -name "localconfig.vdf" 2>/dev/null)

    if [ -z "$config_files" ]; then
        echo -e "${YELLOW}${WARNING} No Steam config files found${NC}"
        return 1
    fi

    local found_kotor=false

    while IFS= read -r config_file; do
        if grep -q "\"$appid\"" "$config_file" 2>/dev/null; then
            found_kotor=true
            echo -e "${GREEN}${CHECK} Found KOTOR configuration in Steam${NC}"

            # Check for overlay setting
            if grep -A 50 "\"$appid\"" "$config_file" | grep -q "\"EnableOverlay\""; then
                local overlay_status=$(grep -A 50 "\"$appid\"" "$config_file" | grep "\"EnableOverlay\"" | grep -o "[0-1]" | head -1)
                if [ "$overlay_status" = "0" ]; then
                    echo -e "${GREEN}   ${CHECK} Steam Overlay: DISABLED${NC}"
                else
                    echo -e "${RED}   ${CROSS} Steam Overlay: ENABLED (should be disabled)${NC}"
                fi
            else
                echo -e "${YELLOW}   ${WARNING} Steam Overlay setting not found${NC}"
            fi
        fi
    done <<< "$config_files"

    if [ "$found_kotor" = false ]; then
        echo -e "${YELLOW}${WARNING} KOTOR not found in Steam configuration${NC}"
    fi
}

# Function to check for desktop shortcuts
check_shortcuts() {
    echo ""
    echo -e "${YELLOW}${INFO} Checking for desktop shortcuts...${NC}"

    local desktop="$HOME/Desktop"
    local found_shortcut=false

    # Check for common shortcut names
    if [ -e "$desktop/KOTOR.app" ] || [ -e "$desktop/KOTOR Modded.app" ] || [ -L "$desktop/KOTOR.app" ]; then
        echo -e "${GREEN}${CHECK} KOTOR desktop shortcut found${NC}"
        found_shortcut=true
    else
        echo -e "${YELLOW}${CROSS} No KOTOR desktop shortcut found${NC}"
        echo -e "   ${INFO} You should create a shortcut to launch KOTOR without Steam"
    fi

    return 0
}

# Function to provide configuration instructions
provide_instructions() {
    echo ""
    echo -e "${BLUE}======================================${NC}"
    echo -e "${BLUE}Configuration Instructions${NC}"
    echo -e "${BLUE}======================================${NC}"
    echo ""
    echo -e "${YELLOW}Required Steps for KOTOR Modding:${NC}"
    echo ""
    echo "1. ${CROSS} Disable Steam Overlay:"
    echo "   - Open Steam Library"
    echo "   - Right-click KOTOR → Properties"
    echo "   - Uncheck 'Enable Steam Overlay'"
    echo ""
    echo "2. ${CROSS} Disable Cloud Save:"
    echo "   - In Properties → General tab"
    echo "   - Uncheck 'Enable Steam Cloud synchronization'"
    echo ""
    echo "3. ${CROSS} Disable Auto-Update:"
    echo "   - In Properties → Updates tab"
    echo "   - Set to 'Only update when I launch it'"
    echo ""
    echo "4. ${ROCKET} Create Desktop Shortcut:"
    echo "   Run this command:"
    echo "   ln -s \"$HOME/Library/Application Support/Steam/steamapps/common/swkotor/Knights of the Old Republic.app\" \"$HOME/Desktop/KOTOR.app\""
    echo ""
    echo -e "${RED}IMPORTANT: After installing mods, always launch using the desktop shortcut, NOT through Steam!${NC}"
    echo ""
}

# Function to create desktop shortcut
create_shortcut() {
    echo ""
    echo -e "${YELLOW}${INFO} Would you like to create a desktop shortcut now? (y/n)${NC}"
    read -r response

    if [[ "$response" =~ ^[Yy]$ ]]; then
        local kotor_app="$HOME/Library/Application Support/Steam/steamapps/common/swkotor/Knights of the Old Republic.app"
        local desktop_shortcut="$HOME/Desktop/KOTOR.app"

        if [ -e "$kotor_app" ]; then
            ln -sf "$kotor_app" "$desktop_shortcut"
            echo -e "${GREEN}${CHECK} Desktop shortcut created successfully!${NC}"
            echo -e "   Location: $desktop_shortcut"
        else
            echo -e "${RED}${CROSS} KOTOR application not found${NC}"
            echo -e "   Expected: $kotor_app"
        fi
    fi
}

# Function to check Override folder
check_override_folder() {
    echo ""
    echo -e "${YELLOW}${INFO} Checking Override folder...${NC}"

    local override_path="$HOME/Library/Application Support/Steam/steamapps/common/swkotor/Knights of the Old Republic.app/Contents/KOTOR Data/Override"

    if [ -d "$override_path" ]; then
        echo -e "${GREEN}${CHECK} Override folder exists${NC}"
        local file_count=$(find "$override_path" -type f | wc -l | tr -d ' ')
        echo -e "   ${INFO} Files in Override: $file_count"

        if [ "$file_count" -gt 0 ]; then
            echo -e "${GREEN}   ${INFO} Mods appear to be installed${NC}"
        fi
    else
        echo -e "${YELLOW}${WARNING} Override folder does not exist${NC}"
        echo -e "   ${INFO} It will be created when you install mods"
    fi
}

# Function to display summary
display_summary() {
    echo ""
    echo -e "${BLUE}======================================${NC}"
    echo -e "${BLUE}Configuration Summary${NC}"
    echo -e "${BLUE}======================================${NC}"
    echo ""
    echo -e "${GREEN}${CHECK}${NC} = Configured correctly"
    echo -e "${RED}${CROSS}${NC} = Needs configuration"
    echo -e "${YELLOW}${WARNING}${NC} = Unable to verify"
    echo ""
    echo "For detailed instructions, see:"
    echo "~/.claude/skills/kotor-mod-manager/references/steam-configuration.md"
    echo ""
}

# Main execution
main() {
    if check_steam_install; then
        check_steam_settings
        check_shortcuts
        check_override_folder
        display_summary
        provide_instructions
        create_shortcut
    else
        echo ""
        echo -e "${RED}Please install KOTOR through Steam first.${NC}"
        exit 1
    fi
}

main "$@"
