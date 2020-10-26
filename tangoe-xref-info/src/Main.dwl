%dw 2.0
input payload application/json
output application/json

// To execute: dw --spell jerney-rbs/tango-xref-info

/**
 * Builds a translation mapping from the translation table. Example output:
 * 
 * {
 *   "COMPANY": {
 *     "AES_LLC": "10",
 *     "PP_LLC": "10",
 *     "GDL_LLC": "10",
 *     "182": "10",
 *     "184": "10",
 *     "183": "10"
 *   }
 * }
 */
fun translations(payload: Object) =
   payload.translations 
     groupBy $.fieldName
     mapObject (fieldTranslations, fieldName) -> do {
       var translations = fieldTranslations
                            groupBy ($.firstKey ++ ($.secondKey default "") ++ ($.thirdKey default ""))
                            mapObject {($$): $[0]["output"]}
       ---
        {(fieldName): translations}
     }

/**
 * Builds selection criteria used for query params in ODS call. Example output:
 * 
 * {
 *   "employeeStatus": "A,U,P,S",
 *   "company": "ADCS_LLC,AES_LLC,GDL_LLC,PDL_LLC,OPL_LLC,PP_LLC,173,183,184,182,176,172,174"
 * }
 */
fun selections(payload: Object) = do {
  // Used to map from fieldName column in XRef table to ODS API Query Parameters
  // TODO: Feel free to add or remove fieldName mappings as necessary.
  var fieldNameToQueryParam = {
      "EMPLOYEESTATUS" : "employeeStatus",
      "LEGALENTITY"    : "company"
      // Others?
  }
  ---
  payload.selections 
    groupBy $.fieldName
    mapObject {(fieldNameToQueryParam[$$]): $..firstKey joinBy ","}
}
---
{
    selections: selections(payload),
    translations: translations(payload)
}