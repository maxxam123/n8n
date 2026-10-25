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

	// 1. YAML-Wertedatei einlesen
	yamlData, err := os.ReadFile(valuesFile)
	if err != nil {
		fmt.Printf("ABBRUCH: Fehler beim Lesen der YAML-Datei: %v\n", err)
		return
	}

	var config map[string]interface{}
	err = yaml.Unmarshal(yamlData, &config)
	if err != nil {
		fmt.Printf("ABBRUCH: Fehler beim Parsen der YAML-Datei: %v\n", err)
		return
	}

	// ABSICHERUNG 1: Basis-Zielordner explizit vorab erstellen
	err = os.MkdirAll(dstDir, os.ModePerm)
	if err != nil {
		fmt.Printf("ABBRUCH: Kann Basisordner %s nicht erstellen: %v\n", dstDir, err)
		return
	}

	// 2. Quellverzeichnis rekursiv durchlaufen
	err = filepath.WalkDir(srcDir, func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}

		// ABSICHERUNG 2: Das Quellverzeichnis selbst nicht als Unterordner duplizieren
		if path == srcDir {
			return nil
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
			// Wenn es eine Datei ist, wende das Template an
			err := templateFile(path, targetPath, config)
			if err != nil {
				return fmt.Errorf("Fehler beim Templating der Datei %s: %w", targetPath, err)
			}
			fmt.Println("Datei gerendert:", targetPath)
		}
		return nil
	})

	if err != nil {
		fmt.Printf("\nLaufzeitfehler während der Generierung: %v\n", err)
		return
	}

	fmt.Println("\nStruktur erfolgreich unter newStruct repliziert und gerendert!")
}

func templateFile(src, dst string, data map[string]interface{}) error {
	// ABSICHERUNG 3: Sicherstellen, dass der übergeordnete Ordner existiert
	dir := filepath.Dir(dst)
	if err := os.MkdirAll(dir, os.ModePerm); err != nil {
		return fmt.Errorf("Zielverzeichnis existiert nicht: %w", err)
	}

	content, err := os.ReadFile(src)
	if err != nil {
		return err
	}

	tmpl, err := template.New(filepath.Base(src)).Option("missingkey=error").Parse(string(content))
	if err != nil {
		return fmt.Errorf("Fehler beim Parsen des Templates: %w", err)
	}

	outputFile, err := os.Create(dst)
	if err != nil {
		return err
	}
	defer outputFile.Close()

	err = tmpl.Execute(outputFile, data)
	if err != nil {
		return fmt.Errorf("Fehler beim Ausführen des Templates: %w", err)
	}

	return nil
}
