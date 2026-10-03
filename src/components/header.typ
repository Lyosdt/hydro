#import "../const.typ": nordakademie_blue

// Header component: document type and short title left, logo right
#let header(doc_type, short_title) = {
  grid(
    columns: (1fr, auto),
    align: horizon,
    stroke: (bottom: .5pt + black),
    inset: (bottom: 5pt),
    {
      set text(size: 9pt, fill: nordakademie_blue)
      text(weight: "bold", upper(doc_type))
      linebreak()
      short_title
    },
    image("../res/nordakademie_logo.png", height: 1.1cm),
  )
}
