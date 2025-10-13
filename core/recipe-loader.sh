#!/bin/bash

# Recipe Loader Module
# Loads and validates Recipe YAML files

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
_LOADER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RECIPE_DIR="${RECIPE_DIR:-$_LOADER_DIR/../recipes}"
YAML_CONVERTER="$_LOADER_DIR/yaml-to-json.py"

# Utility functions
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }

# Load single recipe
# Usage: load_recipe <recipe_file>
load_recipe() {
    local recipe_file="$1"

    if [[ ! -f "$recipe_file" ]]; then
        print_error "Recipe file not found: $recipe_file" >&2
        return 1
    fi

    local recipe_json=""

    # Try yq first
    if command -v yq &>/dev/null; then
        recipe_json=$(yq eval -o=json '.' "$recipe_file" 2>&1)
    # Fall back to Python
    elif command -v python3 &>/dev/null && [[ -f "$YAML_CONVERTER" ]]; then
        recipe_json=$(python3 "$YAML_CONVERTER" "$recipe_file" 2>&1)
    else
        print_error "No YAML parser available (need yq or Python with PyYAML)" >&2
        return 1
    fi

    # Add file path to JSON
    recipe_json=$(echo "$recipe_json" | jq --arg file "$recipe_file" '. + {file: $file}')

    echo "$recipe_json"
}

# Validate recipe structure
# Usage: validate_recipe <recipe_json>
validate_recipe() {
    local recipe="$1"

    # Check required fields
    local has_metadata=$(echo "$recipe" | jq 'has("metadata")')
    local has_triggers=$(echo "$recipe" | jq 'has("triggers")')
    local has_workflow=$(echo "$recipe" | jq 'has("workflow")')

    if [[ "$has_metadata" != "true" ]] || [[ "$has_triggers" != "true" ]] || [[ "$has_workflow" != "true" ]]; then
        return 1
    fi

    return 0
}

# Load all recipes from directory
# Usage: load_all_recipes [directory]
load_all_recipes() {
    local dir="${1:-$RECIPE_DIR}"

    if [[ ! -d "$dir" ]]; then
        print_error "Recipe directory not found: $dir" >&2
        return 1
    fi

    local recipes="[]"
    local count=0

    # Find all YAML files
    while IFS= read -r recipe_file; do
        [[ -z "$recipe_file" ]] && continue

        print_info "Loading: $(basename "$recipe_file")" >&2

        local recipe=$(load_recipe "$recipe_file")

        if validate_recipe "$recipe"; then
            recipes=$(echo "$recipes" | jq --argjson recipe "$recipe" '. += [$recipe]')
            ((count++))
            print_success "Valid: $(basename "$recipe_file")" >&2
        else
            print_warning "Invalid recipe: $(basename "$recipe_file")" >&2
        fi
    done < <(find "$dir" -type f \( -name "*.yaml" -o -name "*.yml" \))

    print_success "Loaded $count recipes" >&2
    echo "$recipes"
}

# Main entry point for testing
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo -e "${GREEN}"
    echo "╔════════════════════════════════════════╗"
    echo "║    Recipe Loader - Test Mode          ║"
    echo "╚════════════════════════════════════════╝"
    echo -e "${NC}"

    recipes=$(load_all_recipes "$RECIPE_DIR")
    count=$(echo "$recipes" | jq 'length')

    echo ""
    echo -e "${BLUE}Loaded $count recipes${NC}"
    echo "$recipes" | jq '.[] | {name: .metadata.name, version: .metadata.version, file: .file}'
fi
