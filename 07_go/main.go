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
	valuesFile := "../values/ord_01.yaml"
	srcDir := "../infrastructure-live"
	dstDir := "newStruct"

	// 1. YAML-Wertedatei einlesen
	var config map[string]interface{}
	yamlData, err := os.ReadFile(valuesFile)
	if err != nil {
		fmt.Printf("Hinweis: YAML-Datei konnte nicht gelesen werden (%v). Templating nutzt leere Werte.\n", err)
	} else {
		err = yaml.Unmarshal(yamlData, &config)
		if err != nil {
			fmt.Printf("Fehler beim Parsen der YAML-Datei: %v. Templating nutzt leere Werte.\n", err)
		}
	}

	// 2. Quellverzeichnis rekursiv durchlaufen
	err = filepath.WalkDir(srcDir, func(path string, d fs.DirEntry, err error) error {
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
			// 3. Wenn es ein Ordner ist, erstelle ihn im Zielverzeichnis
			err := os.MkdirAll(targetPath, os.ModePerm)
			if err != nil {
				return fmt.Errorf("Fehler beim Erstellen des Ordners %s: %w", targetPath, err)
			}
			fmt.Println("Ordner erstellt:", targetPath)
		} else {
			// 4. Wenn es eine Datei ist, lies sie ein, wende das Template an und schreibe sie ins Ziel
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

	fmt.Println("Struktur erfolgreich unter newStruct repliziert und gerendert!")
}

// Hilfsfunktion: Übernimmt den Dateiinhalt, ersetzt Platzhalter und schreibt das Ergebnis ins Ziel
func templateFile(src, dst string, data map[string]interface{}) error {
	content, err := os.ReadFile(src)
	if err != nil {
		return err
	}

	// Template erstellen. "missingkey=zero" verhindert Abstürze bei Terragrunt-Klammern.
	tmpl := template.New(filepath.Base(src)).Option("missingkey=zero")

	// WICHTIG: Wir ändern die Trennzeichen auf [[ ]]. 
	// Dadurch ignoriert Go die {} von Terragrunt und liest NUR deine Variablen ein!
	tmpl = tmpl.Delims("[[", "]]")

	tmpl, err = tmpl.Parse(string(content))
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
