#!/bin/bash

# Failure test cases

test_nonexistent_directory() {
    echo "Testing nonexistent directory..."
    "${FWO_BIN}" --search-dir "${BATS_TEST_TMPDIR}/nonexistent_directory" 2>&1 | grep -q "Error: Directory .* does not exist"
    assert_success "Nonexistent directory test"
}

test_invalid_size_format() {
    echo "Testing invalid size format..."
    "${FWO_BIN}" --min-size "invalid" --search-dir "${BATS_TEST_TMPDIR}/test_files" 2>&1 | grep -q "Error: Invalid size format"
    assert_success "Invalid size format test"
}

test_negative_depth() {
    echo "Testing negative depth..."
    "${FWO_BIN}" --depth -1 --search-dir "${BATS_TEST_TMPDIR}/test_files" 2>&1 | grep -q "Error: Depth must be a positive number"
    assert_success "Negative depth test"
}

test_invalid_size_range() {
    echo "Testing invalid size range..."
    "${FWO_BIN}" --min-size 100M --max-size 10M --search-dir "${BATS_TEST_TMPDIR}/test_files" 2>&1 | grep -q "Error: Maximum size cannot be smaller than minimum size"
    assert_success "Invalid size range test"
}

test_invalid_extension_format() {
    echo "Testing invalid extension format..."
    "${FWO_BIN}" -X "*.txt" --search-dir "${BATS_TEST_TMPDIR}/test_files" 2>&1 | grep -q "Error: Invalid extension format"
    assert_success "Invalid extension format test"
}

test_temp_file_creation_failure() {
    echo "Testing temp file creation failure..."
    mkdir -p "${BATS_TEST_TMPDIR}/readonly"
    chmod 444 "${BATS_TEST_TMPDIR}/readonly"
    
    "${FWO_BIN}" --temp-file "${BATS_TEST_TMPDIR}/readonly/temp.txt" --search-dir "${BATS_TEST_TMPDIR}/test_files" 2>&1 | grep -q "Error: Cannot create temp file"
    assert_success "Temp file creation failure test"
}

test_mutually_exclusive_options() {
    echo "Testing mutually exclusive options..."
    "${FWO_BIN}" --no-text-files --no-programming-files --no-media-files --search-dir "${BATS_TEST_TMPDIR}/test_files" --print-screen --no-print-screen 2>&1 | grep -q "Error: Conflicting options"
    assert_success "Mutually exclusive options test"
}

test_invalid_substring_pattern() {
    echo "Testing invalid substring pattern..."
    "${FWO_BIN}" -S "*invalid[pattern" --search-dir "${BATS_TEST_TMPDIR}/test_files" 2>&1 | grep -q "Error: Invalid substring pattern"
    assert_success "Invalid substring pattern test"
}

test_excessive_depth() {
    echo "Testing excessive depth..."
    "${FWO_BIN}" --depth 1000000 --search-dir "${BATS_TEST_TMPDIR}/test_files" 2>&1 | grep -q "Error: Maximum depth exceeded"
    assert_success "Excessive depth test"
}

test_invalid_directory_pattern() {
    echo "Testing invalid directory pattern..."
    "${FWO_BIN}" -D "*[]invalid" --search-dir "${BATS_TEST_TMPDIR}/test_files" 2>&1 | grep -q "Error: Invalid directory pattern"
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