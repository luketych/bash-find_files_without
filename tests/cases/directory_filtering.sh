#!/bin/bash

# Directory filtering test cases

test_directory_filtering() {
    echo "Testing directory filtering..."
<<<<<<< HEAD
    "${SCRIPT_BIN}" -D "node_modules" --search-dir $(dirname "$0")/test_files < /dev/null
=======
    "${FWO_BIN}" -D "node_modules" --search-dir $(dirname "$0")/test_files < /dev/null
>>>>>>> 1ad8a2e71b00bcb5bea29f490d19ba19ef4a955c
    assert_success "Directory filtering"
}

test_deep_search() {
    echo "Testing deep directory searching..."
<<<<<<< HEAD
    "${SCRIPT_BIN}" --depth 5 --search-dir $(dirname "$0")/test_files < /dev/null
=======
    "${FWO_BIN}" --depth 5 --search-dir $(dirname "$0")/test_files < /dev/null
>>>>>>> 1ad8a2e71b00bcb5bea29f490d19ba19ef4a955c
    assert_success "Deep search"
}

run_directory_filtering_tests() {
    echo "Running directory filtering tests..."
    test_directory_filtering
    test_deep_search
} 