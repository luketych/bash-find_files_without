#!/bin/bash

# File filtering test cases

test_file_sizes() {
    echo "Testing file size filtering..."
<<<<<<< HEAD
    echo "Running: ${SCRIPT_BIN} --min-size 500K --search-dir $(dirname "$0")/test_files < /dev/null"
    "${SCRIPT_BIN}" --min-size 500K --search-dir $(dirname "$0")/test_files < /dev/null
    assert_success "Min size filtering"
    
    echo "Running: ${SCRIPT_BIN} --max-size 5K --search-dir $(dirname "$0")/test_files < /dev/null"
    "${SCRIPT_BIN}" --max-size 5K --search-dir $(dirname "$0")/test_files < /dev/null
=======
    echo "Running: ${FWO_BIN} --min-size 500K --search-dir $(dirname "$0")/test_files < /dev/null"
    "${FWO_BIN}" --min-size 500K --search-dir $(dirname "$0")/test_files < /dev/null
    assert_success "Min size filtering"
    
    echo "Running: ${FWO_BIN} --max-size 5K --search-dir $(dirname "$0")/test_files < /dev/null"
    "${FWO_BIN}" --max-size 5K --search-dir $(dirname "$0")/test_files < /dev/null
>>>>>>> 1ad8a2e71b00bcb5bea29f490d19ba19ef4a955c
    assert_success "Max size filtering"
}

test_extension_filtering() {
    echo "Testing extension filtering..."
<<<<<<< HEAD
    "${SCRIPT_BIN}" -X "mp3,mp4,jpg" --search-dir $(dirname "$0")/test_files < /dev/null
=======
    "${FWO_BIN}" -X "mp3,mp4,jpg" --search-dir $(dirname "$0")/test_files < /dev/null
>>>>>>> 1ad8a2e71b00bcb5bea29f490d19ba19ef4a955c
    assert_success "Extension filtering"
}

run_file_filtering_tests() {
    echo "Running file filtering tests..."
    test_file_sizes
    test_extension_filtering
} 