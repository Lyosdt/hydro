#import "tables.typ": table_style_1

// 12.5 -> "12,50 €"
#let eur(value) = {
  let cents = int(calc.round(value * 100))
  let sign = if cents < 0 { "−" } else { "" }
  cents = calc.abs(cents)
  let rest = calc.rem(cents, 100)
  sign + str(calc.quo(cents, 100)) + "," + (if rest < 10 { "0" } else { "" }) + str(rest) + " €"
}

// Bill of materials. Each entry is either a position
//   (bezeichnung: "...", typ: "...", anzahl: 1, quelle: "..." | none, preis: 4.99 | none)
// or a string/content that is rendered as a group header row.
// `preis` is the unit price in €. A missing price or source is shown as TODO,
// and the total is only computed once every price is known.
// `budget` (optional, in €) adds a budget and difference row.
#let stueckliste(eintraege, budget: none) = {
  let positionen = eintraege.filter(e => type(e) == dictionary)
  // Each empty cell counts as an open TODO (see `entwurf` in main.typ)
  let missing = [#metadata("Stückliste")<todo-marker>#text(red, weight: "bold", "TODO")]
  let summe_bekannt = positionen.all(p => p.preis != none)
  let summe = positionen.map(p => if p.preis == none { 0 } else { p.preis * p.anzahl }).sum(default: 0)

  let zeile(e) = if type(e) == dictionary {
    (
      e.bezeichnung,
      e.typ,
      str(e.anzahl),
      if e.quelle == none { missing } else { e.quelle },
      if e.preis == none { missing } else { eur(e.preis) },
      if e.preis == none { missing } else { eur(e.preis * e.anzahl) },
    )
  } else {
    (table.cell(colspan: 6, inset: (top: 9pt, rest: 5pt), emph(strong(e))),)
  }

  let fuss_zeile(label, wert) = (
    table.cell(colspan: 5, strong(label)),
    table.cell(align: right, strong(wert)),
  )

  set text(size: 10pt)
  set par(justify: false)
  table_style_1(
    table(
      columns: (auto, 1fr, auto, auto, auto, auto),
      inset: 5pt,
      align: (x, y) => if x >= 4 { right } else if x == 2 { center } else { left },
      table.header(
        [Bezeichnung], [Typ], [Anz.], [Bezugsquelle], [Einzelpreis], [Summe],
      ),
      ..eintraege.map(zeile).flatten(),
      table.hline(stroke: 0.7pt + black),
      ..fuss_zeile[Gesamt][#if summe_bekannt { eur(summe) } else { missing }],
      ..if budget != none {
        let differenz = if summe_bekannt { eur(budget - summe) } else { missing }
        fuss_zeile[Budget (Erstattungsgrenze)][#eur(budget)] + fuss_zeile[Differenz zum Budget][#differenz]
      } else { () },
    ),
  )
}
