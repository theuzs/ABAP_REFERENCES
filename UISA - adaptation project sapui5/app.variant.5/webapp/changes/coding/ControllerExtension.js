sap.ui.define(
    [
        'sap/ui/core/mvc/ControllerExtension',
        'sap/ui/core/mvc/OverrideExecution',
        "sap/ui/model/json/JSONModel",
        "sap/m/MessageToast"
    
    ],
    function (ControllerExtension, OverrideExecution, JSONModel, MessageToast) {

        'use strict';
        return ControllerExtension.extend("customer.app.variant.5.ControllerExtension", {
            
            metadata: {
            	// extension can declare the public methods
            	// in general methods that start with "_" are private
            	methods: {
            		publicMethod: {
            			public: true /*default*/ ,
            			final: false /*default*/ ,
            			overrideExecution: OverrideExecution.Instead /*default*/
            		},
            		finalPublicMethod: {
            			final: true
            		},
            		onMyHook: {
            			public: true /*default*/ ,
            			final: false /*default*/ ,
            			overrideExecution: OverrideExecution.After
            		},
            		couldBePrivate: {
            			public: false
            		}
            	}
            },
            // adding a private method, only accessible from this controller extension
            _privateMethod: function() {},
            // adding a public method, might be called from or overridden by other controller extensions as well



            publicMethod: function(oEvent) {
                var sHoraAtual = new Date().toLocaleTimeString("pt-BR", { hour: '2-digit', minute: '2-digit', second: '2-digit', hour12: false }).replace(/:/g, "H") + "S";
                var scurrentUser = sap.ushell?.Container?.getService("UserInfo")?.getId() || "Usuário não encontrado";
                var oModel = this.getView().getModel("oModel");
                var sJustificativa = oModel.getProperty("/Justificativa");
                var sRegularizacao = oModel.getProperty("/Regularizacao");
            
                // Validação: Verifica se os campos estão preenchidos
                if (!sJustificativa || !sRegularizacao) {
                    return;
                }
            
                // Dados a serem enviados
                var oPayload = {
                    "Banfn": "9999999999",
                    "Texto_just1": sJustificativa,
                    "Texto_just2": sRegularizacao,
                    "Usuario": scurrentUser,
                    "Data": new Date().toISOString(), // Formato YYYY-MM-DD
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
                        });
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
                    sap.m.MessageToast.show(error.message);
                    console.log(error);
                });
            }

            ,
            // adding final public method, might be called from, but not overridden by other controller extensions as well
            finalPublicMethod: function() {},
            // adding a hook method, might be called by or overridden from other controller extensions
            // override these method does not replace the implementation, but executes after the original method
            onMyHook: function() {},
            // method public per default, but made private via metadata
            couldBePrivate: function() {},
            // this section allows to extend lifecycle hooks or override public methods of the base controller
                // Definição de Métodos
                _onPurchaseReqTypeChange: function (oEvent) {
                    var sValue = oEvent.getSource().getValue(); // Obtém o novo valor do campo
                
                    console.log("Novo valor do campo PurchaseRequisitionType:", sValue);
                
                    // Verifica se o valor não é nenhum dos valores permitidos
                    if (["ZURG", "ZUTI", "ZREG", "ZDET"].indexOf(sValue) === -1) {
                        // Se o valor for diferente de ZURG, ZUTI, ZREG e ZDET, oculta a seção
                        var oSection = sap.ui.getCore().byId("ui.s2p.mm.profrequisition.maintains1::sap.suite.ui.generic.template.ObjectPage.view.Details::C_PurchaseReqnHeader--customer.app.variant.5.op-section-57ec371e");
                        if (oSection) {
                            oSection.setVisible(false); // Torna a seção invisível
                            console.log("Seção ocultada");
                        }
                    } else {
                        // Se o valor for ZURG, ZUTI, ZREG ou ZDET, garante que a seção esteja visível
                        var oSection = sap.ui.getCore().byId("ui.s2p.mm.profrequisition.maintains1::sap.suite.ui.generic.template.ObjectPage.view.Details::C_PurchaseReqnHeader--customer.app.variant.5.op-section-57ec371e");
                        if (oSection) {
                            oSection.setVisible(true); // Torna a seção visível se ela já existir
                            console.log("Seção já existente e visível");
                            var sHoraAtual = new Date().toLocaleTimeString();
                            var scurrentDate = new Date().toLocaleDateString();
                            var scurrentUser = sap.ushell?.Container?.getService("UserInfo")?.getId() || "Usuário não encontrado";

                            this.byId("idTextHora").setText(sHoraAtual);
                            this.byId("idTextData").setText(scurrentDate);
                            this.byId("idTextUsuario").setText(scurrentUser);
                            
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
            override: {
            	/**
            	 * Called when a controller is instantiated and its View controls (if available) are already created.
            	 * Can be used to modify the View before it is displayed, to bind event handlers and do other one-time initialization.
            	 * @memberOf {{controllerExtPath}}
            	 */
            	onInit: function() {
                    console.log("Controller Extension carregado!");
                    // this.token = this.getOwnerComponent().getModel().getSecurityToken();
                    // this.token = this.oModel.getSecurityToken(); // Obtém o CSRF-Token

                    var oModel = new JSONModel({
                        currentDate: new Date().toLocaleDateString(),
                        currentTime: new Date().toLocaleTimeString(),
                        currentUser: sap.ushell?.Container?.getService("UserInfo")?.getId() || "Usuário não encontrado",
                        Justificativa: "",
                        Regularizacao: ""
                    });
                    this.getView().setModel(oModel, "oModel");
                
        
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
                },
                


            	/**
            	 * Called when the Controller is destroyed. Use this one to free resources and finalize activities.
            	 * @memberOf {{controllerExtPath}}
            	 */
            	onExit: function() {
            	},
            	// override public method of the base controller
            	basePublicMethod: function() {
            	}
            }
        });
    }
);
