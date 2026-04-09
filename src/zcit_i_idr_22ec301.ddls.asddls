@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ID Request Interface View'
define root view entity ZCIT_I_IDR_22EC301
  as select from zcit_idr_22ec301
{
  key request_id      as RequestID,
      employee_id     as EmployeeID,
      employee_name   as EmployeeName,
      request_status  as RequestStatus,
      office_location as OfficeLocation,
      
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at as LastChangedAt
}
