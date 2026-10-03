#import "../const.typ": nordakademie_blue
#import "formatting.typ": todo

// Allowed ratings (CLAUDE.md, section 5)
#let bewertungen = (
  "erfüllt": rgb(30, 130, 60),
  "teilweise erfüllt": rgb(200, 130, 0),
  "nicht geprüft": gray,
)

#let bewertung_badge(bewertung) = {
  if not bewertungen.keys().contains(bewertung) {
    panic(
      "Bewertung muss eine von " + bewertungen.keys().join(", ") + " sein, war `" + str(bewertung) + "`.",
    )
  }
  box(
    fill: bewertungen.at(bewertung),
    inset: (x: 5pt, y: 3pt),
    radius: 2pt,
    text(fill: white, weight: "bold", size: 0.85em, bewertung),
  )
}

// Missing fields are rendered as visible TODO markers instead of left blank
#let feld(value, name) = if value == none { todo(name + " fehlt") } else { value }

// One test case block. Use one call per test case:
//   #testfall(
//     id: "T2",
//     titel: "Abgleich TDS-Sensor gegen Handheld-Messgerät",
//     zeitraum: [...], kriterium: [K2], vorgehen: [...], beobachtung: [...],
//     bewertung: "erfüllt",
//   )
#let testfall(
  id: none,
  titel: none,
  zeitraum: none,
  kriterium: none,
  vorgehen: none,
  beobachtung: none,
  bewertung: none,
) = {
  let label_cell(content) = table.cell(
    fill: nordakademie_blue.lighten(85%),
    text(weight: "bold", content),
  )
  block(breakable: false, above: 1.5em, below: 1.5em, {
    set par(justify: false)
    table(
      columns: (3.2cm, 1fr),
      inset: 7pt,
      stroke: 0.5pt + nordakademie_blue,
      table.cell(
        colspan: 2,
        fill: nordakademie_blue,
        text(fill: white, weight: "bold")[#feld(id, "ID") — #feld(titel, "Bezeichnung")],
      ),
      label_cell[Zeitraum], feld(zeitraum, "Zeitraum"),
      label_cell[Prüfkriterium], feld(kriterium, "Prüfkriterium"),
      label_cell[Vorgehen], feld(vorgehen, "Vorgehen"),
      label_cell[Beobachtung], feld(beobachtung, "Beobachtung"),
      label_cell[Bewertung], if bewertung == none { todo("Bewertung fehlt") } else { bewertung_badge(bewertung) },
    )
  })
}
