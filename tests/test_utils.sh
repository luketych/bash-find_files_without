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
    
    # Clean up any existing test files
    cleanup_test_environment
    
    # Create test directory structure
    mkdir -p "${TEST_DIR}/test_files"/{text,images,code,media,docs,node_modules/some-package}
    mkdir -p "${TEST_DIR}/test_files/level1/level2/level3/level4/level5"
    
    # Create test files with different sizes
    dd if=/dev/zero of="${TEST_DIR}/test_files/small.bin" bs=1K count=1 2>/dev/null
    dd if=/dev/zero of="${TEST_DIR}/test_files/medium.bin" bs=1M count=1 2>/dev/null
    dd if=/dev/zero of="${TEST_DIR}/test_files/large.bin" bs=10M count=1 2>/dev/null

    # Create readonly directory in test_files
    mkdir -p "${TEST_DIR}/test_files/readonly"
    chmod 444 "${TEST_DIR}/test_files/readonly"
    
    create_test_files
    
    # Ensure all test files are readable
    chmod -R a+r "${TEST_DIR}/test_files"
}

# Create various test files
create_test_files() {
    # Text files
    echo "Hello" > "${TEST_DIR}/test_files/text/test.txt"
    echo "Config" > "${TEST_DIR}/test_files/text/config.yml"
    echo "Documentation" > "${TEST_DIR}/test_files/text/README.md"
    
    # Files with specific substrings
    echo "TEMP_file_to_ignore" > "${TEST_DIR}/test_files/temp_123.txt"
    echo "backup_file" > "${TEST_DIR}/test_files/backup_data.txt"
    echo "test_file" > "${TEST_DIR}/test_files/test_file.txt"
    
    # Media files
    touch "${TEST_DIR}/test_files/images/test.jpg"
    touch "${TEST_DIR}/test_files/images/test.png"
    touch "${TEST_DIR}/test_files/media/video.mp4"
    touch "${TEST_DIR}/test_files/media/audio.mp3"
    
    # Programming files
    echo "print('hello')" > "${TEST_DIR}/test_files/code/test.py"
    echo "console.log('hi');" > "${TEST_DIR}/test_files/code/script.js"
    echo "package main" > "${TEST_DIR}/test_files/code/main.go"
    echo "<?php echo 'test'; ?>" > "${TEST_DIR}/test_files/code/test.php"
    
    # Deep nested files
    touch "${TEST_DIR}/test_files/level1/level2/level3/level4/level5/deep_file.txt"
    touch "${TEST_DIR}/test_files/level1/level2/level3/level4/level5/deep_file2.txt"
    
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
    
    # Create files for extension testing
    touch "${TEST_DIR}/test_files/test.txt"
    touch "${TEST_DIR}/test_files/test.md"
    touch "${TEST_DIR}/test_files/test.js"
    touch "${TEST_DIR}/test_files/test.py"
    touch "${TEST_DIR}/test_files/test.jpg"
    touch "${TEST_DIR}/test_files/test.png"
    
    # Create files for directory filtering
    touch "${TEST_DIR}/test_files/node_modules/test.js"
    touch "${TEST_DIR}/test_files/node_modules/some-package/index.js"
}

# Cleanup test environment
cleanup_test_environment() {
    # Remove test files and directories
    # First ensure we can remove read-only directories
    if [ -d "${TEST_DIR}/test_files/readonly" ]; then
        chmod -R 755 "${TEST_DIR}/test_files/readonly" 2>/dev/null
    fi
    rm -rf "${TEST_DIR}/test_files" 2>/dev/null
    rm -rf "${TEST_DIR}/other_test_dir" 2>/dev/null
    
    # Ensure cleanup was successful
    if [ -d "${TEST_DIR}/test_files" ]; then
        echo "Warning: Failed to clean up test files directory"
        return 1
    fi
    return 0
}

# Test result helper functions
assert_success() {
    local exit_code=$?
    if [ $exit_code -eq 0 ]; then
        echo -e "${GREEN}✓ $1 passed${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗ $1 failed (exit code: $exit_code)${NC}"
        ((TESTS_FAILED++))
        return 1
    fi
}

assert_failure() {
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        echo -e "${GREEN}✓ $1 passed${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗ $1 failed (exit code: $exit_code)${NC}"
        ((TESTS_FAILED++))
        return 1
    fi
} 