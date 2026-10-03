#let bold_upper(content) = text(weight: 700, upper(content))

// Visible TODO marker. Every marker is also registered as metadata, so the
// document refuses to compile with `entwurf: false` while TODOs remain.
#let todo(content) = [#metadata(content)<todo-marker>#strong(text(red, "TODO: " + content))]

// Placeholder for a missing photo/drawing. Use inside #figure(...) so numbering
// and references already work; replace with image(...) once the file exists.
#let bild_platzhalter(beschreibung, height: 5cm) = rect(
  width: 100%,
  height: height,
  stroke: (paint: red, dash: "dashed"),
  align(center + horizon, todo(beschreibung)),
)

#let clickable_link(url, display: none) = if display == none {
  link(url, underline(text(blue, url)))
} else {
  link(url, underline(text(blue, display)))
}
