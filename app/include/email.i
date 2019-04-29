/**
 * 
 * ---------------
 *
 *  - Portal de Manifestação de Clientes - SAC
 *
 * Autor: carloseloi.prado@gmail.com
 */

{utp/utapi019.i}

DEFINE BUFFER bmail-manifestacao FOR manifestacao.

FUNCTION fi-get-email-destinatario RETURNS CHAR (pgrupoParam AS CHARACTER):

	DEF VAR c-lstEmails AS CHAR INIT "".

	FOR EACH usuar_grp_usuar NO-LOCK WHERE usuar_grp_usuar.cod_grp_usuar = pgrupoParam,
		EACH usuar_mestre NO-LOCK 
		WHERE usuar_mestre.cod_usuario 		=  usuar_grp_usuar.cod_usuario
		  AND usuar_mestre.dat_fim_valid 	>= TODAY
		  AND usuar_mestre.cod_e_mail_local <> "":

		IF c-lstEmails <> "" THEN c-lstEmails = c-lstEmails + ";" + usuar_mestre.cod_e_mail_local.
		ELSE c-lstEmails = usuar_mestre.cod_e_mail_local.

	END.

    return  c-lstEmails.
	
END FUNCTION.

FUNCTION fi-get-template-email RETURNS LONGCHAR (pIDManifestacao AS CHAR):

    DEFINE VARIABLE lc-itens AS LONGCHAR.
    
    FIND FIRST bmail-manifestacao NO-LOCK WHERE bmail-manifestacao.id-manifestacao = pIDManifestacao NO-ERROR.
    
    IF AVAIL(bmail-manifestacao) THEN 
    DO:
        ASSIGN lc-itens = '<td colspan="3" style="width: 76%; border-top: 0px; border-bottom: 1px solid #dddfeb;">
                            <table class="table" id="dataTable" width="100%" cellspacing="0" style="font-size: 0.8rem;">
                                <thead>                                            
                                </thead><tbody>'.
                
        FOR EACH item-manifestacao NO-LOCK WHERE item-manifestacao.id-manifestacao = pIDManifestacao,
            FIRST item  FIELDS (desc-item it-codigo) NO-LOCK
                WHERE item.it-codigo = item-manifestacao.it-codigo:
                
                ASSIGN lc-itens = lc-itens + '<tr >
                                                <td style="text-align: left; border-top: 0px; border-bottom: 1px solid #dddfeb " class="ng-binding">' + item.it-codigo + '-' + item.desc-item + '</td>
                                               </tr>
                                              '.
        END.
        
        ASSIGN lc-itens = lc-itens + '</tbody></table></td>'.
    END.

    IF NOT AVAIL(bmail-manifestacao) THEN
        RETURN "".
    ELSE 
        RETURN
        '<!DOCTYPE html>
        <html>
            <head>
                <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">		
            </head>
            <body>
            <header>
                <meta http-equiv="Expires" content="0">
                <meta http-equiv="Cache-Control" content="no-cache">
                <meta http-equiv="Pragma" content="no-cache">        
                <meta name="language" content="pt-br">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title> PORTAL ACESSO</title>
                <link href="' + app_config.caminho_assets + '/css/sb-admin-2.min.css" rel="stylesheet">
                <link href="' + app_config.caminho_assets + '/vendor/fontawesome-free/css/all.min.css" rel="stylesheet" type="text/css">
                <link href="' + app_config.caminho_assets + '/css/Footer-white.css" rel="stylesheet" media="screen">
            </header>
            <div id="wrapper">
            <div id="content-wrapper" class="d-flex flex-column">
              <div id="content">
                <div class="container-fluid">
                    <div class="row justify-content-center">
                      <div class="col-xl-8 col-lg-10 col-md-10">                                                                
                            <div class="card shadow mb-4">
                                <div class="card-header py-3 d-flex flex-row align-items-left">                            
                                    <h4 class="m-0 font-weight-bold text-gray-800">Manifesta&ccedil;&atilde;o de Cliente:</h4>                                                    
                                </div>
                                <div class="card-body">
                                    <div class="card-body" style="padding: 0.1rem">                                        
                                    <div class="table-responsive">
                                        <table class="table" id="dataTable" width="100%" cellspacing="0" style="font-size: 0.9rem;">
                                        <tbody>
                                            <tr>
                                                <td style="width: 22%; text-align: right; border-top: 0px; border-bottom: 1px solid #dddfeb">
                                                    <h4 class="m-0 font-weight-bold text-gray-800">ID Manifesta&ccedil;&atilde;o:</h4></td>
                                                <td style="width: 28%; border-top: 0px; border-bottom: 1px solid #dddfeb " class="ng-binding">' + bmail-manifestacao.id-manifestacao + '</td>                                          
                                                <td style="width: 20%; text-align: right; border-top: 0px; border-bottom: 1px solid #dddfeb ">
                                                    <h4 class="m-0 font-weight-bold text-gray-800">Protocolo:</h4></td>
                                                <td style="width: 30%; border-top: 0px; border-bottom: 1px solid #dddfeb " class="ng-binding">' + bmail-manifestacao.nr-protocolo + '</td>  
                                            </tr>                                        
                                            <tr>
                                                <td style="width: 22%; text-align: right; border-top: 0px; border-bottom: 1px solid #dddfeb">
                                                    <h4 class="m-0 font-weight-bold text-gray-800">Aberta:</h4></td>
                                                <td style="width: 28%; border-top: 0px; border-bottom: 1px solid #dddfeb " class="ng-binding">' + string(bmail-manifestacao.dt-cadastro) + ' ' + STRING( hr-cadastro,'hh:mm:ss') + '</td>                                          
                                                <td style="width: 22%; text-align: right; border-top: 0px; border-bottom: 1px solid #dddfeb ">
                                                    <h4 class="m-0 font-weight-bold text-gray-800">Usu&aacute;rio Cadastro:</h4></td>
                                                <td style="width: 28%; border-top: 0px; border-bottom: 1px solid #dddfeb " class="ng-binding">' + bmail-manifestacao.cod-usuar + '</td>  
                                            </tr>                                        
                                            <tr>
                                                <td style="width: 22%; text-align: right; border-top: 0px; border-bottom: 1px solid #dddfeb">
                                                    <h4 class="m-0 font-weight-bold text-gray-800">Origem:</h4></td>
                                                <td style="width: 28%; border-top: 0px; border-bottom: 1px solid #dddfeb " class="ng-binding">' + bmail-manifestacao.origem + '</td>                                          
                                                <td style="width: 20%; text-align: right; border-top: 0px; border-bottom: 1px solid #dddfeb ">
                                                    <h4 class="m-0 font-weight-bold text-gray-800">Telefone:</h4></td>
                                                <td style="width: 30%; border-top: 0px; border-bottom: 1px solid #dddfeb " class="ng-binding">' + bmail-manifestacao.nr-telefone + '</td>
                                            </tr>                                        
                                            <tr>
                                                <td style="width: 22%; text-align: right; border-top: 0px; border-bottom: 1px solid #dddfeb">
                                                    <h4 class="m-0 font-weight-bold text-gray-800">Cliente:</h4></td>
                                                <td style="width: 28%; border-top: 0px; border-bottom: 1px solid #dddfeb " class="ng-binding">' + bmail-manifestacao.nm-cliente + '</td>                                          
                                                <td style="width: 20%; text-align: right; border-top: 0px; border-bottom: 1px solid #dddfeb ">
                                                    <h4 class="m-0 font-weight-bold text-gray-800">Endere&ccedil;o:</h4></td>
                                                <td style="width: 30%; border-top: 0px; border-bottom: 1px solid #dddfeb ">
                                                    <p class="mb-4 ng-binding">' + bmail-manifestacao.ds-logradouro + ',' + bmail-manifestacao.nr-logradouro + ' ' + bmail-manifestacao.complemento + '<br>
                                                        ' + bmail-manifestacao.cidade + ' - ' + bmail-manifestacao.cd-uf + '&nbsp;&nbsp;-&nbsp;&nbsp;<b>CEP</b>:&nbsp;' + bmail-manifestacao.cep + '</p>
                                                </td>  
                                            </tr>                                        
                                            <tr>
                                                <td style="width: 22%; text-align: right; border-top: 0px; border-bottom: 1px solid #dddfeb">
                                                    <h4 class="m-0 font-weight-bold text-gray-800">Tipo:</h4></td>
                                                <td colspan="3" style="width: 28%; border-top: 0px; border-bottom: 1px solid #dddfeb;" class="ng-binding">' + bmail-manifestacao.ds-tpo-manifestacao + ': ' + bmail-manifestacao.cod-grp-usuar  + '</td>
                                            </tr>                                                                               
                                            <tr>                                        
                                                <td style="width: 22%; text-align: right; border-top: 0px; border-bottom: 1px solid #dddfeb ">
                                                    <h4 class="m-0 font-weight-bold text-gray-800">Itens:</h4></td>' +                                                       
                                                        lc-itens                                             
                                            + '</tr>
                                        </tbody>
                                        </table>
                                    </div>
                                    </div>
                                    <div class="dropdown-divider"></div>
                                    <div class="form-group row">
                                        <div class="col-sm-12 text-left">
                                            <h4 class="h4 mb-1 font-weight-bold text-gray-800">Ocorr&ecirc;ncia:</h4>
                                        </div>
                                    </div>
                                    <div class="form-group row">
                                        <div class="col-sm-12 text-left">
                                            <p class="mb-4 ng-binding">' + bmail-manifestacao.ds-ocorrencia + '</p>
                                        </div>
                                    </div>
                                    <div class="dropdown-divider"></div>
                                    <div class="form-group row">
                                        <div class="col-sm-12 text-left">
                                            <h4 class="h4 mb-1 font-weight-bold text-gray-800">Resposta:</h4>
                                        </div>
                                    </div>
                                    <div class="form-group row">
                                        <div class="col-sm-12 text-left">
                                            <p class="mb-4 ng-binding">' + bmail-manifestacao.ds-resp-imediata + '</p>
                                        </div>
                                    </div>
                                    <div class="dropdown-divider"></div>
                                    <div class="form-group row">
                                        <div class="col-sm-12 text-left">
                                            <h4 class="h4 mb-1 font-weight-bold text-gray-800">Investiga&ccedil;&atilde;o:</h4>
                                        </div>
                                    </div>
                                    <div class="form-group row">
                                        <div class="col-sm-12 text-left">
                                            <p class="mb-4 ng-binding">' + bmail-manifestacao.ds-investigacao + '</p>
                                        </div>
                                    </div>  
                                    <div class="dropdown-divider"></div>                        
                                </div>                        
                            </div>
                        </div>                          
                    </div>
                  </div>
              </div>
             <footer class="sticky-footer bg-white">
                <div class="container my-auto">
                  <div class="copyright text-center my-auto">
                    <span>Copyright &copy; Cera Ingelza - 2019</span><BR>
                    <span>Para mais informa&ccedil;&otilde;es acesse o portal: <a href="https://inglezaonline.com.br/cgi-bin/ws.do/WService=sac/login">https://inglezaonline.com.br/cgi-bin/ws.do/WService=sac/login</a></span>
                  </div>
                </div>
              </footer>
            </div>    
          </div>
        </body></html>'.

END FUNCTION.

FUNCTION fi-get-next-id-email-manifestacao RETURNS INT ():

	DEF VAR i-id-email-manifestacao AS INT INIT 0.
	DEF BUFFER b-email-manifestacao for email-manifestacao.

	FIND LAST b-email-manifestacao NO-LOCK NO-ERROR.

	IF AVAIL(b-email-manifestacao) THEN
		ASSIGN i-id-email-manifestacao = b-email-manifestacao.id-email-manifestacao.

	REPEAT:

		FIND FIRST b-email-manifestacao WHERE b-email-manifestacao.id-email-manifestacao = i-id-email-manifestacao + 1 NO-LOCK NO-ERROR.
		ASSIGN i-id-email-manifestacao = i-id-email-manifestacao + 1 .

		IF NOT AVAIL(b-email-manifestacao) THEN LEAVE.
	END.

	RETURN i-id-email-manifestacao.
  
END FUNCTION.

PROCEDURE pi-envia-email:

	DEFINE INPUT PARAMETER p-remetente			AS CHARACTER.
	DEFINE INPUT PARAMETER p-destinatarios		AS CHARACTER.
	DEFINE INPUT PARAMETER p-assunto			AS CHARACTER.
	DEFINE INPUT PARAMETER p-mensagem			AS CHARACTER. //caso não seja cahama de alterção de senha este param receb id da manifestacao
	DEFINE OUTPUT PARAMETER p-status			AS CHARACTER.
    DEFINE INPUT  PARAMETER p-conclusao			AS CHARACTER.

	DEFINE VARIABLE h-utapi019          AS HANDLE.
	DEFINE VARIABLE objMail 			AS COM-HANDLE   NO-UNDO.
	DEFINE VARIABLE ix					AS INTEGER      NO-UNDO.
    DEFINE VARIABLE lc-bodyemail        AS LONGCHAR     NO-UNDO.

	ASSIGN p-status = 'ERROR'.
	IF p-remetente <> "" AND
	   p-destinatarios <> "" AND
	   p-assunto <> "" AND
	   p-mensagem <> "" THEN DO:

        ASSIGN p-destinatarios = p-destinatarios.
        
        //Tratar caso de trâmite diferente de conclusão procede
        //Não enviar email ao app_config.email_rnc
        IF p-conclusao <> 'Procede' AND p-destinatarios <> '' AND p-conclusao <> 'Password' THEN DO:
            ASSIGN p-destinatarios = replace(p-destinatarios, app_config.email_rnc, '')
                   p-destinatarios = replace(p-destinatarios, ';;', ';')
                   p-destinatarios = IF SUBSTR(p-destinatarios,1,1) = ';' THEN SUBSTR(p-destinatarios, 2,( LENGTH(p-destinatarios) - 1) )  ELSE p-destinatarios
                   p-destinatarios = IF SUBSTR(p-destinatarios,LENGTH(p-destinatarios),1) = ';' THEN SUBSTR(p-destinatarios, 1,( LENGTH(p-destinatarios) - 1) ) ELSE p-destinatarios
                   .
        END.
        
        IF p-conclusao <> 'Password' THEN
            ASSIGN lc-bodyemail = fi-get-template-email(p-mensagem).
        
		/** TOTVS11*/
		FIND FIRST param_email NO-LOCK NO-ERROR.

		create  "CDO.message" objMail.
  		objmail:From 		= p-remetente.
  		objmail:To 			= p-destinatarios.
  		objmail:Subject 	= p-assunto.
        
        IF lc-bodyemail = '' THEN
            objmail:TextBody = p-mensagem.
        ELSE 
            objmail:HtmlBody = lc-bodyemail.
            
        objmail:Configuration:Fields:Item("http://schemas.microsoft.com/cdo/configuration/sendusing") = 2.
    	objmail:Configuration:Fields:Item("http://schemas.microsoft.com/cdo/configuration/smtpserver") = IF AVAILABLE param_email THEN param_email.cod_servid_e_mail ELSE "".
    	objmail:Configuration:Fields:Item("http://schemas.microsoft.com/cdo/configuration/smtpserverport") = IF AVAILABLE param_email THEN param_email.num_porta ELSE 587. 
    	objmail:Configuration:Fields:UPDATE.
  		objmail:Send.

		IF ( ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 ) AND app_config.habilita_log THEN DO:
       		DO ix = 1 TO ERROR-STATUS:NUM-MESSAGES:       
          		MESSAGE "|Erro EMAIL...: " + STRING(ERROR-STATUS:GET-NUMBER(ix)) + " - " + ERROR-STATUS:GET-MESSAGE(ix).               			
       		END.				  
    	END.
		ASSIGN p-status = 'OK'.	
	END. /* parametros com valor */

END PROCEDURE.

PROCEDURE pi-grava-envia-email:
	DEFINE INPUT PARAMETER pIdManifestacao		AS CHARACTER NO-UNDO.
	DEFINE INPUT PARAMETER pIdTarManifestacao	AS INTEGER NO-UNDO.
	DEFINE INPUT PARAMETER pBodyManifestacao	AS CHARACTER NO-UNDO.
	DEFINE INPUT PARAMETER pStatusEnvio			AS CHARACTER NO-UNDO.

	FIND FIRST email-manifestacao EXCLUSIVE-LOCK 
		WHERE email-manifestacao.id-manifestacao 		= pIdManifestacao  
		  AND email-manifestacao.id-tar-manifestacao 	= pIdTarManifestacao NO-ERROR.

	IF NOT AVAIL(email-manifestacao) THEN DO:
		CREATE email-manifestacao.
		ASSIGN email-manifestacao.id-email-manifestacao = fi-get-next-id-email-manifestacao().
	END.

	ASSIGN 
		   email-manifestacao.id-manifestacao 		= pIdManifestacao
		   email-manifestacao.ds-body-email 		= pBodyManifestacao	
		   email-manifestacao.dt-envio				= TODAY
		   email-manifestacao.hr-envio				= TIME
		   email-manifestacao.id-tar-manifestacao	= pIdTarManifestacao
      	   email-manifestacao.status-envio			= pStatusEnvio
		   .	

END PROCEDURE.
