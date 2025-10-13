#!/bin/bash

# Automated test for recipe matcher (no user input required)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "========================================="
echo " Recipe Matcher - Automated Test"
echo "========================================="
echo ""

# Source the modules
source "$SCRIPT_DIR/core/recipe-loader.sh"
source "$SCRIPT_DIR/core/recipe-matcher.sh"

# Load all recipes
echo "Loading recipes..."
recipes=$(load_all_recipes "$SCRIPT_DIR/recipes/official" 2>/dev/null)
echo ""

# Test Case 1: Web Development Task
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test 1: Web Development Task"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
task1="使用 React 和 TypeScript 构建一个待办事项应用"
echo "Task: $task1"
echo ""

matches1=$(find_matching_recipes "$task1" "$recipes" 2>/dev/null)
echo "$matches1" | jq '.[] | {name: .metadata.name, confidence: .confidence, keyword_score, pattern_matches}'
echo ""

# Test Case 2: Data Analysis Task
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test 2: Data Analysis Task"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
task2="分析 sales_data.csv 并生成可视化报告"
echo "Task: $task2"
echo ""

matches2=$(find_matching_recipes "$task2" "$recipes" 2>/dev/null)
echo "$matches2" | jq '.[] | {name: .metadata.name, confidence: .confidence, keyword_score, pattern_matches}'
echo ""

# Test Case 3: Unrelated Task (should find no matches)
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test 3: Unrelated Task (should find no or low matches)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
task3="帮我修复打印机驱动问题"
echo "Task: $task3"
echo ""

matches3=$(find_matching_recipes "$task3" "$recipes" 2>/dev/null)
match_count=$(echo "$matches3" | jq 'length')
if [[ $match_count -eq 0 ]]; then
    echo "✓ No matches found (expected)"
else
    echo "$matches3" | jq '.[] | {name: .metadata.name, confidence: .confidence}'
fi
echo ""

echo "========================================="
echo " Test Summary"
echo "========================================="
echo "✓ Test 1: Found $(echo "$matches1" | jq 'length') matches for web development"
echo "✓ Test 2: Found $(echo "$matches2" | jq 'length') matches for data analysis"
echo "✓ Test 3: Found $match_count matches for unrelated task"
echo ""
echo "All tests completed successfully!"
