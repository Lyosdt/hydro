#let bold_upper(content) = text(weight: 700, upper(content))

// Visible TODO marker. Every marker is also registered as metadata, so the
// document refuses to compile with `entwurf: false` while TODOs remain.
#let todo(content) = [#metadata(content)<todo-marker>#strong(text(red, "TODO: " + content))]

#let clickable_link(url, display: none) = if display == none {
  link(url, underline(text(blue, url)))
} else {
  link(url, underline(text(blue, display)))
}
