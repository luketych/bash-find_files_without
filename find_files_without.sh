#!/opt/homebrew/bin/bash


# Define extension groups using simple variables

text_files="md|txt|log|rst|doc|docx|pdf"
package_files="apkg|package.json|pyproject.toml|Cargo.toml|Pipfile|composer.json|requirements.txt"
config_files="properties|yaml|yml|toml|ini|conf|cfg|config|properties|settings|preferences|options|options.json|options.yaml|options.yml|options.toml"
web_files="html|css|js|jsx|ts|tsx|scss|sass"
media_files="aac|avif|aif|mp3.asd|mp3|reapeaks|reapindex|mp4|m4a|avi|mov|wmv|flv|mpeg|mpg|m4v|mkv|webm|gif|jpg|jpeg|png|svg|ico|webp|heic|heif|wav|mp4.part|mp4.ytdl"
archive_files="tgz|.tar.gz|tar.bz2|tar.xz|tar.7z|tar.rar|tar.gz|tar.bz2|tar.xz|tar.7z|tar.rar|bak|zip|tar|gz|bz2|rar|7z|iso|dmg|pkg|apkg|deb|rpm|exe|msi|app|deb|rpm|exe|msi|app"
database_files="db|sqlite|sqlite3|sqlite2|sqlite2.db|sqlite3.db|sqlite2.db-journal|sqlite3.db-journal"
diagram_files="drawio|concept|excalidraw"
markup_files="md|xml"
apple_config_files="plist"
windows_files="dll|exe|msi|bat|cmd|ps1|reg|sys|inf|cab"
programming_files="py|js|jsx|ts|rb|php|cjs|sh|bash|zsh|fish"

find_files_without() {
    local script_dir="$(dirname "${BASH_SOURCE[0]}")"
    local temp_result_file="$script_dir/tmp/result.log"

    local search_dir="."  # Default to current directory
    local dev_null="true"
    local depth="2"  # Default depth
    local extensions=""
    local depth="2"
    local directories=""
    local substrings=""
    local use_text_files="true"
    local use_package_files="true"
    local use_web_files="true"
    local use_media_files="true"  # New option for media files
    local use_archive_files="true"
    local use_database_files="true"
    local use_config_files="true"  # New option for config files
    local use_diagram_files="true"  # New option for diagram files
    local use_markup_files="true"  # New option for markup files
    local use_apple_config_files="true"  # New option for Apple config files
    local use_programming_files="true"  # New option for programming files
    local ansi="true"
    local print_screen="true"  # New argument for printing to screen
    local verbose="false"  # New verbose option
    local force_create_tmp="false"  # New option to force create temp directories
    local step="false"  # New option for step-by-step execution

    # Parse named arguments for backwards compatibility
    for arg in "$@"; do
        case "$arg" in
            search_dir=*) search_dir="${arg#*=}" ;;
            dev_null=*) dev_null="${arg#*=}" ;;
            depth=*) depth="${arg#*=}" ;;
	        extensions=*) extensions="${arg#*=}" ;;
            directories=*) directories="${arg#*=}" ;;
            substrings=*) substrings="${arg#*=}" ;;
            use_text_files=*) use_text_files="${arg#*=}" ;;
            use_package_files=*) use_package_files="${arg#*=}" ;;
            use_web_files=*) use_web_files="${arg#*=}" ;;
            use_media_files=*) use_media_files="${arg#*=}" ;;  # New case for media files
            use_archive_files=*) use_archive_files="${arg#*=}" ;;
            use_database_files=*) use_database_files="${arg#*=}" ;;
            use_config_files=*) use_config_files="${arg#*=}" ;;  # New case for config files
            use_diagram_files=*) use_diagram_files="${arg#*=}" ;;  # New case for diagram files
            use_markup_files=*) use_markup_files="${arg#*=}" ;;  # New case for markup files
            use_apple_config_files=*) use_apple_config_files="${arg#*=}" ;;  # New case for Apple config files
            use_programming_files=*) use_programming_files="${arg#*=}" ;;  # New case for programming files
            ansi=*) ansi="${arg#*=}" ;;
            print_screen=*) print_screen="${arg#*=}" ;;
            verbose=*) verbose="${arg#*=}" ;;
            temp_file=*) temp_result_file="${arg#*=}" ;;
            force_create_tmp=*) force_create_tmp="${arg#*=}" ;;
            step=*) step="${arg#*=}" ;;
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
    if [[ "$use_text_files" == "false" ]]; then
        [[ -n "$extensions" ]] && extensions="${extensions}|"
        extensions="${extensions}${text_files}"
    fi
    if [[ "$use_package_files" == "false" ]]; then
        [[ -n "$extensions" ]] && extensions="${extensions}|"
        extensions="${extensions}${package_files}"
    fi
    if [[ "$use_web_files" == "false" ]]; then
        [[ -n "$extensions" ]] && extensions="${extensions}|"
        extensions="${extensions}${web_files}"
    fi
    if [[ "$use_media_files" == "false" ]]; then
        [[ -n "$extensions" ]] && extensions="${extensions}|"
        extensions="${extensions}${media_files}"
    fi
    if [[ "$use_archive_files" == "false" ]]; then
        [[ -n "$extensions" ]] && extensions="${extensions}|"
        extensions="${extensions}${archive_files}"
    fi
    if [[ "$use_database_files" == "false" ]]; then
        [[ -n "$extensions" ]] && extensions="${extensions}|"
        extensions="${extensions}${database_files}"
    fi
    if [[ "$use_config_files" == "false" ]]; then
        [[ -n "$extensions" ]] && extensions="${extensions}|"
        extensions="${extensions}${config_files}"
    fi
    if [[ "$use_diagram_files" == "false" ]]; then
        [[ -n "$extensions" ]] && extensions="${extensions}|"
        extensions="${extensions}${diagram_files}"
    fi
    if [[ "$use_markup_files" == "false" ]]; then
        [[ -n "$extensions" ]] && extensions="${extensions}|"
        extensions="${extensions}${markup_files}"
    fi
    if [[ "$use_apple_config_files" == "false" ]]; then
        [[ -n "$extensions" ]] && extensions="${extensions}|"
        extensions="${extensions}${apple_config_files}"
    fi
    if [[ "$use_programming_files" == "false" ]]; then
        [[ -n "$extensions" ]] && extensions="${extensions}|"
        extensions="${extensions}${programming_files}"
    fi

    extensions="${extensions#|}" # Remove leading '|'

    [[ "$step" == "true" ]] && read -p "Press Enter to continue with building the command..."

    # Build the command dynamically
    local cmd="fd -d $depth -t f --no-hidden -0 . $search_dir"
    [[ -n "$extensions" ]] && cmd+=" | egrep -zv '\.(${extensions})(~)?$' 2>/dev/null"
    [[ -n "$directories" ]] && cmd+=" | egrep -zv '(${directories})/$1' 2>/dev/null"
    [[ -n "$substrings" ]] && cmd+=" | egrep -zv '(${substrings})' 2>/dev/null"

    # Add xargs and eza to the command with color control
    if [[ "$ansi" == "true" ]]; then
        cmd+=" | xargs -0 eza --icons --long --grid --color=always"
    else
        cmd+=" | xargs -0 eza --icons --long --grid --color=never"
    fi
    
    # Check if either output option is enabled
    if [[ "$print_screen" != "true" && -z "$temp_result_file" ]]; then
        echo "⚠️  Warning: No output destination specified. Please enable print_screen or provide temp_result_file." >&2
        return 1
    fi

    # Only print executing message if verbose is true
    [[ "$verbose" == "true" ]] && echo "executing: $cmd"
    
    [[ "$step" == "true" ]] && read -p "Press Enter to execute the command..."

    # Execute the command dynamically and store result
    if ! result=$(eval "$cmd"); then
        echo "❌ Error: Command execution failed." >&2
        return 1
    fi

    [[ "$step" == "true" ]] && read -p "Press Enter to handle output..."

    # Handle output based on settings
    if [[ "$print_screen" == "true" ]]; then
        echo "$result"
    fi
    
    if [[ -n "$temp_result_file" ]]; then
        echo "$result" > "$temp_result_file"
    fi
}