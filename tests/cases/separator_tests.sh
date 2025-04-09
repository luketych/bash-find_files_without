#!/bin/bash

# Tests for different separator handling

test_newline_separator() {
    [[ "$VERBOSE" == "true" ]] && echo "Testing newline separator handling..."
    
    # Test with default handling (should use newline)
    output=$("${SCRIPT_BIN}" --search-dir "${TEST_DIR}/test_files/newline_test" < /dev/null)
    if [[ $? -eq 0 && "$output" =~ "file with newline.txt" ]]; then
        assert_success "Basic newline handling"
    else
        assert_failure "Basic newline handling"
    fi
    
    # Test with explicit newline separator
    output=$("${SCRIPT_BIN}" --search-dir "${TEST_DIR}/test_files/newline_test" --separator $'\n' < /dev/null)
    if [[ $? -eq 0 && "$output" =~ "file with newline.txt" ]]; then
        assert_success "Explicit newline separator"
    else
        assert_failure "Explicit newline separator"
    fi
}

test_null_separator() {
    [[ "$VERBOSE" == "true" ]] && echo "Testing null separator handling..."
    
    # Test with null separator
    output=$("${SCRIPT_BIN}" --search-dir "${TEST_DIR}/test_files/null_test" --separator $'\0' < /dev/null)

    # printf "%s" "$output" | hexdump -C
    
    if [[ $? -eq 0 ]]; then
        # Count files in the output
        count=$(printf "%s" "$output" | sed 's/[^\\0]//g' | tee /tmp/sed_output | wc -c)
        if [[ $count -gt 0 ]]; then
            assert_success "Null separator handling"
        else
            assert_failure "Null separator handling"
        fi
    else
        assert_failure "Null separator handling"
    fi
}

test_mixed_separators() {
    [[ "$VERBOSE" == "true" ]] && echo "Testing mixed separator scenarios..."
    
    # Test with null separator
    output=$("${SCRIPT_BIN}" --search-dir "${TEST_DIR}/test_files/mixed_test" --separator $'\0' < /dev/null)
    if [[ $? -eq 0 && -n "$output" ]]; then
        assert_success "Mixed separator handling with null"
    else
        assert_failure "Mixed separator handling with null"
    fi
    
    # Test with newline separator
    output=$("${SCRIPT_BIN}" --search-dir "${TEST_DIR}/test_files/mixed_test" --separator $'\n' < /dev/null)
    if [[ $? -eq 0 && -n "$output" ]]; then
        assert_success "Mixed separator handling with newline"
    else
        assert_failure "Mixed separator handling with newline"
    fi
}

run_separator_tests() {
    [[ "$VERBOSE" == "true" ]] && echo "Running separator handling tests..."
    test_newline_separator
    test_null_separator
    test_mixed_separators
} 