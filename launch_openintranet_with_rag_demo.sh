#!/bin/bash

#------------------------------------------------------------------------------
# Configuration
#------------------------------------------------------------------------------
# Generate unique project name with timestamp (DDEV hostname compatible)
TIMESTAMP=$(date +%s)
APP_NAME="openintranet-${TIMESTAMP}"
REPO_URL="https://git.drupalcode.org/project/openintranet.git"



#------------------------------------------------------------------------------
# Functions
#------------------------------------------------------------------------------

# ANSI Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Show welcome header
show_header() {
    clear
    echo ""
    echo -e "${CYAN}${BOLD}"
    echo "  ██████╗ ██████╗ ███████╗███╗   ██╗"
    echo " ██╔═══██╗██╔══██╗██╔════╝████╗  ██║"
    echo " ██║   ██║██████╔╝█████╗  ██╔██╗ ██║"
    echo " ██║   ██║██╔═══╝ ██╔══╝  ██║╚██╗██║"
    echo " ╚██████╔╝██║     ███████╗██║ ╚████║"
    echo "  ╚═════╝ ╚═╝     ╚══════╝╚═╝  ╚═══╝"
    echo ""
    echo " ██╗███╗   ██╗████████╗██████╗  █████╗ ███╗   ██╗███████╗████████╗"
    echo " ██║████╗  ██║╚══██╔══╝██╔══██╗██╔══██╗████╗  ██║██╔════╝╚══██╔══╝"
    echo " ██║██╔██╗ ██║   ██║   ██████╔╝███████║██╔██╗ ██║█████╗     ██║"
    echo " ██║██║╚██╗██║   ██║   ██╔══██╗██╔══██║██║╚██╗██║██╔══╝     ██║"
    echo " ██║██║ ╚████║   ██║   ██║  ██║██║  ██║██║ ╚████║███████╗   ██║"
    echo " ╚═╝╚═╝  ╚═══╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝"
    echo -e "${NC}"
    echo -e "${BLUE}                    POWERED BY DRUPAL${NC}"
    echo ""
    echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}    Your intranet. Your data. Your rules.${NC}"
    echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "  Enterprise intranet you actually own. Self-hosted on your"
    echo -e "  infrastructure. Full source code access. Zero per-user costs."
    echo ""
    echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}Demo: Connecting Open Intranet with Milvus Vector Database for AI-powered RAG${NC}"
    echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${MAGENTA}${BOLD}Built with ❤️  by Droptica${NC}"
    echo ""
    echo -e "${YELLOW}Solid Open Source solutions for ambitious companies${NC}"
    echo ""
    echo -e "${BOLD}What we do:${NC}"
    echo ""
    echo -e "  ${BOLD}Create:${NC}    Open Intranet, Droopler CMS, Druscan"
    echo -e "  ${BOLD}AI Development:${NC} AI chatbots (RAG), autonomous agents, OpenAI/Claude integrations, custom AI models, CMS content automation & translation, workflow automation"
    echo -e "  ${BOLD}Customize:${NC} Drupal, Mautic, Sylius, Symfony"
    echo -e "  ${BOLD}Support & maintain:${NC} Security, updates, training, monitoring 24/7"
    echo ""
    echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}Trusted by: Corporations • SMEs • Startups • Universities • Government${NC}"
    echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# usage:
# log INFO "message"
# log ERROR "message"
# Output: [14:23:45] [INFO] Moja wiadomość
log() {
    echo "[$(date '+%H:%M:%S')] [$1] ${@:2}"
}



# Check if DDEV is installed
check_ddev() {
    if ! command -v ddev &> /dev/null; then
        echo ""
        echo -e "${RED}${BOLD}⚠ DDEV is not installed!${NC}"
        echo ""
        echo -e "DDEV is required to run this demo. Please install it first:"
        echo ""
        echo -e "${CYAN}${BOLD}Installation:${NC}"
        echo -e "  📖 Documentation: ${BLUE}https://ddev.readthedocs.io/en/stable/users/install/${NC}"
        echo ""
        echo -e "${YELLOW}Quick install options:${NC}"
        echo -e "  • macOS:   ${GREEN}brew install ddev/ddev/ddev${NC}"
        echo -e "  • Linux:   Use package manager or binary install"
        echo -e "  • Windows: Use WSL2 + package manager"
        echo ""
        echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        exit 1
    fi

    log "INFO" "DDEV found: $(ddev --version)"
}

# Download latest Milvus docker-compose configuration
download_milvus_config() {
    local workspace_root
    workspace_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local repo_dir="${workspace_root}/openintranet_source_code/openintranet"
    local ddev_dir="${repo_dir}/.ddev"
    local target_file="${ddev_dir}/docker-compose.milvus.yaml"
    local source_url="https://git.drupalcode.org/project/ai_vdb_provider_milvus/-/raw/2.0.x/docs/docker-compose-examples/ddev-example.docker-compose.milvus.yaml"

    echo ""
    echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}Step: Milvus Docker Compose Configuration${NC}"
    echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    # Check if repository exists
    if [ ! -d "$repo_dir" ]; then
        echo ""
        log "ERROR" "Repository not found at: $repo_dir"
        log "ERROR" "Please run setup_openintranet_repo first"
        exit 1
    fi

    # Create .ddev directory if it doesn't exist
    if [ ! -d "$ddev_dir" ]; then
        log "INFO" "Creating .ddev directory..."
        mkdir -p "$ddev_dir"
    fi

    echo ""
    log "INFO" "Downloading latest Milvus docker-compose configuration..."
    log "INFO" "Source: $source_url"
    log "INFO" "Target: $target_file"
    echo ""

    # Download the file
    if curl -f -s -S -o "$target_file" "$source_url"; then
        log "INFO" "✓ Configuration downloaded successfully"
        echo ""
        log "INFO" "File details:"
        ls -lh "$target_file" | awk '{print "  Size: " $5 ", Modified: " $6 " " $7 " " $8}'
    else
        echo ""
        echo -e "${RED}${BOLD}✗ Failed to download Milvus configuration!${NC}"
        echo -e "${YELLOW}Please check your internet connection and try again.${NC}"
        exit 1
    fi

    echo ""
}

# Clone or manage Open Intranet repository
setup_openintranet_repo() {
    local workspace_root
    workspace_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local repo_dir="${workspace_root}/openintranet_source_code/openintranet"

    echo ""
    echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}Step: Open Intranet Repository${NC}"
    echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    if [ -d "$repo_dir" ]; then
        echo ""
        log "INFO" "Repository already exists at: $repo_dir"
        echo ""
        echo -e "${YELLOW}Do you want to delete the existing repository and clone fresh?${NC}"
        echo -e "${YELLOW}This will remove all local changes!${NC}"
        echo ""
        read -p "Delete and re-clone? (y/n): " -n 1 -r
        echo ""

        if [[ $REPLY =~ ^[Yy]$ ]]; then
            log "INFO" "Removing existing repository..."

            # Try to delete DDEV project first (may not exist)
            if [ -f "$repo_dir/.ddev/config.yaml" ]; then
                log "INFO" "Attempting to delete DDEV project..."
                (cd "$repo_dir" && ddev delete -O -y) 2>/dev/null || log "WARN" "DDEV project not found or already deleted"
            fi

            # Remove directory
            log "INFO" "Removing directory: $repo_dir"
            rm -rf "$repo_dir"

            # Clone fresh
            log "INFO" "Cloning repository from: $REPO_URL"
            git clone "$REPO_URL" "$repo_dir"

            if [ $? -eq 0 ]; then
                log "INFO" "Repository cloned successfully"
            else
                echo ""
                echo -e "${RED}${BOLD}✗ Failed to clone repository!${NC}"
                exit 1
            fi
        else
            echo ""
            log "INFO" "Keeping existing repository. Exiting..."
            exit 0
        fi
    else
        log "INFO" "Cloning repository from: $REPO_URL"
        log "INFO" "Target directory: $repo_dir"
        echo ""

        git clone "$REPO_URL" "$repo_dir"

        if [ $? -eq 0 ]; then
            log "INFO" "Repository cloned successfully"
        else
            echo ""
            echo -e "${RED}${BOLD}✗ Failed to clone repository!${NC}"
            exit 1
        fi
    fi

    echo ""
}

# Configure DDEV for the project
configure_ddev() {
    local workspace_root
    workspace_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local repo_dir="${workspace_root}/openintranet_source_code/openintranet"

    echo ""
    echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}Step: DDEV Configuration${NC}"
    echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    if [ -d "$repo_dir/.ddev" ] && [ -f "$repo_dir/.ddev/config.yaml" ]; then
        echo ""
        log "INFO" "DDEV already configured"
        log "INFO" "Project name: $(grep 'name:' $repo_dir/.ddev/config.yaml | awk '{print $2}')"
    else
        echo ""
        log "INFO" "Configuring DDEV project..."

        # Generate unique project name
        NAME=$(basename "$repo_dir" | tr '_' '-')
        declare -i n=$(ddev list | grep --count "$NAME" || echo 0)
        if [ $n -gt 0 ]; then
            NAME=$NAME-$(expr $n + 1)
        fi

        log "INFO" "Project name: $NAME"
        log "INFO" "Project type: drupal10"
        log "INFO" "PHP version: 8.3"
        echo ""

        (cd "$repo_dir" && ddev config --project-type=drupal10 --docroot=web --php-version=8.3 --ddev-version-constraint=">=1.24.0" --project-name="$NAME")

        if [ $? -eq 0 ]; then
            log "INFO" "✓ DDEV configured successfully"
        else
            echo ""
            echo -e "${RED}${BOLD}✗ Failed to configure DDEV!${NC}"
            exit 1
        fi
    fi

    echo ""
}

# Start DDEV containers
start_ddev() {
    local workspace_root
    workspace_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local repo_dir="${workspace_root}/openintranet_source_code/openintranet"

    echo ""
    echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}Step: Starting DDEV${NC}"
    echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    echo ""
    log "INFO" "Starting DDEV containers (this may take a few minutes)..."
    echo ""

    (cd "$repo_dir" && ddev start)

    if [ $? -eq 0 ]; then
        echo ""
        log "INFO" "✓ DDEV started successfully"
    else
        echo ""
        echo -e "${RED}${BOLD}✗ Failed to start DDEV!${NC}"
        exit 1
    fi

    echo ""
}

# Install Composer dependencies
install_composer_dependencies() {
    local workspace_root
    workspace_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local repo_dir="${workspace_root}/openintranet_source_code/openintranet"

    echo ""
    echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}Step: Composer Dependencies${NC}"
    echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    if [ -f "$repo_dir/composer.lock" ]; then
        echo ""
        log "INFO" "Dependencies already installed (composer.lock found)"
    else
        echo ""
        log "INFO" "Installing Composer dependencies (this may take several minutes)..."
        echo ""

        (cd "$repo_dir" && ddev composer install)

        if [ $? -eq 0 ]; then
            echo ""
            log "INFO" "✓ Composer dependencies installed successfully"
        else
            echo ""
            echo -e "${RED}${BOLD}✗ Failed to install Composer dependencies!${NC}"
            exit 1
        fi
    fi

    echo ""
}

# Copy DDEV commands to the project
copy_ddev_commands() {
    local workspace_root
    workspace_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local repo_dir="${workspace_root}/openintranet_source_code/openintranet"

    echo ""
    echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}Step: DDEV Custom Commands${NC}"
    echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    if [ ! -d "$repo_dir/ddev_commands" ]; then
        echo ""
        log "WARN" "ddev_commands directory not found, skipping..."
    else
        echo ""
        log "INFO" "Copying DDEV custom commands..."

        cp -r "$repo_dir/ddev_commands/"* "$repo_dir/.ddev/commands/"

        if [ $? -eq 0 ]; then
            log "INFO" "✓ DDEV commands copied successfully"
            log "INFO" "Commands available: $(ls -1 $repo_dir/.ddev/commands/ | tr '\n' ', ' | sed 's/,$//')"
        else
            echo ""
            echo -e "${YELLOW}${BOLD}⚠ Warning: Failed to copy DDEV commands${NC}"
        fi
    fi

    echo ""
}

# Copy starter theme to the project
copy_starter_theme() {
    local workspace_root
    workspace_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local repo_dir="${workspace_root}/openintranet_source_code/openintranet"

    echo ""
    echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}Step: Starter Theme${NC}"
    echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    if [ ! -d "$repo_dir/starter-theme" ]; then
        echo ""
        log "WARN" "starter-theme directory not found, skipping..."
    else
        echo ""
        log "INFO" "Copying starter theme to web/themes/custom/..."

        mkdir -p "$repo_dir/web/themes/custom/"
        cp -r "$repo_dir/starter-theme/" "$repo_dir/web/themes/custom/"

        if [ $? -eq 0 ]; then
            log "INFO" "✓ Starter theme copied successfully"
        else
            echo ""
            echo -e "${YELLOW}${BOLD}⚠ Warning: Failed to copy starter theme${NC}"
        fi
    fi

    echo ""
}

# Install required Drupal modules
install_drupal_modules() {
    local workspace_root
    workspace_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local repo_dir="${workspace_root}/openintranet_source_code/openintranet"

    echo ""
    echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}Step: Additional Drupal Modules${NC}"
    echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    # Check if module is already installed
    if grep -q "drupal/ai_vdb_provider_milvus" "$repo_dir/composer.json" 2>/dev/null; then
        echo ""
        log "INFO" "Milvus VDB Provider module already required in composer.json"

        # Show current version
        CURRENT_VERSION=$(grep "drupal/ai_vdb_provider_milvus" "$repo_dir/composer.json" | awk -F'"' '{print $4}')
        log "INFO" "Current version: $CURRENT_VERSION"
    else
        echo ""
        log "INFO" "Adding Milvus VDB Provider module..."
        log "INFO" "Package: drupal/ai_vdb_provider_milvus:1.1.x-dev"
        log "INFO" "Source: https://www.drupal.org/project/ai_vdb_provider_milvus"
        log "INFO" "Note: Using dev version for latest bug fixes (including #3523510)"
        echo ""

        (cd "$repo_dir" && ddev composer require 'drupal/ai_vdb_provider_milvus:1.1.x-dev')

        if [ $? -eq 0 ]; then
            echo ""
            log "INFO" "✓ Milvus VDB Provider module added successfully"
        else
            echo ""
            echo -e "${RED}${BOLD}✗ Failed to add Milvus VDB Provider module!${NC}"
            exit 1
        fi
    fi

    echo ""
}

# Apply all patches for AI and Milvus modules
# Fixes:
# 1. drupal/ai: isMultiple() crashes on computed fields (node_grants, role_access)
# 2. drupal/ai_vdb_provider_milvus: Access control filtering with array_contains()
# 3. drupal/ai_vdb_provider_milvus: Enable dynamic fields to store access metadata
apply_module_patches() {
    local workspace_root
    workspace_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local repo_dir="${workspace_root}/openintranet_source_code/openintranet"

    echo ""
    echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}Step: Apply Module Patches${NC}"
    echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    # Check if patches are already configured
    if grep -q "fix-isMultiple-null-datasource.patch" "$repo_dir/composer.json" 2>/dev/null && \
       grep -q "fix-access-control-list-fields.patch" "$repo_dir/composer.json" 2>/dev/null; then
        echo ""
        log "INFO" "All patches already configured in composer.json"
        echo ""
        return 0
    fi

    echo ""
    log "INFO" "Applying patches for Search API access control with Milvus..."
    log "INFO" "Patches:"
    log "INFO" "  - drupal/ai: Fix isMultiple() for computed fields"
    log "INFO" "  - drupal/ai_vdb_provider_milvus: Use array_contains() for list fields"
    log "INFO" "  - drupal/ai_vdb_provider_milvus: Enable dynamic fields for access metadata"
    echo ""

    # Copy all patch files
    local ai_patch_source="${workspace_root}/patches/ai"
    local ai_patch_target="${repo_dir}/patches/ai"
    local milvus_patch_source="${workspace_root}/patches/ai_vdb_provider_milvus"
    local milvus_patch_target="${repo_dir}/patches/ai_vdb_provider_milvus"

    mkdir -p "$ai_patch_target" "$milvus_patch_target"

    if [ -d "$ai_patch_source" ]; then
        cp "$ai_patch_source"/*.patch "$ai_patch_target/" 2>/dev/null
        log "INFO" "✓ AI module patches copied"
    fi

    if [ -d "$milvus_patch_source" ]; then
        cp "$milvus_patch_source"/*.patch "$milvus_patch_target/" 2>/dev/null
        log "INFO" "✓ Milvus provider patches copied"
    fi

    # Configure all patches in composer.json
    echo ""
    log "INFO" "Configuring patches in composer.json..."

    (cd "$repo_dir" && ddev exec php -r "
        \$composerJson = json_decode(file_get_contents('composer.json'), true);

        // Ensure extra.patches section exists
        if (!isset(\$composerJson['extra'])) {
            \$composerJson['extra'] = [];
        }
        if (!isset(\$composerJson['extra']['patches'])) {
            \$composerJson['extra']['patches'] = [];
        }

        // Add patches for drupal/ai
        \$composerJson['extra']['patches']['drupal/ai'] = [
            'Fix isMultiple() null datasource for computed fields' => 'patches/ai/fix-isMultiple-null-datasource.patch'
        ];

        // Add patches for drupal/ai_vdb_provider_milvus
        \$composerJson['extra']['patches']['drupal/ai_vdb_provider_milvus'] = [
            'Fix access control filtering with array_contains for list fields' => 'patches/ai_vdb_provider_milvus/fix-access-control-list-fields.patch',
            'Enable dynamic fields in Milvus to store access metadata' => 'patches/ai_vdb_provider_milvus/enable-dynamic-fields.patch'
        ];

        // Write back
        file_put_contents('composer.json', json_encode(\$composerJson, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES) . PHP_EOL);
        echo 'All patches configured';
    ")

    if [ $? -ne 0 ]; then
        echo ""
        echo -e "${YELLOW}${BOLD}⚠ Warning: Failed to configure patches${NC}"
        return 1
    fi

    log "INFO" "✓ Patches configured in composer.json"

    # Apply patches via composer install
    echo ""
    log "INFO" "Applying patches via composer install..."
    echo ""

    (cd "$repo_dir" && ddev composer install)

    if [ $? -eq 0 ]; then
        echo ""
        log "INFO" "✓ All patches applied successfully"
    else
        echo ""
        echo -e "${YELLOW}${BOLD}⚠ Warning: Some patches may not have been applied correctly${NC}"
    fi

    echo ""
}

# Copy Milvus RAG recipe to project
copy_milvus_rag_recipe() {
    local workspace_root
    workspace_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local repo_dir="${workspace_root}/openintranet_source_code/openintranet"
    local recipe_source="${workspace_root}/recipes/openintranet_milvus_rag"
    local recipe_target="${repo_dir}/recipes/openintranet_milvus_rag"

    echo ""
    echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}Step: Milvus RAG Recipe${NC}"
    echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    if [ ! -d "$recipe_source" ]; then
        echo ""
        log "ERROR" "Milvus RAG recipe not found at: $recipe_source"
        exit 1
    fi

    if [ ! -d "$repo_dir" ]; then
        echo ""
        log "ERROR" "Repository not found at: $repo_dir"
        exit 1
    fi

    echo ""
    log "INFO" "Copying Milvus RAG recipe to project..."
    log "INFO" "Source: $recipe_source"
    log "INFO" "Target: $recipe_target"

    # Remove existing recipe if present
    if [ -d "$recipe_target" ]; then
        rm -rf "$recipe_target"
    fi

    # Create recipes directory if it doesn't exist
    mkdir -p "${repo_dir}/recipes"

    # Copy recipe
    cp -r "$recipe_source" "$recipe_target"

    if [ $? -eq 0 ]; then
        log "INFO" "✓ Milvus RAG recipe copied successfully"
    else
        echo ""
        echo -e "${RED}${BOLD}✗ Failed to copy Milvus RAG recipe!${NC}"
        exit 1
    fi

    echo ""
}

# Prepare Drupal directories for installation
prepare_drupal_directories() {
    local workspace_root
    workspace_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local repo_dir="${workspace_root}/openintranet_source_code/openintranet"

    echo ""
    echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}Step: Prepare Drupal Directories${NC}"
    echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    echo ""
    log "INFO" "Creating required directories for Drupal installation..."
    echo ""

    # Make sure sites/default is writable (needed for Open Intranet profile)
    (cd "$repo_dir" && ddev exec chmod u+w /var/www/html/web/sites/default)

    if [ $? -eq 0 ]; then
        log "INFO" "✓ Set proper permissions for sites/default"
    else
        echo ""
        echo -e "${YELLOW}${BOLD}⚠ Warning: Failed to set permissions${NC}"
    fi

    echo ""
}

# Prompt for OpenAI API Key
prompt_for_openai_key() {
    echo ""
    echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}Step: OpenAI API Key Configuration${NC}"
    echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    echo ""
    echo -e "${YELLOW}${BOLD}OpenAI API Key Required${NC}"
    echo ""
    echo -e "This demo requires an OpenAI API key to generate embeddings."
    echo -e "The key will be securely stored in Drupal's Key module."
    echo ""
    echo -e "${CYAN}How to get your OpenAI API key:${NC}"
    echo -e "  1. Visit: ${BLUE}https://platform.openai.com/api-keys${NC}"
    echo -e "  2. Log in or create an account"
    echo -e "  3. Click ${BOLD}'Create new secret key'${NC}"
    echo -e "  4. Copy the key (starts with ${GREEN}sk-proj-${NC} or ${GREEN}sk-${NC})"
    echo ""
    echo -e "${MAGENTA}${BOLD}Note:${NC} You'll need billing enabled on your OpenAI account."
    echo -e "      Typical cost for this demo: ~\$0.01-0.10"
    echo ""
    echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    # Prompt for API key
    while true; do
        echo -e "${BOLD}Please paste your OpenAI API key:${NC}"
        echo -n "> "
        read -r OPENAI_API_KEY

        # Trim whitespace
        OPENAI_API_KEY=$(echo "$OPENAI_API_KEY" | xargs)

        # Validate format
        if [[ -z "$OPENAI_API_KEY" ]]; then
            echo ""
            echo -e "${RED}Error: API key cannot be empty${NC}"
            echo ""
            continue
        fi

        if [[ ! "$OPENAI_API_KEY" =~ ^sk- ]]; then
            echo ""
            echo -e "${RED}Error: Invalid API key format${NC}"
            echo -e "${YELLOW}OpenAI API keys should start with 'sk-' or 'sk-proj-'${NC}"
            echo ""
            read -p "Try again? (y/n): " -n 1 -r
            echo ""
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                echo ""
                echo -e "${RED}${BOLD}Installation cannot continue without a valid API key${NC}"
                exit 1
            fi
            echo ""
            continue
        fi

        # Show confirmation (with masked key)
        MASKED_KEY="${OPENAI_API_KEY:0:10}...${OPENAI_API_KEY: -4}"
        echo ""
        echo -e "${GREEN}✓ API key accepted: ${MASKED_KEY}${NC}"
        echo ""

        # Ask for confirmation
        read -p "Is this correct? (y/n): " -n 1 -r
        echo ""

        if [[ $REPLY =~ ^[Yy]$ ]]; then
            break
        else
            echo ""
        fi
    done

    # Export for later use
    export OPENAI_API_KEY

    echo ""
    log "INFO" "✓ OpenAI API key configured"
    echo ""
}

# Install and configure Drupal
install_and_configure_drupal() {
    local workspace_root
    workspace_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local repo_dir="${workspace_root}/openintranet_source_code/openintranet"

    echo ""
    echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}Step: Drupal Installation & Configuration${NC}"
    echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    # 1. Install Drupal WITHOUT demo content first
    # This allows Open Intranet profile to configure private files properly
    echo ""
    log "INFO" "Installing Open Intranet (without demo content)..."
    echo ""

    (cd "$repo_dir" && ddev drush site-install openintranet -y)

    if [ $? -eq 0 ]; then
        echo ""
        log "INFO" "✓ Open Intranet installed successfully"
    else
        echo ""
        echo -e "${RED}${BOLD}✗ Failed to install Open Intranet!${NC}"
        exit 1
    fi

    # 1.5. Apply demo content recipe separately
    # This ensures private files are already configured when importing demo content
    echo ""
    log "INFO" "Installing demo content..."
    echo ""

    (cd "$repo_dir" && ddev drush recipe /var/www/html/recipes/default_content)

    if [ $? -eq 0 ]; then
        echo ""
        log "INFO" "✓ Demo content installed successfully"
    else
        echo ""
        echo -e "${YELLOW}${BOLD}⚠ Warning: Failed to install demo content${NC}"
        log "INFO" "You can install it later with: ddev drush recipe /var/www/html/recipes/default_content"
    fi

    # 2. Apply Milvus RAG recipe
    echo ""
    log "INFO" "Applying Milvus RAG recipe..."
    echo ""

    (cd "$repo_dir" && ddev drush recipe /var/www/html/recipes/openintranet_milvus_rag)

    if [ $? -eq 0 ]; then
        echo ""
        log "INFO" "✓ Milvus RAG recipe applied successfully"
    else
        echo ""
        echo -e "${YELLOW}${BOLD}⚠ Warning: Failed to apply Milvus RAG recipe${NC}"
    fi

    # 2.5. Prompt for OpenAI API Key (NOW - after Drupal & recipe installed)
    # This allows us to use ddev drush to save the key directly to Drupal
    prompt_for_openai_key

    # 2.6. Save OpenAI API Key to Drupal Key module
    echo ""
    log "INFO" "Saving OpenAI API key to Drupal Key module..."
    echo ""

    # Save the actual API key value to Key module
    (cd "$repo_dir" && ddev drush config:set key.key.openai_api_key key_provider_settings.key_value "$OPENAI_API_KEY" -y)

    if [ $? -eq 0 ]; then
        log "INFO" "✓ API key saved to Key module"
    else
        echo ""
        echo -e "${RED}${BOLD}✗ Failed to save API key to Key module${NC}"
        exit 1
    fi

    # 2.7. Connect Key module to AI Provider (CRITICAL!)
    echo ""
    log "INFO" "Connecting Key module to AI Provider..."
    echo ""

    (cd "$repo_dir" && ddev drush config:set ai_provider_openai.settings api_key openai_api_key -y)

    if [ $? -eq 0 ]; then
        log "INFO" "✓ API key connected successfully"
    else
        echo ""
        echo -e "${YELLOW}${BOLD}⚠ Warning: Failed to connect API key${NC}"
    fi

    # 3. Clear cache
    echo ""
    log "INFO" "Clearing Drupal cache..."
    echo ""

    (cd "$repo_dir" && ddev drush cr)

    if [ $? -eq 0 ]; then
        echo ""
        log "INFO" "✓ Cache cleared successfully"
    else
        echo ""
        echo -e "${YELLOW}${BOLD}⚠ Warning: Failed to clear cache${NC}"
    fi

    # 4. Index Knowledge Base content to Milvus
    echo ""
    log "INFO" "Indexing Knowledge Base content to Milvus..."
    echo ""

    (cd "$repo_dir" && ddev drush search-api:index knowledge_base_content)

    if [ $? -eq 0 ]; then
        echo ""
        log "INFO" "✓ Content indexed successfully"

        # Show indexing status
        echo ""
        log "INFO" "Search API indexing status:"
        echo ""
        (cd "$repo_dir" && ddev drush search-api:status)
    else
        echo ""
        echo -e "${YELLOW}${BOLD}⚠ Warning: Failed to index content${NC}"
        log "INFO" "You can index it later with: ddev drush search-api:index knowledge_base_content"
    fi

    echo ""
}

# Get DDEV base URL (without port)
get_ddev_base_url() {
    local workspace_root
    workspace_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local repo_dir="${workspace_root}/openintranet_source_code/openintranet"
    local config_file="${repo_dir}/.ddev/config.yaml"

    if [ -f "$config_file" ]; then
        # Extract project name from config.yaml
        local project_name=$(grep '^name:' "$config_file" | awk '{print $2}' | tr -d '"' | tr -d "'")
        if [ -n "$project_name" ]; then
            echo "https://${project_name}.ddev.site"
            return 0
        fi
    fi

    # Fallback: try to get from ddev describe
    local ddev_url=$(cd "$repo_dir" && ddev describe --json-output 2>/dev/null | grep -o '"https://[^"]*\.ddev\.site"' | head -1 | tr -d '"')
    if [ -n "$ddev_url" ]; then
        echo "$ddev_url"
        return 0
    fi

    # Final fallback
    echo "http://localhost"
    return 1
}

# Get DDEV hostname for Attu UI URL
get_ddev_hostname() {
    local workspace_root
    workspace_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local repo_dir="${workspace_root}/openintranet_source_code/openintranet"
    local config_file="${repo_dir}/.ddev/config.yaml"

    if [ -f "$config_file" ]; then
        # Extract project name from config.yaml
        local project_name=$(grep '^name:' "$config_file" | awk '{print $2}' | tr -d '"' | tr -d "'")
        if [ -n "$project_name" ]; then
            echo "https://${project_name}.ddev.site:8521"
            return 0
        fi
    fi

    # Fallback: try to get from ddev describe
    local ddev_url=$(cd "$repo_dir" && ddev describe --json-output 2>/dev/null | grep -o '"https://[^"]*\.ddev\.site"' | head -1 | tr -d '"')
    if [ -n "$ddev_url" ]; then
        # Extract hostname and add port 8521
        local hostname=$(echo "$ddev_url" | sed 's|https://||' | sed 's|/.*||')
        echo "https://${hostname}:8521"
        return 0
    fi

    # Final fallback
    echo "http://localhost:8521"
    return 1
}

# Show project information
show_project_info() {
    local workspace_root
    workspace_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local repo_dir="${workspace_root}/openintranet_source_code/openintranet"

    echo ""
    echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}Project Information${NC}"
    echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    echo ""
    log "INFO" "Project configuration and services:"
    echo ""

    (cd "$repo_dir" && ddev describe)

    echo ""
}

#------------------------------------------------------------------------------
# Main
#------------------------------------------------------------------------------

# Show welcome header
show_header

# Check requirements
check_ddev

echo ""
echo -e "${GREEN}${BOLD}✓ All requirements met! Ready to proceed.${NC}"
echo ""

# Setup Open Intranet repository
setup_openintranet_repo

# Download Milvus configuration
download_milvus_config

# Configure DDEV
configure_ddev

# Start DDEV containers
start_ddev

# Install Composer dependencies
install_composer_dependencies

# Copy DDEV commands
copy_ddev_commands

# Copy starter theme
copy_starter_theme

# Install additional Drupal modules
install_drupal_modules

# Apply all module patches (AI + Milvus)
apply_module_patches

# Copy Milvus RAG recipe
copy_milvus_rag_recipe

# Prepare Drupal directories
prepare_drupal_directories

# Install and configure Drupal (includes OpenAI API key prompt)
install_and_configure_drupal

# Show project information
show_project_info

# Generate one-time login link (FINAL STEP)
workspace_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_dir="${workspace_root}/openintranet_source_code/openintranet"

# Get DDEV URLs
ATTU_URL=$(get_ddev_hostname)
DDEV_BASE_URL=$(get_ddev_base_url)
RAG_SEARCH_URL="${DDEV_BASE_URL}/search-rag-example"

echo ""
echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}🎉 Setup Completed Successfully!${NC}"
echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${GREEN}${BOLD}Your Open Intranet with Milvus RAG is ready!${NC}"
echo ""
echo -e "${YELLOW}${BOLD}Quick Access:${NC}"
echo ""
log "INFO" "Generating one-time admin login link..."
echo ""

(cd "$repo_dir" && ddev drush uli)

echo ""
echo -e "${CYAN}${BOLD}Next Steps:${NC}"
echo -e "  1. Click the login link above (or copy-paste to browser)"
echo -e "  2. Verify Milvus data at: ${BLUE}${ATTU_URL}${NC} (Attu UI)"
echo -e "  3. Check indexing: ${GREEN}cd ${repo_dir} && ddev drush search-api:status${NC}"
echo ""
echo -e "${CYAN}${BOLD}RAG Search Page:${NC}"
echo -e "  The Milvus RAG recipe has added a RAG search view to your Open Intranet."
echo -e "  You can access it at: ${BLUE}${RAG_SEARCH_URL}${NC}"
echo -e "  This page is also available in the main menu as 'RAG Search Example'."
echo ""
echo -e "${MAGENTA}${BOLD}Happy exploring! 🚀${NC}"
echo ""

# Return to workspace root
cd "${BASH_SOURCE%/*}" || cd "$(pwd)"
