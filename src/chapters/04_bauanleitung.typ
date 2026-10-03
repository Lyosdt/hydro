#import "../components/formatting.typ": todo, bild_platzhalter
#import "../components/tables.typ": table_style_1
#import "../dependencies.typ": diagram, node, edge, gls

// Kapitel 4 — Budget: 3,5 Seiten
// Pflichtbestandteile: Bauanleitung, Schaltpläne und/oder Fotos
// Anleitung im Präsens/Passiv, durchgeführte Arbeiten und Beobachtungen im Präteritum.

= Bauanleitung <kap-bauanleitung>

== Mechanischer Aufbau

Der mechanische Aufbau folgt dem #gls("nft")-Prinzip: Die Pflanzen sitzen in
Netztöpfen, die in Öffnungen eines leicht geneigten Rohrs eingesetzt sind. Die
Pumpe fördert die Nährlösung über einen Schlauch aus dem Reservoir an das obere
Ende des Rohrs, von dort fließt sie als dünner Film an den Wurzeln entlang und
zurück in das Reservoir. Abweichend vom Dauerbetrieb des klassischen NFT läuft
die Pumpe im Intervall (@kap-software).

Den Rahmen bildet eine vorne offene, aus Holzbrettern selbst gebaute Holzbox
(@fig-aufbau):

- *Anbaurinne.* Das Rohr ist mit Schraubschellen leicht schräg an der
  Rückwand der Box befestigt und trägt vier Netztöpfe.
- *Beleuchtung.* Das Growlight ist oben in der Box angeschraubt, sein
  Zeitschalter sitzt rechts.
- *Reservoir und Elektronik.* Unter der Holzbox stehen links das Reservoir und
  rechts das Elektronikgehäuse, beide aus je einer Kunststoffbox. Im Gehäuse
  sind ESP32, Steckbrett und MOSFET-Board untergebracht; das Display ist nach
  vorne ausgerichtet.
- *Leitungsführung.* Der Förderschlauch führt durch ein passendes Loch in der
  Holzbox vom Reservoir zum Rohr. Die drei USB-Kabel der Versorgung werden
  hinten herausgeführt, sodass die Vorderseite frei bleibt.

Die Sensoren sind für Präsentationszwecke nicht fest verbaut. Temperatursensor
und TDS-Elektrode hängen lose im Reservoir, der Füllstandssensor wird außen an
die Reservoirwand gehalten. Er arbeitet berührungslos und erkennt die
Flüssigkeit durch die nichtmetallische Behälterwand hindurch; seine Höhe legt
den Mindestfüllstand fest, unterhalb dessen die Pumpe gesperrt wird. So lässt
sich ein sinkender Füllstand vorführen, ohne das Reservoir zu leeren.

Die Netztöpfe sind mit Blähton gefüllt. Das Substrat gibt den Pflanzen Halt,
speichert selbst kaum Nährstoffe und lässt die Wurzeln durch die Öffnungen der
Netztöpfe in den Nährfilm wachsen. Die vier Basilikumpflanzen wurden aus
Stecklingen gezogen, die vollständig in Wasser bewurzelt wurden, bis die
Wurzeln lang genug für den Einsatz in die Netztöpfe waren.

#figure(
  bild_platzhalter("Foto des Gesamtaufbaus (Rinne, Reservoir, Elektronik)"),
  caption: [Gesamtaufbau des Demonstrators],
) <fig-aufbau>

== Schaltplan und Leistungspfad <kap-schaltplan>

Die Schaltung besteht aus drei Kreisen mit je einem eigenen Netzteil
(@fig-leistungspfad): dem Leistungspfad der Pumpe, dem Steuerkreis um den
ESP32 und dem Lichtkreis. Der Lichtkreis ist vollständig getrennt. Das
Growlight wird durch seinen internen Timer geschaltet; es besteht keine
Verbindung zum ESP32.

#figure(
  {
    set text(size: 9pt)
    diagram(
      spacing: (12mm, 9mm),
      node-stroke: 0.6pt,
      node-corner-radius: 2pt,
      node-inset: 6pt,
      node-shape: rect,
      node((0, 0), align(center)[USB-Netzteil Pumpe\ 5 V / 2 A], name: <d-psu>),
      node((2, 0), align(center)[MOSFET-Board\ P2003BDG], name: <d-mos>),
      node((4, 0), align(center)[Pumpe\ 5 V], name: <d-pump>),
      node((4, 1), align(center)[1N4007\ Freilaufdiode], name: <d-diode>),
      node((1, 1), [1000 µF], name: <d-cap>),
      node((0, 2), align(center)[USB-Netzteil\ ESP32], name: <d-epsu>),
      node((2, 2), [ESP32], name: <d-esp>),
      node((4, 2), align(center)[TDS-Modul\ 5 V], name: <d-tds>),
      node((0, 3), align(center)[Netzteil\ Growlight], name: <d-lpsu>),
      node((4, 3), align(center)[Growlight\ (Timer 12 h)], name: <d-light>),
      edge(<d-psu>, <d-mos>, "-|>", [VIN]),
      edge(<d-mos>, <d-pump>, "-|>", [VOUT]),
      edge(<d-pump>, <d-diode>, "-", [parallel], label-side: left),
      edge(<d-cap>, <d-mos>, "-", [an VIN], label-side: right),
      edge(<d-epsu>, <d-esp>, "-|>", [USB]),
      edge(<d-esp>, <d-tds>, "-|>", [5-V-Pin]),
      edge(<d-esp>, <d-mos>, "--|>", [GPIO 25 → TRIG,\ gemeinsame Masse], label-side: right),
      edge(<d-lpsu>, <d-light>, "-|>", [keine Verbindung zum ESP32]),
    )
  },
  caption: [Leistungspfad und Versorgung (vereinfacht)],
) <fig-leistungspfad>

Das USB-Netzteil der Pumpe speist über einen USB-A-Pigtail mit Stecker den
Eingang (VIN) des #gls("mosfet")-Boards. Am Ausgang (VOUT) sitzt ein
USB-A-Pigtail mit Buchse, in die die Pumpe mit ihrem originalen Stecker
eingesteckt wird. Der ESP32 hat ein eigenes USB-Netzteil und versorgt über
seinen 5-V-Pin das TDS-Modul. Dadurch belastet der Anlaufstrom der Pumpe nicht
die Versorgung des Steuerkreises. Der ESP32 steuert das Board über GPIO 25 am
Eingang TRIG an. Über diesen Pin fließt nur der Gate-Steuerstrom im
Mikroampere-Bereich; den Pumpenstrom führt der ESP32 zu keinem Zeitpunkt.

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
      [Puffert den Anlaufstrom der Pumpe, damit die Spannung des Pumpen-Netzteils nicht einbricht.],
      [Gemeinsame Masse],
      [Das Board schaltet low-side und benötigt denselben Bezugspunkt wie der ESP32, obwohl beide getrennte Netzteile haben.],
    ),
  ),
  caption: [Schutzmaßnahmen im Leistungspfad],
) <tab-schutz>

@tab-strombilanz zeigt die Strombilanz der beiden USB-Netzteile. Am Netzteil
der Pumpe bleibt selbst die Spitze beim Anlauf mit ca. 1,5 A unter den 2 A des
Netzteils. Der Steuerkreis nimmt rechnerisch höchstens ca. 0,3 A auf. Das
Growlight (2 A) läuft über sein eigenes Netzteil und geht nicht in die Bilanz
ein.

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
  sein. Solange sie nur gesteckt waren, fand der I²C-Bus-Scan kein Gerät. Die
  Firmware spricht das Display unter der Adresse 0x3C an.
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

== Software <kap-software>

Die Firmware ist im Arduino-Framework für den ESP32 geschrieben. Die
Hauptschleife liest zyklisch Füllstand, Temperatur und Sensorspannung, berechnet
daraus die temperaturkompensierte Leitfähigkeit, wertet die Alarmbedingungen aus
und setzt Pumpenausgang, Status-LEDs und Anzeige. Die Bedeutung der Status-LEDs
ist in @kap-statuslogik beschrieben.

Der Pumpenausgang wird in jedem Schleifendurchlauf aus der Bedingung
`wantPump && waterPresent()` gesetzt. `wantPump` ist der Sollzustand aus dem
Pumpenzeitplan, `waterPresent()` der aktuelle Zustand des Füllstandssensors.
Der Zeitplan taktet die Pumpe mit 15 min Laufzeit und 45 min Pause. Der
Intervallbetrieb senkt den Stromverbrauch der Pumpe und soll in den Pausen die
Belüftung der Wurzeln verbessern (@kap-verfahren). Die
Verriegelung greift in beiden Phasen: Auch innerhalb einer Laufphase wird die
Pumpe abgeschaltet, sobald der Füllstand unter die Sensorhöhe fällt. Es gibt
keinen Pfad, über den die Pumpe ohne aktive Füllstandsprüfung anläuft. Diese
Verriegelung ist der zentrale Hardwareschutz des Systems.

#figure(
  ```cpp
  bool waterPresent() { return digitalRead(PIN_LEVEL) == LOW; }

  // in loop(), every iteration:
  bool wantPump = (now % PUMP_CYCLE_MS) < PUMP_ON_MS;
  digitalWrite(PIN_PUMP, (wantPump && waterPresent()) ? HIGH : LOW);
  ```,
  caption: [Pumpenverriegelung in der Hauptschleife],
) <lst-verriegelung>

@lst-verriegelung zeigt den Kern der Verriegelung. Neben dem Arduino-Kern
verwendet die Firmware die Bibliotheken `Adafruit_SSD1306` und `Adafruit_GFX`
für das Display sowie `OneWire` und `DallasTemperature` für den
Temperatursensor. #gls("wlan") wird nicht genutzt; das System arbeitet
vollständig lokal. Die Wahl von ADC1 für den TDS-Sensor hält eine spätere
WLAN-Erweiterung dennoch offen.

Während Pumpe und Status-LEDs in jedem Schleifendurchlauf gesetzt werden,
erfolgt die Messung alle 30 s. Für einen Messwert bildet die Firmware den
Median aus 30 Einzelwerten, da der TDS-Sensor mit einer Wechselspannung
angeregt wird und Einzelwerte Ausreißer enthalten. Ein nicht antwortender
Temperatursensor wird als ungültiger Wert behandelt und löst den Alarm aus,
statt den Fehlwert der Bibliothek (−127 °C) in die Kompensation einfließen zu
lassen. Die Alarmbedingungen werden ebenfalls im 30-s-Takt ausgewertet; die
Alarm-LED reagiert daher mit bis zu 30 s Verzögerung, die Pumpensperre dagegen
sofort.

Das Display zeigt in zwei Spalten die Temperatur in °C und die Leitfähigkeit in
µS/cm. Neben jedem Wert steht ein Symbol: Pfeil nach oben (zu hoch), Pfeil nach
unten (zu niedrig) oder Haken (im Zielbereich). Damit ist die Bewertung ohne
Kenntnis der Zielbereiche ablesbar. Liefert der Temperatursensor keinen Wert,
erscheint „\-\-.\-“.

Für die Kalibrierung besitzt die Firmware einen eigenen Modus
(`CALIBRATION_MODE`). Darin bleibt die Pumpe gesperrt, und Display und serielle
Schnittstelle zeigen statt der Leitfähigkeit die gemessene Sensorspannung mit
vier Nachkommastellen und die Temperatur an.

Der vollständige Quellcode befindet sich im Anhang (@lst-firmware).

== Pflanzenversorgung ohne Pumpenbetrieb <kap-ohne-betrieb>

Bei Transport, Lagerung oder längeren Zeiten ohne Stromversorgung können die
Pflanzen ohne Pumpe versorgt werden. Diese Betriebsart wurde im Projekt nicht
erprobt und ist als Empfehlung für den Einsatz an Schulen zu verstehen. Dazu
werden die Netztöpfe aus dem Rohr genommen und direkt in das Reservoir gesetzt,
etwa in einen Deckel mit passenden Öffnungen. Die Wurzeln hängen dann
unmittelbar in der Nährlösung. Das entspricht dem passiven Kratky-Verfahren,
das als Hauptverfahren verworfen wurde (@kap-verfahren), sich aber als
Überbrückung eignet, weil es weder Pumpe noch Steuerung benötigt.

Dabei ist Folgendes zu beachten:

- *Füllhöhe.* Die Wurzeln müssen in die Lösung eintauchen, Blähton und
  Pflanzenansatz sollen oberhalb des Pegels bleiben, damit sie nicht dauerhaft
  nass stehen.
- *Luftraum.* Mit sinkendem Pegel entsteht zwischen Lösung und Netztopf ein
  Luftraum, aus dem die oberen Wurzeln Sauerstoff aufnehmen. Das Reservoir wird
  daher nicht ständig bis zum Rand nachgefüllt, sondern erst, wenn die Wurzeln
  die Lösung nicht mehr erreichen.
- *Licht.* Das Growlight hat ein eigenes Netzteil und einen eigenen Timer und
  kann unabhängig vom ESP32 weiterlaufen.
- *Keine Überwachung.* Ohne Steuerung entfallen Füllstands- und
  Temperaturalarm. Füllstand und Zustand der Pflanzen sind manuell zu prüfen.

Für die Wiederaufnahme des Betriebs werden die Netztöpfe in das Rohr
zurückgesetzt und die Prüfschritte der Inbetriebnahme ab der Sensorprüfung
wiederholt.
