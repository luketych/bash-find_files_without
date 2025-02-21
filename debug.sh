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
if [ -f "./find_files_without.sh" ]; then
    source "./find_files_without.sh"
else
    echo "Error: find_files_without.sh not found in current directory"
    exit 1
fi

echo "Listing files..."

if ! find_files_without \
	search_dir="\/Users\/luketych\/Downloads" \
	print_screen="false" \
	depth="3" \
	extensions="csv|toml" \
	\
	\
	filter_out_text_files="false" \
	filter_out_package_files="false" \
	filter_out_web_files="false" \
    \
    ansi="true" \
    print_screen="true" \
    \
    filter_out_media_files="false" \
    \
    separator="\0"; then
    echo "Error: find_files_without command failed"
    exit 1
fi


watch_result=$(cat ./tmp/result.log 2>/dev/null)



# Now format and display the result if it's not empty
if [ -n "$result" ]; then
    echo "Result: $result"
fi