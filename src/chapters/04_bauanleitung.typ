#import "../components/formatting.typ": todo, bild_platzhalter
#import "../components/tables.typ": table_style_1
#import "../dependencies.typ": diagram, node, edge, gls

// Kapitel 4 — Budget: 3,5 Seiten
// Pflichtbestandteile: Bauanleitung, Schaltpläne und/oder Fotos
// Anleitung im Präsens/Passiv, durchgeführte Arbeiten und Beobachtungen im Präteritum.

= Bauanleitung <kap-bauanleitung>

== Mechanischer Aufbau

Der mechanische Aufbau folgt dem #gls("nft")-Prinzip. Die Pflanzen sitzen in
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
- *Reservoir und Elektronik.* Unten in der Holzbox stehen links das Reservoir und
  rechts das Elektronikgehäuse, beide aus je einer Kunststoffbox. Im Gehäuse
  sind ESP32, Steckbrett und MOSFET-Board untergebracht. Das Display ist nach
  vorne ausgerichtet.
- *Leitungsführung.* Der Förderschlauch führt durch ein passendes Loch in das
  Rohr. Die drei USB-Kabel der Versorgung werden hinten herausgeführt, sodass
  die Vorderseite frei bleibt.

Die Sensoren sind für Präsentationszwecke nicht fest verbaut. Temperatursensor
und TDS-Elektrode hängen lose im Reservoir, der Füllstandssensor wird außen an
die Reservoirwand gehalten. Er arbeitet berührungslos und erkennt die
Flüssigkeit durch die nichtmetallische Behälterwand hindurch. Seine Höhe legt
den Mindestfüllstand fest, unterhalb dessen die Pumpe gesperrt wird. So lässt
sich ein sinkender Füllstand vorführen, ohne das Reservoir zu leeren.

Die Netztöpfe sind mit Blähton gefüllt. Das Substrat gibt den Pflanzen Halt,
speichert selbst kaum Nährstoffe und lässt die Wurzeln durch die Öffnungen der
Netztöpfe in den Nährfilm wachsen. Die vier Basilikumpflanzen wurden aus
Stecklingen gezogen, die vollständig in Wasser bewurzelt wurden, bis die
Wurzeln lang genug für den Einsatz in die Netztöpfe waren.

#figure(
  image("../res/HydroAufbau.jpg", height: 7cm),
  caption: [Gesamtaufbau des Demonstrators],
) <fig-aufbau>

== Schaltplan und Leistungspfad <kap-schaltplan>

Die Schaltung besteht aus drei Kreisen mit je einem eigenen Netzteil, nämlich
dem Leistungspfad der Pumpe, dem Steuerkreis um den ESP32 und dem Lichtkreis
(@fig-leistungspfad). Der Lichtkreis ist vollständig getrennt. Das Growlight
wird durch seinen internen Timer geschaltet und hat keine Verbindung zum
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
Mikroampere-Bereich. Den Pumpenstrom führt der ESP32 zu keinem Zeitpunkt.

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
      [Freilaufdiode. Die Motorspule erzeugt beim Abschalten eine Gegenspannung weit über der 25-V-Grenze des MOSFET, die die Diode kurzschließt.],
      [1000 µF an VIN],
      [Puffert den Anlaufstrom der Pumpe, damit die Spannung des Pumpen-Netzteils nicht einbricht.],
      [Gemeinsame Masse],
      [Das Board schaltet low-side und benötigt denselben Bezugspunkt wie der ESP32, obwohl beide getrennte Netzteile haben.],
    ),
  ),
  caption: [Schutzmaßnahmen im Leistungspfad],
) <tab-schutz>

Am Netzteil der Pumpe bleibt selbst die Spitze beim Anlauf mit ca. 1,5 A unter
den 2 A des Netzteils. Der Steuerkreis nimmt rechnerisch höchstens ca. 0,3 A
auf. Die vollständige Strombilanz (@tab-strombilanz) sowie die GPIO-Belegung
mit ihren Randbedingungen (@tab-gpio) stehen im Anhang. Jede Status-LED ist mit
einem 220-Ω-Vorwiderstand beschaltet.

== Inbetriebnahme

Die Inbetriebnahme erfolgt schrittweise, die Pumpe wird zuletzt angeschlossen:

+ *Firmware aufspielen.* Vor dem ersten Flashen prüfen, dass die Strapping-Pins
  unbelegt sind.
+ *Display prüfen.* Die Stiftleisten des #gls("oled")-Displays müssen verlötet
  sein. Solange sie nur gesteckt waren, fand der I²C-Bus-Scan kein Gerät. Die
  Firmware spricht das Display unter der Adresse 0x3C an.
+ *Sensoren prüfen.* Der Temperatursensor muss einen plausiblen Wert liefern,
  und der Füllstandseingang muss beim Füllen und Leeren des Reservoirs den Pegel
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

Die Funktion gilt zwischen ca. 650 und 2300 µS/cm und ist außerhalb dieser
Spanne nicht belastbar. Der Zielbereich für Basilikum (1,0–1,6 mS/cm) liegt
vollständig darin. Da keine Referenzlösung zur Verfügung stand, ist die
EC-Skala relativ zum Handheld-Gerät (@kap-fazit).

== Software <kap-software>

Die Firmware ist im Arduino-Framework für den ESP32 geschrieben. Die
Hauptschleife liest zyklisch Füllstand, Temperatur und Sensorspannung, berechnet
daraus die temperaturkompensierte Leitfähigkeit, wertet die Alarmbedingungen aus
und setzt Pumpenausgang, Status-LEDs und Anzeige. Die Bedeutung der Status-LEDs
ist in @kap-statuslogik beschrieben.

@lst-verriegelung zeigt den Kern der Verriegelung (@kap-statuslogik). Dabei
ist `wantPump` der Sollzustand aus dem Pumpenzeitplan (15 min an, 45 min aus)
und `waterPresent()` der aktuelle Zustand des Füllstandssensors.

#figure(
  ```cpp
  bool waterPresent() { return digitalRead(PIN_LEVEL) == LOW; }

  // in loop(), every iteration:
  bool wantPump = (now % PUMP_CYCLE_MS) < PUMP_ON_MS;
  digitalWrite(PIN_PUMP, (wantPump && waterPresent()) ? HIGH : LOW);
  ```,
  caption: [Pumpenverriegelung in der Hauptschleife],
) <lst-verriegelung>

Neben dem Arduino-Kern
verwendet die Firmware die Bibliotheken `Adafruit_SSD1306` und `Adafruit_GFX`
für das Display sowie `OneWire` und `DallasTemperature` für den
Temperatursensor. #gls("wlan") wird nicht genutzt, das System arbeitet
vollständig lokal. Die Wahl von ADC1 für den TDS-Sensor hält eine spätere
WLAN-Erweiterung dennoch offen.

Gemessen wird alle 30 s, jeweils als Median aus 30 Einzelwerten gegen die
Ausreißer der Wechselspannungsanregung. Die Alarm-LED reagiert daher mit bis zu
30 s Verzögerung, die Pumpensperre dagegen in jedem Schleifendurchlauf sofort.

Für die Kalibrierung besitzt die Firmware einen eigenen Modus
(`CALIBRATION_MODE`). Darin bleibt die Pumpe gesperrt, und Display und serielle
Schnittstelle zeigen statt der Leitfähigkeit die gemessene Sensorspannung mit
vier Nachkommastellen und die Temperatur an.

Der vollständige Quellcode befindet sich im Anhang (@lst-firmware).

== Pflanzenversorgung ohne Pumpenbetrieb <kap-ohne-betrieb>

Für Transport, Lagerung oder Zeiten ohne Stromversorgung wird empfohlen, die
Netztöpfe aus dem Rohr zu nehmen und, etwa in einem Deckel mit passenden
Öffnungen, direkt in das Reservoir zu setzen (passives Kratky-Verfahren,
@kap-verfahren). Im Projekt wurde das nicht erprobt. Die Wurzeln sollen in die
Lösung eintauchen, Blähton und Pflanzenansatz oberhalb des Pegels bleiben. Der
mit sinkendem Pegel entstehende Luftraum versorgt die oberen Wurzeln mit
Sauerstoff, daher wird erst nachgefüllt, wenn die Wurzeln die Lösung nicht mehr
erreichen. Das Growlight läuft unabhängig weiter, die Alarme entfallen jedoch.
Bei Wiederaufnahme des Betriebs wird die Inbetriebnahme ab der Sensorprüfung
wiederholt.
