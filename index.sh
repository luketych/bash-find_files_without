#!/opt/homebrew/bin/bash

# Source the main script
source "$(dirname "${BASH_SOURCE[0]}")/find_files_without.sh"

# Parse command line arguments and convert them to the format expected by find_files_without
args=()
while [[ $# -gt 0 ]]; do
    case "$1" in
        --verbose) args+=("verbose=true") ;;
        --print-screen) args+=("print_screen=true") ;;
        --ansi) args+=("ansi=true") ;;
        --depth) 
            if [[ -z "$2" || "$2" =~ ^- ]]; then
                echo "Error: --depth requires a value" >&2
                exit 1
            fi
            args+=("depth=$2")
            shift
            ;;
        --extensions)
            if [[ -z "$2" || "$2" =~ ^- ]]; then
                echo "Error: --extensions requires a value" >&2
                exit 1
            fi
            args+=("extensions=$2")
            shift
            ;;
        --directories)
            if [[ -z "$2" || "$2" =~ ^- ]]; then
                echo "Error: --directories requires a value" >&2
                exit 1
            fi
            args+=("directories=$2")
            shift
            ;;
        --substrings)
            if [[ -z "$2" || "$2" =~ ^- ]]; then
                echo "Error: --substrings requires a value" >&2
                exit 1
            fi
            args+=("substrings=$2")
            shift
            ;;
        --search-dir)
            if [[ -z "$2" || "$2" =~ ^- ]]; then
                echo "Error: --search-dir requires a value" >&2
                exit 1
            fi
            args+=("search_dir=$2")
            shift
            ;;
        --max-size)
            if [[ -z "$2" || "$2" =~ ^- ]]; then
                echo "Error: --max-size requires a value" >&2
                exit 1
            fi
            args+=("max_size=$2")
            shift
            ;;
        --min-size)
            if [[ -z "$2" || "$2" =~ ^- ]]; then
                echo "Error: --min-size requires a value" >&2
                exit 1
            fi
            args+=("min_size=$2")
            shift
            ;;
        --temp-file)
            if [[ -z "$2" || "$2" =~ ^- ]]; then
                echo "Error: --temp-file requires a value" >&2
                exit 1
            fi
            args+=("temp_file=$2")
            shift
            ;;
        --force-create-temp) args+=("force_create_tmp=true") ;;
        --step) args+=("step=true") ;;
        --no-text-files) args+=("filter_out_text_files=true") ;;
        --no-package-files) args+=("filter_out_package_files=true") ;;
        --no-web-files) args+=("filter_out_web_files=true") ;;
        --no-media-files) args+=("filter_out_media_files=true") ;;
        --no-image-files) args+=("filter_out_image_files=true") ;;
        --no-video-files) args+=("filter_out_video_files=true") ;;
        --no-audio-files) args+=("filter_out_audio_files=true") ;;
        --no-archive-files) args+=("filter_out_archive_files=true") ;;
        --no-database-files) args+=("filter_out_database_files=true") ;;
        --no-config-files) args+=("filter_out_config_files=true") ;;
        --no-diagram-files) args+=("filter_out_diagram_files=true") ;;
        --no-markup-files) args+=("filter_out_markup_files=true") ;;
        --no-apple-config-files) args+=("filter_out_apple_config_files=true") ;;
        --no-programming-files) args+=("filter_out_programming_files=true") ;;
        --no-windows-files) args+=("filter_out_windows_files=true") ;;
        --separator)
            if [[ -z "$2" || "$2" =~ ^- ]]; then
                echo "Error: --separator requires a value" >&2
                exit 1
            fi
            args+=("separator=$2")
            shift
            ;;
        --long) args+=("long=true") ;;
        --type)
            if [[ -z "$2" || "$2" =~ ^- ]]; then
                echo "Error: --type requires a value" >&2
                exit 1
            fi
            args+=("type=$2")
            shift
            ;;
        *)
            echo "Unknown option: $1" >&2
            echo "Use --help for usage information" >&2
            exit 1
            ;;
    esac
    shift
done

# Call find_files_without with converted arguments
find_files_without "${args[@]}" 