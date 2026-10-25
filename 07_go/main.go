package main

import (
	"fmt"
	"io/fs"
	"os"
	"path/filepath"
	"strings"
	"text/template"

	"gopkg.in/yaml.v3"
)

func main() {
	// Verzeichnisse definieren
	valuesDir := "../values" // Ordner, in dem ord_01.yaml und ord_02.yaml liegen
	srcDir := "../infrastructure-live"
	dstDir := "newStruct"

	// Quellverzeichnis rekursiv durchlaufen
	err := filepath.WalkDir(srcDir, func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}

		// Errechne den relativen Pfad vom Quellordner aus
		relPath, err := filepath.Rel(srcDir, path)
		if err != nil {
			return err
		}

		// Bestimme den neuen Zielpfad unter newStruct
		targetPath := filepath.Join(dstDir, relPath)

		if d.IsDir() {
			// Wenn es ein Ordner ist, erstelle ihn im Zielverzeichnis
			err := os.MkdirAll(targetPath, os.ModePerm)
			if err != nil {
				return fmt.Errorf("Fehler beim Erstellen des Ordners %s: %w", targetPath, err)
			}
			fmt.Println("Ordner erstellt:", targetPath)
		} else {
			// Wir initialisieren eine leere Map für die Variablen
			var config map[string]interface{}
			fileName := d.Name()

			// Prüfen, ob es sich um eine ord_XX.hcl Datei handelt
			if strings.HasPrefix(fileName, "ord_") && strings.HasSuffix(fileName, ".hcl") {
				// Ermittle die Nummer/Basisname (z.B. "ord_01" aus "ord_01.hcl")
				baseName := strings.TrimSuffix(fileName, ".hcl")
				
				// Baue den Pfad zur passenden YAML-Datei (z.B. "../values/ord_01.yaml")
				yamlPath := filepath.Join(valuesDir, baseName+".yaml")

				// Versuche die spezifische YAML-Datei einzulesen
				yamlData, err := os.ReadFile(yamlPath)
				if err != nil {
					fmt.Printf("Hinweis: Keine spezifische YAML unter %s gefunden (%v). Nutze leere Werte.\n", yamlPath, err)
				} else {
					err = yaml.Unmarshal(yamlData, &config)
					if err != nil {
						fmt.Printf("Fehler beim Parsen der YAML-Datei %s: %v. Nutze leere Werte.\n", yamlPath, err)
					} else {
						fmt.Printf("Datei %s wird mit Werten aus %s gerendert.\n", fileName, baseName+".yaml")
					}
				}
			}

			// Datei einlesen, Template anwenden und ins Ziel schreiben
			err := templateFile(path, targetPath, config)
			if err != nil {
				return fmt.Errorf("Fehler beim Templating der Datei %s: %w", targetPath, err)
			}
			fmt.Println("Datei gerendert:", targetPath)
		}
		return nil
	})

	if err != nil {
		fmt.Printf("Fehler beim Generieren der Struktur: %v\n", err)
		return
	}

	fmt.Println("Struktur erfolgreich repliziert und dynamisch gerendert!")
}

// Hilfsfunktion: Übernimmt den Dateiinhalt, ersetzt Platzhalter und schreibt das Ergebnis ins Ziel
func templateFile(src, dst string, data map[string]interface{}) error {
	content, err := os.ReadFile(src)
	if err != nil {
		return err
	}

	// 1. Runde: Custom Delimiter [[ ]] vorbereiten
	tmplCustom := template.New(filepath.Base(src) + "_custom").Option("missingkey=zero").Delims("[[", "]]")
	tmplCustom, err = tmplCustom.Parse(string(content))
	if err != nil {
		return fmt.Errorf("Fehler beim Parsen des [[ ]]-Templates: %w", err)
	}

	outputFile, err := os.Create(dst)
	if err != nil {
		return err
	}
	defer outputFile.Close()

	// [[ ]] Variablen ersetzen und in Datei schreiben
	err = tmplCustom.Execute(outputFile, data)
	if err != nil {
		return fmt.Errorf("Fehler beim Ausführen des Templates: %w", err)
	}

	// 2. Runde: Falls klassische {{ }} verwendet wurden, diese nachträglich verarbeiten
	updatedContent, err := os.ReadFile(dst)
	if err == nil {
		tmplStandard := template.New(filepath.Base(src) + "_std").Option("missingkey=zero")
		tmplStandard, err = tmplStandard.Parse(string(updatedContent))
		if err == nil {
			outputFileSeek, err := os.OpenFile(dst, os.O_WRONLY|os.O_TRUNC, 0644)
			if err == nil {
				defer outputFileSeek.Close()
				_ = tmplStandard.Execute(outputFileSeek, data)
			}
		}
	}

	return nil
}
