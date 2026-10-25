package main

import (
	"encoding/json"
	"fmt"
	"io/fs"
	"os"
	"path/filepath"
	"text/template"
)

type ConfigValues map[string]interface{}

const (
	TemplatePoolDir = "./template-pool"
	ConfigPoolDir   = "./config-pool"
	OutputDir       = "./output-deployments"
	TargetFileName  = "target.conf"

	// Feste Namen der Template-Dateien
	MainTmplName   = "template.txt"
	ValuesTmplName = "values.txt"
	PatchTmplName  = "patch.txt"

	// Feste Namen der JSON-Wertdateien im config-pool
	MainJsonName   = "global.json"
	ValuesJsonName = "values.json"
	PatchJsonName  = "patch.json"
)

// Hilfsfunktion zum Laden und Parsen einer JSON-Datei in eine Map
func loadJsonConfig(configSubDir, jsonFileName string) (ConfigValues, error) {
	jsonPath := filepath.Join(configSubDir, jsonFileName)
	values := make(ConfigValues)

	if _, err := os.Stat(jsonPath); os.IsNotExist(err) {
		return values, nil // Datei optional, gibt leere Map zurück
	}

	data, err := os.ReadFile(jsonPath)
	if err != nil {
		return nil, err
	}

	if err := json.Unmarshal(data, &values); err != nil {
		return nil, fmt.Errorf("ungültiges JSON in %s: %w", jsonPath, err)
	}

	return values, nil
}

func main() {
	fmt.Println("Starte Multi-Template-Verarbeitung...")
	fmt.Println("=========================================")

	err := filepath.WalkDir(TemplatePoolDir, func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}

		// Wir triggern den Prozess, sobald wir die Haupt-Template-Datei finden
		if !d.IsDir() && d.Name() == MainTmplName {
			tmplDir := filepath.Dir(path)
			templateKey := filepath.Base(tmplDir) // z.B. "file-one"
			fmt.Printf("Verarbeite Ordner: %s\n", templateKey)

			// 1. Zugehörigen Konfigurations-Ordner bestimmen
			configSubDir := filepath.Join(ConfigPoolDir, templateKey)

			// 2. Alle JSON-Werte separat laden
			mainValues, err := loadJsonConfig(configSubDir, MainJsonName)
			if err != nil {
				return err
			}
			valuesValues, err := loadJsonConfig(configSubDir, ValuesJsonName)
			if err != nil {
				return err
			}
			patchValues, err := loadJsonConfig(configSubDir, PatchJsonName)
			if err != nil {
				return err
			}

			// 3. Eine gemeinsame Template-Gruppe für diesen Ordner erstellen
			tmplGroup := template.New(templateKey)

			// Haupt-Template parsen
			_, err = tmplGroup.ParseFiles(path)
			if err != nil {
				return fmt.Errorf("Fehler beim Parsen von %s: %w", MainTmplName, err)
			}

			// Optionale Unter-Templates (values.txt & patch.txt) parsen und der Gruppe hinzufügen
			optionalTemplates := []string{ValuesTmplName, PatchTmplName}
			for _, tName := range optionalTemplates {
				tPath := filepath.Join(tmplDir, tName)
				if _, err := os.Stat(tPath); err == nil {
					_, err = tmplGroup.ParseFiles(tPath)
					if err != nil {
						return fmt.Errorf("Fehler beim Parsen von %s: %w", tName, err)
					}
				}
			}

			// 4. Zielverzeichnis und Zieldatei vorbereiten
			targetDirPath := filepath.Join(OutputDir, templateKey)
			if err := os.MkdirAll(targetDirPath, 0755); err != nil {
				return fmt.Errorf("Fehler beim Erstellen des Zielordners: %w", err)
			}

			targetFilePath := filepath.Join(targetDirPath, TargetFileName)
			outputFile, err := os.Create(targetFilePath)
			if err != nil {
				return fmt.Errorf("Fehler beim Erstellen der Zieldatei: %w", err)
			}
			defer outputFile.Close()

			// 5. Daten für das Haupt-Template strukturieren
			combinedData := map[string]interface{}{
				"Global": mainValues,
				"Values": valuesValues,
				"Patch":  patchValues,
			}

			// 6. Das Haupt-Template ausführen
			err = tmplGroup.ExecuteTemplate(outputFile, MainTmplName, combinedData)
			if err != nil {
				return fmt.Errorf("Fehler beim Rendern der Hauptdatei: %w", err)
			}

			fmt.Printf("✅ Erfolgreich generiert: %s\n", targetFilePath)
		}

		return nil
	})

	if err != nil {
		fmt.Printf("\n❌ Fehler: %v\n", err)
	} else {
		fmt.Println("\n🎉 Alle Pipelines erfolgreich abgearbeitet!")
	}
}
