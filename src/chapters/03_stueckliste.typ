#import "../components/formatting.typ": todo
#import "../components/stueckliste.typ": stueckliste

// Kapitel 3 — Budget: 1,5 Seiten
// Pflichtbestandteil: Bauteilstückliste
// Nur Komponenten aus CLAUDE.md Abschnitt 3 aufnehmen.
// Preise: Einzelpreis in €, `none` solange unbekannt. Bereits vorhandene Teile:
// quelle: "vorhanden", preis: 0.

= Bauteilstückliste <kap-stueckliste>

@tab-stueckliste führt alle Bauteile des Demonstrators auf, gegliedert nach
Funktionsgruppen. Die Bauteile wurden über Amazon bestellt, im Baumarkt gekauft
oder waren bereits vorhanden. Bereits vorhandene Bauteile sind mit der
Bezugsquelle „vorhanden“ und einem Preis von 0 € geführt, sodass die Summe nur
die tatsächlichen Projektausgaben abbildet. Die Summe ist dem Budget von ca.
100 € gegenübergestellt, das der Erstattungsgrenze der Hochschule entspricht.

#figure(
  stueckliste(
    (
      "Steuerung und Anzeige",
      (bezeichnung: "Mikrocontroller", typ: "ESP32 DevKit, WROOM, 30 Pin", anzahl: 1, quelle: none, preis: none),
      (bezeichnung: "Display", typ: "OLED SSD1306, 128 × 32 px, I²C", anzahl: 1, quelle: none, preis: none),
      (bezeichnung: "Status-LED", typ: "grün, gelb, rot", anzahl: 3, quelle: none, preis: none),
      (bezeichnung: "Vorwiderstand LED", typ: "220 Ω", anzahl: 3, quelle: none, preis: none),
      (bezeichnung: "Steckbrett", typ: "Breadboard", anzahl: 1, quelle: none, preis: none),

      "Sensorik",
      (bezeichnung: "Leitfähigkeitssensor", typ: "TDS analog, Gravity-Bauform, 5 V", anzahl: 1, quelle: none, preis: none),
      (bezeichnung: "Temperatursensor", typ: "DS18B20, wasserdicht, OneWire", anzahl: 1, quelle: none, preis: none),
      (bezeichnung: "Pull-up-Widerstand", typ: "4,7 kΩ (OneWire-Bus)", anzahl: 1, quelle: none, preis: none),
      (bezeichnung: "Füllstandssensor", typ: "XKC-Y25-NPN, berührungslos", anzahl: 1, quelle: none, preis: none),

      "Leistungspfad Pumpe",
      (bezeichnung: "Schaltmodul", typ: "MOSFET-Board P2003BDG, N-Kanal, Logic Level", anzahl: 1, quelle: none, preis: none),
      (bezeichnung: "Wasserpumpe", typ: "5 V, USB-A-Stecker", anzahl: 1, quelle: none, preis: none),
      (bezeichnung: "USB-Netzteil", typ: "5 V, 2 A", anzahl: 1, quelle: none, preis: none),
      (bezeichnung: "USB-A-Pigtail", typ: "Stecker (männlich), Netzteilseite", anzahl: 1, quelle: none, preis: none),
      (bezeichnung: "USB-A-Pigtail", typ: "Buchse (weiblich), Pumpenseite", anzahl: 1, quelle: none, preis: none),
      (bezeichnung: "Freilaufdiode", typ: "1N4007", anzahl: 1, quelle: none, preis: none),
      (bezeichnung: "Elektrolytkondensator", typ: "1000 µF", anzahl: 1, quelle: none, preis: none),

      "Beleuchtung",
      (bezeichnung: "LED-Growlight", typ: "5 V, 2 A, interner Timer", anzahl: 1, quelle: none, preis: none),
      (bezeichnung: "Netzteil Growlight", typ: todo("Typ; im Lieferumfang des Growlights enthalten?"), anzahl: 1, quelle: none, preis: none),

      "Messmittel",
      (bezeichnung: "Referenzmessgerät", typ: "Handheld-TDS/EC-Messgerät", anzahl: 1, quelle: none, preis: none),
    ),
    budget: 100,
  ),
  caption: [Bauteilstückliste des Demonstrators],
) <tab-stueckliste>

#todo("Mechanischer Aufbau und Verbrauchsmaterial fehlen in der Liste. Bitte angeben, was verwendet wurde (Typ, Anzahl, Quelle): Anbaurinne, Reservoir, Netztöpfe (laut Projektauftrag); ggf. Schlauch, Pflanzsubstrat, Nährstoffkonzentrat, Saatgut bzw. Basilikumpflanzen, Verbindungskabel, Stiftleisten, Messmittel für die manuelle pH-Kontrolle.")

Zwei Positionen gehören nicht zum Steuerkreis des ESP32. Das Growlight wird
über ein eigenes Netzteil versorgt und durch seinen internen Timer geschaltet;
es ist elektrisch vollständig vom übrigen Aufbau getrennt. Das
Handheld-Messgerät diente als Referenz für die Kalibrierung der
Leitfähigkeitsmessung (@kap-kalibrierung) und ist kein Bestandteil des
Demonstrators.

Bewusst nicht enthalten ist eine pH-Sonde. Die pH-Kontrolle erfolgt manuell,
weil Sonden mit ausreichender Messqualität das Budget überschritten hätten
(@kap-abgrenzung).

#todo("Wurde eine Dosierpumpe beschafft? Laut CLAUDE.md „vorgesehen“ — falls gekauft, in die Liste aufnehmen.")
