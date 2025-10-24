#!/usr/bin/env bash
# Copyright © 2025 Imre Toth <tothimre@gmail.com> - Proprietary Software. See LICENSE file for terms.

# filescan - A script to scan files in the current directory and print their contents
# with //begin and //end annotations

# Function to check if a file is binary
filescan_is_binary() {
  local file="$1"
  local binary_extensions=("jpg" "jpeg" "png" "gif" "mp3" "mp4" "zip" "tar" "gz" "pdf" "exe" "o" "so" "dylib" "dll")
  local max_file_size=1048576

  # Check file extension
  local extension="${file##*.}"
  for ext in "${binary_extensions[@]}"; do
    if [[ $extension == "$ext" ]]; then
      return 0 # Is binary
    fi
  done

  # Check file size
  local file_size=$(stat -c%s "$file" 2>/dev/null || stat -f%z "$file" 2>/dev/null)
  if [[ $? -ne 0 ]]; then
    echo "Error: Cannot determine file size for $file" >&2
    return 0 # Treat as binary
  fi

  if [[ $file_size -gt $max_file_size ]]; then
    return 0 # Treat as binary/too large
  fi

  # Use file command to detect binary
  if file "$file" | grep -q "text"; then
    return 1 # Not binary
  else
    return 0 # Is binary
  fi
}

# Function to check if a file should be ignored
filescan_should_ignore() {
  local file="$1"
  local ignore_list=("node_modules" ".git" "dist" ".DS_Store" "*.log")

  # Check against ignore list
  for pattern in "${ignore_list[@]}"; do
    if [[ $file == *"$pattern"* ]]; then
      return 0 # Should ignore
    fi
  done

  return 1 # Should not ignore
}

# Function to process a file
filescan_process_file() {
  local file="$1"
  local cwd="$2"
  local rel_path=$(realpath --relative-to="$cwd" "$file")

  # Check if file should be ignored
  if filescan_should_ignore "$file"; then
    echo "Ignoring: $rel_path" >&2
    return
  fi

  # Check if file is binary
  if filescan_is_binary "$file"; then
    echo "Skipping binary file: $rel_path" >&2
    return
  fi

  # Print file with annotations
  echo -e "\n//begin $rel_path"
  cat "$file"
  echo -e "\n//end $rel_path"
  echo "" # Add an empty line between files for better readability
}

filescan() {
  # Initialize variables
  local cwd=$(pwd)

  # Process arguments if provided
  local target_dir="."
  if [[ $# -gt 0 ]]; then
    target_dir="$1"
  fi

  echo "Scanning directory: $target_dir" >&2

  # Find and process all files
  find "$target_dir" -type f | while read -r file; do
    filescan_process_file "$file" "$cwd"
  done
}