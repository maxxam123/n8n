#!/bin/bash

# Define the source file
CONFIG_FILE="03_trigger/struc"

# Check if the configuration file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: $CONFIG_FILE not found!"
    exit 1
fi

# 1. Create the fixed GitHub workflow directories
mkdir -p .github/workflows
touch .github/workflows/test.txt

# 2. Read the configuration file into an array of lines, trimming carriage returns
mapfile -t lines < <(tr -d '\r' < "$CONFIG_FILE")

# 3. Parse the first line to get the platforms/groups (e.g., "aws" and "gcp")
read -r -a platforms <<< "${lines[0]}"

# 4. Loop through each platform to build the infra directory structure
for i in "${!platforms[@]}"; do
    platform="${platforms[$i]}"
    
    # Target the line corresponding to the platform (offset by 1)
    components_line="${lines[$((i + 1))]}"
    
    # Read the components list into an array
    read -r -a components <<< "$components_line"
    
    # Loop through the components and assign a 2-digit padded prefix
    index=1
    for component in "${components[@]}"; do
        # Format the index with a leading zero (e.g., 01, 02)
        padded_index=$(printf "%02d" "$index")
        
        # Build the exact target folder path
        target_dir="01-infra/$platform/${padded_index}_$component"
        
        # Create the directory structure seamlessly
        mkdir -p "$target_dir"
        
        # (Optional) Drop a .gitkeep file inside so Git tracks the empty folder
        touch "$target_dir/.gitkeep"
        
        ((index++))
    done
done

# 5. Dynamically construct and write the tree structure layout to the 'project' file
cat << 'EOF' > project
.github
	workflows
		test.txt
01-infra
EOF

for i in "${!platforms[@]}"; do
    platform="${platforms[$i]}"
    echo "	$platform" >> project
    
    components_line="${lines[$((i + 1))]}"
    read -r -a components <<< "$components_line"
    
    index=1
    for component in "${components[@]}"; do
        padded_index=$(printf "%02d" "$index")
        echo "		${padded_index}_$component" >> project
        ((index++))
    done
done

echo "Successfully built folder structure and wrote structural tree layout to 'project'!"

ls -la
ls -la project
ls -la project/01-infra
ls -la project/01-infra/aws

