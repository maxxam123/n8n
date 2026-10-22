package main

import (
	"bufio"
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"text/template"

	"github-actions-file-manager/models"
	"gopkg.in/yaml.v3"
)

func main() {
	
	customerFile := "../05_modules/path"

	// ==========================================
	// 1. DYNAMIC STEP: Read user tokens from file
	// ==========================================
	file02, err := os.Open(customerFile)
	if err != nil {
		fmt.Printf("Error opening customer file: %v\n", err)
		os.Exit(1)
	}
	
	var lines []string
	scanner := bufio.NewScanner(file02)
	for scanner.Scan() {
		cleanedLine := strings.TrimSpace(scanner.Text())
		cleanedLine = strings.Trim(cleanedLine, "\"")
		cleanedLine = strings.Trim(cleanedLine, "'")
		if cleanedLine != "" {
			lines = append(lines, cleanedLine)
		}
	}
	file02.Close()

	if len(lines) < 5 {
		fmt.Printf("Error: %s must contain at least 5 lines (got %d)\n", customerFile, len(lines))
		os.Exit(1)
	}

	repoName        := lines[0] // e.g., "test-repo-01"
	moduleType      := lines[1] // e.g., "security"
	secondFileName  := lines[2] // e.g., "github-oidc-provider.hcl"
	thirdFileName   := lines[3] // e.g., "github-oidc-provider"
	Number          := lines[4] // e.g., "01"

	// ==========================================
	// 2. DEFAULT BASE SCHEMAS & TARGETS
	// ==========================================
	// Dynamic Value Source Files
	dynamicValues1 := fmt.Sprintf("../02_template/go-mdls/%s/%s/values.yaml", moduleType, thirdFileName)
	dynamicValues2 := fmt.Sprintf("../02_template/go-mdls/%s/%s/values-02.yaml", moduleType, thirdFileName)

	// File 1 Targets (Deployed under _global)
	dynamicTemplate1 := fmt.Sprintf("../02_template/go-mdls/%s/%s/terragrunt.hcl", moduleType, thirdFileName)
	destDir1         := filepath.Clean(fmt.Sprintf("../%s/managment/_global/%s/%s-%s", repoName, moduleType, thirdFileName, Number))
	destFile1        := filepath.Join(destDir1, filepath.Base(dynamicTemplate1))

	// File 2 Targets (Deployed under _envcommon)
	dynamicTemplate2 := fmt.Sprintf("../02_template/go-mdls/%s/%s/%s", moduleType, thirdFileName, secondFileName)
	destDir2         := filepath.Clean(fmt.Sprintf("../%s/managment/_envcommon/%s", repoName, moduleType))
	destFile2        := filepath.Join(destDir2, secondFileName)

	// ==========================================
	// 3. Process Content Mappings (File 1)
	// ==========================================
	yamlFile1, err := os.ReadFile(dynamicValues1)
	if err != nil {
		fmt.Printf("Error reading dynamic values file 1 (%s): %v\n", dynamicValues1, err)
		os.Exit(1)
	}

	var values1 models.ConfigValues
	err = yaml.Unmarshal(yamlFile1, &values1)
	if err != nil {
		fmt.Printf("Error parsing dynamic YAML config 1: %v\n", err)
		os.Exit(1)
	}

	// ==========================================
	// 3b. Process Content Mappings (File 2)
	// ==========================================
	yamlFile2, err := os.ReadFile(dynamicValues2)
	if err != nil {
		fmt.Printf("Error reading dynamic values file 2 (%s): %v\n", dynamicValues2, err)
		os.Exit(1)
	}

	var values2 models.ConfigValues
	err = yaml.Unmarshal(yamlFile2, &values2)
	if err != nil {
		fmt.Printf("Error parsing dynamic YAML config 2: %v\n", err)
		os.Exit(1)
	}

	// ==========================================
	// 4. EXECUTION 1: Template First File
	// ==========================================
	if err := os.MkdirAll(destDir1, 0755); err != nil {
		fmt.Printf("Error creating directory 1 %s: %v\n", destDir1, err)
		os.Exit(1)
	}

	baseName1 := filepath.Base(dynamicTemplate1)
	tmpl1, err := template.New(baseName1).ParseFiles(dynamicTemplate1)
	if err != nil {
		fmt.Printf("Error parsing template file 1 (%s): %v\n", dynamicTemplate1, err)
		os.Exit(1)
	}

	outputFile1, err := os.Create(destFile1)
	if err != nil {
		fmt.Printf("Error creating destination file 1: %v\n", err)
		os.Exit(1)
	}

	err = tmpl1.ExecuteTemplate(outputFile1, baseName1, values1)
	outputFile1.Close()
	if err != nil {
		fmt.Printf("Error executing template 1: %v\n", err)
		os.Exit(1)
	}
	fmt.Printf("Successfully templated file 1: %s\n", destFile1)

	// ==========================================
	// 5. EXECUTION 2: Template Second File
	// ==========================================
	if err := os.MkdirAll(destDir2, 0755); err != nil {
		fmt.Printf("Error creating directory 2 %s: %v\n", destDir2, err)
		os.Exit(1)
	}

	baseName2 := filepath.Base(dynamicTemplate2)
	tmpl2, err := template.New(baseName2).ParseFiles(dynamicTemplate2)
	if err != nil {
		fmt.Printf("Error parsing template file 2 (%s): %v\n", dynamicTemplate2, err)
		os.Exit(1)
	}

	outputFile2, err := os.Create(destFile2)
	if err != nil {
		fmt.Printf("Error creating destination file 2: %v\n", err)
		os.Exit(1)
	}

	// Updated to execute with values2 (from values-02.yaml)
	err = tmpl2.ExecuteTemplate(outputFile2, baseName2, values2)
	outputFile2.Close()
	if err != nil {
		fmt.Printf("Error executing template 2: %v\n", err)
		os.Exit(1)
	}
	fmt.Printf("Successfully templated file 2: %s\n", destFile2)
}
