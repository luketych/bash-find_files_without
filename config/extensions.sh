#!/opt/homebrew/bin/bash

# Extension group definitions
# Each variable defines a set of file extensions to filter

# Document and text files
export text_files="md|txt|log|rst|doc|docx|pdf"

# Package management files
export package_files="apkg|package.json|pyproject.toml|Cargo.toml|Pipfile|composer.json|requirements.txt"

# Configuration files
export config_files="properties|yaml|yml|toml|ini|conf|cfg|config|properties|settings|preferences|options|options.json|options.yaml|options.yml|options.toml"

# Web development files
export web_files="html|css|js|jsx|ts|tsx|scss|sass"

# Media files
export media_files="aac|avif|aif|mp3.asd|mp3|reapeaks|reapindex|mp4|m4a|avi|mov|wmv|flv|mpeg|mpg|m4v|mkv|webm|gif|jpg|jpeg|png|svg|ico|webp|heic|heif|wav|mp4.part|mp4.ytdl"

# Image files
export image_files="jpg|jpeg|png|svg|ico|webp|heic|heif"

# Video files
export video_files="mp4|m4a|avi|mov|wmv|flv|mpeg|mpg|m4v|mkv|webm"

# Audio files
export audio_files="aac|mp3|reapeaks|reapindex|wav|mp4.part|mp4.ytdl"

# Archive and compressed files
export archive_files="tgz|tar.gz|tar.bz2|tar.xz|tar.7z|tar.rar|tar.gz|tar.bz2|tar.xz|tar.7z|tar.rar|bak|zip|tar|gz|bz2|rar|7z|iso|dmg|pkg|apkg|deb|rpm|exe|msi|app|deb|rpm|exe|msi|app"

# Database files
export database_files="db|sqlite|sqlite3|sqlite2|sqlite2.db|sqlite3.db|sqlite2.db-journal|sqlite3.db-journal"

# Diagram files
export diagram_files="drawio|concept|excalidraw"

# Markup files
export markup_files="md|xml"

# Apple specific files
export apple_config_files="plist"

# Windows specific files
export windows_files="dll|exe|msi|bat|cmd|ps1|reg|sys|inf|cab"

# Programming language files
export programming_files="py|js|jsx|ts|rb|php|cjs|sh|bash|zsh|fish" 