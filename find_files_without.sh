#!/opt/homebrew/bin/bash

# Set bash to exit on pipe failures
set -o pipefail

# Define extension groups using simple variables

text_files="md|txt|log|rst|doc|docx|pdf"
package_files="apkg|package.json|pyproject.toml|Cargo.toml|Pipfile|composer.json|requirements.txt"
config_files="properties|yaml|yml|toml|ini|conf|cfg|config|properties|settings|preferences|options|options.json|options.yaml|options.yml|options.toml"
web_files="html|css|js|jsx|ts|tsx|scss|sass"

media_files="aac|avif|aif|mp3.asd|mp3|reapeaks|reapindex|mp4|m4a|avi|mov|wmv|flv|mpeg|mpg|m4v|mkv|webm|gif|jpg|jpeg|png|svg|ico|webp|heic|heif|wav|mp4.part|mp4.ytdl"
image_files="jpg|jpeg|png|svg|ico|webp|heic|heif"
video_files="mp4|m4a|avi|mov|wmv|flv|mpeg|mpg|m4v|mkv|webm"
audio_files="aac|mp3|reapeaks|reapindex|wav|mp4.part|mp4.ytdl"

archive_files="tgz|.tar.gz|tar.bz2|tar.xz|tar.7z|tar.rar|tar.gz|tar.bz2|tar.xz|tar.7z|tar.rar|bak|zip|tar|gz|bz2|rar|7z|iso|dmg|pkg|apkg|deb|rpm|exe|msi|app|deb|rpm|exe|msi|app"
database_files="db|sqlite|sqlite3|sqlite2|sqlite2.db|sqlite3.db|sqlite2.db-journal|sqlite3.db-journal"
diagram_files="drawio|concept|excalidraw"
markup_files="md|xml"
apple_config_files="plist"
windows_files="dll|exe|msi|bat|cmd|ps1|reg|sys|inf|cab"
programming_files="py|js|jsx|ts|rb|php|cjs|sh|bash|zsh|fish"

# find_files_without - Search for files while excluding specific extensions, directories, and substrings
#
# This function searches for files in a directory tree while allowing fine-grained control
# over which types of files to exclude based on extensions, directories, and substrings.
# It supports filtering by file size and various output options.
#
# Arguments:
#   search_dir - Base directory to start search from (default: ".")
#   depth - Maximum directory depth to search (default: "2")
#   extensions - Additional file extensions to exclude (pipe-separated)
#   directories - Directory names to exclude (pipe-separated)
#   substrings - Substrings to exclude from filenames (pipe-separated)
#   min_size - Minimum file size filter
#   max_size - Maximum file size filter
#   filter_out_text_files - Whether to exclude common text files (default: true)
#   filter_out_package_files - Whether to exclude package management files (default: true)
#   filter_out_web_files - Whether to exclude web development files (default: true)
#   filter_out_media_files - Whether to exclude media files (default: true)
#   filter_out_image_files - Whether to exclude image files (default: true)
#   filter_out_video_files - Whether to exclude video files (default: true)
#   filter_out_audio_files - Whether to exclude audio files (default: true)
#   filter_out_archive_files - Whether to exclude archive files (default: true)
#   filter_out_database_files - Whether to exclude database files (default: true)
#   filter_out_config_files - Whether to exclude config files (default: true)
#   filter_out_diagram_files - Whether to exclude diagram files (default: true)
#   filter_out_markup_files - Whether to exclude markup files (default: true)
#   filter_out_apple_config_files - Whether to exclude Apple config files (default: true)
#   filter_out_windows_files - Whether to exclude Windows files (default: true)
#   filter_out_programming_files - Whether to exclude programming files (default: true)
#   ansi - Enable/disable ANSI colors in output (default: true)
#   print_screen - Print results to screen (default: true)
#   verbose - Enable verbose output (default: false)
#   force_create_tmp - Create temp directory without prompting (default: false)
#   step - Enable step-by-step execution (default: false)
#   separator - Output separator character, must be either \0 or \n (default: \0)
#
# Returns:
#   0 on success, 1 on failure
#
# Outputs:
#   List of found files, formatted using eza
#   Optionally writes results to a temp file if specified
find_files_without() {
    local script_dir="$(dirname "${BASH_SOURCE[0]}")"
    local temp_result_file="$script_dir/tmp/result.log"
    local temp_result_file_colored="$script_dir/tmp/result_colored.log"

    local search_dir="."  # Default to current directory
    local depth="2"  # Default depth
    local extensions=""
    local depth="2"
    local directories=""
    local substrings=""
    local min_size=""  # New variable for minimum file size
    local max_size=""  # New variable for maximum file size
    local filter_out_text_files="false"
    local filter_out_package_files="false"
    local filter_out_web_files="false"
    local filter_out_media_files="false"  # New option for media files
    local filter_out_image_files="false"  # New option for image files
    local filter_out_video_files="false"  # New option for video files
    local filter_out_audio_files="false"  # New option for audio files
    local filter_out_archive_files="false"
    local filter_out_database_files="false"
    local filter_out_config_files="false"  # New option for config files
    local filter_out_diagram_files="false"  # New option for diagram files
    local filter_out_markup_files="false"  # New option for markup files
    local filter_out_apple_config_files="false"  # New option for Apple config files
    local filter_out_windows_files="false"  # New option for Windows files
    local filter_out_programming_files="false"  # New option for programming files
    local ansi="true"
    local print_screen="true"  # New argument for printing to screen
    local verbose="false"  # New verbose option
    local force_create_tmp="false"  # New option to force create temp directories
    local step="false"  # New option for step-by-step execution
    local separator="\0"

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

    [[ "$step" == "true" ]] && read -p "Press Enter to continue with building the command..."

    # Build the command dynamically
    local cmd="fd -d $depth -t f --no-hidden"


    if [[ "$separator" == "\0" ]]; then
        cmd+=" --print0 . $search_dir"
    else
        cmd+=" . $search_dir"
    fi

    #[[ "$print_screen" == "false" ]] && cmd+=" > /dev/null"
    
    # Add size filters if specified
    [[ -n "$min_size" ]] && cmd+=" --size +${min_size}"
    [[ -n "$max_size" ]] && cmd+=" --size -${max_size}"
    
    if [[ -n "$extensions" ]]; then
        if [[ "$separator" == "\0" ]]; then
            cmd+=" | egrep -vz '\.(${extensions})(~)?$'"
        else
            cmd+=" | egrep -v '\.(${extensions})(~)?$'"
        fi
        #[[ "$print_screen" == "false" ]] && cmd+=" > /dev/null"
    fi
    
    if [[ -n "$directories" ]]; then
        if [[ "$separator" == "\0" ]]; then
            cmd+=" | egrep -vz '(${directories})'"
        else
            cmd+=" | egrep -v '(${directories})'"
        fi
        #[[ "$print_screen" == "false" ]] && cmd+=" > /dev/null"
    fi
    
    if [[ -n "$substrings" ]]; then
        if [[ "$separator" == "\0" ]]; then
            cmd+=" | egrep -vz '(${substrings})'"
        else
            cmd+=" | egrep -v '(${substrings})'"
        fi
        #[[ "$print_screen" == "false" ]] && cmd+=" > /dev/null"
    fi



    # Check if either output option is enabled
    if [[ "$print_screen" != "false" && -z "$temp_result_file" ]]; then
        echo "⚠️  Warning: No output destination specified. Please enable print_screen or provide temp_result_file." >&2
        return 1
    fi

    # Only print executing message if verbose is true
    [[ "$verbose" == "true" ]] && echo "executing: $cmd"
    
    [[ "$step" == "true" ]] && read -p "Press Enter to execute the command..."


    if ! result=$(eval "$cmd" | tr '\0' '\n' 2>/dev/null); then
        echo "❌ Error: Failed to execute command: $cmd" >&2
        return 1
    fi
    
    watch_result=$(echo "$result" | tr '\n' '¶')


    # Execute the command dynamically and store result
    if [[ -z "$result" ]]; then
        echo "❌ Error: Command execution failed." >&2
        return 1
    fi


    [[ "$step" == "true" ]] && read -p "Press Enter to handle output..."



    # Format result with eza and color control
    if [[ "$ansi" == "true" ]]; then
        final_result=$(echo "$result" | tr '\n' '\0' | xargs -0 eza --icons --long --grid --color=always)
    else
        final_result=$(echo "$result" | tr '\n' '\0' | xargs -0 eza --icons --long --grid --color=never)
    fi


    watch_final_result=$(echo "$final_result" | tr '\n' '¶')


    # Handle output based on settings
    if [[ "$print_screen" == "true" ]]; then
        echo "$final_result"
    fi
    
    if [[ -n "$temp_result_file" ]]; then
        echo "$result" > "$temp_result_file"
        echo "$final_result" > "$temp_result_file_colored"
    fi
}