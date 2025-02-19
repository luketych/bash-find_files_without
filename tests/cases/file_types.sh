#!/bin/bash

# File type filtering test cases

# The FWO_BIN variable needs to be set before running these tests
# This should typically be done in the test setup or passed as an environment variable
# Example: export FWO_BIN=/path/to/your/binary

test_media_filtering() {
    if [ -z "${FWO_BIN}" ]; then
        echo "Error: FWO_BIN environment variable is not set"
        return 1
    fi
    echo "Testing media file filtering..."
    "${FWO_BIN}" --no-media-files --search-dir test_files < /dev/null
    assert_success "Media file filtering"
}

test_programming_filtering() {
    if [ -z "${FWO_BIN}" ]; then
        echo "Error: FWO_BIN environment variable is not set"
        return 1
    fi
    echo "Testing programming file filtering..."
    "${FWO_BIN}" --no-programming-files --search-dir test_files < /dev/null
    assert_success "Programming file filtering"
}

run_file_type_tests() {
    echo "Running file type tests..."
    test_media_filtering
    test_programming_filtering
}