" ====================================================================
" PART 1: DEFINITIONS (Blueprints)
" ====================================================================

CLASS lhc_IDRequest DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PUBLIC SECTION.
    CLASS-DATA: mt_db_insert TYPE TABLE OF zcit_idr_22ec301,
                mt_db_update TYPE TABLE OF zcit_idr_22ec301,
                mt_db_delete TYPE TABLE OF zcit_idr_22ec301.

  PRIVATE SECTION.
    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR IDRequest RESULT result.

    METHODS create FOR MODIFY IMPORTING entities FOR CREATE IDRequest.
    METHODS update FOR MODIFY IMPORTING entities FOR UPDATE IDRequest.
    METHODS delete FOR MODIFY IMPORTING keys FOR DELETE IDRequest.
    METHODS read   FOR READ   IMPORTING keys FOR READ IDRequest RESULT result.
ENDCLASS.

CLASS lsc_idrequest DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS save REDEFINITION.
    METHODS finalize REDEFINITION.
    METHODS check_before_save REDEFINITION.
    METHODS cleanup REDEFINITION.
ENDCLASS.

" ====================================================================
" PART 2: IMPLEMENTATIONS (Logic)
" ====================================================================

CLASS lhc_IDRequest IMPLEMENTATION.

  METHOD get_instance_authorizations.
    " Grant permission for update and delete. (Removed %action-Edit)
    LOOP AT keys INTO DATA(ls_key).
      APPEND VALUE #( %tky         = ls_key-%tky
                      %update      = if_abap_behv=>auth-allowed
                      %delete      = if_abap_behv=>auth-allowed
                    ) TO result.
    ENDLOOP.
  ENDMETHOD.

  METHOD create.
    LOOP AT entities INTO DATA(ls_entity).
      TRY.
          DATA(lv_new_uuid) = cl_system_uuid=>create_uuid_x16_static( ).
        CATCH cx_uuid_error.
      ENDTRY.

      APPEND VALUE #( request_id      = lv_new_uuid
                      employee_id     = ls_entity-EmployeeID
                      employee_name   = ls_entity-EmployeeName
                      request_status  = 'O'
                      office_location = ls_entity-OfficeLocation ) TO mt_db_insert.

      APPEND VALUE #( %cid = ls_entity-%cid RequestID = lv_new_uuid ) TO mapped-idrequest.
    ENDLOOP.
  ENDMETHOD.

  METHOD update.
    LOOP AT entities INTO DATA(ls_entity).
      SELECT SINGLE * FROM zcit_idr_22ec301 WHERE request_id = @ls_entity-RequestID INTO @DATA(ls_db).
      IF sy-subrc = 0.
        IF ls_entity-%control-EmployeeID = if_abap_behv=>mk-on. ls_db-employee_id = ls_entity-EmployeeID. ENDIF.
        IF ls_entity-%control-EmployeeName = if_abap_behv=>mk-on. ls_db-employee_name = ls_entity-EmployeeName. ENDIF.
        IF ls_entity-%control-OfficeLocation = if_abap_behv=>mk-on. ls_db-office_location = ls_entity-OfficeLocation. ENDIF.
        IF ls_entity-%control-RequestStatus = if_abap_behv=>mk-on. ls_db-request_status = ls_entity-RequestStatus. ENDIF.

        GET TIME STAMP FIELD ls_db-last_changed_at.
        APPEND ls_db TO mt_db_update.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD delete.
    LOOP AT keys INTO DATA(ls_key).
      APPEND VALUE #( request_id = ls_key-RequestID ) TO mt_db_delete.
    ENDLOOP.
  ENDMETHOD.

  METHOD read.
    SELECT * FROM zcit_idr_22ec301 FOR ALL ENTRIES IN @keys
      WHERE request_id = @keys-RequestID INTO TABLE @DATA(lt_db).
    LOOP AT lt_db INTO DATA(ls_db).
      APPEND VALUE #( RequestID = ls_db-request_id EmployeeID = ls_db-employee_id
                      EmployeeName = ls_db-employee_name RequestStatus = ls_db-request_status
                      OfficeLocation = ls_db-office_location
                      LastChangedAt = ls_db-last_changed_at ) TO result.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_idrequest IMPLEMENTATION.

  METHOD save.
    IF lhc_IDRequest=>mt_db_insert IS NOT INITIAL.
      INSERT zcit_idr_22ec301 FROM TABLE @lhc_IDRequest=>mt_db_insert.
    ENDIF.

    IF lhc_IDRequest=>mt_db_update IS NOT INITIAL.
      UPDATE zcit_idr_22ec301 FROM TABLE @lhc_IDRequest=>mt_db_update.
    ENDIF.

    IF lhc_IDRequest=>mt_db_delete IS NOT INITIAL.
      LOOP AT lhc_IDRequest=>mt_db_delete INTO DATA(ls_delete).
        DELETE FROM zcit_idr_22ec301 WHERE request_id = @ls_delete-request_id.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD cleanup.
    CLEAR: lhc_IDRequest=>mt_db_insert,
           lhc_IDRequest=>mt_db_update,
           lhc_IDRequest=>mt_db_delete.
  ENDMETHOD.

ENDCLASS.
