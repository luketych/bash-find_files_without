#!/bin/bash

# Basic test suite for fwo script

# Setup - Create test directory structure
setup() {
    mkdir -p test_files/{text,images,code,media,docs}
    mkdir -p test_files/node_modules/some-package
    mkdir -p test_files/level1/level2/level3/level4/level5
    
    # Create some test files
    echo "Hello" > test_files/text/test.txt
    echo "Config" > test_files/text/config.yml
    
    # Create files of different sizes
    dd if=/dev/zero of=test_files/small.bin bs=1K count=1 2>/dev/null
    dd if=/dev/zero of=test_files/medium.bin bs=1M count=1 2>/dev/null
    dd if=/dev/zero of=test_files/large.bin bs=10M count=1 2>/dev/null
    
    # Create files with specific substrings
    echo "TEMP_file_to_ignore" > test_files/temp_123.txt
    echo "backup_file" > test_files/backup_data.txt
    
    # Create files with various extensions
    touch test_files/images/test.jpg
    touch test_files/images/test.png
    touch test_files/media/video.mp4
    touch test_files/media/audio.mp3
    
    # Create programming files
    echo "print('hello')" > test_files/code/test.py
    echo "console.log('hi');" > test_files/code/script.js
    echo "package main" > test_files/code/main.go
    
    # Create deep nested files
    touch test_files/level1/level2/level3/level4/level5/deep_file.txt
    
    # Create some files we expect to find
    touch test_files/random.xyz
    echo "custom" > test_files/custom.data
}

# Cleanup test files
cleanup() {
    rm -rf test_files
}

# Test basic file finding
test_basic_find() {
    echo "Testing basic file finding..."
    ../fwo --no-text-files --no-image-files --search-dir test_files < /dev/null
    
    if [ $? -eq 0 ]; then
        echo "✓ Basic find test passed"
    else
        echo "✗ Basic find test failed"
        return 1
    fi
}

# Test file size filtering
test_file_sizes() {
    echo "Testing file size filtering..."
    
    # Test min size (should only find medium.bin and large.bin)
    ../fwo --min-size 500K --search-dir test_files < /dev/null
    if [ $? -eq 0 ]; then
        echo "✓ Min size test passed"
    else
        echo "✗ Min size test failed"
        return 1
    fi
    
    # Test max size (should only find small.bin)
    ../fwo --max-size 5K --search-dir test_files < /dev/null
    if [ $? -eq 0 ]; then
        echo "✓ Max size test passed"
    else
        echo "✗ Max size test failed"
        return 1
    fi
}

# Test deep directory searching
test_deep_search() {
    echo "Testing deep directory searching..."
    
    # Test with depth 5
    ../fwo --depth 5 --search-dir test_files < /dev/null
    if [ $? -eq 0 ]; then
        echo "✓ Deep search test passed"
    else
        echo "✗ Deep search test failed"
        return 1
    fi
}

# Test substring filtering
test_substring_filtering() {
    echo "Testing substring filtering..."
    
    # Filter out files containing "TEMP" and "backup"
    ../fwo -S "TEMP,backup" --search-dir test_files < /dev/null
    if [ $? -eq 0 ]; then
        echo "✓ Substring filtering test passed"
    else
        echo "✗ Substring filtering test failed"
        return 1
    fi
}

# Test extension filtering
test_extension_filtering() {
    echo "Testing extension filtering..."
    
    # Filter out specific extensions
    ../fwo -X "mp3,mp4,jpg" --search-dir test_files < /dev/null
    if [ $? -eq 0 ]; then
        echo "✓ Extension filtering test passed"
    else
        echo "✗ Extension filtering test failed"
        return 1
    fi
}

# Test directory filtering
test_directory_filtering() {
    echo "Testing directory filtering..."
    
    # Filter out node_modules directory
    ../fwo -D "node_modules" --search-dir test_files < /dev/null
    if [ $? -eq 0 ]; then
        echo "✓ Directory filtering test passed"
    else
        echo "✗ Directory filtering test failed"
        return 1
    fi
}

# Test media file filtering
test_media_filtering() {
    echo "Testing media file filtering..."
    
    # Test with media files disabled
    ../fwo --no-media-files --search-dir test_files < /dev/null
    if [ $? -eq 0 ]; then
        echo "✓ Media filtering test passed"
    else
        echo "✗ Media filtering test failed"
        return 1
    fi
}

# Test programming file filtering
test_programming_filtering() {
    echo "Testing programming file filtering..."
    
    # Test with programming files disabled
    ../fwo --no-programming-files --search-dir test_files < /dev/null
    if [ $? -eq 0 ]; then
        echo "✓ Programming file filtering test passed"
    else
        echo "✗ Programming file filtering test failed"
        return 1
    fi
}

# Test different search directories
test_search_directories() {
    echo "Testing different search directories..."
    
    # Create and test a different directory
    mkdir -p other_test_dir
    touch other_test_dir/test_file.txt
    
    ../fwo --search-dir other_test_dir < /dev/null
    local result=$?
    rm -rf other_test_dir
    
    if [ $result -eq 0 ]; then
        echo "✓ Search directory test passed"
    else
        echo "✗ Search directory test failed"
        return 1
    fi
}

# Run all tests
run_tests() {
    setup
    
    echo "Running fwo tests..."
    echo "===================="
    
    test_basic_find
    test_file_sizes
    test_deep_search
    test_substring_filtering
    test_extension_filtering
    test_directory_filtering
    test_media_filtering
    test_programming_filtering
    test_search_directories
    
    cleanup
    
    echo "===================="
    echo "Tests completed"
}

# Run the test suite
run_tests 