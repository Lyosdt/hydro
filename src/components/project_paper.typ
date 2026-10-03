#import "header.typ": header
#import "translations.typ": english_heading_texts, german_heading_texts
#import "../pages/outline.typ": toc, list_of
#import "../pages/cover.typ": cover
#import "../dependencies.typ": zebraw, zebraw-themes, make-glossary, print-glossary, register-glossary, there-are-refs
#import "../abbreviations.typ": abbreviation_list

#let project_paper(
  language: "de",
  font_size: 12pt,
  margin_y: 3cm,
  margin_x: 2cm,
  par_spacing: 1.2em,
  list_spacing: 0.8em,
  list_indent: 1.5em,
  // Sources are optional in this project report: none = no bibliography
  bibliography_path: none,
  citation_style: "ieee",
  // Start every chapter on a new page
  chapter_pagebreak: true,
  // true: TODO markers are allowed. false: compilation fails while TODOs remain
  entwurf: true,
  headings: (
    margin_top: 30pt,
    margin_bottom: 20pt,
    font_size: 21pt,
  ),
  title: none,
  subtitle: none,
  short_title: none,
  module: none,
  authors: (),
  programme: none,
  lecturer: none,
  date: none,
  appendix_content: none,
  body,
) = {
  // initialize extensions
  show: make-glossary // Glossary
  show: zebraw.with(..zebraw-themes.zebra) // Code listings

  let heading_texts = if language == "en" {
    english_heading_texts
  } else if language == "de" {
    german_heading_texts
  }

  // Document config
  set document(title: title, author: authors.map(a => a.name))
  set text(
    size: font_size,
    lang: language
  )
  set page(
    header: header(heading_texts.doc_type, if short_title != none { short_title } else { title }),
    margin: (y: margin_y, x: margin_x),
  )
  set par(spacing: par_spacing)
  show heading.where(level: 1): set block(above: headings.margin_top, below: headings.margin_bottom)
  show heading.where(level: 1): set text(size: headings.font_size, weight: 600)
  show heading.where(level: 2): set block(above: headings.margin_top, below: headings.margin_bottom)
  set list(spacing: list_spacing, indent: list_indent)
  set enum(spacing: list_spacing, indent: list_indent)
  // Tables and figures: caption above tables, below images (common convention)
  show figure.where(kind: table): set figure.caption(position: top)
  // Long tables (e.g. bill of materials) may continue on the next page
  show figure.where(kind: table): set block(breakable: true)

  // Cover (no header on the cover page)
  {
    set page(header: none)
    cover(heading_texts, title, subtitle, module, authors, programme, lecturer, date)
  }

  // Start page numbering from here
  set page(numbering: "I")
  counter(page).update(1)

  // Table of Contents
  toc(heading_texts.contents)

  // Lists of figures, tables, listings (only printed if not empty)
  list_of(heading_texts.figures, image)
  list_of(heading_texts.tables, table)
  list_of(heading_texts.listings, raw)

  // List of Acronyms (only referenced abbreviations are printed; the heading
  // is hidden if none are used, print-glossary must always run for the labels)
  register-glossary(abbreviation_list)
  context if there-are-refs() { heading(heading_texts.abbreviations) }
  print-glossary(
    abbreviation_list,
    disable-back-references: true,
  )
  [#[] <end-of-roman-numbering>]

  // Main Section
  set page(numbering: "1")
  counter(page).update(1)
  set heading(numbering: "1.1")
  set par(justify: true)
  {
    show heading.where(level: 1): it => {
      if chapter_pagebreak { pagebreak(weak: true) }
      it
    }
    body
  }

  // Back matter in roman numbering, continuing from the front matter
  set page(numbering: "I")
  context {
    let old_page_number = counter(page).at(<end-of-roman-numbering>).first()
    counter(page).update(old_page_number + 1)
  }
  set heading(numbering: none)
  pagebreak(weak: true)

  // References (optional)
  if bibliography_path != none {
    show link: it => text(blue, it)
    set par(spacing: 1em)
    set text(size: 11pt)
    bibliography(
      bibliography_path,
      title: heading_texts.references,
      style: citation_style,
    )
    pagebreak(weak: true)
  }

  // Appendix
  if (appendix_content != none) {
    set heading(numbering: "A.1 ")
    counter(heading).update(0)
    heading(heading_texts.appendix)
    appendix_content
  }

  // Guard against submitting a draft with open TODOs
  if not entwurf {
    context {
      let open = query(<todo-marker>)
      if open.len() > 0 {
        panic(
          str(open.len()) + " offene TODO-Marker. Vor der Abgabe auflösen oder `entwurf: true` setzen.",
        )
      }
    }
  }
}
