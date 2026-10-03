#import "../components/formatting.typ": todo

// Kapitel 6 — Budget: 1 Seite

= Fazit und Ausblick <kap-fazit>

== Ergebnis

Der Demonstrator, eine NFT-Anlage für vier Basilikumpflanzen mit
funktionierendem Kreislauf, erfüllt vier der sechs Zielkriterien
(@tab-soll-ist): Die Pumpe läuft selbstständig im vorgesehenen Takt (K5), die
Verriegelung verhindert einen Trockenlauf (K4), und niedriger Füllstand sowie
Temperaturen außerhalb des Zielbereichs werden gemeldet (K1, K3). Damit ist die
technische Problemstellung gelöst. Die Leitfähigkeitsmessung (K2) ist
kalibriert, aber nur relativ zum Referenzgerät belegt; die Ablesbarkeit für die
Zielgruppe (K6) ist umgesetzt, aber nicht geprüft.

== Limitationen

- *Relative EC-Skala.* Das Handheld-Messgerät wurde nicht gegen eine
  Referenzlösung geprüft; ein systematischer Fehler würde unerkannt übernommen.
  Die Kennlinie verläuft durch genau drei Punkte, eine unabhängige
  Kontrollmessung fehlt. Belastbar ist sie nur zwischen ca. 650 und
  2300 µS/cm.
- *Kein pH-Wert.* Der pH-Wert wurde weder automatisch noch manuell erfasst. Ein
  Teil der Nährlösungsqualität bleibt damit unbeobachtet.
- *Nachträgliche Dokumentation.* Es gab keine kontinuierliche
  Datenaufzeichnung und keinen protokollierten Langzeitbetrieb. Da der Aufbau
  nicht mehr besteht, sind die Tests nicht wiederholbar.
- *Ungeprüfte Annahmen.* Die Temperatur wurde nicht gegen ein
  Referenzthermometer geprüft. Ob der 1000-µF-Kondensator für den stabilen
  Betrieb notwendig ist, wurde nicht getestet, ebenso wenig die Wirkung der
  Pumpenpausen auf die Pflanzen.
- *Lose Sensoren.* Für die Vorführung sind die Sensoren beweglich. Verrutscht
  der Füllstandssensor nach unten, sinkt der Mindestfüllstand, ab dem die Pumpe
  gesperrt wird. Für einen unbeaufsichtigten Betrieb muss er fest montiert
  sein.
- *Didaktische Wirkung.* Eine Erprobung mit Schülerinnen und Schülern fand
  nicht statt.

== Ausblick

Die nächste Ausbaustufe sollte zuerst die Messkette absichern: Mit einer
Referenzlösung (1413 µS/cm) lassen sich Handheld-Gerät und Kennlinie an einem
unabhängigen Punkt prüfen. Darauf aufbauend bietet sich eine Datenaufzeichnung
per WLAN an, die im Unterricht den Anstieg der Leitfähigkeit mit dem
Wasserverbrauch der Pflanzen zeigen würde; die Wahl von ADC1 hält diese
Erweiterung offen. Eine pH-Messung mit hochwertiger Sonde und erst danach eine
automatische Dosierung würden den Regelkreis schließen. Parallel sollte der
Demonstrator mit einer Schulklasse erprobt werden (K6).
