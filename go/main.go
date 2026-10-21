package main

import (
	"fmt"
	"io"
	"os"
	"path/filepath"
)

func main() {
	// 1. Define paths relative to the project root
	// Since GitHub Actions executes from the root, we can use relative paths
	srcFile := "02_template/temp.hcl"
	destDir := "test-repo-01"
	destFile := filepath.Join(destDir, "temp.hcl")

	// 2. Create the test-repo-01 directory if it doesn't exist
	// 0755 gives standard read/write/execute permissions
	err := os.MkdirAll(destDir, 0755)
	if err != nil {
		fmt.Printf("Error creating directory: %v\n", err)
		os.Exit(1)
	}
	fmt.Printf("Successfully created directory: %s\n", destDir)

	// 3. Open the source file for reading
	source, err := os.Open(srcFile)
	if err != nil {
		fmt.Printf("Error opening source file: %v\n", err)
		os.Exit(1)
	}
	defer source.Close()

	// 4. Create the target file for writing
	destination, err := os.Create(destFile)
	if err != nil {
		fmt.Printf("Error creating destination file: %v\n", err)
		os.Exit(1)
	}
	defer destination.Close()

	// 5. Copy the file contents
	_, err = io.Copy(destination, source)
	if err != nil {
		fmt.Printf("Error copying file: %v\n", err)
		os.Exit(1)
	}

	fmt.Printf("Successfully copied %s to %s\n", srcFile, destFile)
}
