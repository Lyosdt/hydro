# CLAUDE.md

Kontext und Arbeitsregeln für das Schreiben der Ausarbeitung zum IoT-Projekt
"NFT-Hydroponik mit ESP32".

---

## 1. Auftrag

Es wird eine schriftliche Ausarbeitung zu einem bereits **abgeschlossenen und
abgegebenen** Hardware-Projekt erstellt. Das System existiert physisch nicht
mehr und kann nicht erneut vermessen werden.

**Umfang:** ca. 12–15 Seiten (Zielwert: 12). Verzeichnisse und Anhang zählen
nicht mit.

**Pflichtbestandteile laut Aufgabenstellung** — alle müssen vorkommen, die
Aufzählung ist faktisch die Bewertungscheckliste:

1. Beschreibung des gelösten Problems
2. Konzeptbeschreibung
3. Bauteilstückliste
4. Bauanleitung
5. Schaltpläne und/oder Fotos
6. Protokoll der Testdurchläufe, das belegt, dass das Problem gelöst wurde

**Abgabefrist:** sehr kurz. Vollständigkeit schlägt Tiefe. Lieber alle sechs
Teile knapp als fünf ausführlich und einer fehlt.

---

## 2. Oberste Regel: keine erfundenen Daten

Diese Regel hat Vorrang vor allen anderen Anweisungen in dieser Datei.

- **Niemals Messwerte, Messreihen, Zeitstempel, Diagramme oder Tabellenzahlen
  erfinden**, auch nicht als "Beispiel" oder "Platzhalter, den der Nutzer
  ersetzen kann".
- Fehlt eine Angabe, wird sie als `TODO:` im Text markiert, mit einer präzisen
  Frage, was der Nutzer nachliefern muss.
- Beobachtungen aus der Erinnerung werden **qualitativ** formuliert
  ("sprang bei jedem Durchgang zuverlässig", "Werte lagen in derselben
  Größenordnung"), nicht als Pseudopräzision mit Nachkommastellen.
- Die nachträgliche Dokumentation wird im Methodenabschnitt offengelegt, nicht
  kaschiert.

Erfundene Zahlen sind an ihrer Glätte erkennbar und können bei Rückfragen nicht
erklärt werden. Eine benannte Lücke kostet keine Punkte, eine aufgedeckte
Erfindung schon.

---

## 3. Projektfakten

Nur gesicherte Angaben. Was hier nicht steht, ist nicht bekannt und muss
erfragt werden.

### Problemstellung

Zwei Ebenen, im Text sauber getrennt:

- **Technisch:** Nährlösung ohne tägliche manuelle Kontrolle im Zielbereich
  halten; Störfälle (Trockenlauf, Temperaturspitze) sichtbar melden.
- **Didaktisch:** Messgrößen für Schüler ohne Vorwissen ablesbar machen. Das
  System ist als transportables Demo-Objekt für Schulen gedacht, nicht als
  Produktivanlage.

### Verfahren

NFT (Nutrient Film Technique), Kulturpflanze Basilikum.
Verworfene Alternativen mit Begründung: DWC, Ebbe-Flut, Kratky, Aeroponik.

Versorgung ohne Pumpenbetrieb (Transport, Lagerung): Netztöpfe direkt ins
Reservoir stellen, passiv nach dem Kratky-Prinzip (Kapitel 4).

### Hardware

| Komponente | Typ | Details |
|---|---|---|
| Controller | ESP32 DevKit (WROOM, 30 Pin) | |
| Leitfähigkeit | analoger TDS-Sensor (Gravity-Bauform) | 5 V Versorgung zwingend, Ausgang 0–2,3 V |
| Temperatur | DS18B20, wasserdicht | OneWire, 4,7 kΩ Pull-up gegen 3V3 erforderlich |
| Füllstand | XKC-Y25-NPN, berührungslos | Open-Collector, LOW = Flüssigkeit erkannt |
| Pumpe | 5 V Wasserpumpe, USB-A-Stecker | über MOSFET geschaltet |
| Beleuchtung | 5 V LED-Growlight, 2 A | **eigenes Netzteil, eigener interner Timer — nicht vom ESP32 geschaltet** |
| Anzeige | OLED SSD1306, 128×32, I²C | |
| Status-LEDs | 3 Stück, je 220 Ω | grün / gelb / rot |
| Schaltelement | P2003BDG MOSFET-Trigger-Board | N-Channel Logic Level, Vgs(th) 1–3 V, 25 V / 28 A, Rds(on) 20 mΩ @ 10 V |
| Referenz | Handheld-TDS/EC-Messgerät | |

### Mechanik und Pflanzen

| Komponente | Details |
|---|---|
| Holzplatte | Grundplatte |
| Rohr | Anbaurinne, Netztöpfe in Öffnungen |
| Schraubschellen | Befestigung des Rohrs |
| Netztöpfe | Anzahl unbekannt |
| 2 Plastikboxen | eine als Reservoir, eine als Elektronikgehäuse |
| Schlauch | Förderleitung |
| Blähton | Substrat |
| Basilikumsetzlinge | Anzahl unbekannt |

Der P2003BDG ist ausdrücklich ein **Logic-Level-MOSFET** und schaltet bei
3,3 V Gate-Spannung durch. Das ist der wesentliche Unterschied zu den häufig
verwendeten IRF520-Boards, die bei 3,3 V nur teilweise durchsteuern.

### GPIO-Belegung

| Pin | Funktion | Modus |
|---|---|---|
| GPIO 4 | XKC-Y25-NPN Füllstand | `INPUT_PULLUP`, LOW = Wasser |
| GPIO 5 | DS18B20 OneWire | Pull-up 4,7 kΩ; zugleich Strapping-Pin |
| GPIO 34 | TDS analog | ADC1, `ADC_11db`, Input-only |
| GPIO 25 | MOSFET TRIG (Pumpe) | `OUTPUT` |
| GPIO 18 | Status-LED grün — Heartbeat | `OUTPUT` |
| GPIO 19 | Status-LED gelb — Pumpe läuft | `OUTPUT` |
| GPIO 23 | Status-LED rot — Alarm | `OUTPUT` |
| GPIO 21 | OLED SDA | I²C |
| GPIO 22 | OLED SCL | I²C |

Begründungen, die in Kapitel 4 gehören:

- **TDS zwingend auf ADC1 (GPIO 32–39).** ADC2 wird vom WLAN-Treiber belegt;
  `analogRead` liefert dort unbrauchbare Werte, sobald WLAN aktiv ist.
- **Alarm-LED auf GPIO 23 statt 21**, weil GPIO 21 vom I²C-Bus für SDA belegt
  wird.
- **Strapping-Pins 0, 2, 12, 15 unbelegt**, da eine Last dort den Bootvorgang
  oder das Flashen blockieren kann.

### Schaltplan — Leistungspfad

```
Netzteil Growlight ──── Growlight (eigener Timer, 12 h)
                        keine Verbindung zum ESP32

USB-Netzteil 2 A ──[USB-A-Pigtail männl.]── MOSFET VIN+ / VIN−
                                                   │
                        MOSFET VOUT+ / VOUT− ──[USB-A-Pigtail weibl.]── Pumpe
                                   │
                              1N4007 über VOUT, Kathodenring Richtung +

MOSFET VIN ──── 1000 µF (Streifen an −)

USB-Netzteil ESP32 ──[USB]── ESP32 ── 5V-Pin ── TDS-Modul 5 V

MOSFET TRIG ──── ESP32 GPIO 25
MOSFET GND  ──── ESP32 GND   (gemeinsame Masse trotz getrennter Netzteile)
```

**ESP32 hat ein eigenes USB-Netzteil** (vom Nutzer bestätigt). Das
TDS-Modul hängt am 5-V-Pin des ESP32, nicht am Pumpenkreis.

Drei Schutzmaßnahmen, die im Text begründet werden müssen:

| Bauteil | Zweck |
|---|---|
| 1N4007 über der Pumpe | Freilaufdiode; die Motorspule erzeugt beim Abschalten eine Gegenspannung weit über der 25-V-Grenze des MOSFET |
| 1000 µF an VIN | puffert den Anlaufstrom der Pumpe, damit die Spannung des Pumpen-Netzteils nicht einbricht |
| gemeinsame Masse | das MOSFET-Board schaltet low-side und benötigt denselben Bezugspunkt wie der ESP32 |

**Der ESP32 führt zu keinem Zeitpunkt den Pumpenstrom.** Über GPIO 25 fließt
nur der Gate-Steuerstrom im Mikroampere-Bereich.

### Strombilanz

| Netzteil | Verbraucher | Aufnahme |
|---|---|---|
| Pumpe (5 V / 2 A) | Pumpe, Betrieb | ~0,5 A |
| | Pumpe, Anlauf (kurz) | +1,0 A Spitze → max. ~1,5 A |
| ESP32 | ESP32 | 0,08–0,25 A |
| | TDS-Modul | 0,01 A |
| | DS18B20 + Füllstandssensor | <0,01 A |
| | 3 Status-LEDs | 0,02 A |
| | **Summe** | **~0,11–0,29 A** |

Die Einzelwerte sind vom Nutzer bestätigt, die Summen wurden nach der Trennung
der Netzteile neu gerechnet.

Das Growlight (2 A) läuft über sein eigenes Netzteil und geht nicht in diese
Bilanz ein.

### Statuslogik

| LED | Verhalten | Aussage |
|---|---|---|
| grün (GPIO 18) | kurzer Blitz alle 2 s | Hauptschleife läuft |
| gelb (GPIO 19) | folgt dem Pumpenausgang | Pumpe geschaltet |
| rot (GPIO 23) | an bei Alarm | Füllstand niedrig, Temperatur außerhalb 18–24 °C, oder Temperatursensor ohne Antwort |

Der Heartbeat ist bewusst ein Blinken und kein Dauerlicht: Dauerlicht wäre
nicht von einem Absturz mit hängengebliebenem Ausgangspegel unterscheidbar.

**Verriegelung:** Der Pumpenausgang wird in derselben Bedingung ausgewertet, die
ihn setzt (`wantPump && waterPresent()`), und zwar in jedem Schleifendurchlauf.
Es existiert kein Pfad, über den die Pumpe ohne aktive Füllstandsprüfung
anläuft. Das ist der zentrale Hardwareschutz des Systems.

### Kalibrierung EC

Dreipunktkalibrierung gegen das Handheld-Messgerät, temperaturkompensiert auf
25 °C mit 2 %/°C. Gemessene Wertepaare:

| Punkt | U gemessen | U kompensiert | Handheld |
|---|---|---|---|
| niedrig | 0,6200 V | 0,6703 V | 662 µS/cm |
| mittel | 0,9560 V | 1,0349 V | 1164 µS/cm |
| hoch | 1,5390 V | 1,6660 V | 2282 µS/cm |

Eine lineare Ausgleichsgerade über den äußeren Punkten verfehlt den Mittelpunkt
um +7,8 %. Verwendet wurde daher die quadratische Anpassung durch alle drei
Punkte:

```
EC [µS/cm] = 396,3 · U² + 701,1 · U + 14,0      (U = kompensierte Spannung)
```

Gültigkeitsbereich ca. 650–2300 µS/cm. Außerhalb dieser Spanne ist die
Anpassung nicht belastbar.

**Einschränkung, die offengelegt werden muss:** Eine Referenzlösung
(1413 µS/cm) stand nicht zur Verfügung. Das Handheld-Gerät konnte daher nicht
gegen einen Normal verifiziert werden. Die EC-Skala des Systems ist relativ zum
Handheld-Gerät, ein systematischer Fehler des Referenzgeräts würde unerkannt
übernommen. Für die Demonstration des relativen Verlaufs (EC steigt, während
die Pflanzen Wasser aufnehmen) ist das ausreichend.

### Zielbereiche Basilikum

| Größe | Bereich |
|---|---|
| EC | 1000–1600 µS/cm |
| pH | 5,5–6,5 (im Projekt nicht gemessen) |
| Wassertemperatur | 18–24 °C |
| Beleuchtung | 12 h (Timer des Growlights) |

### Bewusste Abgrenzungen

- **Keine pH-Messung** — pH-Sonden mit ausreichender Qualität sprengen das
  Budget; eine driftende Billigsonde in einem Regelkreis ist riskanter als gar
  keine. Der pH-Wert wurde im Projekt auch manuell nicht gemessen (Limitation
  im Fazit).
- **Keine automatische Dosierung** — keine Dosierpumpe beschafft (nicht im
  Budget), Regelkreis bewusst nicht geschlossen.
- **Budget ca. 100 €** (Erstattungsgrenze der Hochschule).

### Offen — vom Nutzer zu klären

- I²C-Adresse des OLED: 0x3C, so im Quellcode (geklärt).
- `TODO:` tatsächliche Einzelpreise und Bezugsquellen für die Stückliste
- Gruppe: Lyonel Stadthoewer, Antonio Steinhauer. Aufgabenverteilung je
  Kapitel als Tabelle im Anhang (`tab-aufgaben`): Stadthoewer 1, 4, 6;
  Steinhauer 2, 3, 5; Anhang gemeinsam (je ca. 7,5 Seiten).

### Zu klärende Widersprüche

1. **NFT und Pumpentaktung — entschieden:** Die Firmware bleibt bei
   15 min an / 45 min aus. Der Text beschreibt den Aufbau als NFT mit
   Intervallbetrieb der Pumpe und legt die Abweichung vom klassischen
   Dauerbetrieb offen. Begründung der Taktung: geringerer Stromverbrauch und
   bessere Wurzelbelüftung in den Pausen.
2. **Projektstatus — geklärt:** Das System ist abgegeben. Verlötung des
   Displays, Kalibrierung und alle Tests fanden vor der Abgabe statt.

### Firmware und Tests (vom Nutzer bestätigt)

- Firmware: `src/res/firmware.txt`. Kein WLAN, rein lokaler Betrieb.
- T1 Temperatur: in kaltem und warmem Wasser getestet, rote LED hat reagiert.
  Kein Referenzthermometer.
- T3: rote LED hat reagiert. Wasserkreislauf hat funktioniert.
- NFT bestätigt (Nutzer, nicht Ebbe-Flut).
- Aufbau: vorne offene Holzbox (keine Holzplatte), Rohr leicht schräg an der
  Rückwand, 4 Netztöpfe/4 Pflanzen. Unten in der Box (laut Foto
  `src/res/HydroAufbau.jpg`) links Reservoir, rechts Elektronikbox; Display nach vorne; Growlight oben angeschraubt, Timer rechts;
  3 USB-Kabel hinten raus. Sensoren lose (für Vorführung beweglich).
  Pflanzen aus Stecklingen in Wasser bewurzelt. Holzbox aus Holzbrettern
  selbst gebaut. Schlauch führt durch ein passendes Loch in der Box.
- Kratky-Überbrückung ohne Pumpe: im Projekt nicht erprobt, bleibt als
  Empfehlung im Text.
- T2 EC: Die Dreipunktkalibrierung war der Test; keine weitere Kontrollmessung.
- T3 Füllstand: Sensor an der Wand über/unter den Wasserspiegel bewegt.
- T4 Pumpe: reagiert auf den Füllstandssensor, Takt passt, mit 1000-µF-Kondensator
  kein Reset; ohne Kondensator nicht getestet.
- Keine weiteren Tests, keine Erprobung mit Schülern.

---

## 4. Gliederung mit Seitenbudget

| Kapitel | Seiten | Inhalt |
|---|---|---|
| 1 Problemstellung und Zielsetzung | 2 | Ausgangslage, Zielkriterien K1–K6 in prüfbarer Form, Abgrenzung |
| 2 Konzept | 3 | Verfahrensvergleich mit Begründung, Systemarchitektur, Sensorik/Aktorik, Statuslogik |
| 3 Bauteilstückliste | 1,5 | Tabelle: Bezeichnung, Typ, Stückzahl, Bezugsquelle, Preis, Summe |
| 4 Bauanleitung | 3,5 | Mechanik, Schaltplan, Verdrahtung, Inbetriebnahme, Kalibrierung, Software |
| 5 Testprotokoll | 3 | Methodenhinweis, Testfälle, Beobachtungen, Soll-Ist-Abgleich |
| 6 Fazit und Ausblick | 1 | Erfüllte Kriterien, Limitationen, nächste Ausbaustufe |

**Schreibreihenfolge:** 3 und 4 zuerst (reines Faktenwissen, schnell auf
Seitenzahl), dann 5, dann 1 und 2, zuletzt 6.

Kapitel 1 definiert die Kriterien K1–K6, Kapitel 5 prüft **genau diese**
Kriterien ab, Kapitel 6 fasst das Ergebnis zusammen. Diese Kette muss
durchgängig sein — sonst ist der geforderte Nachweis nicht erbracht.

---

## 5. Testprotokoll — Format

Ein Block je Testfall, einheitlich:

| Feld | Inhalt |
|---|---|
| ID und Bezeichnung | T2 — Abgleich TDS-Sensor gegen Handheld-Messgerät |
| Zeitraum | ungefähre Angabe genügt |
| Prüfkriterium | Verweis auf K-Nummer aus Kapitel 1 |
| Vorgehen | was konkret getan wurde |
| Beobachtung | qualitativ, ohne erfundene Zahlen |
| Bewertung | erfüllt / teilweise erfüllt / nicht geprüft |

Kapitel 5 beginnt mit einem Methodenabsatz: Tests wurden begleitend während der
Aufbauphase durchgeführt, die Dokumentation erfolgte nachträglich anhand von
Fotos und Notizen, eine kontinuierliche Datenaufzeichnung fand nicht statt.

Belegte Testfälle (Details vom Nutzer): Temperatursensor geprüft, TDS gegen
Handheld verglichen, Füllstandssensor ein/aus, Pumpenbetrieb.

---

## 6. Schreibstil

- Sprache Deutsch, sachlich, wissenschaftlich, Präteritum für durchgeführte
  Arbeiten.
- Kein "wir haben dann mal", keine Werbesprache, keine Füllfloskeln.
- Fachbegriffe bei Erstnennung einmal erklären (EC, ppm, NFT, TDS).
- EC in mS/cm als Leitgröße; ppm nur mit Umrechnungsfaktor ("900 ppm @ 500").
- Tabellen und Diagramme statt Fließtextaufzählungen, wo es passt.
- Jede Abbildung bekommt Nummer, Unterschrift und mindestens einen Verweis im
  Text.
- Keine Blähsätze zum Füllen der Seitenzahl. Wenn Umfang fehlt, fehlt Inhalt —
  dann nachfragen, nicht strecken.

---

## 7. Arbeitsweise in diesem Projekt

- Ein Kapitel pro Durchgang, nicht das ganze Dokument auf einmal.
- Vor dem Schreiben eines Kapitels: fehlende Fakten aus Abschnitt 3 abfragen.
- Nach jedem Kapitel: geschätzte Seitenzahl nennen und gegen das Budget
  abgleichen.
- Bestehende Abschnitte nicht ohne Auftrag umschreiben.
- Am Ende jedes Durchgangs offene `TODO:`-Marker auflisten.

### Dateistruktur

Typst-Vorlage (NAK), Einstieg `src/main.typ`, Build: `typst compile src/main.typ`.
Keine wissenschaftliche Arbeit: Quellen nicht gefordert, kein Literaturverzeichnis.

```
src/main.typ                         Deckblattdaten, Kapitel-Includes, Schalter `entwurf`
src/chapters/01_problemstellung.typ
src/chapters/02_konzept.typ
src/chapters/03_stueckliste.typ
src/chapters/04_bauanleitung.typ
src/chapters/05_testprotokoll.typ
src/chapters/06_fazit.typ
src/chapters/99_anhang.typ           Firmware, Fotos, KI-Dokumentation
src/components/testprotokoll.typ     `testfall(...)` nach Format Abschnitt 5
src/components/stueckliste.typ       `stueckliste(...)` mit automatischer Summe
src/components/formatting.typ        `todo(...)` — sichtbarer TODO-Marker
src/abbreviations.typ                Abkürzungen, Verwendung mit @key
src/res/                             Bilder, Firmware-Quellcode
```

`TODO:`-Marker im Text immer über `#todo("...")` setzen. Mit `entwurf: false`
in `main.typ` bricht die Kompilierung ab, solange noch Marker offen sind.

---

## 8. Was nicht zu tun ist

- Keine Messdaten, Diagramme oder Zeitreihen erzeugen, die nicht vom Nutzer
  stammen.
- Keinen Langzeitversuch beschreiben, der nicht stattgefunden hat.
- Keine Komponenten in die Stückliste aufnehmen, die nicht in Abschnitt 3
  stehen.
- Keine pH-Regelung, keine automatische Dosierung darstellen — beides war
  bewusst nicht Teil des Systems.
- Lücken nicht durch plausibel klingende Formulierungen überdecken, sondern als
  Limitation im Fazit benennen.