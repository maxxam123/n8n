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
		if parts := strings.SplitN(line, "=", 2); len(parts) == 2 {
			key := strings.TrimSpace(parts[0])
			value := strings.TrimSpace(parts[1]) // KORREKTUR: Nutzt jetzt Index 1
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

			// WICHTIG: missingkey=error wirft einen echten Fehler statt <no value>
			tmplGroup := template.New(templateKey).Option("missingkey=error")
			combinedData := make(map[string]interface{})

			for _, yamlPath := range yamlFiles {
				tName := filepath.Base(yamlPath)

				yamlData, err := os.ReadFile(yamlPath)
				if err != nil {
					return fmt.Errorf("Fehler beim Lesen des Templates %s: %w", tName, err)
				}
				_, err = tmplGroup.New(tName).Parse(string(yamlData))
				if err != nil {
					return fmt.Errorf("Fehler beim Parsen des Templates %s: %w", tName, err)
				}

				baseNameWithoutExt := strings.TrimSuffix(tName, filepath.Ext(tName))
				txtFileName := baseNameWithoutExt + ".txt"
				configSubDir := filepath.Join(ConfigPoolDir, templateKey)

				configData, err := loadTxtConfig(configSubDir, txtFileName)
				if err != nil {
					return fmt.Errorf("Fehler beim Laden der Config %s: %w", txtFileName, err)
				}

				cleanKey := strings.ReplaceAll(baseNameWithoutExt, "-", "_")
				combinedData[cleanKey] = configData
			}

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

			err = tmplGroup.ExecuteTemplate(outputFile, mainTemplateName, combinedData)
			if err != nil {
				return fmt.Errorf("Rendering-Fehler für %s: %w", mainTemplateName, err)
			}

			fmt.Printf("  ✅ Erfolgreich generiert: %s\n", targetFilePath)

			return filepath.SkipDir
		}

		return nil
	})

	if err != nil {
		fmt.Printf("\n❌ Fehler: %v\n", err)
	} else {
		fmt.Println("\n🎉 Pipeline erfolgreich beendet!")
	}
}
