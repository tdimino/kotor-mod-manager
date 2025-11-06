#!/bin/bash

# install_kotor_command.sh
# Creates a 'kotor' command to launch KOTOR with mods (bypassing Steam)
# Works for any user with KOTOR installed via Steam on macOS

set -euo pipefail

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Emojis
CHECK="✅"
CROSS="❌"
ROCKET="🚀"
INFO="ℹ️"

echo -e "${BLUE}======================================${NC}"
echo -e "${BLUE}KOTOR Command Installer${NC}"
echo -e "${BLUE}======================================${NC}"
echo ""

# Detect KOTOR installation
detect_kotor() {
    local kotor_path="$HOME/Library/Application Support/Steam/steamapps/common/swkotor/Knights of the Old Republic.app"

    if [ -e "$kotor_path" ]; then
        echo -e "${GREEN}${CHECK} KOTOR installation found${NC}"
        echo "   $kotor_path"
        echo "$kotor_path"
        return 0
    else
        echo -e "${RED}${CROSS} KOTOR not found in default Steam location${NC}"
        echo -e "${YELLOW}${INFO} Please ensure KOTOR is installed via Steam${NC}"
        return 1
    fi
}

# Detect shell configuration file
detect_shell_config() {
    if [ -n "${SHELL:-}" ]; then
        case "$SHELL" in
            */zsh)
                echo "$HOME/.zshrc"
                ;;
            */bash)
                if [ -f "$HOME/.bash_profile" ]; then
                    echo "$HOME/.bash_profile"
                elif [ -f "$HOME/.bashrc" ]; then
                    echo "$HOME/.bashrc"
                else
                    echo "$HOME/.bash_profile"
                fi
                ;;
            *)
                echo "$HOME/.profile"
                ;;
        esac
    else
        echo "$HOME/.profile"
    fi
}

# Create ~/bin directory if it doesn't exist
create_bin_dir() {
    if [ ! -d "$HOME/bin" ]; then
        mkdir -p "$HOME/bin"
        echo -e "${GREEN}${CHECK} Created ~/bin directory${NC}"
    else
        echo -e "${GREEN}${CHECK} ~/bin directory exists${NC}"
    fi
}

# Create kotor launch script
create_kotor_script() {
    local kotor_path="$1"
    local script_path="$HOME/bin/kotor"

    cat > "$script_path" << EOF
#!/bin/bash
# Launch KOTOR with mods (bypassing Steam)

KOTOR_APP="$kotor_path"

if [ ! -e "\$KOTOR_APP" ]; then
    echo "Error: KOTOR not found at \$KOTOR_APP"
    exit 1
fi

echo "${ROCKET} Launching KOTOR with mods..."
open "\$KOTOR_APP"
EOF

    chmod +x "$script_path"
    echo -e "${GREEN}${CHECK} Created 'kotor' command at $script_path${NC}"
}

# Add ~/bin to PATH if not already there
add_to_path() {
    local shell_config="$1"

    # Check if ~/bin is already in PATH
    if echo "$PATH" | grep -q "$HOME/bin"; then
        echo -e "${GREEN}${CHECK} ~/bin is already in PATH${NC}"
        return 0
    fi

    # Check if the PATH export is already in the config file
    if [ -f "$shell_config" ] && grep -q "export PATH=\"\$HOME/bin:\$PATH\"" "$shell_config"; then
        echo -e "${GREEN}${CHECK} PATH configuration already exists in $shell_config${NC}"
        return 0
    fi

    # Add to shell config
    echo "" >> "$shell_config"
    echo "# Add ~/bin to PATH for custom scripts" >> "$shell_config"
    echo "export PATH=\"\$HOME/bin:\$PATH\"" >> "$shell_config"

    echo -e "${GREEN}${CHECK} Added ~/bin to PATH in $shell_config${NC}"
    echo -e "${YELLOW}${INFO} Run 'source $shell_config' or restart your terminal to use the command${NC}"
}

# Main installation
main() {
    echo -e "${INFO} Detecting KOTOR installation..."
    local kotor_path
    kotor_path=$(detect_kotor) || exit 1

    echo ""
    echo -e "${INFO} Creating ~/bin directory..."
    create_bin_dir

    echo ""
    echo -e "${INFO} Creating kotor launch command..."
    create_kotor_script "$kotor_path"

    echo ""
    echo -e "${INFO} Configuring PATH..."
    local shell_config
    shell_config=$(detect_shell_config)
    echo "   Using: $shell_config"
    add_to_path "$shell_config"

    echo ""
    echo -e "${BLUE}======================================${NC}"
    echo -e "${GREEN}Installation Complete!${NC}"
    echo -e "${BLUE}======================================${NC}"
    echo ""
    echo -e "Usage:"
    echo -e "  ${GREEN}kotor${NC}     - Launch KOTOR with mods"
    echo ""
    echo -e "To activate the command in your current terminal:"
    echo -e "  ${YELLOW}source $shell_config${NC}"
    echo ""
    echo -e "Or simply open a new terminal window."
    echo ""
    echo -e "${YELLOW}IMPORTANT: Always use 'kotor' command or desktop shortcut.${NC}"
    echo -e "${YELLOW}           NEVER launch through Steam!${NC}"
    echo ""
}

main "$@"
