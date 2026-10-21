package main

import (
	"fmt"
	"os"
	"path/filepath"
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
	valuesFile  := "../02_template/values.yaml"
	srcTemplate := "../02_template/temp.yaml"
	destDir     := "../test-repo-02"
	destFile    := filepath.Join(destDir, "temp.yaml")

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

	if err := os.MkdirAll(destDir, 0755); err != nil {
		fmt.Printf("Error creating directory: %v\n", err)
		os.Exit(1)
	}

	// 5. FIXED: Use template.New with the exact file base name to initialize correct execution context scope
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

	// 7. FIXED: Explicitly use ExecuteTemplate to guarantee the engine matches your baseName layout
	err = tmpl.ExecuteTemplate(outputFile, baseName, values)
	if err != nil {
		fmt.Printf("Error executing template: %v\n", err)
		os.Exit(1)
	}

	fmt.Printf("Successfully templated %s using variables from %s\n", destFile, valuesFile)
}


