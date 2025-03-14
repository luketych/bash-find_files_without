#!/bin/bash

# Content filtering test cases

test_substring_filtering() {
    echo "Testing substring filtering..."
<<<<<<< HEAD
    "${SCRIPT_BIN}" -S "TEMP,backup" --search-dir $(dirname "$0")/test_files < /dev/null
=======
    "${FWO_BIN}" -S "TEMP,backup" --search-dir $(dirname "$0")/test_files < /dev/null
>>>>>>> 1ad8a2e71b00bcb5bea29f490d19ba19ef4a955c
    assert_success "Substring filtering"
}

run_content_filtering_tests() {
    echo "Running content filtering tests..."
    test_substring_filtering
} 