#!/bin/bash

# Define the source file
CONFIG_FILE="03_trigger/struc"

# Check if the configuration file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: $CONFIG_FILE not found!"
    exit 1
fi

# 1. Create the physical GitHub workflow directories and test file
mkdir -p .github/workflows
touch .github/workflows/test.txt

# 2. Read the configuration file into an array of lines, stripping Windows carriage returns (\r)
mapfile -t lines < <(tr -d '\r' < "$CONFIG_FILE")

# 3. Parse the first line to get the platforms (e.g., "aws" and "gcp")
read -r -a platforms <<< "${lines[0]}"

# 4. Loop through each platform to build the actual 01-infra directory structure
for i in "${!platforms[@]}"; do
    platform="${platforms[$i]}"
    
    # Target the line corresponding to the platform (offset by 1)
    components_line="${lines[$((i + 1))]}"
    
    # Read the components list into an array
    read -r -a components <<< "$components_line"
    
    # Loop through components and assign a 2-digit padded prefix
    index=1
    for component in "${components[@]}"; do
        padded_index=$(printf "%02d" "$index")
        
        # Build and create the physical folder path
        target_dir="01-infra/$platform/${padded_index}_$component"
        mkdir -p "$target_dir"
        touch "$target_dir/.gitkeep" # Ensure Git tracks empty directories
        
        ((index++))
    done
done

# 5. Dynamically construct and write the EXACT desired tree structure layout to 'project'
# Use literal tabs (\t) inside the heredoc structure
cat << 'EOF' > project
.github
	workflows
		test.txt
01-infra
EOF

# Append the infra components into the project file with matching tab indentation
for i in "${!platforms[@]}"; do
    platform="${platforms[$i]}"
    echo -e "\t$platform" >> project
    
    components_line="${lines[$((i + 1))]}"
    read -r -a components <<< "$components_line"
    
    index=1
    for component in "${components[@]}"; do
        padded_index=$(printf "%02d" "$index")
        echo -e "\t\t${padded_index}_$component" >> project
        ((index++))
done
done

echo "Successfully built folder structure and wrote structural tree layout to 'project'!"
echo "${{ env.GLOBAL_FIRST_LINE }}"
ls -la ${{ env.GLOBAL_FIRST_LINE }}
ls -la
ls -la .github
ls -la 01-infra
ls -la 01-infra/aws

