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

type ModuleValues struct {
	// Add other structural map fields from valuesFile02 here if needed
}

type CombinedData struct {
	Values  ConfigValues
	Modules ModuleValues
}

func main() {
	valuesFile   := "../02_template/values.yaml"
	valuesFile02 := "../05_modules/path"
	srcTemplate  := "../02_template/temp.yaml"

	// ==========================================
	// 1. DYNAMIC STEP: Read first line of 05_modules file
	// ==========================================
	f02, err := os.Open(valuesFile02)
	if err != nil {
		fmt.Printf("Error opening second values file: %v\n", err)
		os.Exit(1)
	}
	
	scanner := bufio.NewScanner(f02)
	var firstLine string
	if scanner.Scan() {
		firstLine = scanner.Text()
	}
	f02.Close() // Close the file stream cleanly right away

	// Clean up the line (remove trailing spaces, comment markers, or wrapping quotes)
	dynamicValue := strings.TrimSpace(firstLine)
	dynamicValue = strings.Trim(dynamicValue, "\"")
	dynamicValue = strings.Trim(dynamicValue, "'")

	if dynamicValue == "" {
		fmt.Printf("Error: First line of %s is empty\n", valuesFile02)
		os.Exit(1)
	}

	// 2. Build the destination routes using your dynamic string format rule
	destDir  := filepath.Join("..", dynamicValue)
	destFile := filepath.Join(destDir, "temp.yaml")

	// ==========================================
	// 3. Process Config Files & Templates
	// ==========================================
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

	// Read full file bytes for Unmarshaling the rest of valuesFile02 if needed
	yamlFile02, err := os.ReadFile(valuesFile02)
	if err == nil {
		var modules ModuleValues
		_ = yaml.Unmarshal(yamlFile02, &modules)
	}

	// Setup template data map payload
	templateData := CombinedData{
		Values: values,
	}

	// Create directory dynamically
	if err := os.MkdirAll(destDir, 0755); err != nil {
		fmt.Printf("Error creating directory %s: %v\n", err)
		os.Exit(1)
	}

	baseName := filepath.Base(srcTemplate)
	tmpl, err := template.New(baseName).ParseFiles(srcTemplate)
	if err != nil {
		fmt.Printf("Error parsing template file: %v\n", err)
		os.Exit(1)
	}

	outputFile, err := os.Create(destFile)
	if err != nil {
		fmt.Printf("Error creating destination file: %v\n", err)
		os.Exit(1)
	}
	defer outputFile.Close()

	err = tmpl.ExecuteTemplate(outputFile, baseName, templateData)
	if err != nil {
		fmt.Printf("Error executing template: %v\n", err)
		os.Exit(1)
	}

	fmt.Printf("Successfully templated %s into dynamic directory %s\n", destFile, destDir)
}



