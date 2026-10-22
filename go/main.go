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
	RoleName            string       `yaml:"roleName"`
    ExpRole             string       `yaml:"expRole"`
    Org                 string       `yaml:"org"`
	RepoDev             string       `yaml:"repoDev"`
	RepoLive            string       `yaml:"repoLive"`
	OrganizationalUnits []OrgUnit    `yaml:"organizationalUnits"`
	AwsAccounts         []AWSAccount `yaml:"awsAccounts"`
	AwsServiceAccessPrincipals []string     `yaml:"awsServiceAccessPrincipals"`
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

	if len(lines) < 3 {
		fmt.Printf("Error: %s must contain at least 3 lines (got %d)\n", customerFile, len(lines))
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
	// Common Shared Values Source File
	dynamicValues := fmt.Sprintf("../02_template/go-mdls/%s/%s/values.yaml", moduleType, thirdFileName)

	// File 1 Targets (Deployed under _global)
	dynamicTemplate1 := fmt.Sprintf("../02_template/go-mdls/%s/%s/terragrunt.hcl", moduleType, thirdFileName)
	destDir1         := filepath.Clean(fmt.Sprintf("../%s/managment/_global/%s/%s-%s", repoName, moduleType, thirdFileName, Number)) // /%s    , secondFileName
	destFile1        := filepath.Join(destDir1, filepath.Base(dynamicTemplate1))

	dynamicTemplate2 := fmt.Sprintf("../02_template/go-mdls/%s/%s/%s", moduleType, thirdFileName, secondFileName) // /.hcl
	destDir2         := filepath.Clean(fmt.Sprintf("../%s/managment/_envcommon/%s", repoName, moduleType))
	destFile2        := filepath.Join(destDir2, secondFileName)

	// ==========================================
	// 3. Process Content Mappings Once
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

	err = tmpl1.ExecuteTemplate(outputFile1, baseName1, values)
	outputFile1.Close() // Close immediately to lock bytes to storage
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

	err = tmpl2.ExecuteTemplate(outputFile2, baseName2, values)
	outputFile2.Close()
	if err != nil {
		fmt.Printf("Error executing template 2: %v\n", err)
		os.Exit(1)
	}
	fmt.Printf("Successfully templated file 2: %s\n", destFile2)
}
