#let IMAGE_BOX_MAX_WIDTH = 120pt
#let IMAGE_BOX_MAX_HEIGHT = 80pt

// Project template definition.
#let project(title: "", subtitle: none, school-logo: none, company-logo: none, authors: (), mentors: (), jury: (), branch: none, university: none, academic-year: none, french: false, footer-text: "RELATÓRIO", body) = {
  set document(author: authors, title: title)
  set page(
    footer: context {
      let pageNumber = counter(page).at(here()).first();
      if pageNumber > 1 {
        line(length: 100%, stroke: 0.5pt)
        v(-2pt)
        text(size: 12pt, weight: "regular")[
          #footer-text
          #h(1fr)
          #pageNumber
          #h(1fr)
          #academic-year
        ]
      }
    }
  )

  let dict = json("resources/data.json")
  set text(font: "Libertinus Serif", size: 13pt)
  set heading(numbering: "1.1")

  show heading: it => {
    if it.level == 1 and it.numbering != none {
      pagebreak()
      v(10pt)
      text(size: 25pt)[#dict.chapter #counter(heading).display(). #it.body ]
      v(-2pt)
    } else {
      v(5pt)
      [#it]
      v(12pt)
    }
  }

  block[
    #h(1fr)
    #box(height: IMAGE_BOX_MAX_HEIGHT, width: IMAGE_BOX_MAX_WIDTH)[
      #align(center)[
        #if school-logo == none {
          image("images/ufrj-logo.svg")
        } else {
          school-logo
        }
      ]
    ]
  ]

  align(center + horizon)[
    #if subtitle != none {
      text(size: 14pt, tracking: 2pt)[
        #smallcaps[
          #subtitle
        ]
      ]
    }
    #line(length: 100%, stroke: 0.5pt)
    #text(size: 20pt, weight: "bold")[Simulação de uma Rede Aberta de Filas: Análise de Tempo de Serviço e Métricas de Desempenho]
    #line(length: 100%, stroke: 0.5pt)
  ]

  box()
  h(1fr)
  grid(
    columns: (auto, 1fr, auto),
    [
      #if authors.len() > 0 {
        [
          #text(weight: "bold")[
            #if authors.len() > 1 {
              dict.author_plural
            } else {
              dict.author
            }
            #linebreak()
          ]
          #for author in authors {
            [#author #linebreak()]
          }
        ]
      }
    ],
    [
      #if mentors != none and mentors.len() > 0 {
        align(right)[
          #text(weight: "bold")[
            #if mentors.len() > 1 {
              dict.mentor_plural
            } else {
              dict.mentor
            }
            #linebreak()
          ]
          #for mentor in mentors {
            mentor
            linebreak()
          }
        ]
      }
      #if jury != none and jury.len() > 0 {
        align(right)[
          *#dict.jury* #linebreak()
          #for prof in jury {
            [#prof #linebreak()]
          }
        ]
      }
    ]
  )

  align(center + bottom)[
    #if branch != none {
      branch
      linebreak()
    }
    #if university != none {
      university
      linebreak()
    }
    #if academic-year != none {
      [#academic-year]
    }
  ]
  
  pagebreak()

  // Table of contents with customized entries
  outline(
    title: [Sumário],
    depth: 3,
    indent: true
  )

  // Uncomment for additional table
  // outline(
  //   title: dict.figures_table,
  //   target: figure.where(kind: image)
  // )

  body
}
