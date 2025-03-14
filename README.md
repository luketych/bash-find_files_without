# find_files_with

A powerful command-line tool that helps you find files based on positive filters. Unlike traditional find/grep tools that exclude files, this tool starts with an empty set and only includes files that match your specified criteria.

## Requirements

- [fd](https://github.com/sharkdp/fd) - Modern alternative to `find`
- [eza](https://github.com/eza-community/eza) - Modern alternative to `ls`
- Bash 4.0+ (default on macOS with Homebrew)

## Installation

1. Clone this repository:
```bash
git clone <repository-url>
cd find_files_with
```

2. Make the script executable:
```bash
chmod +x find_files_with.sh
```

3. (Optional) Add to your PATH for global access:
```bash
ln -s "$(pwd)/find_files_with.sh" /usr/local/bin/find_files_with
```

## Usage

### Basic Usage

```bash
# Find all Python and JavaScript files
./find_files_with.sh extensions="py|js"

# Find all image files
./find_files_with.sh include_image_files=true

# Find files in specific directories
./find_files_with.sh directories="src|lib"

# Find files with specific substrings in their names
./find_files_with.sh substrings="test|spec"
```

### Advanced Usage

```bash
# Combine multiple filters
./find_files_with.sh include_programming_files=true directories="src" substrings="controller"

# Control search depth and show detailed output
./find_files_with.sh extensions="py" depth=3 long=true

# Filter by file size
./find_files_with.sh extensions="mp4|mov" min_size="100M" max_size="1G"

# Search for specific file types
./find_files_with.sh type="d" # Only directories
./find_files_with.sh type="l" # Only symlinks
./find_files_with.sh type="x" # Only executables
```

## Available Options

### File Type Groups

- `include_text_files` - Common text files (txt, md, log, etc.)
- `include_package_files` - Package management files (lock, toml, etc.)
- `include_web_files` - Web development files (html, css, js, etc.)
- `include_media_files` - All media files (images, audio, video)
- `include_image_files` - Image files (jpg, png, svg, etc.)
- `include_video_files` - Video files (mp4, avi, mkv, etc.)
- `include_audio_files` - Audio files (mp3, wav, ogg, etc.)
- `include_archive_files` - Archive files (zip, tar, gz, etc.)
- `include_database_files` - Database files (sql, db, sqlite, etc.)
- `include_config_files` - Configuration files (ini, yaml, etc.)
- `include_diagram_files` - Diagram files (drawio, vsdx, etc.)
- `include_markup_files` - Markup files (md, rst, tex, etc.)
- `include_apple_config_files` - Apple-specific files (plist, xcodeproj, etc.)
- `include_windows_files` - Windows-specific files (exe, dll, etc.)
- `include_programming_files` - Programming language files (py, js, cpp, etc.)

### General Options

- `search_dir` - Base directory to start search from (default: ".")
- `depth` - Maximum directory depth to search (default: 2)
- `extensions` - Custom file extensions to include (pipe-separated)
- `directories` - Directory names to include (pipe-separated)
- `substrings` - Substrings to match in filenames (pipe-separated)
- `min_size` - Minimum file size (e.g., "100K", "1M", "1G")
- `max_size` - Maximum file size
- `type` - File type filter: f (file), d (directory), l (symlink), x (executable)
- `long` - Enable long format output (default: false)
- `ansi` - Enable/disable ANSI colors in output (default: true)
- `verbose` - Enable verbose output (default: false)
- `step` - Enable step-by-step execution (default: false)

## Examples

```bash
# Find all source code files in the src directory
./find_files_with.sh include_programming_files=true directories="src"

# Find large media files
./find_files_with.sh include_media_files=true min_size="100M"

# Find configuration files with detailed output
./find_files_with.sh include_config_files=true long=true

# Find test files across multiple languages
./find_files_with.sh substrings="test|spec" include_programming_files=true

# Find all documentation
./find_files_with.sh include_markup_files=true include_text_files=true
```

## How It Works

The script uses a pipeline-based approach:

1. Uses `fd` to efficiently find files based on basic criteria (depth, type, size)
2. Applies positive filters using `egrep` to match extensions, directories, and substrings
3. Formats output using `eza` for a modern, colorized display

## Contributing

Feel free to open issues or submit pull requests with improvements.

## License

MIT License 