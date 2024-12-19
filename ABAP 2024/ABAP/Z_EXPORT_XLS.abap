*&---------------------------------------------------------------------*
*& Report Z_EXPORT_XLS
*&---------------------------------------------------------------------*s
*&
*&---------------------------------------------------------------------*
REPORT z_export_xls.


*----------------------------------------------------------------------*
*                                                                      *
*----------------------------------------------------------------------*
* Consultoria ...:                                                     *
* Responsável ...: Douglas Gomes                                       *
* Solicitante ...:                                                     *
* Data desenv ...:                                                     *
* Objetivo    ...:                                                     *
*                                                                      *
* Transacao   ...:                                                     *
*----------------------------------------------------------------------*
*                         .::MODIFICAÇÃO::.                            *
*----------------------------------------------------------------------*
* Data.......:                                                         *
* Request....:                                                         *
* Responsável:                                                         *
* Solicitante:                                                         *
* Objetivo...:                                                         *
*----------------------------------------------------------------------*
*
TABLES: acdoca, t001.
*----------------------------------------------------------------------*
* TYPE-POOLS
*----------------------------------------------------------------------*
TYPE-POOLS: slis, truxs, vrm, abap.


TYPES: BEGIN OF gt_data_type,
         s_compy  TYPE Z_FI_I_GLAccountLineItem-s_compy,
         s_bussr  TYPE Z_FI_I_GLAccountLineItem-s_bussr,
         s_psdat  TYPE Z_FI_I_GLAccountLineItem-s_psdat,
         s_accdc  TYPE Z_FI_I_GLAccountLineItem-s_accdc,
         s_glact  TYPE Z_FI_I_GLAccountLineItem-s_glact,
         s_glacln TYPE Z_FI_I_GLAccountLineItem-s_glacln,
         s_doctxt TYPE Z_FI_I_GLAccountLineItem-s_doctxt,
         s_amincc TYPE z_fi_i_glaccountlineitem-s_amincc,
         s_comcr  TYPE z_fi_i_glaccountlineitem-s_comcr,
         s_amtgc  TYPE z_fi_i_glaccountlineitem-s_amtgc,
         s_glocr  TYPE z_fi_i_glaccountlineitem-s_glocr,
         s_amttr  TYPE z_fi_i_glaccountlineitem-s_amttr,
         s_trncr  TYPE z_fi_i_glaccountlineitem-s_trncr,
         s_acdoct TYPE z_fi_i_glaccountlineitem-s_acdoct,
         s_postk  TYPE z_fi_i_glaccountlineitem-s_postk,
         s_partb  TYPE z_fi_i_glaccountlineitem-s_partb,
         s_profct TYPE z_fi_i_glaccountlineitem-s_profct,
         s_costc  TYPE z_fi_i_glaccountlineitem-s_costc,
         s_suppl  TYPE z_fi_i_glaccountlineitem-s_suppl,
         s_nsupl  TYPE z_fi_i_glaccountlineitem-s_nsupl,
         s_stblg  TYPE z_fi_i_glaccountlineitem-s_stblg,
         s_offac  TYPE z_fi_i_glaccountlineitem-s_offac,
         s_acdcbu TYPE z_fi_i_glaccountlineitem-s_acdcbu,
         s_cpudt  TYPE z_fi_i_glaccountlineitem-s_cpudt,
         s_clerdt TYPE z_fi_i_glaccountlineitem-s_clerdt,
         s_clrac  TYPE z_fi_i_glaccountlineitem-s_clrac,
         s_ordid  TYPE z_fi_i_glaccountlineitem-s_ordid,
         s_offat  TYPE z_fi_i_glaccountlineitem-s_offat,
         s_conta  TYPE z_fi_i_glaccountlineitem-s_conta,


       END OF gt_data_type.


TYPES: BEGIN OF abap_compdescr,
         length    TYPE i,
         decimals  TYPE i,
         type_kind TYPE abap_typekind,
         name      TYPE abap_compname,
       END OF abap_compdescr.

TYPES:
  BEGIN OF ty_range,
    sign   TYPE char1,
    option TYPE char2,
    low    TYPE string,
    high   TYPE string,
  END OF ty_range.

DATA: r_filter TYPE RANGE OF ty_range.



*----------------------------------------------------------------------*
* Definição de Constantes
*----------------------------------------------------------------------*

CONSTANTS:
            c_msg_erro(26)  TYPE c VALUE 'Não ha registros'.


**********************************************************************
* Declaração de Tabelas internas
**********************************************************************
DATA:
  gt_data    TYPE TABLE OF gt_data_type,
  gt_comp    TYPE TABLE OF abap_compdescr,
  gs_data    TYPE acdoca,
  lv_numb    TYPE p,
  gs_xls_aux TYPE zexcel_s_export_xls.

**********************************************************************
* Declaração de Workáreas
**********************************************************************
DATA:
  wa_fieldcat TYPE lvc_s_fcat,
  wa_layout   TYPE lvc_s_layo.
*
**********************************************************************
* Declaração de Workáreas
**********************************************************************
DATA:
  gt_fieldcat   TYPE slis_t_fieldcat_alv,
  gs_fieldcat   TYPE slis_fieldcat_alv,
  gs_layout     TYPE slis_layout_alv,
  gs_layout_log TYPE slis_layout_alv,
  gt_event      TYPE slis_t_event,
  gt_listtop    TYPE slis_t_listheader,
  gs_variant    LIKE disvariant,
  lv_date       TYPE string.


RANGES: r_ledger  FOR acdoca-rldnr,
        r_compy  FOR acdoca-rbukrs,
        r_glact  FOR acdoca-racct,
        r_psdat  FOR acdoca-sgtxt,
        r_stats  FOR acdoca-sgtxt,
        r_PostK  FOR acdoca-bschl,
        r_asingr FOR acdoca-zuonr,
        r_acdoct FOR acdoca-blart,
        r_amincc FOR acdoca-hsl,
        r_txcode FOR acdoca-mwskz,
        r_clerdt FOR acdoca-augdt,
        r_profct FOR acdoca-prctr,
        r_segmt  FOR acdoca-segment,
        r_doctxt FOR acdoca-sgtxt,

        r_conta  FOR acdoca-rmvct,
        r_fintr  FOR acdoca-bttype,
        r_bustr  FOR acdoca-vrgng,
        r_cobtr  FOR acdoca-awtyp,
        r_refdt  FOR acdoca-awsys,
        r_logsy  FOR acdoca-aworg,
        r_refdc  FOR acdoca-awref,
        r_refdo  FOR acdoca-awitem,
        r_refdi  FOR acdoca-awitgrp,
        r_refdg  FOR acdoca-subta,
        r_trxsi  FOR acdoca-xreversing,
        r_isrev  FOR acdoca-xreversed,
        r_rvref  FOR acdoca-aworg_rev,
        r_rvdoc  FOR acdoca-awref_rev,
        r_isset  FOR acdoca-xsettling,
        r_isstl  FOR acdoca-xsettled,
        r_prdct  FOR acdoca-prec_awtyp,
        r_prdco  FOR acdoca-prec_aworg,
        r_prddo  FOR acdoca-prec_awref,
        r_prddi  FOR acdoca-prec_awitem,
        r_prjcc  FOR acdoca-prec_bukrs,
        r_prjfy  FOR acdoca-prec_gjahr,
        r_prdje  FOR acdoca-prec_belnr,
        r_prdji  FOR acdoca-prec_docln,
        r_srdct  FOR acdoca-src_awtyp,
        r_srlog  FOR acdoca-src_awsys.
*r_offac  for acdoca-gkont.

DATA: r_fdc1   TYPE RANGE OF ty_range,
      r_amtfd1 TYPE RANGE OF ty_range,
      r_fdc2   TYPE RANGE OF ty_range,
      r_amtfd2 TYPE RANGE OF ty_range,
      r_fdc3   TYPE RANGE OF ty_range,
      r_amtfd3 TYPE RANGE OF ty_range,
      r_fdc4   TYPE RANGE OF ty_range,
      r_amtfd4 TYPE RANGE OF ty_range,
      r_fdc5   TYPE RANGE OF ty_range,
      r_amtfd5 TYPE RANGE OF ty_range,
      r_fdc6   TYPE RANGE OF ty_range,
      r_amtfd6 TYPE RANGE OF ty_range,
      r_fdc7   TYPE RANGE OF ty_range,
      r_amtfd7 TYPE RANGE OF ty_range,
      r_fdc8   TYPE RANGE OF ty_range,
      r_amtfd8 TYPE RANGE OF ty_range,
      r_famtg  TYPE RANGE OF ty_range,
      r_grfag  TYPE RANGE OF ty_range,
      r_pcfag  TYPE RANGE OF ty_range,
      r_famtc  TYPE RANGE OF ty_range,
      r_tpvag  TYPE RANGE OF ty_range,
      r_grtpv  TYPE RANGE OF ty_range,
      r_pctpv  TYPE RANGE OF ty_range,
      r_fpvag  TYPE RANGE OF ty_range,
      r_grfpv  TYPE RANGE OF ty_range,
      r_pcfpv  TYPE RANGE OF ty_range,
      r_conoc  TYPE RANGE OF ty_range,
      r_amtoc  TYPE RANGE OF ty_range,
      r_granc  TYPE RANGE OF ty_range,
      r_amtgr  TYPE RANGE OF ty_range,
      r_baseu  TYPE RANGE OF ty_range,
      r_qty    TYPE RANGE OF ty_range,
      r_fqty   TYPE RANGE OF ty_range,
      r_csuni  TYPE RANGE OF ty_range,
      r_valq   TYPE RANGE OF ty_range,
      r_valf   TYPE RANGE OF ty_range,
      r_refqu  TYPE RANGE OF ty_range,
      r_refq   TYPE RANGE OF ty_range,
      r_addq1u TYPE RANGE OF ty_range,
      r_addq1  TYPE RANGE OF ty_range,
      r_addq2u TYPE RANGE OF ty_range,
      r_addq2  TYPE RANGE OF ty_range,
      r_addq3u TYPE RANGE OF ty_range,
      r_addq3  TYPE RANGE OF ty_range,
      r_dbcrd  TYPE RANGE OF ty_range,
      r_fispe  TYPE RANGE OF ty_range,
      r_fisyv  TYPE RANGE OF ty_range,
      r_postd  TYPE RANGE OF ty_range,
      r_docdt  TYPE RANGE OF ty_range,
      r_acdit  TYPE RANGE OF ty_range,
      r_acdcg  TYPE RANGE OF ty_range,
      r_trxdt  TYPE RANGE OF ty_range,
      r_subat  TYPE RANGE OF ty_range,
      r_acdcbu TYPE RANGE OF ty_range,
      r_lchdt  TYPE RANGE OF ty_range,
      r_crtdt  TYPE RANGE OF ty_range,
      r_crdte  TYPE RANGE OF ty_range,
      r_elipc  TYPE RANGE OF ty_range,
      r_orgot  TYPE RANGE OF ty_range,
      r_gact   TYPE RANGE OF ty_range,
      r_altga  TYPE RANGE OF ty_range,
      r_ctcoa  TYPE RANGE OF ty_range,
      r_itmspl TYPE RANGE OF ty_range,
      r_invre  TYPE RANGE OF ty_range,
      r_invfy  TYPE RANGE OF ty_range,
      r_fodt   TYPE RANGE OF ty_range,
      r_invit  TYPE RANGE OF ty_range,

      r_refpo  TYPE RANGE OF ty_range,
      r_purchd TYPE RANGE OF ty_range,
      r_purchi TYPE RANGE OF ty_range,
      r_acctn  TYPE RANGE OF ty_range,
      r_saled  TYPE RANGE OF ty_range,
      r_salei  TYPE RANGE OF ty_range,
      r_prod   TYPE RANGE OF ty_range,
      r_plant  TYPE RANGE OF ty_range,
      r_suppl  TYPE RANGE OF ty_range,
      r_cust   TYPE RANGE OF ty_range.



DATA    r_psdatf TYPE RANGE OF sy-datum.





**********************************************************************
* Tela de seleção
**********************************************************************
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.


  PARAMETERS:

    ledger   TYPE string,
    s_ledger TYPE string,
    s_compy  TYPE string,
    s_status TYPE string,
    s_glact  TYPE string,
    s_psdat  TYPE string,

    s_PostK  TYPE string,
    s_asingr TYPE string,
    s_acdoct TYPE string,
    s_amincc TYPE string,
    s_txcode TYPE string,
    s_clerdt TYPE string,
    s_profct TYPE string,
    s_segmt  TYPE string,
    s_doctxt TYPE string,

    s_conta  TYPE string,
    s_fintr  TYPE string,
    s_bustr  TYPE string,
    s_cobtr  TYPE string,
    s_refdt  TYPE string,
    s_logsy  TYPE string,
    s_refdc  TYPE string,
    s_refdo  TYPE string,
    s_refdi  TYPE string,
    s_refdg  TYPE string,
    s_trxsi  TYPE string,
    s_isrev  TYPE string,
    s_rvref  TYPE string,
    s_rvdoc  TYPE string,
    s_isset  TYPE string,
    s_isstl  TYPE string,
    s_prdct  TYPE string,
    s_prdco  TYPE string,
    s_prddo  TYPE string,
    s_prddi  TYPE string,
    s_prjcc  TYPE string,
    s_prjfy  TYPE string,
    s_prdje  TYPE string,
    s_prdji  TYPE string,
    s_srdct  TYPE string,
    s_srlog  TYPE string,

***************************************
***************************************

    s_srdoc  TYPE string,
    s_srdci  TYPE string,
    s_srdcs  TYPE string,
    s_iscom  TYPE string,
    s_jriei  TYPE string,
    s_jpecr  TYPE string,
    s_orgch  TYPE string,
    s_costc  TYPE string,
    s_funca  TYPE string,
    s_bussr  TYPE string,
    s_partc  TYPE string,
    s_partp  TYPE string,
    s_partf  TYPE string,
    s_partb  TYPE string,
    s_parts  TYPE string,
    s_baltr  TYPE string,
    s_amtbt  TYPE string,
    s_trncr  TYPE string,
    s_amttr  TYPE string,
    s_comcr  TYPE string,
    s_glocr  TYPE string,
    s_amtgc  TYPE string,

    s_fdc1   TYPE string,
    s_amtfd1 TYPE string,
    s_fdc2   TYPE string,
    s_amtfd2 TYPE string,
    s_fdc3   TYPE string,
    s_amtfd3 TYPE string,
    s_fdc4   TYPE string,
    s_amtfd4 TYPE string,
    s_fdc5   TYPE string,
    s_amtfd5 TYPE string,
    s_fdc6   TYPE string,
    s_amtfd6 TYPE string,
    s_fdc7   TYPE string,
    s_amtfd7 TYPE string,
    s_fdc8   TYPE string,
    s_amtfd8 TYPE string,
    s_famtg  TYPE string,
    s_grfag  TYPE string,
    s_pcfag  TYPE string,
    s_famtc  TYPE string,
    s_tpvag  TYPE string,
    s_grtpv  TYPE string,
    s_pctpv  TYPE string,
    s_fpvag  TYPE string,
    s_grfpv  TYPE string,
    s_pcfpv  TYPE string,
    s_conoc  TYPE string,
    s_amtoc  TYPE string,
    s_granc  TYPE string,
    s_amtgr  TYPE string,
    s_baseu  TYPE string,
    s_qty    TYPE string,
    s_fqty   TYPE string,
    s_csuni  TYPE string,
    s_valq   TYPE string,
    s_valf   TYPE string,
    s_refqu  TYPE string,
    s_refq   TYPE string,
    s_addq1u TYPE string,
    s_addq1  TYPE string,
    s_addq2u TYPE string,
    s_addq2  TYPE string,
    s_addq3u TYPE string,
    s_addq3  TYPE string,
    s_dbcrd  TYPE string,
    s_fispe  TYPE string,
    s_fisyv  TYPE string,
    s_postd  TYPE string,
    s_docdt  TYPE string,
    s_acdit  TYPE string,
    s_acdcg  TYPE string,
    s_trxdt  TYPE string,
    s_subat  TYPE string,
    s_acdcbu TYPE string,
    s_lchdt  TYPE string,
    s_crtdt  TYPE string,
    s_crdte  TYPE string,
    s_elipc  TYPE string,
    s_orgot  TYPE string,
    s_gact   TYPE string,
    s_altga  TYPE string,
    s_ctcoa  TYPE string,
    s_itmspl TYPE string,
    s_invre  TYPE string,
    s_invfy  TYPE string,
    s_fodt   TYPE string,
    s_invit  TYPE string,

    s_refpo  TYPE string,
    s_purchd TYPE string,
    s_purchi TYPE string,
    s_acctn  TYPE string,
    s_saled  TYPE string,
    s_salei  TYPE string,
    s_prod   TYPE string,
    s_plant  TYPE string,
    s_suppl  TYPE string,
    s_cust   TYPE string.


SELECTION-SCREEN END OF BLOCK b1.

" Operador para rbukrs
* ******************************************************************* *


**********************************************************************
*Início Codificação
**********************************************************************
START-OF-SELECTION.
  PERFORM:
  valida_range,
  zf_ler_tabela.

END-OF-SELECTION.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CASE sy-ucomm.

    WHEN 'BACK' OR 'EXIT'.
      LEAVE TO SCREEN 0.
    WHEN 'CANC'.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*&      Form  zf_ler_tabela
*&---------------------------------------------------------------------*
FORM zf_ler_tabela.

  DATA:
    lt_tb               TYPE TABLE OF zme_cabec_xls,
    ls_tb               TYPE zme_cabec_xls,
    lt_line             TYPE TABLE OF string,
    ls_line             TYPE string,
    lv_file_table       TYPE string,
    lv_rows             TYPE i,
    lv_offset           TYPE i,
    lv_tabix            TYPE sy-tabix,
    lv_file_line        TYPE string,
    lv_aux_char         TYPE numeric12,
    lv_aux              TYPE string,
    lv_valor            TYPE string,
    lv_field_value(200),
    ocl_cl_table        TYPE REF TO cl_abap_structdescr,
    lv_field            TYPE abap_compdescr,
    lv_is_key           TYPE flag,
    lv_count_fields     TYPE i,
    lt_ddfields         TYPE ddfields.

  DATA: lv_data_format_low  TYPE char10,
        lv_data_format_high TYPE char10.

  DATA: lt_BusinessAreaText  TYPE TABLE OF I_BusinessAreaText,
        lt_OffsettingAccount TYPE TABLE OF I_OffsettingAccount,
        lt_ProfitCenterText  TYPE TABLE OF I_ProfitCenterText,
        lt_CostCenterText    TYPE TABLE OF I_CostCenterText,
        lt_CompanyCode       TYPE TABLE OF I_CompanyCode,

        lv_offsettingaccount TYPE i_offsettingaccount-offsettingaccount,
        lv_profitCenter      TYPE i_profitCenterText-profitCenter,
        lv_CostCenter        TYPE i_CostCenterText-CostCenter.



  FIELD-SYMBOLS:
    <line>  TYPE any,
    <field> TYPE any.

  s_ledger = ledger.

  PERFORM process_filter.
  PERFORM convert_date.


  SELECT s_compy,
         s_bussr,
         s_psdat,
         s_accdc,
         s_glact,
         s_glacln,
         s_doctxt,
         s_amincc,
         s_comcr,
         s_amtgc,
         s_glocr,
         s_amttr,
         s_trncr,
         s_acdoct,
         s_postk,
         s_partb,
         s_profct,
         s_costc,
         s_suppl,
         s_nsupl,
         s_stblg,
         s_offac,
         s_acdcbu,
         s_cpudt,
         s_clerdt,
         s_clrac,
         s_ordid,
         s_offat,
         s_conta

    FROM Z_FI_I_GLAccountLineItem
    INTO TABLE @gt_data
    WHERE s_ledger         IN @r_ledger
    AND   s_compy          IN @r_compy
    AND   s_glact          IN @r_glact
    AND   s_psdat          IN @r_psdatf


    AND s_amincc IN @r_amincc
    AND s_txcode IN @r_txcode
    AND s_clerdt IN @r_clerdt
    AND s_profct IN @r_profct
    AND s_doctxt IN @r_doctxt.


  IF sy-subrc = 0.

    SELECT *
      FROM I_CompanyCode
      INTO TABLE @lt_CompanyCode
      FOR ALL ENTRIES IN @gt_data
      WHERE  CompanyCode = @gt_data-s_compy.


    SELECT *
      FROM I_OffsettingAccount
      INTO TABLE @lt_OffsettingAccount
      FOR ALL ENTRIES IN @gt_data
      WHERE OffsettingAccount     = @gt_data-s_offac
        AND offsettingaccounttype = @gt_data-s_offat.


    SELECT *
      FROM I_BusinessAreaText
      INTO TABLE @lt_BusinessAreaText
      FOR ALL ENTRIES IN @gt_data
      WHERE  BusinessArea = @gt_data-s_bussr.


    SELECT *
      FROM I_ProfitCenterText
      INTO TABLE @lt_ProfitCenterText
      FOR ALL ENTRIES IN @gt_data
      WHERE  ControllingArea = @gt_data-s_conta
      AND    ProfitCenter    = @gt_data-s_profct.

    SELECT *
    FROM I_CostCenterText
    INTO TABLE @lt_CostCenterText
    FOR ALL ENTRIES IN @gt_data
    WHERE  ControllingArea = @gt_data-s_conta
    AND    CostCenter      = @gt_data-s_costc.


    PERFORM  f_insert_header TABLES lt_tb.

    IF lt_tb[] IS NOT INITIAL.
      DELETE ADJACENT DUPLICATES FROM lt_tb COMPARING ALL FIELDS.
      LOOP AT lt_tb ASSIGNING FIELD-SYMBOL(<fs_tb1>).
        CLEAR ls_line.
        CONCATENATE  <fs_tb1>-fieldname ';' <fs_tb1>-value ';' INTO ls_line.
        APPEND ls_line TO lt_line.
      ENDLOOP.
      ls_line = ';'.
      APPEND ls_line TO lt_line.
      CLEAR lt_tb[].
    ENDIF.


    IF r_stats[] IS NOT INITIAL.
      LOOP AT r_stats ASSIGNING FIELD-SYMBOL(<fs_stats>).
        ls_tb-fieldname = 'Status'.
        PERFORM f_insert_zmtetest TABLES lt_tb
        USING ls_tb-fieldname <fs_stats>-low <fs_stats>-high <fs_stats>-option.
      ENDLOOP.
    ENDIF.


    IF r_ledger[] IS NOT INITIAL.
      LOOP AT r_ledger ASSIGNING FIELD-SYMBOL(<fs_ledger>).
        ls_tb-fieldname = 'Ledger'.
        PERFORM f_insert_zmtetest TABLES lt_tb
        USING ls_tb-fieldname <fs_ledger>-low <fs_ledger>-high <fs_ledger>-option.
      ENDLOOP.
    ENDIF.

    IF R_compy[] IS NOT INITIAL.
      LOOP AT r_compy ASSIGNING FIELD-SYMBOL(<fs_compy>).
        ls_tb-fieldname = 'Empresa'.
        PERFORM f_insert_zmtetest TABLES lt_tb
        USING ls_tb-fieldname <fs_compy>-low <fs_compy>-high <fs_compy>-option.
      ENDLOOP.
    ENDIF.

    IF r_glact[] IS NOT INITIAL.
      LOOP AT r_glact ASSIGNING FIELD-SYMBOL(<fs_glact>).
        ls_tb-fieldname = 'Conta Razão'.
        PERFORM f_insert_zmtetest TABLES lt_tb
        USING ls_tb-fieldname <fs_glact>-low <fs_glact>-high <fs_glact>-option.
      ENDLOOP.
    ENDIF.



    IF r_Postk[] IS NOT INITIAL.
      LOOP AT r_Postk ASSIGNING FIELD-SYMBOL(<fs_Postk>).
        ls_tb-fieldname = 'Postk'.
        PERFORM f_insert_zmtetest TABLES lt_tb
        USING ls_tb-fieldname <fs_Postk>-low <fs_Postk>-high <fs_Postk>-option.
      ENDLOOP.
    ENDIF.

    IF r_asingr[] IS NOT INITIAL.
      LOOP AT r_asingr ASSIGNING FIELD-SYMBOL(<fs_asingr>).
        ls_tb-fieldname = 'asingr'.
        PERFORM f_insert_zmtetest TABLES lt_tb
        USING ls_tb-fieldname <fs_asingr>-low <fs_asingr>-high <fs_asingr>-option.
      ENDLOOP.
    ENDIF.

    IF r_acdoct[] IS NOT INITIAL.
      LOOP AT r_acdoct ASSIGNING FIELD-SYMBOL(<fs_acdoct>).
        ls_tb-fieldname = 'acdoct'.
        PERFORM f_insert_zmtetest TABLES lt_tb
        USING ls_tb-fieldname <fs_acdoct>-low <fs_acdoct>-high <fs_acdoct>-option.
      ENDLOOP.
    ENDIF.

    IF r_amincc[] IS NOT INITIAL.
      LOOP AT r_amincc ASSIGNING FIELD-SYMBOL(<fs_amincc>).
        ls_tb-fieldname = 'amincc'.
        PERFORM f_insert_zmtetest TABLES lt_tb
        USING ls_tb-fieldname <fs_amincc>-low <fs_amincc>-high <fs_amincc>-option.
      ENDLOOP.
    ENDIF.

    IF r_txcode[] IS NOT INITIAL.
      LOOP AT r_txcode ASSIGNING FIELD-SYMBOL(<fs_txcode>).
        ls_tb-fieldname = 'txcode'.
        PERFORM f_insert_zmtetest TABLES lt_tb
        USING ls_tb-fieldname <fs_txcode>-low <fs_txcode>-high <fs_txcode>-option.
      ENDLOOP.
    ENDIF.

    IF r_clerdt[] IS NOT INITIAL.
      LOOP AT r_clerdt ASSIGNING FIELD-SYMBOL(<fs_clerdt>).
        ls_tb-fieldname = 'clerdt'.
        PERFORM f_insert_zmtetest TABLES lt_tb
        USING ls_tb-fieldname <fs_clerdt>-low <fs_clerdt>-high <fs_clerdt>-option.
      ENDLOOP.
    ENDIF.

    IF r_profct[] IS NOT INITIAL.
      LOOP AT r_profct ASSIGNING FIELD-SYMBOL(<fs_profct>).
        ls_tb-fieldname = 'profct'.
        PERFORM f_insert_zmtetest TABLES lt_tb
        USING ls_tb-fieldname <fs_profct>-low <fs_profct>-high <fs_profct>-option.
      ENDLOOP.
    ENDIF.

    IF r_segmt[] IS NOT INITIAL.
      LOOP AT r_segmt ASSIGNING FIELD-SYMBOL(<fs_segmt>).
        ls_tb-fieldname = 'segmt'.
        PERFORM f_insert_zmtetest TABLES lt_tb
        USING ls_tb-fieldname <fs_segmt>-low <fs_segmt>-high <fs_segmt>-option.
      ENDLOOP.
    ENDIF.

    IF r_doctxt[] IS NOT INITIAL.
      LOOP AT r_doctxt ASSIGNING FIELD-SYMBOL(<fs_doctxt>).
        ls_tb-fieldname = 'doctxt'.
        PERFORM f_insert_zmtetest TABLES lt_tb
        USING ls_tb-fieldname <fs_doctxt>-low <fs_doctxt>-high <fs_doctxt>-option.
      ENDLOOP.
    ENDIF.

    IF r_psdatf[] IS NOT INITIAL.

      LOOP AT r_psdatf ASSIGNING FIELD-SYMBOL(<fs_psdat>).
        ls_tb-fieldname = 'Data aberto'.

        IF <fs_psdat>-low IS NOT INITIAL.
          WRITE <fs_psdat>-low TO lv_data_format_low.
          REPLACE ALL OCCURRENCES OF '.' IN lv_data_format_low WITH '/'.
        ENDIF.

        IF <fs_psdat>-high IS NOT INITIAL.
          WRITE <fs_psdat>-high TO lv_data_format_high.
          REPLACE ALL OCCURRENCES OF '.' IN lv_data_format_high WITH '/'.
        ENDIF.

        PERFORM f_insert_zmtetest TABLES lt_tb
        USING ls_tb-fieldname lv_data_format_low lv_data_format_high <fs_psdat>-option.
      ENDLOOP.

    ENDIF.


*****************************************************************************

    IF r_conta[] IS NOT INITIAL.
      LOOP AT r_conta ASSIGNING FIELD-SYMBOL(<fs_conta>).
        ls_tb-fieldname = 'conta'.
        PERFORM f_insert_zmtetest TABLES lt_tb
        USING ls_tb-fieldname <fs_conta>-low <fs_conta>-high <fs_conta>-option.
      ENDLOOP.
    ENDIF.
    IF r_fintr[] IS NOT INITIAL.
      LOOP AT r_fintr ASSIGNING FIELD-SYMBOL(<fs_fintr>).
        ls_tb-fieldname = 'fintr'.
        PERFORM f_insert_zmtetest TABLES lt_tb
        USING ls_tb-fieldname <fs_fintr>-low <fs_fintr>-high <fs_fintr>-option.
      ENDLOOP.
    ENDIF.
    IF r_bustr[] IS NOT INITIAL.
      LOOP AT r_bustr ASSIGNING FIELD-SYMBOL(<fs_bustr>).
        ls_tb-fieldname = 'bustr'.
        PERFORM f_insert_zmtetest TABLES lt_tb
        USING ls_tb-fieldname <fs_bustr>-low <fs_bustr>-high <fs_bustr>-option.
      ENDLOOP.
    ENDIF.
    IF r_cobtr[] IS NOT INITIAL.
      LOOP AT r_cobtr ASSIGNING FIELD-SYMBOL(<fs_cobtr>).
        ls_tb-fieldname = 'cobtr'.
        PERFORM f_insert_zmtetest TABLES lt_tb
        USING ls_tb-fieldname <fs_cobtr>-low <fs_cobtr>-high <fs_cobtr>-option.
      ENDLOOP.
    ENDIF.
    IF r_refdt[] IS NOT INITIAL.
      LOOP AT r_refdt ASSIGNING FIELD-SYMBOL(<fs_refdt>).
        ls_tb-fieldname = 'refdt'.
        PERFORM f_insert_zmtetest TABLES lt_tb
        USING ls_tb-fieldname <fs_refdt>-low <fs_refdt>-high <fs_refdt>-option.
      ENDLOOP.
    ENDIF.
    IF r_logsy[] IS NOT INITIAL.
      LOOP AT r_logsy ASSIGNING FIELD-SYMBOL(<fs_logsy>).
        ls_tb-fieldname = 'logsy'.
        PERFORM f_insert_zmtetest TABLES lt_tb
        USING ls_tb-fieldname <fs_logsy>-low <fs_logsy>-high <fs_logsy>-option.
      ENDLOOP.
    ENDIF.
    IF r_refdc[] IS NOT INITIAL.
      LOOP AT r_refdc ASSIGNING FIELD-SYMBOL(<fs_refdc>).
        ls_tb-fieldname = 'refdc'.
        PERFORM f_insert_zmtetest TABLES lt_tb
        USING ls_tb-fieldname <fs_refdc>-low <fs_refdc>-high <fs_refdc>-option.
      ENDLOOP.
    ENDIF.
    IF r_refdo[] IS NOT INITIAL.
      LOOP AT r_refdo ASSIGNING FIELD-SYMBOL(<fs_refdo>).
        ls_tb-fieldname = 'refdo'.
        PERFORM f_insert_zmtetest TABLES lt_tb
        USING ls_tb-fieldname <fs_refdo>-low <fs_refdo>-high <fs_refdo>-option.
      ENDLOOP.
    ENDIF.
    IF r_refdi[] IS NOT INITIAL.
      LOOP AT r_refdi ASSIGNING FIELD-SYMBOL(<fs_refdi>).
        ls_tb-fieldname = 'refdi'.
        PERFORM f_insert_zmtetest TABLES lt_tb
        USING ls_tb-fieldname <fs_refdi>-low <fs_refdi>-high <fs_refdi>-option.
      ENDLOOP.
    ENDIF.
    IF r_refdg[] IS NOT INITIAL.
      LOOP AT r_refdg ASSIGNING FIELD-SYMBOL(<fs_refdg>).
        ls_tb-fieldname = 'refdg'.
        PERFORM f_insert_zmtetest TABLES lt_tb
        USING ls_tb-fieldname <fs_refdg>-low <fs_refdg>-high <fs_refdg>-option.
      ENDLOOP.
    ENDIF.
    IF r_trxsi[] IS NOT INITIAL.
      LOOP AT r_trxsi ASSIGNING FIELD-SYMBOL(<fs_trxsi>).
        ls_tb-fieldname = 'trxsi'.
        PERFORM f_insert_zmtetest TABLES lt_tb
        USING ls_tb-fieldname <fs_trxsi>-low <fs_trxsi>-high <fs_trxsi>-option.
      ENDLOOP.
    ENDIF.
    IF r_isrev[] IS NOT INITIAL.
      LOOP AT r_isrev ASSIGNING FIELD-SYMBOL(<fs_isrev>).
        ls_tb-fieldname = 'isrev'.
        PERFORM f_insert_zmtetest TABLES lt_tb
        USING ls_tb-fieldname <fs_isrev>-low <fs_isrev>-high <fs_isrev>-option.
      ENDLOOP.
    ENDIF.
    IF r_rvref[] IS NOT INITIAL.
      LOOP AT r_rvref ASSIGNING FIELD-SYMBOL(<fs_rvref>).
        ls_tb-fieldname = 'rvref'.
        PERFORM f_insert_zmtetest TABLES lt_tb
        USING ls_tb-fieldname <fs_rvref>-low <fs_rvref>-high <fs_rvref>-option.
      ENDLOOP.
    ENDIF.
    IF r_rvdoc[] IS NOT INITIAL.
      LOOP AT r_rvdoc ASSIGNING FIELD-SYMBOL(<fs_rvdoc>).
        ls_tb-fieldname = 'rvdoc'.
        PERFORM f_insert_zmtetest TABLES lt_tb
        USING ls_tb-fieldname <fs_rvdoc>-low <fs_rvdoc>-high <fs_rvdoc>-option.
      ENDLOOP.
    ENDIF.
    IF r_isset[] IS NOT INITIAL.
      LOOP AT r_isset ASSIGNING FIELD-SYMBOL(<fs_isset>).
        ls_tb-fieldname = 'isset'.
        PERFORM f_insert_zmtetest TABLES lt_tb
        USING ls_tb-fieldname <fs_isset>-low <fs_isset>-high <fs_isset>-option.
      ENDLOOP.
    ENDIF.
    IF r_isstl[] IS NOT INITIAL.
      LOOP AT r_isstl ASSIGNING FIELD-SYMBOL(<fs_isstl>).
        ls_tb-fieldname = 'isstl'.
        PERFORM f_insert_zmtetest TABLES lt_tb
        USING ls_tb-fieldname <fs_isstl>-low <fs_isstl>-high <fs_isstl>-option.
      ENDLOOP.
    ENDIF.
    IF r_prdct[] IS NOT INITIAL.
      LOOP AT r_prdct ASSIGNING FIELD-SYMBOL(<fs_prdct>).
        ls_tb-fieldname = 'prdct'.
        PERFORM f_insert_zmtetest TABLES lt_tb
        USING ls_tb-fieldname <fs_prdct>-low <fs_prdct>-high <fs_prdct>-option.
      ENDLOOP.
    ENDIF.
    IF r_prdco[] IS NOT INITIAL.
      LOOP AT r_prdco ASSIGNING FIELD-SYMBOL(<fs_prdco>).
        ls_tb-fieldname = 'prdco'.
        PERFORM f_insert_zmtetest TABLES lt_tb
        USING ls_tb-fieldname <fs_prdco>-low <fs_prdco>-high <fs_prdco>-option.
      ENDLOOP.
    ENDIF.
    IF r_prddo[] IS NOT INITIAL.
      LOOP AT r_prddo ASSIGNING FIELD-SYMBOL(<fs_prddo>).
        ls_tb-fieldname = 'prddo'.
        PERFORM f_insert_zmtetest TABLES lt_tb
        USING ls_tb-fieldname <fs_prddo>-low <fs_prddo>-high <fs_prddo>-option.
      ENDLOOP.
    ENDIF.
    IF r_prddi[] IS NOT INITIAL.
      LOOP AT r_prddi ASSIGNING FIELD-SYMBOL(<fs_prddi>).
        ls_tb-fieldname = 'prddi'.
        PERFORM f_insert_zmtetest TABLES lt_tb
        USING ls_tb-fieldname <fs_prddi>-low <fs_prddi>-high <fs_prddi>-option.
      ENDLOOP.
    ENDIF.
    IF r_prjcc[] IS NOT INITIAL.
      LOOP AT r_prjcc ASSIGNING FIELD-SYMBOL(<fs_prjcc>).
        ls_tb-fieldname = 'prjcc'.
        PERFORM f_insert_zmtetest TABLES lt_tb
        USING ls_tb-fieldname <fs_prjcc>-low <fs_prjcc>-high <fs_prjcc>-option.
      ENDLOOP.
    ENDIF.
    IF r_prjfy[] IS NOT INITIAL.
      LOOP AT r_prjfy ASSIGNING FIELD-SYMBOL(<fs_prjfy>).
        ls_tb-fieldname = 'prjfy'.
        PERFORM f_insert_zmtetest TABLES lt_tb
        USING ls_tb-fieldname <fs_prjfy>-low <fs_prjfy>-high <fs_prjfy>-option.
      ENDLOOP.
    ENDIF.
    IF r_prdje[] IS NOT INITIAL.
      LOOP AT r_prdje ASSIGNING FIELD-SYMBOL(<fs_prdje>).
        ls_tb-fieldname = 'prdje'.
        PERFORM f_insert_zmtetest TABLES lt_tb
        USING ls_tb-fieldname <fs_prdje>-low <fs_prdje>-high <fs_prdje>-option.
      ENDLOOP.
    ENDIF.
    IF r_prdji[] IS NOT INITIAL.
      LOOP AT r_prdji ASSIGNING FIELD-SYMBOL(<fs_prdji>).
        ls_tb-fieldname = 'prdji'.
        PERFORM f_insert_zmtetest TABLES lt_tb
        USING ls_tb-fieldname <fs_prdji>-low <fs_prdji>-high <fs_prdji>-option.
      ENDLOOP.
    ENDIF.
    IF r_srdct[] IS NOT INITIAL.
      LOOP AT r_srdct ASSIGNING FIELD-SYMBOL(<fs_srdct>).
        ls_tb-fieldname = 'srdct'.
        PERFORM f_insert_zmtetest TABLES lt_tb
        USING ls_tb-fieldname <fs_srdct>-low <fs_srdct>-high <fs_srdct>-option.
      ENDLOOP.
    ENDIF.
    IF r_srlog[] IS NOT INITIAL.
      LOOP AT r_srlog ASSIGNING FIELD-SYMBOL(<fs_srlog>).
        ls_tb-fieldname = 'srlog'.
        PERFORM f_insert_zmtetest TABLES lt_tb
        USING ls_tb-fieldname <fs_srlog>-low <fs_srlog>-high <fs_srlog>-option.
      ENDLOOP.
    ENDIF.


*****************************************************************************

    DATA: lt_order         TYPE TABLE OF string,
          lt_columns       TYPE TABLE OF dd03vt,
          lt_final_columns TYPE TABLE OF dd03vt,
          ls_column        TYPE dd03vt.

    APPEND 'S_COMPY'  TO lt_order.
    APPEND 'S_BUSSR'  TO lt_order.
    APPEND 'S_PSDAT'  TO lt_order.
    APPEND 'S_ACCDC'  TO lt_order.
    APPEND 'S_GLACT'  TO lt_order.
    APPEND 'S_GLACLN' TO lt_order.
    APPEND 'S_DOCTXT' TO lt_order.
    APPEND 'S_AMINCC' TO lt_order.
    APPEND 'S_COMCR'  TO lt_order.
    APPEND 'S_AMTGC'  TO lt_order.
    APPEND 'S_GLOCR'  TO lt_order.
    APPEND 'S_AMTTR'  TO lt_order.
    APPEND 'S_TRNCR'  TO lt_order.
    APPEND 'S_ACDOCT' TO lt_order.
    APPEND 'S_POSTK'  TO lt_order.
    APPEND 'S_PARTB'  TO lt_order.
    APPEND 'S_PROFCT' TO lt_order.
    APPEND 'S_COSTC'  TO lt_order.
    APPEND 'S_SUPPL'  TO lt_order.
    APPEND 'S_NSUPL'  TO lt_order.
    APPEND 'S_STBLG'  TO lt_order.
    APPEND 'S_OFFAC'  TO lt_order.
    APPEND 'S_ACDCBU' TO lt_order.
    APPEND 'S_CPUDT'  TO lt_order.
    APPEND 'S_CLERDT' TO lt_order.
    APPEND 'S_CLRAC'  TO lt_order.
    APPEND 'S_ORDID'  TO lt_order.



    IF lt_tb[] IS NOT INITIAL.
      DELETE ADJACENT DUPLICATES FROM lt_tb COMPARING ALL FIELDS.
      LOOP AT lt_tb ASSIGNING FIELD-SYMBOL(<fs_tb>).
        CLEAR ls_line.
        CONCATENATE <fs_tb>-fieldname ';' <fs_tb>-value ';' INTO ls_line.
        APPEND ls_line TO lt_line.
      ENDLOOP.
      ls_line = ';'.
      APPEND ls_line TO lt_line.
    ENDIF.

    DESCRIBE TABLE gt_data LINES lv_rows.

    SELECT *

    FROM dd03vt INTO TABLE @DATA(lt_dd03vt)
          WHERE tabname     = 'ZFIIGLAACCOUNT'
          AND ddlanguage  = @sy-langu
          ORDER BY position.


    IF sy-subrc = 0.

      DELETE ADJACENT DUPLICATES FROM lt_dd03vt COMPARING ALL FIELDS.
      DELETE lt_dd03vt WHERE rollname = 'MANDT'.
      DELETE lt_dd03vt WHERE   fieldname <> 'S_COMPY'
                           AND fieldname <> 'S_BUSSR'
                           AND fieldname <> 'S_CPUDT'
                           AND fieldname <> 'S_STBLG'
                           AND fieldname <> 'S_PSDAT'
                           AND fieldname <> 'S_ACCDC'
                           AND fieldname <> 'S_GLACT'
                           AND fieldname <> 'S_GLACLN'
                           AND fieldname <> 'S_DOCTXT'
                           AND fieldname <> 'S_NSUPL'
                           AND fieldname <> 'S_AMINCC'
                           AND fieldname <> 'S_COMCR'
                           AND fieldname <> 'S_AMTGC'
                           AND fieldname <> 'S_GLOCR'
                           AND fieldname <> 'S_AMTTR'
                           AND fieldname <> 'S_TRNCR'
                           AND fieldname <> 'S_ACDOCT'
                           AND fieldname <> 'S_POSTK'
                           AND fieldname <> 'S_PARTB'
                           AND fieldname <> 'S_PROFCT'
                           AND fieldname <> 'S_COSTC'
                           AND fieldname <> 'S_SUPPL'
                           AND fieldname <> 'S_OFFAC'
                           AND fieldname <> 'S_ACDCBU'
                           AND fieldname <> 'S_CLERDT'
                           AND fieldname <> 'S_CLRAC'
                           AND fieldname <> 'S_ORDID'.


      LOOP AT lt_order ASSIGNING FIELD-SYMBOL(<lv_fieldname>).

        LOOP AT lt_dd03vt ASSIGNING FIELD-SYMBOL(<fs_dd03vt>) WHERE fieldname = <lv_fieldname>.

          CLEAR ls_line.
          lv_tabix = sy-tabix.

          IF <fs_dd03vt>-keyflag IS NOT INITIAL.
            lv_is_key = abap_true.
          ENDIF.

          IF lv_is_key IS NOT INITIAL.
            lv_file_line = lv_file_line.
          ENDIF.

          IF <fs_dd03vt>-scrtext_l = 'Nome' AND <fs_dd03vt>-fieldname = 'S_NSUPL'.
            <fs_dd03vt>-scrtext_l = 'Nome Fornecedor'.

          ELSEIF <fs_dd03vt>-scrtext_l = 'Estorno com' AND <fs_dd03vt>-fieldname = 'S_STBLG'.
            <fs_dd03vt>-scrtext_l = 'Nº ref.estorno'.

          ELSEIF <fs_dd03vt>-scrtext_l = 'Data de entrada' AND <fs_dd03vt>-fieldname = 'S_CPUDT'.
            <fs_dd03vt>-scrtext_l = 'Data Criação lçto.contabil servidor'.

          ELSEIF <fs_dd03vt>-scrtext_l = 'Data de entrada' AND <fs_dd03vt>-fieldname = 'S_DOCTXT'.
            <fs_dd03vt>-scrtext_l = 'Txt.it.partida indv.'.

          ENDIF.


          lv_file_line = lv_file_line && <fs_dd03vt>-scrtext_l && ';'.

        ENDLOOP.
      ENDLOOP.

      ls_line = lv_file_line.
      APPEND ls_line TO lt_line.

**********************************************
    ENDIF.

*-- BUSCANDO ELEMENTOS DA TABELA ORIGINAL
    ocl_cl_table ?= cl_abap_structdescr=>describe_by_name( 'ZFIIGLAACCOUNT' ).
    lv_count_fields = lines( ocl_cl_table->components[] ).
    lt_ddfields = ocl_cl_table->get_ddic_field_list(  ).

    CLEAR lv_file_line.

    gt_comp = ocl_cl_table->components.

    DELETE gt_comp WHERE name <> 'S_COMPY'
                     AND name <> 'S_BUSSR'
                     AND name <> 'S_PSDAT'
                     AND name <> 'S_ACCDC'
                     AND name <> 'S_NSUPL'
                     AND name <> 'S_GLACT'
                     AND name <> 'S_STBLG'
                     AND name <> 'S_NSUPL'
                     AND name <> 'S_GLACLN'
                     AND name <> 'S_DOCTXT'
                     AND name <> 'S_AMINCC'
                     AND name <> 'S_COMCR'
                     AND name <> 'S_AMTGC'
                     AND name <> 'S_GLOCR'
                     AND name <> 'S_AMTTR'
                     AND name <> 'S_TRNCR'
                     AND name <> 'S_ACDOCT'
                     AND name <> 'S_POSTK'
                     AND name <> 'S_PARTB'
                     AND name <> 'S_PROFCT'
                     AND name <> 'S_COSTC'
                     AND name <> 'S_SUPPL'
                     AND name <> 'S_OFFAC'
                     AND name <> 'S_ACDCBU'
                     AND name <> 'S_CLERDT'
                     AND name <> 'S_CLRAC'
                     AND name <> 'S_ORDID'.


    LOOP AT gt_data ASSIGNING FIELD-SYMBOL(<lfs_tab>).

      LOOP AT gt_comp INTO lv_field.

        ASSIGN COMPONENT sy-tabix OF STRUCTURE <lfs_tab> TO <field>.

        CHECK <field> IS ASSIGNED.
        CASE lv_field-type_kind.
          WHEN 'C'.
            WRITE <field> TO lv_field_value.
            REPLACE ALL OCCURRENCES OF '.' IN lv_field_value WITH '/'.
          WHEN 'P'.

            lv_aux   = <field>.
            lv_valor = <field>.
            lv_numb  = <field>.

            IF lv_aux CP '*-'.
              REPLACE ALL OCCURRENCES OF '.' IN lv_valor WITH ','.
              WRITE lv_valor TO lv_field_value CURRENCY 'BRL'.
              lv_aux = lv_field_value.
              REPLACE ALL OCCURRENCES OF '-' IN lv_aux WITH ''.

              SHIFT lv_aux LEFT DELETING LEADING space.

              CONCATENATE '-' lv_aux  INTO lv_field_value.
            ELSE.
              SHIFT lv_valor LEFT DELETING LEADING space.
              REPLACE ALL OCCURRENCES OF '.' IN lv_valor WITH ','.
              WRITE lv_valor TO lv_field_value CURRENCY 'BRL'.
            ENDIF.



            IF lv_field-name = 'S_AMINCC'.
              gs_xls_aux-coluna_08 = gs_xls_aux-coluna_08 + <field>.
            ELSEIF lv_field-name = 'S_AMTGC'.
              gs_xls_aux-coluna_10 = gs_xls_aux-coluna_10 + <field>.
            ELSEIF lv_field-name = 'S_AMTTR'.
              gs_xls_aux-coluna_12 = gs_xls_aux-coluna_12 + <field>.

            ENDIF.


          WHEN OTHERS.
            WRITE <field> TO lv_field_value.
        ENDCASE.

        IF lv_field-name = 'S_COMPY'.
          READ TABLE lt_CompanyCode ASSIGNING FIELD-SYMBOL(<fs_CompanyCode>) WITH KEY CompanyCode = lv_field_value.
          IF sy-subrc = 0.
            CLEAR lv_aux.
            CONCATENATE lv_field_value ' ' '(' <fs_CompanyCode>-CompanyCodename')' INTO lv_aux.
            lv_field_value = lv_aux.
          ENDIF.



        ELSEIF lv_field-name = 'S_ACCDC'.
          READ TABLE lt_businessareatext ASSIGNING FIELD-SYMBOL(<fs_businessareatext>) WITH KEY businessarea = lv_field_value.
          IF sy-subrc = 0.
            CLEAR lv_aux.
            CONCATENATE lv_field_value ' ' '(' <fs_businessareatext>-businessareaname')' INTO lv_aux.
            lv_field_value = lv_aux.
          ENDIF.

        ELSEIF lv_field-name = 'S_OFFAC'.

          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = lv_field_value
            IMPORTING
              output = lv_offsettingaccount.


          READ TABLE lt_offsettingaccount ASSIGNING FIELD-SYMBOL(<fs_offsettingaccount>) WITH KEY offsettingaccount = lv_offsettingaccount.
          IF sy-subrc = 0.
            CLEAR lv_aux.
            CONCATENATE lv_field_value ' ' '(' <fs_offsettingaccount>-offsettingaccountname ')' INTO lv_aux.
            lv_field_value = lv_aux.

          ELSE.
            CONCATENATE lv_field_value ' ' '(' ')' INTO lv_aux.
            lv_field_value = lv_aux.

          ENDIF.

        ELSEIF lv_field-name = 'S_PROFCT'.

          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = lv_field_value
            IMPORTING
              output = lv_ProfitCenter.


          READ TABLE lt_ProfitCenterText ASSIGNING FIELD-SYMBOL(<fs_ProfitCenterText>) WITH KEY ProfitCenter = lv_ProfitCenter.
          IF sy-subrc = 0.
            CLEAR lv_aux.
            CONCATENATE lv_field_value ' ' '(' <fs_ProfitCenterText>-ProfitCentername ')' INTO lv_aux.
            lv_field_value = lv_aux.
          ENDIF.


        ELSEIF lv_field-name = 'S_COSTC'.

          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = lv_field_value
            IMPORTING
              output = lv_CostCenter.


          READ TABLE lt_CostCenterText ASSIGNING FIELD-SYMBOL(<fs_CostCenterText>) WITH KEY CostCenter = lv_CostCenter.
          IF sy-subrc = 0.
            CLEAR lv_aux.
            CONCATENATE lv_field_value ' ' '(' <fs_CostCenterText>-CostCentername ')' INTO lv_aux.
            lv_field_value = lv_aux.
          ENDIF.
        ENDIF.

        lv_file_line = lv_file_line && lv_field_value && ';' .
        CLEAR lv_field_value.

      ENDLOOP.

      ls_line = lv_file_line.
      APPEND ls_line TO lt_line.
      CLEAR lv_file_line.

    ENDLOOP.

    DATA lv_file TYPE string.
    PERFORM zf_busca_retorno  CHANGING lv_file.

    PERFORM zexcel_s_export_xls TABLES lt_line USING lv_file.

  ELSE.
    MESSAGE 'Nenhum valor encontrado.' TYPE 'E'.
  ENDIF.
ENDFORM.                    " zf_ler_tabela


*&---------------------------------------------------------------------*
*& Form f_insert_ZMTETEST
*&---------------------------------------------------------------------*
FORM f_insert_zmtetest TABLES pt_tb STRUCTURE zme_cabec_xls USING
                              p_field TYPE zme_cabec_xls-fieldname
                              p_low
                              p_high
                              p_op.

  DATA: lv_value TYPE char100.

  " Lógica de concatenação baseado no operador
  CASE p_op.

    WHEN 'CP'.  " Igual
*      lv_value = p_low.
      CONCATENATE ' *' p_low '*' INTO lv_value.

    WHEN 'EQ'.  " Igual
*      lv_value = p_low.
      CONCATENATE ' = ' p_low INTO lv_value SEPARATED BY space.

    WHEN 'BT'.  " Entre
      IF p_high IS NOT INITIAL.
        CONCATENATE ' ' p_low 'até' p_high INTO lv_value SEPARATED BY space.
      ELSE.
        lv_value = p_low.  " Se não houver HIGH, apenas o LOW
      ENDIF.

    WHEN 'LT'.  " Menor que
      CONCATENATE ' < ' p_low INTO lv_value SEPARATED BY space.

    WHEN 'LE'.  " Menor ou igual
      CONCATENATE ' <= ' p_low INTO lv_value SEPARATED BY space.

    WHEN 'GT'.  " Maior que
      CONCATENATE ' > ' p_low INTO lv_value SEPARATED BY space.

    WHEN 'GE'.  " Maior ou igual
      CONCATENATE ' >= ' p_low INTO lv_value SEPARATED BY space.

    WHEN 'NE'.  " Diferente
      CONCATENATE ' <> ' p_low INTO lv_value SEPARATED BY space.

      " Adicione outros operadores conforme necessário
    WHEN OTHERS.
      lv_value = p_low.  " Valor padrão, caso o operador não seja reconhecido
  ENDCASE.


  " Inserir na tabela
  APPEND INITIAL LINE TO pt_tb ASSIGNING FIELD-SYMBOL(<fs_tb>).
  <fs_tb>-fieldname = p_field.

  WRITE lv_value TO lv_value.
  <fs_tb>-value = lv_value.


ENDFORM.


*&---------------------------------------------------------------------*
*& Form f_insert_ZMTETEST
*&---------------------------------------------------------------------*
FORM f_insert_header TABLES pt_tb STRUCTURE zme_cabec_xls.

  DATA: lv_value    TYPE string,
        lv_fullname TYPE string,
        lv_data     TYPE char10,
        lv_time     TYPE char8.

  DATA: t_address LIKE  bapiaddr3,
        t_return  TYPE TABLE OF bapiret2.

  " Obter detalhes do usuário
  CALL FUNCTION 'BAPI_USER_GET_DETAIL'
    EXPORTING
      username = sy-uname
    IMPORTING
      address  = t_address
    TABLES
      return   = t_return.

  IF sy-subrc EQ 0.
    lv_fullname = t_address-fullname.
  ENDIF.

  " Inserir na tabela: Usuário
  APPEND INITIAL LINE TO pt_tb ASSIGNING FIELD-SYMBOL(<fs_tb1>).
  <fs_tb1>-fieldname = 'Usuário'.
  <fs_tb1>-value = lv_fullname.


  WRITE sy-datum TO lv_data.
  REPLACE ALL OCCURRENCES OF '.' IN lv_data WITH '/'.
  CONDENSE lv_data.

  " Inserir na tabela: Data
  APPEND INITIAL LINE TO pt_tb ASSIGNING FIELD-SYMBOL(<fs_tb2>).
  <fs_tb2>-fieldname = 'Data'.
  <fs_tb2>-value = lv_data.


  WRITE sy-uzeit TO lv_time.
  CONDENSE lv_time.

  " Inserir na tabela: Hora
  APPEND INITIAL LINE TO pt_tb ASSIGNING FIELD-SYMBOL(<fs_tb3>).
  <fs_tb3>-fieldname = 'Hora'.
  <fs_tb3>-value = lv_time.

ENDFORM.



*&---------------------------------------------------------------------*
*& Form f_gui_download
*&---------------------------------------------------------------------*
FORM f_gui_download  TABLES   p_data_tab
                     USING    p_type
                              p_filename.
  DATA:
    vl_filename TYPE  string,
    vl_filetype TYPE  char10.

  CONCATENATE p_filename '\'  sy-datum '_' sy-uzeit '.CSV' INTO vl_filename.
  vl_filetype = 'ASC'.


  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      filetype                = vl_filetype
      filename                = vl_filename
      write_field_separator   = abap_true
*     filetype                = 'txt'
*     header                  = '00'  "<= note this
    TABLES
      data_tab                = p_data_tab
*     fieldnames              = it_fieldnames[] "<= Pass your header table here
    EXCEPTIONS
      file_write_error        = 1
      no_batch                = 2
      gui_refuse_filetransfer = 3
      invalid_type            = 4
      no_authority            = 5
      unknown_error           = 6
      header_not_allowed      = 7
      separator_not_allowed   = 8
      filesize_not_allowed    = 9
      header_too_long         = 10
      dp_error_create         = 11
      dp_error_send           = 12
      dp_error_write          = 13
      unknown_dp_error        = 14
      access_denied           = 15
      dp_out_of_memory        = 16
      disk_full               = 17
      dp_timeout              = 18
      file_not_found          = 19
      dataprovider_exception  = 20
      control_flush_error     = 21
      OTHERS                  = 22.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form zf_busca_retorno
*&---------------------------------------------------------------------*
FORM zf_busca_retorno  CHANGING p_retorno.

  DATA:
    l_path TYPE string,
    l_len  TYPE n.

  CLEAR: l_path, l_len.

  IF p_retorno IS INITIAL.

    p_retorno = 'C:\Users\Downloads'.


  ENDIF.

ENDFORM.


FORM valida_range.

  LOOP AT r_ledger ASSIGNING FIELD-SYMBOL(<fs_ledger>).

    " Validando todos os campos com a lógica CO -> CP e NO para diferente de
    IF <fs_ledger>-option = 'CO' OR <fs_ledger>-option = 'CONTAINS'.
      <fs_ledger>-option = 'CP'.
    ELSEIF <fs_ledger>-option = 'NO'.  " Verificando valor diferente
      <fs_ledger>-option = 'NE'.       " Converte NO para NE, que representa "diferente de" no SAP
    ENDIF.

  ENDLOOP.


  LOOP AT r_compy ASSIGNING FIELD-SYMBOL(<fs_compy>).

    " Validando todos os campos com a lógica CO -> CP e NO para diferente de
    IF <fs_compy>-option = 'CO' OR <fs_compy>-option = 'CONTAINS'.
      <fs_compy>-option = 'CP'.
    ELSEIF <fs_compy>-option = 'NO'.  " Verificando valor diferente
      <fs_compy>-option = 'NE'.       " Converte NO para NE, que representa "diferente de" no SAP
    ENDIF.

  ENDLOOP.

  LOOP AT r_glact ASSIGNING FIELD-SYMBOL(<fs_glact>).

    " Validando todos os campos com a lógica CO -> CP e NO para diferente de
    IF <fs_glact>-option = 'CO' OR <fs_glact>-option = 'CONTAINS'.
      <fs_glact>-option = 'CP'.
    ELSEIF <fs_glact>-option = 'NO'.  " Verificando valor diferente
      <fs_glact>-option = 'NE'.       " Converte NO para NE, que representa "diferente de" no SAP
    ENDIF.

  ENDLOOP.

  LOOP AT r_psdatf ASSIGNING FIELD-SYMBOL(<fs_psdatf>).

    " Validando todos os campos com a lógica CO -> CP e NO para diferente de
    IF <fs_psdatf>-option = 'CO' OR <fs_psdatf>-option = 'CONTAINS'.
      <fs_psdatf>-option = 'CP'.
    ELSEIF <fs_psdatf>-option = 'NO'.  " Verificando valor diferente
      <fs_psdatf>-option = 'NE'.       " Converte NO para NE, que representa "diferente de" no SAP
    ENDIF.

  ENDLOOP.


  LOOP AT r_stats ASSIGNING FIELD-SYMBOL(<fs_stats>).

    " Validando todos os campos com a lógica CO -> CP e NO para diferente de
    IF <fs_stats>-option = 'CO' OR <fs_stats>-option = 'CONTAINS'.
      <fs_stats>-option = 'CP'.
    ELSEIF <fs_stats>-option = 'NO'.  " Verificando valor diferente
      <fs_stats>-option = 'NE'.       " Converte NO para NE, que representa "diferente de" no SAP
    ENDIF.

  ENDLOOP.



ENDFORM.

FORM convert_date.

  DATA: lv_date_string         TYPE string,
        lv_day                 TYPE string,
        lv_month               TYPE string,
        lv_year                TYPE string,
        lv_converted_date_low  TYPE string,
        lv_converted_date_high TYPE string,
        lv_date_low            TYPE sy-datum,
        lv_date_high           TYPE sy-datum.


  LOOP AT r_psdat ASSIGNING FIELD-SYMBOL(<fs_psdat>).

    lv_date_string = <fs_psdat>-low+4.

    lv_month = lv_date_string+0(3). " (mês)
    lv_day = lv_date_string+4(2).   " (dia)
    lv_year = lv_date_string+7(4).  " (ano)

    TRANSLATE lv_month TO UPPER CASE.

    " Converter o mês abreviado para o número do mês
    CASE lv_month.
      WHEN 'JAN'.
        lv_month = '01'.
      WHEN 'FEB'.
        lv_month = '02'.
      WHEN 'MAR'.
        lv_month = '03'.
      WHEN 'APR'.
        lv_month = '04'.
      WHEN 'MAY'.
        lv_month = '05'.
      WHEN 'JUN'.
        lv_month = '06'.
      WHEN 'JUL'.
        lv_month = '07'.
      WHEN 'AUG'.
        lv_month = '08'.
      WHEN 'SEP'.
        lv_month = '09'.
      WHEN 'OCT'.
        lv_month = '10'.
      WHEN 'NOV'.
        lv_month = '11'.
      WHEN 'DEC'.
        lv_month = '12'.
      WHEN OTHERS.
        lv_month = '00'. " Caso o mês seja inválido
    ENDCASE.


    CONCATENATE lv_year lv_month lv_day INTO lv_converted_date_low.

    lv_date_low = lv_converted_date_low.
    lv_date_low = lv_date_low + 1.

    IF <fs_psdat>-high IS NOT INITIAL.

      lv_date_string = <fs_psdat>-high+4.

      lv_month = lv_date_string+0(3). " (mês)
      lv_day = lv_date_string+4(2).   " (dia)
      lv_year = lv_date_string+7(4).  " (ano)

      TRANSLATE lv_month TO UPPER CASE.

      " Converter o mês abreviado para o número do mês
      CASE lv_month.
        WHEN 'JAN'.
          lv_month = '01'.
        WHEN 'FEB'.
          lv_month = '02'.
        WHEN 'MAR'.
          lv_month = '03'.
        WHEN 'APR'.
          lv_month = '04'.
        WHEN 'MAY'.
          lv_month = '05'.
        WHEN 'JUN'.
          lv_month = '06'.
        WHEN 'JUL'.
          lv_month = '07'.
        WHEN 'AUG'.
          lv_month = '08'.
        WHEN 'SEP'.
          lv_month = '09'.
        WHEN 'OCT'.
          lv_month = '10'.
        WHEN 'NOV'.
          lv_month = '11'.
        WHEN 'DEC'.
          lv_month = '12'.
        WHEN OTHERS.
          lv_month = '00'. " Caso o mês seja inválido
      ENDCASE.

*      lv_day = lv_day - 1.

      CONCATENATE lv_year lv_month lv_day INTO lv_converted_date_high.
      lv_date_high = lv_converted_date_high.
      lv_date_high = lv_date_high + 1.

    ENDIF.

    IF lv_converted_date_low IS NOT INITIAL.
      IF lv_date_high IS NOT INITIAL.
        APPEND VALUE #( sign = 'I' option = <fs_psdat>-option low = lv_date_low high = lv_date_high ) TO r_psdatf.
      ELSE.
        APPEND VALUE #( sign = 'I' option = <fs_psdat>-option low = lv_date_low ) TO r_psdatf.
      ENDIF.
    ENDIF.

  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form process_filter
*&---------------------------------------------------------------------*
FORM process_filter.

  DATA: lt_ledger TYPE TABLE OF string,
        lt_compy  TYPE TABLE OF string,
        lt_glact  TYPE TABLE OF string,
        lt_stats  TYPE TABLE OF string,

        lt_Psdat  TYPE TABLE OF string,
        lt_PostK  TYPE TABLE OF string,
        lt_asingr TYPE TABLE OF string,
        lt_acdoct TYPE TABLE OF string,
        lt_amincc TYPE TABLE OF string,
        lt_txcode TYPE TABLE OF string,
        lt_clerdt TYPE TABLE OF string,
        lt_profct TYPE TABLE OF string,
        lt_segmt  TYPE TABLE OF string,
        lt_doctxt TYPE TABLE OF string,


***************************************************
        lt_conta  TYPE TABLE OF string,
        lt_fintr  TYPE TABLE OF string,
        lt_bustr  TYPE TABLE OF string,
        lt_cobtr  TYPE TABLE OF string,
        lt_refdt  TYPE TABLE OF string,
        lt_logsy  TYPE TABLE OF string,
        lt_refdc  TYPE TABLE OF string,
        lt_refdo  TYPE TABLE OF string,
        lt_refdi  TYPE TABLE OF string,
        lt_refdg  TYPE TABLE OF string,
        lt_trxsi  TYPE TABLE OF string,
        lt_isrev  TYPE TABLE OF string,
        lt_rvref  TYPE TABLE OF string,
        lt_rvdoc  TYPE TABLE OF string,
        lt_isset  TYPE TABLE OF string,
        lt_isstl  TYPE TABLE OF string,
        lt_prdct  TYPE TABLE OF string,
        lt_prdco  TYPE TABLE OF string,
        lt_prddo  TYPE TABLE OF string,
        lt_prddi  TYPE TABLE OF string,
        lt_prjcc  TYPE TABLE OF string,
        lt_prjfy  TYPE TABLE OF string,
        lt_prdje  TYPE TABLE OF string,
        lt_prdji  TYPE TABLE OF string,
        lt_srdct  TYPE TABLE OF string,
        lt_srlog  TYPE TABLE OF string,

***************************************************


        lv_key    TYPE string,
        lv_value  TYPE string,
        lv_low    TYPE char100,
        lv_high   TYPE string,
        lv_op     TYPE string,
        lv_index  TYPE i,
        lv_gl     TYPE I_GLAccountLineItemRawData-glaccount.


  REPLACE ALL OCCURRENCES OF '"' IN s_ledger WITH ''.
  REPLACE ALL OCCURRENCES OF '"' IN s_compy  WITH ''.
  REPLACE ALL OCCURRENCES OF '"' IN s_glact  WITH ''.
  REPLACE ALL OCCURRENCES OF '"' IN s_status WITH ''.
  REPLACE ALL OCCURRENCES OF '"' IN s_psdat  WITH ''.

  REPLACE ALL OCCURRENCES OF '"' IN s_PostK   WITH ''.
  REPLACE ALL OCCURRENCES OF '"' IN s_asingr  WITH ''.
  REPLACE ALL OCCURRENCES OF '"' IN s_acdoct  WITH ''.
  REPLACE ALL OCCURRENCES OF '"' IN s_amincc  WITH ''.
  REPLACE ALL OCCURRENCES OF '"' IN s_txcode  WITH ''.
  REPLACE ALL OCCURRENCES OF '"' IN s_clerdt  WITH ''.
  REPLACE ALL OCCURRENCES OF '"' IN s_profct  WITH ''.
  REPLACE ALL OCCURRENCES OF '"' IN s_segmt   WITH ''.
  REPLACE ALL OCCURRENCES OF '"' IN s_doctxt  WITH ''.


  SPLIT s_ledger  AT ',' INTO TABLE lt_ledger.
  SPLIT s_compy   AT ',' INTO TABLE lt_compy.
  SPLIT s_glact   AT ',' INTO TABLE lt_glact.
  SPLIT s_psdat   AT ',' INTO TABLE lt_psdat.
  SPLIT s_status  AT ',' INTO TABLE lt_stats.

  SPLIT s_PostK   AT ',' INTO TABLE lt_PostK.
  SPLIT s_asingr  AT ',' INTO TABLE lt_asingr.
  SPLIT s_acdoct  AT ',' INTO TABLE lt_acdoct.
  SPLIT s_amincc  AT ',' INTO TABLE lt_amincc.
  SPLIT s_txcode  AT ',' INTO TABLE lt_txcode.
  SPLIT s_clerdt  AT ',' INTO TABLE lt_clerdt.
  SPLIT s_profct  AT ',' INTO TABLE lt_profct.
  SPLIT s_segmt   AT ',' INTO TABLE lt_segmt.
  SPLIT s_doctxt  AT ',' INTO TABLE lt_doctxt.


***************************************************

  REPLACE ALL OCCURRENCES OF '"' IN s_conta  WITH ''.
  REPLACE ALL OCCURRENCES OF '"' IN s_fintr  WITH ''.
  REPLACE ALL OCCURRENCES OF '"' IN s_bustr  WITH ''.
  REPLACE ALL OCCURRENCES OF '"' IN s_cobtr  WITH ''.
  REPLACE ALL OCCURRENCES OF '"' IN s_refdt  WITH ''.
  REPLACE ALL OCCURRENCES OF '"' IN s_logsy  WITH ''.
  REPLACE ALL OCCURRENCES OF '"' IN s_refdc  WITH ''.
  REPLACE ALL OCCURRENCES OF '"' IN s_refdo  WITH ''.
  REPLACE ALL OCCURRENCES OF '"' IN s_refdi  WITH ''.
  REPLACE ALL OCCURRENCES OF '"' IN s_refdg  WITH ''.
  REPLACE ALL OCCURRENCES OF '"' IN s_trxsi  WITH ''.
  REPLACE ALL OCCURRENCES OF '"' IN s_isrev  WITH ''.
  REPLACE ALL OCCURRENCES OF '"' IN s_rvref  WITH ''.
  REPLACE ALL OCCURRENCES OF '"' IN s_rvdoc  WITH ''.
  REPLACE ALL OCCURRENCES OF '"' IN s_isset  WITH ''.
  REPLACE ALL OCCURRENCES OF '"' IN s_isstl  WITH ''.
  REPLACE ALL OCCURRENCES OF '"' IN s_prdct  WITH ''.
  REPLACE ALL OCCURRENCES OF '"' IN s_prdco  WITH ''.
  REPLACE ALL OCCURRENCES OF '"' IN s_prddo  WITH ''.
  REPLACE ALL OCCURRENCES OF '"' IN s_prddi  WITH ''.
  REPLACE ALL OCCURRENCES OF '"' IN s_prjcc  WITH ''.
  REPLACE ALL OCCURRENCES OF '"' IN s_prjfy  WITH ''.
  REPLACE ALL OCCURRENCES OF '"' IN s_prdje  WITH ''.
  REPLACE ALL OCCURRENCES OF '"' IN s_prdji  WITH ''.
  REPLACE ALL OCCURRENCES OF '"' IN s_srdct  WITH ''.
  REPLACE ALL OCCURRENCES OF '"' IN s_srlog  WITH ''.


  SPLIT s_conta  AT ',' INTO TABLE lt_conta.
  SPLIT s_fintr  AT ',' INTO TABLE lt_fintr.
  SPLIT s_bustr  AT ',' INTO TABLE lt_bustr.
  SPLIT s_cobtr  AT ',' INTO TABLE lt_cobtr.
  SPLIT s_refdt  AT ',' INTO TABLE lt_refdt.
  SPLIT s_logsy  AT ',' INTO TABLE lt_logsy.
  SPLIT s_refdc  AT ',' INTO TABLE lt_refdc.
  SPLIT s_refdo  AT ',' INTO TABLE lt_refdo.
  SPLIT s_refdi  AT ',' INTO TABLE lt_refdi.
  SPLIT s_refdg  AT ',' INTO TABLE lt_refdg.
  SPLIT s_trxsi  AT ',' INTO TABLE lt_trxsi.
  SPLIT s_isrev  AT ',' INTO TABLE lt_isrev.
  SPLIT s_rvref  AT ',' INTO TABLE lt_rvref.
  SPLIT s_rvdoc  AT ',' INTO TABLE lt_rvdoc.
  SPLIT s_isset  AT ',' INTO TABLE lt_isset.
  SPLIT s_isstl  AT ',' INTO TABLE lt_isstl.
  SPLIT s_prdct  AT ',' INTO TABLE lt_prdct.
  SPLIT s_prdco  AT ',' INTO TABLE lt_prdco.
  SPLIT s_prddo  AT ',' INTO TABLE lt_prddo.
  SPLIT s_prddi  AT ',' INTO TABLE lt_prddi.
  SPLIT s_prjcc  AT ',' INTO TABLE lt_prjcc.
  SPLIT s_prjfy  AT ',' INTO TABLE lt_prjfy.
  SPLIT s_prdje  AT ',' INTO TABLE lt_prdje.
  SPLIT s_prdji  AT ',' INTO TABLE lt_prdji.
  SPLIT s_srdct  AT ',' INTO TABLE lt_srdct.
  SPLIT s_srlog  AT ',' INTO TABLE lt_srlog.


***************************************************


  LOOP AT lt_ledger ASSIGNING FIELD-SYMBOL(<fs_ledger>).

    SPLIT <fs_ledger> AT '=' INTO lv_key lv_value.

    " Preenche os campos LOW, HIGH e OP conforme o índice
    IF lv_key CP 'S_LEDGER*'.
      lv_low = lv_value.
      lv_op  = 'EQ'.
    ENDIF.


    " Se todos os campos (LOW, HIGH, OP) estiverem preenchidos, adiciona ao intervalo
    IF lv_low IS NOT INITIAL AND lv_op IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = lv_op low = lv_low high = lv_high ) TO r_ledger.
      CLEAR: lv_low, lv_high, lv_op.
    ENDIF.

  ENDLOOP.

****************************
*          compy
****************************

  LOOP AT lt_compy ASSIGNING FIELD-SYMBOL(<fs_compy>).

    SPLIT <fs_compy> AT '=' INTO lv_key lv_value.

    IF lv_key CP 'LOW*'.
      lv_index = lv_key+3(1).
      lv_low = lv_value.
    ELSEIF lv_key CP 'HIGH*'.
      lv_index = lv_key+4(1).
      lv_high = lv_value.
    ELSEIF lv_key CP 'OP*'.
      lv_index = lv_key+2(1).
      lv_op = lv_value.
    ENDIF.

    " Se todos os campos (LOW, HIGH, OP) estiverem preenchidos, adiciona ao intervalo
    IF lv_low IS NOT INITIAL AND lv_op IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = lv_op low = lv_low high = lv_high ) TO r_compy.
      CLEAR: lv_low, lv_high, lv_op.
    ENDIF.


  ENDLOOP.


****************************
*****   glact
****************************

  LOOP AT lt_glact ASSIGNING FIELD-SYMBOL(<fs_glact>).

    SPLIT <fs_glact> AT '=' INTO lv_key lv_value.

    IF lv_key CP 'LOW*'.
      lv_index = lv_key+3(1).
      lv_low = lv_value.
    ELSEIF lv_key CP 'HIGH*'.
      lv_index = lv_key+4(1).
      lv_high = lv_value.
    ELSEIF lv_key CP 'OP*'.
      lv_index = lv_key+2(1).
      lv_op = lv_value.
    ENDIF.

    " Se todos os campos (LOW, HIGH, OP) estiverem preenchidos, adiciona ao intervalo
    IF lv_low IS NOT INITIAL AND lv_op IS NOT INITIAL.
      lv_gl = lv_low.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = lv_gl
        IMPORTING
          output = lv_gl.

      APPEND VALUE #( sign = 'I' option = lv_op low = lv_gl high = lv_high ) TO r_glact.
      CLEAR: lv_low, lv_high, lv_op.
    ENDIF.

  ENDLOOP.


****************************
**  psdat
****************************

  LOOP AT lt_psdat ASSIGNING FIELD-SYMBOL(<fs_psdat>).

    SPLIT <fs_psdat> AT '=' INTO lv_key lv_value.

    IF lv_key CP 'LOW*'.
      lv_index = lv_key+3(1).
      lv_low = lv_value.
    ELSEIF lv_key CP 'HIGH*'.
      lv_index = lv_key+4(1).
      lv_high = lv_value.
    ELSEIF lv_key CP 'OP*'.
      lv_index = lv_key+2(1).
      lv_op = lv_value.
    ENDIF.

    " Se todos os campos (LOW, HIGH, OP) estiverem preenchidos, adiciona ao intervalo
    IF lv_low IS NOT INITIAL AND lv_op IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = lv_op low = lv_low high = lv_high ) TO r_psdat.
      CLEAR: lv_low, lv_high, lv_op.
    ENDIF.

  ENDLOOP.



****************************
**  Status
****************************

  LOOP AT lt_stats ASSIGNING FIELD-SYMBOL(<fs_stats>).

    SPLIT <fs_stats> AT '=' INTO lv_key lv_value.

    IF lv_key CP 'LOW*'.
      lv_index = lv_key+3(1).

      IF lv_value = 1.
        lv_value = 'Partidas em Aberto'.
      ELSE.
        lv_value = 'Itens Compensados'.
      ENDIF.

      lv_low = lv_value.
    ELSEIF lv_key CP 'HIGH*'.
      lv_index = lv_key+4(1).
      lv_high = lv_value.
    ELSEIF lv_key CP 'OP*'.
      lv_index = lv_key+2(1).
      lv_op = lv_value.
    ENDIF.

    " Se todos os campos (LOW, HIGH, OP) estiverem preenchidos, adiciona ao intervalo
    IF lv_low IS NOT INITIAL AND lv_op IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = lv_op low = lv_low high = lv_high ) TO r_stats.
      CLEAR: lv_low, lv_high, lv_op.
    ENDIF.

  ENDLOOP.


****************************
**  PostK
****************************

  LOOP AT lt_Postk ASSIGNING FIELD-SYMBOL(<fs_Postk>).

    SPLIT <fs_Postk> AT '=' INTO lv_key lv_value.

    IF lv_key CP 'LOW*'.
      lv_index = lv_key+3(1).
      lv_low = lv_value.
    ELSEIF lv_key CP 'HIGH*'.
      lv_index = lv_key+4(1).
      lv_high = lv_value.
    ELSEIF lv_key CP 'OP*'.
      lv_index = lv_key+2(1).
      lv_op = lv_value.
    ENDIF.
    " Se todos os campos (LOW, HIGH, OP) estiverem preenchidos, adiciona ao intervalo
    IF lv_low IS NOT INITIAL AND lv_op IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = lv_op low = lv_low high = lv_high ) TO r_Postk.
      CLEAR: lv_low, lv_high, lv_op.
    ENDIF.
  ENDLOOP.


****************************
*     **  asingr **
****************************

  LOOP AT lt_asingr ASSIGNING FIELD-SYMBOL(<fs_asingr>).
    SPLIT <fs_asingr> AT '=' INTO lv_key lv_value.
    IF lv_key CP 'LOW*'.
      lv_index = lv_key+3(1).
      lv_low = lv_value.
    ELSEIF lv_key CP 'HIGH*'.
      lv_index = lv_key+4(1).
      lv_high = lv_value.
    ELSEIF lv_key CP 'OP*'.
      lv_index = lv_key+2(1).
      lv_op = lv_value.
    ENDIF.
    " Se todos os campos (LOW, HIGH, OP) estiverem preenchidos, adiciona ao intervalo
    IF lv_low IS NOT INITIAL AND lv_op IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = lv_op low = lv_low high = lv_high ) TO r_asingr.
      CLEAR: lv_low, lv_high, lv_op.
    ENDIF.
  ENDLOOP.


****************************
*     **  acdoct **
****************************

  LOOP AT lt_acdoct ASSIGNING FIELD-SYMBOL(<fs_acdoct>).
    SPLIT <fs_acdoct> AT '=' INTO lv_key lv_value.
    IF lv_key CP 'LOW*'.
      lv_index = lv_key+3(1).
      lv_low = lv_value.
    ELSEIF lv_key CP 'HIGH*'.
      lv_index = lv_key+4(1).
      lv_high = lv_value.
    ELSEIF lv_key CP 'OP*'.
      lv_index = lv_key+2(1).
      lv_op = lv_value.
    ENDIF.
    " Se todos os campos (LOW, HIGH, OP) estiverem preenchidos, adiciona ao intervalo
    IF lv_low IS NOT INITIAL AND lv_op IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = lv_op low = lv_low high = lv_high ) TO r_acdoct.
      CLEAR: lv_low, lv_high, lv_op.
    ENDIF.
  ENDLOOP.


****************************
*     **  amincc **
****************************

  LOOP AT lt_amincc ASSIGNING FIELD-SYMBOL(<fs_amincc>).
    SPLIT <fs_amincc> AT '=' INTO lv_key lv_value.
    IF lv_key CP 'LOW*'.
      lv_index = lv_key+3(1).
      lv_low = lv_value.
    ELSEIF lv_key CP 'HIGH*'.
      lv_index = lv_key+4(1).
      lv_high = lv_value.
    ELSEIF lv_key CP 'OP*'.
      lv_index = lv_key+2(1).
      lv_op = lv_value.
    ENDIF.
    " Se todos os campos (LOW, HIGH, OP) estiverem preenchidos, adiciona ao intervalo
    IF lv_low IS NOT INITIAL AND lv_op IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = lv_op low = lv_low high = lv_high ) TO r_amincc.
      CLEAR: lv_low, lv_high, lv_op.
    ENDIF.
  ENDLOOP.

****************************
*     **  txcode **
****************************

  LOOP AT lt_txcode ASSIGNING FIELD-SYMBOL(<fs_txcode>).
    SPLIT <fs_txcode> AT '=' INTO lv_key lv_value.
    IF lv_key CP 'LOW*'.
      lv_index = lv_key+3(1).
      lv_low = lv_value.
    ELSEIF lv_key CP 'HIGH*'.
      lv_index = lv_key+4(1).
      lv_high = lv_value.
    ELSEIF lv_key CP 'OP*'.
      lv_index = lv_key+2(1).
      lv_op = lv_value.
    ENDIF.
    " Se todos os campos (LOW, HIGH, OP) estiverem preenchidos, adiciona ao intervalo
    IF lv_low IS NOT INITIAL AND lv_op IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = lv_op low = lv_low high = lv_high ) TO r_txcode.
      CLEAR: lv_low, lv_high, lv_op.
    ENDIF.
  ENDLOOP.


****************************
*     **  clerdt **
****************************

  LOOP AT lt_clerdt ASSIGNING FIELD-SYMBOL(<fs_clerdt>).
    SPLIT <fs_clerdt> AT '=' INTO lv_key lv_value.
    IF lv_key CP 'LOW*'.
      lv_index = lv_key+3(1).
      lv_low = lv_value.
    ELSEIF lv_key CP 'HIGH*'.
      lv_index = lv_key+4(1).
      lv_high = lv_value.
    ELSEIF lv_key CP 'OP*'.
      lv_index = lv_key+2(1).
      lv_op = lv_value.
    ENDIF.
    " Se todos os campos (LOW, HIGH, OP) estiverem preenchidos, adiciona ao intervalo
    IF lv_low IS NOT INITIAL AND lv_op IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = lv_op low = lv_low high = lv_high ) TO r_clerdt.
      CLEAR: lv_low, lv_high, lv_op.
    ENDIF.
  ENDLOOP.

****************************
*     **  profct **
****************************

  LOOP AT lt_profct ASSIGNING FIELD-SYMBOL(<fs_profct>).
    SPLIT <fs_profct> AT '=' INTO lv_key lv_value.
    IF lv_key CP 'LOW*'.
      lv_index = lv_key+3(1).
      lv_low = lv_value.
    ELSEIF lv_key CP 'HIGH*'.
      lv_index = lv_key+4(1).
      lv_high = lv_value.
    ELSEIF lv_key CP 'OP*'.
      lv_index = lv_key+2(1).
      lv_op = lv_value.
    ENDIF.
    " Se todos os campos (LOW, HIGH, OP) estiverem preenchidos, adiciona ao intervalo
    IF lv_low IS NOT INITIAL AND lv_op IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = lv_op low = lv_low high = lv_high ) TO r_profct.
      CLEAR: lv_low, lv_high, lv_op.
    ENDIF.
  ENDLOOP.

****************************
*     **  segmt **
****************************

  LOOP AT lt_segmt ASSIGNING FIELD-SYMBOL(<fs_segmt>).
    SPLIT <fs_segmt> AT '=' INTO lv_key lv_value.
    IF lv_key CP 'LOW*'.
      lv_index = lv_key+3(1).
      lv_low = lv_value.
    ELSEIF lv_key CP 'HIGH*'.
      lv_index = lv_key+4(1).
      lv_high = lv_value.
    ELSEIF lv_key CP 'OP*'.
      lv_index = lv_key+2(1).
      lv_op = lv_value.
    ENDIF.
    " Se todos os campos (LOW, HIGH, OP) estiverem preenchidos, adiciona ao intervalo
    IF lv_low IS NOT INITIAL AND lv_op IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = lv_op low = lv_low high = lv_high ) TO r_segmt.
      CLEAR: lv_low, lv_high, lv_op.
    ENDIF.
  ENDLOOP.


****************************
*     **  doctxt **
****************************

  LOOP AT lt_doctxt ASSIGNING FIELD-SYMBOL(<fs_doctxt>).
    SPLIT <fs_doctxt> AT '=' INTO lv_key lv_value.
    IF lv_key CP 'LOW*'.
      lv_index = lv_key+3(1).
      lv_low = lv_value.
    ELSEIF lv_key CP 'HIGH*'.
      lv_index = lv_key+4(1).
      lv_high = lv_value.
    ELSEIF lv_key CP 'OP*'.
      lv_index = lv_key+2(1).
      lv_op = lv_value.
    ENDIF.
    " Se todos os campos (LOW, HIGH, OP) estiverem preenchidos, adiciona ao intervalo
    IF lv_low IS NOT INITIAL AND lv_op IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = lv_op low = lv_low high = lv_high ) TO r_doctxt.
      CLEAR: lv_low, lv_high, lv_op.
    ENDIF.
  ENDLOOP.

****************************
*     **  conta **
****************************

  LOOP AT lt_conta ASSIGNING FIELD-SYMBOL(<fs_conta>).
    SPLIT <fs_conta> AT '=' INTO lv_key lv_value.
    IF lv_key CP 'LOW*'.
      lv_index = lv_key+3(1).
      lv_low = lv_value.
    ELSEIF lv_key CP 'HIGH*'.
      lv_index = lv_key+4(1).
      lv_high = lv_value.
    ELSEIF lv_key CP 'OP*'.
      lv_index = lv_key+2(1).
      lv_op = lv_value.
    ENDIF.
    " Se todos os campos (LOW, HIGH, OP) estiverem preenchidos, adiciona ao intervalo
    IF lv_low IS NOT INITIAL AND lv_op IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = lv_op low = lv_low high = lv_high ) TO r_conta.
      CLEAR: lv_low, lv_high, lv_op.
    ENDIF.
  ENDLOOP.

****************************
*     **  fintr **
****************************

  LOOP AT lt_fintr ASSIGNING FIELD-SYMBOL(<fs_fintr>).
    SPLIT <fs_fintr> AT '=' INTO lv_key lv_value.
    IF lv_key CP 'LOW*'.
      lv_index = lv_key+3(1).
      lv_low = lv_value.
    ELSEIF lv_key CP 'HIGH*'.
      lv_index = lv_key+4(1).
      lv_high = lv_value.
    ELSEIF lv_key CP 'OP*'.
      lv_index = lv_key+2(1).
      lv_op = lv_value.
    ENDIF.
    " Se todos os campos (LOW, HIGH, OP) estiverem preenchidos, adiciona ao intervalo
    IF lv_low IS NOT INITIAL AND lv_op IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = lv_op low = lv_low high = lv_high ) TO r_fintr.
      CLEAR: lv_low, lv_high, lv_op.
    ENDIF.
  ENDLOOP.

****************************
*     **  bustr **
****************************

  LOOP AT lt_bustr ASSIGNING FIELD-SYMBOL(<fs_bustr>).
    SPLIT <fs_bustr> AT '=' INTO lv_key lv_value.
    IF lv_key CP 'LOW*'.
      lv_index = lv_key+3(1).
      lv_low = lv_value.
    ELSEIF lv_key CP 'HIGH*'.
      lv_index = lv_key+4(1).
      lv_high = lv_value.
    ELSEIF lv_key CP 'OP*'.
      lv_index = lv_key+2(1).
      lv_op = lv_value.
    ENDIF.
    " Se todos os campos (LOW, HIGH, OP) estiverem preenchidos, adiciona ao intervalo
    IF lv_low IS NOT INITIAL AND lv_op IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = lv_op low = lv_low high = lv_high ) TO r_bustr.
      CLEAR: lv_low, lv_high, lv_op.
    ENDIF.
  ENDLOOP.

****************************
*     ** cobtr **
****************************

  LOOP AT lt_cobtr ASSIGNING FIELD-SYMBOL(<fs_cobtr>).
    SPLIT <fs_cobtr> AT '=' INTO lv_key lv_value.
    IF lv_key CP 'LOW*'.
      lv_index = lv_key+3(1).
      lv_low = lv_value.
    ELSEIF lv_key CP 'HIGH*'.
      lv_index = lv_key+4(1).
      lv_high = lv_value.
    ELSEIF lv_key CP 'OP*'.
      lv_index = lv_key+2(1).
      lv_op = lv_value.
    ENDIF.
    " Se todos os campos (LOW, HIGH, OP) estiverem preenchidos, adiciona ao intervalo
    IF lv_low IS NOT INITIAL AND lv_op IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = lv_op low = lv_low high = lv_high ) TO r_cobtr.
      CLEAR: lv_low, lv_high, lv_op.
    ENDIF.
  ENDLOOP.

****************************
*     ** refdt **
****************************

  LOOP AT lt_refdt ASSIGNING FIELD-SYMBOL(<fs_refdt>).
    SPLIT <fs_refdt> AT '=' INTO lv_key lv_value.
    IF lv_key CP 'LOW*'.
      lv_index = lv_key+3(1).
      lv_low = lv_value.
    ELSEIF lv_key CP 'HIGH*'.
      lv_index = lv_key+4(1).
      lv_high = lv_value.
    ELSEIF lv_key CP 'OP*'.
      lv_index = lv_key+2(1).
      lv_op = lv_value.
    ENDIF.
    " Se todos os campos (LOW, HIGH, OP) estiverem preenchidos, adiciona ao intervalo
    IF lv_low IS NOT INITIAL AND lv_op IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = lv_op low = lv_low high = lv_high ) TO r_refdt.
      CLEAR: lv_low, lv_high, lv_op.
    ENDIF.
  ENDLOOP.

****************************
*     ** logsy **
****************************

  LOOP AT lt_logsy ASSIGNING FIELD-SYMBOL(<fs_logsy>).
    SPLIT <fs_logsy> AT '=' INTO lv_key lv_value.
    IF lv_key CP 'LOW*'.
      lv_index = lv_key+3(1).
      lv_low = lv_value.
    ELSEIF lv_key CP 'HIGH*'.
      lv_index = lv_key+4(1).
      lv_high = lv_value.
    ELSEIF lv_key CP 'OP*'.
      lv_index = lv_key+2(1).
      lv_op = lv_value.
    ENDIF.
    " Se todos os campos (LOW, HIGH, OP) estiverem preenchidos, adiciona ao intervalo
    IF lv_low IS NOT INITIAL AND lv_op IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = lv_op low = lv_low high = lv_high ) TO r_logsy.
      CLEAR: lv_low, lv_high, lv_op.
    ENDIF.
  ENDLOOP.

****************************
*     ** refdc **
****************************

  LOOP AT lt_refdc ASSIGNING FIELD-SYMBOL(<fs_refdc>).
    SPLIT <fs_refdc> AT '=' INTO lv_key lv_value.
    IF lv_key CP 'LOW*'.
      lv_index = lv_key+3(1).
      lv_low = lv_value.
    ELSEIF lv_key CP 'HIGH*'.
      lv_index = lv_key+4(1).
      lv_high = lv_value.
    ELSEIF lv_key CP 'OP*'.
      lv_index = lv_key+2(1).
      lv_op = lv_value.
    ENDIF.
    " Se todos os campos (LOW, HIGH, OP) estiverem preenchidos, adiciona ao intervalo
    IF lv_low IS NOT INITIAL AND lv_op IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = lv_op low = lv_low high = lv_high ) TO r_refdc.
      CLEAR: lv_low, lv_high, lv_op.
    ENDIF.
  ENDLOOP.

****************************
*     ** refdo **
****************************

  LOOP AT lt_refdo ASSIGNING FIELD-SYMBOL(<fs_refdo>).
    SPLIT <fs_refdo> AT '=' INTO lv_key lv_value.
    IF lv_key CP 'LOW*'.
      lv_index = lv_key+3(1).
      lv_low = lv_value.
    ELSEIF lv_key CP 'HIGH*'.
      lv_index = lv_key+4(1).
      lv_high = lv_value.
    ELSEIF lv_key CP 'OP*'.
      lv_index = lv_key+2(1).
      lv_op = lv_value.
    ENDIF.
    " Se todos os campos (LOW, HIGH, OP) estiverem preenchidos, adiciona ao intervalo
    IF lv_low IS NOT INITIAL AND lv_op IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = lv_op low = lv_low high = lv_high ) TO r_refdo.
      CLEAR: lv_low, lv_high, lv_op.
    ENDIF.
  ENDLOOP.

****************************
*     ** refdi **
****************************

  LOOP AT lt_refdi ASSIGNING FIELD-SYMBOL(<fs_refdi>).
    SPLIT <fs_refdi> AT '=' INTO lv_key lv_value.
    IF lv_key CP 'LOW*'.
      lv_index = lv_key+3(1).
      lv_low = lv_value.
    ELSEIF lv_key CP 'HIGH*'.
      lv_index = lv_key+4(1).
      lv_high = lv_value.
    ELSEIF lv_key CP 'OP*'.
      lv_index = lv_key+2(1).
      lv_op = lv_value.
    ENDIF.
    " Se todos os campos (LOW, HIGH, OP) estiverem preenchidos, adiciona ao intervalo
    IF lv_low IS NOT INITIAL AND lv_op IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = lv_op low = lv_low high = lv_high ) TO r_refdi.
      CLEAR: lv_low, lv_high, lv_op.
    ENDIF.
  ENDLOOP.

****************************
*     ** refdg **
****************************

  LOOP AT lt_refdg ASSIGNING FIELD-SYMBOL(<fs_refdg>).
    SPLIT <fs_refdg> AT '=' INTO lv_key lv_value.
    IF lv_key CP 'LOW*'.
      lv_index = lv_key+3(1).
      lv_low = lv_value.
    ELSEIF lv_key CP 'HIGH*'.
      lv_index = lv_key+4(1).
      lv_high = lv_value.
    ELSEIF lv_key CP 'OP*'.
      lv_index = lv_key+2(1).
      lv_op = lv_value.
    ENDIF.
    " Se todos os campos (LOW, HIGH, OP) estiverem preenchidos, adiciona ao intervalo
    IF lv_low IS NOT INITIAL AND lv_op IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = lv_op low = lv_low high = lv_high ) TO r_refdg.
      CLEAR: lv_low, lv_high, lv_op.
    ENDIF.
  ENDLOOP.

****************************
*     ** trxsi **
****************************

  LOOP AT lt_trxsi ASSIGNING FIELD-SYMBOL(<fs_trxsi>).
    SPLIT <fs_trxsi> AT '=' INTO lv_key lv_value.
    IF lv_key CP 'LOW*'.
      lv_index = lv_key+3(1).
      lv_low = lv_value.
    ELSEIF lv_key CP 'HIGH*'.
      lv_index = lv_key+4(1).
      lv_high = lv_value.
    ELSEIF lv_key CP 'OP*'.
      lv_index = lv_key+2(1).
      lv_op = lv_value.
    ENDIF.
    " Se todos os campos (LOW, HIGH, OP) estiverem preenchidos, adiciona ao intervalo
    IF lv_low IS NOT INITIAL AND lv_op IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = lv_op low = lv_low high = lv_high ) TO r_trxsi.
      CLEAR: lv_low, lv_high, lv_op.
    ENDIF.
  ENDLOOP.

****************************
*     ** isrev **
****************************

  LOOP AT lt_isrev ASSIGNING FIELD-SYMBOL(<fs_isrev>).
    SPLIT <fs_isrev> AT '=' INTO lv_key lv_value.
    IF lv_key CP 'LOW*'.
      lv_index = lv_key+3(1).
      lv_low = lv_value.
    ELSEIF lv_key CP 'HIGH*'.
      lv_index = lv_key+4(1).
      lv_high = lv_value.
    ELSEIF lv_key CP 'OP*'.
      lv_index = lv_key+2(1).
      lv_op = lv_value.
    ENDIF.
    " Se todos os campos (LOW, HIGH, OP) estiverem preenchidos, adiciona ao intervalo
    IF lv_low IS NOT INITIAL AND lv_op IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = lv_op low = lv_low high = lv_high ) TO r_isrev.
      CLEAR: lv_low, lv_high, lv_op.
    ENDIF.
  ENDLOOP.

****************************
*     ** rvref **
****************************

  LOOP AT lt_rvref ASSIGNING FIELD-SYMBOL(<fs_rvref>).
    SPLIT <fs_rvref> AT '=' INTO lv_key lv_value.
    IF lv_key CP 'LOW*'.
      lv_index = lv_key+3(1).
      lv_low = lv_value.
    ELSEIF lv_key CP 'HIGH*'.
      lv_index = lv_key+4(1).
      lv_high = lv_value.
    ELSEIF lv_key CP 'OP*'.
      lv_index = lv_key+2(1).
      lv_op = lv_value.
    ENDIF.
    " Se todos os campos (LOW, HIGH, OP) estiverem preenchidos, adiciona ao intervalo
    IF lv_low IS NOT INITIAL AND lv_op IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = lv_op low = lv_low high = lv_high ) TO r_rvref.
      CLEAR: lv_low, lv_high, lv_op.
    ENDIF.
  ENDLOOP.

****************************
*     ** rvdoc **
****************************

  LOOP AT lt_rvdoc ASSIGNING FIELD-SYMBOL(<fs_rvdoc>).
    SPLIT <fs_rvdoc> AT '=' INTO lv_key lv_value.
    IF lv_key CP 'LOW*'.
      lv_index = lv_key+3(1).
      lv_low = lv_value.
    ELSEIF lv_key CP 'HIGH*'.
      lv_index = lv_key+4(1).
      lv_high = lv_value.
    ELSEIF lv_key CP 'OP*'.
      lv_index = lv_key+2(1).
      lv_op = lv_value.
    ENDIF.
    " Se todos os campos (LOW, HIGH, OP) estiverem preenchidos, adiciona ao intervalo
    IF lv_low IS NOT INITIAL AND lv_op IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = lv_op low = lv_low high = lv_high ) TO r_rvdoc.
      CLEAR: lv_low, lv_high, lv_op.
    ENDIF.
  ENDLOOP.
****************************
*     ** isset **
****************************

  LOOP AT lt_isset ASSIGNING FIELD-SYMBOL(<fs_isset>).
    SPLIT <fs_isset> AT '=' INTO lv_key lv_value.
    IF lv_key CP 'LOW*'.
      lv_index = lv_key+3(1).
      lv_low = lv_value.
    ELSEIF lv_key CP 'HIGH*'.
      lv_index = lv_key+4(1).
      lv_high = lv_value.
    ELSEIF lv_key CP 'OP*'.
      lv_index = lv_key+2(1).
      lv_op = lv_value.
    ENDIF.
    " Se todos os campos (LOW, HIGH, OP) estiverem preenchidos, adiciona ao intervalo
    IF lv_low IS NOT INITIAL AND lv_op IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = lv_op low = lv_low high = lv_high ) TO r_isset.
      CLEAR: lv_low, lv_high, lv_op.
    ENDIF.
  ENDLOOP.

****************************
*     ** isstl **
****************************

  LOOP AT lt_isstl ASSIGNING FIELD-SYMBOL(<fs_isstl>).
    SPLIT <fs_isstl> AT '=' INTO lv_key lv_value.
    IF lv_key CP 'LOW*'.
      lv_index = lv_key+3(1).
      lv_low = lv_value.
    ELSEIF lv_key CP 'HIGH*'.
      lv_index = lv_key+4(1).
      lv_high = lv_value.
    ELSEIF lv_key CP 'OP*'.
      lv_index = lv_key+2(1).
      lv_op = lv_value.
    ENDIF.
    " Se todos os campos (LOW, HIGH, OP) estiverem preenchidos, adiciona ao intervalo
    IF lv_low IS NOT INITIAL AND lv_op IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = lv_op low = lv_low high = lv_high ) TO r_isstl.
      CLEAR: lv_low, lv_high, lv_op.
    ENDIF.
  ENDLOOP.

****************************
*     ** prdct **
****************************

  LOOP AT lt_prdct ASSIGNING FIELD-SYMBOL(<fs_prdct>).
    SPLIT <fs_prdct> AT '=' INTO lv_key lv_value.
    IF lv_key CP 'LOW*'.
      lv_index = lv_key+3(1).
      lv_low = lv_value.
    ELSEIF lv_key CP 'HIGH*'.
      lv_index = lv_key+4(1).
      lv_high = lv_value.
    ELSEIF lv_key CP 'OP*'.
      lv_index = lv_key+2(1).
      lv_op = lv_value.
    ENDIF.
    " Se todos os campos (LOW, HIGH, OP) estiverem preenchidos, adiciona ao intervalo
    IF lv_low IS NOT INITIAL AND lv_op IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = lv_op low = lv_low high = lv_high ) TO r_prdct.
      CLEAR: lv_low, lv_high, lv_op.
    ENDIF.
  ENDLOOP.

****************************
*     ** prdco **
****************************

  LOOP AT lt_prdco ASSIGNING FIELD-SYMBOL(<fs_prdco>).
    SPLIT <fs_prdco> AT '=' INTO lv_key lv_value.
    IF lv_key CP 'LOW*'.
      lv_index = lv_key+3(1).
      lv_low = lv_value.
    ELSEIF lv_key CP 'HIGH*'.
      lv_index = lv_key+4(1).
      lv_high = lv_value.
    ELSEIF lv_key CP 'OP*'.
      lv_index = lv_key+2(1).
      lv_op = lv_value.
    ENDIF.
    " Se todos os campos (LOW, HIGH, OP) estiverem preenchidos, adiciona ao intervalo
    IF lv_low IS NOT INITIAL AND lv_op IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = lv_op low = lv_low high = lv_high ) TO r_prdco.
      CLEAR: lv_low, lv_high, lv_op.
    ENDIF.
  ENDLOOP.

****************************
*     ** prddo **
****************************

  LOOP AT lt_prddo ASSIGNING FIELD-SYMBOL(<fs_prddo>).
    SPLIT <fs_prddo> AT '=' INTO lv_key lv_value.
    IF lv_key CP 'LOW*'.
      lv_index = lv_key+3(1).
      lv_low = lv_value.
    ELSEIF lv_key CP 'HIGH*'.
      lv_index = lv_key+4(1).
      lv_high = lv_value.
    ELSEIF lv_key CP 'OP*'.
      lv_index = lv_key+2(1).
      lv_op = lv_value.
    ENDIF.
    " Se todos os campos (LOW, HIGH, OP) estiverem preenchidos, adiciona ao intervalo
    IF lv_low IS NOT INITIAL AND lv_op IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = lv_op low = lv_low high = lv_high ) TO r_prddo.
      CLEAR: lv_low, lv_high, lv_op.
    ENDIF.
  ENDLOOP.

****************************
*     ** prddi **
****************************

  LOOP AT lt_prddi ASSIGNING FIELD-SYMBOL(<fs_prddi>).
    SPLIT <fs_prddi> AT '=' INTO lv_key lv_value.
    IF lv_key CP 'LOW*'.
      lv_index = lv_key+3(1).
      lv_low = lv_value.
    ELSEIF lv_key CP 'HIGH*'.
      lv_index = lv_key+4(1).
      lv_high = lv_value.
    ELSEIF lv_key CP 'OP*'.
      lv_index = lv_key+2(1).
      lv_op = lv_value.
    ENDIF.
    " Se todos os campos (LOW, HIGH, OP) estiverem preenchidos, adiciona ao intervalo
    IF lv_low IS NOT INITIAL AND lv_op IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = lv_op low = lv_low high = lv_high ) TO r_prddi.
      CLEAR: lv_low, lv_high, lv_op.
    ENDIF.
  ENDLOOP.

****************************
*     ** prjcc **
****************************

  LOOP AT lt_prjcc ASSIGNING FIELD-SYMBOL(<fs_prjcc>).
    SPLIT <fs_prjcc> AT '=' INTO lv_key lv_value.
    IF lv_key CP 'LOW*'.
      lv_index = lv_key+3(1).
      lv_low = lv_value.
    ELSEIF lv_key CP 'HIGH*'.
      lv_index = lv_key+4(1).
      lv_high = lv_value.
    ELSEIF lv_key CP 'OP*'.
      lv_index = lv_key+2(1).
      lv_op = lv_value.
    ENDIF.
    " Se todos os campos (LOW, HIGH, OP) estiverem preenchidos, adiciona ao intervalo
    IF lv_low IS NOT INITIAL AND lv_op IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = lv_op low = lv_low high = lv_high ) TO r_prjcc.
      CLEAR: lv_low, lv_high, lv_op.
    ENDIF.
  ENDLOOP.

****************************
*     ** prjfy **
****************************

  LOOP AT lt_prjfy ASSIGNING FIELD-SYMBOL(<fs_prjfy>).
    SPLIT <fs_prjfy> AT '=' INTO lv_key lv_value.
    IF lv_key CP 'LOW*'.
      lv_index = lv_key+3(1).
      lv_low = lv_value.
    ELSEIF lv_key CP 'HIGH*'.
      lv_index = lv_key+4(1).
      lv_high = lv_value.
    ELSEIF lv_key CP 'OP*'.
      lv_index = lv_key+2(1).
      lv_op = lv_value.
    ENDIF.
    " Se todos os campos (LOW, HIGH, OP) estiverem preenchidos, adiciona ao intervalo
    IF lv_low IS NOT INITIAL AND lv_op IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = lv_op low = lv_low high = lv_high ) TO r_prjfy.
      CLEAR: lv_low, lv_high, lv_op.
    ENDIF.
  ENDLOOP.

****************************
*     ** prdje **
****************************

  LOOP AT lt_prdje ASSIGNING FIELD-SYMBOL(<fs_prdje>).
    SPLIT <fs_prdje> AT '=' INTO lv_key lv_value.
    IF lv_key CP 'LOW*'.
      lv_index = lv_key+3(1).
      lv_low = lv_value.
    ELSEIF lv_key CP 'HIGH*'.
      lv_index = lv_key+4(1).
      lv_high = lv_value.
    ELSEIF lv_key CP 'OP*'.
      lv_index = lv_key+2(1).
      lv_op = lv_value.
    ENDIF.
    " Se todos os campos (LOW, HIGH, OP) estiverem preenchidos, adiciona ao intervalo
    IF lv_low IS NOT INITIAL AND lv_op IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = lv_op low = lv_low high = lv_high ) TO r_prdje.
      CLEAR: lv_low, lv_high, lv_op.
    ENDIF.
  ENDLOOP.


****************************
*     ** prdji **
****************************

  LOOP AT lt_prdji ASSIGNING FIELD-SYMBOL(<fs_prdji>).
    SPLIT <fs_prdji> AT '=' INTO lv_key lv_value.
    IF lv_key CP 'LOW*'.
      lv_index = lv_key+3(1).
      lv_low = lv_value.
    ELSEIF lv_key CP 'HIGH*'.
      lv_index = lv_key+4(1).
      lv_high = lv_value.
    ELSEIF lv_key CP 'OP*'.
      lv_index = lv_key+2(1).
      lv_op = lv_value.
    ENDIF.
    " Se todos os campos (LOW, HIGH, OP) estiverem preenchidos, adiciona ao intervalo
    IF lv_low IS NOT INITIAL AND lv_op IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = lv_op low = lv_low high = lv_high ) TO r_prdji.
      CLEAR: lv_low, lv_high, lv_op.
    ENDIF.
  ENDLOOP.
****************************
*     ** srdct **
****************************

  LOOP AT lt_srdct ASSIGNING FIELD-SYMBOL(<fs_srdct>).
    SPLIT <fs_srdct> AT '=' INTO lv_key lv_value.
    IF lv_key CP 'LOW*'.
      lv_index = lv_key+3(1).
      lv_low = lv_value.
    ELSEIF lv_key CP 'HIGH*'.
      lv_index = lv_key+4(1).
      lv_high = lv_value.
    ELSEIF lv_key CP 'OP*'.
      lv_index = lv_key+2(1).
      lv_op = lv_value.
    ENDIF.
    " Se todos os campos (LOW, HIGH, OP) estiverem preenchidos, adiciona ao intervalo
    IF lv_low IS NOT INITIAL AND lv_op IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = lv_op low = lv_low high = lv_high ) TO r_srdct.
      CLEAR: lv_low, lv_high, lv_op.
    ENDIF.
  ENDLOOP.

****************************
*     ** srlog **
****************************

  LOOP AT lt_srlog ASSIGNING FIELD-SYMBOL(<fs_srlog>).
    SPLIT <fs_srlog> AT '=' INTO lv_key lv_value.
    IF lv_key CP 'LOW*'.
      lv_index = lv_key+3(1).
      lv_low = lv_value.
    ELSEIF lv_key CP 'HIGH*'.
      lv_index = lv_key+4(1).
      lv_high = lv_value.
    ELSEIF lv_key CP 'OP*'.
      lv_index = lv_key+2(1).
      lv_op = lv_value.
    ENDIF.
    " Se todos os campos (LOW, HIGH, OP) estiverem preenchidos, adiciona ao intervalo
    IF lv_low IS NOT INITIAL AND lv_op IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = lv_op low = lv_low high = lv_high ) TO r_srlog.
      CLEAR: lv_low, lv_high, lv_op.
    ENDIF.
  ENDLOOP.



ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_AJUSTA_DATA
*&---------------------------------------------------------------------*
FORM f_ajusta_data USING p_in CHANGING p_out.

  IF p_in IS NOT INITIAL.
    IF p_in(1) CA sy-abcde.
    ELSE.
      IF p_in CA '/'.
        CONCATENATE p_in+6(4) p_in+3(2) p_in(2) INTO p_out.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form zexcel_s_export_xls
*&---------------------------------------------------------------------*
FORM zexcel_s_export_xls TABLES   pt_line
                          USING    pv_file.

  DATA: lo_excel        TYPE REF TO zcl_excel,
        lo_style_title  TYPE REF TO zcl_excel_style,
        lo_excel_writer TYPE REF TO zif_excel_writer,
        lo_worksheet    TYPE REF TO zcl_excel_worksheet,
        lo_border_light TYPE REF TO zcl_excel_style_border,
        lo_style_color0 TYPE REF TO zcl_excel_style,
        lo_style_color1 TYPE REF TO zcl_excel_style,
        lo_style_color2 TYPE REF TO zcl_excel_style,
        lo_style_color3 TYPE REF TO zcl_excel_style,
        lo_style_color4 TYPE REF TO zcl_excel_style,
        lo_style_color5 TYPE REF TO zcl_excel_style,
        lo_style_color6 TYPE REF TO zcl_excel_style,
        lo_style_color7 TYPE REF TO zcl_excel_style,
        lo_style_credit TYPE REF TO zcl_excel_style,
        lo_style_link   TYPE REF TO zcl_excel_style,
        lo_column       TYPE REF TO zcl_excel_column,
        lo_row          TYPE REF TO zcl_excel_row,
        lo_hyperlink    TYPE REF TO zcl_excel_hyperlink.

  DATA: lv_style_color0_guid TYPE zexcel_cell_style,
        lv_style_color1_guid TYPE zexcel_cell_style,
        lv_style_color2_guid TYPE zexcel_cell_style,
        lv_style_color3_guid TYPE zexcel_cell_style,
        lv_style_color4_guid TYPE zexcel_cell_style,
        lv_style_color5_guid TYPE zexcel_cell_style,
        lv_style_color6_guid TYPE zexcel_cell_style,
        lv_style_color7_guid TYPE zexcel_cell_style,
        lv_style_credit_guid TYPE zexcel_cell_style,
        lv_style_title_guid  TYPE zexcel_cell_style,
        lv_style_link_guid   TYPE zexcel_cell_style.

  DATA: lv_col_str TYPE zexcel_cell_column_alpha,
        lv_row     TYPE i,
        lv_col     TYPE i,
        lt_mapper  TYPE TABLE OF zexcel_cell_style,
        ls_mapper  TYPE zexcel_cell_style.

  DATA: lv_file      TYPE xstring,
        lv_bytecount TYPE i,
        lt_file_tab  TYPE solix_tab.

  DATA: lv_full_path      TYPE string,
        lv_workdir        TYPE string,
        lv_file_separator TYPE c.

  CONSTANTS: lc_typekind_string TYPE abap_typekind VALUE cl_abap_typedescr=>typekind_string,
             lc_typekind_packed TYPE abap_typekind VALUE cl_abap_typedescr=>typekind_packed,
             lc_typekind_num    TYPE abap_typekind VALUE cl_abap_typedescr=>typekind_num,
             lc_typekind_date   TYPE abap_typekind VALUE cl_abap_typedescr=>typekind_date,
             lc_typekind_s_ls   TYPE string VALUE 's_leading_blanks'.

  CONCATENATE pv_file '\' sy-datum '_' sy-uzeit '.xlsx' INTO lv_full_path.


  " Creates active sheet
  CREATE OBJECT lo_excel.

*  CREATE OBJECT lo_border_light.
*  lo_border_light->border_color-rgb = zcl_excel_style_color=>c_black.
*  lo_border_light->border_style = zcl_excel_style_border=>c_border_medium.

  " Create color white


  " Styles
  lo_style_title                   = lo_excel->add_new_style( ).
  lo_style_title->font->bold       = abap_true.
  lv_style_title_guid              = lo_style_title->get_guid( ).


  " Get active sheet
  lo_worksheet = lo_excel->get_active_worksheet( ).
*  lo_worksheet->set_title( ip_title = 'Sheet' ).


  lv_row = 1.
  lv_col = 1.


  DATA: gt_xlsx           TYPE TABLE OF zexcel_s_export_xls,
        gs_xlsx           TYPE zexcel_s_export_xls,
        lv_line           TYPE numc2,
        lv_row_n          TYPE zexcel_cell_row,

        LV_coluna_08_CHAR TYPE char40,
        LV_coluna_10_CHAR TYPE char40,
        LV_coluna_12_CHAR TYPE char40,

        LV_coluna_08_CURR TYPE ekpo-netpr,
        LV_coluna_10_CURR TYPE ekpo-netpr,
        LV_coluna_12_CURR TYPE ekpo-netpr,

        LV_coluna_03_CHAR TYPE char40,
        LV_coluna_24_CHAR TYPE char40,
        LV_coluna_25_CHAR TYPE char40,

        LV_coluna_08_DATM TYPE sy-datum,
        LV_coluna_10_DATM TYPE sy-datum,
        LV_coluna_12_DATM TYPE sy-datum,
        LV_bool           TYPE boolean,
        LV_bool_stop      TYPE boolean.

  LOOP AT pt_line ASSIGNING FIELD-SYMBOL(<FS_line>).

    IF gs_xlsx-coluna_03 IS NOT INITIAL AND LV_bool IS INITIAL AND LV_bool_stop IS INITIAL.
      LV_bool = abap_true.
    ENDIF.


    CLEAR gs_xlsx.

    SPLIT <FS_line> AT ';' INTO
    gs_xlsx-coluna_01
    gs_xlsx-coluna_02
*    gs_xlsx-coluna_03
    LV_coluna_03_CHAR
    gs_xlsx-coluna_04
    gs_xlsx-coluna_05
    gs_xlsx-coluna_06
    gs_xlsx-coluna_07
    LV_coluna_08_CHAR
*    gs_xlsx-coluna_08
    gs_xlsx-coluna_09
    LV_coluna_10_CHAR
*    gs_xlsx-coluna_10
    gs_xlsx-coluna_11
    LV_coluna_12_CHAR
*    gs_xlsx-coluna_12
    gs_xlsx-coluna_13
    gs_xlsx-coluna_14
    gs_xlsx-coluna_15
    gs_xlsx-coluna_16
    gs_xlsx-coluna_17
    gs_xlsx-coluna_18
    gs_xlsx-coluna_19
    gs_xlsx-coluna_20
    gs_xlsx-coluna_21
    gs_xlsx-coluna_22
    gs_xlsx-coluna_23
*    gs_xlsx-coluna_24
*    gs_xlsx-coluna_25
    LV_coluna_24_CHAR
    LV_coluna_25_CHAR
    gs_xlsx-coluna_26
    gs_xlsx-coluna_27
    gs_xlsx-coluna_28
    gs_xlsx-coluna_29
    gs_xlsx-coluna_30.

    PERFORM convert_char_to_curr USING LV_coluna_08_CHAR CHANGING gs_xlsx-coluna_08.
    PERFORM convert_char_to_curr USING LV_coluna_10_CHAR CHANGING gs_xlsx-coluna_10.
    PERFORM convert_char_to_curr USING LV_coluna_12_CHAR CHANGING gs_xlsx-coluna_12.

    PERFORM convert_char_to_DATM USING LV_coluna_03_CHAR CHANGING gs_xlsx-coluna_03.
    PERFORM convert_char_to_DATM USING LV_coluna_24_CHAR CHANGING gs_xlsx-coluna_24.
    PERFORM convert_char_to_DATM USING LV_coluna_25_CHAR CHANGING gs_xlsx-coluna_25.

    CONDENSE:
    gs_xlsx-coluna_01,
    gs_xlsx-coluna_02,
    gs_xlsx-coluna_03,
    gs_xlsx-coluna_04,
    gs_xlsx-coluna_05,
    gs_xlsx-coluna_06,
    gs_xlsx-coluna_07,
    gs_xlsx-coluna_08,
    gs_xlsx-coluna_09,
    gs_xlsx-coluna_10,
    gs_xlsx-coluna_11,
    gs_xlsx-coluna_12,
    gs_xlsx-coluna_13,
    gs_xlsx-coluna_14,
    gs_xlsx-coluna_15,
    gs_xlsx-coluna_16,
    gs_xlsx-coluna_17,
    gs_xlsx-coluna_18,
    gs_xlsx-coluna_19,
    gs_xlsx-coluna_20,
    gs_xlsx-coluna_21,
    gs_xlsx-coluna_22,
    gs_xlsx-coluna_23,
    gs_xlsx-coluna_24,
    gs_xlsx-coluna_25,
    gs_xlsx-coluna_26,
    gs_xlsx-coluna_27,
    gs_xlsx-coluna_28,
    gs_xlsx-coluna_29,
    gs_xlsx-coluna_30.

    APPEND gs_xlsx TO gt_xlsx.
    ADD 1 TO lv_row_n.




    IF LV_bool IS INITIAL.
      lo_worksheet->set_cell( ip_column = 'A'  ip_row = lv_row_n ip_value = gs_xlsx-coluna_01 ip_style = lv_style_title_guid ).
      lo_worksheet->set_cell( ip_column = 'B'  ip_row = lv_row_n ip_value = gs_xlsx-coluna_02 ip_style = lv_style_title_guid ).
    ELSE.
      lo_worksheet->set_cell( ip_column = 'A'  ip_row = lv_row_n ip_value = gs_xlsx-coluna_01 ).
      lo_worksheet->set_cell( ip_column = 'B'  ip_row = lv_row_n ip_value = gs_xlsx-coluna_02 ).
    ENDIF.


    IF gs_xlsx-coluna_03 IS NOT INITIAL.
      IF gs_xlsx-coluna_03(1) CA sy-abcde OR gs_xlsx-coluna_03+1(1) CA sy-abcde.
        lo_worksheet->set_cell( ip_column = 'C'  ip_row = lv_row_n ip_value = gs_xlsx-coluna_03 ip_style = lv_style_title_guid ).
      ELSE.
        lo_worksheet->set_cell( ip_column = 'C'  ip_row = lv_row_n ip_value = gs_xlsx-coluna_03 ip_abap_type = lc_typekind_date ).
      ENDIF.
    ENDIF.

    IF LV_bool IS INITIAL.
      lo_worksheet->set_cell( ip_column = 'D'  ip_row = lv_row_n ip_value = gs_xlsx-coluna_04 ip_style = lv_style_title_guid ).
      lo_worksheet->set_cell( ip_column = 'E'  ip_row = lv_row_n ip_value = gs_xlsx-coluna_05 ip_style = lv_style_title_guid ).
      lo_worksheet->set_cell( ip_column = 'F'  ip_row = lv_row_n ip_value = gs_xlsx-coluna_06 ip_style = lv_style_title_guid ).
      lo_worksheet->set_cell( ip_column = 'G'  ip_row = lv_row_n ip_value = gs_xlsx-coluna_07 ip_style = lv_style_title_guid ).
    ELSE.
      lo_worksheet->set_cell( ip_column = 'D'  ip_row = lv_row_n ip_value = gs_xlsx-coluna_04 ).
      lo_worksheet->set_cell( ip_column = 'E'  ip_row = lv_row_n ip_value = gs_xlsx-coluna_05 ).
      lo_worksheet->set_cell( ip_column = 'F'  ip_row = lv_row_n ip_value = gs_xlsx-coluna_06 ).
      lo_worksheet->set_cell( ip_column = 'G'  ip_row = lv_row_n ip_value = gs_xlsx-coluna_07 ).
    ENDIF.

    IF gs_xlsx-coluna_08 IS NOT INITIAL.
      IF gs_xlsx-coluna_08(1) CA sy-abcde OR gs_xlsx-coluna_08+1(1) CA sy-abcde.
        lo_worksheet->set_cell( ip_column = 'H'  ip_row = lv_row_n ip_value = gs_xlsx-coluna_08 ip_style = lv_style_title_guid ).
      ELSE.
        lo_worksheet->set_cell( ip_column = 'H'  ip_row = lv_row_n ip_value = gs_xlsx-coluna_08 ip_abap_type = lc_typekind_packed ).
      ENDIF.
    ENDIF.

    IF LV_bool IS INITIAL.
      lo_worksheet->set_cell( ip_column = 'I'  ip_row = lv_row_n ip_value = gs_xlsx-coluna_09 ip_style = lv_style_title_guid ).
    ELSE.
      lo_worksheet->set_cell( ip_column = 'I'  ip_row = lv_row_n ip_value = gs_xlsx-coluna_09 ).
    ENDIF.

    IF gs_xlsx-coluna_10 IS NOT INITIAL.
      IF gs_xlsx-coluna_10(1) CA sy-abcde OR gs_xlsx-coluna_10+1(1) CA sy-abcde.
        lo_worksheet->set_cell( ip_column = 'J'  ip_row = lv_row_n ip_value = gs_xlsx-coluna_10  ip_style = lv_style_title_guid ).
      ELSE.
        lo_worksheet->set_cell( ip_column = 'J'  ip_row = lv_row_n ip_value = gs_xlsx-coluna_10 ip_abap_type = lc_typekind_packed ).
      ENDIF.
    ENDIF.

    IF LV_bool IS INITIAL.
      lo_worksheet->set_cell( ip_column = 'K'  ip_row = lv_row_n ip_value = gs_xlsx-coluna_11 ip_style = lv_style_title_guid ).
    ELSE.
      lo_worksheet->set_cell( ip_column = 'K'  ip_row = lv_row_n ip_value = gs_xlsx-coluna_11 ).
    ENDIF.


    IF gs_xlsx-coluna_12 IS NOT INITIAL.
      IF gs_xlsx-coluna_12(1) CA sy-abcde OR gs_xlsx-coluna_12+1(1) CA sy-abcde.
        lo_worksheet->set_cell( ip_column = 'L'  ip_row = lv_row_n ip_value = gs_xlsx-coluna_12 ip_style = lv_style_title_guid ).
      ELSE.
        lo_worksheet->set_cell( ip_column = 'L'  ip_row = lv_row_n ip_value = gs_xlsx-coluna_12 ip_abap_type = lc_typekind_packed ).
      ENDIF.
    ENDIF.


    IF LV_bool IS INITIAL.
      lo_worksheet->set_cell( ip_column = 'M'  ip_row = lv_row_n ip_value = gs_xlsx-coluna_13 ip_style = lv_style_title_guid ).
      lo_worksheet->set_cell( ip_column = 'N'  ip_row = lv_row_n ip_value = gs_xlsx-coluna_14 ip_style = lv_style_title_guid ).
      lo_worksheet->set_cell( ip_column = 'O'  ip_row = lv_row_n ip_value = gs_xlsx-coluna_15 ip_style = lv_style_title_guid ).
      lo_worksheet->set_cell( ip_column = 'P'  ip_row = lv_row_n ip_value = gs_xlsx-coluna_16 ip_style = lv_style_title_guid ).
      lo_worksheet->set_cell( ip_column = 'Q'  ip_row = lv_row_n ip_value = gs_xlsx-coluna_17 ip_style = lv_style_title_guid ).
      lo_worksheet->set_cell( ip_column = 'R'  ip_row = lv_row_n ip_value = gs_xlsx-coluna_18 ip_style = lv_style_title_guid ).
      lo_worksheet->set_cell( ip_column = 'S'  ip_row = lv_row_n ip_value = gs_xlsx-coluna_19 ip_style = lv_style_title_guid ).
      lo_worksheet->set_cell( ip_column = 'T'  ip_row = lv_row_n ip_value = gs_xlsx-coluna_20 ip_style = lv_style_title_guid ).
      lo_worksheet->set_cell( ip_column = 'U'  ip_row = lv_row_n ip_value = gs_xlsx-coluna_21 ip_style = lv_style_title_guid ).
      lo_worksheet->set_cell( ip_column = 'V'  ip_row = lv_row_n ip_value = gs_xlsx-coluna_22 ip_style = lv_style_title_guid ).
      lo_worksheet->set_cell( ip_column = 'W'  ip_row = lv_row_n ip_value = gs_xlsx-coluna_23 ip_style = lv_style_title_guid ).
    ELSE.
      lo_worksheet->set_cell( ip_column = 'M'  ip_row = lv_row_n ip_value = gs_xlsx-coluna_13 ).
      lo_worksheet->set_cell( ip_column = 'N'  ip_row = lv_row_n ip_value = gs_xlsx-coluna_14 ).
      lo_worksheet->set_cell( ip_column = 'O'  ip_row = lv_row_n ip_value = gs_xlsx-coluna_15 ).
      lo_worksheet->set_cell( ip_column = 'P'  ip_row = lv_row_n ip_value = gs_xlsx-coluna_16 ).
      lo_worksheet->set_cell( ip_column = 'Q'  ip_row = lv_row_n ip_value = gs_xlsx-coluna_17 ).
      lo_worksheet->set_cell( ip_column = 'R'  ip_row = lv_row_n ip_value = gs_xlsx-coluna_18 ).
      lo_worksheet->set_cell( ip_column = 'S'  ip_row = lv_row_n ip_value = gs_xlsx-coluna_19 ).
      lo_worksheet->set_cell( ip_column = 'T'  ip_row = lv_row_n ip_value = gs_xlsx-coluna_20 ).
      lo_worksheet->set_cell( ip_column = 'U'  ip_row = lv_row_n ip_value = gs_xlsx-coluna_21 ).
      lo_worksheet->set_cell( ip_column = 'V'  ip_row = lv_row_n ip_value = gs_xlsx-coluna_22 ).
      lo_worksheet->set_cell( ip_column = 'W'  ip_row = lv_row_n ip_value = gs_xlsx-coluna_23 ).
    ENDIF.

    IF gs_xlsx-coluna_24 IS NOT INITIAL.
      IF gs_xlsx-coluna_24(1) CA sy-abcde OR gs_xlsx-coluna_24+1(1) CA sy-abcde.
        lo_worksheet->set_cell( ip_column = 'X'  ip_row = lv_row_n ip_value = gs_xlsx-coluna_24  ip_style = lv_style_title_guid ).
      ELSE.
        lo_worksheet->set_cell( ip_column = 'X'  ip_row = lv_row_n ip_value = gs_xlsx-coluna_24 ip_abap_type = lc_typekind_date ).
      ENDIF.
    ENDIF.
*    lo_worksheet->set_cell( ip_column = 'X'  ip_row = lv_row_n ip_value = gs_xlsx-coluna_24 ).

    IF gs_xlsx-coluna_25 IS NOT INITIAL.
      IF gs_xlsx-coluna_25(1) CA sy-abcde OR gs_xlsx-coluna_25+1(1) CA sy-abcde.
        lo_worksheet->set_cell( ip_column = 'Y'  ip_row = lv_row_n ip_value = gs_xlsx-coluna_25 ip_style = lv_style_title_guid ).
      ELSE.
        lo_worksheet->set_cell( ip_column = 'Y'  ip_row = lv_row_n ip_value = gs_xlsx-coluna_25 ip_abap_type = lc_typekind_date ).
      ENDIF.
    ENDIF.
*    lo_worksheet->set_cell( ip_column = 'Y'  ip_row = lv_row_n ip_value = gs_xlsx-coluna_25 ).

    IF LV_bool IS INITIAL.
      lo_worksheet->set_cell( ip_column = 'Z'  ip_row = lv_row_n ip_value = gs_xlsx-coluna_26 ip_style = lv_style_title_guid ).
      lo_worksheet->set_cell( ip_column = 'AA' ip_row = lv_row_n ip_value = gs_xlsx-coluna_27 ip_style = lv_style_title_guid ).
      lo_worksheet->set_cell( ip_column = 'AB' ip_row = lv_row_n ip_value = gs_xlsx-coluna_28 ip_style = lv_style_title_guid ).
      lo_worksheet->set_cell( ip_column = 'AC' ip_row = lv_row_n ip_value = gs_xlsx-coluna_29 ip_style = lv_style_title_guid ).
      lo_worksheet->set_cell( ip_column = 'AD' ip_row = lv_row_n ip_value = gs_xlsx-coluna_30 ip_style = lv_style_title_guid ).
    ELSE.
      lo_worksheet->set_cell( ip_column = 'Z'  ip_row = lv_row_n ip_value = gs_xlsx-coluna_26 ).
      lo_worksheet->set_cell( ip_column = 'AA' ip_row = lv_row_n ip_value = gs_xlsx-coluna_27 ).
      lo_worksheet->set_cell( ip_column = 'AB' ip_row = lv_row_n ip_value = gs_xlsx-coluna_28 ).
      lo_worksheet->set_cell( ip_column = 'AC' ip_row = lv_row_n ip_value = gs_xlsx-coluna_29 ).
      lo_worksheet->set_cell( ip_column = 'AD' ip_row = lv_row_n ip_value = gs_xlsx-coluna_30 ).
    ENDIF.

    IF lv_bool IS NOT INITIAL.
      LV_bool_stop = abap_true.
    ENDIF.

  ENDLOOP.

  lo_worksheet->set_show_gridlines( i_show_gridlines = abap_true ).


  lo_column = lo_worksheet->get_column( ip_column = 'AP' ).
  lo_column->set_auto_size( ip_auto_size = abap_true ).

  CREATE OBJECT lo_excel_writer TYPE zcl_excel_writer_2007.
  lv_file = lo_excel_writer->write_file( lo_excel ).

  " Convert to binary
  CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
    EXPORTING
      buffer        = lv_file
    IMPORTING
      output_length = lv_bytecount
    TABLES
      binary_tab    = lt_file_tab.

  cl_gui_frontend_services=>gui_download( EXPORTING bin_filesize = lv_bytecount
                                                    filename     = lv_full_path
                                                    filetype     = 'BIN'
                                           CHANGING data_tab     = lt_file_tab ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONVERT_CHAR_TO_CURR
*&---------------------------------------------------------------------*
FORM convert_char_to_curr  USING    p_IN
                           CHANGING p_OUT.

  DATA:
    lv_neg  TYPE c,
    LV_p_IN TYPE char15,
    lv_curr TYPE ekpo-netpr.

  CHECK p_IN IS NOT INITIAL.
  IF p_IN(1) CA sy-abcde.
    p_OUT = p_IN.
  ELSE.
    CLEAR: lv_neg, p_OUT.
    IF p_IN  CA '-'.
      lv_neg = 'X'.
    ENDIF.

    LV_p_IN = p_IN.
    REPLACE ALL OCCURRENCES OF '-' IN LV_p_IN WITH ''.
    REPLACE ALL OCCURRENCES OF '.' IN LV_p_IN WITH ''.
    REPLACE ALL OCCURRENCES OF ',' IN LV_p_IN WITH '.'.

    IF lv_neg IS NOT INITIAL.
      lv_curr = LV_p_IN * -1.
    ELSE.
      lv_curr = LV_p_IN.
    ENDIF.

    p_OUT = lv_curr.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form convert_char_to_DATM
*&---------------------------------------------------------------------*
FORM convert_char_to_DATM  USING    p_IN
                           CHANGING p_OUT.

  DATA:
    LV_p_IN TYPE char10.

  CHECK p_IN IS NOT INITIAL.
  IF p_IN(1) CA sy-abcde.
    p_OUT = p_IN.
  ELSE.
    CLEAR: p_OUT.
    CONCATENATE p_IN+6(4) p_IN+3(2) p_IN(2) INTO p_OUT.
  ENDIF.

ENDFORM.