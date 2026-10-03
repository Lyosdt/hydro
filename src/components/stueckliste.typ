#import "tables.typ": table_style_1, table_style_3_bottom_cell
#import "formatting.typ": todo

// 12.5 -> "12,50 €"
#let eur(value) = {
  let cents = int(calc.round(value * 100))
  let rest = calc.rem(cents, 100)
  str(calc.quo(cents, 100)) + "," + (if rest < 10 { "0" } else { "" }) + str(rest) + " €"
}

// Bill of materials. Each position:
//   (bezeichnung: "...", typ: "...", anzahl: 1, quelle: "..." | none, preis: 4.99 | none)
// `preis` is the unit price in €. A missing price or source is shown as TODO,
// and the total is only computed once every price is known.
#let stueckliste(positionen) = {
  let missing(name) = text(red, weight: "bold", "TODO")
  let summe_bekannt = positionen.all(p => p.preis != none)
  let summe = positionen.map(p => if p.preis == none { 0 } else { p.preis * p.anzahl }).sum(default: 0)

  if not summe_bekannt {
    todo("Stückliste: Preise unvollständig, Summe wird erst bei vollständigen Preisen berechnet")
  }

  table_style_1(
    table(
      columns: (auto, 1fr, auto, auto, auto, auto),
      align: (x, y) => if x >= 4 { right } else if x == 3 { center } else { left },
      table.header(
        [Bezeichnung], [Typ], [Anz.], [Bezugsquelle], [Einzelpreis], [Summe],
      ),
      ..positionen.map(p => (
        p.bezeichnung,
        p.typ,
        str(p.anzahl),
        if p.quelle == none { missing("Quelle") } else { p.quelle },
        if p.preis == none { missing("Preis") } else { eur(p.preis) },
        if p.preis == none { missing("Preis") } else { eur(p.preis * p.anzahl) },
      )).flatten(),
      table.cell(colspan: 5, stroke: (top: 0.7pt + black), strong[Gesamt]),
      table_style_3_bottom_cell(if summe_bekannt { eur(summe) } else { "TODO" }),
    ),
  )
}
