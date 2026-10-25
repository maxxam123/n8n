package main

import (
	"fmt"
	"io/fs"
	"os"
	"path/filepath"
	"text/template"

	"gopkg.in/yaml.v3"
)

func main() {
	// Pfade definieren
	valuesFile := "./values/org_01.yaml"
	srcDir := "../infrastructure-live"
	dstDir := "newStruct"

	// 1. YAML-Wertedatei einlesen und parsen
	yamlData, err := os.ReadFile(valuesFile)
	if err != nil {
		fmt.Printf("Fehler beim Lesen der YAML-Datei: %v\n", err)
		return
	}

	// Flexibles Map-Interface für die Vorlagen-Variablen
	var config map[string]interface{}
	err = yaml.Unmarshal(yamlData, &config)
	if err != nil {
		fmt.Printf("Fehler beim Parsen der YAML-Datei: %v\n", err)
		return
	}

	// 2. Quellverzeichnis rekursiv durchlaufen
	err = filepath.WalkDir(srcDir, func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}

		// Relativen Pfad berechnen
		relPath, err := filepath.Rel(srcDir, path)
		if err != nil {
			return err
		}

		// Zielpfad bestimmen
		targetPath := filepath.Join(dstDir, relPath)

		if d.IsDir() {
			// Ordner im Zielverzeichnis erstellen
			err := os.MkdirAll(targetPath, os.ModePerm)
			if err != nil {
				return fmt.Errorf("Fehler beim Erstellen des Ordners %s: %w", targetPath, err)
			}
			fmt.Println("Ordner erstellt:", targetPath)
		} else {
			// 3. Datei-Inhalt templaten und schreiben
			err := templateFile(path, targetPath, config)
			if err != nil {
				return fmt.Errorf("Fehler beim Templating von %s: %w", path, err)
			}
			fmt.Println("Datei gerendert:", targetPath)
		}
		return nil
	})

	if err != nil {
		fmt.Printf("Fehler beim Generieren der Struktur: %v\n", err)
		return
	}

	fmt.Println("Struktur erfolgreich mit YAML-Werten repliziert!")
}

// Hilfsfunktion, die eine Datei liest, die Platzhalter ersetzt und im Ziel speichert
func templateFile(src, dst string, data map[string]interface{}) error {
	// Quelltext der Datei einlesen
	content, err := os.ReadFile(src)
	if err != nil {
		return err
	}

	// Go-Template initialisieren (Option "missingkey=error" wirft Fehler bei fehlenden Variablen)
	tmpl, err := template.New(filepath.Base(src)).Option("missingkey=error").Parse(string(content))
	if err != nil {
		return err
	}

	// Zieldatei zum Schreiben öffnen
	outputFile, err := os.OpenFile(dst, os.O_CREATE|os.O_WRONLY|os.O_TRUNC, 0644)
	if err != nil {
		return err
	}
	defer outputFile.Close()

	// Template mit den YAML-Daten rendern und in die Zieldatei schreiben
	err = tmpl.Execute(outputFile, data)
	if err != nil {
		return err
	}

	return nil
}
