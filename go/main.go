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
	// 1. DYNAMIC STEP: Read lines from customerFile
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

	// Ensure the file contains enough lines for both operations
	if len(lines) < 5 {
		fmt.Printf("Error: %s must contain at least 5 valid text line parameters (got %d)\n", customerFile, len(lines))
		os.Exit(1)
	}

	// ==========================================
	// 2. Read Common Configuration Values Once
	// ==========================================
	dynamicValues := lines[1] // Line 2: e.g. "../02_template/values.yaml"

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

	// ==========================================
	// 3. EXECUTION 1: Template First File
	// ==========================================
	dynamicDestDir  := lines[0] // Line 1: e.g. "test-repo-02"
	dynamicTemplate := lines[2] // Line 3: e.g. "../02_template/temp.yaml"

	destDir  := dynamicPathOrName(dynamicDestDir)
	destFile := filepath.Join(destDir, filepath.Base(dynamicTemplate))

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

	err = tmpl.ExecuteTemplate(outputFile, baseName, values)
	outputFile.Close() // Close immediately to lock bytes to storage
	if err != nil {
		fmt.Printf("Error executing template 1: %v\n", err)
		os.Exit(1)
	}
	fmt.Printf("Successfully templated file 1: %s\n", destFile)

	// ==========================================
	// 4. EXECUTION 2: Template Second File
	// ==========================================
	dynamicDestDir01  := lines[5] // Line 4: Explicit alternate directory target
	dynamicTemplate02 := lines[6] // Line 5: Explicit alternate blueprint configuration file

	destDir01  := dynamicPathOrName(dynamicDestDir01)
	destFile02 := filepath.Join(destDir01, filepath.Base(dynamicTemplate02))

	if err := os.MkdirAll(destDir01, 0755); err != nil {
		fmt.Printf("Error creating directory %s: %v\n", destDir01, err)
		os.Exit(1)
	}

	baseName02 := filepath.Base(dynamicTemplate02)
	tmpl02, err := template.New(baseName02).ParseFiles(dynamicTemplate02)
	if err != nil {
		fmt.Printf("Error parsing second template file (%s): %v\n", dynamicTemplate02, err)
		os.Exit(1)
	}

	outputFile02, err := os.Create(destFile02)
	if err != nil {
		fmt.Printf("Error creating second destination file: %v\n", err)
		os.Exit(1)
	}

	err = tmpl02.ExecuteTemplate(outputFile02, baseName02, values)
	outputFile02.Close()
	if err != nil {
		fmt.Printf("Error executing second template mapping: %v\n", err)
		os.Exit(1)
	}
	fmt.Printf("Successfully templated file 2: %s\n", destFile02)
}

func dynamicPathOrName(s string) string {
	s = strings.TrimPrefix(s, "../")
	s = strings.TrimPrefix(s, "./")
	return s
}


