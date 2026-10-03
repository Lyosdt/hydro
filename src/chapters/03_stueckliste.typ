#import "../components/formatting.typ": todo
#import "../components/stueckliste.typ": stueckliste

// Kapitel 3 — Budget: 1,5 Seiten
// Pflichtbestandteil: Bauteilstückliste
// Nur Komponenten aus CLAUDE.md Abschnitt 3 aufnehmen (inkl. Mechanik und Pflanzen).
// Preise: Einzelpreis in €, `none` solange unbekannt. Bereits vorhandene Teile:
// quelle: "vorhanden", preis: 0.

= Bauteilstückliste <kap-stueckliste>

@tab-stueckliste führt alle Bauteile des Demonstrators auf, gegliedert nach
Funktionsgruppen. Die Bauteile wurden über Amazon bestellt, im Baumarkt gekauft
oder waren bereits vorhanden. Bereits vorhandene Bauteile sind mit der
Bezugsquelle „vorhanden“ und einem Preis von 0 € geführt, sodass die Summe nur
die tatsächlichen Projektausgaben abbildet. Die Summe ist dem Budget von ca.
100 € gegenübergestellt, das der Erstattungsgrenze der Hochschule entspricht.

// The bill of materials is long enough to continue on the next page
#show figure: set block(breakable: true)
#figure(
  stueckliste(
    (
      "Steuerung und Anzeige",
      (bezeichnung: "Mikrocontroller", typ: "ESP32 DevKit, WROOM, 30 Pin", anzahl: 1, quelle: "vorhanden", preis: 0),
      (bezeichnung: "Display", typ: "OLED SSD1306, 128 × 32 px, I²C", anzahl: 1, quelle: "Amazon", preis: 2.99),
      (bezeichnung: "Status-LED", typ: "grün, gelb, rot", anzahl: 3, quelle: "vorhanden", preis: 0),
      (bezeichnung: "Vorwiderstand LED", typ: "220 Ω", anzahl: 3, quelle: "vorhanden", preis: 0),
      (bezeichnung: "Steckbrett", typ: "Breadboard", anzahl: 1, quelle: "Amazon", preis: 9.99),
      (bezeichnung: "USB-Netzteil", typ: "Versorgung ESP32, mit USB-Kabel", anzahl: 1, quelle: none, preis: none),
      (bezeichnung: "Jumperwire", typ: "Jumperwire für Breadboard F-F, F-M, M-M", anzahl: 1, quelle: "Amazon", preis: 6.99),

      "Sensorik",
      (bezeichnung: "Leitfähigkeitssensor", typ: "TDS analog, Gravity-Bauform, 5 V", anzahl: 1, quelle: "Amazon", preis: 8.09),
      (bezeichnung: "Temperatursensor", typ: "DS18B20, wasserdicht, OneWire", anzahl: 1, quelle: "Amazon", preis: 8.07),
      (bezeichnung: "Pull-up-Widerstand", typ: "4,7 kΩ (OneWire-Bus)", anzahl: 1, quelle: "vorhanden", preis: 0),
      (bezeichnung: "Füllstandssensor", typ: "XKC-Y25-NPN, berührungslos", anzahl: 1, quelle: "Amazon", preis: 10.39),

      "Leistungspfad Pumpe",
      (bezeichnung: "Schaltmodul", typ: "MOSFET-Board P2003BDG, N-Kanal, Logic Level", anzahl: 1, quelle: "vorhanden", preis: 0),
      (bezeichnung: "Wasserpumpe", typ: "5 V, USB-A-Stecker", anzahl: 1, quelle: "Amazon", preis: 8.95),
      (bezeichnung: "USB-Netzteil", typ: "5 V, 2 A, Versorgung Pumpe", anzahl: 1, quelle: "vorhanden", preis: 0),
      (bezeichnung: "USB-A-Pigtail", typ: "Stecker (männlich), Netzteilseite & Buchse (weiblich), Pumpenseite", anzahl: 1, quelle: "vorhanden", preis: 0),
      (bezeichnung: "Freilaufdiode", typ: "1N4007", anzahl: 1, quelle: "vorhanden", preis: 0),
      (bezeichnung: "Elektrolytkondensator", typ: "1000 µF", anzahl: 1, quelle: "vorhanden", preis: 0),
      "Beleuchtung",
      (bezeichnung: "LED-Growlight", typ: "5 V, 2 A, interner Timer, mit Netzteil", anzahl: 1, quelle: "Amazon", preis: 16.59),

      "Mechanischer Aufbau",
      (bezeichnung: "Rahmen", typ: "Holzbox, vorne offen, aus Holzbrettern selbst gebaut", anzahl: 1, quelle: none, preis: none),
      (bezeichnung: "Anbaurohr", typ: "Rohr mit Öffnungen für die Netztöpfe", anzahl: 1, quelle: none, preis: none),
      (bezeichnung: "Rohrbefestigung", typ: "Schraubschelle", anzahl: none, quelle: none, preis: none),
      (bezeichnung: "Netztopf", typ: "Pflanzkorb für Hydrokultur", anzahl: 4, quelle: none, preis: none),
      (bezeichnung: "Reservoir", typ: "Plastikbox", anzahl: 1, quelle: none, preis: none),
      (bezeichnung: "Elektronikgehäuse", typ: "Plastikbox", anzahl: 1, quelle: none, preis: none),
      (bezeichnung: "Schlauch", typ: "Förderleitung Pumpe → Rohr", anzahl: 1, quelle: none, preis: none),

      "Pflanzen und Substrat",
      (bezeichnung: "Substrat", typ: "Blähton", anzahl: 1, quelle: none, preis: none),
      (bezeichnung: "Pflanzen", typ: "Basilikum, Steckling in Wasser bewurzelt", anzahl: 4, quelle: none, preis: none),
    ),
    budget: 100,
  ),
  caption: [Bauteilstückliste des Demonstrators],
) <tab-stueckliste>

#todo("Mechanik und Pflanzen: Anzahl der Schraubschellen; Bezugsquelle und Preis aller Positionen der beiden letzten Gruppen (\"vorhanden\" geht auch). Außerdem: Welches Nährstoffkonzentrat wurde verwendet (Produkt, Quelle, Preis)?")

Zwei Positionen gehören nicht zum Steuerkreis des ESP32. Das Growlight wird
über ein eigenes Netzteil versorgt und durch seinen internen Timer geschaltet;
es ist elektrisch vollständig vom übrigen Aufbau getrennt. Das
Handheld-Messgerät diente als Referenz für die Kalibrierung der
Leitfähigkeitsmessung (@kap-kalibrierung) und ist kein Bestandteil des
Demonstrators. pH-Sonde und Dosierpumpe sind bewusst nicht enthalten
(@kap-abgrenzung).
