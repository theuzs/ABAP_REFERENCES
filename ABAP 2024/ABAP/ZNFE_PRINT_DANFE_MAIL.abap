*&---------------------------------------------------------------------*
*& Report  ZNFE_PRINT_DANFE                                            *
*&---------------------------------------------------------------------*
*&  Print of DANFE by SmartForm                                        *
*&  Should be used together with Message Control (NAST)                *
*&  Basically, a copy of J_1BNFPR                                      *
*&---------------------------------------------------------------------*
REPORT  znfe_print_danfe_mail MESSAGE-ID 8b.
*======================================================================*
*  TABLES, INCLUDES, STRUCTURES, DATAS, ...                            *
*======================================================================*
"
*----------------------------------------------------------------------*
*  TABLES                                                              *
*----------------------------------------------------------------------*
* tables ---------------------------------------------------------------
TABLES: j_1bnfdoc,
        vbrk,                          " billing document header
        bkpf,
        kna1,
        lfa1,                          " financial document header
        j_1bnfe_active,
        j_1b_nfe_access_key.
*----------------------------------------------------------------------*
*  INCLUDES                                                            *
*----------------------------------------------------------------------*
* INCLUDE for General Table Descriptions for Print Programs ------------
INCLUDE rvadtabl.
INCLUDE znfe_j_1bnfpr_printinc_mail.
*INCLUDE znfe_j_1bnfpr_printinc.

*----------------------------------------------------------------------*
*  STRUCTURES                                                          *
*----------------------------------------------------------------------*
* Nota Fiscal header structure -----------------------------------------
DATA: BEGIN OF wk_header.
        INCLUDE STRUCTURE j_1bnfdoc.
DATA: END OF wk_header.

* Nota Fiscal messages -----------------------------------------                                    "+ TP - Fusion - Upgrade S4 2023 - 29.02.2024
DATA: gr_texts TYPE REF TO if_logbr_nf_texts_data,                                                  "+ TP - Fusion - Upgrade S4 2023 - 29.02.2024
      gt_texts TYPE logbr_nf_text_tt,                                                               "+ TP - Fusion - Upgrade S4 2023 - 29.02.2024
      gt_split TYPE STANDARD TABLE OF char72 WITH EMPTY KEY.                                        "+ TP - Fusion - Upgrade S4 2023 - 29.02.2024

* Nota Fiscal header structure - add. segment --------------------------
DATA: BEGIN OF wk_header_add.
        INCLUDE STRUCTURE j_1bindoc.
DATA: END OF wk_header_add.

* Nota Fiscal partner structure ----------------------------------------
DATA: BEGIN OF wk_partner OCCURS 0.
        INCLUDE STRUCTURE j_1bnfnad.
DATA: END OF wk_partner.

* Nota Fiscal item structure -------------------------------------------
DATA: BEGIN OF wk_item OCCURS 0.
        INCLUDE STRUCTURE j_1bnflin.
DATA: END OF wk_item.

* Nota Fiscal item structure - add. segment ----------------------------
DATA: BEGIN OF wk_item_add OCCURS 0.
        INCLUDE STRUCTURE j_1binlin.
DATA: END OF wk_item_add.

* Nota Fiscal item tax structure ---------------------------------------
DATA: BEGIN OF wk_item_tax OCCURS 0.
        INCLUDE STRUCTURE j_1bnfstx.
DATA: END OF wk_item_tax.

* Nota Fiscal header message structure ---------------------------------
DATA: BEGIN OF wk_header_msg OCCURS 0.
        INCLUDE STRUCTURE j_1bnfftx.
DATA: END OF wk_header_msg.

* Nota Fiscal reference to header message structure -------------------
DATA: BEGIN OF wk_refer_msg OCCURS 0.
        INCLUDE STRUCTURE j_1bnfref.
DATA: END OF wk_refer_msg.

* Carrega a Work area para Contigencia ----------------------
DATA: BEGIN OF wk_danfe OCCURS 0.
        INCLUDE STRUCTURE j_1bnfe_active.
DATA: END OF wk_danfe.


* auxiliar structure for vbrk key (used to update FI) ------------------
DATA: BEGIN OF key_vbrk,
        vbeln LIKE vbrk-vbeln,
      END OF key_vbrk.

DATA: my_destination LIKE j_1binnad,
      my_issuer      LIKE j_1binnad,
      my_carrier     LIKE j_1binnad,
      my_items       LIKE j_1bprnfli OCCURS 0 WITH HEADER LINE.

DATA: fm_name        TYPE rs38l_fnam.

DATA: BEGIN OF inter_total_table OCCURS 0,
        matorg    LIKE j_1bprnfli-matorg,
        taxsit    LIKE j_1bprnfli-taxsit,
        icmsrate  LIKE j_1bprnfli-icmsrate,
        condensed TYPE c,
        nfnett    LIKE j_1bprnfli-nfnett,
      END OF inter_total_table.

*---data for SmartForms---*
DATA: output_options TYPE ssfcompop. " transfer printer to SM
DATA: control_parameters TYPE ssfctrlop.

* Tabela para dados da fatura (SMARTFORMS).
DATA: w_danfe  TYPE znfedanfe_header.

* Informações de contigência
DATA: v_contingkey(36) TYPE c,
      v_nftot_char(14) TYPE c,
      v_cpf(11)        TYPE c,
      v_icmproprio     TYPE c,
      v_icmsub         TYPE c,
      v_nfe            TYPE string,
      v_nfe1           TYPE string.

DATA: e_znfecontigekey TYPE znfecontigekey.

DATA: gt_fatura TYPE TABLE OF zstnfe002.

DATA: BEGIN OF wa_nfe_alv,
*        status      TYPE icon-id,                        "ACC >>>
*        errlog      TYPE icon-id.
        status(50)     TYPE c,
        errlog(50)     TYPE c,                                "ACC <<<
        event(50)      TYPE c,                              "1575364
        exten_vals(50) TYPE c,                              "2934502
        cloud_log      TYPE nfe_icon,
        email_log      TYPE nfe_icon.
        INCLUDE STRUCTURE j_1bnfe_active.
DATA: END OF wa_nfe_alv.

DATA: it_nfe_alv LIKE TABLE OF wa_nfe_alv
         WITH KEY docnum.

* ALV display of NF-e history

DATA: BEGIN OF wa_nfe_alv2,
        docstat TYPE j_1bstscodet-text,
        scsstat TYPE j_1bstscodet-text,
        codet   TYPE j_1bstscodet-text.
        INCLUDE STRUCTURE j_1bnfe_history.
DATA: END OF wa_nfe_alv2.

DATA: it_nfe_alv2 LIKE TABLE OF wa_nfe_alv2
         WITH KEY docnum docsta.

* ALV display of NF-e Events
DATA: BEGIN OF wa_nfe_alv3,                         "1575364  CCE
        docstat            TYPE j_1bstscodet-text,          "1575364
        extevt             TYPE j_1bnfe_extevt-description, "1575364
        evegrpt            TYPE j_1bnfe_evegrpt-description, "1575364
        codet              TYPE j_1bstscodet-text,          "1575364
        crea_date          TYPE j_1bnfe_eve_creadat,        "1575364
        crea_time          TYPE j_1bnfe_eve_creatim,        "1575364
        auth_date          TYPE j_1bnfe_eve_authdat,        "1575364
        auth_time          TYPE j_1bnfe_eve_authtim,        "1575364
        event_icon         TYPE char50,                     "1575364
        exten_vals_evt(50) TYPE c.                          "2934502
        INCLUDE STRUCTURE j_1bnfe_event.            "1575364
DATA: END OF wa_nfe_alv3.                                   "1575364

DATA: it_nfe_alv3 LIKE TABLE OF wa_nfe_alv3                 "1575364
WITH KEY docnum.
* Busca informações do cliente (Mestre de clientes) ------------------
*DATA: BEGIN OF t_kna1,
*        regio LIKE kna1-regio,
*        stcd1 LIKE kna1-stcd1,
*        stcd2 LIKE kna1-stcd2,
*        txjdc LIKE kna1-txjdc,
*      END OF t_kna1.
*
** Busca informações do Fornecedor (Mestre de fornecedores ) ------------------
*DATA: BEGIN OF t_lfa1,
*        regio LIKE lfa1-regio,
*        stcd1 LIKE lfa1-stcd1,
*        stcd2 LIKE lfa1-stcd2,
*        txjdc LIKE lfa1-txjdc,
*      END OF t_lfa1.

*----------------------------------------------------------------------*
*  DATA AND CONSTANTS                                                 *
*----------------------------------------------------------------------*
DATA: wk_docnum    TYPE j_1bnfdoc-docnum,
      retcode      TYPE sy-subrc,
      xscreen,
      wk_xblnr     TYPE bkpf-xblnr,
      subrc_upd_bi TYPE sy-subrc.
DATA: bi_subrc TYPE sy-subrc,
      fi_subrc TYPE sy-subrc.

CLASS cl_exithandler DEFINITION LOAD.

DATA: gs_nfeactive TYPE        j_1bnfe_active,
      lr_badi      TYPE REF TO zif_ex_nfe.

DATA: gs_j_1bnfdoc TYPE j_1bnfdoc.
DATA: gt_j_1bnfdoc TYPE TABLE OF j_1bnfdoc.

DATA: it_objpack        TYPE TABLE OF sopcklsti1,
      it_objbin         TYPE TABLE OF solisti1,
      it_objpack_backup TYPE TABLE OF sopcklsti1,
      it_objbin_backup  TYPE TABLE OF solisti1,
      pt_retorno        TYPE TABLE OF bapireturn1,
      i_docnum          TYPE j_1bdocnum, " Número do documento (entrado como parâmetro)
      v_docnum          TYPE j_1bdocnum,
      v_lines           TYPE i,
      v_count_xml       TYPE i.

**********************************************************************
* Tela de seleção
**********************************************************************
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.

  SELECT-OPTIONS:
    s_docnum  FOR gs_j_1bnfdoc-docnum OBLIGATORY,
    s_nftype  FOR gs_j_1bnfdoc-nftype,
    s_doctyp  FOR gs_j_1bnfdoc-doctyp,
    s_direct  FOR gs_j_1bnfdoc-direct,
    s_docdat  FOR gs_j_1bnfdoc-docdat,
    s_pstdat  FOR gs_j_1bnfdoc-pstdat.

SELECTION-SCREEN END OF BLOCK b1.

**********************************************************************
*Início Codificação
**********************************************************************
START-OF-SELECTION.

  PERFORM entry USING 999 ''.

*======================================================================*
*  PROGRAM                                                             *
*======================================================================*

*&---------------------------------------------------------------------*
*&       FORM ENTRY  (MAIN FORM)                                       *
*&---------------------------------------------------------------------*
*       Form for Message Control                                       *
*----------------------------------------------------------------------*
FORM entry USING return_code us_screen.

  CLEAR: retcode.
  xscreen = us_screen.

  DATA: v_sform TYPE tdsfname.

  SELECT SINGLE sform
         INTO v_sform
         FROM tnapr
         WHERE kschl EQ 'NF01'
           AND kappl EQ 'NF'
           AND nacha EQ '1'.

  IF tnapr IS NOT INITIAL.
    IF NOT v_sform IS INITIAL.
      tnapr-sform = v_sform.
      CLEAR tnapr-funcname.
      CLEAR tnapr-fonam.
    ENDIF.
  ELSEIF tnapr IS INITIAL.

    SELECT SINGLE *
           INTO tnapr
           FROM tnapr
           WHERE kschl EQ 'NF55'
             AND kappl EQ 'NF'
             AND nacha EQ '1'.

    IF tnapr-sform IS NOT INITIAL.
      v_sform = tnapr-sform.
    ELSE.
      tnapr-sform = v_sform = 'Z_NFDANFE_PORTRAIT_SAP'.
    ENDIF.
  ELSE.
    tnapr-sform = v_sform = 'Z_NFDANFE_PORTRAIT_SAP'.
  ENDIF.

  IF lr_badi IS INITIAL.

    CALL METHOD cl_exithandler=>get_instance
      EXPORTING
        exit_name                     = 'ZNFE'
      CHANGING
        instance                      = lr_badi
      EXCEPTIONS
        no_reference                  = 1
        no_interface_reference        = 2
        no_exit_interface             = 3
        class_not_implement_interface = 4
        single_exit_multiply_active   = 5
        cast_error                    = 6
        exit_not_existing             = 7
        data_incons_in_exit_managem   = 8
        OTHERS                        = 9.

    IF sy-subrc <> 0.                                       "#EC NEEDED
    ENDIF.

  ENDIF.

  PERFORM smart_sub_printing.

* main -----------------------------------------------------------------

** check retcode (return code) ------------------------------------------
*  IF retcode NE 0.
*    return_code = 1.
*  ELSE.
*    return_code = 0.
*  ENDIF.

ENDFORM.                               " ENTRY

*&---------------------------------------------------------------------*
*&      Form  NOTA_FISCAL_READ
*&---------------------------------------------------------------------*
*       Read the Nota Fiscal based in the key giving by Message        *
*       Control.                                                       *
*----------------------------------------------------------------------*
FORM nota_fiscal_read USING p_docnum.

*  MOVE nast-objky TO wk_docnum.
  MOVE p_docnum TO wk_docnum.

  CALL FUNCTION 'J_1B_NF_DOCUMENT_READ'
    EXPORTING
      doc_number         = wk_docnum
    IMPORTING
      doc_header         = wk_header
      doc_texts          = gr_texts                                                                 "+ TP - Fusion - Upgrade S4 2023 - 29.02.2024
    TABLES
      doc_partner        = wk_partner
      doc_item           = wk_item
      doc_item_tax       = wk_item_tax
      doc_header_msg     = wk_header_msg
      doc_refer_msg      = wk_refer_msg
    EXCEPTIONS
      document_not_found = 1
      docum_lock         = 2
      OTHERS             = 3.

* check the sy-subrc ---------------------------------------------------
  PERFORM check_error.


  CALL FUNCTION 'J_1B_NF_VALUE_DETERMINATION'
    EXPORTING
      nf_header   = wk_header
    IMPORTING
      ext_header  = wk_header_add
    TABLES
      nf_item     = wk_item
      nf_item_tax = wk_item_tax
      ext_item    = wk_item_add.

*** Projeto NT002/003 - Início
  DATA: li_tabix TYPE sy-tabix.

  DATA: ls_item_add LIKE LINE OF wk_item_add,
        ls_item_tax LIKE LINE OF wk_item_tax.

  IF wk_header-ind_iedest = '9'.  " Não Contribuinte
    READ TABLE wk_item_tax WITH KEY taxtyp = 'ICAP'.
    IF sy-subrc IS INITIAL.
      LOOP AT wk_item_add INTO ls_item_add.
        li_tabix = sy-tabix.
        READ TABLE wk_item_tax INTO ls_item_tax WITH KEY itmnum = ls_item_add-itmnum taxtyp = 'ICM3'.
        CHECK sy-subrc IS INITIAL.
        ls_item_add-icmsrate = ls_item_tax-rate.
        ls_item_add-icmsval  = ls_item_tax-taxval.
        MODIFY wk_item_add INDEX li_tabix FROM ls_item_add.
      ENDLOOP.
    ENDIF.
  ENDIF.
*** Projeto NT002/003 - Fim

ENDFORM.                               " NOTA_FISCAL_READ
*&---------------------------------------------------------------------*
*&      Form  NOTA_FISCAL_NUMBER
*&---------------------------------------------------------------------*
*       Get the next Nota Fiscal number                                *
*----------------------------------------------------------------------*
FORM nota_fiscal_number.

  CALL FUNCTION 'J_1B_NF_NUMBER_GET_NEXT'
    EXPORTING
      bukrs                         = wk_header-bukrs
      branch                        = wk_header-branch
      form                          = wk_header-form
      headerdata                    = wk_header
    IMPORTING
      nf_number                     = wk_header-nfnum
    EXCEPTIONS
      print_number_not_found        = 1
      interval_not_found            = 2
      number_range_not_internal     = 3
      object_not_found              = 4
      other_problems_with_numbering = 5
      OTHERS                        = 6.

  PERFORM check_error.

ENDFORM.                               " NOTA_FISCAL_NUMBER

*&---------------------------------------------------------------------*
*&      Form  NOTA_FISCAL_UPDATE
*&---------------------------------------------------------------------*
*       Update NF date and number                                      *
*----------------------------------------------------------------------*
FORM nota_fiscal_update.

  wk_header-printd = 'X'.

  UPDATE j_1bnfdoc SET printd = wk_header-printd
                       follow = wk_header-follow
                 WHERE docnum = wk_header-docnum.

  IF sy-subrc <> 0.
    retcode = sy-subrc.
    syst-msgid = '8B'.
    syst-msgno = '107'.
    syst-msgty = 'E'.
    syst-msgv1 = wk_header-docnum.
    PERFORM protocol_update.
  ENDIF.

ENDFORM.                               " NOTA_FISCAL_UPDATE
*&---------------------------------------------------------------------*
*&      Form  CHECK_ERROR
*&---------------------------------------------------------------------*
*       Check return code                                              *
*----------------------------------------------------------------------*
FORM check_error.

  IF sy-subrc <> 0.
    retcode = sy-subrc.
    PERFORM protocol_update.
  ENDIF.

ENDFORM.                               " CHECK_ERROR
*&---------------------------------------------------------------------*
*&      Form  PROTOCOL_UPDATE
*&---------------------------------------------------------------------*
*       The messages are collected for the processing protocol.        *
*----------------------------------------------------------------------*
FORM protocol_update.

  CHECK xscreen = space.
  CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
    EXPORTING
      msg_arbgb = syst-msgid
      msg_nr    = syst-msgno
      msg_ty    = syst-msgty
      msg_v1    = syst-msgv1
      msg_v2    = syst-msgv2
      msg_v3    = syst-msgv3
      msg_v4    = syst-msgv4
    EXCEPTIONS
      OTHERS    = 1.

ENDFORM.                               " PROTOCOL_UPDATE
*&---------------------------------------------------------------------*
*&      Form  FINANCIAL_DOC_UPDATE
*&---------------------------------------------------------------------*
*       Update the sales document and Financial document with the      *
*       Nota Fiscal number and the Nota Fiscal with the financial      *
*       document                                                       *
*----------------------------------------------------------------------*
FORM financial_doc_update.

  SORT wk_item.
  READ TABLE wk_item INDEX 1.

  CALL FUNCTION 'J_1B_NF_NUMBER_CONDENSE'
    EXPORTING
      nf_number  = wk_header-nfnum
      series     = wk_header-series
      subseries  = wk_header-subser
      nf_number9 = wk_header-nfenum
    IMPORTING
      ref_number = wk_xblnr
    EXCEPTIONS
      OTHERS     = 1.

* get the type of the document and update the documents ----------------
  CASE wk_item-reftyp.

    WHEN 'BI'.
      MOVE wk_item-refkey TO key_vbrk.
      PERFORM read_bi_document.
      CLEAR bkpf.
      IF NOT vbrk IS INITIAL.          " if find VBRK (Billing document)
        PERFORM get_fi_number.
      ENDIF.
      IF bkpf-belnr IS INITIAL.        " there is not FI document
        IF NOT vbrk IS INITIAL.        " if find VBRK (Billing document)
          PERFORM update_bi_document.
        ENDIF.
      ELSE.                            " there is FI document
        PERFORM update_bi_document.
        IF  subrc_upd_bi IS INITIAL.   " update in billing ok.
          PERFORM update_fi_nf_document
                    USING bkpf-bukrs bkpf-belnr bkpf-gjahr.
          PERFORM update_bsid_nf_document
                  USING bkpf-bukrs bkpf-belnr bkpf-gjahr.
        ENDIF.
      ENDIF.

    WHEN OTHERS.  " for MD or <space> that means writer.
      wk_header-follow = 'X'.

  ENDCASE.

ENDFORM.                               " FINANCIAL_DOC_UPDATE

*&---------------------------------------------------------------------*
*&      Form  READ_BI_DOCUMENT
*&---------------------------------------------------------------------*
*       This form read the billing document                            *
*----------------------------------------------------------------------*
FORM read_bi_document.

  SELECT SINGLE * FROM  vbrk
         WHERE  vbeln       = key_vbrk-vbeln.

  IF sy-subrc <> 0.
    CLEAR vbrk.
  ENDIF.

ENDFORM.                               " READ_BI_DOCUMENT

*&---------------------------------------------------------------------*
*&      Form  READ_FI_DOCUMENT
*&---------------------------------------------------------------------*
*       read the fi_document                                           *
*----------------------------------------------------------------------*
FORM read_fi_document USING xbukrs xbelnr xgjahr.

  SELECT SINGLE * FROM  bkpf
         WHERE  bukrs       = xbukrs
         AND    belnr       = xbelnr
         AND    gjahr       = xgjahr.

  IF sy-subrc <> 0.
    CLEAR bkpf.
  ENDIF.

ENDFORM.                               " READ_FI_DOCUMENT

*&---------------------------------------------------------------------*
*&      Form  UPDATE_BI_DOCUMENT
*&---------------------------------------------------------------------*
*       Update billing document                                        *
*----------------------------------------------------------------------*
FORM update_bi_document.

  IF bi_subrc = 0.                     " billing not lock

    UPDATE vbrk SET xblnr = wk_xblnr
                WHERE  vbeln = key_vbrk-vbeln.

    PERFORM check_error.

    subrc_upd_bi = sy-subrc.

    CALL FUNCTION 'DEQUEUE_EVVBRKE'
      EXPORTING
        mandt  = sy-mandt
        vbeln  = key_vbrk-vbeln
      EXCEPTIONS
        OTHERS = 1.

  ELSE.                                " billing lock

    subrc_upd_bi = sy-subrc.

  ENDIF.

ENDFORM.                               " UPDATE_BI_DOCUMENT

*&---------------------------------------------------------------------*
*&      Form  UPDATE_FI_NF_DOCUMENT
*&---------------------------------------------------------------------*
*       Update financial and nota fiscal document                      *
*----------------------------------------------------------------------*
FORM update_fi_nf_document USING xbukrs xbelnr xgjahr.

  IF fi_subrc = 0.                     " billing not lock

    UPDATE bkpf SET xblnr = wk_xblnr
                WHERE  bukrs       = xbukrs
                AND    belnr       = xbelnr
                AND    gjahr       = xgjahr.

    PERFORM check_error.

    wk_header-follow = 'X'.

  ENDIF.

ENDFORM.                               " UPDATE_FI_NF_DOCUMENT

*&---------------------------------------------------------------------*
*&      Form  GET_FI_NUMBER
*&---------------------------------------------------------------------*
*       Read financial document via Billing document number            *
*----------------------------------------------------------------------*
FORM get_fi_number.

  SELECT SINGLE * FROM  bkpf
         WHERE  bukrs = vbrk-bukrs
         AND    awtyp = 'VBRK'
         AND    awkey = key_vbrk-vbeln.

  IF sy-subrc <> 0.
    CLEAR bkpf.
  ENDIF.

ENDFORM.                               " GET_FI_NUMBER


*&---------------------------------------------------------------------*
*&      Form  UPDATE_BSID_NF_DOCUMENT
*&---------------------------------------------------------------------*
*  update table BSID with external Nota Fiscal number - KI3K050466
*  change 23.01.97
*  Change 28.06.2000:
*  update also BSIS if G/L account with line item display exists
*  Change 09.08.2000: if cust account already cleared
*    (e.g. credit card sales) update BSAD instead of BSID
*----------------------------------------------------------------------*
FORM update_bsid_nf_document USING xbukrs xbelnr xgjahr.

  TABLES: bseg,
          bsid,
          bsis,
          bsad.

  SELECT * FROM bseg WHERE bukrs = xbukrs
                       AND belnr = xbelnr
                       AND gjahr = xgjahr
                       AND ( koart = 'D' OR koart = 'S' ).
    IF sy-subrc = '0'.
      IF bseg-koart = 'D'.
        IF NOT bseg-augbl IS INITIAL.  " account cleared --> update BSAD
          UPDATE ('BSAD') SET xblnr = wk_xblnr
                    WHERE bukrs = bseg-bukrs
                      AND kunnr = bseg-kunnr
                      AND umsks = bseg-umsks
                      AND umskz = bseg-umskz
                      AND augdt = bseg-augdt
                      AND augbl = bseg-augbl
                      AND zuonr = bseg-zuonr
                      AND gjahr = bseg-gjahr
                      AND belnr = bseg-belnr
                      AND buzei = bseg-buzei.

        ELSE.   " open item --> update BSID
* Customer account --> update BSID
          UPDATE ('BSID') SET xblnr = wk_xblnr
                    WHERE bukrs = bseg-bukrs
                      AND kunnr = bseg-kunnr
                      AND umsks = bseg-umsks
                      AND umskz = bseg-umskz
                      AND augdt = bseg-augdt
                      AND augbl = bseg-augbl
                      AND zuonr = bseg-zuonr
                      AND gjahr = bseg-gjahr
                      AND belnr = bseg-belnr
                      AND buzei = bseg-buzei.
          IF sy-subrc EQ 0.
            CALL FUNCTION 'OPEN_FI_PERFORM_00005010_P'
              EXPORTING
                i_chgtype     = 'U'
                i_origin      = 'J_1BNFPR UPDATE_BSID_NF_DOCUMENT'
                i_tabname     = 'BSID'
                i_where_bukrs = bseg-bukrs
                i_where_kunnr = bseg-kunnr
                i_where_umsks = bseg-umsks
                i_where_umskz = bseg-umskz
                i_where_augdt = bseg-augdt
                i_where_augbl = bseg-augbl
                i_where_zuonr = bseg-zuonr
                i_where_gjahr = bseg-gjahr
                i_where_belnr = bseg-belnr
                i_where_buzei = bseg-buzei
              EXCEPTIONS
                OTHERS        = 1.
            IF sy-subrc NE 0.
              MESSAGE ID sy-msgid TYPE 'A' NUMBER sy-msgno
                      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
            ENDIF.
          ELSE.
            PERFORM check_error.                            " 793934
          ENDIF. " BSID update ok
        ENDIF. " Clearing status: BSID or BSAD
      ENDIF.  " Debitor Accounts, Note 793934

* Always try to udate BSIS, regardless of account type (Note 793934)

*  G/L account --> try to update BSIS
      UPDATE ('BSIS') SET xblnr = wk_xblnr
                WHERE bukrs = bseg-bukrs
                  AND gjahr = bseg-gjahr
                  AND belnr = bseg-belnr
                  AND buzei = bseg-buzei.
* Update only possible for G/L accounts with line item display
*   --> Print NF even for update failure in bsis
      CLEAR sy-subrc.
    ENDIF. " Reading BSEG
  ENDSELECT.

* perform unlocking of the fi document only after the update of BSID,
* because this table must also be locked during update - the following
* call function was before in the form update_fi_nf_document.

  CALL FUNCTION 'DEQUEUE_EFBKPF'
    EXPORTING
      bukrs  = xbukrs
      belnr  = xbelnr
      gjahr  = xgjahr
    EXCEPTIONS
      OTHERS = 1.

ENDFORM.                               " UPDATE_BSID_NF_DOCUMENT

*---------------------------------------------------------------------*
*       FORM ENQUEUE_BI_FI                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM enqueue_bi_fi.

  CLEAR bi_subrc.

* sort the wk_item to get the first item
  SORT wk_item.
  READ TABLE wk_item INDEX 1.

  CHECK wk_item-reftyp = 'BI'.
  MOVE wk_item-refkey TO key_vbrk.

  PERFORM read_bi_document.

  IF NOT vbrk IS INITIAL.              "call via SD
    CALL FUNCTION 'ENQUEUE_EVVBRKE'
      EXPORTING
        mandt          = sy-mandt
        vbeln          = key_vbrk-vbeln
      EXCEPTIONS
        foreign_lock   = 1
        system_failure = 2
        OTHERS         = 3.

    bi_subrc = sy-subrc.
    PERFORM check_error.
    IF bi_subrc = 0.                   "BI document not locked
      CLEAR bkpf.
      PERFORM get_fi_number.
      IF NOT bkpf-belnr IS INITIAL.
        CALL FUNCTION 'ENQUEUE_EFBKPF'
          EXPORTING
            bukrs          = bkpf-bukrs
            belnr          = bkpf-belnr
            gjahr          = bkpf-gjahr
          EXCEPTIONS
            foreign_lock   = 1
            system_failure = 2
            OTHERS         = 3.

        fi_subrc = sy-subrc.
        PERFORM check_error.
        IF fi_subrc <> 0.     "FI lock not successful -> release BI lock
          CALL FUNCTION 'DEQUEUE_EVVBRKE'
            EXPORTING
              mandt  = sy-mandt
              vbeln  = key_vbrk-vbeln
            EXCEPTIONS
              OTHERS = 1.
          PERFORM check_error.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                               " ENQUEUE_BI_FI
*&---------------------------------------------------------------------*
*&      Form  check_nf_canceled
*&---------------------------------------------------------------------*
*       allow print of NF only when NF is not canceled
*----------------------------------------------------------------------*
FORM check_nf_canceled.
  DATA: lv_dummy  TYPE c.

  IF NOT wk_header-cancel IS INITIAL AND wk_header-nfnum IS INITIAL.
    sy-subrc = 1.
    MESSAGE ID '8B'
            TYPE 'E'
            NUMBER '678'
            WITH wk_header-docnum
            INTO lv_dummy.

    PERFORM check_error.
    IF sy-batch IS INITIAL.                " corr. of note 442570
      MESSAGE e678 WITH wk_header-docnum.
    ENDIF.                                 " corr. of note 442570
  ENDIF.
ENDFORM.                    " check_nf_canceled
*&---------------------------------------------------------------------*
*&      Form  check_nfe_authorized
*&---------------------------------------------------------------------*
FORM check_nfe_authorized.
  DATA: lv_dummy TYPE c,
        lv_subrc TYPE sy-subrc,
        obj_ref  TYPE REF TO if_ex_cl_nfe_print.

  CLEAR gs_nfeactive.

* only NFes
  CHECK wk_header-nfe = 'X'.

  SELECT SINGLE * FROM j_1bnfe_active INTO gs_nfeactive
  WHERE docnum = wk_header-docnum.

  IF NOT sy-subrc IS INITIAL.
    MESSAGE e012 WITH wk_header-docnum.
  ENDIF.

  IF gs_nfeactive-code IS INITIAL.

    COMMIT WORK AND WAIT.
    WAIT UP TO 30 SECONDS.

    SELECT SINGLE * FROM j_1bnfe_active INTO gs_nfeactive
    WHERE docnum = wk_header-docnum.

    IF NOT sy-subrc IS INITIAL.
      MESSAGE e012 WITH wk_header-docnum.
    ENDIF.

  ENDIF.

  j_1bnfe_active = gs_nfeactive.

* don't print NF-e when ...
* ... rejected docsta = 2
* ... denied   docsta = 3
* ... switches manual to contingency
  IF gs_nfeactive-conting_s = 'X'
  OR gs_nfeactive-docsta    = '2'
  OR gs_nfeactive-docsta    = '3'.

    lv_subrc = 1.

  ELSE.

*-- don´t print not authorized NFes

    IF  wk_header-authcod IS INITIAL    "Nfe is not authorized
    AND wk_header-conting IS INITIAL.   "and not in contingency
      lv_subrc = 1.
    ENDIF.
  ENDIF.

*-- BADI for reset subrc
*-- When subrc is 0 NFes can be printed without aauthorization code

  IF obj_ref IS INITIAL.

    CALL METHOD cl_exithandler=>get_instance       " #EC CI_BADI_GETINST
      EXPORTING
        exit_name                     = 'CL_NFE_PRINT'
        null_instance_accepted        = seex_false
      CHANGING
        instance                      = obj_ref
      EXCEPTIONS
        no_reference                  = 1
        no_interface_reference        = 2
        no_exit_interface             = 3
        class_not_implement_interface = 4
        single_exit_multiply_active   = 5
        cast_error                    = 6
        exit_not_existing             = 7
        data_incons_in_exit_managem   = 8
        OTHERS                        = 9.

    IF sy-subrc IS INITIAL.
*- nothing to do
    ENDIF.

  ENDIF.

  IF obj_ref IS BOUND.
    CALL METHOD obj_ref->reset_subrc
      EXPORTING
        is_nfdoc = wk_header
      CHANGING
        ch_subrc = lv_subrc.
  ENDIF.

  sy-subrc = lv_subrc.

  IF sy-subrc IS NOT INITIAL.
    IF gs_nfeactive-conting_s = 'X'.
      MESSAGE ID 'J1B_NFE'
              TYPE 'E'
              NUMBER '040'
              WITH wk_header-docnum
              INTO lv_dummy.
    ELSE.
      MESSAGE ID 'J1B_NFE'
              TYPE 'E'
              NUMBER '039'
              WITH wk_header-docnum
              INTO lv_dummy.
    ENDIF.
    IF sy-batch IS INITIAL.
      PERFORM check_error.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ELSE.
    gs_nfeactive-printd = 'X'.
  ENDIF.

ENDFORM.                    " check_nfe_authorized
*&---------------------------------------------------------------------*
*&      Form  active_update
*&---------------------------------------------------------------------*
FORM active_update .

  UPDATE j_1bnfe_active FROM gs_nfeactive.

  IF sy-subrc <> 0.
    MESSAGE a021(j1b_nfe) WITH gs_nfeactive-docnum.
  ENDIF.

ENDFORM.                    " active_update
*&--------------------------------------------------------------------*
*&      Form  smart_sub_printing
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
FORM smart_sub_printing.

  DATA:   tax_types LIKE j_1baj OCCURS 30 WITH HEADER LINE.

  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = tnapr-sform
    IMPORTING
      fm_name            = fm_name
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2.

  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  REFRESH: my_items.

  SELECT *
    FROM j_1bnfdoc
    INTO TABLE gt_j_1bnfdoc
    WHERE docnum IN s_docnum
      AND nftype IN s_nftype
      AND doctyp IN s_doctyp
      AND direct IN s_direct
      AND docdat IN s_docdat
      AND pstdat IN s_pstdat.

  IF sy-subrc = 0.

  ELSE.
    EXIT.
  ENDIF.

  LOOP AT gt_j_1bnfdoc ASSIGNING FIELD-SYMBOL(<fs_j_1bnfdoc>).

* read the Nota Fiscal
    PERFORM nota_fiscal_read USING <fs_j_1bnfdoc>-docnum.            " read nota fiscal

* allow print of NF only when NF is not canceled
    PERFORM check_nf_canceled.   " check nota fiscal canceled,442570

* number and update the Nota Fiscal
    CHECK retcode IS INITIAL.

* The NFe to be printed must have an authorization code
    IF wk_header-nfe = 'X'.

*   The NFe to be printed must have an authorization code
      PERFORM check_nfe_authorized.
      CHECK retcode IS INITIAL.

    ENDIF.
* for NFe the DANFE is printed. Numbering has already taken place
* before sending teh XML document to SEFAZ.
* Billing document is updated for NFe with the 9 digit NFe number
    IF wk_header-entrad = 'X' OR  "update only entradas or outgoing NF
       wk_header-direct  = '2'.
      IF wk_header-printd IS INITIAL AND " not printed.
         wk_header-nfnum IS INITIAL  AND " without NF number
         nast-nacha = '1'.               " sent to printer

        PERFORM enqueue_bi_fi.
        CHECK retcode IS INITIAL.
* get NF number only for "normal NFs" NFe has already the number
        IF wk_header-nfe IS INITIAL.
          PERFORM nota_fiscal_number.      " get the next number
        ENDIF.

        IF retcode IS INITIAL.
*        PERFORM financial_doc_update.    " update in database
          PERFORM nota_fiscal_update.      " update in database
          IF NOT gs_nfeactive IS INITIAL.
            PERFORM active_update. "ON COMMIT.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    IF retcode IS INITIAL.
    ELSE.
      MESSAGE a114 WITH '01' 'J_1BNFNUMB'.
    ENDIF.

*----------------------------------------------------------------------*
*    read tax types into internal buffer table                         *
*----------------------------------------------------------------------*
    SELECT * FROM j_1baj INTO TABLE tax_types ORDER BY PRIMARY KEY.

    CLEAR  w_danfe.
    CLEAR: w_danfe-issuer,
           w_danfe-destination,
           w_danfe-carrier,
           w_danfe-nota_fiscal,
           w_danfe-others,
           w_danfe-nfe,
           w_danfe-observ1,
           w_danfe-observ2,
           w_danfe-item,
           w_danfe-invoice.

*----------------------------------------------------------------------*
*    fill header data into communication structure                     *
*----------------------------------------------------------------------*
    MOVE-CORRESPONDING wk_header TO w_danfe-nota_fiscal.

    CLEAR: w_danfe-nota_fiscal-pstdat, w_danfe-nota_fiscal-cretim.    "Fusion - Taiã Pryor - 10:29:19

    SELECT SINGLE *
           FROM j_1bnfe_active
           INTO w_danfe-nfe
           WHERE docnum EQ wk_header-docnum.

*---> determine CFOP length, extension and deafulttext from version
*---> table
    PERFORM get_cfop_length_smart  USING wk_header-bukrs
                                   wk_header-branch
                                   wk_header-pstdat
                          CHANGING cfop_version     " BOI note 593218
                                   cfop_length
                                   extension_length
                                   defaulttext
                                   issuer_region.

    MOVE cfop_length TO w_danfe-nota_fiscal-cfop_len.
*... fill header CFOP .................................................*

    DATA: BEGIN OF wk_cfop OCCURS 0,
            key(6)          TYPE c,
            char6(6)        TYPE c,
            dupl_text_indic TYPE c,
            text(50)        TYPE c.
    DATA: END OF wk_cfop.
    DATA: help_cfop(6)    TYPE c,
          default_cfop(6) TYPE c,
          lv_tabix        TYPE sytabix,
          v_cfop          TYPE j_1bnflin-cfop.


    LOOP AT wk_item.
*    CONCATENATE wk_item-cfop(3) '0' wk_item-cfop+4(2) INTO v_cfop.
*    wk_item-cfop = v_cfop.
      WRITE wk_item-cfop  TO help_cfop.
      help_cfop = help_cfop(cfop_length).
      CASE extension_length.
        WHEN 1.
          IF ( wk_item-cfop+1(3) = '991' OR wk_item-cfop+1(3) = '999' )
                                               AND issuer_region = 'SP'.
            CONCATENATE help_cfop '.' wk_item-cfop+3(1) INTO help_cfop.
          ENDIF.
        WHEN 2.
          IF wk_item-cfop+1(2) = '99' AND issuer_region = 'SC'.
            CONCATENATE help_cfop '.' wk_item-cfop+3(2) INTO help_cfop.
          ENDIF.
      ENDCASE.

      READ TABLE wk_cfop WITH KEY key = help_cfop.
      lv_tabix = sy-tabix.
      IF sy-subrc <> 0.  " new CFOP on this NF: append this CFOP to list
        wk_cfop-char6  =  wk_item-cfop.
        wk_cfop-key    =  help_cfop.

        SELECT SINGLE * FROM j_1bagnt   WHERE spras   = sy-langu
                                          AND version = cfop_version
                                          AND cfop    = wk_item-cfop.
        IF sy-subrc = 0.
          wk_cfop-text = j_1bagnt-cfotxt.
          APPEND wk_cfop.
        ELSE.
          encoded_cfop = wk_item-cfop.
          IF encoded_cfop(1) CA                    " BOI note 593218-470
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ[-<>=!?]'.
            WRITE wk_item-cfop  TO encoded_cfop.
            REPLACE '/' IN encoded_cfop WITH ' '.
            CONDENSE encoded_cfop NO-GAPS.
          ELSE.
            PERFORM encoding_cfop_smart CHANGING encoded_cfop.
          ENDIF.                                   " EOI note 593218-470
*PERFORM ENCODING_CFOP_SMART CHANGING ENCODED_CFOP." note 593218-470
          SELECT SINGLE * FROM j_1bagnt WHERE spras = nast-spras
                                            AND version = cfop_version
                                            AND cfop    = encoded_cfop.
          IF sy-subrc = 0.
            wk_cfop-text = j_1bagnt-cfotxt.
            APPEND wk_cfop.
          ENDIF.
        ENDIF.
      ELSE. " CFOP already on list; however, could be rel. to other text
        IF wk_cfop-char6 <> wk_item-cfop AND
                                    wk_cfop-dupl_text_indic IS INITIAL.
          default_cfop      = wk_item-cfop.
          default_cfop+4(2) = defaulttext.
          SELECT SINGLE * FROM j_1bagnt WHERE spras   = nast-spras
                                          AND version = cfop_version
                                          AND cfop    = default_cfop.
          IF sy-subrc = 0.
            wk_cfop-text = j_1bagnt-cfotxt.
            wk_cfop-dupl_text_indic = 'X'.
            MODIFY wk_cfop INDEX lv_tabix.
          ELSE.
            encoded_cfop = default_cfop.
            PERFORM encoding_cfop_smart CHANGING encoded_cfop.
            SELECT SINGLE * FROM j_1bagnt WHERE spras = nast-spras
                                            AND version = cfop_version
                                            AND cfop    = encoded_cfop.
            IF sy-subrc = 0.
              wk_cfop-text = j_1bagnt-cfotxt.
              wk_cfop-dupl_text_indic = 'X'.
              MODIFY wk_cfop INDEX lv_tabix.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.

    DESCRIBE TABLE wk_cfop LINES cfop_lines.
    IF cfop_lines > 1.
      SORT wk_cfop.
      DELETE ADJACENT DUPLICATES FROM wk_cfop COMPARING key.
      LOOP AT wk_cfop.
        CONCATENATE w_danfe-nota_fiscal-cfop_text
                    '/'
                    wk_cfop-key wk_cfop-text
                    INTO w_danfe-nota_fiscal-cfop_text.
        IF w_danfe-nota_fiscal-cfop_text(1) EQ '/'.
          SHIFT w_danfe-nota_fiscal-cfop_text LEFT BY 1 PLACES.
        ENDIF.
      ENDLOOP.
    ELSEIF cfop_lines = 1.      " NF with items that all have one CFOP
      MOVE wk_cfop-key  TO w_danfe-nota_fiscal-cfop.
      MOVE wk_cfop-text TO w_danfe-nota_fiscal-cfop_text.
    ENDIF.                                             " BOI note 593218

*----------------------------------------------------------------------*
*    If you are on contingency, print barcode                          *
*----------------------------------------------------------------------*

    CLEAR  v_contingkey.
    WRITE: wk_header_add-nftot TO v_nftot_char(14).

    REPLACE '.' INTO v_nftot_char WITH ''.
    REPLACE ',' INTO v_nftot_char WITH ''.
    CONDENSE v_nftot_char NO-GAPS.
    UNPACK v_nftot_char TO v_nftot_char .


*  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*    EXPORTING
*      input  = v_nftot_char
*    IMPORTING
*      output = v_nftot_char.


    IF NOT gs_nfeactive-conting IS INITIAL.
* Adiciona dados de icms proprio e icms de substituicao para contigencia
*v_nftot_char
      e_znfecontigekey-icmsp = '2'.
      e_znfecontigekey-icmss = '2'.


      LOOP AT wk_item.
        IF wk_item-taxsit = '0' OR wk_item-taxsit = '1' OR wk_item-taxsit
    = '2' OR wk_item-taxsit = '6' OR wk_item-taxsit = '7'
              OR wk_item-taxsit = '10' OR wk_item-taxsit = '51' OR
    wk_item-taxsit = 'B'.
          e_znfecontigekey-icmsp = '1'.
        ENDIF.

        IF  wk_item-taxsit = '1' OR wk_item-taxsit = '3' OR wk_item-taxsit
                  = '6' OR wk_item-taxsit = '7'.
          e_znfecontigekey-icmss = '1'.
        ENDIF.

      ENDLOOP.



* Monta o número de contigencia
* Tipo de impressão (FS - Contingência com uso do Formulário de
* segurança) página 8 do manual de contingência
      e_znfecontigekey-tpemiss = '5'.

* Valor total da nota sem pontos, virgulas e com zeros a esquerda (14
*    posições)
      e_znfecontigekey-vtotal = v_nftot_char.

* Dia da data de emissão
      e_znfecontigekey-ddemiss = wk_header-docdat+6(2).

      MOVE j_1bnfe_active TO wk_danfe.

* Código da região e CNPJ do destinatário

* Se for cliente
      IF wk_header-partyp = 'C'.

        SELECT SINGLE *
          FROM kna1
          WHERE kunnr = wk_header-parid.


        e_znfecontigekey-regio = kna1-txjcd+3(2).
        e_znfecontigekey-stcd1 = kna1-stcd1(14).
* Não Esquecer de colocar o campo stcd2 na estrutura
*      if e_znfecontigekey-stcd1 = '00000000000000'.
*        clear e_znfecontigekey-stcd1.
*      endif.
*      WRITE: kna1-stcd2 TO v_cpf.
*      REPLACE '.' INTO v_cpf WITH ''.
*      REPLACE '.' INTO v_cpf WITH ''.
*      REPLACE '-' INTO v_cpf WITH ''.
*
*      CONDENSE v_cpf NO-GAPS.
*
*      UNPACK v_cpf TO  e_znfecontigekey-stcd2 .

      ENDIF.

* se for Fornecedor

      IF wk_header-partyp = 'V' OR
         wk_header-partyp = 'B'.

        SELECT SINGLE *
          FROM lfa1
          WHERE lifnr = wk_header-parid.

        e_znfecontigekey-regio = lfa1-txjcd+3(2).
        e_znfecontigekey-stcd1 = lfa1-stcd1(14).
*      if e_znfecontigekey-stcd1 = '00000000000000'.
*        clear e_znfecontigekey-stcd1.
*      endif.
*      WRITE: lfa1-stcd2 TO v_cpf.
*      REPLACE '.' INTO v_cpf WITH ''.
*      REPLACE '.' INTO v_cpf WITH ''.
*      REPLACE '-' INTO v_cpf WITH ''.
*
*      CONDENSE v_cpf NO-GAPS.
*
*      UNPACK v_cpf TO  e_znfecontigekey-stcd2 .

      ENDIF.

* Se for cliente do exterior
*    IF j_1bprnfde-land1 <> 'BR'.
*
*      CLEAR:
*        e_znfecontigekey-regio,
*        e_znfecontigekey-stcd1.
*
*      e_znfecontigekey-regio = '99'.
*      e_znfecontigekey-stcd1 = '00000000000000'.
*    ENDIF.

* Gera digito verificador
      CALL FUNCTION 'ZNFE_CREATE_CONTI_CHECK_DIGIT'
        CHANGING
          c_contingkey = e_znfecontigekey.

* Cria chave de contingencia
      CONCATENATE e_znfecontigekey-regio
                  e_znfecontigekey-tpemiss
                  e_znfecontigekey-stcd1
*                e_znfecontigekey-stcd2
                  e_znfecontigekey-vtotal
                  e_znfecontigekey-icmsp
                  e_znfecontigekey-icmss
                  e_znfecontigekey-ddemiss
                  e_znfecontigekey-cdv
                  INTO v_contingkey.

* Apagar chave de contingência, caso não seja do tipo

      MOVE 'DADOS NF-e' TO v_nfe.

      IF gs_nfeactive-conting = space.

        CLEAR: v_contingkey,
               v_nfe.
      ENDIF.
    ENDIF.

*----------------------------------------------------------------------*
*    determine issuer and destination (only for test)                  *
*----------------------------------------------------------------------*
    IF wk_header-direct = '1'   AND
       wk_header-entrad = ' '.
      issuer-partner_type      = wk_header-partyp.
      issuer-partner_id        = wk_header-parid.
      issuer-partner_function  = wk_header-parvw.
      destination-partner_type = 'B'.
      destination-partner_id   = wk_header-bukrs.
      destination-partner_id+4 = wk_header-branch.
    ELSE.
      issuer-partner_type          = 'B'.
      issuer-partner_id            = wk_header-bukrs.
      issuer-partner_id+4          = wk_header-branch.
      destination-partner_type     = wk_header-partyp.
      destination-partner_id       = wk_header-parid.
      destination-partner_function = wk_header-parvw.
    ENDIF.

*----------------------------------------------------------------------*
*    read branch data (issuer)                                         *
*----------------------------------------------------------------------*

    CLEAR j_1binnad.

    CALL FUNCTION 'J_1B_NF_PARTNER_READ'
      EXPORTING
        partner_type           = issuer-partner_type
        partner_id             = issuer-partner_id
        partner_function       = issuer-partner_function
        doc_number             = wk_header-docnum
        obj_item               = wk_item
      IMPORTING
        parnad                 = j_1binnad
      EXCEPTIONS
        partner_not_found      = 1
        partner_type_not_found = 2
        OTHERS                 = 3.
    MOVE-CORRESPONDING j_1binnad TO w_danfe-issuer.



*... check the sy-subrc ...............................................*
    PERFORM check_error.
    CHECK retcode IS INITIAL.

*----------------------------------------------------------------------*
*    read destination data                                             *
*----------------------------------------------------------------------*

    CLEAR j_1binnad.

    CALL FUNCTION 'J_1B_NF_PARTNER_READ'
      EXPORTING
        partner_type           = destination-partner_type
        partner_id             = destination-partner_id
        partner_function       = destination-partner_function
        doc_number             = wk_header-docnum
        obj_item               = wk_item
      IMPORTING
        parnad                 = j_1binnad
      EXCEPTIONS
        partner_not_found      = 1
        partner_type_not_found = 2
        OTHERS                 = 3.
    MOVE-CORRESPONDING j_1binnad TO w_danfe-destination.

    IF w_danfe-destination-land1 NE 'BR'.
      SELECT SINGLE valuf FROM  j_1bnfe_cust3
        INTO w_danfe-destination-regio
       WHERE bukrs  = wk_header-bukrs
         AND branch = wk_header-branch
         AND model  = wk_header-model.
    ENDIF.

* >>> Início - Fusion - LA - 19.05.2020 - Dados destinatário (9535)
*----------------------------------------------------------------------*
*    read destination data                                             *
*----------------------------------------------------------------------*
    CLEAR j_1binnad.
    CALL FUNCTION 'J_1B_NF_PARTNER_READ'
      EXPORTING
        partner_type           = destination-partner_type
        partner_id             = destination-partner_id
        partner_function       = destination-partner_function
        doc_number             = wk_header-docnum
        obj_item               = wk_item
      IMPORTING
        parnad                 = j_1binnad
      EXCEPTIONS
        partner_not_found      = 1
        partner_type_not_found = 2
        OTHERS                 = 3.
    MOVE-CORRESPONDING j_1binnad TO w_danfe-destination.

    DATA:
      l_vbeln TYPE vbeln.
    READ TABLE wk_item
      INDEX 1.
    l_vbeln = wk_item-refkey.
    CALL FUNCTION 'Z_SD_DADOS_DESTINATARIO_DANFE'
      EXPORTING
        i_vbeln        = l_vbeln
        i_danfe        = abap_true
      TABLES
        it_item        = wk_item
      CHANGING
        cs_destination = w_danfe-destination.
* <<< Fim - Fusion - LA - 19.05.2020 - Dados destinatário (9535)

* >>> Início - Fusion - JB - 13.03.2021 - Dados Local de entrega - Melhorias Endereço
    DATA: lv_vbeln     TYPE vbrp-vbeln,
          lv_aubel     TYPE vbrp-aubel,
          lv_auart     TYPE vbak-auart,
          lv_kunnr     TYPE vbpa-kunnr,
          lv_lifnr     TYPE vbpa-lifnr,
          lv_adrnumber TYPE vbpa-adrnr.

    CLEAR w_danfe-delivery.
    SELECT sign, opti, low, high
      INTO TABLE @DATA(lr_auart)
      FROM tvarvc
      WHERE name EQ 'TIPO_OV_ENDENTREGA'.
    IF sy-subrc IS INITIAL.
      SELECT SINGLE a~cgc, a~cpf, a~stains, b~refkey
             FROM j_1bnfdoc AS a
                  INNER JOIN j_1bnflin AS b
                        ON b~docnum = a~docnum
             INTO @DATA(ls_nfdata)
             WHERE a~docnum = @wk_header-docnum.
      lv_vbeln = ls_nfdata-refkey(10).
      SELECT SINGLE aubel
             INTO lv_aubel
             FROM vbrp
             WHERE vbeln = lv_vbeln.
      SELECT SINGLE auart
             INTO lv_auart
             FROM vbak
             WHERE vbeln = lv_aubel.
      "Checa se o tipo de ordem está na stvarv TIPO_OV_ENDENTREGA
      IF lv_auart IN lr_auart.
        SELECT SINGLE kunnr lifnr adrnr
               INTO (lv_kunnr, lv_lifnr, lv_adrnumber)
               FROM vbpa
               WHERE vbeln = lv_vbeln
                 AND parvw = 'ZE'. "entrega da mercadoria
        IF sy-subrc IS INITIAL.
          SELECT SINGLE name1, name2, street, house_num1, city1, city2, region, post_code1, tel_number
                 INTO @DATA(ls_end)
                 FROM adrc
                 WHERE addrnumber = @lv_adrnumber.
          IF sy-subrc IS INITIAL.
            w_danfe-delivery-name1  = ls_end-name1. "nome
            w_danfe-delivery-name2  = ls_end-name2.
            w_danfe-delivery-stras  = |{ ls_end-street }| & | | & |{ ls_end-house_num1 }|. "rua+numero
            w_danfe-delivery-ort01  = ls_end-city1. "municipio
            w_danfe-delivery-ort02  = ls_end-city2. "bairro
            w_danfe-delivery-regio  = ls_end-region. "uf
            w_danfe-delivery-pstlz  = ls_end-post_code1. "cep
            w_danfe-delivery-telf1  = ls_end-tel_number. "telefone
            IF ls_nfdata-cgc IS NOT INITIAL.
              w_danfe-delivery-cgc  = ls_nfdata-cgc. "cgc
            ELSE.
              w_danfe-delivery-cpf  = ls_nfdata-cpf. "cpf
            ENDIF.
            w_danfe-delivery-stains = ls_nfdata-stains."inscrição estadual
          ENDIF.
        ENDIF.

      ENDIF.
    ENDIF.
* >>> Fim - Fusion - JB - 13.03.2021 - Dados local de entrega - Melhorias Endereço

*----------------------------------------------------------------------*
*    read fatura data if the Nota Fiscal is a Nota Fiscal Fatura       *
*----------------------------------------------------------------------*

    DATA: v_loops TYPE i,
          v_linha TYPE i,
          v_index TYPE i.

    CLEAR v_linha.

    IF wk_header-fatura = 'X'.

      IF wk_header-zterm NE space.
        SELECT *
               FROM t052
               WHERE zterm = wk_header-zterm
               ORDER BY PRIMARY KEY.
          EXIT.
        ENDSELECT.

        IF t052-ztagg > '00' AND t052-ztagg LT wk_header-zfbdt+6(2).
          SELECT *
                 FROM t052
                 WHERE zterm =  wk_header-zterm
                 AND   ztagg GE wk_header-zfbdt+6(2)
                 ORDER BY PRIMARY KEY.
            EXIT.
          ENDSELECT.
        ENDIF.

        IF t052-xsplt = 'X'.               "holdback/retainage

          SELECT *
                 FROM t052s
                 INTO TABLE int_t052s
                 WHERE zterm = wk_header-zterm
                 ORDER BY PRIMARY KEY.

          DESCRIBE TABLE int_t052s LINES t052slines.

          " FS - NP - Chamado 8443. Uma linha com as faturas concatenadas na DANFE
          CLEAR v_loops.
          IF t052slines > 0.
            v_loops = 1.
          ENDIF.

*        IF t052slines > 6.  "limite da estrutura j_1bprnffa         "TP - Ch.15192 - Fusion - 07.04.2022
*          t052slines = 6.                                           "TP - Ch.15192 - Fusion - 07.04.2022
*        ENDIF.                                                      "TP - Ch.15192 - Fusion - 07.04.2022

          IF t052slines > 5.  "limite da estrutura j_1bprnffa
            t052slines = 5.
          ENDIF.

          DO v_loops TIMES.

            ADD 1 TO v_linha.

            DO t052slines TIMES VARYING rate  FROM j_1bprnffa-ratpz1
                                              NEXT j_1bprnffa-ratpz2
                                VARYING text2 FROM j_1bprnffa-txt12
                                              NEXT j_1bprnffa-txt22
                                VARYING text3 FROM j_1bprnffa-txt13
                                              NEXT j_1bprnffa-txt23
                                VARYING text4 FROM j_1bprnffa-txt14
                                              NEXT j_1bprnffa-txt24
                                VARYING text1 FROM j_1bprnffa-txt11
                                              NEXT j_1bprnffa-txt21.

              v_index = sy-index + ( ( v_linha - 1 ) * 3 ).

              READ TABLE int_t052s INDEX v_index.

              rate = int_t052s-ratpz.
              SELECT SINGLE *
                     FROM t052
                     WHERE zterm = int_t052s-ratzt
                     AND   ztagg = '00'.
              CALL FUNCTION 'FI_TEXT_ZTERM'
                EXPORTING
                  i_t052  = t052
                TABLES
                  t_ztext = ztext.
              LOOP AT ztext.
                CASE sy-tabix.
                  WHEN 1.
                    text2 = ztext-text1.
                  WHEN 2.
                    text3 = ztext-text1.
                  WHEN 3.
                    text4 = ztext-text1.
                  WHEN 4.
                    text1 = ztext-text1.
                ENDCASE.
              ENDLOOP.
            ENDDO.
            APPEND j_1bprnffa TO w_danfe-invoice.
          ENDDO.
        ELSE.                              " t052-xsplt = ' '
          CALL FUNCTION 'FI_TEXT_ZTERM'
            EXPORTING
              i_t052  = t052
            TABLES
              t_ztext = ztext.

          LOOP AT ztext.
            CASE sy-tabix.
              WHEN 1.
                j_1bprnffa-txt02 = ztext-text1.
              WHEN 2.
                j_1bprnffa-txt03 = ztext-text1.
              WHEN 3.
                j_1bprnffa-txt04 = ztext-text1.
              WHEN 4.
                j_1bprnffa-txt01 = ztext-text1.
            ENDCASE.
          ENDLOOP.
          APPEND j_1bprnffa TO w_danfe-invoice.
        ENDIF.
      ENDIF.
    ENDIF.


*----------------------------------------------------------------------*
*    read carrier data                                                 *
*----------------------------------------------------------------------*

    DATA: lv_adrnr TYPE adrnr,
          lv_end   TYPE ad_strspp1,
          lv_end1  TYPE ad_strspp1,
          lv_end2  TYPE ad_strspp1,
          lv_end3  TYPE ad_strspp1.

    CONSTANTS: cc_lf TYPE j_1bparvw VALUE 'LF'.

    IF wk_header-doctyp NE '2'.          "no carrier for Complementars

      READ TABLE wk_partner WITH KEY docnum = wk_header-docnum
                                     parvw  = 'SP'.
      IF sy-subrc = 0.

        CLEAR j_1binnad.
        CALL FUNCTION 'J_1B_NF_PARTNER_READ'
          EXPORTING
            partner_type           = wk_partner-partyp
            partner_id             = wk_partner-parid
            partner_function       = wk_partner-parvw
            doc_number             = wk_header-docnum
          IMPORTING
            parnad                 = j_1binnad
          EXCEPTIONS
            partner_not_found      = 1
            partner_type_not_found = 2
            OTHERS                 = 3.

        MOVE-CORRESPONDING j_1binnad TO w_danfe-carrier.

* >>>> FS - RT 03/06/2019
*      SELECT SINGLE adrnr FROM lfa1
*        INTO lv_adrnr
*       WHERE lifnr = wk_partner-parid.
*
*      w_danfe-carrier-name1 = w_danfe-carrier-name2.
*      w_danfe-carrier-name2 = w_danfe-carrier-name3.
*
*      SELECT SINGLE str_suppl1 FROM adrc
*        INTO w_danfe-carrier-stras
*       WHERE addrnumber = lv_adrnr.
* <<<< FS - RT 03/06/2019
      ENDIF.

    ENDIF.          "no carrier for Complementars

    CLEAR: lv_adrnr, lv_end1, lv_end2, lv_end3.

    IF wk_header-parvw = cc_lf.
      SELECT SINGLE adrnr FROM lfa1
        INTO lv_adrnr
       WHERE lifnr = wk_header-parid.
    ELSE.
      SELECT SINGLE adrnr FROM kna1
        INTO lv_adrnr
       WHERE kunnr = wk_header-parid.
    ENDIF.

    w_danfe-nota_fiscal-name1 = w_danfe-nota_fiscal-name2.
    w_danfe-nota_fiscal-name2 = w_danfe-nota_fiscal-name3.

    SELECT SINGLE str_suppl1 str_suppl2 FROM adrc
      INTO (lv_end1, lv_end2)
     WHERE addrnumber = lv_adrnr.
    SPLIT lv_end1 AT ',' INTO lv_end lv_end3.

    CONDENSE lv_end3.
    CONCATENATE lv_end lv_end3 INTO lv_end SEPARATED BY space.
    IF NOT lv_end2 IS INITIAL.
      CONCATENATE lv_end lv_end2 INTO w_danfe-destination-street SEPARATED BY ','.
    ELSE.
      w_danfe-destination-street = lv_end.
    ENDIF.
* >>> Início - Fusion - LA - 23.05.2019
*  w_danfe-destination-name1 = w_danfe-destination-name2.
*  w_danfe-destination-name2 = w_danfe-destination-name3.
* <<< Fim - Fusion - LA - 23.05.2019

*----------------------------------------------------------------------*
*    read reference NF                                                 *
*----------------------------------------------------------------------*
    IF w_danfe-nota_fiscal-docref <> space.
      SELECT SINGLE * FROM j_1bnfdoc INTO *j_1bnfdoc
               WHERE docnum = w_danfe-nota_fiscal-docref.
      w_danfe-nota_fiscal-nf_docref = *j_1bnfdoc-nfnum.
      w_danfe-nota_fiscal-nf_serref = *j_1bnfdoc-series.
      w_danfe-nota_fiscal-nf_subref = *j_1bnfdoc-subser.
      w_danfe-nota_fiscal-nf_datref = *j_1bnfdoc-docdat.
    ENDIF.

*----------------------------------------------------------------------*
*    get information about form                                        *
*----------------------------------------------------------------------*

    DATA: print_conf TYPE j_1bb2.

*    CALL FUNCTION 'J_1BNF_GET_PRINT_CONF'
*      EXPORTING
*        headerdata = wk_header
*      IMPORTING
*        print_conf = print_conf
*      EXCEPTIONS
*        error      = 1
*        OTHERS     = 2.
*
*    PERFORM check_error.
*    CHECK retcode IS INITIAL.

*----------------------------------------------------------------------*
*    write texts to TEXTS window                                       *
*----------------------------------------------------------------------*

    DATA: w_line TYPE tline.

    istart = print_conf-totlih.                       " note note 743361

    "Recupera textos da NF                                                                            "+ TP - Fusion - Upgrade S4 2023 - 29.02.2024
    gt_texts[] = gr_texts->get_text_table( ).                                                         "+ TP - Fusion - Upgrade S4 2023 - 29.02.2024
    LOOP AT gt_texts[] ASSIGNING FIELD-SYMBOL(<fs_nftext>)                                            "+ TP - Fusion - Upgrade S4 2023 - 29.02.2024
      WHERE type = 'C'. "Informações complementares (empresa)                                         "+ TP - Fusion - Upgrade S4 2023 - 29.02.2024
      CLEAR gt_split[].                                                                               "+ TP - Fusion - Upgrade S4 2023 - 29.02.2024
      "Divide string                                                                                  "+ TP - Fusion - Upgrade S4 2023 - 29.02.2024
      CALL FUNCTION 'SOTR_SERV_STRING_TO_TABLE'                                                       "+ TP - Fusion - Upgrade S4 2023 - 29.02.2024
        EXPORTING                                                                                     "+ TP - Fusion - Upgrade S4 2023 - 29.02.2024
          text        = <fs_nftext>-text                                                              "+ TP - Fusion - Upgrade S4 2023 - 29.02.2024
          line_length = 72  "Mantendo tamanho da estrutura wk_header_msg                              "+ TP - Fusion - Upgrade S4 2023 - 29.02.2024
        TABLES                                                                                        "+ TP - Fusion - Upgrade S4 2023 - 29.02.2024
          text_tab    = gt_split[].                                                                   "+ TP - Fusion - Upgrade S4 2023 - 29.02.2024
      LOOP AT gt_split ASSIGNING FIELD-SYMBOL(<fs_text>).                                             "+ TP - Fusion - Upgrade S4 2023 - 29.02.2024
        w_line-tdline = <fs_text>.                                                                    "+ TP - Fusion - Upgrade S4 2023 - 29.02.2024
        IF sy-index LT istart.                                                                        "+ TP - Fusion - Upgrade S4 2023 - 29.02.2024
          IF sy-index EQ 1.                                                                           "+ TP - Fusion - Upgrade S4 2023 - 29.02.2024
            w_danfe-observ1 = <fs_text>.                                                              "+ TP - Fusion - Upgrade S4 2023 - 29.02.2024
          ELSE.                                                                                       "+ TP - Fusion - Upgrade S4 2023 - 29.02.2024
            CONCATENATE w_danfe-observ1                                                               "+ TP - Fusion - Upgrade S4 2023 - 29.02.2024
                        cl_abap_char_utilities=>cr_lf                                                 "+ TP - Fusion - Upgrade S4 2023 - 29.02.2024
                        <fs_text>                                                                     "+ TP - Fusion - Upgrade S4 2023 - 29.02.2024
                        INTO w_danfe-observ1.                                                         "+ TP - Fusion - Upgrade S4 2023 - 29.02.2024
          ENDIF.                                                                                      "+ TP - Fusion - Upgrade S4 2023 - 29.02.2024
          APPEND w_line TO w_danfe-text1.                                                             "+ TP - Fusion - Upgrade S4 2023 - 29.02.2024
        ELSE.                                                                                         "+ TP - Fusion - Upgrade S4 2023 - 29.02.2024
          IF sy-index EQ istart.                                                                      "+ TP - Fusion - Upgrade S4 2023 - 29.02.2024
            w_danfe-observ2 = <fs_text>.                                                              "+ TP - Fusion - Upgrade S4 2023 - 29.02.2024
          ELSE.                                                                                       "+ TP - Fusion - Upgrade S4 2023 - 29.02.2024
            CONCATENATE w_danfe-observ2                                                               "+ TP - Fusion - Upgrade S4 2023 - 29.02.2024
                        cl_abap_char_utilities=>cr_lf                                                 "+ TP - Fusion - Upgrade S4 2023 - 29.02.2024
                        <fs_text>                                                                     "+ TP - Fusion - Upgrade S4 2023 - 29.02.2024
                        INTO w_danfe-observ2.                                                         "+ TP - Fusion - Upgrade S4 2023 - 29.02.2024
          ENDIF.                                                                                      "+ TP - Fusion - Upgrade S4 2023 - 29.02.2024
          APPEND w_line TO w_danfe-text2.                                                             "+ TP - Fusion - Upgrade S4 2023 - 29.02.2024
        ENDIF.                                                                                        "+ TP - Fusion - Upgrade S4 2023 - 29.02.2024
      ENDLOOP.                                                                                        "+ TP - Fusion - Upgrade S4 2023 - 29.02.2024
    ENDLOOP.                                                                                          "+ TP - Fusion - Upgrade S4 2023 - 29.02.2024

*  LOOP AT wk_header_msg.                                                                           "- TP - Fusion - Upgrade S4 2023 - 29.02.2024
*    w_line-tdline = wk_header_msg-message.                                                         "- TP - Fusion - Upgrade S4 2023 - 29.02.2024
*    IF sy-index LT istart.                                                                         "- TP - Fusion - Upgrade S4 2023 - 29.02.2024
*      IF sy-index EQ 1.                                                                            "- TP - Fusion - Upgrade S4 2023 - 29.02.2024
*        w_danfe-observ1 = wk_header_msg-message.                                                   "- TP - Fusion - Upgrade S4 2023 - 29.02.2024
*      ELSE.                                                                                        "- TP - Fusion - Upgrade S4 2023 - 29.02.2024
*        CONCATENATE w_danfe-observ1                                                                "- TP - Fusion - Upgrade S4 2023 - 29.02.2024
*                    cl_abap_char_utilities=>cr_lf                                                  "- TP - Fusion - Upgrade S4 2023 - 29.02.2024
*                    wk_header_msg-message                                                          "- TP - Fusion - Upgrade S4 2023 - 29.02.2024
*                    INTO w_danfe-observ1.                                                          "- TP - Fusion - Upgrade S4 2023 - 29.02.2024
*      ENDIF.                                                                                       "- TP - Fusion - Upgrade S4 2023 - 29.02.2024
*      APPEND w_line TO w_danfe-text1.                                                              "- TP - Fusion - Upgrade S4 2023 - 29.02.2024
*    ELSE.                                                                                          "- TP - Fusion - Upgrade S4 2023 - 29.02.2024
*      IF sy-index EQ istart.                                                                       "- TP - Fusion - Upgrade S4 2023 - 29.02.2024
*        w_danfe-observ2 = wk_header_msg-message.                                                   "- TP - Fusion - Upgrade S4 2023 - 29.02.2024
*      ELSE.                                                                                        "- TP - Fusion - Upgrade S4 2023 - 29.02.2024
*        CONCATENATE w_danfe-observ2                                                                "- TP - Fusion - Upgrade S4 2023 - 29.02.2024
*                    cl_abap_char_utilities=>cr_lf                                                  "- TP - Fusion - Upgrade S4 2023 - 29.02.2024
*                    wk_header_msg-message                                                          "- TP - Fusion - Upgrade S4 2023 - 29.02.2024
*                    INTO w_danfe-observ2.                                                          "- TP - Fusion - Upgrade S4 2023 - 29.02.2024
*      ENDIF.                                                                                       "- TP - Fusion - Upgrade S4 2023 - 29.02.2024
*      APPEND w_line TO w_danfe-text2.                                                              "- TP - Fusion - Upgrade S4 2023 - 29.02.2024
*    ENDIF.                                                                                         "- TP - Fusion - Upgrade S4 2023 - 29.02.2024
*  ENDLOOP.                                                                                         "- TP - Fusion - Upgrade S4 2023 - 29.02.2024

    DATA: lp_icap_val TYPE j_1bnfstx-taxval,
          lp_icep_val TYPE j_1bnfstx-taxval,
          lp_icsp_val TYPE j_1bnfstx-taxval.

    DATA: lp_icap_base TYPE j_1bnfstx-base,
          lp_icep_base TYPE j_1bnfstx-base,
          lp_icsp_base TYPE j_1bnfstx-base.

    DATA: lp_icap_aliq TYPE j_1bnfstx-rate,
          lp_icep_aliq TYPE j_1bnfstx-rate,
          lp_icsp_aliq TYPE j_1bnfstx-rate.

    DATA: lc_icap_val TYPE c LENGTH 15,
          lc_icep_val TYPE c LENGTH 15,
          lc_icsp_val TYPE c LENGTH 15.

    DATA: lc_icap_base TYPE c LENGTH 15,
          lc_icep_base TYPE c LENGTH 15,
          lc_icsp_base TYPE c LENGTH 15.

    DATA: lc_icap_aliq TYPE c LENGTH 15,
          lc_icep_aliq TYPE c LENGTH 15,
          lc_icsp_aliq TYPE c LENGTH 15.

    DATA: lc_partr TYPE c LENGTH 15.

    IF wk_header-ind_iedest = '9'.  " Não Contribuinte
      READ TABLE wk_item_tax WITH KEY taxtyp = 'ICAP'.  " Busca valor na Partilha
      IF sy-subrc IS INITIAL AND wk_item_tax-taxval > 0.
        LOOP AT wk_item_tax.
          CASE wk_item_tax-taxtyp.
            WHEN 'ICAP'. " ICMS Destino
              lp_icap_val  = lp_icap_val + wk_item_tax-taxval.
              lp_icap_base = lp_icap_base + wk_item_tax-base.
              lp_icap_aliq = wk_item_tax-rate.
            WHEN 'ICEP'.  " ICMS Origem
              lp_icep_val  = lp_icep_val + wk_item_tax-taxval.
              lp_icep_base = lp_icep_base + wk_item_tax-base.
              lp_icep_aliq = wk_item_tax-rate.
            WHEN 'ICSP'. " Fundo de Pobreza
              lp_icsp_val  = lp_icsp_val + wk_item_tax-taxval.
              lp_icsp_base = lp_icsp_base + wk_item_tax-base.
              lp_icsp_aliq = wk_item_tax-rate.
          ENDCASE.
        ENDLOOP.

        WRITE wk_header-partr TO lc_partr LEFT-JUSTIFIED.
        WRITE lp_icap_base TO lc_icap_base LEFT-JUSTIFIED.
        WRITE lp_icap_aliq TO lc_icap_aliq LEFT-JUSTIFIED.
        WRITE lp_icap_val  TO lc_icap_val  LEFT-JUSTIFIED.
        CONCATENATE 'ICMS Part.Destino: Base R$' lc_icap_base '- Aliq.' lc_icap_aliq '%-Perc.Part.' lc_partr '%-Valor R$' lc_icap_val
               INTO w_line-tdline SEPARATED BY space.
        APPEND w_line TO w_danfe-text1.

        WRITE lp_icep_base TO lc_icep_base LEFT-JUSTIFIED.
        WRITE lp_icep_aliq TO lc_icep_aliq LEFT-JUSTIFIED.
        WRITE lp_icep_val  TO lc_icep_val  LEFT-JUSTIFIED.
        CONCATENATE 'ICMS Part.Origem: Base R$' lc_icep_base '- Aliq.' lc_icep_aliq '%-Valor R$' lc_icep_val
               INTO w_line-tdline SEPARATED BY space.
        APPEND w_line TO w_danfe-text1.

*** Se Fundo de Pobreza maior que zero.
        IF lp_icsp_val > 0.
          WRITE lp_icsp_base TO lc_icsp_base LEFT-JUSTIFIED.
          WRITE lp_icsp_aliq TO lc_icsp_aliq LEFT-JUSTIFIED.
          WRITE lp_icsp_val  TO lc_icsp_val  LEFT-JUSTIFIED.
          CONCATENATE 'ICMS Fundo da Pobreza: Base R$' lc_icsp_base '- Aliq.' lc_icsp_aliq '%-Valor R$' lc_icsp_val
                INTO w_line-tdline SEPARATED BY space.
          APPEND w_line TO w_danfe-text1.
        ENDIF.
      ENDIF.
    ENDIF.

*... fill items ......................................................*

    DATA: lt_vbfa TYPE TABLE OF vbfa,
          ls_vbfa TYPE vbfa.

    DATA: ls_vbrp TYPE vbrp.

    DATA: lc_id       TYPE thead-tdid     VALUE 'TXXX', "'TX06',
          lc_language TYPE thead-tdspras,
          lc_name     TYPE thead-tdname,
          lc_object   TYPE thead-tdobject VALUE 'VBBK'.

    DATA: lt_lines TYPE TABLE OF tline,
          ls_lines TYPE tline.

    DATA: lp_valor_trib TYPE j_1bnflin-vtottrib,
          lc_valor_trib TYPE c LENGTH 16.

    LOOP AT wk_item.
      lp_valor_trib = lp_valor_trib + wk_item-vtottrib.
    ENDLOOP.

    WRITE lp_valor_trib TO lc_valor_trib LEFT-JUSTIFIED.
    CONCATENATE 'Total aproximado de tributos: R$' lc_valor_trib INTO w_line-tdline SEPARATED BY space.
    APPEND w_line TO w_danfe-text1.

    IF NOT wk_item-refkey IS INITIAL.

      SELECT * FROM vbfa
        INTO TABLE lt_vbfa
       WHERE vbeln = wk_item-refkey
         AND vbtyp_v = 'J'.

      CLEAR w_line-tdline.
      DELETE ADJACENT DUPLICATES FROM lt_vbfa COMPARING vbelv.
      LOOP AT lt_vbfa INTO ls_vbfa.
        IF sy-tabix = 1.
          CONCATENATE 'Remessa:' ls_vbfa-vbelv INTO w_line-tdline SEPARATED BY space.
        ELSE.
          CONCATENATE w_line-tdline ',' INTO w_line-tdline.
          CONCATENATE w_line-tdline ls_vbfa-vbelv INTO w_line-tdline SEPARATED BY space.
        ENDIF.
      ENDLOOP.
      IF NOT w_line-tdline IS INITIAL.
        APPEND w_line TO w_danfe-text1.
      ENDIF.

      SELECT SINGLE * FROM vbrp
        INTO ls_vbrp
       WHERE vbeln = wk_item-refkey
         AND posnr = wk_item-refitm.

      IF NOT wk_item-xped IS INITIAL.
        CONCATENATE 'Ordem:' ls_vbrp-aubel '- Pedido:' wk_item-xped INTO w_line-tdline SEPARATED BY space.
        APPEND w_line TO w_danfe-text1.
      ELSE.
        CONCATENATE 'Ordem:' ls_vbrp-aubel INTO w_line-tdline SEPARATED BY space.
        APPEND w_line TO w_danfe-text1.
      ENDIF.

      lc_language = sy-langu.
      lc_name = wk_item-refkey.

      CALL FUNCTION 'READ_TEXT'
        EXPORTING
          id                      = lc_id
          language                = lc_language
          name                    = lc_name
          object                  = lc_object
        TABLES
          lines                   = lt_lines
        EXCEPTIONS
          id                      = 1
          language                = 2
          name                    = 3
          not_found               = 4
          object                  = 5
          reference_check         = 6
          wrong_access_to_archive = 7
          OTHERS                  = 8.

      LOOP AT lt_lines INTO ls_lines.
        w_line-tdline = ls_lines-tdline.
        APPEND w_line TO w_danfe-text1.
      ENDLOOP.

    ENDIF.

    DATA: ls_ztbfci005 TYPE ztbfci005.

*** Início - Fusion - Taiã Pryor - 03.07.2019
    SELECT SINGLE *
      FROM ztbfci005
      INTO ls_ztbfci005
      WHERE bukrs  = wk_header-bukrs
        AND branch = wk_header-branch.
    IF sy-subrc IS INITIAL.
      DATA(lv_first_fci) = abap_true.
    ENDIF.
*** Fim - Fusion - Taiã Pryor - 03.07.2019

    LOOP AT wk_item.

      IF wk_item-matorg EQ '3' OR
         wk_item-matorg EQ '5' OR
         wk_item-matorg EQ '8'.

*** Início - Fusion - Taiã Pryor - 03.07.2019
*      SELECT SINGLE * FROM ztbfci005
*        INTO ls_ztbfci005
*       WHERE bukrs  = wk_header-bukrs
*         AND branch = wk_header-branch.
*** Fim - Fusion - Taiã Pryor - 03.07.2019

        IF ls_ztbfci005-hab_imp IS NOT INITIAL.
          IF wk_item-nfci IS NOT INITIAL.
*** Início - Fusion - Taiã Pryor - 03.07.2019
*          CONCATENATE 'Resolução do Senado Federal no 13/12, Número da FCI' wk_item-nfci INTO w_line-tdline SEPARATED BY space.
            IF lv_first_fci IS NOT INITIAL.
              CLEAR: w_line, lv_first_fci.

              APPEND w_line TO w_danfe-text1.
              w_line-tdline = 'Resolução do Senado Federal no 13/12, Número da FCI:'.
              APPEND w_line TO w_danfe-text1.
            ENDIF.

            w_line-tdline = wk_item-matnr && ':'.
            CONCATENATE w_line-tdline
                        wk_item-nfci
                   INTO w_line-tdline
                   SEPARATED BY space.
            APPEND w_line TO w_danfe-text1.
*** Fim - Fusion - Taiã Pryor - 03.07.2019
          ENDIF.
        ENDIF.
      ENDIF.

      READ TABLE wk_item_add WITH KEY docnum = wk_item-docnum
                                      itmnum = wk_item-itmnum.
      IF wk_item-netdis < 0.
        wk_item-netdis = wk_item-netdis * -1.
      ENDIF.

      MOVE wk_item-netdis TO wk_header_add-nfdis.

      CLEAR j_1bprnfli.
      MOVE-CORRESPONDING wk_item TO j_1bprnfli.
      MOVE-CORRESPONDING wk_item_add TO j_1bprnfli.

*... fill text reference ..............................................*

      LOOP AT wk_refer_msg WHERE itmnum = wk_item-itmnum.
        REPLACE '  ' WITH wk_refer_msg-seqnum INTO j_1bprnfli-text_ref.
        REPLACE ' '  WITH ','                 INTO j_1bprnfli-text_ref.
      ENDLOOP.
      REPLACE ', ' WITH '  ' INTO j_1bprnfli-text_ref.

      SELECT SINGLE base FROM j_1bnfstx
        INTO j_1bprnfli-base
       WHERE docnum = wk_item-docnum
         AND itmnum = wk_item-itmnum
         AND taxtyp = 'ICM3'.

      APPEND j_1bprnfli TO w_danfe-item.

    ENDLOOP.

    CHECK retcode IS INITIAL.

    MOVE-CORRESPONDING wk_header_add TO w_danfe-nota_fiscal.

    IF NOT lr_badi IS INITIAL.
      CALL METHOD lr_badi->filling_danfe
        CHANGING
          danfe = w_danfe.
    ENDIF.

*----------------------------------------------------------------------*
*    Faturas / Duplicatas
*----------------------------------------------------------------------*
    DATA: lt_bkpf TYPE TABLE OF bkpf,
          lt_bseg TYPE TABLE OF bseg.

    DATA: ls_bseg TYPE bseg.

    DATA: ld_zfbdt TYPE dzfbdt,
          lc_zfbdt TYPE c LENGTH 10,
          li_tabix TYPE i,
          lc_dmbtr TYPE c LENGTH 12.

    DATA: ls_fatura  TYPE zstnfe002,
          ls_invoice TYPE j_1bprnffa.

    READ TABLE wk_item INDEX 1.
    IF wk_item-reftyp EQ 'BI'.
      REFRESH: gt_fatura[].
      SELECT * FROM bkpf
        INTO TABLE lt_bkpf
       WHERE awtyp = 'VBRK'
         AND awkey = wk_item-refkey.
      IF lt_bkpf[] IS NOT INITIAL.
        SELECT * FROM bseg
          INTO TABLE lt_bseg
           FOR ALL ENTRIES IN lt_bkpf
         WHERE bukrs = lt_bkpf-bukrs
           AND belnr = lt_bkpf-belnr
           AND gjahr = lt_bkpf-gjahr.
        " Manter apenas registros onde chave de lançamento = Fatura
        DELETE lt_bseg WHERE bschl NE '01'.

        LOOP AT lt_bseg INTO ls_bseg.
          WRITE ls_bseg-dmbtr TO lc_dmbtr LEFT-JUSTIFIED.
          CALL FUNCTION 'FKK_RWIN_DUE_DATE_DETERMINE'
            EXPORTING
              i_zterm = ls_bseg-zterm
              i_bldat = ls_bseg-zfbdt
              i_budat = ls_bseg-zfbdt
              i_cpudt = ls_bseg-zfbdt
              i_zfbdt = ls_bseg-zfbdt
            IMPORTING
              e_faedn = ld_zfbdt.
          CONCATENATE ld_zfbdt+6(2) ld_zfbdt+4(2) ld_zfbdt+2(2) INTO lc_zfbdt SEPARATED BY '/'.
          CONCATENATE lc_zfbdt lc_dmbtr INTO ls_fatura-fatura SEPARATED BY space.
          APPEND ls_fatura TO gt_fatura.
        ENDLOOP.
      ENDIF.
    ENDIF.

    IF NOT gt_fatura[] IS INITIAL AND ls_invoice IS NOT INITIAL.
      APPEND ls_invoice TO w_danfe-invoice.
    ENDIF.

*----------------------------------------------------------------------*
*    Espécie
*----------------------------------------------------------------------*
    READ TABLE wk_item INDEX 1.
    IF wk_item-reftyp = 'BI'.
      IF w_danfe-nota_fiscal-shpunt NE 'PAL'.
        w_danfe-nota_fiscal-shpunt = 'VOL'.
      ENDIF.
    ENDIF.

    PERFORM call_smartform USING wk_header w_danfe wa_nfe_alv '2' abap_false.

  ENDLOOP.

ENDFORM.                        "smart_sub_printing

*&---------------------------------------------------------------------
*&      Form  GET_CFOP_LENGTH_SMART
*&---------------------------------------------------------------------
*       text
*----------------------------------------------------------------------
FORM get_cfop_length_smart USING    p_bukrs
                                    p_branch
                                    p_pstdat
                           CHANGING p_version         " note 593218
                                    p_clength
                                    p_elength
                                    p_text
                                    p_region.         " note 593218

  DATA: lv_adress   TYPE addr1_val.

  CALL FUNCTION 'J_1BREAD_BRANCH_DATA'
    EXPORTING
      bukrs             = p_bukrs
      branch            = p_branch
    IMPORTING
      address1          = lv_adress
    EXCEPTIONS
      branch_not_found  = 1
      address_not_found = 2
      company_not_found = 3
      OTHERS            = 4.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  p_region = lv_adress-region.                   " note 593218

  CALL FUNCTION 'J_1B_CFOP_GET_VERSION'
    EXPORTING
      region            = lv_adress-region
      date              = p_pstdat
    IMPORTING
      version           = p_version        " note 593218
      extension         = p_elength
      cfoplength        = p_clength
      txtdef            = p_text
    EXCEPTIONS
      date_missing      = 1
      version_not_found = 2
      OTHERS            = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                             " GET_CFOP_LENGTH_SMART

*&---------------------------------------------------------------------
*&      Form  ENCODING_CFOP_SMART
*&---------------------------------------------------------------------
*       encode the CFOP
*      51234   =>  51234
*      5123A   =>  5123A
*      512345  =>  512345
*      51234A  =>  51234A
*      5123B4  =>  5123B4
*      5123BA  =>  5123BA
*----------------------------------------------------------------------
FORM encoding_cfop_smart  CHANGING p_cfop.

  DATA: len(1)         TYPE n,
        helpstring(60) TYPE c,
        d              TYPE i.

  helpstring =
    'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ[-<>=!?]'.

  len = strlen( p_cfop ).
  IF len = 6.
    CASE p_cfop(1).
      WHEN 1.
        d = 0.
      WHEN 2.
        d = 1.
      WHEN 3.
        d = 2.
      WHEN 5.
        d = 3.
      WHEN 6.
        d = 4.
      WHEN 7.
        d = 5.
    ENDCASE.
    d = d * 10 + p_cfop+1(1).
    SHIFT helpstring BY d PLACES.
    MOVE helpstring(1) TO p_cfop(1).
    p_cfop+1(4) = p_cfop+2(4).
    CLEAR p_cfop+5(1).
  ENDIF.

ENDFORM.                    " ENCODING_CFOP_SMART
*&--------------------------------------------------------------------*
*&      Form  call_smartform
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
FORM call_smartform USING wk_header   TYPE j_1bnfdoc
                          w_danfe     TYPE znfedanfe_header
                          wa_nfe_alv  LIKE wa_nfe_alv
p_op_type TYPE c
        p_is_event TYPE abap_bool.

*  DATA: lt_pdf_tab      TYPE TABLE OF tline,
*        lt_otf          TYPE TABLE OF itcoo,
*        ls_otfdata      TYPE ssfcrescl,
*        lv_subject      TYPE tdtitle,
*        lv_pdf          TYPE char1,
*        lv_bin_file     TYPE xstring,
*        lv_bin_filesize TYPE i.
*
** I - Alt - Projeto Visão 360
*  DATA: ls_spool     TYPE rspoid,
*        ls_spool_360 TYPE zsd_t_spool_360.
** F - Alt - Projeto Visão 360
*
*  DATA lv_v360(1) TYPE c.                                     "+ TP - Ch.14854 - Fusion - 23.03.2022
*
*  output_options-tdimmed       = nast-dimme.
*  output_options-tddest        = nast-ldest.
*  control_parameters-no_dialog = 'X'.
** I - Alt - Projeto Visão 360
*  output_options-tdnewid = abap_true.
** F - Alt - Projeto Visão 360
*
*
** >>> Início - Fusion - LA - 30.11.2020 - Envio de DANFE automaticamente por e-mail
*  CLEAR: lv_pdf.
*  IMPORT xpdf = lv_pdf FROM MEMORY ID 'ZFNFE001'.
*  IF lv_pdf <> abap_true AND sy-cprog = '/XNFE/NFE_B2B_SEND'.
*    lv_pdf = abap_true.
*  ENDIF.
** <<< Fim - Fusion - LA - 30.11.2020 - Envio de DANFE automaticamente por e-mail
*
*  " Buscar dispositivo do cadastro do usuário
*  IF sy-tcode EQ 'J1B3N'.
*    SELECT SINGLE spld FROM usr01
*      INTO output_options-tddest
*     WHERE bname = sy-uname.
*  ENDIF.
*
** >>> Início - Fusion - LA - 30.11.2020 - Envio de DANFE automaticamente por e-mail
*  IF lv_pdf IS NOT INITIAL.
*    control_parameters-no_dialog = 'X'.
*    control_parameters-getotf    = 'X'.
*  ENDIF.
** <<< Fim - Fusion - LA - 30.11.2020 - Envio de DANFE automaticamente por e-mail
*
*  CALL FUNCTION fm_name
*    EXPORTING
*      control_parameters = control_parameters
*      output_options     = output_options
*      user_settings      = ''
*      nota_fiscal        = w_danfe
*      v_contingkey       = v_contingkey
*      v_nfe              = v_nfe
*      v_nfe1             = v_nfe1
*      v_docnum           = wk_header-docnum
** >>> Início - Fusion - LA - 30.11.2020 - Envio de DANFE automaticamente por e-mail
*    IMPORTING
*      job_output_info    = ls_otfdata
** <<< Fim - Fusion - LA - 30.11.2020 - Envio de DANFE automaticamente por e-mail
*    TABLES
*      t_fatura           = gt_fatura
*    EXCEPTIONS
*      formatting_error   = 1
*      internal_error     = 2
*      send_error         = 3
*      user_canceled      = 4
*      OTHERS             = 5.
*
** I - Alt - Projeto Visão 360
*  IF sy-subrc EQ 0.
*    CLEAR lv_v360.                                            "+ TP - Ch.14854 - Fusion - 23.03.2022
*    IMPORT lv_v360 = lv_v360 FROM MEMORY ID 'ZV360_DANFE'.    "+ TP - Ch.14854 - Fusion - 23.03.2022
*    IF lv_v360 = 'X'.                                         "+ TP - Ch.14854 - Fusion - 23.03.2022
*
*      READ TABLE ls_otfdata-spoolids INTO ls_spool INDEX 1.
*      IF sy-subrc EQ 0.
*        ls_spool_360-spool = ls_spool.
*        ls_spool_360-docnum = w_danfe-nota_fiscal-docnum.
*        MODIFY zsd_t_spool_360 FROM ls_spool_360.
*      ENDIF.
*
*    ENDIF.                                                    "+ TP - Ch.14854 - Fusion - 23.03.2022
*    FREE MEMORY ID 'ZV360_DANFE'.                             "+ TP - Ch.14854 - Fusion - 23.03.2022
*  ENDIF.
** I - Alt - Projeto Visão 360
*
*
*
** >>> Início - Fusion - LA - 30.11.2020 - Envio de DANFE automaticamente por e-mail
*  " Envio do PDF
*  IF lv_pdf IS NOT INITIAL.
*    REFRESH: lt_pdf_tab,
*             lt_otf.
*
*    lt_otf[] = ls_otfdata-otfdata[].
*
*    CALL FUNCTION 'CONVERT_OTF'
*      EXPORTING
*        format                = 'PDF'
*        max_linewidth         = 132
*      IMPORTING
*        bin_filesize          = lv_bin_filesize
*        bin_file              = lv_bin_file
*      TABLES
*        otf                   = lt_otf
*        lines                 = lt_pdf_tab
*      EXCEPTIONS
*        err_max_linewidth     = 1
*        err_format            = 2
*        err_conv_not_possible = 3
*        OTHERS                = 4.
*
*    IF sy-subrc <> 0.
*      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*    ENDIF.
*
*    EXPORT pdf = lv_bin_file            TO MEMORY ID 'ZFNFE001'.
**    EXPORT lt_otf      FROM lt_otf      TO MEMORY ID 'LT_OTF'.
**    EXPORT lt_pdf_tab  FROM lt_pdf_tab  TO MEMORY ID 'LT_PDF_TAB'.
** <<< Fim - Fusion - LA - 30.11.2020 - Envio de DANFE automaticamente por e-mail
*
*  ENDIF.

*******************************************

  DATA lo_download   TYPE REF TO cl_j_1bnfe_xml_download.
  DATA lv_access_key TYPE j_1b_nfe_access_key_dtel44.
  DATA lv_direction  TYPE j_1b_nfe_direction.
  DATA lv_doctype    TYPE j_1b_nfe_doctype.
  DATA ls_acckey     TYPE j_1b_nfe_access_key.
  DATA ls_active     TYPE j_1bnfe_active.
  DATA ls_event      TYPE j_1bnfe_event.
  DATA lv_rfcdest    TYPE rfcdest.
  DATA lv_docentrad  TYPE j_1bnfdoc-entrad.                 "2176338
  DATA: lo_nfse               TYPE REF TO if_j_1bnfse,
        lo_download_cloud     TYPE REF TO cl_nfe_cloud_download, "2932848
        lv_is_valid_for_cloud TYPE abap_bool,                         "2932848 "3039634
        lv_cloud_uuid         TYPE nfe_document_uuid.       "2932848
  DATA lx_nfe          TYPE REF TO cx_nfe.
  DATA lx_file_handler TYPE REF TO cx_nfe_cloud_badi_file_handler.
  DATA lo_log_error    TYPE REF TO cl_j_1bnfe_error_log.
  DATA lv_is_mass_download_allowed TYPE abap_bool.

  CONSTANTS lc_model_nfe  TYPE j_1b_nfe_doctype VALUE 'NFE'.
  CONSTANTS lc_model_cte  TYPE j_1b_nfe_doctype VALUE 'CTE'.
  CONSTANTS lc_direct_in  TYPE j_1b_nfe_direction VALUE 'INBD'.
  CONSTANTS lc_direct_out TYPE j_1b_nfe_direction VALUE 'OUTB'.

  DATA: go_download  TYPE REF TO  cl_j_1bnfe_xml_download.

  DATA lo_dom TYPE REF TO if_ixml_document.  ##NEEDED
  DATA w_string TYPE xstring.    ##NEEDED
  DATA w_size        TYPE i.
  DATA it_xml        TYPE dcxmllines.

* ALV selection

  DATA: it_selected_rows TYPE lvc_t_row,
        wa_selected_rows TYPE lvc_s_row.
  DATA: lt_event_selected_rows TYPE lvc_t_row,
        wa_event_selected_rows TYPE lvc_s_row.
  DATA: wa_alv_selection  TYPE j_1bnfe_active,
        it_alv_selection  TYPE TABLE OF j_1bnfe_active
           WITH KEY docnum,
        it_alv_error      TYPE TABLE OF j_1bnfe_active
               WITH KEY docnum,

        gt_attachment_hex TYPE solix_tab. " Table which contains the attached file
  DATA lo_nfe_related_nf_cancel_mgr TYPE REF TO if_nfe_related_nf_cancel_mgr.

* Modified entries of ALV (current NF-e statuses)           "1090279
  DATA wa_active_mod TYPE          j_1bnfe_active.          "1090279
  DATA it_active_mod LIKE TABLE OF wa_active_mod            "1090279
                     WITH KEY      docnum.                  "1090279
* Modified entries for ALV2 (single NF-e history)           "1090279
  DATA wa_nfe_alv2_new LIKE        wa_nfe_alv2.             "109027

*data ls_active type j_1bnfe_active.

  " Retrieve key information
  SELECT SINGLE *
    FROM j_1bnfe_active
    INTO ls_active
  WHERE docnum = wk_header-docnum.

  MOVE-CORRESPONDING ls_active TO ls_acckey.

  " Map the key to the proper structure
  lv_access_key = ls_acckey.

  " Retrieve the GRC rfc connection
  PERFORM get_rfc_destination
    USING ls_active
    CHANGING lv_rfcdest.

* Service Nota Fiscal (NFS-e)                                                                                         "2520709
  lo_nfse = cl_j_1bnfse=>get_instance( ).
  IF lo_nfse->is_service_notafiscal( iv_document_number = ls_active-docnum ) = abap_true. "2520709.
    lv_rfcdest = if_j_1bnfse=>mc_nfse_downloadxml_key.      "2520709
    lv_access_key = ls_active-rps.                          "3001273
    IF wa_nfe_alv-conting = abap_true.                      "2932848
      MESSAGE ID 'NFE' TYPE 'I' NUMBER '004'.               "2932848
      RETURN.                                               "2932848
    ENDIF.                                                  "2932848
  ENDIF.                                                    "2520709

  CREATE OBJECT lo_download_cloud.
  lv_is_valid_for_cloud = lo_download_cloud->is_valid_for_cloud( iv_document_number     = ls_active-docnum    "2932848 "3039634
                                                                 iv_company_code        = ls_active-bukrs     "2932848 "3039634
                                                                 iv_business_place      = ls_active-branch    "2932848 "3039634
                                                                 is_electronic_document = ls_active
                                                                 is_event               = p_is_event ).
  IF lv_is_valid_for_cloud = abap_true.                                                                   "2932848 "3039634
    MOVE-CORRESPONDING wa_nfe_alv3 TO ls_event ##ENH_OK.
    TRY.
        lo_download_cloud->download( is_electronic_nota_fiscal = ls_active
                                     is_nfe_event              = ls_event
                                     iv_uuid                   = lv_cloud_uuid                           "2932848
                                     iv_option                 = p_op_type ).                            "2932848
      CATCH cx_nfe_cloud_badi_file_handler INTO lx_file_handler.
        CREATE OBJECT lo_log_error.
        lo_log_error->add_error_message_table( lx_file_handler->get_messages( ) ).
        lo_log_error->display_error_log( ).
      CATCH cx_nfe INTO lx_nfe.
        lx_nfe->raise_message( ).
    ENDTRY.
    RETURN.                                                 "2932848
  ENDIF.                                                    "2932848

  " If connection was found
  IF lv_rfcdest IS NOT INITIAL.

    " Instantiate download object
    CREATE OBJECT lo_download
      EXPORTING
        iv_xml_key = lv_access_key
        iv_rfc     = lv_rfcdest.

    "   Check the nf type
    CASE ls_active-model.
      WHEN 55.
        lv_doctype = lc_model_nfe.
      WHEN 57.
        lv_doctype = lc_model_cte.
    ENDCASE.

    "   Check the direction
    CASE ls_active-direct.
      WHEN '1'.
        " Check if flaged as 'entrada' and
        " chage direction if needed
        SELECT SINGLE entrad                                "2176338
          FROM j_1bnfdoc                                    "2176338
          INTO lv_docentrad                                 "2176338
          WHERE docnum = ls_active-docnum.                  "2176338
        IF lv_docentrad = abap_true.                        "2176338
          lv_direction = lc_direct_out.                     "2176338
        ELSE.                                               "2176338
          lv_direction = lc_direct_in.                      "2176338
        ENDIF.                                              "2176338
      WHEN '2'.
        lv_direction = lc_direct_out.
    ENDCASE.

    IF wa_nfe_alv IS INITIAL.
      MOVE-CORRESPONDING ls_active TO wa_nfe_alv.
    ENDIF.

    IF wa_nfe_alv3 IS INITIAL.
      MOVE-CORRESPONDING ls_active TO wa_nfe_alv3.
    ENDIF.

    CASE p_op_type.
      WHEN '1'.
        " Start downloading XML
        CALL METHOD lo_download->save_xml_to_file
          EXPORTING
            iv_docnum       = wa_nfe_alv-docnum
            iv_event_type   = wa_nfe_alv3-ext_event
            iv_event_seqnum = wa_nfe_alv3-seqnum
            iv_direction    = lv_direction
            iv_doctype      = lv_doctype.

      WHEN '2'.
        " Start downloading XML
*        CALL METHOD lo_download->save_xml_to_screen
*          EXPORTING
*            iv_docnum       = wa_nfe_alv-docnum
*            iv_event_type   = wa_nfe_alv3-ext_event
*            iv_event_seqnum = wa_nfe_alv3-seqnum
*            iv_direction    = lv_direction
*            iv_doctype      = lv_doctype.


        "   Load XML from GRC and store on class attributes
        CALL METHOD lo_download->load_xml_content
          EXPORTING
            iv_docnum       = wa_nfe_alv-docnum
            iv_event_type   = wa_nfe_alv3-ext_event
            iv_event_seqnum = wa_nfe_alv3-seqnum
            iv_direction    = lv_direction
            iv_doctype      = lv_doctype.

        DATA lv_xml_content TYPE j_1b_nfe_xml_content.

*new_code
        CALL METHOD lo_download->get_xml_content
          RECEIVING
            ev_xml_content = lv_xml_content.

        DATA: it_binarytab     TYPE STANDARD TABLE OF sdokcntbin,
              wa_binarytab     TYPE sdokcntbin,
              l_xml_table_size TYPE i,
              l_output_length  TYPE  i,
              lv_xml_xstring   TYPE xstring,
              lv_xml_string    TYPE xstring,
              string_aux       TYPE string,
              lv_file_name     TYPE string,
              ti_buffer_xml    TYPE STANDARD TABLE OF soli.




        CALL FUNCTION 'SDIXML_XML_TO_DOM'
          EXPORTING
            xml           = lv_xml_content
          IMPORTING
            document      = lo_dom
          EXCEPTIONS
            invalid_input = 1
            OTHERS        = 2.


        CALL METHOD cl_crm_saf_se_util=>convert_xml_to_string
          EXPORTING
            ir_xml_doc    = lo_dom
          RECEIVING
            rv_xml_string = string_aux.



        CALL FUNCTION 'SCMS_STRING_TO_XSTRING'
          EXPORTING
            text   = string_aux
          IMPORTING
            buffer = lv_xml_xstring
          EXCEPTIONS
            failed = 1
            OTHERS = 2.
        IF sy-subrc <> 0.
          RETURN.
        ENDIF.


        " Chama o perform
        PERFORM envia_nfe_danfe_aux USING i_docnum.




        " Converte XSTRING para binário
        CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
          EXPORTING
            buffer        = lv_xml_xstring
          IMPORTING
            output_length = l_output_length
          TABLES
            binary_tab    = ti_buffer_xml.




    ENDCASE.

    FREE lo_download.
    CLEAR wa_selected_rows.
    CLEAR it_selected_rows.

  ENDIF.

*******************************************


  DATA: w_cont_par_otf TYPE  ssfctrlop.
  DATA: w_out_opt_otf TYPE  ssfcompop.
  DATA: gv_bin_filesize TYPE i.
  DATA: gt_pdf_tab TYPE TABLE OF tline, " SAPscript: Text Lines
        gt_otf     TYPE TABLE OF itcoo. " OTF Structure
  DATA: gs_otfdata TYPE ssfcrescl.
  DATA: gs_docdata TYPE sodocchgi1. " Data of an object which can be changed
  DATA: gt_reclist TYPE TABLE OF somlreci1. " SAPoffice: Structure of the API Recipient List
  DATA: gs_reclist TYPE somlreci1. " SAPoffice: Structure of the API Recipient List
  DATA: gs_objbin TYPE solisti1. " SAPoffice: Single List with Column Length 255
  DATA: gs_pdf_tab TYPE tline. " Workarea for SAP Script Text Lines
  DATA: gv_len TYPE i.
  DATA: gv_pos TYPE i.
  DATA: gv_tab_lines TYPE i.
  DATA: gt_objbin TYPE TABLE OF solisti1. " SAPoffice: Single List with Column Length 255
  DATA: gs_objpack TYPE sopcklsti1. " SAPoffice: Description of Imported Object Components
  DATA: gt_objpack TYPE TABLE OF sopcklsti1. " SAPoffice: Description of Imported Object Components
  DATA: t_ctxt TYPE TABLE OF solisti1.
  DATA: lv_email TYPE adr6-smtp_addr.

*    control_parameters-no_dialog = 'X'.
*    control_parameters-getotf    = 'X'.



  DATA:
    vl_num_spool            LIKE tbtco-jobcount,
    vl_dt_lim(10)           TYPE c,

    tl_num_spool            TYPE tsfspoolid,

    wl_document_output_info TYPE ssfcrespd,
    wl_job_output_info      TYPE ssfcrescl,
    wl_job_output_options   TYPE ssfcresop,
    wl_control_param        TYPE ssfctrlop,
    wl_composer_param       TYPE ssfcompop,
    vl_devtype              TYPE rspoptype,
    v_email                 TYPE char250,
    v_spool                 TYPE tsp01-rqident.

  DATA:
    ti_plist        LIKE sopcklsti1 OCCURS 2 WITH HEADER LINE,
    document_data   LIKE sodocchgi1,
    real_type       LIKE soodk-objtp,
    sp_lang         LIKE tst01-dlang,
    line_size       TYPE i VALUE 255,
    ti_rec_tab      LIKE somlreci1 OCCURS 1 WITH HEADER LINE,
    ti_txmail       TYPE TABLE OF solisti1 WITH HEADER LINE,
    ti_packing_list LIKE sopcklsti1 OCCURS 1 WITH HEADER LINE,
    ti_contents     LIKE solisti1 OCCURS 1 WITH HEADER LINE,
    ti_receivers    LIKE somlreci1 OCCURS 1 WITH HEADER LINE,
    ti_receivers_f  LIKE somlreci1 OCCURS 1 WITH HEADER LINE,
    ti_attachment   LIKE solisti1 OCCURS 1 WITH HEADER LINE,
    ti_message      TYPE STANDARD TABLE OF solisti1 INITIAL SIZE 10 WITH HEADER LINE,

*    ti_buffer       LIKE soli OCCURS 100 WITH HEADER LINE,

    ti_buffer       TYPE STANDARD TABLE OF soli,
    wa_buffer       TYPE STANDARD TABLE OF soli,
    ti_ltdxt        TYPE STANDARD TABLE OF ltdxt.

  DATA:
    v_name      LIKE soextreci1-receiver,
    v_txmail    TYPE solisti1-line,
    v_real_type TYPE soodk-objtp,
    v_sp_lang   TYPE tst01-dlang,
    v_message   TYPE c LENGTH 400,
    v_titulo    TYPE c LENGTH 100,
*  v_email     TYPE char250,
*  v_spool     TYPE tsp01-rqident,
    v_name_form TYPE rs38l_fnam,
    v_repid     TYPE sy-repid,
    v_zlsch     TYPE c,
    v_countz    TYPE num6,
    v_countc    TYPE char6,
    v_kunnr     TYPE kna1-kunnr,
    v_name1     TYPE kna1-name1,
    v_zuonr     TYPE num10,
    v_butxt     TYPE t001-butxt,

    v_docnum_c  TYPE char10.

  control_parameters-no_dialog = 'X'.
  control_parameters-preview = ' '.
  control_parameters-device = 'PRINTER'.
  control_parameters-getotf        = 'X'.

  output_options-tdprinter = 'LP01'. " Test
  output_options-tddest = 'LP01' .
  output_options-tdnewid = 'X' .
  output_options-tdimmed = ' '.
  output_options-tdnoprev = 'X'.


  CALL FUNCTION fm_name
    EXPORTING
      control_parameters   = control_parameters
      output_options       = output_options
      user_settings        = ''
      nota_fiscal          = w_danfe
      v_contingkey         = v_contingkey
      v_nfe                = v_nfe
      v_nfe1               = v_nfe1
      v_docnum             = wk_header-docnum
    IMPORTING
      document_output_info = wl_document_output_info
      job_output_info      = wl_job_output_info
      job_output_options   = wl_job_output_options
    TABLES
      t_fatura             = gt_fatura
    EXCEPTIONS
      formatting_error     = 1
      internal_error       = 2
      send_error           = 3
      user_canceled        = 4
      OTHERS               = 5.

  MOVE wl_job_output_info-spoolids[] TO tl_num_spool[].

  LOOP AT tl_num_spool INTO vl_num_spool.
    v_spool   = vl_num_spool.
    EXIT.
  ENDLOOP.


  v_spool   = vl_num_spool.


  DATA: lv_pdf_xstring TYPE xstring,
        lt_pdf_table   TYPE TABLE OF tline,
        lv_pdf_size    TYPE i.
  DATA: lv_bin_filesize TYPE so_obj_len,
        lv_sent_to_all  TYPE os_boolean,
        lv_bin_xstr     TYPE xstring,
        lv_fname        TYPE rs38l_fnam,
        lv_string_text  TYPE string.

  DATA: lt_otfdata            TYPE ssfcrescl,
        lt_binary_content     TYPE solix_tab,
        lt_text               TYPE bcsy_text,
        lt_pdf_tab            TYPE STANDARD TABLE OF tline,
        lt_otf                TYPE STANDARD TABLE OF itcoo,
        lw_control_parameters TYPE ssfctrlop,
        lw_output_options     TYPE ssfcompop,
        lw_ssfcrescl          TYPE ssfcrescl,
        lw_content            TYPE soli.

  DATA: gv_fname        TYPE rs38l_fnam,       "Fucntion Module
        gv_subject      TYPE so_obj_des,
        gv_title        TYPE so_obj_des,
        lv_transfer_bin TYPE sx_boolean,
        lv_len          TYPE so_obj_len.

  DATA: li_otf         TYPE TABLE OF itcoo,
        li_pdf_tab     TYPE TABLE OF tline,
        li_content_txt TYPE soli_tab,
        li_content_hex TYPE solix_tab,
        li_objhead     TYPE soli_tab,
        lw_otf         TYPE itcoo,
        gi_main_text   TYPE bcsy_text.

  lt_otf[] = wl_job_output_info-otfdata[].


  CALL FUNCTION 'CONVERT_OTF'
    EXPORTING
      format                = 'PDF'
    IMPORTING
*     bin_filesize          = lv_bin_filesize
      bin_file              = lv_bin_xstr
    TABLES
      otf                   = lt_otf
      lines                 = lt_pdf_tab
    EXCEPTIONS
      err_max_linewidth     = 1
      err_format            = 2
      err_conv_not_possible = 3
      OTHERS                = 4.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


  REFRESH li_content_txt.


  LOOP AT lt_otf  INTO  lw_otf.
    CLEAR lw_content.
    CONCATENATE lw_otf-tdprintcom lw_otf-tdprintpar
    INTO lw_content.
    APPEND lw_content TO li_content_txt.
  ENDLOOP.

  REFRESH : li_content_hex,
  li_objhead.

  CLEAR : lv_transfer_bin,
  lv_len.


  CALL FUNCTION 'SX_OBJECT_CONVERT_OTF_PDF'
    EXPORTING
      format_src      = 'OTF'
      format_dst      = 'PDF'
    CHANGING
      transfer_bin    = lv_transfer_bin
      content_txt     = li_content_txt
      content_bin     = li_content_hex
      objhead         = li_objhead
      len             = lv_len
    EXCEPTIONS
      err_conv_failed = 1
      OTHERS          = 2.


  SELECT SINGLE
  fdoc~docnum, fdoc~printd, fdoc~parvw, fdoc~parid,
  kna1~kunnr, kna1~name1, kna1~ort01, kna1~regio, kna1~adrnr,
  adr6~addrnumber, adr6~persnumber, adr6~date_from, adr6~consnumber, adr6~smtp_addr
      FROM j_1bnfdoc AS fdoc
      INNER JOIN kna1 AS kna1 ON kna1~kunnr      = fdoc~parid
      INNER JOIN adr6 AS adr6 ON adr6~addrnumber = kna1~adrnr
      INTO @DATA(ls_inner)
      WHERE fdoc~docnum = @wk_header-docnum
        AND adr6~smtp_addr <> @space.

  IF ls_inner-smtp_addr IS NOT INITIAL." AND ls_inner-printd IS INITIAL.

    DATA: ls_nfe_active TYPE j_1b_nfe_access_key.

    SELECT SINGLE regio nfyear nfmonth stcd1 model serie nfnum9 docnum9 cdv
       FROM j_1bnfe_active
       INTO CORRESPONDING FIELDS OF ls_nfe_active
       WHERE docnum = wk_header-docnum.

    v_email = ls_inner-smtp_addr.


* Get the spool data.
    CALL FUNCTION 'RSPO_RETURN_SPOOLJOB'
      EXPORTING
        rqident              = v_spool
        first_line           = 1
      IMPORTING
        real_type            = real_type
        sp_lang              = sp_lang
      TABLES
        buffer               = ti_buffer
      EXCEPTIONS
        no_such_job          = 1
        job_contains_no_data = 2
        selection_empty      = 3
        no_permission        = 4
        can_not_access       = 5
        read_error           = 6
        type_no_match        = 7
        OTHERS               = 8.

    REFRESH: ti_txmail, ti_plist, ti_rec_tab.
    CLEAR:   v_name.

    DATA rq       TYPE tsp01.
    DATA bin_size TYPE so_obj_len.
    DATA dummy    TYPE TABLE OF rspoattr.


    CONCATENATE 'Envio do XML da NF-e' ls_nfe_active INTO document_data-obj_descr SEPARATED BY space.

    PERFORM f_send_xml_cl_bcs USING lv_xml_xstring lv_bin_xstr ls_inner-smtp_addr document_data-obj_descr
          .


    """""""""""""""""""""""""""""""""""""""""""""""""""""
* Subject.
    PACK wk_header-docnum TO v_docnum_c.
    CONDENSE v_docnum_c.





    v_txmail = 'Este é um e-mail automático do sistema. Favor não respondê-lo'.
    APPEND v_txmail TO ti_txmail.
    v_txmail = 'Em anexo você está recebendo o arquivo PDF da Nota Fiscal Eletrônica (NF-e).'.
    APPEND v_txmail TO ti_txmail.
    v_txmail = 'Este arquivo deve ser armazenado pelo prazo estabelecido na legislação tributária vigente.'.
    APPEND v_txmail TO ti_txmail.
    v_txmail = 'Para verificações de autenticidade, acessar o site nacional da NF-e,'.
    APPEND v_txmail TO ti_txmail.
    CONCATENATE 'informando a chave:' ls_nfe_active INTO v_txmail SEPARATED BY space.
    APPEND v_txmail TO ti_txmail.


    DESCRIBE TABLE ti_txmail LINES  ti_plist-body_num.
    READ TABLE ti_txmail INDEX  ti_plist-body_num.
    document_data-doc_size = (  ti_plist-body_num - 1 ) * 255 + strlen( ti_txmail ).

* Fill the fields of the packing_list for the main document:
    CLEAR  ti_plist-transf_bin.

* The document needs no header (head_num = 0)
    ti_plist-head_start = 1.
    ti_plist-head_num = 0.

* Body
    ti_plist-body_start = 1.
    ti_plist-doc_type = 'RAW'.
    APPEND  ti_plist.

* Prepare the ata.
    ti_plist-transf_bin = 'X'.
    ti_plist-head_start = 0.
    ti_plist-head_num = 0.
    ti_plist-body_start = 0.
    ti_plist-body_num = 0.
    ti_plist-doc_type = 'RAW'.
    ti_plist-obj_descr = wk_header-docnum.
    ti_plist-transf_bin = 'X'.
    ti_plist-head_start = 0.
    ti_plist-head_num = 0.
    ti_plist-body_start = 1.

*    DESCRIBE TABLE ti_buffer LINES  ti_plist-body_num.
*
*    ti_plist-doc_type = real_type.
** Get the size.
*    READ TABLE ti_buffer ASSIGNING FIELD-SYMBOL(<ti_buffer>) INDEX  ti_plist-body_num.
*
*    ti_plist-doc_size = (  ti_plist-body_num - 1 ) * line_size
*
*   + strlen( <ti_buffer> ).
*
*    APPEND  ti_plist.

************************************************************************************
*
    DATA v_size TYPE i.
    CLEAR: ti_plist, line_size.
    LOOP AT ti_buffer_xml ASSIGNING FIELD-SYMBOL(<fs_buffer_xml>).

      APPEND <fs_buffer_xml> TO ti_buffer.
    ENDLOOP.
    ti_plist-body_num   = v_size.

* Mail pack do anexo do e-mail

    DESCRIBE TABLE ti_buffer_xml LINES v_size.
    READ TABLE     ti_buffer_xml ASSIGNING <fs_buffer_xml> INDEX v_size.
*
*************************
*
*
*
** Get the size.
*
    ti_plist-doc_size = (  ti_plist-body_num - 1 ) * line_size

   + strlen( <fs_buffer_xml> ).

*
**************************
*
*  SPLIT wa_file-filename AT '.' INTO v_file v_extend.

    ti_plist-obj_name   = 'ANEXO XML'.
    ti_plist-obj_descr  = wk_header-docnum.
    ti_plist-doc_type   = 'xml'.
    ti_plist-transf_bin = 'X'.
    ti_plist-head_start = 1.
    ti_plist-head_num   = 1.
    ti_plist-body_start = 1.
    ti_plist-doc_size   = l_output_length.
    APPEND ti_plist.
    CLEAR: v_size.
*
************************************************************************************

* Move the receiver address.
    MOVE: ls_inner-smtp_addr TO ti_rec_tab-receiver,
      'U' TO ti_rec_tab-rec_type.
    APPEND ti_rec_tab.

    IF NOT sp_lang IS INITIAL.
      document_data-obj_langu = sp_lang.
    ELSE.
      document_data-obj_langu = sy-langu.
    ENDIF.

    v_name = sy-uname.

*    CALL FUNCTION 'SO_DOCUMENT_SEND_API1'
*      EXPORTING
*        document_data              = document_data
*        sender_address             = v_name
*        sender_address_type        = 'B'
*      TABLES
*        packing_list               = ti_plist
*        contents_bin               = ti_buffer
*        contents_txt               = ti_txmail
*        receivers                  = ti_rec_tab
*      EXCEPTIONS
*        too_many_receivers         = 1
*        document_not_sent          = 2
*        document_type_not_exist    = 3
*        operation_no_authorization = 4
*        parameter_error            = 5
*        x_error                    = 6
*        enqueue_error              = 7
*        OTHERS                     = 8.

    CASE sy-subrc.
      WHEN 0.
        v_message = 'Email enviado'.
        COMMIT WORK.
      WHEN 1.
        v_message = 'Erro email - Muitos destinatários, sem autorização'.
*      PERFORM grava_log USING v_message p_pes_cod p_mobile_name p_smtp_addr.
      WHEN 2.
        v_message = 'Erro email - O e-mail não foi enviado'.
*      PERFORM grava_log USING v_message p_pes_cod p_mobile_name p_smtp_addr.
      WHEN 3.
        v_message = 'Erro email - O tipo de e-mail ou anexo não existe'.
*      PERFORM grava_log USING v_message p_pes_cod p_mobile_name p_smtp_addr.
      WHEN 4.
        v_message = 'Erro email - Sem autorização para enviar/criar'.
*      PERFORM grava_log USING v_message p_pes_cod p_mobile_name p_smtp_addr.
      WHEN 5.
        v_message = 'Erro email - Combinação inválida de valores dos parâmetros'.
*      PERFORM grava_log USING v_message p_pes_cod p_mobile_name p_smtp_addr.
      WHEN 6.
        v_message = 'Erro email - Erro interno ou base de dados inconsistente'.
*      PERFORM grava_log USING v_message p_pes_cod p_mobile_name p_smtp_addr.
      WHEN 7.
        v_message = 'Erro email - Bloqueios requeridos não puderam ser definidos'.
*      PERFORM grava_log USING v_message p_pes_cod p_mobile_name p_smtp_addr.
      WHEN OTHERS.
        v_message = 'Erro email - Erro indefinido'.
*      PERFORM grava_log USING v_message p_pes_cod p_mobile_name p_smtp_addr.
    ENDCASE.


  ENDIF.


ENDFORM.                    "call_smartform
*&---------------------------------------------------------------------*
*& Form F_send_xml_CL_BCS
*&---------------------------------------------------------------------*

FORM f_send_xml_cl_bcs  USING p_lv_xml_xstring TYPE xstring
                              p_lv_pdf_xstring TYPE xstring
                              gc_email_to TYPE adr6-smtp_addr
                              p_obj_descr TYPE char_50.

  CONSTANTS:
    gc_type_raw        TYPE so_obj_tp VALUE 'RAW', " Tipo do e-mail
    gc_att_type_xml    TYPE soodk-objtp VALUE 'XML', " Tipo do anexo XML
    gc_att_type_pdf    TYPE soodk-objtp VALUE 'PDF', " Tipo do anexo PDF
    gc_att_subject_xml TYPE sood-objdes VALUE 'Document in XML', " Título do anexo XML
    gc_att_subject_pdf TYPE sood-objdes VALUE 'Document in PDF'. " Título do anexo PDF

  DATA:
    gc_subject        TYPE so_obj_des,
    gt_text           TYPE soli_tab, " Tabela que contém o texto do corpo do e-mail
    gt_attachment_hex TYPE solix_tab, " Tabela para o conteúdo do anexo XML
    gt_pdf_attachment TYPE solix_tab, " Tabela para o conteúdo do anexo PDF
    gv_sent_to_all    TYPE os_boolean, " Recebe a informação se o e-mail foi enviado
    gv_error_message  TYPE string, " Usado para pegar a mensagem de erro
    lv_xml_aux        TYPE string,
    lv_length         TYPE char12,
    go_send_request   TYPE REF TO cl_bcs, " Objeto do e-mail
    go_recipient      TYPE REF TO if_recipient_bcs, " Destinatário do e-mail
    go_sender         TYPE REF TO cl_sapuser_bcs, " Quem está enviando o e-mail
    go_document       TYPE REF TO cl_document_bcs, " Corpo do e-mail
    gx_bcs_exception  TYPE REF TO cx_bcs. " Exceção do BCS

  DATA     ti_buffer_aux     TYPE  soli_tab.

  TRY.

      gc_subject = p_obj_descr.


      " Criar requisição de envio persistente
      go_send_request = cl_bcs=>create_persistent( ).

      " Definir remetente
      go_sender = cl_sapuser_bcs=>create( sy-uname ).
      go_send_request->set_sender( i_sender = go_sender ).

      " Criar o destinatário e adicioná-lo à requisição
      go_recipient = cl_cam_address_bcs=>create_internet_address( gc_email_to ).
      go_send_request->add_recipient(
        EXPORTING
          i_recipient = go_recipient
          i_express   = abap_true
      ).

      " Adicionar o XML ao corpo do e-mail
      CLEAR gt_text.
      APPEND 'Segue em anexo os documentos solicitados.' TO gt_text.
      APPEND 'Este é um e-mail automático do sistema. Favor não respondê-lo' TO gt_text.
      APPEND 'Em anexo você está recebendo o arquivo PDF da Nota Fiscal Eletrônica (NF-e).' TO gt_text.
      APPEND 'Este arquivo deve ser armazenado pelo prazo estabelecido na legislação tributária vigente.' TO gt_text.
      APPEND 'Para verificações de autenticidade, acessar o site nacional da NF-e,' TO gt_text.


      " Criar o documento com o texto do corpo do e-mail
      go_document = cl_document_bcs=>create_document(
        i_type    = gc_type_raw
        i_text    = gt_text
        i_subject = gc_subject ). " Assunto do e-mail

      " Converter XML XSTRING para formato HEX (solix_tab)
      CALL METHOD cl_bcs_convert=>xstring_to_solix
        EXPORTING
          iv_xstring = p_lv_xml_xstring
        RECEIVING
          et_solix   = gt_attachment_hex.

      " Anexar o arquivo XML
      go_document->add_attachment(
        EXPORTING
          i_attachment_type    = gc_att_type_xml
          i_attachment_subject = gc_att_subject_xml
          i_att_content_hex    = gt_attachment_hex
      ).


      " Converter PDF XSTRING para formato HEX (solix_tab)
      CALL METHOD cl_bcs_convert=>xstring_to_solix
        EXPORTING
          iv_xstring = p_lv_pdf_xstring
        RECEIVING
          et_solix   = gt_pdf_attachment.


      " Anexar o arquivo PDF
      go_document->add_attachment(
        EXPORTING
          i_attachment_type    = gc_att_type_pdf
          i_attachment_subject = gc_att_subject_pdf
*         i_attachment_size    = p_pdf_size
          i_att_content_hex    = gt_pdf_attachment
      ).

      " Definir o documento para a requisição de envio
      go_send_request->set_document( go_document ).

      " Enviar o e-mail
      gv_sent_to_all = go_send_request->send( i_with_error_screen = abap_true ).

*      IF gv_sent_to_all = abap_true.
*        MESSAGE 'Email enviado com sucesso!'.
*      ENDIF.

      " Commit para garantir que o e-mail seja enviado
      COMMIT WORK.

    CATCH cx_bcs INTO gx_bcs_exception.
      gv_error_message = gx_bcs_exception->get_text( ).
      WRITE gv_error_message. " Mostrar mensagem de erro

  ENDTRY.

ENDFORM.



FORM envia_nfe_danfe_aux USING i_docnum TYPE j_1bdocnum.

ENDFORM.