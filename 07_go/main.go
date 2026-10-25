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

	// Standardize paths to ensure matching patterns work reliably
	cleanSource := filepath.Clean(sourceRoot)
	cleanOutput := filepath.Clean(outputDir)

	fmt.Printf("Scanning '%s' and replicating structure under '%s'...\n", cleanSource, cleanOutput)

	err := filepath.WalkDir(cleanSource, func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			return nil // Skip access errors gracefully
		}

		// Handle directories
		if d.IsDir() {
			// Prevent infinite loop if output directory is inside the source folder
			if d.Name() == ".git" || d.Name() == ".terragrunt-cache" || path == cleanOutput {
				return filepath.SkipDir
			}
			return nil // Keep walking deeper into this directory
		}

		// Handle files (this replaces the !d.IsDir check cleanly)
		// Extract relative path from sourceRoot (e.g., "infrastructure-live/dev/vpc/file.txt" -> "dev/vpc/file.txt")
		relPath, err := filepath.Rel(cleanSource, path)
		if err != nil {
			return fmt.Errorf("failed to calculate relative path for %s: %w", path, err)
		}

		// Map to the new target folder: "./newStruct/dev/vpc/file.txt"
		destinationPath := filepath.Join(cleanOutput, relPath)
		destinationDir  := filepath.Dir(destinationPath)

		// 1. Physically create the parent directory chain inside newStruct
		err = os.MkdirAll(destinationDir, 0755)
		if err != nil {
			return fmt.Errorf("failed to create directory %s: %w", destinationDir, err)
		}

		// 2. Stream and write the contents
		err = copyFile(path, destinationPath)
		if err != nil {
			return fmt.Errorf("failed to copy file to %s: %w", destinationPath, err)
		}

		fmt.Printf("Replicated: %s\n", destinationPath)
		return nil
	})

	if err != nil {
		fmt.Printf("Error processing directories: %v\n", err)
		return
	}

	fmt.Println("Structure replication complete.")
}

// Helper function to handle copying the actual file content
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
