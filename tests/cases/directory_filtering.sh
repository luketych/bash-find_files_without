#!/bin/bash

# Directory filtering test cases

test_directory_filtering() {
    echo "Testing directory filtering..."
    "${SCRIPT_BIN}" -D "node_modules" --search-dir $(dirname "$0")/test_files < /dev/null
    assert_success "Directory filtering"
}

test_deep_search() {
    echo "Testing deep directory searching..."
    "${SCRIPT_BIN}" --depth 5 --search-dir $(dirname "$0")/test_files < /dev/null
    assert_success "Deep search"
}

run_directory_filtering_tests() {
    echo "Running directory filtering tests..."
    test_directory_filtering
    test_deep_search
} 