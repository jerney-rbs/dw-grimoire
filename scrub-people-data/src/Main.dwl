%dw 2.0
output application/json

import mapLeafValues from dw::util::Tree

fun isSsn(k): Boolean = do {
  var lk = lower(k as String)
  ---
  (lk contains "ssn") 
    or (lk contains "nationalid")
}

fun isFirstName(k): Boolean =
  lower(k as String) contains "firstname"

fun isLastName(k): Boolean =
  lower(k as String) contains "lastname"

fun isDob(k): Boolean =
  lower(k as String) contains "birth"

fun scrub(payload: Any): Any =
  payload mapLeafValues (v,k) -> do {
  var key = k[-1].selector
  var placeholder = "REDACTED"
  ---
  key match {
    case ssn       if isSsn(key)       -> placeholder
    case firstName if isFirstName(key) -> placeholder
    case lastName  if isLastName(key)  -> placeholder
    case dob       if isDob(key)       -> placeholder
    else -> v
  }
}
---
scrub(payload)
