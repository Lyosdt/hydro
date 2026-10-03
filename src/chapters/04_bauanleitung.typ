#import "../components/formatting.typ": todo, bild_platzhalter
#import "../components/tables.typ": table_style_1
#import "../dependencies.typ": diagram, node, edge, gls

// Kapitel 4 — Budget: 3,5 Seiten
// Pflichtbestandteile: Bauanleitung, Schaltpläne und/oder Fotos
// Anleitung im Präsens/Passiv, durchgeführte Arbeiten und Beobachtungen im Präteritum.

= Bauanleitung <kap-bauanleitung>

== Mechanischer Aufbau

Der mechanische Aufbau folgt dem #gls("nft")-Prinzip: Die Pflanzen sitzen in
Netztöpfen in einer leicht geneigten Anbaurinne. Die Pumpe fördert die
Nährlösung aus dem Reservoir an das obere Ende der Rinne, von dort fließt sie
als dünner Film an den Wurzeln entlang und zurück in das Reservoir.

Der Füllstandssensor arbeitet berührungslos und erkennt die Flüssigkeit durch
eine nichtmetallische Behälterwand hindurch. Er wird außen am Reservoir
befestigt; seine Montagehöhe legt den Mindestfüllstand fest, unterhalb dessen
die Pumpe gesperrt wird.

#todo("Angaben zum Aufbau: Material und Länge der Rinne, Neigung, Anzahl Netztöpfe, Volumen des Reservoirs, Schlauchführung, Montagehöhe des Füllstandssensors, Position von Temperatur- und TDS-Sonde (im Reservoir?)")

#figure(
  bild_platzhalter("Foto des Gesamtaufbaus (Rinne, Reservoir, Elektronik)"),
  caption: [Gesamtaufbau des Demonstrators],
) <fig-aufbau>

== Schaltplan und Leistungspfad <kap-schaltplan>

Die Schaltung besteht aus drei Kreisen (@fig-leistungspfad): dem Lichtkreis,
dem Leistungspfad der Pumpe und dem Steuerkreis um den ESP32. Der Lichtkreis
ist vollständig getrennt. Das Growlight wird über ein eigenes Netzteil versorgt
und durch seinen internen Timer geschaltet; es besteht keine Verbindung zum
ESP32.

#figure(
  {
    set text(size: 9pt)
    diagram(
      spacing: (12mm, 9mm),
      node-stroke: 0.6pt,
      node-corner-radius: 2pt,
      node-inset: 6pt,
      node-shape: rect,
      node((0, 0), align(center)[USB-Netzteil\ 5 V / 2 A], name: <d-psu>),
      node((2, 0), align(center)[MOSFET-Board\ P2003BDG], name: <d-mos>),
      node((4, 0), align(center)[Pumpe\ 5 V], name: <d-pump>),
      node((4, 1), align(center)[1N4007\ Freilaufdiode], name: <d-diode>),
      node((2, 1), align(center)[5-V-Schiene\ Steckbrett], name: <d-rail>),
      node((3, 1), [ESP32], name: <d-esp>),
      node((1.5, 2), [1000 µF], name: <d-cap>),
      node((2.5, 2), [TDS-Modul], name: <d-tds>),
      node((0, 3), align(center)[Netzteil\ Growlight], name: <d-lpsu>),
      node((4, 3), align(center)[Growlight\ (Timer 12 h)], name: <d-light>),
      edge(<d-psu>, <d-mos>, "-|>", [VIN]),
      edge(<d-mos>, <d-pump>, "-|>", [VOUT]),
      edge(<d-pump>, <d-diode>, "-", [parallel], label-side: left),
      edge(<d-mos>, <d-rail>, "-|>", [VIN], label-side: right),
      edge(<d-rail>, <d-cap>, "-"),
      edge(<d-rail>, <d-tds>, "-|>"),
      edge(<d-rail>, <d-esp>, "-|>", [5V], label-side: right),
      edge(<d-esp>, <d-mos>, "--|>", [GPIO 25 → TRIG], label-side: right),
      edge(<d-lpsu>, <d-light>, "-|>", [keine Verbindung zum ESP32]),
    )
  },
  caption: [Leistungspfad und Versorgung (vereinfacht, gemeinsame Masse nicht dargestellt)],
) <fig-leistungspfad>

Das USB-Netzteil speist über einen USB-A-Pigtail mit Stecker den Eingang (VIN)
des #gls("mosfet")-Boards. Am Ausgang (VOUT) sitzt ein USB-A-Pigtail mit
Buchse, in die die Pumpe mit ihrem originalen Stecker eingesteckt wird. Von VIN
wird zusätzlich die 5-V-Schiene des Steckbretts versorgt, an der das TDS-Modul
und, im Betrieb ohne angeschlossenen Rechner, der ESP32 über seinen 5-V-Pin
hängen. Der ESP32 steuert das Board über GPIO 25 am Eingang TRIG an. Über
diesen Pin fließt nur der Gate-Steuerstrom im Mikroampere-Bereich; den
Pumpenstrom führt der ESP32 zu keinem Zeitpunkt.

Der P2003BDG ist ein Logic-Level-MOSFET mit einer Schwellspannung von 1–3 V und
schaltet bei 3,3 V Gate-Spannung vollständig durch. Darin unterscheidet er sich
von den verbreiteten IRF520-Boards, die bei 3,3 V nur teilweise durchsteuern.
Drei Schutzmaßnahmen ergänzen den Leistungspfad (@tab-schutz).

#figure(
  table_style_1(
    table(
      columns: (auto, 1fr),
      align: left,
      table.header([Maßnahme], [Zweck]),
      [1N4007 über der Pumpe\ (Kathodenring an +)],
      [Freilaufdiode. Die Motorspule erzeugt beim Abschalten eine Gegenspannung weit über der 25-V-Grenze des MOSFET; die Diode schließt sie kurz.],
      [1000 µF an VIN],
      [Puffert den Anlaufstrom der Pumpe, damit die 5-V-Schiene nicht einbricht und den ESP32 zurücksetzt.],
      [Gemeinsame Masse],
      [Das Board schaltet low-side und benötigt denselben Bezugspunkt wie der ESP32.],
    ),
  ),
  caption: [Schutzmaßnahmen im Leistungspfad],
) <tab-schutz>

@tab-strombilanz zeigt die Strombilanz am USB-Netzteil. Selbst im ungünstigsten
Fall, wenn der Anlaufstrom der Pumpe zum vollen Betriebsstrom aller Verbraucher
hinzukommt, bleibt die Spitze mit ca. 1,8 A unter den 2 A des Netzteils. Das
Growlight (2 A) läuft über sein eigenes Netzteil und geht nicht in die Bilanz
ein.

#figure(
  table_style_1(
    table(
      columns: (1fr, auto),
      table.header([Verbraucher], [Stromaufnahme]),
      [Pumpe, Betrieb], [ca. 0,5 A],
      [Pumpe, Anlauf (kurzzeitig)], [+1,0 A Spitze],
      [ESP32], [0,08–0,25 A],
      [TDS-Modul], [0,01 A],
      [DS18B20 und Füllstandssensor], [< 0,01 A],
      [3 Status-LEDs], [0,02 A],
      table.hline(stroke: 0.7pt),
      [*Summe Dauerbetrieb (rechnerisch)*], [*0,61–0,79 A*],
      [*Spitze beim Pumpenanlauf*], [*max. ca. 1,8 A*],
    ),
  ),
  caption: [Strombilanz am USB-Netzteil],
) <tab-strombilanz>

#todo("Summen prüfen: CLAUDE.md nennt ~0,9 A Dauer und ~1,5 A Spitze; aus den Einzelwerten ergeben sich 0,61–0,79 A und — falls „+1,0 A“ zusätzlich zum Betriebsstrom gemeint ist — bis ca. 1,8 A. Ist +1,0 A zusätzlich oder 1,0 A Gesamtspitze der Pumpe?")

#figure(
  bild_platzhalter("Foto der Verdrahtung (Steckbrett, MOSFET-Board, ESP32) oder Schaltplan aus Fritzing/KiCad"),
  caption: [Verdrahtung von Steuer- und Leistungskreis],
) <fig-verdrahtung>

== Verdrahtung und GPIO-Belegung

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

Jede Status-LED ist mit einem 220-Ω-Vorwiderstand beschaltet.

== Inbetriebnahme

Die Inbetriebnahme erfolgt schrittweise, die Pumpe wird zuletzt angeschlossen:

+ *Firmware aufspielen.* Vor dem ersten Flashen prüfen, dass die Strapping-Pins
  unbelegt sind.
+ *Display prüfen.* Die Stiftleisten des #gls("oled")-Displays müssen verlötet
  sein. Solange sie nur gesteckt waren, fand der I²C-Bus-Scan kein Gerät.
  Erwartet wird die Adresse 0x3C. #todo("I²C-Adresse durch Bus-Scan bestätigen")
+ *Sensoren prüfen.* Der Temperatursensor muss einen plausiblen Wert liefern;
  der Füllstandseingang muss beim Füllen und Leeren des Reservoirs den Pegel
  wechseln.
+ *Leitfähigkeit kalibrieren* (@kap-kalibrierung).
+ *Pumpe anschließen und Verriegelung prüfen.* Bei leerem Reservoir darf die
  Pumpe nicht anlaufen.

Die Ergebnisse dieser Prüfungen sind in @kap-testprotokoll dokumentiert.

== Kalibrierung der EC-Messung <kap-kalibrierung>

Der #gls("tds")-Sensor liefert eine Spannung, die mit der elektrischen
Leitfähigkeit der Lösung steigt. Da die Leitfähigkeit stark von
der Temperatur abhängt, wird die gemessene Spannung $U$ mit der Temperatur $T$
des DS18B20 auf 25 °C bezogen:

$ U_"komp" = U / (1 + alpha (T - 25 "°C")), quad alpha = "0,02" "/°C" $

Kalibriert wurde an drei Punkten gegen das Handheld-Messgerät (@tab-kalibrierung).

#figure(
  table_style_1(
    table(
      columns: 4,
      table.header([Punkt], [$U$ gemessen], [$U_"komp"$], [Handheld]),
      [niedrig], [0,6200 V], [0,6703 V], [662 µS/cm],
      [mittel], [0,9560 V], [1,0349 V], [1164 µS/cm],
      [hoch], [1,5390 V], [1,6660 V], [2282 µS/cm],
    ),
  ),
  caption: [Kalibrierpunkte der Leitfähigkeitsmessung],
) <tab-kalibrierung>

Eine Gerade durch die beiden äußeren Punkte verfehlt den mittleren Punkt um
+7,8 %. Der Zusammenhang ist im Messbereich also nicht linear. Verwendet wird
daher eine quadratische Funktion, die exakt durch alle drei Punkte verläuft:

$ "EC" = "396,3" dot U_"komp"^2 + "701,1" dot U_"komp" + "14,0" quad [µ"S/cm"] $

Die Funktion gilt zwischen ca. 650 und 2300 µS/cm; außerhalb dieser Spanne ist
sie nicht belastbar. Der Zielbereich für Basilikum (1,0–1,6 mS/cm) liegt
vollständig darin.

Eine Referenzlösung (1413 µS/cm) stand nicht zur Verfügung, sodass das
Handheld-Messgerät nicht gegen einen Normal geprüft werden konnte. Die
EC-Skala des Systems ist damit relativ zum Handheld-Gerät; ein systematischer
Fehler des Referenzgeräts würde unerkannt übernommen. Für die Demonstration des
relativen Verlaufs, etwa des Anstiegs der Leitfähigkeit, während die Pflanzen
Wasser aufnehmen, ist das ausreichend.

== Software

Die Firmware ist im Arduino-Framework für den ESP32 geschrieben. Die
Hauptschleife liest zyklisch Füllstand, Temperatur und Sensorspannung, berechnet
daraus die temperaturkompensierte Leitfähigkeit, wertet die Alarmbedingungen aus
und setzt Pumpenausgang, Status-LEDs und Anzeige. Die Bedeutung der Status-LEDs
ist in @kap-statuslogik beschrieben.

Der Pumpenausgang wird in jedem Schleifendurchlauf aus der Bedingung
`wantPump && waterPresent()` gesetzt. `wantPump` ist der Sollzustand aus dem
Pumpenzeitplan, `waterPresent()` der aktuelle Zustand des Füllstandssensors.
Es gibt keinen Pfad, über den die Pumpe ohne aktive Füllstandsprüfung anläuft.
Diese Verriegelung ist der zentrale Hardwareschutz des Systems.

#todo("Pumpenzeitplan: Dauerbetrieb (passend zu NFT) oder 15 min an / 45 min aus wie in der aufgespielten Firmware? Widerspruch aus CLAUDE.md vorher klären.")

#todo("Firmware-Datei bereitstellen: verwendete Bibliotheken, Entwicklungsumgebung, Anzeigeinhalt des OLED, Nutzung von WLAN — und Kernausschnitt der Verriegelung als Listing.")

Der vollständige Quellcode befindet sich im Anhang.
