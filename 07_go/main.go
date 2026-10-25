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
		
		// Unterstützung für Doppelpunkt ":" oder Gleichheitszeichen "=" als Trenner
		var separator string
		if strings.Contains(line, ":") {
			separator = ":"
		} else if strings.Contains(line, "=") {
			separator = "="
		} else {
			continue
		}

		if parts := strings.SplitN(line, separator, 2); len(parts) == 2 {
			key := strings.TrimSpace(parts[0])
			value := strings.TrimSpace(parts[1])
			
			// Entfernt optionale Anführungszeichen um den Wert (z.B. "staging" -> staging)
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

			// 3. Template-Gruppe initialisieren
			tmplGroup := template.New(templateKey).Option("missingkey=error")
			combinedData := make(map[string]interface{})

			for _, yamlPath := range yamlFiles {
				tName := filepath.Base(yamlPath)

				// Datei manuell einlesen und unter dem reinen Dateinamen registrieren
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

				// Wenn es sich um das Haupt-Template handelt, spiele die Variablen 
				// direkt auf die oberste Ebene ein, damit sie mit {{ .variable }} erreichbar sind.
				if yamlPath == mainTemplatePath {
					for k, v := range configData.Vars {
						combinedData[k] = v
					}
				}
			}

			// 5. Zielstruktur aufbauen
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

			// 6. Haupt-YAML-Template ausführen
			err = tmplGroup.ExecuteTemplate(outputFile, mainTemplateName, combinedData)
			if err != nil {
				return fmt.Errorf("Rendering-Fehler für %s: %w", mainTemplateName, err)
			}

			fmt.Printf("  ✅ Erfolgreich generiert: %s\n", targetFilePath)

			// KORREKTUR: "return nil" statt "SkipDir" sorgt dafür, dass Go zum nächsten Ordner springt
			return nil 
		}

		return nil
	})

	if err != nil {
		fmt.Printf("\n❌ Fehler: %v\n", err)
	} else {
		fmt.Println("\n🎉 Pipeline erfolgreich beendet!")
	}
}
