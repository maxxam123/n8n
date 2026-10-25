package main

import (
	"fmt"
	"io"
	"os"
	"path/filepath"
)

// CopyDirectory replicates the entire directory structure and copies all files.
func CopyDirectory(srcDir, dstDir string) error {
	srcDir = filepath.Clean(srcDir)
	dstDir = filepath.Clean(dstDir)

	return filepath.WalkDir(srcDir, func(path string, d os.DirEntry, err error) error {
		if err != nil {
			return err
		}

		// Calculate relative path from the template pool root
		relPath, err := filepath.Rel(srcDir, path)
		if err != nil {
			return fmt.Errorf("failed to get relative path: %w", err)
		}

		// Construct the destination path inside output-deployments
		targetPath := filepath.Join(dstDir, relPath)

		if d.IsDir() {
			info, err := d.Info()
			if err != nil {
				return err
			}
			// Reproduce the directory structure with matching permissions
			return os.MkdirAll(targetPath, info.Mode())
		}

		// Reproduce the file structure
		return copyFile(path, targetPath)
	})
}

// copyFile copies content and permissions from src to dst.
func copyFile(src, dst string) error {
	// Ensure the parent directory tree exists before creating the file
	if err := os.MkdirAll(filepath.Dir(dst), 0755); err != nil {
		return err
	}

	srcFile, err := os.Open(src)
	if err != nil {
		return err
	}
	defer srcFile.Close()

	srcInfo, err := srcFile.Stat()
	if err != nil {
		return err
	}

	dstFile, err := os.OpenFile(dst, os.O_CREATE|os.O_WRONLY|os.O_TRUNC, srcInfo.Mode())
	if err != nil {
		return err
	}
	defer dstFile.Close()

	_, err = io.Copy(dstFile, srcFile)
	return err
}

func main() {
	// Set your target input and output paths
	source := "../template-pool"
	destination := "../output-deployments"

	fmt.Printf("Reproducing structure from %s to %s...\n", source, destination)
	if err := CopyDirectory(source, destination); err != nil {
		fmt.Printf("Deployment error: %v\n", err)
		os.Exit(1)
	}
	fmt.Println("Deployment structure successfully reproduced!")
}
