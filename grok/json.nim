import std/json
import std/times

import grok/time

proc unixTimeToZone*(js: JsonNode; tz: Timezone; name="time"): DateTime =
  result = js.get(name, 0).fromUnix().inZone(tz)

converter `%`*(input: DateTime): JsonNode =
  result = % input.iso8601()
