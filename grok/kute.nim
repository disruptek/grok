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
  size = len("1024" & $KuteUnit.high)

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
        result.add $(b div r)
        result.add '.'
        result.add $((b mod r) div 100)
      result.add system.`$`(KuteUnit i)
      break
  assert result.len <= size  # make sure we don't alloc somehow
