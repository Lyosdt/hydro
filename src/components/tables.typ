#import "../const.typ": nordakademie_blue

// Default table style: tinted header, thin rules between rows, closing rule
// at the bottom. Cell text is set ragged-right, since justified text tears
// apart in narrow columns.
#let table_style_1(table_content) = {
  set text(size: 10pt)
  set par(justify: false, leading: 0.55em)
  show table.cell.where(y: 0): strong
  show table: it => block(stroke: (bottom: 0.8pt + nordakademie_blue), it)
  set table(
    fill: (x, y) => if y == 0 { nordakademie_blue.lighten(88%) },
    stroke: (x, y) => (
      top: if y == 0 { 0.8pt + nordakademie_blue }
        else if y == 1 { 0.6pt + nordakademie_blue }
        else { 0.4pt + luma(200) },
    ),
    inset: (x: 6pt, y: 5pt),
    align: (x, y) => (
      if x > 0 { center + top }
      else { left + top }
    ),
  )
  table_content
}

#let table_style_2(table_content) = {
  set text(size: 0.8em)
  show table.cell.where(y: 0): strong
  set table(
    stroke: (x, y) => {
      if y == 0 {
        (bottom: 0.7pt + black)
      }
      if y > 1 {
        (top: 0.7pt + gray)
      }
      if x == 0 {
        (right: 0.7pt + black)
      }
    },
    align: left,
    inset: 8pt,
  )
  pad(x: 1em, y: 1em, table_content)
}

#let table_style_3(table_content) = {
  set text(size: 0.8em)
  show table.cell.where(y: 0): strong
  set table(
    stroke: (x, y) => {
      if y == 0 {
        (bottom: 0.7pt + black)
      }
      if y > 1 {
        (top: 0.7pt + gray)
      }
      if x < 2 {
        (right: 0.7pt + black)
      }
      if x > 2 {
        (left: 0.7pt + gray)
      }
    },
    align: (x, y) => (
      if x > 0 { center }
      else { left }
    ),
    inset: 8pt,
  )
  pad(x: 1em, y: 1em, table_content)
}

#let table_style_3_bottom_cell(content) = {
  table.cell(stroke: (top: 0.7pt + black), strong(content))
}