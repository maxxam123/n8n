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

type ConfigValues struct {
	Environment         string    `yaml:"environment"`
	Region              string    `yaml:"region"`
	OrganizationalUnits []OrgUnit `yaml:"organizationalUnits"`
}

func main() {
	valuesFile   := "../02_template/values.yaml"
	customerFile := "../05_modules/path"
	srcTemplate  := "../02_template/temp.yaml"

	// 1. Open customerFile and safely read the first line
	file02, err := os.Open(customerFile)
	if err != nil {
		fmt.Printf("Error opening customer file: %v\n", err)
		os.Exit(1)
	}
	
	scanner := bufio.NewScanner(file02)
	var firstLine string
	if scanner.Scan() {
		firstLine = scanner.Text()
	}
	file02.Close() // Close file stream immediately after scanning

	// Clean up leading/trailing spaces and wrapping quotes from the dynamic string
	dynamicPathValue := strings.TrimSpace(firstLine)
	dynamicPathValue = strings.Trim(dynamicPathValue, "\"")
	dynamicPathValue = strings.Trim(dynamicPathValue, "'")

	if dynamicPathValue == "" {
		fmt.Printf("Error: First line of %s is empty\n", customerFile)
		os.Exit(1)
	}

	// 2. DYNAMIC: Compute destination directory and file using the value from the file
	destDir  := filepath.Join("..", dynamicPathValue)
	destFile := filepath.Join(destDir, "temp.yaml")

	// 3. Process YAML values content mapping
	yamlFile, err := os.ReadFile(valuesFile)
	if err != nil {
		fmt.Printf("Error reading values file: %v\n", err)
		os.Exit(1)
	}

	var values ConfigValues
	err = yaml.Unmarshal(yamlFile, &values)
	if err != nil {
		fmt.Printf("Error parsing YAML config: %v\n", err)
		os.Exit(1)
	}

	// 4. Create output directory tree dynamically
	if err := os.MkdirAll(destDir, 0755); err != nil {
		fmt.Printf("Error creating directory %s: %v\n", destDir, err)
		os.Exit(1)
	}

	// 5. Build template context container
	baseName := filepath.Base(srcTemplate)
	tmpl, err := template.New(baseName).ParseFiles(srcTemplate)
	if err != nil {
		fmt.Printf("Error parsing template file: %v\n", err)
		os.Exit(1)
	}

	// 6. Instantiation of target artifact file descriptor
	outputFile, err := os.Create(destFile)
	if err != nil {
		fmt.Printf("Error creating destination file: %v\n", err)
		os.Exit(1)
	}
	defer outputFile.Close()

	// 7. Inject standard template variables directly into execution scope 
	err = tmpl.ExecuteTemplate(outputFile, baseName, values)
	if err != nil {
		fmt.Printf("Error executing template: %v\n", err)
		os.Exit(1)
	}

	fmt.Printf("Successfully templated %s inside dynamic directory %s\n", destFile, destDir)
}
