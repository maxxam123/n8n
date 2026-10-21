package main

import (
	"bufio"
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"text/template"
)

func main() {
	// 1. Define paths relative to the 'go' subdirectory execution point
	valuesFile  := "../02_template/values.yaml"
	srcTemplate := "../02_template/temp.hcl"
	destDir     := "../test-repo-01"
	destFile    := filepath.Join(destDir, "temp.hcl")

	// 2. Parse values from temp-02.hcl into a map
	values, err := parseHclValues(valuesFile)
	if err != nil {
		fmt.Printf("Error reading values file: %v\n", err)
		os.Exit(1)
	}

	// 3. Create the destination directory if it doesn't exist
	err = os.MkdirAll(destDir, 0755)
	if err != nil {
		fmt.Printf("Error creating directory: %v\n", err)
		os.Exit(1)
	}

	// 4. Parse the template file
	tmpl, err := template.ParseFiles(srcTemplate)
	if err != nil {
		fmt.Printf("Error parsing template file: %v\n", err)
		os.Exit(1)
	}

	// 5. Create the output file
	outputFile, err := os.Create(destFile)
	if err != nil {
		fmt.Printf("Error creating destination file: %v\n", err)
		os.Exit(1)
	}
	defer outputFile.Close()

	// 6. Execute template engine using parsed map values
	err = tmpl.Execute(outputFile, values)
	if err != nil {
		fmt.Printf("Error executing template: %v\n", err)
		os.Exit(1)
	}

	fmt.Printf("Successfully templated %s using variables from %s\n", destFile, valuesFile)
}

// Helper function to read a basic key = "value" file into a map[string]string
func parseHclValues(filename string) (map[string]string, error) {
	file, err := os.Open(filename)
	if err != nil {
		return nil, err
	}
	defer file.Close()

	values := make(map[string]string)
	scanner := bufio.NewScanner(file)

	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		// Skip empty lines or comments
		if line == "" || strings.HasPrefix(line, "#") || strings.HasPrefix(line, "//") {
			continue
		}

		// Split lines structured like: key = "value"
		parts := strings.SplitN(line, "=", 2)
		if len(parts) == 2 {
			key := strings.TrimSpace(parts[0])
			val := strings.TrimSpace(parts[1])
			// Strip wrapping quotes around the value string
			val = strings.Trim(val, "\"")
			values[key] = val
		}
	}

	return values, scanner.Err()
}
