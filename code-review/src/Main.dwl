%dw 2.0
input payload application/xml
output application/json

var muleFile = payload

fun variables(): Array =
  (muleFile..@target default []) ++ (muleFile..@variableName default [])

fun flows(): Array = 
  (muleFile..*flow default []) ++ (muleFile..*"sub-flow" default [])

fun flowNames(): Array = 
  flows() map $.@name

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
        loggerNames: (flow..*logger default []) filter ($.@level == "INFO") map $.@name
      })
    filter !isEmpty($.loggerNames)
  }
---
{
  variableNames         : variables()   distinctBy $ orderBy $,
  flowNames             : flowNames()   distinctBy $ orderBy $,
  infoLoggers           : infoLoggers() distinctBy $ orderBy $.flowName,
  scattersWithNoTimeout : scatters()    distinctBy $ orderBy $.flowName
}