#!/bin/bash

# Basic operations test cases

test_basic_find() {
    echo "Testing basic file finding..."
    local cmd="${SCRIPT_BIN} --no-text-files --no-image-files --search-dir $(dirname "$0")/test_files < /dev/null"
    echo "Running command: $cmd"
    eval "$cmd"
    assert_success "Basic find test"
}

test_search_directories() {
    echo "Testing different search directories..."
    mkdir -p other_test_dir
    touch other_test_dir/test_file.txt
    
    "${SCRIPT_BIN}" --search-dir other_test_dir < /dev/null
    assert_success "Search directory test"
}

run_basic_operations_tests() {
    echo "Running basic operations tests..."
    test_basic_find
    test_search_directories
} 