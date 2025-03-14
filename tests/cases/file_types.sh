#!/bin/bash

# File type filtering test cases

# The SCRIPT_BIN variable needs to be set before running these tests
# This should typically be done in the test setup or passed as an environment variable
# Example: export SCRIPT_BIN=/path/to/your/binary

test_media_filtering() {
    if [ -z "${SCRIPT_BIN}" ]; then
        echo "Error: SCRIPT_BIN environment variable is not set"
        return 1
    fi
    echo "Testing media file filtering..."
    "${SCRIPT_BIN}" --no-media-files --search-dir $(dirname "$0")/test_files < /dev/null
    assert_success "Media file filtering"
}

test_programming_filtering() {
    if [ -z "${SCRIPT_BIN}" ]; then
        echo "Error: SCRIPT_BIN environment variable is not set"
        return 1
    fi
    echo "Testing programming file filtering..."
    "${SCRIPT_BIN}" --no-programming-files --search-dir $(dirname "$0")/test_files < /dev/null
    assert_success "Programming file filtering"
}

run_file_type_tests() {
    echo "Running file type tests..."
    test_media_filtering
    test_programming_filtering
}