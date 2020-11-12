%dw 2.0
output application/json

var muleFile = payload

fun variables(): Array =
  (muleFile..@target default []) ++ (muleFile..@variableName default []) distinctBy $ orderBy $

fun flows(): Array = 
  (muleFile..*flow default []) ++ (muleFile..*"sub-flow" default [])

fun flowNames(): Array = 
  flows() map $.@name orderBy $

fun scatters(): Array = do {
  flows()
    map ((flow) ->
      {
        flowName: flow.@name,
        scattersWithNoTimeout: sizeOf((flow..*"scatter-gather" default []) filter !$.@timeout?)
      })
    filter ($.scattersWithNoTimeout > 0)
  }

fun infoLoggers(): Array = do {
  flows()
    map ((flow) ->
      {
        flowName: flow.@name,
        loggerNames: (flow..*logger default [] filter $.@level == "INFO") map $.@name
      })
    filter !isEmpty($.loggerNames)
}
---
{
  variableNames         : variables(),
  flowNames             : flowNames(),
  infoLoggers           : infoLoggers(),
  scattersWithNoTimeout : scatters()
}