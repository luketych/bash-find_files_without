#!/opt/homebrew/bin/bash

# Second stage of the pipeline - builds filter and format commands
get_filter_command() {
    local extensions="$1"
    local directories="$2"
    local substrings="$3"
    local separator="$4"
    local ansi="$5"
    local long="$6"

    local cmd=""
    
    # Build filter command
    if [[ -n "$extensions" ]]; then
        if [[ "$separator" == "\0" ]]; then
            cmd+=" | egrep -vz '\.(${extensions})(~)?$'"
        else
            cmd+=" | egrep -v '\.(${extensions})(~)?$'"
        fi
    fi
    
    if [[ -n "$directories" ]]; then
        if [[ "$separator" == "\0" ]]; then
            cmd+=" | egrep -vz '(${directories})'"
        else
            cmd+=" | egrep -v '(${directories})'"
        fi
    fi
    
    if [[ -n "$substrings" ]]; then
        if [[ "$separator" == "\0" ]]; then
            cmd+=" | egrep -vz '(${substrings})'"
        else
            cmd+=" | egrep -v '(${substrings})'"
        fi
    fi

    # Convert null-terminated to newlines and format with eza
    if [[ "$separator" == $'\0' ]]; then
        # Only convert to newlines if we're not using eza
        if [[ "$long" != "true" ]]; then
            cmd+=" | tr '\0' '\n'"
        fi
    fi

    # Add eza formatting only if not using null separator
    if [[ "$separator" != $'\0' ]]; then
        cmd+=" | eza --all --grid --icons"
        [[ "$long" == "true" ]] && cmd+=" --long"
        [[ "$ansi" == "true" ]] && cmd+=" --color=always"
    fi

    echo "$cmd"
}