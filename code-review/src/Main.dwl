%dw 2.0
output application/json

var muleFile    = payload
var variables   = muleFile..@target ++ muleFile..@variableName distinctBy $ orderBy $
var flows       = muleFile..*flow ++ muleFile..*"sub-flow"
var flowNames   = flows map $.@name orderBy $
var infoLoggers = do {
  var flows = (muleFile..*flow ++ muleFile..*"sub-flow") 
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
  variableNames : variables,
  flowNames     : flowNames,
  infoLoggers   : infoLoggers
}