#!/bin/bash

# Utility functions for tests

# Make test counters available to all test files
export TESTS_PASSED=0
export TESTS_FAILED=0

# ANSI color codes
export GREEN='\033[0;32m'
export RED='\033[0;31m'
export NC='\033[0m' # No Color

# Set up test directory
export TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Setup test environment
setup_test_environment() {
    # Reset test counters at start
    TESTS_PASSED=0
    TESTS_FAILED=0
    
    # Create test directory structure
    mkdir -p "${TEST_DIR}/test_files"/{text,images,code,media,docs}
    mkdir -p "${TEST_DIR}/test_files/node_modules/some-package"
    mkdir -p "${TEST_DIR}/test_files/level1/level2/level3/level4/level5"
    
    # Create test files with different sizes
    dd if=/dev/zero of="${TEST_DIR}/test_files/small.bin" bs=1K count=1 2>/dev/null
    dd if=/dev/zero of="${TEST_DIR}/test_files/medium.bin" bs=1M count=1 2>/dev/null
    dd if=/dev/zero of="${TEST_DIR}/test_files/large.bin" bs=10M count=1 2>/dev/null

    # Create readonly directory in test_files
    mkdir -p "${TEST_DIR}/test_files/readonly"
    chmod 444 "${TEST_DIR}/test_files/readonly"
    
    create_test_files
}

# Create various test files
create_test_files() {
    # Text files
    echo "Hello" > "${TEST_DIR}/test_files/text/test.txt"
    echo "Config" > "${TEST_DIR}/test_files/text/config.yml"
    
    # Files with specific substrings
    echo "TEMP_file_to_ignore" > "${TEST_DIR}/test_files/temp_123.txt"
    echo "backup_file" > "${TEST_DIR}/test_files/backup_data.txt"
    
    # Media files
    touch "${TEST_DIR}/test_files/images/test.jpg"
    touch "${TEST_DIR}/test_files/images/test.png"
    touch "${TEST_DIR}/test_files/media/video.mp4"
    touch "${TEST_DIR}/test_files/media/audio.mp3"
    
    # Programming files
    echo "print('hello')" > "${TEST_DIR}/test_files/code/test.py"
    echo "console.log('hi');" > "${TEST_DIR}/test_files/code/script.js"
    echo "package main" > "${TEST_DIR}/test_files/code/main.go"
    
    # Deep nested files
    touch "${TEST_DIR}/test_files/level1/level2/level3/level4/level5/deep_file.txt"
    
    # Miscellaneous files
    touch "${TEST_DIR}/test_files/random.xyz"
    echo "custom" > "${TEST_DIR}/test_files/custom.data"
    
    # Create directory for separator tests
    mkdir -p "${TEST_DIR}/test_files/newline_test"
    mkdir -p "${TEST_DIR}/test_files/null_test"
    mkdir -p "${TEST_DIR}/test_files/mixed_test"
    
    # Create files with spaces (using quotes)
    touch "${TEST_DIR}/test_files/null_test/file with spaces.txt"
    touch "${TEST_DIR}/test_files/null_test/special*char?file.txt"
    
    # Create files with newlines (using quotes)
    touch "${TEST_DIR}/test_files/newline_test/file with newline.txt"
    touch "${TEST_DIR}/test_files/newline_test/another file.txt"
    
    # Create mixed test files
    touch "${TEST_DIR}/test_files/mixed_test/file with mixed.txt"
    touch "${TEST_DIR}/test_files/mixed_test/spaces and chars.txt"
}

# Cleanup test environment
cleanup_test_environment() {
    rm -rf "${TEST_DIR}/test_files" other_test_dir
}

# Test result helper functions
assert_success() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ $1 passed${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗ $1 failed${NC}"
        ((TESTS_FAILED++))
        return 1
    fi
} 