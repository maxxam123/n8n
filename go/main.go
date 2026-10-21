package main

import (
	"bufio"
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"text/template"

	"gopkg.in/yaml.v3"
)

type OrgUnit struct {
	ID   string `yaml:"id"`
	Name string `yaml:"name"`
}

type AWSAccount struct {
	Key      string `yaml:"key"`
	Name     string `yaml:"name"`
	Email    string `yaml:"email"`
	RoleName string `yaml:"roleName"`
	OuKey    string `yaml:"ouKey"`
}

type ConfigValues struct {
	Environment         string    `yaml:"environment"`
	Region              string    `yaml:"region"`
	Repo                string       `yaml:"repo"`
	OrganizationalUnits []OrgUnit `yaml:"organizationalUnits"`
    AwsAccounts         []AWSAccount `yaml:"awsAccounts"`
}

func main() {
	customerFile := "../05_modules/path"

	// ==========================================
	// 1. DYNAMIC STEP: Read 3 lines from customerFile
	// ==========================================
	file02, err := os.Open(customerFile)
	if err != nil {
		fmt.Printf("Error opening customer file: %v\n", err)
		os.Exit(1)
	}
	
	var lines []string
	scanner := bufio.NewScanner(file02)
	for scanner.Scan() {
		// Trim hidden padding whitespace and string quote characters instantly
		cleanedLine := strings.TrimSpace(scanner.Text())
		cleanedLine = strings.Trim(cleanedLine, "\"")
		cleanedLine = strings.Trim(cleanedLine, "'")
		if cleanedLine != "" {
			lines = append(lines, cleanedLine)
		}
	}
	file02.Close()

	// Ensure the file contains exactly what the project requires
	if len(lines) < 3 {
		fmt.Printf("Error: %s must contain at least 3 valid text line parameters (got %d)\n", customerFile, len(lines))
		os.Exit(1)
	}

	// Route the dynamic configurations from the read rows
	dynamicDestDir  := lines[0] // Line 1: e.g. "test-repo-02"
	dynamicValues   := lines[1] // Line 2: e.g. "../02_template/values.yaml"
	dynamicTemplate := lines[2] // Line 3: e.g. "../02_template/temp.yaml"

	// 2. Compute full safe directory paths relative to the execution engine point
	destDir  := dynamicPathOrName(dynamicDestDir)
	destFile := filepath.Join(destDir, filepath.Base(dynamicTemplate))

	// ==========================================
	// 3. Process Content Mappings & Executions
	// ==========================================
	yamlFile, err := os.ReadFile(dynamicValues)
	if err != nil {
		fmt.Printf("Error reading dynamic values file (%s): %v\n", dynamicValues, err)
		os.Exit(1)
	}

	var values ConfigValues
	err = yaml.Unmarshal(yamlFile, &values)
	if err != nil {
		fmt.Printf("Error parsing dynamic YAML config: %v\n", err)
		os.Exit(1)
	}

	if err := os.MkdirAll(destDir, 0755); err != nil {
		fmt.Printf("Error creating dynamic directory %s: %v\n", destDir, err)
		os.Exit(1)
	}

	baseName := filepath.Base(dynamicTemplate)
	tmpl, err := template.New(baseName).ParseFiles(dynamicTemplate)
	if err != nil {
		fmt.Printf("Error parsing dynamic template file (%s): %v\n", dynamicTemplate, err)
		os.Exit(1)
	}

	outputFile, err := os.Create(destFile)
	if err != nil {
		fmt.Printf("Error creating dynamic destination file: %v\n", err)
		os.Exit(1)
	}
	defer outputFile.Close()

	err = tmpl.ExecuteTemplate(outputFile, baseName, values)
	if err != nil {
		fmt.Printf("Error executing template mapping stack: %v\n", err)
		os.Exit(1)
	}

	fmt.Printf("Successfully templated %s inside dynamic directory %s\n", destFile, destDir)
}

// Helper to keep formatting clean if a path prefix rule was already written in line 1
func dynamicPathOrName(s string) string {
	s = strings.TrimPrefix(s, "../")
	return strings.TrimPrefix(s, "./")
}

