# TODO

Offene Punkte bis zur Abgabe. Alle Stellen sind im Dokument als `#todo(...)`
markiert; mit `entwurf: false` in `src/main.typ` bricht der Build ab, solange
noch welche offen sind.

## Vom Nutzer nachzuliefern

- [ ] **Stückliste** (`03_stueckliste.typ`)
  - Anzahl der Schraubschellen
  - USB-Netzteil des ESP32: Bezugsquelle und Preis („vorhanden“?)
  - Bezugsquelle und Preis für Mechanik und Pflanzen (Holzbretter, Rohr,
    Schellen, Netztöpfe, 2 Plastikboxen, Schlauch, Blähton, Pflanzen) —
    „vorhanden“ geht auch
  - Nährstoffkonzentrat: Produkt, Quelle, Preis
- [ ] **Foto Gesamtaufbau** nach `src/res/` legen, Platzhalter in
  `04_bauanleitung.typ` (`fig-aufbau`) ersetzen
- [ ] **Deckblatt** (`main.typ`): Modul, Matrikelnummer, Studiengang/Zenturie,
  Dozent, Abgabedatum, ggf. weitere Gruppenmitglieder
- [ ] **KI-Dokumentation** im Anhang (`99_anhang.typ`) ausfüllen

## Zu entscheiden

- [ ] **Umfang:** Textteil aktuell ca. 20 Seiten, Ziel 12–15. Größter Posten
  ist Kapitel 4 (ca. 7 statt 3,5 Seiten). Kürzen?
- [ ] **Platzhalter Verdrahtungsfoto** (`fig-verdrahtung`) streichen, da nur
  ein Foto existiert und der Leistungspfad als Diagramm vorliegt?

## Vor der Abgabe

- [ ] `entwurf: false` setzen und `typst compile src/main.typ` ausführen
- [ ] PDF einmal komplett durchlesen (Seitenumbrüche, Tabellen, Verweise)
