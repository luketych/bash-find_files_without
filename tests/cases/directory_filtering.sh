#!/bin/bash

# Directory filtering test cases

test_directory_filtering() {
    echo "Testing directory filtering..."
    ../fwo -D "node_modules" --search-dir test_files < /dev/null
    assert_success "Directory filtering"
}

test_deep_search() {
    echo "Testing deep directory searching..."
    ../fwo --depth 5 --search-dir test_files < /dev/null
    assert_success "Deep search"
}

run_directory_filtering_tests() {
    echo "Running directory filtering tests..."
    test_directory_filtering
    test_deep_search
} 