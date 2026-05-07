#set page(
  paper: "presentation-16-9",
  fill: rgb("#0d0d0d"),
  margin: (x: 8%, y: 10%),
)
#set text(fill: white, font: "Helvetica Neue", weight: "bold", size: 2.8em)
#set par(justify: false, leading: 0.6em)

#let accent = rgb("#e8702a")
#let muted  = rgb("#888888")

#let slide(body) = {
  align(horizon + center, body)
  pagebreak(weak: true)
}

#let hl(body)  = text(fill: accent, body)
#let dim(body) = text(fill: muted, weight: "regular", size: 0.65em, body)
#let code-slide(body) = slide[
  #set text(size: 0.55em, weight: "regular", font: "Menlo")
  #set align(left)
  #body
]

// ── Title ────────────────────────────────────────────────────────────────────

#slide[
  #text(size: 1.3em)[#hl[Endpoint]Compare]
]

// ── Problem ──────────────────────────────────────────────────────────────────

#slide[The Fear]

#slide[
  You upgrade Rails \
  #dim[(a big system update)]
]

#slide[
  500 pages \
  200 APIs
]

#slide[Did anything break?]

#slide[
  You can't check \
  them all manually
]

// ── Solution ─────────────────────────────────────────────────────────────────

#slide[
  What if you could check \
  #hl[all] of them at once?
]

#slide[#hl[Endpoint]Compare]

#slide[
  Deploy #hl[two] servers \
  Ask both the #hl[same] questions \
  Compare the answers
]

// ── Pass / Fail ───────────────────────────────────────────────────────────────

#code-slide[
```
Old  →  /api/products  →  { "count": 42 }
New  →  /api/products  →  { "count": 42 }
```
#v(0.4em)
#align(center)[#text(fill: rgb("#4caf50"), size: 1.6em)[✓  PASS]]
]

#code-slide[
```
Old  →  /lp/pc  →  200 OK
New  →  /lp/pc  →  500 ERROR
```
#v(0.4em)
#align(center)[#text(fill: rgb("#f44336"), size: 1.6em)[✗  FAIL]]
]

// ── How to use ───────────────────────────────────────────────────────────────

#slide[You write a list of paths]

#code-slide[
```yaml
checks:
  - get: /healthcheck
  - get: /api/products
  - get: /lp
  - get: /lp/pc
  - post: /api/orders
```
]

#slide[Or just pick a #hl[preset]]

#slide[
  Open the UI \
  #dim[Pick baseline & candidate] \
  Hit #hl[Run]
]

#slide[Live results \
#dim[as they stream in]]

#slide[#text(size: 1.4em)[Demo]]

// ── Bug story ────────────────────────────────────────────────────────────────

#slide[Now the fun part]

#slide[I found a bug \
#dim[while building this tool]]

#slide[
  The tool sends requests \
  to both servers \
  #hl[at the same time]
]

#slide[Parallel = #hl[faster]]

#slide[
  But pages returned \
  the #hl[wrong] canonical URL
]

#code-slide[
```
User visits:  /lp
Page says:    canonical = /lp/pc   ← wrong!
```
]

#slide[
  I thought: \
  #dim[my code has a race condition]
]

#slide[
  I rewrote everything \
  threads #sym.arrow processes
]

#slide[#hl[Still broken]]

#slide[#text(size: 2em)[...]]

#slide[It was the #hl[target app]]

#slide[
  hikakaku-cms had \
  a #hl[shared mutable singleton] \
  for request state
]

#code-slide[
```ruby
class RequestManager
  include Singleton

  attr_accessor :request  # shared between all threads
  attr_accessor :params   # overwritten by each request
end
```
]

#slide[
  Thread A writes #hl[`/lp`] \
  Thread B writes `/ lp/pc` \
  Thread A reads… #hl[`/lp/pc`]
]

#slide[Hidden for years]

#slide[
  Rails 6 serialized requests \
  #hl[Rails 8 does not]
]

#slide[
  EndpointCompare \
  #hl[found it] — by design
]

#slide[
  Parallel requests \
  exposed a silent bug \
  in #hl[production code]
]

// ── Guide ────────────────────────────────────────────────────────────────────

#slide[How to run it]

#code-slide[
```bash
docker compose up
```
#v(0.6em)
#align(center)[#text(size: 1.2em)[open #text(fill: accent)[localhost:9292]]]
]

#slide[
  Choose a preset \
  #dim[or write your own manifest] \
  Hit Run
]

#slide[When to use it]

#slide[Before any big #hl[upgrade]]

#slide[Before major #hl[deploys]]

#slide[
  Not a replacement \
  for unit tests
]

#slide[
  A #hl[safety net] \
  for the whole system
]

// ── End ──────────────────────────────────────────────────────────────────────

#slide[#text(size: 1.4em)[Questions?]]

#slide[
  Try it \
  #dim[`endpoint_compare`]
]
