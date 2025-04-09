#!/opt/homebrew/bin/bash

# Set bash to exit on pipe failures
set -o pipefail

# Source required files
source "$(dirname "${BASH_SOURCE[0]}")/config/extensions.sh"
source "$(dirname "${BASH_SOURCE[0]}")/pipeline/a-get_find_command.sh"
source "$(dirname "${BASH_SOURCE[0]}")/pipeline/b-get_filter_command.sh"

# Function to convert size to bytes
convert_to_bytes() {
    local size=$1
    local value=${size%[kKmMgG]}
    local unit=${size#$value}
    
    case "${unit,,}" in
        k) echo $((value * 1024)) ;;
        m) echo $((value * 1024 * 1024)) ;;
        g) echo $((value * 1024 * 1024 * 1024)) ;;
        *) echo "$value" ;;
    esac
}

# Validation functions
validate_directory_pattern() {
    local dir="$1"
    # Check for invalid characters and patterns
    if [[ "$dir" =~ [*?[\]{}] ]]; then
        echo "❌ Error: Directory pattern '$dir' contains invalid wildcards or special characters." >&2
        return 1
    fi
    return 0
}

validate_size_format() {
    local size="$1"
    # Check for valid size format (number followed by optional unit)
    if ! [[ "$size" =~ ^[0-9]+[kKmMgGtT]?[bB]?$ ]]; then
        echo "❌ Error: Invalid size format '$size'. Expected format: number[unit] (e.g., 100, 50K, 20M, 1G)" >&2
        return 1
    fi
    # Convert to bytes for comparison
    local bytes=$(convert_to_bytes "$size")
    if [[ $bytes -lt 0 ]]; then
        echo "❌ Error: Size cannot be negative." >&2
        return 1
    fi
    return 0
}

validate_extension_format() {
    local ext="$1"
    # Check for valid extension format
    if ! [[ "$ext" =~ ^[a-zA-Z0-9._-]+$ ]]; then
        echo "❌ Error: Invalid extension format '$ext'. Extensions should only contain alphanumeric characters, dots, underscores, or hyphens." >&2
        return 1
    fi
    return 0
}

validate_substring_pattern() {
    local pattern="$1"
    # Check for empty pattern
    if [[ -z "$pattern" ]]; then
        echo "❌ Error: Substring pattern cannot be empty." >&2
        return 1
    fi
    # Check for invalid characters that might break the find command
  
    return 0
}



# Default values (outside the function)
DEFAULT_search_dir="."
DEFAULT_type=""
DEFAULT_depth=""
DEFAULT_min_size=""
DEFAULT_max_size=""
DEFAULT_extensions=""
DEFAULT_directories=""
DEFAULT_substrings=""
DEFAULT_output_format="NEWLINE"
DEFAULT_temp_file=""
DEFAULT_filter_out_text_files="false"
DEFAULT_filter_out_package_files="false"
DEFAULT_filter_out_web_files="false"
DEFAULT_filter_out_media_files="false"
DEFAULT_filter_out_image_files="false"
DEFAULT_filter_out_video_files="false"
DEFAULT_filter_out_audio_files="false"
DEFAULT_filter_out_archive_files="false"
DEFAULT_filter_out_database_files="false"
DEFAULT_filter_out_config_files="false"
DEFAULT_filter_out_diagram_files="false"
DEFAULT_filter_out_markup_files="false"
DEFAULT_filter_out_apple_config_files="false"
DEFAULT_filter_out_programming_files="false"
DEFAULT_filter_out_windows_files="false"
DEFAULT_ansi="true"
DEFAULT_print_screen="true"
DEFAULT_verbose="false"
DEFAULT_force_create_tmp="false"
DEFAULT_step="false"
DEFAULT_separator="NEWLINE"
DEFAULT_long="false"

run_final_cmd() {
  fd --hidden --no-ignore . . \
    | egrep -v '\.(py|js)(~)?$' \
    | eza --all --grid --icons --color=always
}

append_filters() {
  local find_cmd="$1"
  local input="$2"
  local flag="$3"
  local pattern_prefix="$4"
  local pattern_suffix="$5"

  IFS=',' read -ra items <<< "$input"
  for item in "${items[@]}"; do
    item="${item#"${item%%[![:space:]]*}"}"   # Trim leading
    item="${item%"${item##*[![:space:]]}"}"   # Trim trailing
    [[ -n "$item" ]] && find_cmd+=" $flag \"$pattern_prefix$item$pattern_suffix\""
  done

  echo "$find_cmd"
}


##
# run_split_pipeline
#
# Splits and executes a piped shell command string, ensuring that the full
# pipeline runs correctly in both TTY and non-TTY environments.
#
# This function:
# - Accepts a single command string with pipes (e.g., 'fd ... | grep ... | eza ...')
# - Splits the string into its pipeline parts
# - Trims whitespace around each part
# - Rebuilds the cleaned pipeline
# - Executes the command in a pseudo-terminal using `script` (if available),
#   preserving full formatting (grid, colors, icons, etc.)
# - Falls back to normal `bash -c` execution if `script` is not supported
#
# Arguments:
#   $1 - Full pipeline command string to execute
#
# Example:
#   run_split_pipeline 'fd . | grep "\.md$" | eza --all --grid --icons --color=always'
##
run_split_pipeline() {
  local full_cmd="$1"  # The full command string with pipes, e.g., 'fd ... | grep ... | eza ...'

  # Split the command string into pipeline parts at each pipe symbol
  IFS='|' read -ra parts <<< "$full_cmd"

  # Trim leading and trailing whitespace from each part
  for i in "${!parts[@]}"; do
    parts[$i]="${parts[$i]#"${parts[$i]%%[![:space:]]*}"}"  # Trim leading whitespace
    parts[$i]="${parts[$i]%"${parts[$i]##*[![:space:]]}"}"  # Trim trailing whitespace
  done

  # Rebuild the cleaned pipeline string
  local pipeline=""
  for i in "${!parts[@]}"; do
    [[ $i -gt 0 ]] && pipeline+=" | "      # Add pipe between parts (but not before the first one)
    pipeline+="${parts[$i]}"               # Append the cleaned command part
  done

  # Try running the pipeline inside a pseudo-terminal using `script`
  # This ensures proper rendering for tools like `eza`, `fzf`, etc.
  if command -v script &>/dev/null && [[ -t 1 ]]; then
    script -q /dev/null bash -c "$pipeline" 2>/dev/null || bash -c "$pipeline"
  else
    # Fallback to regular execution if `script` is not available or output isn't a TTY
    bash -c "$pipeline"
  fi
}


# find_files_without - Search for files while excluding specific extensions, directories, and substrings
#
# This function searches for files in a directory tree while allowing fine-grained control
# over which types of files to exclude based on extensions, directories, and substrings.
# It supports filtering by file size and various output options.
find_files_without() {
    # Step 1: Parse arguments and store in a map-like array
    declare -A overrides=()

    for arg in "$@"; do
        if [[ "$arg" == --*=* ]]; then
        key="${arg%%=*}"       # before '='
        value="${arg#*=}"      # after '='
        key="${key#--}"        # strip leading '--'

        overrides["$key"]="$value"

        # echo "🔑 Key: $key"
        # echo "📦 Value: $value"
        else
        echo "❌ Invalid argument: $arg"
        fi
    done

    # Step 2: Assign default or overridden values as local variables
    local var
    for var in \
        search_dir type depth min_size max_size extensions directories substrings \
        output_format temp_file filter_out_text_files filter_out_package_files \
        filter_out_web_files filter_out_media_files filter_out_image_files \
        filter_out_video_files filter_out_audio_files filter_out_archive_files \
        filter_out_database_files filter_out_config_files filter_out_diagram_files \
        filter_out_markup_files filter_out_apple_config_files filter_out_programming_files \
        filter_out_windows_files ansi print_screen verbose force_create_tmp step \
        separator long; do

        # If an override was passed in, use it. Otherwise use the default.
        eval "local $var=\"\${overrides[$var]:-\${DEFAULT_$var}}\""
    done

    # Constants for output format
    local NEWLINE=$'\n'
    local NULL_CHAR=$'\0'



    # Validate required parameters
    if [[ -z "$search_dir" ]]; then
        echo "❌ Error: search_dir is required" >&2
        return 1
    fi

    # Convert size parameters to bytes if provided
    local min_bytes=""
    local max_bytes=""
    if [[ -n "$min_size" ]]; then
        min_bytes=$(convert_to_bytes "$min_size")
    fi
    if [[ -n "$max_size" ]]; then
        max_bytes=$(convert_to_bytes "$max_size")
    fi

    # Validate size range
    if [[ -n "$min_size" && -n "$max_size" && "$min_bytes" -gt "$max_bytes" ]]; then
        echo "❌ Error: min_size ($min_size) cannot be greater than max_size ($max_size)." >&2
        return 1
    fi

    for field in extensions substrings directories; do
        value="${!field}"  # indirect expansion: gets the value of the variable named by $field
        if [[ -n "$value" && "$value" =~ [*?\[\]] ]]; then
            echo "❌ Error: Invalid $field pattern '$value'. Wildcards are not allowed." >&2
            return 1
        fi
    done

    # Check if temp file directory exists
    if [[ -n "$temp_file" ]]; then
        local temp_dir
        temp_dir="$(dirname "$temp_file")"

        if [[ ! -d "$temp_dir" ]]; then
            if [[ "$force_create_tmp" == "true" ]] || { read -p "Directory '$temp_dir' doesn't exist. Create it? (y/n) " answer && [[ "$answer" =~ ^[Yy]$ ]]; }; then
            mkdir -p "$temp_dir"
            else
            echo "❌ Error: Temp file directory does not exist and was not created." >&2
            return 1
            fi
        fi
    fi

    [[ "$step" == "true" ]] && read -p "Press Enter to continue with extension normalization..."

    # Normalize extensions: remove all dots
    [[ -n "$extensions" ]] && extensions="${extensions//./}"

    # Add extensions based on enabled filters
    declare -A extension_groups=(
        [text_files]="$filter_out_text_files"
        [package_files]="$filter_out_package_files"
        [web_files]="$filter_out_web_files"
        [media_files]="$filter_out_media_files"
        [image_files]="$filter_out_image_files"
        [video_files]="$filter_out_video_files"
        [audio_files]="$filter_out_audio_files"
        [archive_files]="$filter_out_archive_files"
        [database_files]="$filter_out_database_files"
        [config_files]="$filter_out_config_files"
        [diagram_files]="$filter_out_diagram_files"
        [markup_files]="$filter_out_markup_files"
        [apple_config_files]="$filter_out_apple_config_files"
        [programming_files]="$filter_out_programming_files"
        [windows_files]="$filter_out_windows_files"
    )

    for group in "${!extension_groups[@]}"; do
        if [[ "${extension_groups[$group]}" == "true" ]]; then
            [[ -n "$extensions" ]] && extensions+="|"
            extensions+="${!group}"
        fi
    done


    find_cmd="$(get_find_command "$depth" "$search_dir" "$min_size" "$max_size" "$separator" "$type")"

    filter_cmd="$(get_filter_command "$extensions" "$directories" "$substrings" "$separator" "$ansi" "$long")"

    final_cmd="$find_cmd $filter_cmd"

    echo "🔍 Executing command: $final_cmd"

    # Execute the find command with the appropriate separator
    if [[ "$output_format" == "NULL_CHAR" ]]; then
        eval "$final_cmd -print0" > "$temp_file"
    else
        eval "$final_cmd" > "$temp_file"
    fi


    run_split_pipeline "$final_cmd"




    #escaped_cmd=$(printf "%q" "$final_cmd")

    #run_with_pty_and_log "out.txt" $escaped_cmd

    # less -R out.txt



    # run $final_cmd

    # eval "$final_cmd"



    #eza --all --grid --icons --color=always out.txt


    #eza --all --grid --icons --color=always -- $(<out.txt)

    #unbuffer eza --all --grid --icons --color=always -- $(<out.txt)


    # Check if the command succeeded
    if [[ $? -ne 0 ]]; then
        echo "❌ Error: Command execution failed." >&2
        return 1
    fi

    # Print results if requested
    if [[ "$print_screen" == "true" ]]; then
        if [[ "$output_format" == "NULL_CHAR" ]]; then
            # Use cat -v to preserve null characters
            cat -v "$temp_file" | tr '\0' '\n'
        else
            cat "$temp_file"
        fi
    fi

    return 0
}

# Build arguments string
# args=""
# [[ -n "$verbose" ]] && args+="--verbose=$verbose "
# [[ -n "$print_screen" ]] && args+="--print-screen=$print_screen "
# [[ -n "$ansi" ]] && args+="--ansi=$ansi "
# [[ -n "$depth" ]] && args+="--depth=$depth "
# [[ -n "$search_dir" ]] && args+="--search-dir=$search_dir "
# [[ -n "$max_size" ]] && args+="--max-size=$max_size "
# [[ -n "$min_size" ]] && args+="--min-size=$min_size "
# [[ -n "$force_create_tmp" ]] && args+="--force-create-tmp=$force_create_tmp "
# [[ -n "$step" ]] && args+="--step=$step "
# [[ -n "$separator" ]] && args+="--separator=$separator "
# [[ -n "$long" ]] && args+="--long=$long "
# [[ -n "$type" ]] && args+="--type=$type "
# [[ -n "$extensions" ]] && args+="--extensions=$extensions "
# [[ -n "$directories" ]] && args+="--directories=$directories "
# [[ -n "$substrings" ]] && args+="--substrings=$substrings "
# [[ -n "$filter_out_text_files" ]] && args+="--filter-out-text-files=$filter_out_text_files "
# [[ -n "$filter_out_package_files" ]] && args+="--filter-out-package-files=$filter_out_package_files "
# [[ -n "$filter_out_web_files" ]] && args+="--filter-out-web-files=$filter_out_web_files "
# [[ -n "$filter_out_media_files" ]] && args+="--filter-out-media-files=$filter_out_media_files "
# [[ -n "$filter_out_image_files" ]] && args+="--filter-out-image-files=$filter_out_image_files "
# [[ -n "$filter_out_video_files" ]] && args+="--filter-out-video-files=$filter_out_video_files "
# [[ -n "$filter_out_audio_files" ]] && args+="--filter-out-audio-files=$filter_out_audio_files "
# [[ -n "$filter_out_archive_files" ]] && args+="--filter-out-archive-files=$filter_out_archive_files "
# [[ -n "$filter_out_database_files" ]] && args+="--filter-out-database-files=$filter_out_database_files "
# [[ -n "$filter_out_config_files" ]] && args+="--filter-out-config-files=$filter_out_config_files "
# [[ -n "$filter_out_diagram_files" ]] && args+="--filter-out-diagram-files=$filter_out_diagram_files "
# [[ -n "$filter_out_markup_files" ]] && args+="--filter-out-markup-files=$filter_out_markup_files "
# [[ -n "$filter_out_apple_config_files" ]] && args+="--filter-out-apple-config-files=$filter_out_apple_config_files "
# [[ -n "$filter_out_programming_files" ]] && args+="--filter-out-programming-files=$filter_out_programming_files "
# [[ -n "$filter_out_windows_files" ]] && args+="--filter-out-windows-files=$filter_out_windows_files "
# [[ -n "$temp_file" ]] && args+="--temp-file=$temp_file"

# find_files_without $args