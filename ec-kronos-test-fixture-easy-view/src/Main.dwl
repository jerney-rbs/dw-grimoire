%dw 2.0
input payload application/json
output application/csv

import update from dw::util::Values

fun explodeData(persons: Array) = do {
  fun explodeEmploymentInformation(persons: Array) = do {
    persons flatMap (person) ->
      person.employmentInformation map (employmentInfo) ->
        person update ["employmentInformation"] with employmentInfo
  }

  fun explodeJobInformation(persons: Array) = do {
    persons flatMap (person) ->
      person.employmentInformation.jobInformation map (jobInfo) ->
        person update ["employmentInformation", "jobInformation"] with jobInfo
  }
  ---
  explodeJobInformation(explodeEmploymentInformation(persons))
}
---
explodeData(payload) orderBy $.personId map do {
  var jobInfo = $.employmentInformation.jobInformation
  ---
  {
    personId: $.personId,
    company: jobInfo.organisation.organisationStructure.company,
    departmentType: jobInfo.organisation.organisationStructure.departmentType,
    state: jobInfo.organisation.organisationStructure.address.state,
    employeeType: jobInfo.employeeType,
    employeeStatus: jobInfo.employeeStatus,
    flsaStatus: jobInfo.flsaStatus,
    regularTemp: jobInfo.regularTemp,
    startDate: jobInfo.effectiveStartDate,
    endDate: jobInfo.effectiveEndDate
  }
}