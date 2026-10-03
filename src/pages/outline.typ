// Outline Components

// Table of Contents
#let toc(title) = {
  show outline.entry.where(level: 1): strong
  show outline.entry: set block(above: 0.7em)
  show outline.entry.where(level: 1): set block(above: 1.2em)
  outline(
    indent: 20pt,
    title: title,
  )
  pagebreak(weak: true)
}

// List of x — only printed if the document contains at least one figure of that kind
#let list_of(title, kind) = context {
  if query(figure.where(kind: kind)).len() > 0 {
    heading[#title]
    outline(
      title: none,
      target: figure.where(kind: kind),
    )
    pagebreak(weak: true)
  }
}
