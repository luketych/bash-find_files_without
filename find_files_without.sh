#!/opt/homebrew/bin/bash


# Define extension groups using simple variables

text_files="md|txt|log|rst"
package_files="package.json|pyproject.toml|Cargo.toml|Pipfile|composer.json|requirements.txt"
web_files="html|css|js|jsx|ts|tsx|scss|sass"


find_files_without() {
    local temp_result_file="./tmp/result.txt"

    local search_dir="."  # Default to current directory
    local dev_null="true"
    local depth="2"  # Default depth
    local extensions=""
    local directories=""
    local substrings=""
    local use_text_files="true"
    local use_package_files="true"
    local use_web_files="true"
    local ansi="true"
    local print_screen="true"  # New argument for printing to screen
    local verbose="false"  # New verbose option

    # Parse named arguments
    for arg in "$@"; do
        case "$arg" in
            search_dir=*) search_dir="${arg#*=}" ;;
            dev_null=*) dev_null="${arg#*=}" ;;
            depth=*) depth="${arg#*=}" ;;
	        extensions=*) extensions="${arg#*=}" ;;
            directories=*) directories="${arg#*=}" ;;
            substrings=*) substrings="${arg#*=}" ;;
            use_text_files=*) use_text_files="${arg#*=}" ;;
            use_package_files=*) use_package_files="${arg#*=}" ;;
            use_web_files=*) use_web_files="${arg#*=}" ;;
            ansi=*) ansi="${arg#*=}" ;;
            print_screen=*) print_screen="${arg#*=}" ;;
            verbose=*) verbose="${arg#*=}" ;;
            *) echo "❌ Error: Unknown argument: $arg" >&2 && return 1 ;;
        esac
    done

    # Normalize extensions: remove leading dots if present
    if [[ -n "$extensions" ]]; then
        extensions=$(echo "$extensions" | sed 's/\.//g')
    fi

    # Add extensions based on enabled flags
    [[ "$use_text_files" == "true" ]] && extensions="${extensions}|${text_files}"
    [[ "$use_package_files" == "true" ]] && extensions="${extensions}|${package_files}"
    [[ "$use_web_files" == "true" ]] && extensions="${extensions}|${web_files}"

    extensions="${extensions#|}" # Remove leading '|'

    # Build the command dynamically
    local cmd="fd -d $depth -t f --no-hidden -0 . $search_dir"
    [[ -n "$extensions" ]] && cmd+=" | egrep -zv '\.(${extensions})$' 2>/dev/null"
    [[ -n "$directories" ]] && cmd+=" | egrep -zv '(${directories})/$1' 2>/dev/null"
    [[ -n "$substrings" ]] && cmd+=" | egrep -zv '(${substrings})' 2>/dev/null"

    # Add xargs and eza to the command with color control
    if [[ "$ansi" == "true" ]]; then
        cmd+=" | xargs -0 eza --icons --long --grid --color=always"
    else
        cmd+=" | xargs -0 eza --icons --long --grid --color=never"
    fi
    
    # Check if either output option is enabled
    if [[ "$print_screen" != "true" && -z "$temp_result_file" ]]; then
        echo "⚠️  Warning: No output destination specified. Please enable print_screen or provide temp_result_file." >&2
        return 1
    fi

    # Only print executing message if verbose is true
    [[ "$verbose" == "true" ]] && echo "executing: $cmd"
    
    # Execute the command dynamically and store result
    if ! result=$(eval "$cmd"); then
        echo "❌ Error: Command execution failed." >&2
        return 1
    fi

    # Handle output based on settings
    if [[ "$print_screen" == "true" ]]; then
        echo "$result"
    fi
    
    if [[ -n "$temp_result_file" ]]; then
        echo "$result" > "$temp_result_file"
    fi
}