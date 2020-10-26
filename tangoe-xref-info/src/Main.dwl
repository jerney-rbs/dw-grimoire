%dw 2.0
input payload application/json
output application/json
---
payload.translations 
  groupBy ($.firstKey ++ ($.secondKey default ""))
  mapObject (translation, key) -> {(key): translation[0]["output"]}