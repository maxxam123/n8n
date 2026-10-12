#!/bin/bash

# Define input files
GROUPS_FILE="02_template/aws/vpc/teraform/groups.txt"
USERS_FILE="02_template/aws/vpc/teraform/users.txt"

# Define output target file
OUTPUT_FILE="locals.tf"

# Check if input files exist before proceeding
if [[ ! -f "$GROUPS_FILE" || ! -f "$USERS_FILE" ]]; then
    echo "❌ Error: Required source files ($GROUPS_FILE and/or $USERS_FILE) are missing."
    exit 1
fi

# 1. Start writing the open locals block structure
cat << EOF > "$OUTPUT_FILE"
# Generated automatically by shell script automation
locals {
  iam_groups = [
EOF

# 2. Ingest and format Group list data from external file
# Sanitizes any existing syntax inconsistencies and ensures indent structure
while IFS= read -r line || [[ -n "$line" ]]; do
    # Remove trailing commas and clean up quotes/whitespace
    clean_line=$(echo "$line" | sed -E 's/[,[:space:]]*//g' | tr -d '"')
    if [[ -n "$clean_line" ]]; then
        echo "    \"$clean_line\"," >> "$OUTPUT_FILE"
    fi
done < "$GROUPS_FILE"

# 3. Transition block into directory mappings
cat << EOF >> "$OUTPUT_FILE"
  ]

  user_directory = {
EOF

# 4. Ingest and format user mapping layout from external file
# Preserves the map declarations and applies neat tabular formatting
while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ -n "$line" ]]; then
        echo "    $line" >> "$OUTPUT_FILE"
    fi
done < "$USERS_FILE"

# 5. Seal off the locals block and append the dynamic resource templates
cat << EOF >> "$OUTPUT_FILE"
  }
}
