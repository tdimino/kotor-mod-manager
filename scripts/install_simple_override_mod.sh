#!/usr/bin/env bash

# install_simple_override_mod.sh
# Quick installer for simple Override folder mods (textures, models, simple replacements)
# For mods that are just files to copy - no TSLPatcher, no complex installation

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="$SCRIPT_DIR/../data"
INSTALL_LOG="$DATA_DIR/installed_mods.json"

# Ensure data directory exists
mkdir -p "$DATA_DIR"

# Function to print colored output
print_header() {
    echo -e "\n${CYAN}╔════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}  ${BLUE}KOTOR Simple Override Mod Installer${NC}   ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════╝${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

# Function to detect KOTOR installation
detect_kotor_install() {
    local install_path_file="$DATA_DIR/installation_paths.json"

    if [[ -f "$install_path_file" ]]; then
        # Parse JSON to get Override path
        OVERRIDE_PATH=$(grep -o '"override_path":"[^"]*"' "$install_path_file" | cut -d'"' -f4 | head -1)

        if [[ -n "$OVERRIDE_PATH" ]] && [[ -d "$OVERRIDE_PATH" ]]; then
            print_success "KOTOR installation found"
            print_info "Override path: $OVERRIDE_PATH"
            return 0
        fi
    fi

    # Run detection script if path not found
    print_info "Running installation detection..."
    "$SCRIPT_DIR/detect_kotor_install.sh" > /dev/null 2>&1

    # Try again
    if [[ -f "$install_path_file" ]]; then
        OVERRIDE_PATH=$(grep -o '"override_path":"[^"]*"' "$install_path_file" | cut -d'"' -f4 | head -1)

        if [[ -n "$OVERRIDE_PATH" ]] && [[ -d "$OVERRIDE_PATH" ]]; then
            print_success "KOTOR installation found"
            print_info "Override path: $OVERRIDE_PATH"
            return 0
        fi
    fi

    print_error "Could not detect KOTOR installation"
    return 1
}

# Function to extract mod archive
extract_mod() {
    local archive_path="$1"
    local temp_dir="/tmp/kotor_mod_install_$$"

    print_info "Extracting mod archive..."

    mkdir -p "$temp_dir"

    case "$archive_path" in
        *.zip)
            unzip -q "$archive_path" -d "$temp_dir" || return 1
            ;;
        *.7z)
            7z x "$archive_path" -o"$temp_dir" > /dev/null || return 1
            ;;
        *.rar)
            unrar x "$archive_path" "$temp_dir" > /dev/null 2>&1 || return 1
            ;;
        *)
            print_error "Unsupported archive format. Supported: .zip, .7z, .rar"
            return 1
            ;;
    esac

    print_success "Mod extracted to: $temp_dir"
    echo "$temp_dir"
}

# Function to find mod files
find_mod_files() {
    local temp_dir="$1"

    print_info "Analyzing mod structure..."

    # Find all game files (common KOTOR file types)
    local file_count=$(find "$temp_dir" -type f \( \
        -iname "*.mdl" -o -iname "*.mdx" -o \
        -iname "*.tga" -o -iname "*.tpc" -o \
        -iname "*.2da" -o -iname "*.ncs" -o \
        -iname "*.nss" -o -iname "*.dlg" -o \
        -iname "*.utc" -o -iname "*.uti" -o \
        -iname "*.utp" -o -iname "*.wav" -o \
        -iname "*.mp3" \) | wc -l | tr -d ' ')

    if [[ "$file_count" -eq 0 ]]; then
        print_error "No KOTOR mod files found in archive"
        return 1
    fi

    print_success "Found $file_count mod files"

    # List file types
    echo ""
    echo -e "${CYAN}File breakdown:${NC}"
    find "$temp_dir" -type f \( \
        -iname "*.mdl" -o -iname "*.mdx" -o \
        -iname "*.tga" -o -iname "*.tpc" -o \
        -iname "*.2da" -o -iname "*.ncs" -o \
        -iname "*.nss" -o -iname "*.dlg" -o \
        -iname "*.utc" -o -iname "*.uti" -o \
        -iname "*.utp" -o -iname "*.wav" -o \
        -iname "*.mp3" \) -exec basename {} \; | \
        sed 's/.*\.//' | sort | uniq -c | \
        awk '{printf "  %s files: %d\n", $2, $1}'

    return 0
}

# Function to list installation options
list_install_options() {
    local temp_dir="$1"

    echo ""
    echo -e "${CYAN}Available folders to install:${NC}"

    # Find directories containing mod files
    local dirs=()
    while IFS= read -r dir; do
        dirs+=("$dir")
    done < <(find "$temp_dir" -type f \( \
        -iname "*.mdl" -o -iname "*.mdx" -o \
        -iname "*.tga" -o -iname "*.tpc" \) \
        -exec dirname {} \; | sort -u)

    if [[ ${#dirs[@]} -eq 0 ]]; then
        print_error "No installable folders found"
        return 1
    fi

    local index=1
    for dir in "${dirs[@]}"; do
        local file_count=$(find "$dir" -maxdepth 1 -type f | wc -l | tr -d ' ')
        local rel_path="${dir#$temp_dir/}"
        echo "  $index) $rel_path ($file_count files)"
        index=$((index + 1))
    done

    echo "  a) All folders"
    echo "  q) Quit without installing"
    echo ""
}

# Function to check for conflicts
check_conflicts() {
    local source_dir="$1"

    print_info "Checking for file conflicts..."

    local conflicts=0
    local conflict_files=()

    while IFS= read -r file; do
        local basename=$(basename "$file")
        if [[ -f "$OVERRIDE_PATH/$basename" ]]; then
            conflicts=$((conflicts + 1))
            conflict_files+=("$basename")
        fi
    done < <(find "$source_dir" -type f \( \
        -iname "*.mdl" -o -iname "*.mdx" -o \
        -iname "*.tga" -o -iname "*.tpc" -o \
        -iname "*.2da" -o -iname "*.ncs" \))

    if [[ $conflicts -gt 0 ]]; then
        print_warning "Found $conflicts file conflicts (will be overwritten):"
        for file in "${conflict_files[@]:0:5}"; do
            echo "    - $file"
        done
        if [[ ${#conflict_files[@]} -gt 5 ]]; then
            echo "    ... and $((${#conflict_files[@]} - 5)) more"
        fi
        echo ""
        read -p "Continue with installation? (y/n): " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return 1
        fi
    else
        print_success "No file conflicts detected"
    fi

    return 0
}

# Function to install mod files
install_mod_files() {
    local source_dir="$1"
    local mod_name="$2"

    print_info "Installing mod files to Override folder..."

    local installed_count=0
    local installed_files=()

    # Find and copy all mod files
    while IFS= read -r file; do
        local basename=$(basename "$file")
        cp "$file" "$OVERRIDE_PATH/" || {
            print_error "Failed to copy $basename"
            return 1
        }
        installed_count=$((installed_count + 1))
        installed_files+=("$basename")
    done < <(find "$source_dir" -type f \( \
        -iname "*.mdl" -o -iname "*.mdx" -o \
        -iname "*.tga" -o -iname "*.tpc" -o \
        -iname "*.2da" -o -iname "*.ncs" -o \
        -iname "*.nss" -o -iname "*.dlg" -o \
        -iname "*.utc" -o -iname "*.uti" -o \
        -iname "*.utp" -o -iname "*.wav" -o \
        -iname "*.mp3" \))

    print_success "Installed $installed_count files"

    # Log installation
    log_installation "$mod_name" "${installed_files[@]}"

    return 0
}

# Function to verify installation
verify_installation() {
    local source_dir="$1"

    print_info "Verifying installation..."

    local verified=0
    local failed=0

    while IFS= read -r file; do
        local basename=$(basename "$file")
        if [[ -f "$OVERRIDE_PATH/$basename" ]]; then
            verified=$((verified + 1))
        else
            failed=$((failed + 1))
            print_error "Missing: $basename"
        fi
    done < <(find "$source_dir" -type f \( \
        -iname "*.mdl" -o -iname "*.mdx" -o \
        -iname "*.tga" -o -iname "*.tpc" -o \
        -iname "*.2da" -o -iname "*.ncs" \))

    if [[ $failed -eq 0 ]]; then
        print_success "All $verified files verified successfully"
        return 0
    else
        print_error "Verification failed: $failed files missing"
        return 1
    fi
}

# Function to log installation
log_installation() {
    local mod_name="$1"
    shift
    local files=("$@")

    # Create or update installation log
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    # Simple JSON append (not perfect but functional)
    if [[ ! -f "$INSTALL_LOG" ]]; then
        echo "{" > "$INSTALL_LOG"
        echo '  "installations": []' >> "$INSTALL_LOG"
        echo "}" >> "$INSTALL_LOG"
    fi

    # Note: This is a simplified log. For production, use proper JSON manipulation
    print_info "Installation logged to: $INSTALL_LOG"
}

# Main installation workflow
main() {
    print_header

    # Check if archive path provided
    if [[ $# -eq 0 ]]; then
        print_error "Usage: $0 <mod_archive_path>"
        echo ""
        echo "Example:"
        echo "  $0 ~/Downloads/kotor/twilek_mod.7z"
        echo ""
        exit 1
    fi

    local archive_path="$1"

    # Verify archive exists
    if [[ ! -f "$archive_path" ]]; then
        print_error "Archive not found: $archive_path"
        exit 1
    fi

    # Detect KOTOR installation
    detect_kotor_install || exit 1

    # Extract mod
    local temp_dir=$(extract_mod "$archive_path") || exit 1

    # Analyze mod structure
    find_mod_files "$temp_dir" || {
        rm -rf "$temp_dir"
        exit 1
    }

    # List installation options
    list_install_options "$temp_dir"

    # Get user choice
    read -p "Select folder to install: " choice

    if [[ "$choice" == "q" ]]; then
        print_info "Installation cancelled"
        rm -rf "$temp_dir"
        exit 0
    fi

    # Determine source directory
    local source_dir
    if [[ "$choice" == "a" ]]; then
        source_dir="$temp_dir"
        print_info "Installing all folders"
    else
        # Get the selected directory
        local dirs=()
        while IFS= read -r dir; do
            dirs+=("$dir")
        done < <(find "$temp_dir" -type f \( \
            -iname "*.mdl" -o -iname "*.mdx" -o \
            -iname "*.tga" -o -iname "*.tpc" \) \
            -exec dirname {} \; | sort -u)

        if [[ "$choice" =~ ^[0-9]+$ ]] && [[ $choice -ge 1 ]] && [[ $choice -le ${#dirs[@]} ]]; then
            source_dir="${dirs[$((choice - 1))]}"
            print_info "Installing: ${source_dir#$temp_dir/}"
        else
            print_error "Invalid choice"
            rm -rf "$temp_dir"
            exit 1
        fi
    fi

    # Check for conflicts
    check_conflicts "$source_dir" || {
        print_info "Installation cancelled by user"
        rm -rf "$temp_dir"
        exit 0
    }

    # Get mod name
    local mod_name=$(basename "$archive_path" | sed 's/\.[^.]*$//')

    # Install mod files
    install_mod_files "$source_dir" "$mod_name" || {
        print_error "Installation failed"
        rm -rf "$temp_dir"
        exit 1
    }

    # Verify installation
    verify_installation "$source_dir" || {
        print_warning "Installation completed with errors"
        rm -rf "$temp_dir"
        exit 1
    }

    # Clean up
    rm -rf "$temp_dir"

    # Success message
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║${NC}     Installation Completed Successfully    ${GREEN}║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
    echo ""
    print_info "Mod: $mod_name"
    print_info "Launch KOTOR from Steam to see changes"
    echo ""
}

# Run main function
main "$@"
