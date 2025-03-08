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
    local cmd="fd -d $depth --no-hidden"

    # Add type filter if specified, otherwise default to files
    if [[ -n "$type" ]]; then
        cmd+=" -t $type"
    fi

    if [[ "$separator" == "\0" ]]; then
        cmd+=" --print0 . $search_dir"
    else
        cmd+=" . $search_dir"
    fi
    
    # Add size filters if specified
    [[ -n "$min_size" ]] && cmd+=" --size +${min_size}"
    [[ -n "$max_size" ]] && cmd+=" --size -${max_size}"

    echo "$cmd"
}