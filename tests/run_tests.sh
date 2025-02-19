#!/usr/bin/env bash

# Main test runner script

echo "Running: [[${BASH_SOURCE[0]##*/}]]"

if [ -z "${FWO_BIN}" ]; then
    export FWO_BIN="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/fwo"
fi


# Source all test files
source "$(dirname "$0")/test_utils.sh"
source "$(dirname "$0")/cases/basic_operations.sh"
source "$(dirname "$0")/cases/file_filtering.sh"
source "$(dirname "$0")/cases/directory_filtering.sh"
source "$(dirname "$0")/cases/content_filtering.sh"
source "$(dirname "$0")/cases/file_types.sh"
source "$(dirname "$0")/cases/failure_cases.sh"

# Run all test suites
run_all_tests() {
    setup_test_environment
    
    echo "Running all test suites..."
    echo "=========================="
    
    # Basic operations
    run_basic_operations_tests
    
    # File filtering tests
    run_file_filtering_tests
    
    # Directory filtering tests
    run_directory_filtering_tests
    
    # Content filtering tests
    run_content_filtering_tests
    
    # File type tests
    run_file_type_tests
    
    # Failure case tests
    run_failure_case_tests
    
    cleanup_test_environment
    
    echo "=========================="
    echo "All test suites completed"
}

run_all_tests