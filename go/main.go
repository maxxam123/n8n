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
	Environment         string       `yaml:"environment"`
	Region              string       `yaml:"region"`
	Repo                string       `yaml:"repo"`
	OrganizationalUnits []OrgUnit    `yaml:"organizationalUnits"`
	AwsAccounts         []AWSAccount `yaml:"awsAccounts"`
}

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

	if len(lines) < 2 {
		fmt.Printf("Error: %s must contain at least 2 lines (got %d)\n", customerFile, len(lines))
		os.Exit(1)
	}

	// Extract the only two dynamic fields
	repoName   := lines[0] // e.g., "test-repo-01"
	moduleType := lines[1] // e.g., "security"

	// ==========================================
	// 2. DEFAULT SCHEMAS (Hardcoded inside Go)
	// ==========================================
	// Generates: "../test-repo-01/managment/_global/security"
	dynamicDestDir := fmt.Sprintf("../%s/managment/_global/%s", repoName, moduleType)
	
	// Generates: "../02_template/go-mdls/security/values.yaml"
	dynamicValues := fmt.Sprintf("../02_template/go-mdls/%s/values.yaml", moduleType)
	
	// Generates: "../02_template/go-mdls/security/terragrunt.hcl"
	dynamicTemplate := fmt.Sprintf("../02_template/go-mdls/%s/terragrunt.hcl", moduleType)

	// Clean destination directory path structure
	destDir  := filepath.Clean(dynamicDestDir)
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
