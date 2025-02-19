#!/bin/bash

# File type filtering test cases

test_media_filtering() {
    echo "Testing media file filtering..."
    ../fwo --no-media-files --search-dir test_files < /dev/null
    assert_success "Media file filtering"
}

test_programming_filtering() {
    echo "Testing programming file filtering..."
    ../fwo --no-programming-files --search-dir test_files < /dev/null
    assert_success "Programming file filtering"
}

run_file_type_tests() {
    echo "Running file type tests..."
    test_media_filtering
    test_programming_filtering
} 