#!/usr/bin/env bash

# Main test runner script

echo "Running: [[${BASH_SOURCE[0]##*/}]]"

ROOT_DIR=$(dirname "$(dirname "$(readlink -f "$BASH_SOURCE")")")
TEST_DIR=$(dirname "$(readlink -f "$BASH_SOURCE")")


if [ -z "${SCRIPT_BIN}" ]; then
    export SCRIPT_BIN="$(cd "$ROOT_DIR" && pwd)/index"
fi

# Parse command line arguments
SKIP_TESTS=()
while [[ $# -gt 0 ]]; do
    case $1 in
        --skip)
            SKIP_TESTS+=("$2")
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Source all test files
source "$TEST_DIR/test_utils.sh"
source "$TEST_DIR/cases/basic_operations.sh"
source "$TEST_DIR/cases/file_filtering.sh"
source "$TEST_DIR/cases/directory_filtering.sh"
source "$TEST_DIR/cases/content_filtering.sh"
source "$TEST_DIR/cases/file_types.sh"
source "$TEST_DIR/cases/separator_tests.sh"

# Source failure cases by default unless skipped
if [[ ! " ${SKIP_TESTS[@]} " =~ " failure_cases " ]]; then
    source "$TEST_DIR/cases/failure_cases.sh"
fi

# Run all test suites
run_all_tests() {
    setup_test_environment
    
    echo "Running all test suites..."
    echo "=========================="
    
    # Basic operations
    if [[ ! " ${SKIP_TESTS[@]} " =~ " basic_operations " ]]; then
        run_basic_operations_tests
    fi
    
    # File filtering tests
    if [[ ! " ${SKIP_TESTS[@]} " =~ " file_filtering " ]]; then
        run_file_filtering_tests
    fi
    
    # Directory filtering tests
    if [[ ! " ${SKIP_TESTS[@]} " =~ " directory_filtering " ]]; then
        run_directory_filtering_tests
    fi
    
    # Content filtering tests
    if [[ ! " ${SKIP_TESTS[@]} " =~ " content_filtering " ]]; then
        run_content_filtering_tests
    fi
    
    # File type tests
    if [[ ! " ${SKIP_TESTS[@]} " =~ " file_types " ]]; then
        run_file_type_tests
    fi
    
    # Failure case tests
    if [[ ! " ${SKIP_TESTS[@]} " =~ " failure_cases " ]]; then
        run_failure_case_tests
    fi
    
    # Separator handling tests
    if [[ ! " ${SKIP_TESTS[@]} " =~ " separator_tests " ]]; then
        run_separator_tests
    fi
    
    cleanup_test_environment
    
    echo "=========================="
    echo "Test Results:"
    echo "Tests Passed: $TESTS_PASSED"
    echo "Tests Failed: $TESTS_FAILED"
    echo "Total Tests: $((TESTS_PASSED + TESTS_FAILED))"
    
    # Exit with failure if any tests failed
    [ $TESTS_FAILED -eq 0 ]
}

run_all_tests "$@"