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
		cleanedLine := strings.TrimSpace(scanner.Text())
		cleanedLine = strings.Trim(cleanedLine, "\"")
		cleanedLine = strings.Trim(cleanedLine, "'")
		if cleanedLine != "" {
			lines = append(lines, cleanedLine)
		}
	}
	file02.Close()

	if len(lines) < 3 {
		fmt.Printf("Error: %s must contain at least 3 valid text line parameters (got %d)\n", customerFile, len(lines))
		os.Exit(1)
	}

	// Route configurations from file rows
	dynamicDestDir  := lines[0] // Line 1: e.g. "test-repo-02"
	dynamicValues   := lines[1] // Line 2: e.g. "../02_template/values.yaml"
	dynamicTemplate := lines[2] // Line 3: e.g. "../02_template/temp.yaml"

	// Compute base paths without directory traversals
	destDir  := dynamicPathOrName(dynamicDestDir)
	destFile := filepath.Join(destDir, filepath.Base(dynamicTemplate))

	// ==========================================
	// 2. Read Common Configuration Values Once
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

	// Create local destination directory tree
	if err := os.MkdirAll(destDir, 0755); err != nil {
		fmt.Printf("Error creating dynamic directory %s: %v\n", destDir, err)
		os.Exit(1)
	}

	// ==========================================
	// 3. EXECUTION 1: Template First File
	// ==========================================
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
	outputFile.Close() // Close immediately to avoid descriptor leaks
	if err != nil {
		fmt.Printf("Error executing template 1 mapping stack: %v\n", err)
		os.Exit(1)
	}
	fmt.Printf("Successfully templated %s inside directory %s\n", destFile, destDir)

	// ==========================================
	// 4. EXECUTION 2: Template Second File
	// ==========================================
	// Explicit assignments using your rules:
	dynamicDestDir01  := lines[0]
	dynamicTemplate02 := lines[2]

	destDir01  := dynamicPathOrName(dynamicDestDir01)
	
	// Create another distinct file name based on your second file pattern setup
	// Here we add an "_02" extension suffix to separate it from file 1
	ext := filepath.Ext(dynamicTemplate02)
	baseWithoutExt := strings.TrimSuffix(filepath.Base(dynamicTemplate02), ext)
	destFile02 := filepath.Join(destDir01, baseWithoutExt+"_02"+ext)

	baseName02 := filepath.Base(dynamicTemplate02)
	tmpl02, err := template.New(baseName02).ParseFiles(dynamicTemplate02)
	if err != nil {
		fmt.Printf("Error parsing second dynamic template file (%s): %v\n", dynamicTemplate02, err)
		os.Exit(1)
	}

	outputFile02, err := os.Create(destFile02)
	if err != nil {
		fmt.Printf("Error creating second dynamic destination file: %v\n", err)
		os.Exit(1)
	}

	err = tmpl02.ExecuteTemplate(outputFile02, baseName02, values)
	outputFile02.Close()
	if err != nil {
		fmt.Printf("Error executing second template mapping stack: %v\n", err)
		os.Exit(1)
	}
	fmt.Printf("Successfully templated second file %s inside directory %s\n", destFile02, destDir01)
}

func dynamicPathOrName(s string) string {
	s = strings.TrimPrefix(s, "../")
	s = strings.TrimPrefix(s, "./")
	return s
}


