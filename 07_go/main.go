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
	valuesFile := "./values/ord_01.yaml" // ACHTUNG: Prüfe, ob es org_01 oder ord_01 heißt!
	srcDir := "../infrastructure-live"
	dstDir := "newStruct"

	// 1. YAML-Wertedatei einlesen (Optionalisiert: Wenn sie fehlt, loggen wir es, machen aber weiter)
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
	// 1. Inhalt der originalen Datei einlesen
	content, err := os.ReadFile(src)
	if err != nil {
		return err
	}

	// 2. Template mit dem Namen der Datei erstellen und parsen
	// .Option("missingkey=zero") sorgt dafür, dass das Skript NICHT abstürzt, wenn ein Key in der YAML fehlt (wird leer gelassen)
	tmpl, err := template.New(filepath.Base(src)).Option("missingkey=zero").Parse(string(content))
	if err != nil {
		return fmt.Errorf("Fehler beim Parsen des Templates: %w", err)
	}

	// 3. Zieldatei zum Schreiben erstellen (ersetzt dein os.OpenFile von vorher)
	outputFile, err := os.Create(dst)
	if err != nil {
		return err
	}
	defer outputFile.Close()

	// 4. Template ausführen und Daten hineinschreiben
	err = tmpl.Execute(outputFile, data)
	if err != nil {
		return fmt.Errorf("Fehler beim Ausführen des Templates: %w", err)
	}

	return nil
}
