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
	valuesFile := "./values/ord_01.yaml" 
	srcDir := "../infrastructure-live"
	dstDir := "newStruct"

	var config map[string]interface{}
	yamlData, err := os.ReadFile(valuesFile)
	if err != nil {
		fmt.Printf("ABBRUCH: YAML-Datei konnte nicht gelesen werden: %v\n", err)
		return
	}

	err = yaml.Unmarshal(yamlData, &config)
	if err != nil {
		fmt.Printf("ABBRUCH: Fehler beim Parsen der YAML-Datei: %v\n", err)
		return
	}

	// WICHTIG: Schau dir diese Ausgabe im Terminal an!
	fmt.Println("\n=== [DEBUG] EXAKTE STRUKTUR DEINER YAML IN GO ===")
	for k, v := range config {
		fmt.Printf("Key: '%s' | Typ des Inhalts: %T | Wert: %v\n", k, v, v)
	}
	fmt.Println("================================================\n")

	err = filepath.WalkDir(srcDir, func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}

		relPath, err := filepath.Rel(srcDir, path)
		if err != nil {
			return err
		}

		targetPath := filepath.Join(dstDir, relPath)

		if d.IsDir() {
			err := os.MkdirAll(targetPath, os.ModePerm)
			if err != nil {
				return fmt.Errorf("Fehler beim Erstellen des Ordners %s: %w", targetPath, err)
			}
		} else {
			// Wir übergeben die Konfiguration an die Templating-Funktion
			err := templateFile(path, targetPath, config)
			if err != nil {
				return fmt.Errorf("Fehler beim Templating der Datei %s: %w", targetPath, err)
			}
			fmt.Println("Datei erfolgreich gerendert:", targetPath)
		}
		return nil
	})

	if err != nil {
		fmt.Printf("\nGenerierung abgebrochen wegen Fehler: %v\n", err)
		return
	}

	fmt.Println("\nStruktur erfolgreich unter newStruct repliziert und gerendert!")
}

func templateFile(src, dst string, data map[string]interface{}) error {
	content, err := os.ReadFile(src)
	if err != nil {
		return err
	}

	tmpl := template.New(filepath.Base(src))
	
	// Wir erzwingen hier einen harten Fehler statt "<no value>" zu schreiben!
	tmpl = tmpl.Option("missingkey=error")

	tmpl, err = tmpl.Parse(string(content))
	if err != nil {
		return fmt.Errorf("Fehler beim Parsen der Syntax: %w", err)
	}

	outputFile, err := os.Create(dst)
	if err != nil {
		return err
	}
	defer outputFile.Close()

	err = tmpl.Execute(outputFile, data)
	if err != nil {
		// Wenn eine Variable fehlt, sehen wir hier genau, welche gesucht wurde
		return fmt.Errorf("Fehler beim Ersetzen der Variablen: %w", err)
	}

	return nil
}
