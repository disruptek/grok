import std/strutils
import std/macros

template crash*(msg = "crash") =
  writeStackTrace()
  debugEcho msg
  quit 1

# just a hack to output the example numbers during docgen...
when defined(nimdoc):
  var
    exampleCounter {.compileTime.}: int

macro ex*(x: untyped): untyped =
  result = x
  when defined(nimdoc):
    for node in x.last:
      if node.kind == nnkCall:
        if node[0].kind == nnkIdent:
          if $node[0] == "runnableExamples":
            inc exampleCounter
            let id = repr(x[0])
            hint "fig. $1 for $2:" % [ $exampleCounter, $id ]
            hint indent(repr(node[1]), 4)

proc quiesceMemory*(message: string): int {.inline.} =
  GC_fullCollect()
  when defined(debug):
    stdmsg().writeLine GC_getStatistics()
  result = getOccupiedMem()

template dumpMem*() =
  when defined(debug):
    when defined(nimTypeNames):
      dumpNumberOfInstances()
    stdmsg().writeLine "total: " & $getTotalMem()
    stdmsg().writeLine " free: " & $getFreeMem()
    stdmsg().writeLine "owned: " & $getOccupiedMem()
    stdmsg().writeLine "  max: " & $getMaxMem()
