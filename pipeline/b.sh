#!/opt/homebrew/bin/bash

# Second stage of the pipeline - builds filter and format commands
<<<<<<< HEAD
get_filter_command() {
=======
get_include_filter_command() {
>>>>>>> 1ad8a2e71b00bcb5bea29f490d19ba19ef4a955c
    local extensions="$1"
    local directories="$2"
    local substrings="$3"
    local separator="$4"
    local ansi="$5"
    local long="$6"

    local cmd=""
    
<<<<<<< HEAD
    # Build filter command
    if [[ -n "$extensions" ]]; then
        if [[ "$separator" == "\0" ]]; then
            cmd+=" | egrep -vz '\.(${extensions})(~)?$'"
        else
            cmd+=" | egrep -v '\.(${extensions})(~)?$'"
=======
    # Build filter command with positive matches
    if [[ -n "$extensions" ]]; then
        if [[ "$separator" == "\0" ]]; then
            cmd+=" | egrep -z '\.(${extensions})(~)?$'"
        else
            cmd+=" | egrep '\.(${extensions})(~)?$'"
>>>>>>> 1ad8a2e71b00bcb5bea29f490d19ba19ef4a955c
        fi
    fi
    
    if [[ -n "$directories" ]]; then
        if [[ "$separator" == "\0" ]]; then
<<<<<<< HEAD
            cmd+=" | egrep -vz '(${directories})'"
        else
            cmd+=" | egrep -v '(${directories})'"
=======
            cmd+=" | egrep -z '(${directories})'"
        else
            cmd+=" | egrep '(${directories})'"
>>>>>>> 1ad8a2e71b00bcb5bea29f490d19ba19ef4a955c
        fi
    fi
    
    if [[ -n "$substrings" ]]; then
        if [[ "$separator" == "\0" ]]; then
<<<<<<< HEAD
            cmd+=" | egrep -vz '(${substrings})'"
        else
            cmd+=" | egrep -v '(${substrings})'"
=======
            cmd+=" | egrep -z '(${substrings})'"
        else
            cmd+=" | egrep '(${substrings})'"
>>>>>>> 1ad8a2e71b00bcb5bea29f490d19ba19ef4a955c
        fi
    fi

    # Convert to newlines for eza
    cmd+=" | tr '\0' '\n'"

    # Format with eza
    local eza_cmd="eza --icons --grid"
    [[ "$long" == "true" ]] && eza_cmd+=" --long"
    [[ "$ansi" == "true" ]] && eza_cmd+=" --color=always" || eza_cmd+=" --color=never"

    cmd+=" | tr '\n' '\0' | xargs -0 $eza_cmd"

    echo "$cmd"
} 