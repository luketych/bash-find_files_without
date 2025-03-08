#!/opt/homebrew/bin/bash

# Set bash to exit on pipe failures
set -o pipefail

# Source extension definitions
source "$(dirname "${BASH_SOURCE[0]}")/config/filters.sh"

# Source pipeline stages
source "$(dirname "${BASH_SOURCE[0]}")/pipeline/a.sh"
source "$(dirname "${BASH_SOURCE[0]}")/pipeline/b.sh"

# find_files_with - Search for files matching specific extensions, directories, and substrings
#
# This function searches for files in a directory tree while allowing fine-grained control
# over which types of files to include based on extensions, directories, and substrings.
# It supports filtering by file size and various output options.
find_files_with() { 
    local script_dir="$(dirname "${BASH_SOURCE[0]}")"
    local temp_result_file="$script_dir/tmp/result.log"
    local temp_result_file_colored="$script_dir/tmp/result_colored.log"

    local search_dir="."  # Base directory to start search from (default: ".")
    local depth="1"  # Maximum directory depth to search (default: "2")
    local extensions=""  # File extensions to include (pipe-separated)
    local directories=""  # Directory names to include (pipe-separated)
    local substrings=""  # Substrings to include in filenames (pipe-separated)
    local min_size=""  # Minimum file size filter
    local max_size=""  # Maximum file size filter
    local include_text_files="false"  # Whether to include common text files
    local include_package_files="false"  # Whether to include package management files
    local include_web_files="false"  # Whether to include web development files
    local include_media_files="false"  # Whether to include media files
    local include_image_files="false"  # Whether to include image files
    local include_video_files="false"  # Whether to include video files
    local include_audio_files="false"  # Whether to include audio files
    local include_archive_files="false"  # Whether to include archive files
    local include_database_files="false"  # Whether to include database files
    local include_config_files="false"  # Whether to include config files
    local include_diagram_files="false"  # Whether to include diagram files
    local include_markup_files="false"  # Whether to include markup files
    local include_apple_config_files="false"  # Whether to include Apple config files
    local include_windows_files="false"  # Whether to include Windows files
    local include_programming_files="false"  # Whether to include programming files
    local ansi="true"  # Enable/disable ANSI colors in output (default: true)
    local print_screen="true"  # Print results to screen (default: true)
    local verbose="false"  # Enable verbose output (default: false)
    local force_create_tmp="false"  # Create temp directory without prompting (default: false)
    local step="false"  # Enable step-by-step execution (default: false)
    local separator="\0"
    local long="false"  # Enable long format output (default: false)
    local type="f"  # Filter by type: f (file), d (directory), l (symlink), x (executable)
    
    # Parse named arguments
    for arg in "$@"; do
        case "$arg" in
            search_dir=*) search_dir="${arg#*=}" ;;
            depth=*) depth="${arg#*=}" ;;
            extensions=*) extensions="${arg#*=}" ;;
            directories=*) directories="${arg#*=}" ;;
            substrings=*) substrings="${arg#*=}" ;;
            min_size=*) min_size="${arg#*=}" ;;
            max_size=*) max_size="${arg#*=}" ;;
            include_text_files=*) include_text_files="${arg#*=}" ;;
            include_package_files=*) include_package_files="${arg#*=}" ;;
            include_web_files=*) include_web_files="${arg#*=}" ;;
            include_media_files=*) include_media_files="${arg#*=}" ;;
            include_image_files=*) include_image_files="${arg#*=}" ;;
            include_video_files=*) include_video_files="${arg#*=}" ;;
            include_audio_files=*) include_audio_files="${arg#*=}" ;;
            include_archive_files=*) include_archive_files="${arg#*=}" ;;
            include_database_files=*) include_database_files="${arg#*=}" ;;
            include_config_files=*) include_config_files="${arg#*=}" ;;
            include_diagram_files=*) include_diagram_files="${arg#*=}" ;;
            include_markup_files=*) include_markup_files="${arg#*=}" ;;
            include_apple_config_files=*) include_apple_config_files="${arg#*=}" ;;
            include_programming_files=*) include_programming_files="${arg#*=}" ;;
            include_windows_files=*) include_windows_files="${arg#*=}" ;;
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
    local all_extensions=""
    if [[ "$include_text_files" == "true" ]]; then
        [[ -n "$all_extensions" ]] && all_extensions="${all_extensions}|"
        all_extensions="${all_extensions}${text_files}"
    fi
    if [[ "$include_package_files" == "true" ]]; then
        [[ -n "$all_extensions" ]] && all_extensions="${all_extensions}|"
        all_extensions="${all_extensions}${package_files}"
    fi
    if [[ "$include_web_files" == "true" ]]; then
        [[ -n "$all_extensions" ]] && all_extensions="${all_extensions}|"
        all_extensions="${all_extensions}${web_files}"
    fi
    if [[ "$include_media_files" == "true" ]]; then
        [[ -n "$all_extensions" ]] && all_extensions="${all_extensions}|"
        all_extensions="${all_extensions}${media_files}"
    fi
    if [[ "$include_image_files" == "true" ]]; then
        [[ -n "$all_extensions" ]] && all_extensions="${all_extensions}|"
        all_extensions="${all_extensions}${image_files}"
    fi
    if [[ "$include_video_files" == "true" ]]; then
        [[ -n "$all_extensions" ]] && all_extensions="${all_extensions}|"
        all_extensions="${all_extensions}${video_files}"
    fi
    if [[ "$include_audio_files" == "true" ]]; then
        [[ -n "$all_extensions" ]] && all_extensions="${all_extensions}|"
        all_extensions="${all_extensions}${audio_files}"
    fi
    if [[ "$include_archive_files" == "true" ]]; then
        [[ -n "$all_extensions" ]] && all_extensions="${all_extensions}|"
        all_extensions="${all_extensions}${archive_files}"
    fi
    if [[ "$include_database_files" == "true" ]]; then
        [[ -n "$all_extensions" ]] && all_extensions="${all_extensions}|"
        all_extensions="${all_extensions}${database_files}"
    fi
    if [[ "$include_config_files" == "true" ]]; then
        [[ -n "$all_extensions" ]] && all_extensions="${all_extensions}|"
        all_extensions="${all_extensions}${config_files}"
    fi
    if [[ "$include_diagram_files" == "true" ]]; then
        [[ -n "$all_extensions" ]] && all_extensions="${all_extensions}|"
        all_extensions="${all_extensions}${diagram_files}"
    fi
    if [[ "$include_markup_files" == "true" ]]; then
        [[ -n "$all_extensions" ]] && all_extensions="${all_extensions}|"
        all_extensions="${all_extensions}${markup_files}"
    fi
    if [[ "$include_apple_config_files" == "true" ]]; then
        [[ -n "$all_extensions" ]] && all_extensions="${all_extensions}|"
        all_extensions="${all_extensions}${apple_config_files}"
    fi
    if [[ "$include_windows_files" == "true" ]]; then
        [[ -n "$all_extensions" ]] && all_extensions="${all_extensions}|"
        all_extensions="${all_extensions}${windows_files}"
    fi
    if [[ "$include_programming_files" == "true" ]]; then
        [[ -n "$all_extensions" ]] && all_extensions="${all_extensions}|"
        all_extensions="${all_extensions}${programming_files}"
    fi

    # Combine user-specified extensions with flag-based extensions
    if [[ -n "$extensions" ]]; then
        [[ -n "$all_extensions" ]] && all_extensions="${all_extensions}|"
        all_extensions="${all_extensions}${extensions}"
    fi

    [[ "$step" == "true" ]] && read -p "Press Enter to execute pipeline..."

    # Get commands from pipeline stages
    local find_cmd=$(get_find_command \
        "$depth" \
        "$search_dir" \
        "$min_size" \
        "$max_size" \
        "$separator" \
        "$type")

    local filter_cmd=$(get_include_filter_command \
        "$all_extensions" \
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