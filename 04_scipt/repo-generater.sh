#!/usr/bin/env bash
set -euo pipefail

CONFIG_FILE="03_trigger/repo-generater"

# 1. Verify input file exists
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Error: Configuration file '$CONFIG_FILE' not found." >&2
    exit 1
fi

# 2. Read lines efficiently into an array and strip carriage returns (\r)
mapfile -t lines < <(tr -d '\r' < "$CONFIG_FILE")

# 3. Map line arrays to clean structural elements
REPO_NAME="${lines[0]}"
read -r -a REPO_STRUCTURE <<< "${lines[1]}"
read -r -a REPO_CONTENT <<< "${lines[2]}"

# 4. Generate directory architectures
mkdir -p "$REPO_NAME"
cd "$REPO_NAME"

for dir in "${REPO_STRUCTURE[@]}"; do
    if [[ "$dir" == ".github" ]]; then
        # Create GitHub specific layout
        mkdir -p ".github/workflows"
        touch ".github/workflows/.test.yaml"
    else
        # Build cloud environment combinations
        for provider in "${REPO_CONTENT[@]}"; do
            mkdir -p "$dir/$provider"
            touch "$dir/$provider/.test.txt"
        done
    fi
done

echo "Successfully parsed 3-line format and generated '$REPO_NAME' structure."
ls -la 
