*----------------------------------------------------------------------*
***INCLUDE LZSDT0046F01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form Z_FORM_1
*&---------------------------------------------------------------------*
FORM z_form_01 . "Antes de gravar os dados no banco de dados

  DATA:
    lv_CHNGIND  TYPE cdpos-chngind,
    lv_OBJECTID TYPE cdhdr-objectid,
    lv_TCODE    TYPE cdhdr-tcode,
    lv_UTIME    TYPE cdhdr-utime,
    lv_UDATE    TYPE cdhdr-udate,
    lv_USERNAME TYPE cdhdr-username,
    ls_new      TYPE zsdt0046,
    ls_old      TYPE zsdt0046,
    lt_cdtxt    TYPE TABLE OF cdtxt.

  APPEND LINES OF total TO gt_ZSDT0046_D .

  SELECT *
    FROM zsdt0046
    INTO TABLE Gt_zsdt0046_o
    ORDER BY id.

  LOOP AT gt_ZSDT0046_a ASSIGNING FIELD-SYMBOL(<fs_ZSDT0046_a>).
    CLEAR: ls_new, ls_old.

    IF <fs_ZSDT0046_a>-action IS INITIAL.
      <fs_ZSDT0046_a>-action = 'D'.
    ELSEIF <fs_ZSDT0046_a>-action = 'N'.
      <fs_ZSDT0046_a>-action = 'I'.
    ENDIF.

    lv_CHNGIND  = <fs_ZSDT0046_a>-action.
    lv_OBJECTID = <fs_ZSDT0046_a>-id.
    lv_TCODE    = sy-tcode.
    lv_UTIME    = sy-uzeit.
    lv_UDATE    = sy-datum.
    lv_USERNAME = sy-uname.

    IF <fs_ZSDT0046_a>-action = 'D'.
      ls_old = <fs_ZSDT0046_a>.
    ELSE.

      MOVE-CORRESPONDING <fs_ZSDT0046_a> TO ls_new.
      READ TABLE gt_ZSDT0046_o ASSIGNING FIELD-SYMBOL(<fs_ZSDT0046_o>)
      WITH KEY id = <fs_ZSDT0046_a>-id BINARY SEARCH.
      IF sy-subrc = 0.
        ls_old = <fs_ZSDT0046_o>.
      ENDIF.

    ENDIF.

    CLEAR lt_cdtxt.
    APPEND INITIAL LINE TO lt_cdtxt ASSIGNING FIELD-SYMBOL(<FS_cdtxt>).
    <FS_cdtxt>-teilobjid = 'ZSDT0046'.
*    <FS_cdtxt>-teilobjid = lv_OBJECTID.
    <FS_cdtxt>-textart = <fs_ZSDT0046_a>-action.
    <FS_cdtxt>-textspr = sy-langu.
    <FS_cdtxt>-updkz = <fs_ZSDT0046_a>-action.

    CALL FUNCTION 'ZSDT0046_WRITE_DOCUMENT'
      EXPORTING
        objectid        = lv_OBJECTID
        tcode           = lv_TCODE
        utime           = lv_UTIME
        udate           = lv_UDATE
        username        = lv_USERNAME
        n_zsdt0046      = ls_new
        o_zsdt0046      = ls_old
        upd_zsdt0046    = lv_CHNGIND
      TABLES
        icdtxt_zsdt0046 = lt_cdtxt.

    IF sy-subrc = 0.
      COMMIT WORK.
    ENDIF.

  ENDLOOP.
  CLEAR: gt_ZSDT0046_a.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form Z_FORM_5
*&---------------------------------------------------------------------*
FORM z_form_05 .  "Criando uma nova entrada

  IF zsdt0046-email IS INITIAL.
    MESSAGE e004(zacm02) DISPLAY LIKE 'E'.
    STOP.
  ELSE.

    DATA lv_email TYPE zsdt0046-email.
    SELECT SINGLE email
      FROM zsdt0046 INTO lv_email
      WHERE email = zsdt0046-email.

    IF sy-subrc = 0.
      MESSAGE e003(zacm02) WITH zsdt0046-email DISPLAY LIKE 'E'.
      STOP.
    ELSE.

      DATA: l_num TYPE cms_dte_seqno.
      CALL FUNCTION 'NUMBER_GET_NEXT'
        EXPORTING
          nr_range_nr             = '01'
          object                  = 'ZAUTO'
        IMPORTING
          number                  = l_num
        EXCEPTIONS
          interval_not_found      = 1
          number_range_not_intern = 2
          object_not_found        = 3
          quantity_is_0           = 4
          quantity_is_not_1       = 5
          interval_overflow       = 6
          buffer_overflow         = 7
          OTHERS                  = 8.

      zsdt0046-id = l_num.
      TRANSLATE zsdt0046-email TO LOWER CASE.

    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form Z_FORM_18
*&---------------------------------------------------------------------*
FORM z_form_18 . "Após verificar se os dados foram alterados

  IF sy-ucomm = 'SAVE'.

    APPEND LINES OF total TO gt_ZSDT0046_a .
    DELETE gt_ZSDT0046_a WHERE action  IS INITIAL.
    DELETE gt_ZSDT0046_a WHERE id      IS INITIAL
                            OR email   IS INITIAL.

  ENDIF.

ENDFORM.