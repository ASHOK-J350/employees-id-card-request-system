@EndUserText.label: 'Projection View for ID Request'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Search.searchable: true
@Metadata.allowExtensions: true  // <-- THIS IS THE LINE THAT FIXES YOUR ERROR
define root view entity ZCIT_C_IDR_22EC301
  provider contract transactional_query
  as projection on ZCIT_I_IDR_22EC301
{
  key RequestID,
      EmployeeID,
      EmployeeName,
      RequestStatus,
      OfficeLocation,
      LastChangedAt
}
