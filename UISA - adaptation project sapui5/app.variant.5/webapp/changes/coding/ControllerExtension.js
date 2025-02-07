sap.ui.define(
    [
        'sap/ui/core/mvc/ControllerExtension',
        'sap/ui/core/mvc/OverrideExecution',
        "sap/ui/model/json/JSONModel",
        "sap/m/MessageToast"
    
    ],
    function (ControllerExtension, OverrideExecution, JSONModel, MessageToast) {

        'use strict';
        return ControllerExtension.extend("customer.app.variant.4.ObjectPage", {

            handleLiveChangeJust: function (oEvent) {
                var oTextArea = oEvent.getSource(),
                    sValue = oTextArea.getValue().trim(), // Remove espaços em branco no início e fim
                    iValueLength = sValue.length,
                    sState,
                    sStateText = "";
            
                // Validação: Campo obrigatório
                if (iValueLength === 0) {
                    sState = sap.ui.core.ValueState.Error;
                    sStateText = "Campo justificativa é obrigatório";
                } 
                // Validação: Comprimento mínimo de 50 caracteres
                else if (iValueLength < 50) {
                    sState = sap.ui.core.ValueState.Warning;
                    sStateText = "Comprimento da justificativa deve ser maior que 50 caracteres";
                } 
                // Caso válido
                else {
                    sState = sap.ui.core.ValueState.None;
                }
            
                oTextArea.setValueState(sState);
                oTextArea.setValueStateText(sStateText);
            },
            
            handleLiveChangeReg: function (oEvent) {
                var oTextArea = oEvent.getSource(),
                    sValue = oTextArea.getValue().trim(),
                    iValueLength = sValue.length,
                    sState,
                    sStateText = "";
            
                // Validação: Campo obrigatório
                if (iValueLength === 0) {
                    sState = sap.ui.core.ValueState.Error;
                    sStateText = "Campo regularização é obrigatório";
                } 
                // Validação: Comprimento mínimo de 50 caracteres
                else if (iValueLength < 50) {
                    sState = sap.ui.core.ValueState.Warning;
                    sStateText = "Comprimento da regularização deve ser maior que 50 caracteres";
                } 
                // Caso válido
                else {
                    sState = sap.ui.core.ValueState.None;
                }
            
                oTextArea.setValueState(sState);
                oTextArea.setValueStateText(sStateText);
            },
            
            publicMethod: function(on_Init) {
            // Limpar variáveis antes de abrir a tela
            oModel.setProperty("/Justificativa", "");
            oModel.setProperty("/Regularizacao", "");
            }            
            , 
            formatarData: function (timestamp) {
                var data = new Date(parseInt(timestamp.match(/\d+/)[0])); // Extrai e converte o número
                data.setDate(data.getDate() + 1); // Soma 1 no dia
                
                return data.toLocaleDateString("pt-BR"); // Formata para DD/MM/YYYY
            },

            formatarHora : function (isoHora) {
                var match = isoHora.match(/PT(\d+)H(\d+)M(\d+)S/);
                if (!match) return "00:00:00"; // Retorno padrão caso falhe
            
                var horas = match[1].padStart(2, "0");
                var minutos = match[2].padStart(2, "0");
                var segundos = match[3].padStart(2, "0");
            
                return `${horas}:${minutos}:${segundos}`;
            },


            publicMethod: function(oEvent) {
                var oDate = new Date();
                var sHoraAtual = "PT" + 
                String(oDate.getHours()).padStart(2, "0") + "H" + 
                String(oDate.getMinutes()).padStart(2, "0") + "M" + 
                String(oDate.getSeconds()).padStart(2, "0") + "S";
                var scurrentUser = sap.ushell?.Container?.getService("UserInfo")?.getId() || "Usuário não encontrado";
                var oModel = this.getView().getModel("oModel");
                var sData = oDate.toISOString().split("T")[0] + "T00:00:00"
                sHoraAtual = sHoraAtual.replace("MM", "M");

                var sJustificativa = oModel.getProperty("/Justificativa");
                var sRegularizacao = oModel.getProperty("/Regularizacao");

                // Recupera os controles de entrada (ajuste os IDs conforme necessário)
                var oInputJustificativa = sap.ui.getCore().byId("ui.s2p.mm.profrequisition.maintains1::sap.suite.ui.generic.template.ObjectPage.view.Details::C_PurchaseReqnHeader--customer.app.variant.4.idTextAreaJustificativa");
                var oInputRegularizacao = sap.ui.getCore().byId("ui.s2p.mm.profrequisition.maintains1::sap.suite.ui.generic.template.ObjectPage.view.Details::C_PurchaseReqnHeader--customer.app.variant.4.idTextAreaRegularizacao");

                // Validação: Verifica se os campos estão preenchidos

                    if (oInputJustificativa && !sJustificativa) {
                        // oInputJustificativa.setValueState(sap.ui.core.ValueState.Error);
                        // oInputJustificativa.setValueStateText("Campo justificativa é obrigatório");
                        return;
                    }else{
                        // oInputJustificativa.setValueState(sap.ui.core.ValueState.None);
                    }


                    if (oInputRegularizacao && !sRegularizacao) {

                        // oInputRegularizacao.setValueState(sap.ui.core.ValueState.Error);
                        // oInputRegularizacao.setValueStateText("Campo regularização é obrigatório");
                        return;
                    }else{
                        // oInputRegularizacao.setValueState(sap.ui.core.ValueState.None);
                    }


            // Validação: Verifica se os campos possuem pelo menos 50 caracteres
            if (sJustificativa.length < 50  && oInputJustificativa ) {
                // oInputJustificativa.setValueState(sap.ui.core.ValueState.Warning);
                // oInputJustificativa.setValueStateText("Comprimento da justificativa deve ser maior que 50 caracteres");
                return;
               }
            if (sRegularizacao.length < 50 && oInputRegularizacao  ) {
                // oInputRegularizacao.setValueState(sap.ui.core.ValueState.Warning);
                // oInputRegularizacao.setValueStateText("Comprimento da regularização deve ser maior que 50 caracteres.");
                return;
               }
                // Dados a serem enviados
                var oPayload = {
                    "Banfn": "9999999999",
                    "Texto_just1": sJustificativa,
                    "Texto_just2": sRegularizacao,
                    "Usuario": scurrentUser,
                    "Data": sData, 
                    "Hora": sHoraAtual
                };
            
                const sUrl = "/sap/opu/odata/sap/ZMM_JUST_CDS/ZMM_JUST";
            
                // Etapa 1: Obter o token CSRF
                fetch(sUrl, {
                    method: "GET",
                    headers: {
                        "X-CSRF-Token": "Fetch"
                    }
                })
                .then(response => {
                    if (!response.ok) {
                        throw new Error('Erro ao buscar token CSRF');
                    }
                    return response.headers.get("X-CSRF-Token");
                })
                .then(token => {
                    this.token = token;
                    // console.log("Token CSRF obtido:", this.token);
            
                    // Etapa 2: Verificar se a justificativa já existe (GET)
                    return fetch(sUrl + "('9999999999')", {
                        method: "GET",
                        headers: {
                            "X-CSRF-Token": this.token
                        }
                    });
                })
                .then(response => {
                    if (!response.ok && response.status !== 404) {
                        throw new Error('Erro ao verificar justificativa existente');
                    }
            
                    // Caso a justificativa não exista, cria um novo registro (POST)
                    if (response.status === 404) {
                        return fetch(sUrl, {
                            method: "POST",
                            headers: {
                                "Content-Type": "application/json",
                                "X-CSRF-Token": this.token
                            },
                            body: JSON.stringify(oPayload)
                        })
                        .then(response => {
                            if (!response.ok) {
                                return response.text().then(text => { throw new Error(text); });
                            }
                            return response;
                        });
                    } else {
                        // Caso a justificativa já exista, atualiza a justificativa (PUT)
                        return fetch(sUrl + "('9999999999')", {
                            method: "PUT",
                            headers: {
                                "Content-Type": "application/json",
                                "X-CSRF-Token": this.token
                            },
                            body: JSON.stringify(oPayload)
                        })
                        // .then(response => {
                        //     if (!response.ok) {
                        //         return response.text().then(text => { throw new Error(text); });
                        //     }
                        //     return response;
                        // })
                        ;
                    }
                })
                .then(response => {
                    if (!response.ok) {
                        throw new Error('Erro ao salvar ou atualizar justificativa');
                    }
                    // return response.json();
                })
                .then(data => {
                    console.log("Resposta do servidor:", data);
                    sap.m.MessageToast.show("Justificativa salva/atualizada com sucesso!");
                })
                .catch(error => {
                    // sap.m.MessageToast.show(error.message);
                    console.log(error);
                });
            },
        
        
            _onPurchaseReqTypeChange: function (oEvent) {
                var sValue = oEvent.getSource().getValue(); // Obtém o novo valor do campo
            
                var extractedCode = sValue; // Por padrão, usa o valor sem espaços

                if (typeof sValue === "string" &&  sValue.includes("(") && sValue.includes(")")) {
                    var match = sValue.match(/\(([^)]+)\)$/); // Pega tudo entre os parênteses no final da string
                    if (match) {
                        extractedCode = match[1]; // Se encontrou, usa o código extraído
                    }
                }

                console.log("Novo valor do campo PurchaseRequisitionType:", sValue);
            
                // Verifica se o valor não é nenhum dos valores permitidos
                if (["ZURG", "ZRTI", "ZUTI", "ZREG", "ZDET"].indexOf(extractedCode) === -1) {
                    // Se o valor for diferente de ZURG, ZUTI, ZREG e ZDET, oculta a seção
                    var oSection = sap.ui.getCore().byId("ui.s2p.mm.profrequisition.maintains1::sap.suite.ui.generic.template.ObjectPage.view.Details::C_PurchaseReqnHeader--customer.app.variant.4.op-section-d53ec658");
                    if (oSection) {
                        oSection.setVisible(false); // Torna a seção invisível
                        console.log("Seção ocultada");
                    }
                } else {
                    // Se o valor for ZURG, ZRTI, ZUTI, ZREG ou ZDET, garante que a seção esteja visível
                    var oSection = sap.ui.getCore().byId("ui.s2p.mm.profrequisition.maintains1::sap.suite.ui.generic.template.ObjectPage.view.Details::C_PurchaseReqnHeader--customer.app.variant.4.op-section-d53ec658");
                    if (oSection) {
                        oSection.setVisible(true); // Torna a seção visível se ela já existir
                        console.log("Seção já existente e visível");
                    } else {
                        console.log("Seção não encontrada");
                    }
                }
            
                // Exemplo de validação: Se o valor for vazio, mostra um alerta
                if (!sValue) {
                    // sap.m.MessageToast.show("O tipo de requisição de compra não pode estar vazio.");
                }
            }
            ,
            onRoutePatternMatched: function(event) {

                 
                var sCurrentRoute = event.getParameter("name");
                var sPreviousRoute = this._sPreviousRoute || ""; // Pega a rota anterior (caso tenha)
            
                // Atualiza a rota anterior com a rota atual
                this._sPreviousRoute = sCurrentRoute; 
            
                // Se a tela não for "C_PurchaseReqnHeaderquery", sai da função
                if (sCurrentRoute !== "C_PurchaseReqnHeaderquery") {
                    return;
                }
                var oInputJustificativa = sap.ui.getCore().byId("ui.s2p.mm.profrequisition.maintains1::sap.suite.ui.generic.template.ObjectPage.view.Details::C_PurchaseReqnHeader--customer.app.variant.4.idTextAreaJustificativa");
                var oInputRegularizacao = sap.ui.getCore().byId("ui.s2p.mm.profrequisition.maintains1::sap.suite.ui.generic.template.ObjectPage.view.Details::C_PurchaseReqnHeader--customer.app.variant.4.idTextAreaRegularizacao");

                if (oInputJustificativa) {
                    oInputJustificativa.setEditable(true); // Desabilita edição
                }
                
                if (oInputRegularizacao) {
                    oInputRegularizacao.setEditable(true); // Desabilita edição
                }


                if (sPreviousRoute !== "C_PurchaseReqnHeader/to_PurchaseReqnItemquery" && sPreviousRoute !== "C_PurchaseReqnHeaderquery" 
                    // && sPreviousRoute !== "rootquery" &&  sPreviousRoute !== "" 
                ) {

                var oModel = new JSONModel({
                    currentDate: new Date().toLocaleDateString(),
                    currentTime: new Date().toLocaleTimeString(),
                    currentUser: sap.ushell?.Container?.getService("UserInfo")?.getId() || "Usuário não encontrado",
                    Justificativa: "",
                    Regularizacao: ""
                });
                this.getView().setModel(oModel, "oModel");

            }

            // if (sPreviousRoute !== "C_PurchaseReqnHeader/to_PurchaseReqnItemquery" && sPreviousRoute !== "C_PurchaseReqnHeaderquery" ) {

            //     var oModel = new JSONModel({
            //         currentDate: new Date().toLocaleDateString(),
            //         currentTime: new Date().toLocaleTimeString(),
            //         currentUser: sap.ushell?.Container?.getService("UserInfo")?.getId() || "Usuário não encontrado",
            //         Justificativa: "",
            //         Regularizacao: ""
            //     });
            //     this.getView().setModel(oModel, "oModel");
            
            // }







            
            if (sPreviousRoute == "rootquery" && sCurrentRoute == "C_PurchaseReqnHeaderquery" 
                || sPreviousRoute == "" && sCurrentRoute == "C_PurchaseReqnHeaderquery" 
            ) {
            
                const sUrl = "/sap/opu/odata/sap/ZMM_JUST_BANFN_CDS/ZMM_JUST_Banfn";

                const currentUrl = window.location.href;

                // Expressão regular para encontrar o valor de PurchaseRequisition
                const match = currentUrl.match(/PurchaseRequisition='(\d+)'/);
                
                if (match) {
                    const purchaseRequisition = match[1]; // Captura o valor numérico
                    console.log("PurchaseRequisition:", purchaseRequisition);


                    var extractedCode = purchaseRequisition; // Por padrão, usa o valor sem espaços
            


                    // Fetch com a URL ajustada
                    fetch(sUrl + "('" + extractedCode + "')" + "/?$format=json", {
                        method: "GET",
    
                    })
                    .then(response => response.json())  // Faz o parse da resposta JSON
                    .then(data => {
                        // Dados extraídos do OData
                        var justificativa = data.d.TextoJust1 || "";
                        var regularizacao = data.d.TextoJust2 || "";
                        var dataReq = data.d.Data || "";  // Data da requisição
                        var horaReq = data.d.Hora || "";  // Hora da requisição
                        var usuarioReq = data.d.Usuario || "";
                        var oController = this; // Salva a referência do this
                        // Atualizando o modelo com os dados extraídos
                        var oModel = new JSONModel({
                            currentDate: dataReq,  // Usando a data da requisição
                            currentTime: horaReq,  // Usando a hora da requisição
                            currentUser: usuarioReq, // Usando o usuário da requisição
                            Justificativa: justificativa,
                            Regularizacao: regularizacao
                        });
                
                        // Definir o modelo na view
                        this.getView().setModel(oModel, "oModel");

                        var oInputJustificativa = sap.ui.getCore().byId("ui.s2p.mm.profrequisition.maintains1::sap.suite.ui.generic.template.ObjectPage.view.Details::C_PurchaseReqnHeader--customer.app.variant.4.idTextAreaJustificativa");
                        var oInputRegularizacao = sap.ui.getCore().byId("ui.s2p.mm.profrequisition.maintains1::sap.suite.ui.generic.template.ObjectPage.view.Details::C_PurchaseReqnHeader--customer.app.variant.4.idTextAreaRegularizacao");

                        if (oInputJustificativa) {
                            oInputJustificativa.setEditable(false); // Desabilita edição
                        }
                        
                        if (oInputRegularizacao) {
                            oInputRegularizacao.setEditable(false); // Desabilita edição
                        }

                        // this.byId("idTextHora").setText(horaReq);
                        // this.byId("idTextData").setText(dataReq);
                        // this.byId("idTextUsuario").setText(usuarioReq);
                        var oController = this; // Salva a referência do this

                        this.byId("idTextData").setText(oController.formatarData(dataReq));
                        this.byId("idTextHora").setText(oController.formatarHora(horaReq)); 
                        this.byId("idTextUsuario").setText(usuarioReq);
                        


                       
                        var oController = this; // Salva a referência do this
                        var oGroupElement = sap.ui.getCore().byId("ui.s2p.mm.profrequisition.maintains1::sap.suite.ui.generic.template.ObjectPage.view.Details::C_PurchaseReqnHeader--iDocType::PurchaseRequisitionType::GroupElement");
    
                        if (oGroupElement) {
                            // Acessa os campos dentro do GroupElement
                            var oField = oGroupElement.getAggregation("fields")[0]; // Assume que existe um único campo de entrada
                        
                            if (oField && oField.setValue) {
                                // Define um novo valor antes de disparar o evento
                                var novoValor = "ZRTI"; 
                                // oField.setValue(novoValor);
                        
                                if (oField.attachChange) {
                                    // Adiciona o evento de mudança ao campo
                                    oField.attachChange(oController._onPurchaseReqTypeChange.bind(oController));
                        
                                    // Dispara o evento manualmente passando o novo valor
                                    oController._onPurchaseReqTypeChange({
                                        getSource: function() {
                                            return {
                                                getValue: function() {
                                                    return novoValor; // Retorna o valor que acabamos de definir
                                                }
                                            };
                                        }
                                    });
                                }
                            } else {
                                console.warn("Campo não encontrado ou não é um campo válido.");
                            }
                        } else {
                            console.warn("GroupElement não encontrado.");
                        }
                        this.loadData();
                        


                    })
                    .catch(error => {
                        console.error("Erro ao buscar dados do OData:", error);
                    });
                }else{

                    
                    var sHoraAtual = new Date().toLocaleTimeString();
                    var scurrentDate = new Date().toLocaleDateString();
                    var scurrentUser = sap.ushell?.Container?.getService("UserInfo")?.getId() || "Usuário não encontrado";

                    this.byId("idTextHora").setText(sHoraAtual);
                    this.byId("idTextData").setText(scurrentDate);
                    this.byId("idTextUsuario").setText(scurrentUser);


                    var oGroupElement = sap.ui.getCore().byId("ui.s2p.mm.profrequisition.maintains1::sap.suite.ui.generic.template.ObjectPage.view.Details::C_PurchaseReqnHeader--iDocType::PurchaseRequisitionType::GroupElement");
                    var oController = this; // Salva a referência do this
                    if (oGroupElement) {
                        // Acessa os campos dentro do GroupElement
                        var oField = oGroupElement.getAggregation("fields")[0]; // Assume que existe um único campo de entrada
                        var novoValor = "NB"; 
                        if (oField && oField.attachChange) {
                            // Adiciona o evento de mudança ao campo
                            oField.attachChange(oController._onPurchaseReqTypeChange.bind(oController));
                            oController._onPurchaseReqTypeChange({
                                getSource: function() {
                                    return {
                                        getValue: function() {
                                            return novoValor; // Pega o valor atual do campo
                                        }
                                    };
                                }
                            });
                        }else {
                            console.warn("Campo não encontrado ou não é um campo válido.");
                        }
                    } else {
                        console.warn("GroupElement não encontrado.");
                    }
                this.loadData();

                }
                

                } else {
                    console.log("PurchaseRequisition não encontrado na URL.");



                    var sHoraAtual = new Date().toLocaleTimeString();
                    var scurrentDate = new Date().toLocaleDateString();
                    var scurrentUser = sap.ushell?.Container?.getService("UserInfo")?.getId() || "Usuário não encontrado";

                    this.byId("idTextHora").setText(sHoraAtual);
                    this.byId("idTextData").setText(scurrentDate);
                    this.byId("idTextUsuario").setText(scurrentUser);


                    var oGroupElement = sap.ui.getCore().byId("ui.s2p.mm.profrequisition.maintains1::sap.suite.ui.generic.template.ObjectPage.view.Details::C_PurchaseReqnHeader--iDocType::PurchaseRequisitionType::GroupElement");
                    var oController = this; // Salva a referência do this
                    if (oGroupElement) {
                        // Acessa os campos dentro do GroupElement
                        var oField = oGroupElement.getAggregation("fields")[0]; // Assume que existe um único campo de entrada
                
                        if (oField && oField.attachChange) {
                            // Adiciona o evento de mudança ao campo
                            oField.attachChange(oController._onPurchaseReqTypeChange.bind(oController));
                            oController._onPurchaseReqTypeChange({
                                getSource: function() {
                                    return {
                                        getValue: function() {
                                            return oField.getValue(); // Pega o valor atual do campo
                                        }
                                    };
                                }
                            });
                        }else {
                            console.warn("Campo não encontrado ou não é um campo válido.");
                        }
                    } else {
                        console.warn("GroupElement não encontrado.");
                    }
                this.loadData();

                }

        
              

























            

            },




            
            loadData: function() {
                // Sua lógica de buscar os dados da API ou do backend
            },
            _onValidarAntesDeCriar: async function (oEvent) {
                var oModel = this.getView().getModel("oModel");
                var oMessageManager = sap.ui.getCore().getMessageManager();
                oMessageManager.removeAllMessages();
            
                var sJustificativa = oModel.getProperty("/Justificativa");
                var sRegularizacao = oModel.getProperty("/Regularizacao");
            
                var oInputJustificativa = sap.ui.getCore().byId("ui.s2p.mm.profrequisition.maintains1::sap.suite.ui.generic.template.ObjectPage.view.Details::C_PurchaseReqnHeader--customer.app.variant.4.idTextAreaJustificativa");
                var oInputRegularizacao = sap.ui.getCore().byId("ui.s2p.mm.profrequisition.maintains1::sap.suite.ui.generic.template.ObjectPage.view.Details::C_PurchaseReqnHeader--customer.app.variant.4.idTextAreaRegularizacao");
            

                var oSection = sap.ui.getCore().byId("ui.s2p.mm.profrequisition.maintains1::sap.suite.ui.generic.template.ObjectPage.view.Details::C_PurchaseReqnHeader--customer.app.variant.4.op-section-d53ec658");
            
                var bValid = true;
                var aMessages = [];
            
                // Se a seção estiver invisível, ignora a validação
                if (oSection && !oSection.getVisible()) {
                    console.log("Seção invisível, pulando validação");
                    return true;
                }
            
                // Validação Justificativa
                if (!sJustificativa) {
                    oInputJustificativa.setValueState(sap.ui.core.ValueState.Error);
                    oInputJustificativa.setValueStateText("Campo justificativa é obrigatório");
                    // aMessages.push("Campo justificativa é obrigatório.");
                    bValid = false;
                } else if (sJustificativa.length < 50) {
                    oInputJustificativa.setValueState(sap.ui.core.ValueState.Warning);
                    oInputJustificativa.setValueStateText("Comprimento da justificativa deve ser maior que 50 caracteres");
                    // aMessages.push("Comprimento da justificativa deve ser maior que 50 caracteres.");
                    bValid = false;
                } else {
                    oInputJustificativa.setValueState(sap.ui.core.ValueState.None);
                }
            
                // Validação Regularização
                if (!sRegularizacao) {
                    oInputRegularizacao.setValueState(sap.ui.core.ValueState.Error);
                    oInputRegularizacao.setValueStateText("Campo regularização é obrigatório");
                    // aMessages.push("Campo regularização é obrigatório.");
                    bValid = false;
                } else if (sRegularizacao.length < 50) {
                    oInputRegularizacao.setValueState(sap.ui.core.ValueState.Warning);
                    oInputRegularizacao.setValueStateText("Comprimento da regularização deve ser maior que 50 caracteres.");
                    // aMessages.push("Comprimento da regularização deve ser maior que 50 caracteres.");
                    bValid = false;
                } else {
                    oInputRegularizacao.setValueState(sap.ui.core.ValueState.None);
                }
            
                // Se houver erros, exibe mensagem e impede a criação
                if (!bValid) {

                    // sap.m.MessageBox.error(aMessages.join("\n"), {
                    //     onClose: function () {
                    //         setTimeout(function () {
                    //             // oMessageManager.removeAllMessages();
                    //         }, 100);
                    //     }
                    // });


                    var oDate = new Date();
                    var sHoraAtual = "PT" + 
                    String(oDate.getHours()).padStart(2, "0") + "H" + 
                    String(oDate.getMinutes()).padStart(2, "0") + "M" + 
                    String(oDate.getSeconds()).padStart(2, "0") + "S";
                    var scurrentUser = sap.ushell?.Container?.getService("UserInfo")?.getId() || "Usuário não encontrado";
                    var oModel = this.getView().getModel("oModel");
                    var sData = oDate.toISOString().split("T")[0] + "T00:00:00"
                    sHoraAtual = sHoraAtual.replace("MM", "M");
    
                    var sJustificativa = "ERRO JUSTIFICATIVA ERRO";
                    var sRegularizacao = "ERRO REGULARIZACAO ERRO";
    
                    // Recupera os controles de entrada (ajuste os IDs conforme necessário)
                    var oInputJustificativa = sap.ui.getCore().byId("ui.s2p.mm.profrequisition.maintains1::sap.suite.ui.generic.template.ObjectPage.view.Details::C_PurchaseReqnHeader--customer.app.variant.4.idTextAreaJustificativa");
                    var oInputRegularizacao = sap.ui.getCore().byId("ui.s2p.mm.profrequisition.maintains1::sap.suite.ui.generic.template.ObjectPage.view.Details::C_PurchaseReqnHeader--customer.app.variant.4.idTextAreaRegularizacao");
    

                  var oPayload = {
                    "Banfn": "8888888888",
                    "Texto_just1": sJustificativa,
                    "Texto_just2": sRegularizacao,
                    "Usuario": scurrentUser,
                    "Data": sData, 
                    "Hora": sHoraAtual
                };
            
                const sUrl = "/sap/opu/odata/sap/ZMM_JUST_CDS/ZMM_JUST";
            
                // Etapa 1: Obter o token CSRF
                fetch(sUrl, {
                    method: "GET",
                    headers: {
                        "X-CSRF-Token": "Fetch"
                    }
                })
                .then(response => {
                    if (!response.ok) {
                        throw new Error('Erro ao buscar token CSRF');
                    }
                    return response.headers.get("X-CSRF-Token");
                })
                .then(token => {
                    this.token = token;
                    // console.log("Token CSRF obtido:", this.token);
            
                    // Etapa 2: Verificar se a justificativa já existe (GET)
                    return fetch(sUrl + "('8888888888')", {
                        method: "GET",
                        headers: {
                            "X-CSRF-Token": this.token
                        }
                    });
                })
                .then(response => {
                    if (!response.ok && response.status !== 404) {
                        // throw new Error('Erro ao verificar justificativa existente');
                    }
            
                    // Caso a justificativa não exista, cria um novo registro (POST)
                    if (response.status === 404) {
                        return fetch(sUrl, {
                            method: "POST",
                            headers: {
                                "Content-Type": "application/json",
                                "X-CSRF-Token": this.token
                            },
                            body: JSON.stringify(oPayload)
                        })
                        .then(response => {
                            if (!response.ok) {
                                // return response.text().then(text => { throw new Error(text); });
                            }
                            return response;
                        });
                    } else {
                        // Caso a justificativa já exista, atualiza a justificativa (PUT)
                        return fetch(sUrl + "('8888888888')", {
                            method: "PUT",
                            headers: {
                                "Content-Type": "application/json",
                                "X-CSRF-Token": this.token
                            },
                            body: JSON.stringify(oPayload)
                        })
                        // .then(response => {
                        //     if (!response.ok) {
                        //         return response.text().then(text => { throw new Error(text); });
                        //     }
                        //     return response;
                        // })
                        ;
                    }
                })
                .then(response => {
                    if (!response.ok) {
                        // throw new Error('Erro ao salvar ou atualizar justificativa');
                    }
                    // return response.json();
                })
                .then(data => {
                    // console.log("Resposta do servidor:", data);
                    // sap.m.MessageToast.show("Justificativa salva/atualizada com sucesso!");
                })
                .catch(error => {
                    // sap.m.MessageToast.show(error.message);
                    // console.log(error);
                });

                
                await new Promise(function(resolve){setTimeout(resolve, 2000)});

                }
                // oMessageManager.removeAllMessages();
                return true;
            },
            override: {
            	/**
            	 * Called when a controller is instantiated and its View controls (if available) are already created.
            	 * Can be used to modify the View before it is displayed, to bind event handlers and do other one-time initialization.
            	 * @memberOf {{controllerExtPath}}
            	 */
            	onInit: function() {
                    console.log("Controller Extension carregado!");
                    // this.token = this.oModel.getSecurityToken(); // Obtém o CSRF-Token 

                    var oModel = new JSONModel({
                        currentDate: new Date().toLocaleDateString(),
                        currentTime: new Date().toLocaleTimeString(),
                        currentUser: sap.ushell?.Container?.getService("UserInfo")?.getId() || "Usuário não encontrado",
                        Justificativa: "",
                        Regularizacao: ""
                    });
                    this.getView().setModel(oModel, "oModel");
                    var oInputJustificativa = sap.ui.getCore().byId("ui.s2p.mm.profrequisition.maintains1::sap.suite.ui.generic.template.ObjectPage.view.Details::C_PurchaseReqnHeader--customer.app.variant.4.idTextAreaJustificativa");
                    var oInputRegularizacao = sap.ui.getCore().byId("ui.s2p.mm.profrequisition.maintains1::sap.suite.ui.generic.template.ObjectPage.view.Details::C_PurchaseReqnHeader--customer.app.variant.4.idTextAreaRegularizacao");
    
                    if (oInputJustificativa) {
                        oInputJustificativa.setEditable(true); // Desabilita edição
                    }
                    
                    if (oInputRegularizacao) {
                        oInputRegularizacao.setEditable(true); // Desabilita edição
                    }
        
                    var oController = this; 
                    var oComponent = sap.ui.core.Component.getOwnerComponentFor(this.getView());
                       if (oComponent && typeof oComponent.getRouter === "function") {
                           var oRouter = oComponent.getRouter();
                         var myRoute = oRouter.getRoute("C_PurchaseReqnHeader");
                           
                           if (myRoute) {
                               myRoute.attachPatternMatched(oController.onRoutePatternMatched, this);
                               oRouter.attachRoutePatternMatched(oController.onRoutePatternMatched, this);
                           } else {
                               console.error("Rota 'ObjectPage' não encontrada.");
                           }
                       } else {
                           console.error("Componente não possui roteador.");
                       }
                   
            	},

            	/**
            	 * Similar to onAfterRendering, but this hook is invoked before the controller's View is re-rendered
            	 * (NOT before the first rendering! onInit() is used for that one!).
            	 * @memberOf {{controllerExtPath}}
            	 */
            	onBeforeRendering: function() {
            	},
            	/**
            	 * Called when the View has been rendered (so its HTML is part of the document). Post-rendering manipulations of the HTML could be done here.
            	 * This hook is the same one that SAPUI5 controls get after being rendered.
            	 * @memberOf {{controllerExtPath}}
            	 */
                onAfterRendering: function () {

                    var sHoraAtual = new Date().toLocaleTimeString();
                    var scurrentDate = new Date().toLocaleDateString();
                    var scurrentUser = sap.ushell?.Container?.getService("UserInfo")?.getId() || "Usuário não encontrado";

                    this.byId("idTextHora").setText(sHoraAtual);
                    this.byId("idTextData").setText(scurrentDate);
                    this.byId("idTextUsuario").setText(scurrentUser);

                    var oController = this; // Salva a referência do this

                    var oGroupElement = sap.ui.getCore().byId("ui.s2p.mm.profrequisition.maintains1::sap.suite.ui.generic.template.ObjectPage.view.Details::C_PurchaseReqnHeader--iDocType::PurchaseRequisitionType::GroupElement");

                    if (oGroupElement) {
                        // Acessa os campos dentro do GroupElement
                        var oField = oGroupElement.getAggregation("fields")[0]; // Assume que existe um único campo de entrada
                
                        if (oField && oField.attachChange) {
                            // Adiciona o evento de mudança ao campo
                            oField.attachChange(oController._onPurchaseReqTypeChange.bind(oController));
                            oController._onPurchaseReqTypeChange({
                                getSource: function() {
                                    return {
                                        getValue: function() {
                                            return oField.getValue(); // Pega o valor atual do campo
                                        }
                                    };
                                }
                            });
                        }else {
                            console.warn("Campo não encontrado ou não é um campo válido.");
                        }
                    } else {
                        console.warn("GroupElement não encontrado.");
                    }

                    var oButton = sap.ui.getCore().byId("ui.s2p.mm.profrequisition.maintains1::sap.suite.ui.generic.template.ObjectPage.view.Details::C_PurchaseReqnHeader--activate");

                    if (oButton) {
                        oButton.attachPress(this._onValidarAntesDeCriar.bind(this));
                    }



                }
            }
        });
    }
);