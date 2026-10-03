#import "../components/formatting.typ": todo
#import "../components/code.typ": codeblock
#import "../components/ai_table.typ": ai_documentation
#import "../components/tables.typ": table_style_1
#import "../dependencies.typ": gls

== Aufgabenverteilung

@tab-aufgaben zeigt, wer für welches Kapitel der Ausarbeitung verantwortlich
ist.

#figure(
  table_style_1(
    table(
      columns: (1fr, auto),
      align: left,
      table.header([Kapitel], [Verantwortlich]),
      [1 Problemstellung und Zielsetzung], [Lyonel Stadthoewer],
      [2 Konzept], [Antonio Steinhauer],
      [3 Bauteilstückliste], [Antonio Steinhauer],
      [4 Bauanleitung], [Lyonel Stadthoewer],
      [5 Testprotokoll], [Antonio Steinhauer],
      [6 Fazit und Ausblick], [Lyonel Stadthoewer],
      [Anhang], [gemeinsam],
    ),
  ),
  caption: [Aufgabenverteilung nach Kapiteln],
) <tab-aufgaben>

== GPIO-Belegung

@tab-gpio zeigt die Pinbelegung des ESP32 DevKit (WROOM, 30 Pin).

#figure(
  table_style_1(
    table(
      columns: (auto, 1fr, auto),
      align: left,
      table.header([Pin], [Funktion], [Modus]),
      [GPIO 4], [Füllstandssensor XKC-Y25-NPN], [`INPUT_PULLUP`, LOW = Wasser],
      [GPIO 5], [DS18B20, OneWire], [4,7 kΩ Pull-up gegen 3V3],
      [GPIO 34], [TDS-Sensor, analog], [ADC1, `ADC_11db`, nur Eingang],
      [GPIO 25], [MOSFET-Board TRIG (Pumpe)], [`OUTPUT`],
      [GPIO 18], [Status-LED grün — Heartbeat], [`OUTPUT`],
      [GPIO 19], [Status-LED gelb — Pumpe läuft], [`OUTPUT`],
      [GPIO 23], [Status-LED rot — Alarm], [`OUTPUT`],
      [GPIO 21], [OLED SDA], [I²C],
      [GPIO 22], [OLED SCL], [I²C],
    ),
  ),
  caption: [GPIO-Belegung des ESP32],
) <tab-gpio>

Die Belegung folgt vier Randbedingungen des ESP32:

- *TDS-Sensor auf ADC1.* Der Analogeingang muss auf ADC1 (GPIO 32–39) liegen.
  ADC2 wird vom #gls("wlan")-Treiber belegt; `analogRead` liefert dort
  unbrauchbare Werte, sobald WLAN aktiv ist. GPIO 34 ist ein reiner Eingang und
  damit für diese Aufgabe geeignet. Der Sensorausgang (0–2,3 V) bleibt unter
  der 3,3-V-Grenze des Eingangs; das Modul selbst benötigt zwingend 5 V.
- *Alarm-LED auf GPIO 23.* GPIO 21 ist durch die SDA-Leitung des
  #gls("i2c")-Busses belegt.
- *Strapping-Pins frei.* GPIO 0, 2, 12 und 15 bleiben unbelegt, da eine Last
  dort den Bootvorgang oder das Flashen blockieren kann. GPIO 5 ist ebenfalls
  ein Strapping-Pin; der Pull-up des OneWire-Busses hält ihn beim Start auf
  High.
- *Füllstandssensor ohne Pegelwandler.* Der Sensor hat einen
  Open-Collector-Ausgang, der bei erkannter Flüssigkeit nach Masse zieht. Den
  High-Pegel stellt der interne Pull-up des ESP32 mit 3,3 V her.

== Strombilanz

Das Growlight (2 A) läuft über sein eigenes Netzteil und geht nicht in die
Bilanz ein (@tab-strombilanz).

#figure(
  table_style_1(
    table(
      columns: (1fr, auto),
      table.header([Verbraucher], [Stromaufnahme]),
      table.cell(colspan: 2, align: left, emph[USB-Netzteil Pumpe (5 V / 2 A)]),
      [Pumpe, Betrieb], [ca. 0,5 A],
      [Pumpe, Anlauf (kurzzeitig)], [+1,0 A Spitze],
      [*Spitze beim Pumpenanlauf*], [*max. ca. 1,5 A*],
      table.hline(stroke: 0.7pt),
      table.cell(colspan: 2, align: left, emph[USB-Netzteil ESP32]),
      [ESP32], [0,08–0,25 A],
      [TDS-Modul], [0,01 A],
      [DS18B20 und Füllstandssensor], [< 0,01 A],
      [3 Status-LEDs], [0,02 A],
      [*Summe (rechnerisch)*], [*ca. 0,11–0,29 A*],
    ),
  ),
  caption: [Strombilanz der USB-Netzteile],
) <tab-strombilanz>

== Firmware
#figure(
  codeblock("../res/firmware.txt", "cpp"),
  caption: [Firmware des ESP32],
) <lst-firmware>

// Pflicht laut NAK, falls KI genutzt wurde. Nur tatsächliche Anfragen eintragen.
#let ki_software = "Claude Code (Claude Opus 5.5, Anthropic)"
#ai_documentation(
  entries: (
    (
      query: "Ausformulieren der Kapitel 1–6 aus eigenen Projektdaten (Messwerte, Testbeobachtungen, Firmware, Fotos, Entscheidungen)",
      date: "2026-10-03",
      reason: "Strukturierung und sprachliche Ausarbeitung bei knapper Frist",
      quality: "Alle Inhalte gegen das eigene Projekt geprüft. Mehrere sachliche Fehler korrigiert (Stromversorgung des ESP32, Anordnung von Reservoir und Elektronik, Kabel- und Schlauchführung). Keine Messwerte von der KI übernommen, alle Zahlen stammen aus eigenen Messungen.",
      software: ki_software,
    ),
    (
      query: "Beschreibung der Firmware aus dem eigenen Quellcode",
      date: "2026-10-03",
      reason: "Zusammenfassung von Bibliotheken, Messablauf und Verriegelung",
      quality: "Mit dem Quellcode abgeglichen",
      software: ki_software,
    ),
    (
      query: "Typst-Umsetzung von Tabellen und Diagrammen (Systemarchitektur, Leistungspfad)",
      date: "2026-10-03",
      reason: "Satz und Layout",
      quality: "Schaltplan auf korrekte Verdrahtung geprüft und korrigiert",
      software: ki_software,
    ),
    (
      query: "Kürzung auf maximal 15 Seiten",
      date: "2026-10-03",
      reason: "Umfangsvorgabe",
      quality: "Streichungen einzeln ausgewählt und freigegeben",
      software: ki_software,
    ),
  ),
)
