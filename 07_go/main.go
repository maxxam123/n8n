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
	targetFile := "terragrunt.hcl"
	outputDir := "newStruct"

	fmt.Printf("Scanning '%s' and replicating structure under '%s'...\n", sourceRoot, outputDir)

	err := filepath.WalkDir(sourceRoot, func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			return nil // Skip access errors
		}

		// Skip high-volume cache/git directories
		if d.IsDir() {
			if d.Name() == ".git" || d.Name() == ".terragrunt-cache" {
				return filepath.SkipDir
			}
			return nil
		}

		// Found a matching target file
		if d.Name() == targetFile {
			// 1. Calculate the new relative path destination
			// Example: "infrastructure-live/prod/vpc/terragrunt.hcl" -> "newStruct/infrastructure-live/prod/vpc/terragrunt.hcl"
			destinationPath := filepath.Join(outputDir, path)
			destinationDir := filepath.Dir(destinationPath)

			// 2. Recreate the parent directory tree inside newStruct
			err := os.MkdirAll(destinationDir, 0755)
			if err != nil {
				return fmt.Errorf("failed to create directory %s: %w", destinationDir, err)
			}

			// 3. Copy the file contents to the newly created path
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
