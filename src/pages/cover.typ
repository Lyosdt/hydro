#import "../const.typ": nordakademie_blue

#let blue_cell(content) = table.cell(
	fill: nordakademie_blue,
	inset: 8pt,
	text(weight: "bold", fill: white, content),
)

#let value_cell(content) = table.cell(inset: 8pt, content)

// Cover Component
// authors: array of (name: "...", matnr: "...")
#let cover(texts, title, subtitle, module, authors, programme, lecturer, date) = {
	set text(font: "Liberation Sans", fallback: true)
	set par(justify: false)

	grid(
		columns: (1fr, auto),
		align: horizon,
		text(weight: "bold", fill: nordakademie_blue, size: 15pt, texts.doc_type),
		image("../res/nordakademie_logo.png", height: 1.4cm),
	)

	v(3cm)
	text(weight: "bold", size: 22pt, fill: nordakademie_blue, title)
	if subtitle != none {
		v(0.3cm)
		text(size: 14pt, subtitle)
	}
	v(2cm)

	table(
		columns: (1fr, 2fr),
		stroke: 0.5pt + nordakademie_blue,
		blue_cell(texts.cover_module), value_cell(module),
		blue_cell(texts.cover_authors), value_cell(
			authors.map(a => [#a.name (#a.matnr)]).join(linebreak())
		),
		blue_cell(texts.cover_programme), value_cell(programme),
		blue_cell(texts.cover_lecturer), value_cell(lecturer),
		blue_cell(texts.cover_date), value_cell(date),
	)

	set text(font: "libertinus serif")
	pagebreak()
}
