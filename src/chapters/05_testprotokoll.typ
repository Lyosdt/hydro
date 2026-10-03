#import "../components/formatting.typ": todo
#import "../components/testprotokoll.typ": testfall, bewertung_badge
#import "../components/tables.typ": table_style_1

// Kapitel 5 — Budget: 3 Seiten
// Pflichtbestandteil: Protokoll der Testdurchläufe
// Keine erfundenen Messwerte. Beobachtungen qualitativ formulieren.

= Testprotokoll <kap-testprotokoll>

== Methodik

Die Tests wurden begleitend zur Aufbauphase durchgeführt, vor der Abgabe des
Demonstrators. Sie prüfen die Zielkriterien K1–K6 aus @kap-kriterien. Eine
kontinuierliche Datenaufzeichnung fand nicht statt, ebenso kein Langzeitbetrieb
mit protokolliertem Verlauf. Die Dokumentation erfolgte nachträglich anhand von
Fotos und Notizen. Da der Aufbau nach der Abgabe nicht mehr besteht, konnten die
Tests weder wiederholt noch um Messreihen ergänzt werden. Die Beobachtungen sind
deshalb qualitativ wiedergegeben; Zahlenwerte stehen nur dort, wo sie während
der Tests notiert wurden (Kalibrierpunkte in @tab-kalibrierung).

Jeder Testfall ist in einem einheitlichen Block dokumentiert: Zeitraum,
geprüftes Kriterium, Vorgehen, Beobachtung und Bewertung. Die Bewertung lautet
_erfüllt_, _teilweise erfüllt_ oder _nicht geprüft_.

== Testfälle

#testfall(
  id: "T1",
  titel: [Temperatursensor in kaltem und warmem Wasser],
  zeitraum: [Aufbauphase, vor der Abgabe],
  kriterium: [K1],
  vorgehen: [Der DS18B20 wurde nacheinander in kaltes und in warmes Wasser
    getaucht und der Messwert abgelesen.],
  beobachtung: [Der Messwert folgte dem Wechsel zwischen kaltem und warmem
    Wasser in der erwarteten Richtung, und die rote Alarm-LED zeigte die
    Temperatur außerhalb des Zielbereichs an. Ein Abgleich gegen ein
    Referenzthermometer fand nicht statt; die absolute Genauigkeit stützt sich
    allein auf die Werkskalibrierung des Sensors.],
  bewertung: "erfüllt",
)

#testfall(
  id: "T2",
  titel: [Abgleich TDS-Sensor gegen Handheld-Messgerät],
  zeitraum: [Aufbauphase, vor der Abgabe],
  kriterium: [K2],
  vorgehen: [Die Kalibrierung diente zugleich als Test. Im Kalibriermodus der
    Firmware (@kap-software) blieb die Pumpe gesperrt, angezeigt wurde die
    Rohspannung des Sensors. Sensor und Handheld-Messgerät wurden in drei
    Lösungen unterschiedlicher Leitfähigkeit gemessen; die Spannung wurde mit
    der Temperatur des DS18B20 auf 25 °C kompensiert (@kap-kalibrierung).],
  beobachtung: [Die kompensierte Spannung stieg mit der Leitfähigkeit des
    Handheld-Geräts an (@tab-kalibrierung). Eine Gerade durch die äußeren Punkte
    verfehlte den mittleren um +7,8 %; der Zusammenhang ist also nicht linear,
    weshalb eine quadratische Kennlinie verwendet wird. Diese verläuft per
    Konstruktion exakt durch alle drei Punkte und ist damit kein unabhängiger
    Nachweis der Genauigkeit. Eine Kontrollmessung an einem vierten Punkt fand
    nicht statt; das Handheld-Gerät selbst wurde nicht gegen eine
    Referenzlösung geprüft.],
  bewertung: "teilweise erfüllt",
)

#testfall(
  id: "T3",
  titel: [Füllstandssensor ein/aus],
  zeitraum: [Aufbauphase, vor der Abgabe],
  kriterium: [K3],
  vorgehen: [Der berührungslose Sensor wurde an der Reservoirwand über und
    unter den Wasserspiegel bewegt. Damit wurden ein sinkender und ein wieder
    steigender Füllstand nachgebildet, ohne das Reservoir zu leeren.],
  beobachtung: [Die Erkennung wechselte mit dem Über- und Unterschreiten des
    Wasserspiegels. Befand sich der Sensor oberhalb des Wasserspiegels, meldete
    die rote Alarm-LED den niedrigen Füllstand. Dass die Pumpe ebenfalls
    reagierte, zeigt T4.],
  bewertung: "erfüllt",
)

#testfall(
  id: "T4",
  titel: [Pumpenbetrieb und Trockenlaufverriegelung],
  zeitraum: [Aufbauphase, vor der Abgabe],
  kriterium: [K4, K5],
  vorgehen: [Bei angeschlossener Pumpe wurde der Füllstandssensor wie in T3
    bewegt und die Reaktion der Pumpe beobachtet. Außerdem wurde der Pumpentakt
    im Normalbetrieb beobachtet. Der Leistungspfad war dabei mit dem
    1000-µF-Kondensator an VIN bestückt (@kap-schaltplan).],
  beobachtung: [Die Pumpe reagierte auf den Füllstandssensor: Erkannte er
    keine Flüssigkeit, lief sie nicht. Im Betrieb floss die Nährlösung durch
    das Rohr zurück in das Reservoir; der Kreislauf funktionierte. Der Takt
    entsprach der Vorgabe von
    15 min Laufzeit und 45 min Pause. Beim Anlauf der Pumpe wurde der ESP32
    nicht zurückgesetzt. Ein Betrieb ohne Kondensator wurde nicht getestet; ob
    der Kondensator für den stabilen Betrieb notwendig ist, ist daher nicht
    belegt.],
  bewertung: "erfüllt",
)

== Soll-Ist-Abgleich

@tab-soll-ist ordnet jedem Zielkriterium den prüfenden Testfall und das
Ergebnis zu.

#figure(
  table_style_1(
    table(
      columns: (auto, auto, auto, 1fr),
      align: left + horizon,
      table.header([Kriterium], [Test], [Bewertung], [Anmerkung]),
      [K1 Wassertemperatur], [T1], bewertung_badge("erfüllt"),
      [Messwert und Alarm reagieren; kein Referenzthermometer],
      [K2 Leitfähigkeit], [T2], bewertung_badge("teilweise erfüllt"),
      [Kalibrierung durchgeführt; keine unabhängige Kontrollmessung,
        Referenzgerät nicht geprüft],
      [K3 Füllstand], [T3], bewertung_badge("erfüllt"),
      [Erkennung und Meldung über Alarm-LED],
      [K4 Trockenlaufschutz], [T4], bewertung_badge("erfüllt"),
      [Pumpe läuft ohne erkannte Flüssigkeit nicht],
      [K5 Pumpenbetrieb], [T4], bewertung_badge("erfüllt"),
      [Takt eingehalten, kein Neustart des ESP32 (mit Kondensator)],
      [K6 Ablesbarkeit], [—], bewertung_badge("nicht geprüft"),
      [Anzeige umgesetzt (@kap-software); keine Erprobung mit Schülern],
    ),
  ),
  caption: [Soll-Ist-Abgleich der Zielkriterien],
) <tab-soll-ist>

Der Kern der technischen Problemstellung ist nachgewiesen: Die Pumpe läuft
ohne manuellen Eingriff im vorgesehenen Takt, die Verriegelung verhindert
einen Trockenlauf (K4, K5), und beide Störfälle, niedriger Füllstand und
Temperatur außerhalb des Zielbereichs, werden sichtbar gemeldet (K1, K3). Die
Leitfähigkeitsmessung (K2) ist kalibriert, aber nicht gegen eine unabhängige
Referenz abgesichert. Die didaktische
Zielsetzung (K6) ist konstruktiv umgesetzt, ihre Wirkung auf die Zielgruppe
wurde nicht erprobt. Diese Einschränkungen werden in @kap-fazit als
Limitationen aufgegriffen.
