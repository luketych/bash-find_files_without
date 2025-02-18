#!/opt/homebrew/bin/bash


#fd -d 2 -t f --no-hidden -0 \
#| \
#egrep -zv '\.(yml|py|json|md|lock)$' \
#| \
#egrep -zv '()/$' \
#| \
#egrep -zv '(README)' \
#| \
#xargs -0 eza --icons --long --grid --color=always \
#| \
#tee ~/.talon/tmp.log

# Define extension groups using simple variables
text_files="md|txt|log|rst"
package_files="package.json|pyproject.toml|Cargo.toml|Pipfile|composer.json|requirements.txt"
web_files="html|css|js|jsx|ts|tsx|scss|sass"

find_files_excluding() {
    local dev_null="true"
    local depth="2"  # Default depth
    local extensions=""
    local directories=""
    local substrings=""
    local use_text_files="true"
    local use_package_files="true"
    local use_web_files="true"

    # Parse named arguments
    for arg in "$@"; do
        case "$arg" in
            dev_null=*) dev_null="${arg#*=}" ;;
            depth=*) depth="${arg#*=}" ;;
	        extensions=*) extensions="${arg#*=}" ;;
            directories=*) directories="${arg#*=}" ;;
            substrings=*) substrings="${arg#*=}" ;;
            use_text_files=*) use_text_files="${arg#*=}" ;;
            use_package_files=*) use_package_files="${arg#*=}" ;;
            use_web_files=*) use_web_files="${arg#*=}" ;;
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
    local cmd="fd -d $depth -t f --no-hidden -0"
    [[ -n "$extensions" ]] && cmd+=" | egrep -zv '\.(${extensions})$' 2>/dev/null"
    [[ -n "$directories" ]] && cmd+=" | egrep -zv '(${directories})/$1' 2>/dev/null"
    [[ -n "$substrings" ]] && cmd+=" | egrep -zv '(${substrings})' 2>/dev/null"

    # Add xargs and eza to the command
    cmd+=" | xargs -0 eza --icons --long --grid --color=always" 
    cmd+=" | tee ~/.talon/tmp.log"
    
    if [[ "$dev_null" == "true" ]]; then
        cmd+=" > /dev/null"
    fi

    echo "executing: $cmd"

    # Execute the command dynamically and handle errors
    if ! eval "$cmd"; then
        echo "❌ Error: Command execution failed." >&2
        return
    fi
}


#find_files_excluding() {
#    local extensions=""
#    local directories=""
#    local substrings=""
#
#    # Parse named arguments
#    for arg in "$@"; do
#        case "$arg" in
#            extensions=*) extensions="${arg#*=}" ;;
#            directories=*) directories="${arg#*=}" ;;
#            substrings=*) substrings="${arg#*=}" ;;
#            *) echo "Unknown argument: $arg" && return 1 ;;
#        esac
#    done
#
#    # Start with fd command
#    local cmd="fd -d 2 -t f --no-hidden -0"
#
#    # Add egrep filters only if arguments are non-empty
#    [[ -n "$extensions" ]] && cmd+=" | egrep -zv '\.(${extensions})$' 2>/dev/null"
#    [[ -n "$directories" ]] && cmd+=" | egrep -zv '(${directories})/$' 2>/dev/null"
#    [[ -n "$substrings" ]] && cmd+=" | egrep -zv '(${substrings})' 2>/dev/null"
#
#    # Execute the command dynamically
#    eval "$cmd" | xargs -0 eza --icons --long --grid --color=always | tee ~/.talon/tmp.log
#}


# Call the function with named arguments
# find_files_excluding \
#    extensions="log|bak" \
#    directories="cache" \
#    substrings="debug|temp"