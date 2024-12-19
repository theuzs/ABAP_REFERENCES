@Metadata.layer: #CORE
@UI.headerInfo: {
    typeName: 'Item',
    typeNamePlural: 'Itens'
    }


annotate entity Z_FI_I_GLAccountLineItem with
{

  @UI: {
      lineItem: [

          {   position: 10,
              value: 'status',
              criticality: 's_status'
          }
      ]
  }
  status;
}