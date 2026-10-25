package main

import (
	"fmt"
	"html/template"
	"io"
	"os"
	"path/filepath"
	"strings"

	"gopkg.in/yaml.v3"
)

func main() {
	srcDir := "../template-pool"
	configDir := "../config-pool"
	dstDir := "../output-deployments"

	fmt.Printf("Scanning files from '%s' using configs from '%s'...\n", srcDir, configDir)
	err := GenerateStructure(srcDir, configDir, dstDir)
	if err != nil {
		fmt.Printf("Generation failed: %v\n", err)
		os.Exit(1)
	}
	fmt.Printf("Successfully generated structure inside '%s'!\n", dstDir)
}

// GenerateStructure walks srcDir, finds paired configs in configDir, and outputs to dstDir
func GenerateStructure(srcDir, configDir, dstDir string) error {
	return filepath.Walk(srcDir, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}

		// Calculate relative path from source folder root
		relPath, err := filepath.Rel(srcDir, path)
		if err != nil {
			return err
		}

		if relPath == "." {
			return nil
		}

		// Map target output path
		targetPath := filepath.Join(dstDir, relPath)

		// 1. If folder, create the path downstream
		if info.IsDir() {
			return os.MkdirAll(targetPath, info.Mode())
		}

		// 2. Process template files ending in .yaml (or .tmpl if preferred)
		if strings.HasSuffix(info.Name(), ".yaml") || strings.HasSuffix(info.Name(), ".yml") {
			// Locate the corresponding config file in config-pool with the exact same relative structure
			configFile := filepath.Join(configDir, relPath)
			
			return renderTemplateWithMatchingConfig(path, configFile, targetPath, info.Mode())
		}

		// 3. Fallback for static files that don't need templating
		return copyStaticFile(path, targetPath, info.Mode())
	})
}

func renderTemplateWithMatchingConfig(templateSrc, configSrc, dst string, mode os.FileMode) error {
	// Dynamically load the YAML variables specifically for this template
	configData, err := loadConfigMap(configSrc)
	if err != nil {
		// Log warning or stop process depending on your preferred strictness
		fmt.Printf("Warning: Config file skipped or missing for %s: %v. Rendering with empty scope.\n", configSrc, err)
		configData = make(map[string]interface{})
	}

	tmpl, err := template.ParseFiles(templateSrc)
	if err != nil {
		return fmt.Errorf("failed parsing template %s: %w", templateSrc, err)
	}

	if err := os.MkdirAll(filepath.Dir(dst), 0755); err != nil {
		return err
	}

	file, err := os.OpenFile(dst, os.O_CREATE|os.O_WRONLY|os.O_TRUNC, mode)
	if err != nil {
		return fmt.Errorf("failed creating target file %s: %w", dst, err)
	}
	defer file.Close()

	// Execute with the uniquely loaded map data
	if err := tmpl.Execute(file, configData); err != nil {
		return fmt.Errorf("failed rendering template %s: %w", templateSrc, err)
	}

	return nil
}

// loadConfigMap unmarshals the matching YAML file into a data map dynamically
func loadConfigMap(configPath string) (map[string]interface{}, error) {
	file, err := os.Open(configPath)
	if err != nil {
		return nil, err
	}
	defer file.Close()

	var data map[string]interface{}
	decoder := yaml.NewDecoder(file)
	if err := decoder.Decode(&data); err != nil {
		return nil, err
	}

	return data, nil
}

func copyStaticFile(src, dst string, mode os.FileMode) error {
	srcFile, err := os.Open(src)
	if err != nil {
		return err
	}
	defer srcFile.Close()

	if err := os.MkdirAll(filepath.Dir(dst), 0755); err != nil {
		return err
	}

	dstFile, err := os.OpenFile(dst, os.O_CREATE|os.O_WRONLY|os.O_TRUNC, mode)
	if err != nil {
		return err
	}
	defer dstFile.Close()

	_, err = io.Copy(dstFile, srcFile)
	return err
}
