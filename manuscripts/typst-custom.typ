// Allow figures (and tables wrapped in figure) to paginate across pages
#show figure: set block(breakable: true)

// Add breathing room between author block and table of contents
#show outline: it => {
  v(2em)
  it
}
