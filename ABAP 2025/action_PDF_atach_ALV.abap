*----------------------------------------------------------------------*
***INCLUDE LZSDV0031I01.
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  CHECK_ZSDV0031_PAI_FIELDS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_zsdv0031_pai_fields INPUT.

  TABLES: srgbtbrel.

  DATA:
    wa_object     TYPE sibflporb,
    fs_object     TYPE sibflporb,
    lt_object     TYPE TABLE OF sibflporb,
    lv_instid     TYPE sibflporb-instid,
    lv_instid_aux TYPE sibflporb-instid,
    lv_count      TYPE c.


  DATA:
    lt_fieldcat         TYPE lvc_t_fcat,
    ls_layout           TYPE lvc_s_layo,
    lv_grid_title       TYPE  lvc_title,
    l_screen_end_line   TYPE i,
    l_screen_end_column TYPE i.

  DATA: lt_wbhk     TYPE TABLE OF wbhk,
        ls_ZSDT0047 TYPE zsdt0047.

  IF vim_marked IS NOT INITIAL AND sy-ucomm = 'PDF'.

    CONCATENATE  zsdt0030-partner zsdv0031-check_type '%' INTO lv_instid_aux.

    SELECT SINGLE MAX( instid_a )
    INTO lv_instid
    FROM srgbtbrel
    WHERE instid_a LIKE lv_instid_aux.


    IF lv_instid IS NOT INITIAL.
*        lv_instid = lv_instid + 1.
    ELSE.
      CONCATENATE  zsdt0030-partner zsdv0031-check_type  '000001' INTO lv_instid.
    ENDIF.

    wa_object-instid = lv_instid.
    wa_object-typeid = sy-tcode.
    wa_object-catid = 'BO'.

*****************************
*    CLEAR lt_object.
*
*    SELECT *
*    FROM wbhk
*    INTO TABLE lt_wbhk
*    WHERE kunnr = zsdt0030-partner.
*
*    IF sy-subrc = 0.
*
*      LOOP AT lt_wbhk ASSIGNING FIELD-SYMBOL(<fs_wbhk>).
*        CLEAR  fs_object.
*        fs_object-instid = <fs_wbhk>-tkonn.
*        fs_object-typeid = 'BUS2124'.
*        fs_object-catid = 'BO'.
*        APPEND fs_object TO lt_object.
*      ENDLOOP.
*    ENDIF.

*****************************

    CALL FUNCTION 'GOS_ATTACHMENT_LIST_POPUP'
      EXPORTING
        is_object      = wa_object
        ip_check_arl   = ''
        ip_check_bds   = ''
        ip_notes       = ''
        ip_attachments = 'X'
        ip_urls        = ''
        ip_mode        = 'C'
      TABLES
        it_objects     = lt_object.

    IF sy-subrc = 0.

      CLEAR lv_exists.

      SELECT SINGLE instid_a
      INTO lv_exists
      FROM srgbtbrel
      WHERE instid_a = lv_instid.

      IF lv_exists IS NOT INITIAL.
        zsdv0031-check_anexo = '@IT@'. " Ícone PDF
      ELSE.
        zsdv0031-check_anexo = '@04@'. " Ícone ADD
      ENDIF.
    ENDIF.

********************************

  ELSEIF vim_marked IS NOT INITIAL AND sy-ucomm = 'OBS'.

    CLEAR: lt_ZSDT0047, lt_fieldcat, ls_layout.

    SELECT *
      FROM zsdt0047
      INTO TABLE lt_ZSDT0047
      WHERE  check_type = zsdv0031-check_type
      AND    partner    = zsdv0031-partner.

    IF sy-subrc = 0.
      SORT lt_ZSDT0047 BY id check_type partner.
    ENDIF.

    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
        i_structure_name = 'ZSDT0047'
*       i_client_never_display = 'X'
      CHANGING
        ct_fieldcat      = lt_fieldcat.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

*    ls_layout-zebra = ls_layout-edit = ls_layout-edit_mode = abap_true .
    ls_layout-zebra = ls_layout-edit_mode = abap_true .


    LOOP AT lt_fieldcat ASSIGNING FIELD-SYMBOL(<fs_fieldcat>).

      IF <fs_fieldcat>-fieldname = 'DATUM'
      OR <fs_fieldcat>-fieldname = 'UZEIT'
      OR <fs_fieldcat>-fieldname = 'CHECK_TYPE'.
        <fs_fieldcat>-edit = abap_false.
      ELSEIF <fs_fieldcat>-fieldname = 'OBS'.
        <fs_fieldcat>-edit = abap_true.
        CLEAR <fs_fieldcat>-no_out.
      ELSEIF <fs_fieldcat>-fieldname = 'ATIVO'.
        <fs_fieldcat>-outputlen = '5'.
        <fs_fieldcat>-edit = abap_true.
        <fs_fieldcat>-checkbox = 'X'.
        CLEAR <fs_fieldcat>-no_out.
      ELSE.
        <fs_fieldcat>-no_out = 'X'.
      ENDIF.

    ENDLOOP.

    l_screen_end_column = '155'.
    DESCRIBE TABLE lt_ZSDT0047 LINES l_screen_end_line.

    l_screen_end_line = l_screen_end_line + 25.
*    lv_grid_title       = 'Observações'.

    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
      EXPORTING
        is_layout_lvc            = ls_layout
        i_callback_program       = sy-repid
*        i_callback_top_of_page   = 'TOP-OF-PAGE'
        i_callback_pf_status_set = 'PF_STATUS'
        i_callback_user_command  = 'F_USER_COMMAND_GRP_SCREEN'
        i_structure_name         = 'ZSDT0047'
        it_fieldcat_lvc          = lt_fieldcat
        i_grid_title             = lv_grid_title
        i_screen_start_column    = 30
        i_screen_start_line      = 15
        i_screen_end_column      = l_screen_end_column
        i_screen_end_line        = l_screen_end_line
        i_default                = 'X'
        i_save                   = 'A'
      TABLES
        t_outtab                 = lt_ZSDT0047.

    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.


  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CHECK_ZSDV0031_PBO_FIELDS OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE check_zsdv0031_pbo_fields OUTPUT.

  DATA lv_index TYPE string.

  IF zsdv0031-key_type <> 'ZCAR'.

    LOOP AT SCREEN.
      IF screen-group1 = 'MD1'.
        screen-active = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.

  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module UPDATE_ANEXO_ICON OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE update_anexo_icon OUTPUT.

  DATA: lt_srgbtbrel TYPE TABLE OF srgbtbrel,
        lt_GBINREL   TYPE TABLE OF gbinrel.

  DATA: lt_wbhk_n   TYPE TABLE OF wbhk,
        lv_instid_n TYPE sibflporb-instid.

  DATA: ls_object_o TYPE  borident,
        ls_object_n TYPE  borident.

  CLEAR       lv_instid.
  CONCATENATE zsdv0031-partner zsdv0031-check_type '%' INTO lv_instid.

  CLEAR lv_exists.

  SELECT *
  INTO TABLE lt_srgbtbrel
  FROM srgbtbrel
  WHERE instid_a LIKE lv_instid.

  IF lt_srgbtbrel IS NOT INITIAL.
    zsdv0031-check_anexo = '@IT@'. " Ícone indicando que há anexo

***************************************
*    SELECT *
*    FROM wbhk
*    INTO TABLE lt_wbhk_n
*    WHERE kunnr = zsdv0031-partner.
*
*    IF sy-subrc = 0.
*
*      LOOP AT lt_srgbtbrel ASSIGNING FIELD-SYMBOL(<fs_srgbtbrel>).
*
*        LOOP AT lt_wbhk_n ASSIGNING FIELD-SYMBOL(<fs_wbhk_n>).
*          CLEAR:  ls_object_o, ls_object_n.
*
*          ls_object_o-objkey  = <fs_srgbtbrel>-instid_a.
*          ls_object_o-objtype = <fs_srgbtbrel>-typeid_a.
*
*          ls_object_n-objkey  = <fs_wbhk_n>-tkonn.
*          ls_object_n-objtype = 'BUS2124'.
*
*          CALL FUNCTION 'ZFM_ATTACHMENT_COPY'
*            EXPORTING
*              is_object_o = ls_object_o
*              is_object_n = ls_object_n.
**            TABLES
**              it_binrel   = lt_GBINREL.
*
*
*        ENDLOOP.
*      ENDLOOP.
*
*
*
*
*    ENDIF.
***************************************
  ELSE.
    zsdv0031-check_anexo = '@CZ@'. " Ícone indicando que não há anexo
  ENDIF.

  SELECT *
    INTO TABLE @DATA(Lt_ZSDT0047_tp)
    FROM zsdt0047
    WHERE check_type = @zsdv0031-check_type
      AND partner    = @zsdt0030-partner.
  IF sy-subrc = 0.
    zsdv0031-check_OBSer = '@0O@'. " Ícone indicando que há observação
  ELSE.
    zsdv0031-check_OBSer = '@CZ@'. " Ícone indicando que não observação
  ENDIF.

ENDMODULE.