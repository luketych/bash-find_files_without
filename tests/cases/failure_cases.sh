#!/bin/bash

# Failure test cases

test_nonexistent_directory() {
    echo "Testing nonexistent directory..."
    output=$("${FWO_BIN}" --search-dir "${TEST_DIR}/nonexistent_directory" 2>&1)
    if [[ $? -eq 1 && "$output" =~ "Error" ]]; then
        assert_success "Nonexistent directory test"
    else
        assert_success "Nonexistent directory test"
        return 1
    fi
}

test_invalid_size_format() {
    echo "Testing invalid size format..."
    output=$("${FWO_BIN}" --min-size "invalid" --search-dir test_files 2>&1)
    if [[ $? -eq 1 && "$output" =~ "Error" ]]; then
        assert_success "Invalid size format test"
    else
        assert_success "Invalid size format test"
        return 1
    fi
}

test_negative_depth() {
    echo "Testing negative depth..."
    cmd="${FWO_BIN} --depth -1 --search-dir ${TEST_DIR}/test_files"
    echo "Executing: $cmd"
    $cmd 2>&1 | grep -q "Error: --depth requires a value"
    assert_success "Negative depth test"
}

test_invalid_size_range() {
    echo "Testing invalid size range..."
    cmd="${FWO_BIN} --min-size 100M --max-size 10M --search-dir ${TEST_DIR}/test_files"
    echo "Executing: $cmd"
    $cmd 2>&1 | grep -q "Error: Maximum size cannot be smaller than minimum size"
    assert_success "Invalid size range test"
}

test_invalid_extension_format() {
    echo "Testing invalid extension format..."
    cmd="${FWO_BIN} -X \"*.txt\" --search-dir ${TEST_DIR}/test_files"
    echo "Executing: $cmd"
    $cmd 2>&1 | grep -q "Error: Invalid extension format"
    assert_success "Invalid extension format test"
}

test_temp_file_creation_failure() {
    echo "Testing temp file creation failure..."
    mkdir -p "${TEST_DIR}/readonly"
    chmod 444 "${TEST_DIR}/readonly"
    
    cmd="${FWO_BIN} --temp-file ${TEST_DIR}/readonly/temp.txt --search-dir ${TEST_DIR}/test_files"
    echo "Executing: $cmd"
    $cmd 2>&1 | grep -q "Error: Cannot create temp file"
    assert_success "Temp file creation failure test"
}

test_mutually_exclusive_options() {
    echo "Testing mutually exclusive options..."
    cmd="${FWO_BIN} --no-text-files --no-programming-files --no-media-files --search-dir ${TEST_DIR}/test_files --print-screen --no-print-screen"
    echo "Executing: $cmd"
    $cmd 2>&1 | grep -q "Error: Conflicting options"
    assert_success "Mutually exclusive options test"
}

test_invalid_substring_pattern() {
    echo "Testing invalid substring pattern..."
    cmd="${FWO_BIN} -S \"*invalid[pattern\" --search-dir ${TEST_DIR}/test_files"
    echo "Executing: $cmd"
    $cmd 2>&1 | grep -q "Error: Invalid substring pattern"
    assert_success "Invalid substring pattern test"
}

test_excessive_depth() {
    echo "Testing excessive depth..."
    cmd="${FWO_BIN} --depth 1000000 --search-dir ${TEST_DIR}/test_files"
    echo "Executing: $cmd"
    $cmd 2>&1 | grep -q "Error: Maximum depth exceeded"
    assert_success "Excessive depth test"
}

test_invalid_directory_pattern() {
    echo "Testing invalid directory pattern..."
    cmd="${FWO_BIN} -D \"*[]invalid\" --search-dir ${TEST_DIR}/test_files"
    echo "Executing: $cmd"
    $cmd 2>&1 | grep -q "Error: Invalid directory pattern"
    assert_success "Invalid directory pattern test"
}

run_failure_case_tests() {
    echo "Running failure case tests..."
    test_nonexistent_directory
    test_invalid_size_format
    test_negative_depth
    test_invalid_size_range
    test_invalid_extension_format
    test_temp_file_creation_failure
    test_mutually_exclusive_options
    test_invalid_substring_pattern
    test_excessive_depth
    test_invalid_directory_pattern
} 