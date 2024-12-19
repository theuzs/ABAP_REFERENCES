@AbapCatalog.sqlViewName: 'ZFICOMPANYVH'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Company Value Help'
@Metadata.ignorePropagatedAnnotations: true
define view Z_FI_COMPANY_VH
  as select distinct from I_GLAccountLineItemRawData as gl
    inner join            I_CompanyCode              as cc on gl.CompanyCode = cc.CompanyCode
{
  key gl.CompanyCode     as s_compy,
      gl.SourceLedger    as s_ledger,
      cc.CompanyCodeName as CompanyName, // Nome da Empresa
      cc.CityName        as City,        // Cidade
      cc.Country         as Country,     // País
      cc.Currency        as Currency,    // Moeda
      cc.Language        as Language     // Idioma
}
