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

// ParsedConfig hält sowohl den rohen Text als auch die extrahierten Schlüssel-Wert-Paare einer .txt-Datei
type ParsedConfig struct {
	RawText string                 // Der gesamte Inhalt der .txt-Datei als String
	Vars    map[string]interface{} // Einzelne Variablen, falls im Format "KEY=VALUE" geschrieben
}

// Hilfsfunktion zum Einlesen und Parsen einer .txt Konfigurationsdatei
func loadTxtConfig(configSubDir, txtFileName string) (ParsedConfig, error) {
	txtPath := filepath.Join(configSubDir, txtFileName)
	config := ParsedConfig{
		Vars: make(map[string]interface{}),
	}

	if _, err := os.Stat(txtPath); os.IsNotExist(err) {
		return config, nil // Datei ist optional
	}

	// 1. Gesamte Datei als rohen Text einlesen
	data, err := os.ReadFile(txtPath)
	if err != nil {
		return config, err
	}
	config.RawText = string(data)

	// 2. Datei zeilenweise parsen für KEY=VALUE Paare
	file, err := os.Open(txtPath)
	if err != nil {
		return config, err
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		// Ignoriere Leerzeilen und Kommentare
		if line == "" || strings.HasPrefix(line, "#") || strings.HasPrefix(line, "//") {
			continue
		}
		// Splitte am ersten "=" Zeichen
		if parts := strings.SplitN(line, "=", 2); len(parts) == 2 {
			key := strings.TrimSpace(parts[0])
			value := strings.TrimSpace(parts[1])
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

		// Wir verarbeiten jeden Unterordner einzeln
		if d.IsDir() && path != TemplatePoolDir {
			templateKey := filepath.Base(path)
			fmt.Printf("Verarbeite Ordner: %s\n", templateKey)

			// 1. Alle .yaml Template-Dateien in DIESEM Ordner finden
			yamlFiles, err := filepath.Glob(filepath.Join(path, "*.yaml"))
			if err != nil || len(yamlFiles) == 0 {
				return nil // Keine Templates gefunden, weitergehen
			}

			// 2. Das Haupttemplate bestimmen (enthält "main" oder "template", sonst das erste Element)
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

			// 3. Template-Gruppe initialisieren und alle .yaml Dateien laden
			tmplGroup := template.New(templateKey)
			combinedData := make(map[string]interface{})

			for _, yamlPath := range yamlFiles {
				tName := filepath.Base(yamlPath)

				_, err = tmplGroup.ParseFiles(yamlPath)
				if err != nil {
					return fmt.Errorf("Fehler beim Parsen des Templates %s: %w", tName, err)
				}

				// 4. Zugehörige .txt Datei im config-pool suchen
				baseNameWithoutExt := strings.TrimSuffix(tName, filepath.Ext(tName))
				txtFileName := baseNameWithoutExt + ".txt"
				configSubDir := filepath.Join(ConfigPoolDir, templateKey)

				configData, err := loadTxtConfig(configSubDir, txtFileName)
				if err != nil {
					return fmt.Errorf("Fehler beim Laden der Config %s: %w", txtFileName, err)
				}

				// Key für das Template säubern (Bindestriche zu Unterstrichen)
				cleanKey := strings.ReplaceAll(baseNameWithoutExt, "-", "_")
				combinedData[cleanKey] = configData
			}

			// 5. Zielstruktur aufbauen
			targetDirPath := filepath.Join(OutputDir, templateKey)
			if err := os.MkdirAll(targetDirPath, 0755); err != nil {
				return fmt.Errorf("Zielordner-Fehler: %w", err)
			}

			// Zieldatei heißt nun wie das Haupt-Template (z.B. main.yaml)
			targetFilePath := filepath.Join(targetDirPath, mainTemplateName)
			outputFile, err := os.Create(targetFilePath)
			if err != nil {
				return fmt.Errorf("Zieldatei-Fehler: %w", err)
			}
			defer outputFile.Close()

			// 6. Haupt-YAML-Template ausführen
			err = tmplGroup.ExecuteTemplate(outputFile, mainTemplateName, combinedData)
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
