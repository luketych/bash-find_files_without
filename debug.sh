#!/usr/bin/env bash

# Debug script for find_files_without
# This script helps test and debug the find_files_without functionality

# Source the main script
file="$(dirname "${BASH_SOURCE[0]}")/find_files_without.sh"
source "$file"

# Test cases with descriptive names
test_basic_extension_filter() {
    echo "🧪 Testing basic extension filter (Python and JavaScript files)..."
    find_files_without --extensions="py|js" --verbose=true
}

test_image_files() {
    echo "🧪 Testing image files filter..."
    find_files_without filter_out_image_files=true verbose=true
}

test_directory_filter() {
    echo "🧪 Testing directory filter (src and lib)..."
    find_files_without directories="src|lib" verbose=true
}

test_substring_filter() {
    echo "🧪 Testing substring filter (test and spec)..."
    find_files_without substrings="test|spec" verbose=true
}

test_combined_filters() {
    echo "🧪 Testing combined filters (programming files in src with 'controller')..."
    find_files_without filter_out_programming_files=true directories="src" substrings="controller" verbose=true
}

test_size_filters() {
    echo "🧪 Testing size filters (files between 1K and 1M)..."
    find_files_without min_size="1K" max_size="1M" verbose=true
}

test_type_filters() {
    echo "🧪 Testing type filters (directories only)..."
    find_files_without type="d" verbose=true long=true
}

test_format_options() {
    echo "🧪 Testing format options (long format with ANSI colors)..."
    find_files_without filter_out_programming_files=true long=true ansi=true verbose=true
}

# Debug function to run specific test
debug_test() {
    local test_name=$1
    echo "🔍 Debugging test: $test_name"
    
    # Enable debugging
    set -x
    
    # Run the specified test
    case $test_name in
        "extension") test_basic_extension_filter ;;
        "image") test_image_files ;;
        "directory") test_directory_filter ;;
        "substring") test_substring_filter ;;
        "combined") test_combined_filters ;;
        "size") test_size_filters ;;
        "type") test_type_filters ;;
        "format") test_format_options ;;
        *) echo "❌ Unknown test: $test_name" ;;
    esac
    
    # Disable debugging
    set +x
}

# Function to run all tests
run_all_tests() {
    echo "🧪 Running all tests..."
    test_basic_extension_filter
    test_image_files
    test_directory_filter
    test_substring_filter
    test_combined_filters
    test_size_filters
    test_type_filters
    test_format_options
}

# Show usage if no arguments provided
usage() {
    echo "Usage: $0 [test_name]"
    echo "Available tests:"
    echo "  extension  - Test basic extension filtering"
    echo "  image     - Test image files filtering"
    echo "  directory - Test directory filtering"
    echo "  substring - Test substring filtering"
    echo "  combined  - Test combined filters"
    echo "  size      - Test size filters"
    echo "  type      - Test type filters"
    echo "  format    - Test format options"
    echo "  all       - Run all tests"
    echo
    echo "Example: $0 extension"
}

# Main execution
if [ $# -eq 0 ]; then
    usage
    exit 1
fi

case $1 in
    "all") run_all_tests ;;
    *) debug_test "$1" ;;
esac 