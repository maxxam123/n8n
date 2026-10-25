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

// ExcludeConfig maps the expected layout of your exclude.yaml file
type ExcludeConfig struct {
	ExcludeDirs []string `yaml:"exclude_dirs"`
}

func main() {

	if len(os.Args) < 2 {
		fmt.Println("Error: Missing directory name. Usage: go run main.go <dir_name>")
		return
	}

	// 2. Capture the value (e.g., "dev-eu-central")
	environmentName := os.Args[1]
	
	srcDir := "../template-pool"
	configDir := "../config-pool"
	dstDir := "../output-deployments"
	excludeFile := fmt.Sprintf("../exclude/%s/exclude.yaml", environmentName)

	// Load exclusion list before walking the directory tree
	exclusions, err := loadExclusions(excludeFile)
	if err != nil {
		fmt.Printf("Warning: Could not read exclusion file: %v. Proceeding without exclusions.\n", err)
	}

	fmt.Printf("Scanning files from '%s' using configs from '%s'...\n", srcDir, configDir)
	err = GenerateStructure(srcDir, configDir, dstDir, exclusions)
	if err != nil {
		fmt.Printf("Generation failed: %v\n", err)
		os.Exit(1)
	}
	fmt.Printf("Successfully generated structure inside '%s'!\n", dstDir)
}

// GenerateStructure walks srcDir, evaluates exclusions, finds paired configs, and outputs to dstDir
func GenerateStructure(srcDir, configDir, dstDir string, exclusions map[string]bool) error {
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

		// Check if the current relative path is matched in the exclusion configurations
		cleanRelPath := filepath.Clean(relPath)
		if exclusions[cleanRelPath] {
			if info.IsDir() {
				// Tells filepath.Walk to skip this directory and all its contents completely
				return filepath.SkipDir
			}
			// FIXED: Return nil to safely skip this specific file without breaking the walk loop
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
			configFile := filepath.Join(configDir, relPath)
			return renderTemplateWithMatchingConfig(path, configFile, targetPath, info.Mode())
		}

		// 3. Fallback for static files that don't need templating
		return copyStaticFile(path, targetPath, info.Mode())
	})
}

// loadExclusions reads the exclude config file and parses it into a fast lookup map
func loadExclusions(configPath string) (map[string]bool, error) {
	exclusionMap := make(map[string]bool)
	
	file, err := os.Open(configPath)
	if err != nil {
		return exclusionMap, err
	}
	defer file.Close()

	var conf ExcludeConfig
	decoder := yaml.NewDecoder(file)
	if err := decoder.Decode(&conf); err != nil {
		return exclusionMap, err
	}

	// Standardize path styles into the lookup map to prevent mismatching slashes
	for _, dir := range conf.ExcludeDirs {
		exclusionMap[filepath.Clean(dir)] = true
	}

	return exclusionMap, nil
}

func renderTemplateWithMatchingConfig(templateSrc, configSrc, dst string, mode os.FileMode) error {
	configData, err := loadConfigMap(configSrc)
	if err != nil {
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

	if err := tmpl.Execute(file, configData); err != nil {
		return fmt.Errorf("failed rendering template %s: %w", templateSrc, err)
	}

	return nil
}

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
