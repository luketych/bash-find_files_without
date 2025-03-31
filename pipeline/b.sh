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
            cmd+=" | grep -Evz '\.(${extensions})(~)?$'"
        else
            cmd+=" | grep -Ev '\.(${extensions})(~)?$'"
        fi
    fi
    
    if [[ -n "$directories" ]]; then
        if [[ "$separator" == "\0" ]]; then
            cmd+=" | grep -Evz '(${directories})'"
        else
            cmd+=" | grep -Ev '(${directories})'"
        fi
    fi
    
    if [[ -n "$substrings" ]]; then
        if [[ "$separator" == "\0" ]]; then
            cmd+=" | grep -Evz '(${substrings})'"
        else
            cmd+=" | grep -Ev '(${substrings})'"
        fi
    fi

    # Format with eza
    local eza_cmd="eza --icons --grid"
    [[ "$long" == "true" ]] && eza_cmd+=" --long"
    [[ "$ansi" == "true" ]] && eza_cmd+=" --color=always" || eza_cmd+=" --color=never"

    # Only add xargs if we need to convert to newlines
    if [[ "$separator" == "\0" ]]; then
        cmd+=" | xargs -0 $eza_cmd"
    else
        cmd+=" | $eza_cmd"
    fi

    echo "${cmd}"
}