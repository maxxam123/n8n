package main

import (
	"bytes"
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
	valuesDir := "../values" // Ordner, in dem die passenden .yaml-Dateien liegen
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

			// DYNAMISCH: Prüfen, ob es sich um IRGENDEINE .yaml Datei handelt
			if strings.HasSuffix(fileName, ".yaml") {
				// Ermittle den Basisnamen (schneidet die Endung .yaml ab, z.B. "mein-service")
				baseName := strings.TrimSuffix(fileName, ".yaml")
				
				// Baue den Pfad zur namensgleichen YAML-Datei (z.B. "../values/mein-service.yaml")
				yamlPath := filepath.Join(valuesDir, baseName+".hcl")

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

			// Datei einlesen, Template anwenden (egal ob .yaml mit Werten oder andere Dateien ohne Werte) und ins Ziel schreiben
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

// Hilfsfunktion: Übernimmt den Dateiinhalt, ersetzt Platzhalter sequenziell im Speicher und schreibt ins Ziel
func templateFile(src, dst string, data map[string]interface{}) error {
	content, err := os.ReadFile(src)
	if err != nil {
		return err
	}

	// 1. Runde: Custom Delimiter [[ ]] im Arbeitsspeicher verarbeiten
	tmplCustom, err := template.New(filepath.Base(src) + "_custom").
		Option("missingkey=zero").
		Delims("[[", "]]").
		Parse(string(content))
	if err != nil {
		return fmt.Errorf("Fehler beim Parsen des [[ ]]-Templates: %w", err)
	}

	var bufRound1 bytes.Buffer
	err = tmplCustom.Execute(&bufRound1, data)
	if err != nil {
		return fmt.Errorf("Fehler beim Ausführen des [[ ]]-Templates: %w", err)
	}

	// 2. Runde: Klassische {{ }} auf das Zwischenergebnis im Arbeitsspeicher anwenden
	tmplStandard, err := template.New(filepath.Base(src) + "_std").
		Option("missingkey=zero").
		Parse(bufRound1.String())
	if err != nil {
		return fmt.Errorf("Fehler beim Parsen des {{ }}-Templates: %w", err)
	}

	var bufRound2 bytes.Buffer
	err = tmplStandard.Execute(&bufRound2, data)
	if err != nil {
		return fmt.Errorf("Fehler beim Ausführen des {{ }}-Templates: %w", err)
	}

	// Finale Runde: Das vollständig gerenderte Ergebnis einmalig auf die Festplatte schreiben
	err = os.WriteFile(dst, bufRound2.Bytes(), 0644)
	if err != nil {
		return fmt.Errorf("Fehler beim Schreiben der Zieldatei: %w", err)
	}

	return nil
}
