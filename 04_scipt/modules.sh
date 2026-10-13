#!/bin/bash

INPUT_FILE="03_trigger/modules"


# 1. Verification Guard: Ensure the dynamic source data exists
if [[ ! -f "$INPUT_FILE" ]]; then
    echo "❌ Error: Source file '$INPUT_FILE' not found."
    exit 1
fi

echo "🚀 Compiling dynamic repo paths from '$INPUT_FILE'..."

# 2. Extract specific arrays directly from the structured input lines
# Line 1: Top-level category layers
IFS=' ' read -r -a categories <<< "$(sed -n '1p' "$INPUT_FILE")"

# Line 2: Cloud Provider variants 
IFS=' ' read -r -a providers <<< "$(sed -n '2p' "$INPUT_FILE")"

# Line 3: Standard AWS Resource keys
IFS=' ' read -r -a aws_resources <<< "$(sed -n '3p' "$INPUT_FILE")"

# Line 4: Standard GCP Resource keys
IFS=' ' read -r -a gcp_resources <<< "$(sed -n '4p' "$INPUT_FILE")"

# Line 5: Raw AWS Module names
IFS=' ' read -r -a aws_modules <<< "$(sed -n '5p' "$INPUT_FILE")"

# Line 6: Raw GCP Module names
IFS=' ' read -r -a gcp_modules <<< "$(sed -n '6p' "$INPUT_FILE")"

# Dynamic Extraction: Read line 7 to get the exact workflow filename
WORKFLOW_FILENAME=$(sed -n '7p' "$INPUT_FILE" | tr -d '\r ' )


# 3. Provision Core Root Structure and clean CI/CD directory
WORKFLOW_DIR="${categories[0]}/workflows"
mkdir -p "$WORKFLOW_DIR"

# CRITICAL FIX: Delete any other files in this directory to guarantee ONLY test-repo-02.yaml remains
rm -f "$WORKFLOW_DIR"/*

# Create the single valid workflow file
touch "$WORKFLOW_DIR/${WORKFLOW_FILENAME}.yaml"


# 4. Provision '01-infra' Layer
# Process AWS infra tracks with sequence serial prefixes (01_, 02_, etc.)
for i in "${!aws_resources[@]}"; do
    prefix_num=$(printf "%02d" $((i + 1)))
    mkdir -p "${categories[1]}/${providers[0]}/${prefix_num}_${aws_resources[$i]}"
done

# Process GCP infra tracks with sequence serial prefixes
for i in "${!gcp_resources[@]}"; do
    prefix_num=$(printf "%02d" $((i + 1)))
    mkdir -p "${categories[1]}/${providers[1]}/${prefix_num}_${gcp_resources[$i]}"
done


# 5. Provision '02-modules' Layer
# Map out clean AWS modular abstraction folders
for mod in "${aws_modules[@]}"; do
    mkdir -p "${categories[2]}/${providers[0]}/$mod"
done

# Map out clean GCP modular abstraction folders
for mod in "${gcp_modules[@]}"; do
    mkdir -p "${categories[2]}/${providers[1]}/$mod"
done


# 6. Provision '03_apps' Layer
# Set up default baseline application hooks per cloud target
mkdir -p "${categories[3]}/${providers[0]}"
mkdir -p "${categories[3]}/${providers[1]}"


# -------------------------------------------------------------
# TARGETED LEAF-FOLDER PLACEHOLDER RUNNER
# -------------------------------------------------------------
# Sucht gezielt nach Ordnern, die keine Unterordner enthalten (Unterste Ebene)
for dir in "${categories[1]}" "${categories[2]}" "${categories[3]}"; do
    if [[ -d "$dir" ]]; then
        # Findet alle Verzeichnisse, die selbst keine Unterverzeichnisse besitzen
        find "$dir" -type d | while read -r target_dir; do
            # Überprüfung, ob der Ordner leer von weiteren Unterordnern ist
            if [[ -z "$(find "$target_dir" -mindepth 1 -type d)" ]]; then
                touch "$target_dir/test.txt"
            fi
        done
    fi
done


# 7. Print the resulting tree layout using standard tools
echo -e "\n✅ Success! Repository structure generated perfectly:\n"
if command -v tree &> /dev/null; then
    tree "${categories[0]}" "${categories[1]}" "${categories[2]}" "${categories[3]}"
else
    # Fallback to recursive find visualization if tree is not installed on system
    find . -maxdepth 5 -not -path '*/.*' | sort
fi

ls -la
ls -la ${categories[0]}
ls -la ${categories[1]}
ls -la ${categories[2]}
ls -la ${categories[3]}
