FUNCTION zfm_attachment_copy.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     REFERENCE(IS_OBJECT_O) TYPE  BORIDENT
*"     REFERENCE(IS_OBJECT_N) TYPE  BORIDENT
*"  TABLES
*"      IT_BINREL STRUCTURE  GBINREL OPTIONAL
*"----------------------------------------------------------------------

  DATA: lt_srgbtbrel TYPE TABLE OF srgbtbrel.
  DATA lo_attachment TYPE REF TO cl_gos_document_service.
  DATA lp_attachment TYPE swo_typeid.
  DATA ls_attachment TYPE sibflporb.
  DATA lv_bc_object TYPE  sibflporb.

  DATA:
    lv_instid_a TYPE srgbtbrel-instid_a,
    lv_typeid_a TYPE srgbtbrel-typeid_a.


  DATA: l_folder_id          TYPE soodk,
        l_object_id          TYPE soodk,
        t_objcont            TYPE STANDARD TABLE OF soli,
        t_objhead            TYPE STANDARD TABLE OF soli,
        t_objpara            TYPE STANDARD TABLE OF selc,
        t_objparb            TYPE STANDARD TABLE OF soop1,
        wa_objcont           TYPE soli,
        ls_object_fl_display LIKE  sofm2,
        ls_object_hd_display LIKE  sood2,
        ls_object_rc_display LIKE  soos6.

  DATA:
    ls_obj_data TYPE sood1,
    lt_objhead  TYPE STANDARD TABLE OF soli.

  DATA: gt_file_table       TYPE filetable,   "Uploaded file information
        gt_content          TYPE soli_tab,    "Uploaded files content
        gs_fol_id           TYPE soodk,       "Folder ID
        gs_obj_id           TYPE soodk,       "Object ID
        parent_id           LIKE soodk,
        el_object_hd_change TYPE sood1,
        el_folder_id        LIKE soodk,
        hd_dat              LIKE sood1,
        document_id         LIKE soodk,
        object_id           LIKE soodk,
        folder_id           LIKE soodk,
        link_folder_id      LIKE soodk.
*    parent_id LIKE soodk.

*  is_object_n-objkey = '4500002180'.

  DATA:
    ls_new_parent    LIKE  soodk,
    ls_folder_id     LIKE  sofdk,
    ls_object_id     LIKE  soodk,
    ls_attach_id     LIKE  soodk,
    lv_forwarder     LIKE  soud-usrnam,
    lv_owner         LIKE  soud-usrnam,
    ls_new_object_id LIKE  soodk.
  DATA l_folmem_k TYPE sofmk.

  DATA:
    object_hd_change  LIKE  sood1,
    object_fl_display LIKE  sofm2,
    object_hd_display LIKE  sood2.

  DATA: ls_fol_id   TYPE soodk,
        ls_obj_id   TYPE soodk,
*        ls_obj_data   TYPE sood1,
        ls_folmem_k TYPE sofmk,
        ls_note     TYPE borident,
        ls_object   TYPE borident,
        lv_ep_note  TYPE borident-objkey.


* Create main BO object_a
  DATA:

* Create attachment BO object_b
    lv_instid_b TYPE srgbtbrel-instid_b,
    lv_typeid_b TYPE srgbtbrel-typeid_b.

  DATA: wa_srgbtbrel  TYPE srgbtbrel.
  DATA: it_srgbtbrel  TYPE TABLE OF srgbtbrel.
  DATA: binrel LIKE  gbinrel.

  IF is_object_o IS INITIAL.
    lv_instid_a = '4500002185'.
    lv_typeid_a = 'BUS2012'.
  ELSE.
    lv_instid_a = is_object_o-objkey.
    lv_typeid_a = is_object_o-objtype.
  ENDIF.
  DATA l_note TYPE borident.

  DATA: ls_objcont        TYPE soli.

  DATA: crep_id(30)    VALUE 'SOFFDB',
        doc_id(40),
        docid1         TYPE sdokobject,
        phio_object    LIKE sdokobject,
        context        LIKE sdokpropty OCCURS 0 WITH HEADER LINE,
        content_info   LIKE  scms_acinf OCCURS 1 WITH HEADER LINE,
        content_char   LIKE  sdokcntasc OCCURS 1 WITH HEADER LINE,
        content_bin    LIKE  sdokcntbin OCCURS 1 WITH HEADER LINE,
        ls_content_bin LIKE LINE OF content_bin.
  DATA : xobject_b TYPE borident.
  DATA : xobject_a TYPE borident.
  DATA : xfilenamepath TYPE string.
  DATA : xdoctitle TYPE string.
  DATA : it_objhead TYPE STANDARD TABLE OF soli WITH HEADER LINE.
  DATA : idoc_content TYPE soli_tab.
  DATA : idoc_content1 TYPE soli_tab.
  DATA : w_idoc_content TYPE soli.
  DATA l_tamarq TYPE i.

  CLEAR it_binrel.

  SELECT *
    FROM srgbtbrel INTO TABLE lt_srgbtbrel
    WHERE instid_a = lv_instid_a
      AND typeid_a = lv_typeid_a.

  IF sy-subrc = 0.

    LOOP AT lt_srgbtbrel ASSIGNING FIELD-SYMBOL(<fs_srgbtbrel>).

      CALL FUNCTION 'SO_FOLDER_ROOT_ID_GET'
        EXPORTING
          region    = 'B'
        IMPORTING
          folder_id = el_folder_id
        EXCEPTIONS
          OTHERS    = 0.

      l_folder_id-objtp = <fs_srgbtbrel>-instid_b(3).
      l_folder_id-objyr = <fs_srgbtbrel>-instid_b+3(2).
      l_folder_id-objno = <fs_srgbtbrel>-instid_b+5(12).

      l_object_id-objtp = <fs_srgbtbrel>-instid_b+17(3).
      l_object_id-objyr = <fs_srgbtbrel>-instid_b+20(2).
      l_object_id-objno = <fs_srgbtbrel>-instid_b+22(12).

      CALL FUNCTION 'SO_OBJECT_READ'
        EXPORTING
          folder_id                  = l_folder_id
          object_id                  = l_object_id
        IMPORTING
          object_fl_display          = ls_object_fl_display
          object_hd_display          = ls_object_hd_display
          object_rc_display          = ls_object_rc_display
        TABLES
          objcont                    = t_objcont
          objhead                    = t_objhead
          objpara                    = t_objpara
          objparb                    = t_objparb
        EXCEPTIONS
          active_user_not_exist      = 1
          communication_failure      = 2
          component_not_available    = 3
          folder_not_exist           = 4
          folder_no_authorization    = 5
          object_not_exist           = 6
          object_no_authorization    = 7
          operation_no_authorization = 8
          owner_not_exist            = 9
          parameter_error            = 10
          substitute_not_active      = 11
          substitute_not_defined     = 12
          system_failure             = 13
          x_error                    = 14
          OTHERS                     = 15.

      CLEAR: xobject_a, xobject_b.
      ls_folmem_k-foltp = ls_fol_id-objtp.
      ls_folmem_k-folyr = ls_fol_id-objyr.
      ls_folmem_k-folno = ls_fol_id-objno.

      ls_folmem_k-doctp = ls_obj_id-objtp.
      ls_folmem_k-docyr = ls_obj_id-objyr.
      ls_folmem_k-docno = ls_obj_id-objno.
      lv_ep_note = ls_folmem_k.
      ls_note-objkey = lv_ep_note.

*******************************************************
      ls_new_parent = el_folder_id.
      lv_owner = lv_forwarder = sy-uname.

      MOVE-CORRESPONDING ls_object_hd_display TO object_hd_change.

      object_hd_change-dldat  = sy-datum.
      object_hd_change-dltim  = sy-uzeit.

      CALL FUNCTION 'SO_OBJECT_INSERT'
        EXPORTING
          folder_id             = el_folder_id
          object_type           = 'EXT'
          object_hd_change      = object_hd_change
          owner                 = sy-uname
        IMPORTING
          object_fl_display     = object_fl_display
          object_hd_display     = object_hd_display
          object_id             = object_id
        TABLES
          objcont               = t_objcont
          objhead               = t_objhead
          objpara               = t_objpara
          objparb               = t_objparb
        EXCEPTIONS
          active_user_not_exist = 35
          folder_not_exist      = 6
          object_type_not_exist = 17
          owner_not_exist       = 22
          parameter_error       = 23
          OTHERS                = 1000.

* Create main BO object_a
      IF is_object_n-objkey IS NOT INITIAL.
        xobject_a-objkey = is_object_n-objkey.
      ELSE.
        xobject_a-objkey = '4500002179'.
      ENDIF.

      xobject_a-objtype = <fs_srgbtbrel>-typeid_a.

* Create attachment BO object_b
      CONCATENATE el_folder_id object_id INTO xobject_b-objkey.
      xobject_b-objtype = <fs_srgbtbrel>-typeid_b.

      CALL FUNCTION 'BINARY_RELATION_CREATE'
        EXPORTING
          obj_rolea    = xobject_a
          obj_roleb    = xobject_b
          relationtype = 'ATTA'
        IMPORTING
          binrel       = binrel
        EXCEPTIONS
          OTHERS       = 1.

      IF sy-subrc = 1.
        MESSAGE TEXT-e01 TYPE 'E'.
      ELSE.
        APPEND binrel TO it_binrel.
      ENDIF.

      COMMIT WORK.

    ENDLOOP.

  ENDIF.

ENDFUNCTION.