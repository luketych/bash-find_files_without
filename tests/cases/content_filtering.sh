#!/bin/bash

# Content filtering test cases

test_substring_filtering() {
    echo "Testing substring filtering..."
    "${FWO_BIN}" -S "TEMP,backup" --search-dir test_files < /dev/null
    assert_success "Substring filtering"
}

run_content_filtering_tests() {
    echo "Running content filtering tests..."
    test_substring_filtering
} 