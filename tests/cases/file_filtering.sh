#!/bin/bash

# File filtering test cases

test_file_sizes() {
    echo "Testing file size filtering..."
    
    ../fwo --min-size 500K --search-dir test_files < /dev/null
    assert_success "Min size filtering"
    
    ../fwo --max-size 5K --search-dir test_files < /dev/null
    assert_success "Max size filtering"
}

test_extension_filtering() {
    echo "Testing extension filtering..."
    ../fwo -X "mp3,mp4,jpg" --search-dir test_files < /dev/null
    assert_success "Extension filtering"
}

run_file_filtering_tests() {
    echo "Running file filtering tests..."
    test_file_sizes
    test_extension_filtering
} 