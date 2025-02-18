#!/opt/homebrew/bin/bash

# Cleanup function to handle exit
cleanup() {
    echo -e "\nCleaning up..."
    # Kill the VSCode debugging session and its parent
    if [ ! -z "$PPID" ]; then
        # Get the parent of the parent (debugger process)
        DEBUGGER_PID=$(ps -o ppid= $PPID | tr -d ' ')
        # Kill both the terminal and debugger processes
        
        if [ ! -z "$DEBUGGER_PID" ]; then
            # Kill the entire process group to ensure debugger is terminated
            kill -TERM -$DEBUGGER_PID 2>/dev/null || true
            # If TERM signal doesn't work, try KILL
            sleep 0.1
            kill -KILL -$DEBUGGER_PID 2>/dev/null || true
        fi
    fi

    exit 0
}

# Handle Ctrl+C gracefully
handle_sigint() {
    echo -e "\nReceived interrupt signal"
    cleanup
}

# Register signal handlers
trap cleanup EXIT
trap handle_sigint SIGINT

# Source the functions file with error checking
if [ -f "./ls.sh" ]; then
    source "./ls.sh"
else
    echo "Error: ls.sh not found in current directory"
    exit 1
fi

# Create tmp directory and result file if they don't exist
mkdir -p ./tmp

touch ./tmp/result.txt || echo "Error creating file!" >&2

echo "Listing files..."

find_files_excluding \
	search_dir="\/Users\/luketych\/Dev" \
	dev_null="false" \
	depth="3" \
	extensions="csv|toml" \
	directories="talon-gaze-ocr|talon_axkit" \
	substrings="LICENSE" \
	\
	use_text_files="true" \
	use_package_files="false" \
	use_web_files="true" \
    \
    ansi="true"


debug_result=$(cat ./tmp/result.txt 2>/dev/null)



# Now format and display the result if it's not empty
if [ -n "$result" ]; then
    echo "Result: $result"
fi