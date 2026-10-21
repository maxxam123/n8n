package main

import (
	"fmt"
	"os"
	"path/filepath"
	"text/template"
	"gopkg.in/yaml.v3" // Make sure to run `go get gopkg.in/yaml.v3` in your terminal
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
	srcTemplate := "../02_template/temp.hcl"
	destDir     := "../test-repo-01"
	destFile    := filepath.Join(destDir, "temp.hcl")

	// 1. Read the yaml file bytes natively
	yamlFile, err := os.ReadFile(valuesFile)
	if err != nil {
		fmt.Printf("Error reading values file: %v\n", err)
		os.Exit(1)
	}

	// 2. Decode the structure directly into our struct object
	var values ConfigValues
	err = yaml.Unmarshal(yamlFile, &values)
	if err != nil {
		fmt.Printf("Error parsing YAML config structural map: %v\n", err)
		os.Exit(1)
	}

	// 3. Setup directory
	if err := os.MkdirAll(destDir, 0755); err != nil {
		fmt.Printf("Error creating directory: %v\n", err)
		os.Exit(1)
	}

	// 4. Parse the template configuration file
	tmpl, err := template.ParseFiles(srcTemplate)
	if err != nil {
		fmt.Printf("Error parsing template file: %v\n", err)
		os.Exit(1)
	}

	// 5. Open generation output file
	outputFile, err := os.Create(destFile)
	if err != nil {
		fmt.Printf("Error creating destination file: %v\n", err)
		os.Exit(1)
	}
	defer outputFile.Close()

	// 6. Inject the struct fields and render the values
	err = tmpl.Execute(outputFile, values)
	if err != nil {
		fmt.Printf("Error executing template: %v\n", err)
		os.Exit(1)
	}

	fmt.Printf("Successfully templated %s using variables from %s\n", destFile, valuesFile)
}

