#import "../components/formatting.typ": todo

// Kapitel 2 — Budget: 3 Seiten
// Pflichtbestandteil: Konzeptbeschreibung

= Konzept <kap-konzept>

== Verfahrensauswahl
// NFT gegen DWC, Ebbe-Flut, Kratky, Aeroponik — Vergleichstabelle mit Begründung.
#todo("Verfahrensvergleich")

== Systemarchitektur
// Blockschaltbild: Sensoren -> ESP32 -> Aktorik / Anzeige; getrennter Lichtkreis.
#todo("Systemarchitektur mit Abbildung")

== Sensorik und Aktorik
#todo("Sensorik und Aktorik")

== Statuslogik und Verriegelung
// Heartbeat-Blinken statt Dauerlicht; Pumpenverriegelung `wantPump && waterPresent()`.
#todo("Statuslogik und Verriegelung")

== Abweichungen gegenüber dem Projektauftrag
// Der Projektauftrag nennt Relaismodul, Schwimmerschalter und geschaltete
// Beleuchtung; umgesetzt wurden MOSFET-Board, kapazitiver Füllstandssensor und
// ein Growlight mit eigenem Timer. Abweichungen hier kurz begründen.
#todo("Abweichungen gegenüber dem Projektauftrag")
