#!/bin/bash

# Define files
INPUT_FILE="02_template/aws/vpc/terraform/groups.txt"
OUTPUT_FILE="locals.tf"

# Check if input file exists
if [[ ! -f "$INPUT_FILE" ]]; then
    echo "❌ Error: Source file '$INPUT_FILE' not found."
    exit 1
fi

# 1. Start writing the open HCL block syntax
cat << EOF > "$OUTPUT_FILE"
# locals.tf
locals {
  # Map of VPC configurations
  vpc_directory = {
EOF

while read -r env cidr team critical || [[ -n "$env" ]]; do
    # Skip empty lines or comment lines
    if [[ -z "$env" || "$env" =~ ^# ]]; then
        continue
    fi

    # Append the structured map block to the output file
    cat << EOF >> "$OUTPUT_FILE"
    "$env" = {
      cidr_block = "$cidr"
      team       = "$team"
      critical   = $critical
    }
EOF
done < "$INPUT_FILE"

# 3. Seal the closing HCL blocks safely
cat << EOF >> "$OUTPUT_FILE"
  }
}
EOF
