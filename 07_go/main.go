package main

import (
	"fmt"
	"io"
	"io/fs"
	"os"
	"path/filepath"
)

func main() {
	sourceRoot := "./infrastructure-live"
	outputDir  := "./newStruct"

	// Standardize names to ensure matching works perfectly
	cleanSource := filepath.Clean(sourceRoot)
	cleanOutput := filepath.Clean(outputDir)

	fmt.Printf("Scanning '%s' and replicating structure under '%s'...\n", cleanSource, cleanOutput)

	err := filepath.WalkDir(cleanSource, func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			return nil // Skip access errors gracefully
		}

		// 1. Handle Skip Directories up front
		if d.IsDir() {
			// Skip cache, git, and prevent infinite loop over our output folder
			if d.Name() == ".git" || d.Name() == ".terragrunt-cache" || path == cleanOutput {
				return filepath.SkipDir
			}
			// DO NOT return nil here. Let execution drop down so WalkDir reads files inside.
		}

		// 2. Process Files Only
		if !d.IsDir() {
			// Strip the root prefix so folders align directly inside newStruct
			relPath, err := filepath.Rel(cleanSource, path)
			if err != nil {
				return fmt.Errorf("failed to get relative path: %w", err)
			}

			destinationPath := filepath.Join(cleanOutput, relPath)
			destinationDir  := filepath.Dir(destinationPath)

			// Create the folders
			err = os.MkdirAll(destinationDir, 0755)
			if err != nil {
				return fmt.Errorf("failed to create directory %s: %w", destinationDir, err)
			}

			// Copy the file contents
			err = copyFile(path, destinationPath)
			if err != nil {
				return fmt.Errorf("failed to copy file to %s: %w", destinationPath, err)
			}

			fmt.Printf("Replicated: %s\n", destinationPath)
		}

		return nil
	})

	if err != nil {
		fmt.Printf("Error processing directories: %v\n", err)
		return
	}

	fmt.Println("Structure replication complete.")
}

func copyFile(src, dst string) error {
	sourceFile, err := os.Open(src)
	if err != nil {
		return err
	}
	defer sourceFile.Close()

	destinationFile, err := os.Create(dst)
	if err != nil {
		return err
	}
	defer destinationFile.Close()

	_, err = io.Copy(destinationFile, sourceFile)
	return err
}
