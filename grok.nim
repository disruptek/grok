import std/macros

import grok/mem
export mem

template crash*(msg = "crash") =
  writeStackTrace()
  debugEcho msg
  quit 1

macro enumValuesAsSet*(e: typed) =
  ## given an enum type, render a set of its values
  newNimNode(nnkCurly).add(e.getType[1][1..^1])

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
