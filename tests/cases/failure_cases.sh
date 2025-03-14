#!/opt/homebrew/bin/bash

# Failure test cases

#source $(pwd)/find_files_without.sh
source $(pwd)/index

test_nonexistent_directory() {
    echo "Testing nonexistent directory..."
    find_files_without --search_dir "${TEST_DIR}/nonexistent_directory" 2>&1
    output=$("${SCRIPT_BIN}" --search-dir "${TEST_DIR}/nonexistent_directory" 2>&1)
    if [[ $? -eq 1 && "$output" =~ "Error" ]]; then
        assert_success "Nonexistent directory test"
    else
        assert_success "Nonexistent directory test"
        return 1
    fi
}

test_invalid_size_format() {
    echo "Testing invalid size format..."
    output=$("${SCRIPT_BIN}" --min-size "invalid" --search-dir $(dirname "$0")/test_files 2>&1)
    if [[ $? -eq 1 && "$output" =~ "Error" ]]; then
        assert_success "Invalid size format test"
    else
        assert_success "Invalid size format test"
        return 1
    fi
}

test_negative_depth() {
    echo "Testing negative depth..."
    
    # Define command as an array
    cmd=("$SCRIPT_BIN" "--depth" "-1" "--search-dir" "$TEST_DIR/test_files")

    echo "Executing: $(printf '%q ' "${cmd[@]}")"

    # Capture output
    output="$("${cmd[@]}" 2>&1)"
    exit_code=$?

    # Check if expected error message is present
    if echo "$output" | grep -q "Error: --depth requires a value" && [[ $exit_code -ne 0 ]]; then
        echo "✅ Expected error message detected."
    else
        echo "❌ Expected error message NOT found!"
        echo "Output: $output"
    fi

    assert_success "Negative depth test"
}

test_invalid_size_range() {
    echo "Testing invalid size range..."

    # Define command as an array
    cmd=("$SCRIPT_BIN" "--min-size" "100M" "--max-size" "10M" "--search-dir" "$TEST_DIR/test_files")

    echo "Executing: ${cmd[@]}"

    # Capture command output (both stdout and stderr)
    output="$("${cmd[@]}" 2>&1)"
    exit_code=$?

    if echo "$output" | grep -q "Error: No results found." && [[ $exit_code -ne 0 ]]; then
        echo "✅ Expected error message detected."
    else
        echo "❌ Expected error message NOT found!"
        echo "Output: $output"
    fi

    assert_success "Invalid size range test"
}

test_invalid_extension_format() {
    echo "Testing invalid extension format..."
    
    # Define command as an array to correctly pass arguments
    cmd=("$SCRIPT_BIN" "-X" "*.txt" "--search-dir" "$TEST_DIR/test_files")
    
    echo "Executing: ${cmd[@]}"

    # Run command and capture both stdout & stderr
    output="$("${cmd[@]}" 2>&1)"
    exit_code=$?

    if echo "$output" | grep -q "Error: Command execution failed" && [[ $exit_code -ne 0 ]]; then
        echo "✅ Expected error message detected."
    else
        echo "❌ Expected error message NOT found!"
        echo "Output: $output"
    fi
    
    assert_success "Invalid extension format test"
}


test_invalid_substring_pattern() {
    echo "Testing invalid substring pattern..."
    
    # Define command as an array
    cmd=("$SCRIPT_BIN" "-S" "*invalid[pattern" "--search-dir" "$TEST_DIR/test_files")

    echo "Executing: $(printf '%q ' "${cmd[@]}")"
    
    # Capture output
    output="$("${cmd[@]}" 2>&1)"
    exit_code=$?


    if echo "$output" | grep -q "Error: Command execution failed" && [[ $exit_code -ne 0 ]]; then
        echo "✅ Expected error message detected."
    else
        echo "❌ Expected error message NOT found!"
        echo "Output: $output"
    fi

    assert_success "Invalid substring pattern test"
}


test_excessive_depth() {
    echo "Testing excessive depth..."
    
    # Define command as an array
    cmd=("$SCRIPT_BIN" "--depth" "1000000" "--search-dir" "$TEST_DIR/test_files")

    echo "Executing: $(printf '%q ' "${cmd[@]}")"
    
    # Capture output
    unset output
    output="$("${cmd[@]}" 2>&1)"
    echo "$output"


    assert_success "Excessive depth test"
}

test_invalid_directory_pattern() {
    echo "Testing invalid directory pattern..."
    
    # Define command as an array
    cmd=("$SCRIPT_BIN" "-D" "*[]invalid" "--search-dir" "$TEST_DIR/test_files")

    echo "Executing: ${cmd[@]}"
    
    # Capture output
    output="$("${cmd[@]}" 2>&1)"
    echo "$output"


    assert_success "Invalid directory pattern test"
}

run_failure_case_tests() {
    echo "Running failure case tests..."
    test_nonexistent_directory
    test_invalid_size_format
    test_negative_depth
    test_invalid_size_range
    test_invalid_extension_format
    test_invalid_substring_pattern
    test_excessive_depth
    test_invalid_directory_pattern
} 