import std/macros

import grok/mem
export mem

template crash*(msg = "crash") =
  writeStackTrace()
  debugEcho msg
  quit 1

macro enumValuesAsArray*(e: typed): untyped =
  ## given an enum type, render an array of its symbol fields
  nnkBracket.newNimNode(e).add:
    e.getType[1][1..^1]

macro enumValuesAsSet*(e: typed): untyped =
  ## given an enum type, render a set of its symbol fields
  nnkCurly.newNimNode(e).add:
    e.getType[1][1..^1]

macro enumValuesAsSetOfOrds*(e: typed): untyped =
  ## given an enum type, render a set of its integer values
  result = nnkCurly.newNimNode(e)
  for n in 1 ..< e.getType[1].len:
    result.add:
      newLit e.getType[1][n].intVal

# just a hack to output the example numbers during docgen...
when defined(nimdoc):
  var
    exampleCounter {.compileTime.}: int

when defined(nimdoc):
  import std/strutils

macro ex*(x: untyped): untyped =
  result = x
  when defined(nimdoc):
    for node in x[^1]:
      if node.kind == nnkCall:
        if node[0].kind == nnkIdent:
          if $node[0] == "runnableExamples":
            inc exampleCounter
            let id = repr(x[0])
            hint "fig. $1 for $2:" % [ $exampleCounter, $id ]
            hint indent(repr(node[1]), 4)

proc errorAst*(s: string): NimNode =
  ## produce {.error: s.} in order to embed errors in the ast
  nnkPragma.newTree:
    ident"error".newColonExpr: newLit s

proc errorAst*(n: NimNode; s = "creepy ast"): NimNode =
  ## embed an error with a message
  errorAst s & ":\n" & treeRepr(n) & "\n"

proc accQuoted(s: string): NimNode = nnkAccQuoted.newTree: ident s

when isMainModule:
  type
    TestEnum = enum
      One   = (1, "1st")
      Two   = (2, "2nd")
      Three = (3, "3rd")

  when enumValuesAsArray(TestEnum) != [One, Two, Three]:
    error "enumValuesAsArray is broken"

  when enumValuesAsSet(TestEnum) != {One, Two, Three}:
    error "enumValuesAsSet is broken"
