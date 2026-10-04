#import "../components/formatting.typ": todo
#import "../components/tables.typ": table_style_1
#import "../dependencies.typ": diagram, node, edge, gls

// Kapitel 2 — Budget: 3 Seiten
// Pflichtbestandteil: Konzeptbeschreibung

= Konzept <kap-konzept>

== Verfahrensauswahl <kap-verfahren>

Hydroponische Systeme unterscheiden sich darin, wie die Nährlösung an die
Wurzeln gelangt. @tab-verfahren vergleicht fünf verbreitete Verfahren im
Hinblick auf den Einsatz als transportabler, automatisierter Demonstrator.

#figure(
  table_style_1(
    table(
      columns: (2.4cm, 1fr, 1.25fr),
      align: left,
      table.header([Verfahren], [Prinzip], [Bewertung]),
      [#gls("nft")],
      [Eine Pumpe fördert die Lösung in eine leicht geneigte Rinne, durch die sie
        als dünner Film an den Wurzeln entlang zurück ins Reservoir fließt.],
      [*Gewählt.* Der Kreislauf ist sichtbar, die Pumpe ist ein schaltbarer
        Aktor, und in der Rinne steht nur wenig Lösung. Vom Projektauftrag
        vorgegeben.],
      [#gls("dwc")],
      [Die Wurzeln hängen dauerhaft in einer Lösung, die von einer Luftpumpe
        belüftet wird.],
      [Verworfen. Der Kreislauf ist nicht sichtbar, und die Luftpumpe läuft
        dauerhaft ohne Schaltaufgabe. Das große Lösungsvolumen erschwert den
        Transport.],
      [Ebbe-Flut],
      [Ein Pflanzbecken wird periodisch geflutet und läuft anschließend zurück
        ins Reservoir.],
      [Verworfen. Ein eigenes Flutbecken mit Ablauf und mehr Lösung erhöht den
        Aufwand für einen transportablen Aufbau.],
      [Kratky],
      [Die Pflanzen sitzen passiv über stehender Lösung. Mit sinkendem Pegel
        entsteht ein Luftraum für die Wurzeln.],
      [Verworfen als Hauptverfahren, da ohne Aktor keine Automatisierungsaufgabe
        entsteht. Empfohlen als Überbrückung ohne Pumpe (@kap-ohne-betrieb).],
      [Aeroponik],
      [Die Wurzeln hängen frei und werden mit Nährlösung besprüht.],
      [Verworfen. Düsen und Druckpumpe sind aufwendig und verstopfen leicht, und bei
        einem Pumpenausfall trocknen die Wurzeln schnell aus.],
    ),
  ),
  caption: [Vergleich hydroponischer Verfahren],
) <tab-verfahren>

Der Nachteil von NFT ist die Abhängigkeit von der Pumpe. Fällt sie aus oder
läuft das Reservoir leer, werden die Wurzeln in der Rinne nicht mehr versorgt.
Gerade daraus ergibt sich die Automatisierungsaufgabe, Pumpe und Füllstand zu
überwachen.

Abweichend vom klassischen NFT, bei dem die Pumpe dauerhaft läuft, wird die
Pumpe im Intervall mit 15 min Laufzeit und 45 min Pause betrieben. Das senkt
den Stromverbrauch der Pumpe und soll in den Pausen die Belüftung der Wurzeln
verbessern. Der Aufbau bleibt ein NFT-System mit geneigter Rinne und
Rücklauf. Geändert ist nur der Betrieb der Pumpe.

== Systemarchitektur

@fig-architektur zeigt den funktionalen Aufbau. Drei Sensoren erfassen den
Zustand der Nährlösung, der ESP32 verarbeitet die Messwerte und steuert Anzeige,
Status-LEDs und Pumpe. Das System arbeitet vollständig lokal, ohne Rechner und
ohne Netzwerk. Die Beleuchtung bildet einen getrennten Kreis mit eigenem
Netzteil und Timer.

#figure(
  {
    set text(size: 9pt)
    diagram(
      spacing: (14mm, 6mm),
      node-stroke: 0.6pt,
      node-corner-radius: 2pt,
      node-inset: 6pt,
      node-shape: rect,
      node((0, 0), align(center)[Temperatur\ DS18B20], name: <a-temp>),
      node((0, 1), align(center)[Leitfähigkeit\ TDS-Sensor], name: <a-tds>),
      node((0, 2), align(center)[Füllstand\ XKC-Y25-NPN], name: <a-level>),
      node((1.6, 1), align(center)[*ESP32*\ Messung, Bewertung,\ Verriegelung], name: <a-esp>),
      node((3.2, 0), align(center)[OLED-Display], name: <a-oled>),
      node((3.2, 1), align(center)[3 Status-LEDs], name: <a-led>),
      node((3.2, 2), align(center)[MOSFET-Board], name: <a-mos>),
      node((4.4, 2), [Pumpe], name: <a-pump>),
      node((1.6, 3), align(center)[Growlight mit Timer und eigenem Netzteil\ (keine Verbindung zum ESP32)],
        stroke: (dash: "dashed", thickness: 0.6pt), name: <a-light>),
      edge(<a-temp>, <a-esp>, "-|>", [OneWire], label-side: left),
      edge(<a-tds>, <a-esp>, "-|>", [analog]),
      edge(<a-level>, <a-esp>, "-|>", [digital], label-side: right),
      edge(<a-esp>, <a-oled>, "-|>", [I²C], label-side: left),
      edge(<a-esp>, <a-led>, "-|>", [GPIO]),
      edge(<a-esp>, <a-mos>, "-|>", [GPIO 25], label-side: right),
      edge(<a-mos>, <a-pump>, "-|>"),
    )
  },
  caption: [Systemarchitektur des Demonstrators],
) <fig-architektur>

== Sensorik und Aktorik

@tab-komponenten fasst die Aufgaben der Sensoren und Aktoren zusammen. Die
elektrische Umsetzung beschreibt @kap-schaltplan.

#figure(
  table_style_1(
    table(
      columns: (auto, auto, 1fr),
      align: left,
      table.header([Funktion], [Bauteil], [Prinzip und Begründung]),
      [Temperatur], [DS18B20],
      [Digitaler, werkseitig kalibrierter Sensor am OneWire-Bus, der auch die
        Temperatur für die EC-Kompensation liefert.],
      [Leitfähigkeit], [TDS-Sensor],
      [Zwei Elektroden mit Wechselspannung (keine Elektrolyse), Ausgang
        0–2,3 V.],
      [Füllstand], [XKC-Y25-NPN],
      [Kapazitiv durch die Behälterwand, ohne Kontakt zur Lösung.],
      [Pumpe], [MOSFET-Board],
      [Logic-Level, schaltet mit 3,3 V vom GPIO voll durch.],
      [Anzeige], [OLED 128 × 32],
      [Messwerte mit Bewertungssymbol, #gls("i2c")-Bus.],
      [Status], [3 LEDs],
      [Betrieb, Pumpe und Alarm auf einen Blick.],
    ),
  ),
  caption: [Sensoren und Aktoren],
) <tab-komponenten>

Der TDS-Sensor ist nach der Größe #gls("tds") benannt, der Menge gelöster
Feststoffe in #gls("ppm"). Sie wird aus der Leitfähigkeit mit einem
geräteabhängigen Faktor berechnet. Die Firmware nutzt passend zum
Handheld-Gerät den Faktor 0,5 („ppm \@ 500“). Leitgröße ist deshalb die
Leitfähigkeit.

== Statuslogik und Verriegelung <kap-statuslogik>

Drei Status-LEDs zeigen den Zustand des Systems (@tab-status).

#figure(
  table_style_1(
    table(
      columns: (auto, auto, 1fr),
      align: left,
      table.header([LED], [Verhalten], [Aussage]),
      [grün], [kurzer Blitz alle 2 s], [Die Hauptschleife läuft.],
      [gelb], [folgt dem Pumpenausgang], [Die Pumpe ist eingeschaltet.],
      [rot], [an bei Alarm],
      [Füllstand niedrig, Temperatur außerhalb 18–24 °C oder Temperatursensor
        ohne Antwort.],
    ),
  ),
  caption: [Bedeutung der Status-LEDs],
) <tab-status>

Die grüne LED blinkt bewusst, statt dauerhaft zu leuchten. Ein Dauerlicht wäre
nicht von einem Absturz zu unterscheiden, bei dem der Ausgang auf High hängen
geblieben ist. Das Blinken beweist dagegen, dass die Hauptschleife tatsächlich
durchlaufen wird.

Eine Leitfähigkeit außerhalb des Zielbereichs löst keinen Alarm aus. Sie ist
keine akute Gefahr für die Anlage, und die Korrektur erfolgt ohnehin von Hand.
Das Display zeigt die Abweichung mit einem Pfeil nach oben oder unten an. Liegt
der Wert im Zielbereich, erscheint ein Haken. Dieselbe Bewertung gilt für die
Temperatur. So ist der Zustand ohne Kenntnis der Zielbereiche ablesbar.

Die zentrale Schutzfunktion ist die Pumpenverriegelung. Der Pumpenausgang wird
in jedem Schleifendurchlauf aus dem Sollzustand des Zeitplans und dem aktuellen
Signal des Füllstandssensors gebildet. Nur wenn beide
erfüllt sind, läuft die Pumpe. Es gibt keinen Pfad, über den die Pumpe ohne
aktive Füllstandsprüfung anläuft, und auch eine laufende Pumpe wird sofort
abgeschaltet, sobald der Füllstand unter die Sensorhöhe fällt. Beim Start setzt
die Firmware den Pumpenausgang als erstes auf Low, damit die Pumpe nicht
während der Initialisierung anläuft.

== Abweichungen gegenüber dem Projektauftrag

Die Umsetzung weicht in mehreren Punkten vom Projektauftrag ab
(@tab-abweichungen).

#figure(
  table_style_1(
    table(
      columns: (1fr, 1fr, 2.4fr),
      align: left,
      table.header([Projektauftrag], [Umsetzung], [Begründung]),
      [Pumpe über Relaismodul], [MOSFET-Board],
      [Die Pumpe ist ein 5-V-Gleichstromverbraucher mit ca. 0,5 A. Ein
        Logic-Level-MOSFET schaltet sie direkt mit 3,3 V vom GPIO, ohne
        mechanische Kontakte.],
      [Beleuchtung über Relaismodul], [Growlight mit eigenem Timer],
      [Das Growlight nimmt 2 A auf und hätte zusammen mit der Pumpe das
        USB-Netzteil der Pumpe überlastet (@tab-strombilanz). Der feste Lichtzyklus
        benötigt keine Sensordaten, und der Timer ist bereits integriert.],
      [Schwimmerschalter], [Kapazitiver Sensor XKC-Y25-NPN],
      [Keine beweglichen Teile und kein Kontakt mit der Nährlösung. Der Sensor
        lässt sich außen an der Wand verschieben, wodurch der Alarm vorführbar
        wird.],
      [Daten per WLAN bereitstellen], [Lokale Anzeige],
      [Messwerte, Bewertung und Zustand werden am Gerät angezeigt. Für den
        Einsatz als Demo-Objekt steht die Ablesbarkeit vor Ort im Vordergrund
        (K6). Eine Netzwerkanbindung wurde nicht umgesetzt.],
      [Kontinuierliche Umspülung], [Intervall 15 min / 45 min],
      [Geringerer Stromverbrauch, Belüftung der Wurzeln in den Pausen
        (@kap-verfahren).],
      [—], [Leitfähigkeit (zusätzlich)],
      [Die Nährstoffkonzentration ist neben der Temperatur die wichtigste Größe
        der Nährlösung und wurde ergänzt.],
    ),
  ),
  caption: [Abweichungen gegenüber dem Projektauftrag],
) <tab-abweichungen>
