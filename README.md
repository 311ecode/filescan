# filescan.sh - File Scanning Utility

## Overview

`filescan.sh` is a Bash script utility that scans files in a directory and prints their contents with structured annotations. It intelligently handles binary files and provides a clean output format suitable for documentation and code analysis.

## Installation

### Quick Setup

1. Download the script:
```bash
curl -O https://your-repo/filescan.sh
```

2. Source it in your shell profile for persistent access:
```bash
# Add to ~/.bashrc or ~/.zshrc
source /path/to/filescan.sh
```

3. Or source it temporarily in your current session:
```bash
source ./filescan.sh
```

**Note:** This script is designed to be sourced, not executed. You don't need to make it executable with `chmod +x`.

## Usage

Simply source the script and call the `filescan` function:

```bash
# Source the script
source ./filescan.sh

# Use the function directly
filescan                    # Scan current directory
filescan /path/to/directory # Scan specific directory
```

### Parameters

- **directory** (optional): The target directory to scan. If not provided, defaults to the current directory (`.`).

## Examples

### Basic Usage

```bash
# Source the script first
source ./filescan.sh

# Scan current directory
filescan

# Scan specific directory
filescan /path/to/project

# Scan and save to file
filescan > project_contents.txt
```

### Advanced Usage

```bash
# Scan multiple directories
for dir in src tests docs; do
  echo "=== Scanning $dir ===" >> output.txt
  filescan "$dir" >> output.txt
done

# Use in a pipeline
filescan src | grep -A 10 "//begin.*\.js$"

# Combine with other tools
filescan | pbcopy  # Copy to clipboard (macOS)
```

### Integration in Your Scripts

```bash
#!/usr/bin/env bash

# Source filescan
source /path/to/filescan.sh

# Use it in your workflow
echo "Analyzing project structure..."
filescan src > codebase_snapshot.txt

# You can also use helper functions
if filescan_is_binary "myfile.dat"; then
  echo "File is binary"
fi
```

## Features

### Smart File Filtering

The script automatically:
- **Ignores common directories and files**: `node_modules`, `.git`, `dist`, `.DS_Store`, and `*.log` files
- **Detects binary files**: Using file extensions, size checks, and the `file` command
- **Handles large files**: Files larger than 1MB are skipped to prevent performance issues

### Supported File Types

The script processes text files while skipping:
- **Binary extensions**: jpg, jpeg, png, gif, mp3, mp4, zip, tar, gz, pdf, exe, o, so, dylib, dll
- **Large files**: Files exceeding 1MB in size
- **Non-text files**: Files identified as binary by the `file` command

### Output Format

The script generates output with clear file pointer annotations. Each file is wrapped with begin/end markers that include the **relative path from your current working directory (cwd)**:

```
//begin relative/path/to/file.txt
[file content here]
//end relative/path/to/file.txt
```

**Important:** The paths in the annotations are always relative to your current working directory, not the target directory being scanned. This ensures consistent, predictable paths regardless of where you're scanning.

**Example:**
```bash
# If your cwd is /home/user/project
# And you run: filescan src
# The output will show:

//begin src/components/Button.js
[content]
//end src/components/Button.js

# Not just: components/Button.js
```

Each file is separated by empty lines for better readability.

## Available Functions

When you source the script, you gain access to these functions:

### `filescan [directory]`
Main function to scan and print file contents with relative path annotations.

**Path Behavior:** All file paths in the output are relative to your current working directory when `filescan` is called.

### `filescan_is_binary <file>`
Check if a file is binary. Returns 0 (true) if binary, 1 (false) if text.

```bash
if filescan_is_binary "myfile.txt"; then
  echo "Binary file"
else
  echo "Text file"
fi
```

### `filescan_should_ignore <file>`
Check if a file matches ignore patterns. Returns 0 (true) if should ignore.

```bash
if filescan_should_ignore "node_modules/package.json"; then
  echo "This file will be ignored"
fi
```

### `filescan_process_file <file> <cwd>`
Process a single file with annotations. Used internally but available for custom workflows.

**Parameters:**
- `file`: Absolute or relative path to the file
- `cwd`: Current working directory (used to calculate relative paths in output)

## Implementation Details

### File Detection Logic

1. **Extension Check**: Compares file extensions against known binary types
2. **Size Validation**: Skips files larger than 1MB (1048576 bytes)
3. **Content Analysis**: Uses the `file` command to detect text vs binary content
4. **Cross-Platform Support**: Compatible with both GNU and BSD `stat` commands

### Path Handling

- The script captures your current working directory when `filescan` is invoked
- All file paths in the `//begin` and `//end` annotations are calculated relative to this directory
- This ensures that the output is consistent and paths are meaningful in context

### Ignore Patterns

The script automatically ignores:
- Development directories (`node_modules`, `.git`, `dist`)
- System files (`.DS_Store`)
- Log files (`*.log`)

### Error Handling

- Gracefully handles files that cannot be accessed
- Provides informative error messages to stderr
- Continues processing other files when errors occur

## Common Use Cases

### 1. Code Documentation
```bash
source ./filescan.sh
filescan src > codebase_documentation.txt
```

### 2. Project Snapshot
```bash
source ./filescan.sh
filescan . > project_snapshot_$(date +%Y%m%d).txt
```

### 3. Code Review Preparation
```bash
source ./filescan.sh
filescan src tests | grep -v "test fixtures" > review.txt
```

### 4. AI/LLM Context Generation
```bash
source ./filescan.sh
filescan src > context_for_ai.txt
# Share this file with AI tools for better code understanding
# The relative paths make it easy for AI to understand your project structure
```

## Troubleshooting

### Function not found
Make sure you've sourced the script:
```bash
source ./filescan.sh
```

### Binary files not detected properly
The script uses the `file` command. Ensure it's installed:
```bash
# macOS (usually pre-installed)
which file

# Linux
sudo apt-get install file  # Debian/Ubuntu
sudo yum install file      # RedHat/CentOS
```

### Paths look wrong in output
Remember that paths are relative to your current working directory when you call `filescan`, not relative to the target directory. If you want cleaner paths, `cd` into the parent directory first:

```bash
# Instead of this from /home/user:
filescan project/src  # Shows: project/src/file.js

# Do this:
cd project
filescan src          # Shows: src/file.js
```

## Tips and Best Practices

1. **Add to your shell profile** for permanent access:
   ```bash
   echo "source ~/scripts/filescan.sh" >> ~/.bashrc
   ```

2. **Create aliases** for common operations:
   ```bash
   alias scan-src='filescan src'
   alias scan-all='filescan .'
   ```

3. **Combine with version control**:
   ```bash
   # Scan only tracked files
   git ls-files | while read f; do filescan_process_file "$f" "$(pwd)"; done
   ```

4. **Use with AI tools**: The structured output format with relative paths from your cwd is ideal for providing context to AI assistants and LLMs, making it clear how files relate to your project structure.

## License

Proprietary Software. See LICENSE file for terms.

Copyright © 2025 Imre Toth <tothimre@gmail.com>
