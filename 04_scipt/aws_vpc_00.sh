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

echo "Hello, World!"
              # git clone https://github.com/maxxam123/n8n-in.git
              ls -la
              pwd
              first_line=$(sed -n '2{p;q;}' 03_trigger/aws/01_vpc)
              second_line=$(sed -n '1{p;q;}' 03_trigger/aws/01_vpc)
              
              NEW_VAR="aws_vpc_${first_line}.yaml"
              touch ${second_line}/.github/workflows/"$NEW_VAR"
              cp 02_template/aws/vpc/pipeline/pipeline.yaml ${second_line}/.github/workflows/"$NEW_VAR"
              # sed -i "s/VAR_2/$third_line/g" n8n-in/.github/workflows/"$NEW_VAR"
              # sed -i "s/VAR_1/$second_line/g" n8n-in/.github/workflows/"$NEW_VAR"

              NEW_VAR_2="${first_line}_aws_vpc"
              mkdir ${second_line}/01-infra/aws/01_vpc/"$NEW_VAR_2"
              ls -la ${second_line}/01-infra/aws/01_vpc
              cp locals.tf ${second_line}/01-infra/aws/01_vpc/"$NEW_VAR_2"/locals.tf
              
              cp 02_template/aws/vpc/terraform/03_main.tf ${second_line}/01-infra/aws/01_vpc/"$NEW_VAR_2"/main.tf

              cp 02_template/aws/vpc/terraform/04_provider.tf ${second_line}/01-infra/aws/01_vpc/"$NEW_VAR_2"/provider.tf

              ls -la
              ls -la ${second_line}
              ls -la ${second_line}/01-infra/aws/01_vpc/$NEW_VAR_2
