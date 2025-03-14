#!/opt/homebrew/bin/bash

# Set bash to exit on pipe failures
set -o pipefail
CONFIG_DIR=$(dirname "$(readlink -f "$BASH_SOURCE")")

source "${CONFIG_DIR}/config/filters.sh"
source "${CONFIG_DIR}/pipeline/a.sh"
source "${CONFIG_DIR}/pipeline/b.sh"

# find_files_without - Search for files while excluding specific extensions, directories, and substrings
#
# This function searches for files in a directory tree while allowing fine-grained control
# over which types of files to exclude based on extensions, directories, and substrings.
# It supports filtering by file size and various output options.
find_files_without() { 
    local script_dir="$(dirname "${BASH_SOURCE[0]}")"
    local temp_result_file="$script_dir/tmp/result.log"
    local temp_result_file_colored="$script_dir/tmp/result_colored.log"

    local search_dir="."  # Base directory to start search from (default: ".")
    local depth="2"  # Maximum directory depth to search (default: "2")
    local extensions=""  # Additional file extensions to exclude (pipe-separated)
    local directories=""  # Directory names to exclude (pipe-separated)
    local substrings=""  # Substrings to exclude from filenames (pipe-separated)
    local min_size=""  # Minimum file size filter
    local max_size=""  # Maximum file size filter
    local filter_out_text_files="false"  # Whether to exclude common text files (default: true)
    local filter_out_package_files="false"  # Whether to exclude package management files (default: true)
    local filter_out_web_files="false"  # Whether to exclude web development files (default: true)
    local filter_out_media_files="false"  # Whether to exclude media files (default: true)
    local filter_out_image_files="false"  # Whether to exclude image files (default: true)
    local filter_out_video_files="false"  # Whether to exclude video files (default: true)
    local filter_out_audio_files="false"  # Whether to exclude audio files (default: true)
    local filter_out_archive_files="false"  # Whether to exclude archive files (default: true)
    local filter_out_database_files="false"  # Whether to exclude database files (default: true)
    local filter_out_config_files="false"  # Whether to exclude config files (default: true)
    local filter_out_diagram_files="false"  # Whether to exclude diagram files (default: true)
    local filter_out_markup_files="false"  # Whether to exclude markup files (default: true)
    local filter_out_apple_config_files="false"  # Whether to exclude Apple config files (default: true)
    local filter_out_windows_files="false"  # Whether to exclude Windows files (default: true)
    local filter_out_programming_files="false"  # Whether to exclude programming files (default: true)
    local ansi="true"  # Enable/disable ANSI colors in output (default: true)
    local print_screen="true"  # Print results to screen (default: true)
    local verbose="false"  # Enable verbose output (default: false)
    local force_create_tmp="false"  # Create temp directory without prompting (default: false)
    local step="false"  # Enable step-by-step execution (default: false)
    local separator="\0"
    local long="false"  # Enable long format output (default: false)
    local type="f"  # Filter by type: f (file), d (directory), l (symlink), x (executable)
    
    # Parse named arguments for backwards compatibility
    for arg in "$@"; do
        case "$arg" in
            search_dir=*) search_dir="${arg#*=}" ;;
            depth=*) depth="${arg#*=}" ;;
	          extensions=*) extensions="${arg#*=}" ;;
            directories=*) directories="${arg#*=}" ;;
            substrings=*) substrings="${arg#*=}" ;;
            min_size=*) min_size="${arg#*=}" ;;  # New case for minimum size
            max_size=*) max_size="${arg#*=}" ;;  # New case for maximum size
            filter_out_text_files=*) filter_out_text_files="${arg#*=}" ;;
            filter_out_package_files=*) filter_out_package_files="${arg#*=}" ;;
            filter_out_web_files=*) filter_out_web_files="${arg#*=}" ;;
            filter_out_media_files=*) filter_out_media_files="${arg#*=}" ;;  # New case for media files
            filter_out_image_files=*) filter_out_image_files="${arg#*=}" ;;  # New case for image files
            filter_out_video_files=*) filter_out_video_files="${arg#*=}" ;;  # New case for video files
            filter_out_audio_files=*) filter_out_audio_files="${arg#*=}" ;;  # New case for audio files
            filter_out_archive_files=*) filter_out_archive_files="${arg#*=}" ;;
            filter_out_database_files=*) filter_out_database_files="${arg#*=}" ;;
            filter_out_config_files=*) filter_out_config_files="${arg#*=}" ;;  # New case for config files
            filter_out_diagram_files=*) filter_out_diagram_files="${arg#*=}" ;;  # New case for diagram files
            filter_out_markup_files=*) filter_out_markup_files="${arg#*=}" ;;  # New case for markup files
            filter_out_apple_config_files=*) filter_out_apple_config_files="${arg#*=}" ;;  # New case for Apple config files
            filter_out_programming_files=*) filter_out_programming_files="${arg#*=}" ;;  # New case for programming files
            filter_out_windows_files=*) filter_out_windows_files="${arg#*=}" ;;  # New case for Windows files
            ansi=*) ansi="${arg#*=}" ;;
            print_screen=*) print_screen="${arg#*=}" ;;
            verbose=*) verbose="${arg#*=}" ;;
            temp_file=*) temp_result_file="${arg#*=}" ;;
            force_create_tmp=*) force_create_tmp="${arg#*=}" ;;
            step=*) step="${arg#*=}" ;;
            long=*) long="${arg#*=}" ;;
            type=*) type="${arg#*=}" ;;
            separator=*) 
                if [[ "${arg#*=}" != "\0" && "${arg#*=}" != "\n" ]]; then
                    echo "❌ Error: separator must be either \0 or \n" >&2
                    return 1
                fi
                separator="${arg#*=}" 
                ;;
            *) echo "❌ Error: Unknown argument: $arg" >&2 && return 1 ;;
        esac
    done

    # if max_size is less than min_size, return an error
    if [[ -n "$min_size" && -n "$max_size" ]]; then
        if [[ "$min_size" -gt "$max_size" ]]; then
            echo "❌ Error: Minimum size is greater than maximum size." >&2
            return 1
        fi
    fi


    # Check if temp file directory exists
    if [[ -n "$temp_result_file" ]]; then
        temp_dir=$(dirname "$temp_result_file")
        if [[ ! -d "$temp_dir" ]]; then
            if [[ "$force_create_tmp" == "true" ]]; then
                mkdir -p "$temp_dir"
            else
                read -p "Directory for temp file '$temp_dir' does not exist. Create it? (y/n) " answer
                if [[ "$answer" =~ ^[Yy]$ ]]; then
                    mkdir -p "$temp_dir"
                else
                    echo "❌ Error: Temp file directory does not exist and was not created." >&2
                    return 1
                fi
            fi
        fi
    fi

    [[ "$step" == "true" ]] && read -p "Press Enter to continue with extension normalization..."

    # Normalize extensions: remove leading dots if present
    if [[ -n "$extensions" ]]; then
        extensions=$(echo "$extensions" | sed 's/\.//g')
    fi
    [[ "$step" == "true" ]] && read -p "Press Enter to continue with adding extensions based on flags..."

    # Add extensions based on enabled flags
    if [[ "$filter_out_text_files" == "true" ]]; then
        [[ -n "$extensions" ]] && extensions="${extensions}|"
        extensions="${extensions}${text_files}"
    fi
    if [[ "$filter_out_package_files" == "true" ]]; then
        [[ -n "$extensions" ]] && extensions="${extensions}|"
        extensions="${extensions}${package_files}"
    fi
    if [[ "$filter_out_web_files" == "true" ]]; then
        [[ -n "$extensions" ]] && extensions="${extensions}|"
        extensions="${extensions}${web_files}"
    fi
    if [[ "$filter_out_media_files" == "true" ]]; then
        [[ -n "$extensions" ]] && extensions="${extensions}|"
        extensions="${extensions}${media_files}"
    fi
    if [[ "$filter_out_image_files" == "true" ]]; then
        [[ -n "$extensions" ]] && extensions="${extensions}|"
        extensions="${extensions}${image_files}"
    fi
    if [[ "$filter_out_video_files" == "true" ]]; then
        [[ -n "$extensions" ]] && extensions="${extensions}|"
        extensions="${extensions}${video_files}"
    fi
    if [[ "$filter_out_audio_files" == "true" ]]; then
        [[ -n "$extensions" ]] && extensions="${extensions}|"
        extensions="${extensions}${audio_files}"
    fi
    if [[ "$filter_out_archive_files" == "true" ]]; then
        [[ -n "$extensions" ]] && extensions="${extensions}|"
        extensions="${extensions}${archive_files}"
    fi
    if [[ "$filter_out_database_files" == "true" ]]; then
        [[ -n "$extensions" ]] && extensions="${extensions}|"
        extensions="${extensions}${database_files}"
    fi
    if [[ "$filter_out_config_files" == "true" ]]; then
        [[ -n "$extensions" ]] && extensions="${extensions}|"
        extensions="${extensions}${config_files}"
    fi
    if [[ "$filter_out_diagram_files" == "true" ]]; then
        [[ -n "$extensions" ]] && extensions="${extensions}|"
        extensions="${extensions}${diagram_files}"
    fi
    if [[ "$filter_out_markup_files" == "true" ]]; then
        [[ -n "$extensions" ]] && extensions="${extensions}|"
        extensions="${extensions}${markup_files}"
    fi
    if [[ "$filter_out_apple_config_files" == "true" ]]; then
        [[ -n "$extensions" ]] && extensions="${extensions}|"
        extensions="${extensions}${apple_config_files}"
    fi
    if [[ "$filter_out_windows_files" == "true" ]]; then
        [[ -n "$extensions" ]] && extensions="${extensions}|"
        extensions="${extensions}${windows_files}"
    fi
    if [[ "$filter_out_programming_files" == "true" ]]; then
        [[ -n "$extensions" ]] && extensions="${extensions}|"
        extensions="${extensions}${programming_files}"
    fi

    extensions="${extensions#|}" # Remove leading '|'

    [[ "$step" == "true" ]] && read -p "Press Enter to execute pipeline..."

    # Get commands from pipeline stages
    local find_cmd=$(get_find_command \
        "$depth" \
        "$search_dir" \
        "$min_size" \
        "$max_size" \
        "$separator" \
        "$type")

    local filter_cmd=$(get_filter_command \
        "$extensions" \
        "$directories" \
        "$substrings" \
        "$separator" \
        "$ansi" \
        "$long")

    # Build final command
    local final_cmd="$find_cmd$filter_cmd"

    # Print command if verbose
    [[ "$verbose" == "true" ]] && echo "Executing: $final_cmd" >&2

    # Execute the command and capture output
    if ! result=$(eval "$final_cmd" 2>/dev/null); then
        echo "❌ Error: Command execution failed." >&2
        return 1
    fi

    if [[ -z "$result" ]]; then
        echo "❌ Error: No results found." >&2
        return 1
    fi

    # Handle output
    if [[ "$print_screen" == "true" ]]; then
        echo "$result"
    fi
    
    if [[ -n "$temp_result_file" ]]; then
        echo "$result" > "$temp_result_file"
    fi
}