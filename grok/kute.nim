import std/math

import grok

type
  Kute* = distinct int64
  KuteUnit* = enum
    Bytes      = "b"
    KiloBytes  = "kb"
    MegaBytes  = "mb"
    GigaBytes  = "gb"
    TeraBytes  = "tb"
    PetaBytes  = "pb"
    ExaBytes   = "eb"
    ZettaBytes = "zb"
    YottaBytes = "yb"

const
  k = 1024
  size = len("1023.9" & $KuteUnit.high)

proc `<`(a, b: Kute): bool {.borrow.}
proc `==`(a, b: Kute): bool {.borrow.}
proc `div`(a, b: Kute): int64 {.borrow.}
proc `mod`(a, b: Kute): int64 {.borrow.}
converter toBase(b: Kute): int64 = int64 b

converter `$`*(b: Kute): string =
  result = newStringOfCap size
  var i = 0
  # start low, go high
  while i <= KuteUnit.high.int:
    # r is the next largest unit
    let r = k ^ (i+1)
    if b > r:
      # go to the next unit
      inc i
    else:
      if i == 0:
        # the first unit gets special treatment
        result.add system.`$`(b)
      else:
        # else, gimme the decimal remainder
        let r = k ^ i
        let bdr = b div r
        result.add $bdr
        var rem = b mod r
        # only provide a remainder if it exists and bdr is 1-2 digits
        if rem != 0 and bdr < 100:
          result.add '.'
          # smaller bdr values yield more remainder digits
          result.add $(rem * (if bdr > 9: 100 else: 1000) div r)
      result.add system.`$`(KuteUnit i)
      break
  assert result.len <= size  # make sure we don't alloc somehow

when isMainModule:
  import balls

  suite "kute":
    check "sanity":
      $Kute(812) == "812b"
      $Kute(8192) == "8kb"
      $Kute(8900) == "8.691kb"
      $Kute(10*8500) == "83.0kb"
      $Kute(100*8500) == "830kb"
      $Kute(1000*8500) == "8.106mb"
