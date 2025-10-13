#!/bin/bash

# Recipe Optimizer
# Merges similar Recipes, archives unused ones, and maintains Recipe quality
# Analyzes Recipe collection and performs optimization operations

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# ============================================================================
# Helper Functions
# ============================================================================

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# ============================================================================
# Recipe Loading
# ============================================================================

# Load all Recipe YAML files from a directory
load_all_recipes() {
    local recipe_dir="$1"

    if [[ ! -d "$recipe_dir" ]]; then
        echo "[]"
        return 0
    fi

    local recipes="[]"

    # Find all YAML files
    while IFS= read -r recipe_file; do
        if [[ -f "$recipe_file" ]]; then
            # Extract key fields
            local name=$(grep -A 10 "^metadata:" "$recipe_file" | grep "name:" | cut -d'"' -f2 | head -1)
            local category=$(grep -A 10 "^metadata:" "$recipe_file" | grep "category:" | cut -d'"' -f2 | head -1)
            local version=$(grep -A 10 "^metadata:" "$recipe_file" | grep "version:" | cut -d'"' -f2 | head -1)

            # Extract keywords
            local keywords=$(awk '/^triggers:/,/^[a-z_]+:/ {if (/- "/) print}' "$recipe_file" | grep -o '"[^"]*"' | tr -d '"' | jq -R . | jq -s '.')

            # Extract stats
            local stats=$(awk '/^stats:/,/^[a-z_]+:/ {print}' "$recipe_file" | grep -E "^\s+(usage_count|success_rate|avg_satisfaction):" || echo "")
            local usage_count=$(echo "$stats" | grep "usage_count:" | sed 's/.*: *//' | head -1)
            local success_rate=$(echo "$stats" | grep "success_rate:" | sed 's/.*: *//' | head -1)
            local avg_satisfaction=$(echo "$stats" | grep "avg_satisfaction:" | sed 's/.*: *//' | head -1)

            # Default values
            usage_count=${usage_count:-0}
            success_rate=${success_rate:-null}
            avg_satisfaction=${avg_satisfaction:-null}

            # Build JSON object
            local recipe_json=$(jq -n \
                --arg file "$recipe_file" \
                --arg name "$name" \
                --arg category "$category" \
                --arg version "$version" \
                --argjson keywords "$keywords" \
                --argjson usage "$usage_count" \
                --arg success "$success_rate" \
                --arg satisfaction "$avg_satisfaction" \
                '{
                    file_path: $file,
                    name: $name,
                    category: $category,
                    version: $version,
                    keywords: $keywords,
                    stats: {
                        usage_count: $usage,
                        success_rate: $success,
                        avg_satisfaction: $satisfaction
                    }
                }')

            recipes=$(echo "$recipes" | jq --argjson recipe "$recipe_json" '. + [$recipe]')
        fi
    done < <(find "$recipe_dir" -name "*.yaml" -o -name "*.yml" 2>/dev/null)

    echo "$recipes"
}

# ============================================================================
# Similarity Analysis
# ============================================================================

# Calculate similarity score between two Recipes (0.0 - 1.0)
calculate_similarity() {
    local recipe1="$1"
    local recipe2="$2"

    # Extract keywords
    local keywords1=$(echo "$recipe1" | jq -c '.keywords')
    local keywords2=$(echo "$recipe2" | jq -c '.keywords')

    # Calculate Jaccard similarity for keywords
    local similarity=$(echo "$keywords1" "$keywords2" | jq -s '
        .[0] as $k1 | .[1] as $k2 |
        ($k1 + $k2 | unique) as $union |
        ($k1 | map(select(. as $x | $k2 | index($x)))) as $intersection |
        if ($union | length) > 0
        then (($intersection | length) / ($union | length))
        else 0
        end
    ')

    # Check category match (boost if same)
    local cat1=$(echo "$recipe1" | jq -r '.category // "general"')
    local cat2=$(echo "$recipe2" | jq -r '.category // "general"')
    local category_boost=0
    if [[ "$cat1" == "$cat2" ]]; then
        category_boost=0.2
    fi

    # Calculate final similarity score
    awk "BEGIN {printf \"%.3f\", $similarity + $category_boost}"
}

# Find groups of similar Recipes
find_similar_recipes() {
    local recipes="$1"
    local similarity_threshold="${2:-0.6}"  # Default 60% similarity

    local count=$(echo "$recipes" | jq 'length')
    local groups="[]"

    # Compare each pair of recipes
    for ((i=0; i<count; i++)); do
        local recipe1=$(echo "$recipes" | jq ".[$i]")
        local file1=$(echo "$recipe1" | jq -r '.file_path')

        # Check if already in a group
        local in_group=$(echo "$groups" | jq --arg file "$file1" 'map(select(.members | map(.file_path) | index($file))) | length > 0')
        if [[ "$in_group" == "true" ]]; then
            continue
        fi

        # Start a new group
        local group_members="[$recipe1]"

        # Find similar recipes
        for ((j=i+1; j<count; j++)); do
            local recipe2=$(echo "$recipes" | jq ".[$j]")
            local file2=$(echo "$recipe2" | jq -r '.file_path')

            # Check if already in a group
            local in_group2=$(echo "$groups" | jq --arg file "$file2" 'map(select(.members | map(.file_path) | index($file))) | length > 0')
            if [[ "$in_group2" == "true" ]]; then
                continue
            fi

            # Calculate similarity
            local similarity=$(calculate_similarity "$recipe1" "$recipe2")
            local is_similar=$(awk "BEGIN {print ($similarity >= $similarity_threshold) ? \"true\" : \"false\"}")

            if [[ "$is_similar" == "true" ]]; then
                group_members=$(echo "$group_members" | jq --argjson r "$recipe2" '. + [$r]')
            fi
        done

        # Add group if it has more than one member
        local group_size=$(echo "$group_members" | jq 'length')
        if [[ "$group_size" -gt 1 ]]; then
            local group=$(jq -n --argjson members "$group_members" \
                --argjson threshold "$similarity_threshold" \
                '{
                    members: $members,
                    size: ($members | length),
                    similarity_threshold: $threshold
                }')
            groups=$(echo "$groups" | jq --argjson g "$group" '. + [$g]')
        fi
    done

    echo "$groups"
}

# ============================================================================
# Recipe Merging
# ============================================================================

# Merge a group of similar Recipes into one
merge_recipe_group() {
    local group="$1"
    local output_dir="$2"

    local members=$(echo "$group" | jq -c '.members')
    local member_count=$(echo "$members" | jq 'length')

    # Select primary Recipe (highest usage count)
    local primary=$(echo "$members" | jq 'sort_by(-.stats.usage_count) | .[0]')
    local primary_name=$(echo "$primary" | jq -r '.name')
    local primary_file=$(echo "$primary" | jq -r '.file_path')

    print_info "Merging $member_count Recipes into: $primary_name" >&2

    # Collect all keywords from all recipes
    local all_keywords=$(echo "$members" | jq '[.[].keywords] | flatten | unique')

    # Sum usage counts
    local total_usage=$(echo "$members" | jq '[.[].stats.usage_count] | add')

    # Calculate weighted average for success_rate and satisfaction
    local avg_success=$(echo "$members" | jq '
        [.[] | select(.stats.success_rate != null and .stats.success_rate != "null")
        | {usage: .stats.usage_count, rate: (.stats.success_rate | tonumber)}]
        | if length > 0
          then (map(.usage * .rate) | add) / (map(.usage) | add)
          else null
          end
    ')

    local avg_satisfaction=$(echo "$members" | jq '
        [.[] | select(.stats.avg_satisfaction != null and .stats.avg_satisfaction != "null")
        | {usage: .stats.usage_count, sat: (.stats.avg_satisfaction | tonumber)}]
        | if length > 0
          then (map(.usage * .sat) | add) / (map(.usage) | add)
          else null
          end
    ')

    # Return merge information
    jq -n \
        --arg primary_file "$primary_file" \
        --arg primary_name "$primary_name" \
        --argjson members "$members" \
        --argjson keywords "$all_keywords" \
        --argjson usage "$total_usage" \
        --argjson success "$avg_success" \
        --argjson satisfaction "$avg_satisfaction" \
        '{
            action: "merge",
            primary_recipe: $primary_file,
            primary_name: $primary_name,
            merged_recipes: ($members | map(.file_path)),
            merged_count: ($members | length),
            updated_keywords: $keywords,
            updated_stats: {
                total_usage: $usage,
                avg_success_rate: $success,
                avg_satisfaction: $satisfaction
            }
        }'
}

# ============================================================================
# Recipe Archiving
# ============================================================================

# Identify Recipes that should be archived
find_recipes_to_archive() {
    local recipes="$1"
    local min_usage="${2:-5}"         # Archive if usage < 5
    local min_success_rate="${3:-0.5}" # Archive if success_rate < 50%
    local age_days="${4:-90}"          # Archive if unused for 90 days

    echo "$recipes" | jq --argjson min_usage "$min_usage" \
        --argjson min_success "$min_success_rate" \
        '[.[] | select(
            .stats.usage_count < $min_usage or
            (.stats.success_rate != null and
             .stats.success_rate != "null" and
             (.stats.success_rate | tonumber) < $min_success)
        )]'
}

# ============================================================================
# Optimization Operations
# ============================================================================

# Optimize Recipe collection
optimize_recipes() {
    local recipe_dir="${1:-$PROJECT_ROOT/recipes}"
    local output_dir="${2:-$PROJECT_ROOT/recipes/optimized}"
    local archive_dir="${3:-$PROJECT_ROOT/recipes/archived}"
    local similarity_threshold="${4:-0.65}"

    print_info "Loading Recipes from: $recipe_dir" >&2

    # Load all recipes
    local recipes=$(load_all_recipes "$recipe_dir")
    local recipe_count=$(echo "$recipes" | jq 'length')

    if [[ "$recipe_count" -eq 0 ]]; then
        print_warning "No Recipes found in: $recipe_dir" >&2
        echo '{"merged": [], "archived": [], "stats": {"total": 0, "merged": 0, "archived": 0}}'
        return 0
    fi

    print_info "Found $recipe_count Recipes" >&2

    # Find similar recipes
    print_info "Analyzing similarity (threshold=$similarity_threshold)..." >&2
    local similar_groups=$(find_similar_recipes "$recipes" "$similarity_threshold")
    local group_count=$(echo "$similar_groups" | jq 'length')

    print_info "Found $group_count groups of similar Recipes" >&2

    # Merge similar recipes
    local merged_recipes="[]"
    if [[ "$group_count" -gt 0 ]]; then
        for ((i=0; i<group_count; i++)); do
            local group=$(echo "$similar_groups" | jq ".[$i]")
            local merge_result=$(merge_recipe_group "$group" "$output_dir")
            merged_recipes=$(echo "$merged_recipes" | jq --argjson m "$merge_result" '. + [$m]')
        done
    fi

    # Find recipes to archive
    print_info "Identifying Recipes to archive..." >&2
    local to_archive=$(find_recipes_to_archive "$recipes" 5 0.5 90)
    local archive_count=$(echo "$to_archive" | jq 'length')

    print_info "Found $archive_count Recipes to archive" >&2

    # Archive recipes
    local archived_recipes="[]"
    if [[ "$archive_count" -gt 0 ]]; then
        mkdir -p "$archive_dir"
        for ((i=0; i<archive_count; i++)); do
            local recipe=$(echo "$to_archive" | jq ".[$i]")
            local file_path=$(echo "$recipe" | jq -r '.file_path')
            local name=$(echo "$recipe" | jq -r '.name')

            archived_recipes=$(echo "$archived_recipes" | jq --arg file "$file_path" --arg name "$name" \
                '. + [{file_path: $file, name: $name, action: "archive"}]')
        done
    fi

    # Return optimization report
    jq -n \
        --argjson merged "$merged_recipes" \
        --argjson archived "$archived_recipes" \
        --argjson total "$recipe_count" \
        --argjson merge_count "$group_count" \
        --argjson archive_count "$archive_count" \
        '{
            merged: $merged,
            archived: $archived,
            stats: {
                total_recipes: $total,
                groups_merged: $merge_count,
                recipes_archived: $archive_count,
                recipes_remaining: ($total - $archive_count)
            }
        }'
}

# ============================================================================
# Statistics
# ============================================================================

# Get Recipe collection statistics
get_recipe_stats() {
    local recipe_dir="${1:-$PROJECT_ROOT/recipes}"

    local recipes=$(load_all_recipes "$recipe_dir")
    local total=$(echo "$recipes" | jq 'length')

    if [[ "$total" -eq 0 ]]; then
        echo '{"total": 0, "by_category": {}, "total_usage": 0, "avg_success_rate": null}'
        return 0
    fi

    # Group by category
    local by_category=$(echo "$recipes" | jq 'group_by(.category // "general") | map({(.[0].category // "general"): length}) | add // {}')

    # Calculate totals
    local total_usage=$(echo "$recipes" | jq '[.[].stats.usage_count] | add')
    local avg_success=$(echo "$recipes" | jq '
        [.[] | select(.stats.success_rate != null and .stats.success_rate != "null")
        | (.stats.success_rate | tonumber)]
        | if length > 0 then (add / length) else null end
    ')

    jq -n \
        --argjson total "$total" \
        --argjson by_cat "$by_category" \
        --argjson usage "$total_usage" \
        --argjson success "$avg_success" \
        '{
            total_recipes: $total,
            by_category: $by_cat,
            total_usage: $usage,
            avg_success_rate: $success
        }'
}

# ============================================================================
# Test Mode
# ============================================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    print_info "Recipe Optimizer - Test Mode"
    echo ""

    # Check if recipes directory exists
    RECIPE_DIR="$PROJECT_ROOT/recipes"
    if [[ ! -d "$RECIPE_DIR" ]]; then
        print_error "Recipes directory not found: $RECIPE_DIR"
        exit 1
    fi

    # Show statistics
    print_info "📊 Recipe Collection Statistics:"
    stats=$(get_recipe_stats "$RECIPE_DIR")
    echo "$stats" | jq '.'
    echo ""

    # Run optimization
    print_info "🔧 Running optimization..."
    echo ""
    result=$(optimize_recipes "$RECIPE_DIR/official" "$RECIPE_DIR/optimized" "$RECIPE_DIR/archived" 0.65)
    echo ""

    # Show results
    print_success "✨ Optimization Results:"
    echo "$result" | jq '.'
    echo ""

    merged_count=$(echo "$result" | jq '.stats.groups_merged')
    archived_count=$(echo "$result" | jq '.stats.recipes_archived')

    if [[ "$merged_count" -gt 0 ]]; then
        print_info "Merged $merged_count groups of similar Recipes"
    else
        print_info "No similar Recipes found to merge"
    fi

    if [[ "$archived_count" -gt 0 ]]; then
        print_info "Archived $archived_count underperforming Recipes"
    else
        print_info "No Recipes need archiving"
    fi

    echo ""
    print_success "Recipe Optimizer test complete!"
fi
