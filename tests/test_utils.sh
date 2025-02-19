#!/bin/bash

# Utility functions for tests

# Setup test environment
setup_test_environment() {
    mkdir -p test_files/{text,images,code,media,docs}
    mkdir -p test_files/node_modules/some-package
    mkdir -p test_files/level1/level2/level3/level4/level5
    
    # Create test files with different sizes
    dd if=/dev/zero of=test_files/small.bin bs=1K count=1 2>/dev/null
    dd if=/dev/zero of=test_files/medium.bin bs=1M count=1 2>/dev/null
    dd if=/dev/zero of=test_files/large.bin bs=10M count=1 2>/dev/null
    
    create_test_files
}

# Create various test files
create_test_files() {
    # Text files
    echo "Hello" > test_files/text/test.txt
    echo "Config" > test_files/text/config.yml
    
    # Files with specific substrings
    echo "TEMP_file_to_ignore" > test_files/temp_123.txt
    echo "backup_file" > test_files/backup_data.txt
    
    # Media files
    touch test_files/images/test.jpg
    touch test_files/images/test.png
    touch test_files/media/video.mp4
    touch test_files/media/audio.mp3
    
    # Programming files
    echo "print('hello')" > test_files/code/test.py
    echo "console.log('hi');" > test_files/code/script.js
    echo "package main" > test_files/code/main.go
    
    # Deep nested files
    touch test_files/level1/level2/level3/level4/level5/deep_file.txt
    
    # Miscellaneous files
    touch test_files/random.xyz
    echo "custom" > test_files/custom.data
}

# Cleanup test environment
cleanup_test_environment() {
    rm -rf test_files other_test_dir
}

# Test result helper functions
assert_success() {
    if [ $? -eq 0 ]; then
        echo "✓ $1 passed"
        return 0
    else
        echo "✗ $1 failed"
        return 1
    fi
} 