#import "components/project_paper.typ": project_paper
#import "const.typ": language
#import "components/formatting.typ": todo

#show: project_paper.with(
	language: language,
	title: "NFT-Hydroponik mit ESP32",
	subtitle: "Automatisierter Basilikum-Demonstrator für den Schuleinsatz",
	module: todo("Modulbezeichnung"),
	// Ein Eintrag je Gruppenmitglied
	authors: (
		(name: "Lyonel Stadthoewer", matnr: todo("Matrikelnummer")),
	),
	programme: todo("Studiengang, Zenturie"),
	lecturer: todo("Dozent"),
	date: todo("Abgabedatum"),
	// Vor der Abgabe auf false setzen: Kompilierung schlägt fehl, solange TODOs offen sind
	entwurf: true,
	// Kapitel nicht auf neuer Seite beginnen (Seitenumfang)
	chapter_pagebreak: false,
	appendix_content: include "chapters/99_anhang.typ",
)

// Lange Tabellen dürfen umbrechen (Kopfzeile wird wiederholt), statt als
// Ganzes auf die nächste Seite zu springen
#show figure.where(kind: table): set block(breakable: true)

#include "chapters/01_problemstellung.typ"
#include "chapters/02_konzept.typ"
#include "chapters/03_stueckliste.typ"
#include "chapters/04_bauanleitung.typ"
#include "chapters/05_testprotokoll.typ"
#include "chapters/06_fazit.typ"
