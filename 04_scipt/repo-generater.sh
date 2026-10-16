#!/usr/bin/env bash
set -euo pipefail

CONFIG_FILE="config.txt"

# 1. Verify configuration file exists
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Error: Configuration file '$CONFIG_FILE' not found." >&2
    exit 1
fi

# 2. Extract values dynamically using sed and clean up line endings
REPO_NAME=$(sed -n 's/^# REPO_NAME:[[:space:]]*//p' "$CONFIG_FILE" | tr -d '\r')
STRUCT_STR=$(sed -n 's/^# REPO_STRUCTURE:[[:space:]]*//p' "$CONFIG_FILE" | tr -d '\r')
CONTENT_STR=$(sed -n 's/^# REPO_CONTENT:[[:space:]]*//p' "$CONFIG_FILE" | tr -d '\r')

# 3. Convert space-separated string values into native Bash arrays
read -r -a REPO_STRUCTURE <<< "$STRUCT_STR"
read -r -a REPO_CONTENT <<< "$CONTENT_STR"

# 4. Initialize target repository
mkdir -p "$REPO_NAME"
cd "$REPO_NAME"

# 5. Process directories and assemble paths
for dir in "${REPO_STRUCTURE[@]}"; do
    if [[ "$dir" == ".github" ]]; then
        # Handle targeted structural case for workflows
        mkdir -p ".github/workflows"
        touch ".github/workflows/.test.yaml"
    else
        # Standard cloud distribution directories
        for provider in "${REPO_CONTENT[@]}"; do
            mkdir -p "$dir/$provider"
            touch "$dir/$provider/.test.txt"
        done
    fi
done

echo "Successfully read config from '$CONFIG_FILE' and generated '$REPO_NAME'!"
ls -la $REPO_NAME
