%dw 2.0
output application/json

var muleFile    = payload
var variables   = (muleFile..@target default []) ++ (muleFile..@variableName default []) distinctBy $ orderBy $
var flows       = (muleFile..*flow default []) ++ (muleFile..*"sub-flow" default [])
var flowNames   = flows map $.@name orderBy $
var scatters    = do {
  flows
    map ((flow) ->
      {
        flowName: flow.@name,
        scattersWithNoTimeout: sizeOf((flow..*"scatter-gather" default []) filter !$.@timeout?)
      })
    filter ($.scattersWithNoTimeout > 0)
}
var infoLoggers = do {
  var flows = (muleFile..*flow default []) ++ (muleFile..*"sub-flow" default []) 
  ---
  flows 
    map ((flow) ->
      {
        flowName: flow.@name,
        loggerNames: (flow..*logger default [] filter $.@level == "INFO") map $.@name
      })
    filter !isEmpty($.loggerNames)
}
---
{
  variableNames         : variables,
  flowNames             : flowNames,
  infoLoggers           : infoLoggers,
  scattersWithNoTimeout : scatters
}