package main

import (
	"fmt"
	"io/fs"
	"os"
	"path/filepath"
)

func main() {
	// ".." springt eine Ebene höher, um nach "infrastructure-live" zu suchen
	srcDir := "../infrastructure-live"
	dstDir := "newStruct"

	// 1. Quellverzeichnis rekursiv durchlaufen
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
			// 2. Wenn es ein Ordner ist, erstelle ihn im Zielverzeichnis
			err := os.MkdirAll(targetPath, os.ModePerm)
			if err != nil {
				return fmt.Errorf("Fehler beim Erstellen des Ordners %s: %w", targetPath, err)
			}
			fmt.Println("Ordner erstellt:", targetPath)
		} else {
			// 3. Wenn es eine Datei ist, erstelle eine leere Datei im Zielverzeichnis
			file, err := os.OpenFile(targetPath, os.O_CREATE|os.O_WRONLY|os.O_TRUNC, 0644)
			if err != nil {
				return fmt.Errorf("Fehler beim Erstellen der Datei %s: %w", targetPath, err)
			}
			file.Close() // Datei direkt wieder schließen
			fmt.Println("Datei erstellt:", targetPath)
		}
		return nil
	})

	if err != nil {
		fmt.Printf("Fehler beim Generieren der Struktur: %v\n", err)
		return
	}

	fmt.Println("Struktur erfolgreich unter newStruct repliziert!")
}
