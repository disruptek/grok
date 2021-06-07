proc quiesceMemory*(message: string): int {.inline.} =
  when not defined(nimscript):
    when not defined(js):
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
