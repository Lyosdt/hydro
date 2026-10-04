#import "../components/formatting.typ": todo
#import "../components/tables.typ": table_style_1
#import "../dependencies.typ": gls

// Kapitel 1 — Budget: 2 Seiten
// Pflichtbestandteil: Beschreibung des gelösten Problems

= Problemstellung und Zielsetzung <kap-problemstellung>

== Ausgangslage
// Technische Ebene: Nährlösung ohne tägliche manuelle Kontrolle im Zielbereich
// halten, Störfälle (Trockenlauf, Temperaturspitze) sichtbar melden.
// Didaktische Ebene: Messgrößen für Schüler ohne Vorwissen ablesbar machen
// (transportables Demo-Objekt für Schulen). Beide Ebenen getrennt darstellen.

In der Hydroponik wachsen Pflanzen ohne Erde. Ihre Wurzeln werden direkt mit
einer Nährlösung versorgt, also mit Wasser, in dem Nährsalze gelöst sind.
Gegenstand dieses Projekts ist ein Demonstrator, der Basilikum in einem
geschlossenen Kreislauf kultiviert. Der Projektauftrag sieht dafür eine Anlage
nach der Nutrient Film Technique vor, die von einem ESP32-Mikrocontroller
gesteuert wird. Er verbindet den Pflanzenanbau mit typischen Aufgaben der
Gebäude- und Automatisierungstechnik wie Datenerfassung, Visualisierung und
Steuerung. Die Problemstellung hat eine technische und eine didaktische Ebene.

*Technische Ebene.* Damit die Pflanzen gedeihen, muss die Nährlösung in einem
Zielbereich bleiben. Maßgeblich sind drei Größen:

- *Leitfähigkeit.* Die elektrische Leitfähigkeit (#gls("ec")) der Lösung steigt
  mit der Menge gelöster Nährsalze und dient daher als Maß für die
  Nährstoffkonzentration. Sie wird in µS/cm oder mS/cm angegeben. Für
  Basilikum liegt der Zielbereich bei 1,0–1,6 mS/cm. Durch die Wasseraufnahme
  der Pflanzen und durch Verdunstung verändert sich die Konzentration im
  laufenden Betrieb.
- *Wassertemperatur.* Der Zielbereich liegt bei 18–24 °C. Wärmeres Wasser
  löst weniger Sauerstoff und begünstigt Wurzelfäule, kälteres hemmt das
  Wachstum.
- *Füllstand.* Der Pegel im Reservoir sinkt mit der Zeit. Fällt er zu weit,
  läuft die Pumpe trocken und die Wurzeln werden nicht mehr versorgt.

Ohne Automatisierung müssen diese Größen täglich von Hand gemessen und die
Pumpe manuell betrieben werden. Die technische Aufgabe besteht darin, den
Zustand der Nährlösung laufend zu überwachen, sodass ein Verlassen des
Zielbereichs ohne tägliche manuelle Messung erkannt wird. Die Pumpe soll
selbstständig laufen und bei niedrigem Füllstand zuverlässig gesperrt sein.
Störfälle, also ein drohender Trockenlauf und eine Temperatur außerhalb des
Zielbereichs, sollen sichtbar gemeldet werden.

*Didaktische Ebene.* Der Demonstrator ist als transportables Demo-Objekt für
Schulen gedacht, nicht als Produktivanlage. Schülerinnen und Schüler sollen
ohne Vorwissen erkennen können, in welchem Zustand sich die Anlage befindet.
Ein Zahlenwert in µS/cm sagt ohne Kenntnis des Zielbereichs jedoch nichts
darüber aus, ob die Lösung in Ordnung ist. Die Messgrößen müssen daher bewertet
und so angezeigt werden, dass ihr Zustand auf einen Blick ablesbar ist.
Außerdem sollen sich der Wasserkreislauf, das Schalten der Pumpe und die
Reaktion auf einen Störfall vorführen lassen.

== Zielkriterien <kap-kriterien>
// K1–K6 in prüfbarer Form. Kapitel 5 prüft genau diese Kriterien ab,
// Kapitel 6 fasst das Ergebnis zusammen.
Aus der Problemstellung und dem Projektauftrag ergeben sich sechs Zielkriterien
(@tab-kriterien). Sie sind so formuliert, dass sie am Aufbau geprüft werden
können. @kap-testprotokoll prüft genau diese Kriterien ab.

#figure(
  table_style_1(
    table(
      columns: (auto, auto, 1fr),
      align: left,
      table.header([Nr.], [Kriterium], [Prüfbare Anforderung]),
      [K1], [Wassertemperatur],
      [Die Temperatur der Nährlösung wird erfasst und angezeigt. Werte außerhalb
        von 18–24 °C werden über die Alarm-LED gemeldet.],
      [K2], [Leitfähigkeit],
      [Die temperaturkompensierte #gls("ec") wird im Zielbereich von
        1,0–1,6 mS/cm in Übereinstimmung mit dem Referenzmessgerät bestimmt.],
      [K3], [Füllstand],
      [Das Unterschreiten des Mindestfüllstands im Reservoir wird erkannt und
        über die Alarm-LED gemeldet.],
      [K4], [Trockenlaufschutz],
      [Bei unterschrittenem Mindestfüllstand läuft die Pumpe nicht an, und eine
        laufende Pumpe wird abgeschaltet.],
      [K5], [Pumpenbetrieb],
      [Die Pumpe läuft ohne manuellen Eingriff im Takt 15 min an / 45 min aus.
        Der Anlauf der Pumpe führt nicht zu einem Neustart des ESP32.],
      [K6], [Ablesbarkeit],
      [Temperatur, Leitfähigkeit mit Bewertung (zu niedrig / im Bereich / zu
        hoch) und der Systemzustand sind direkt am Gerät, ohne Rechner und ohne
        Vorwissen ablesbar.],
    ),
  ),
  caption: [Zielkriterien des Demonstrators],
) <tab-kriterien>

== Abgrenzung <kap-abgrenzung>
// Keine pH-Messung (Sonde nicht im Budget), keine Dosierpumpe / automatische
// Dosierung, Budget ca. 100 €.

Der finanzielle Rahmen lag bei ca. 100 €, der Erstattungsgrenze der
Hochschule. Daraus und aus der Zielsetzung als Demo-Objekt ergeben sich
folgende Abgrenzungen:

- *Keine pH-Messung.* Neben der Leitfähigkeit beeinflusst der pH-Wert
  (Zielbereich für Basilikum 5,5–6,5) die Nährstoffaufnahme. pH-Sonden mit
  ausreichender Messqualität sprengen das Budget. Eine driftende, günstige Sonde
  wäre in einem Regelkreis zudem riskanter als gar keine Messung. Der pH-Wert wurde
  im Projekt auch manuell nicht gemessen.
- *Keine automatische Dosierung.* Das System misst und bewertet die
  Leitfähigkeit, korrigiert sie aber nicht. Eine Dosierpumpe wurde nicht
  beschafft, der Regelkreis ist bewusst nicht geschlossen. Nährstoff und
  Wasser werden von Hand nachgefüllt.
- *Beleuchtung ohne Steuerung durch den ESP32.* Das Growlight wird von seinem
  eigenen Timer für 12 h am Tag eingeschaltet.
- *Keine Datenübertragung.* Die Messwerte werden ausschließlich am Gerät
  angezeigt, WLAN wird nicht genutzt.
- *Kein Ertragsversuch.* Bewertet wird die Funktion des technischen Systems,
  nicht Wachstum oder Ertrag der Pflanzen.
