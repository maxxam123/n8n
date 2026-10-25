package main

import (
	"bufio"
	"fmt"
	"io/fs"
	"os"
	"path/filepath"
	"strings"
	"text/template"
)

const (
	TemplatePoolDir = "../template-pool"
	ConfigPoolDir   = "../config-pool"
	OutputDir       = "../output-deployments"
)

type ParsedConfig struct {
	RawText string
	Vars    map[string]interface{}
}

func loadTxtConfig(configSubDir, txtFileName string) (ParsedConfig, error) {
	txtPath := filepath.Join(configSubDir, txtFileName)
	config := ParsedConfig{
		Vars: make(map[string]interface{}),
	}

	if _, err := os.Stat(txtPath); os.IsNotExist(err) {
		return config, nil
	}

	data, err := os.ReadFile(txtPath)
	if err != nil {
		return config, err
	}
	config.RawText = string(data)

	file, err := os.Open(txtPath)
	if err != nil {
		return config, err
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		if line == "" || strings.HasPrefix(line, "#") || strings.HasPrefix(line, "//") {
			continue
		}

		var separator string
		if strings.Contains(line, "=") {
			separator = "="
		} else if strings.Contains(line, ":") {
			separator = ":"
		} else {
			continue
		}

		if parts := strings.SplitN(line, separator, 2); len(parts) == 2 {
			key := strings.TrimSpace(parts[0])
			value := strings.TrimSpace(parts[1])
			value = strings.Trim(value, `"'`)
			config.Vars[key] = value
		}
	}

	return config, nil
}

func main() {
	fmt.Println("Starte Pipeline (.yaml Templates + .txt Configs)...")
	fmt.Println("==================================================")

	err := filepath.WalkDir(TemplatePoolDir, func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}

		if d.IsDir() && path != TemplatePoolDir {
			templateKey := filepath.Base(path)
			fmt.Printf("Verarbeite Ordner: %s\n", templateKey)

			yamlFiles, err := filepath.Glob(filepath.Join(path, "*.yaml"))
			if err != nil || len(yamlFiles) == 0 {
				return nil
			}

			var mainTemplatePath string
			for _, file := range yamlFiles {
				lowerName := strings.ToLower(filepath.Base(file))
				if strings.Contains(lowerName, "main") || strings.Contains(lowerName, "template") {
					mainTemplatePath = file
					break
				}
			}
			if mainTemplatePath == "" {
				mainTemplatePath = yamlFiles[0]
			}

			mainTemplateName := filepath.Base(mainTemplatePath)
			fmt.Printf("  -> Haupt-Template: %s\n", mainTemplateName)

			combinedData := make(map[string]interface{})
			configSubDir := filepath.Join(ConfigPoolDir, templateKey)

			// NEW APPROACH: Scan and read EVERY single .txt file in the folder 
			// regardless of its filename convention.
			txtFiles, _ := filepath.Glob(filepath.Join(configSubDir, "*.txt"))
			for _, txtPath := range txtFiles {
				txtFileName := filepath.Base(txtPath)
				baseNameWithoutExt := strings.TrimSuffix(txtFileName, filepath.Ext(txtFileName))

				configData, err := loadTxtConfig(configSubDir, txtFileName)
				if err != nil {
					return fmt.Errorf("Fehler beim Laden der Config %s: %w", txtFileName, err)
				}

				// Keep structured access if templates use {{.file_name.Vars.key}}
				cleanKey := strings.ReplaceAll(baseNameWithoutExt, "-", "_")
				combinedData[cleanKey] = configData

				// Flatten variables to top level for direct access like {{.key}}
				for k, v := range configData.Vars {
					combinedData[k] = v
				}
			}

			// Parse the template file
			tmpl, err := template.ParseFiles(mainTemplatePath)
			if err != nil {
				return fmt.Errorf("Fehler beim Parsen von %s: %w", mainTemplateName, err)
			}

			// Set up target directories and paths
			targetDirPath := filepath.Join(OutputDir, templateKey)
			if err := os.MkdirAll(targetDirPath, 0755); err != nil {
				return fmt.Errorf("Zielordner-Fehler: %w", err)
			}

			targetFilePath := filepath.Join(targetDirPath, mainTemplateName)
			outputFile, err := os.Create(targetFilePath)
			if err != nil {
				return fmt.Errorf("Zieldatei-Fehler: %w", err)
			}
			defer outputFile.Close()

			// Execute template evaluation
			err = tmpl.Execute(outputFile, combinedData)
			if err != nil {
				return fmt.Errorf("Rendering-Fehler für %s: %w", mainTemplateName, err)
			}

			fmt.Printf("  ✅ Erfolgreich generiert: %s\n", targetFilePath)
		}

		return nil
	})

	if err != nil {
		fmt.Printf("\n❌ Fehler: %v\n", err)
	} else {
		fmt.Println("\n🎉 Pipeline erfolgreich beendet!")
	}
}
