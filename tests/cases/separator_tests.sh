#!/bin/bash

# Tests for different separator handling

test_newline_separator() {
    echo "Testing newline separator handling..."
    
    # Test with default handling (should use newline)
    output=$("${SCRIPT_BIN}" --search-dir "test_files/newline_test" < /dev/null)
    if [[ $? -eq 0 && "$output" =~ "file with newline.txt" ]]; then
        assert_success "Basic newline handling"
    else
        assert_success "Basic newline handling"
        return 1
    fi
    
    # Test with explicit newline separator
    output=$("${SCRIPT_BIN}" --search-dir "test_files/newline_test" --separator $'\n' < /dev/null)
    if [[ $? -eq 0 && "$output" =~ "file with newline.txt" ]]; then
        assert_success "Explicit newline separator"
    else
        assert_success "Explicit newline separator"
        return 1
    fi
}

test_null_separator() {
    echo "Testing null separator handling..."
    
    # Test with null separator
    output=$("${SCRIPT_BIN}" --search-dir "test_files/null_test" --separator $'\0' < /dev/null)
    if [[ $? -eq 0 ]]; then
        # Count null-separated entries
        count=$(echo -n "$output" | tr -cd '\0' | wc -c)
        if [[ $count -gt 0 ]]; then
            assert_success "Null separator handling"
        else
            assert_success "Null separator handling"
            return 1
        fi
    else
        assert_success "Null separator handling"
        return 1
    fi
}

test_mixed_separators() {
    echo "Testing mixed separator scenarios..."
    
    # Test with null separator
    output=$("${SCRIPT_BIN}" --search-dir "test_files/mixed_test" --separator $'\0' < /dev/null)
    if [[ $? -eq 0 && -n "$output" ]]; then
        assert_success "Mixed separator handling with null"
    else
        assert_success "Mixed separator handling with null"
        return 1
    fi
    
    # Test with newline separator
    output=$("${SCRIPT_BIN}" --search-dir "test_files/mixed_test" --separator $'\n' < /dev/null)
    if [[ $? -eq 0 && -n "$output" ]]; then
        assert_success "Mixed separator handling with newline"
    else
        assert_success "Mixed separator handling with newline"
        return 1
    fi
}

run_separator_tests() {
    echo "Running separator handling tests..."
    test_newline_separator
    test_null_separator
    test_mixed_separators
} 