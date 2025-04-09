#!/opt/homebrew/bin/bash

# First stage of the pipeline - builds fd command
get_find_command() {
    local depth="$1"
    local search_dir="$2"
    local min_size="$3"
    local max_size="$4"
    local separator="$5"
    local type="$6"

    # Build the command dynamically
    local cmd="fd"

    # Add basic options
    cmd+=" --hidden --no-ignore"
    [[ -n "$depth" ]] && cmd+=" --max-depth $depth"
    [[ -n "$type" ]] && cmd+=" --type $type"

    # Add size filters if specified
    [[ -n "$min_size" ]] && cmd+=" --size +${min_size}"
    [[ -n "$max_size" ]] && cmd+=" --size -${max_size}"

    # Add separator option
    [[ "$separator" == $'\0' ]] && cmd+=" --print0"

    # Add search directory
    cmd+=" . ${search_dir:-.}"

    echo "$cmd"
}