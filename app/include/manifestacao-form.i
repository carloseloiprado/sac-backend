/******Vari·veis Locais******/
DEFINE VARIABLE lg-RetOK      	AS LOGICAL   NO-UNDO.
DEFINE VARIABLE c-MsgResponse   AS CHARACTER NO-UNDO.
DEFINE VARIABLE ix    			AS INTEGER	 NO-UNDO.
DEFINE VARIABLE c-body      	AS CHARACTER NO-UNDO.
DEFINE VARIABLE c-email      	AS CHARACTER NO-UNDO.

DEFINE TEMP-TABLE body NO-UNDO
   	FIELD item           AS CHARACTER
	FIELD ds_tp_item     AS CHARACTER
	FIELD protocolo 		AS CHARACTER
	FIELD origem    		AS CHARACTER
	FIELD telefone  		AS CHARACTER
	FIELD cliente   		AS CHARACTER
	FIELD cep       		AS CHARACTER
	FIELD rua       		AS CHARACTER
	FIELD nrlogradouro	AS CHARACTER
	FIELD complemento 	AS CHARACTER
	FIELD bairro      	AS CHARACTER
	FIELD cidade      	AS CHARACTER
	FIELD uf          	AS CHARACTER
	FIELD tipo        	AS CHARACTER
	FIELD tpitem      	AS CHARACTER
	FIELD ocorrencia  	AS CHARACTER
	FIELD resposta    	AS CHARACTER
	FIELD investigacao	AS CHARACTER
    FIELD parecertecnico    AS CHARACTER
	FIELD conclusao 		AS CHARACTER
    FIELD acao              AS CHARACTER
	.

DEFINE TEMP-TABLE response NO-UNDO
	FIELD protocolo 		AS CHARACTER
	FIELD origem    		AS CHARACTER
	FIELD telefone  		AS CHARACTER
	FIELD cliente   		AS CHARACTER
	FIELD cep       		AS CHARACTER
	FIELD rua       		AS CHARACTER
	FIELD nrlogradouro	AS CHARACTER
	FIELD complemento 	AS CHARACTER
	FIELD bairro      	AS CHARACTER
	FIELD cidade      	AS CHARACTER
	FIELD uf          	AS CHARACTER
	FIELD tipo        	AS CHARACTER
	FIELD tpitem      	AS CHARACTER
	FIELD ocorrencia  	AS CHARACTER
	FIELD resposta    	AS CHARACTER
	FIELD investigacao	AS CHARACTER
	.

/** Temp-table de retorno */
DEFINE TEMP-TABLE ttRetornoHeader NO-UNDO
	FIELD retornoSucesso	AS LOGICAL
	FIELD retornoMensagem	AS CHARACTER.


/** Temp-table */
DEFINE TEMP-TABLE ttRetorno NO-UNDO
	FIELD id          		    	AS CHARACTER
	FIELD it_codigo           		LIKE item-portal-manifestacao-form.it-codigo
	field item							LIKE item.desc-item
	.

/** Datasets das tabelas retorno*/
DEFINE DATASET dsRetornoHeader  FOR ttRetornoHeader.
DEFINE DATASET dsRetorno      	FOR ttRetorno.
DEFINE DATASET dsResponse      	FOR response.

/***Functions Locais**/
FUNCTION fi-get-next-id-manifestacao RETURNS CHAR ():
    return  STRING(today,'99999999') + REPLACE(STRING(TIME,'hh:mm:ss'),':','').
END FUNCTION.

FUNCTION fi-get-next-id-anexo-manifestacao RETURNS INT ():

	DEF VAR i-id-anexo-manifestacao AS INT INIT 0.
	DEF BUFFER b-anexo-manifestacao for anexo-manifestacao.

	FIND LAST b-anexo-manifestacao NO-LOCK NO-ERROR.

	IF AVAIL(b-anexo-manifestacao) THEN
		ASSIGN i-id-anexo-manifestacao = b-anexo-manifestacao.id-anexo-manifestacao.

	REPEAT:

		FIND FIRST b-anexo-manifestacao WHERE b-anexo-manifestacao.id-anexo-manifestacao = i-id-anexo-manifestacao + 1 NO-LOCK NO-ERROR.
		ASSIGN i-id-anexo-manifestacao = i-id-anexo-manifestacao + 1 .

		IF NOT AVAIL(b-anexo-manifestacao) THEN LEAVE.
	END.

	RETURN i-id-anexo-manifestacao.
  
END FUNCTION.

/** Retorna Json */
PROCEDURE pi-retorno:

	DEFINE VARIABLE lRetOK      AS LOGICAL   NO-UNDO.
   
	ASSIGN lRetOK = DATASET dsRetorno:WRITE-JSON("STREAM", "WebStream",NO, "utf-8", ?, TRUE).

END PROCEDURE.

/** Cria registro de retorno */
PROCEDURE pi-retorno-item-manifestacao:

	CREATE ttRetorno.

	assign ttRetorno.id          		   = manifestacao.id-manifestacao
		   ttRetorno.it_codigo             = item.it-codigo
		   ttRetorno.item			       = item.desc-item
			.

END PROCEDURE.

/** Cria registro de retorno */
PROCEDURE pi-registro-retorno:

	CREATE ttRetorno.

	assign ttRetorno.id          		   = portal-manifestacao-form.cod-usu-corrente
		   ttRetorno.it_codigo             = item-portal-manifestacao-form.it-codigo
		   ttRetorno.item			       = item.desc-item
			.

END PROCEDURE.

/** Cria registro de retorno */
PROCEDURE pi-registro-retorno-anexo:

	CREATE ttRetorno.

	assign ttRetorno.id          		   = portal-manifestacao-form.cod-usu-corrente
		   ttRetorno.it_codigo             = item-portal-manifestacao-form.it-codigo
		   ttRetorno.item			       = item.desc-item
			.

END PROCEDURE.

/** Cria registro de retorno */
PROCEDURE pi-finaliza-manifestacao:

	DEFINE INPUT-OUTPUT PARAMETER pRetOK      		AS LOGICAL   NO-UNDO.
	DEFINE INPUT-OUTPUT PARAMETER pMsgResponse      AS CHARACTER NO-UNDO.
    DEFINE INPUT        PARAMETER pParecerTecnico       AS CHARACTER NO-UNDO.

	DEFINE VARIABLE vDestino        		AS CHAR NO-UNDO. 
	DEFINE VARIABLE vOrigem	        		AS CHAR NO-UNDO. 
	DEFINE VARIABLE i-id-anexo-manifestacao	AS INT NO-UNDO.
	DEFINE VARIABLE c-status        		AS CHAR NO-UNDO.
	DEFINE VARIABLE i-id-tar-manifestacao	AS INT NO-UNDO.

	FIND FIRST portal-manifestacao-form NO-LOCK
		WHERE portal-manifestacao-form.finalizado 	= NO and							 
			portal-manifestacao-form.cod-usu-corrente = usuarioCorrente NO-ERROR.

	MESSAGE 'pi-finaliza-manifestacao'.
	IF AVAIL(portal-manifestacao-form) THEN DO:

		CREATE manifestacao.
		ASSIGN manifestacao.id-manifestacao			= fi-get-next-id-manifestacao()
				manifestacao.nr-protocolo			= portal-manifestacao-form.nr-protocolo
				manifestacao.origem					= portal-manifestacao-form.origem
				manifestacao.nr-telefone			= portal-manifestacao-form.nr-telefone
				manifestacao.nm-cliente				= portal-manifestacao-form.nm-cliente
				manifestacao.cep					= portal-manifestacao-form.cep
				manifestacao.ds-logradouro			= portal-manifestacao-form.ds-logradouro
				manifestacao.nr-logradouro			= portal-manifestacao-form.nr-logradouro
				manifestacao.complemento			= portal-manifestacao-form.complemento
				manifestacao.bairro					= portal-manifestacao-form.bairro
				manifestacao.cidade					= portal-manifestacao-form.cidade
				manifestacao.cd-uf					= portal-manifestacao-form.cd-uf
				manifestacao.ds-tpo-manifestacao	= portal-manifestacao-form.ds-tpo-manifestacao
				manifestacao.ds-ocorrencia			= portal-manifestacao-form.ds-ocorrencia
				manifestacao.ds-resp-imediata 		= portal-manifestacao-form.ds-resp-imediata
				manifestacao.ds-investigacao		= portal-manifestacao-form.ds-investigacao
				manifestacao.cod-usu-cadastro		= portal-manifestacao-form.cod-usu-corrente
				manifestacao.dt-cadastro			= TODAY
				manifestacao.hr-cadastro			= TIME
				manifestacao.cod-grp-usuar			= portal-manifestacao-form.ds-tp-tpo-manifestacao
				manifestacao.cod-usuar				= '' 
				manifestacao.cd-status				= 1 /*ABERTA*/  	
				NO-ERROR.

		IF ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 THEN DO:
			DO ix = 1 TO ERROR-STATUS:NUM-MESSAGES:
				ASSIGN pMsgResponse = pMsgResponse + STRING (ERROR-STATUS:GET-NUMBER(ix)) + " " + ERROR-STATUS:GET-MESSAGE(ix) + ". "
					   pRetOK		  = FALSE.
			END.
			RETURN.                                                                                                       
		END.


		FOR EACH item-portal-manifestacao-form NO-LOCK
			WHERE item-portal-manifestacao-form.cod-usu-corrente = usuarioCorrente :
			
			CREATE item-manifestacao.
			ASSIGN item-manifestacao.it-codigo 		= item-portal-manifestacao-form.it-codigo
				item-manifestacao.id-manifestacao	= manifestacao.id-manifestacao
				item-manifestacao.ds-tpo-item		= item-portal-manifestacao-form.ds-tpo-item	
				NO-ERROR.
			
			IF ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 THEN DO:
				DO ix = 1 TO ERROR-STATUS:NUM-MESSAGES:
					ASSIGN pMsgResponse = pMsgResponse + STRING (ERROR-STATUS:GET-NUMBER(ix)) + " " + ERROR-STATUS:GET-MESSAGE(ix) + ". "
						pRetOK		  = FALSE.
				END.
				RETURN.                                                                                                       
			END.

			ASSIGN manifestacao.cod-grp-usuar		= item-manifestacao.ds-tpo-item.
		END.

		FOR EACH portal-anexo-manifestacao-form NO-LOCK
            WHERE portal-anexo-manifestacao-form.cod-usu-corrente   = usuarioCorrente
              AND portal-anexo-manifestacao-form.token				= get-cookie("SessionContextToken"):
			
			ASSIGN i-id-anexo-manifestacao = fi-get-next-id-anexo-manifestacao().

			FIND FIRST anexo-manifestacao EXCLUSIVE-LOCK WHERE anexo-manifestacao.id-anexo-manifestacao = i-id-anexo-manifestacao NO-ERROR.
			message 'avail.: ' AVAIL(anexo-manifestacao).

			IF NOT AVAIL(anexo-manifestacao) THEN
				CREATE anexo-manifestacao.

			ASSIGN anexo-manifestacao.id-anexo-manifestacao		= i-id-anexo-manifestacao
					anexo-manifestacao.id-manifestacao			= manifestacao.id-manifestacao
					anexo-manifestacao.path-anexo				= portal-anexo-manifestacao-form.path-anexo
					NO-ERROR.
			
			IF ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 THEN DO:
				DO ix = 1 TO ERROR-STATUS:NUM-MESSAGES:
					ASSIGN pMsgResponse = pMsgResponse + STRING (ERROR-STATUS:GET-NUMBER(ix)) + " " + ERROR-STATUS:GET-MESSAGE(ix) + ". "
							pRetOK		  = FALSE.
				END.
				RETURN.
			END.

			ASSIGN vDestino = app_config.caminho_img_anexo + manifestacao.id-manifestacao
				   vOrigem	= get-config("fileUploadDirectory":U) + '\' + portal-anexo-manifestacao-form.token.

			MESSAGE 'vDestino.: ' vDestino skip
					'vOrigem.: ' vOrigem.
			/* Verifica se a pasta existe */
			ASSIGN FILE-INFO:FILE-NAME = vDestino.

			/* Se n√£o a pasta n√£o existir cria */
			IF FILE-INFO:FULL-PATHNAME = ? then
				OS-CREATE-DIR VALUE(vDestino).

			ASSIGN FILE-INFO:FILE-NAME = vDestino.
    		IF FILE-INFO:FULL-PATHNAME <> ? THEN DO:
				MESSAGE  'DELETOU.: ' vOrigem + "\" + portal-anexo-manifestacao-form.path-anexo.
					
				/* verifica se arquivo foi gerado */	 
				FILE-INFO:FILE-NAME = vDestino + "\" + anexo-manifestacao.path-anexo.
				
				IF FILE-INFO:PATHNAME = ? THEN DO:
					/*move do tempor·rio para definitivo*/
					OS-COPY VALUE(vOrigem + "\" + portal-anexo-manifestacao-form.path-anexo) VALUE(vDestino + "\" + anexo-manifestacao.path-anexo).
					
				END.
			END.

		END.

		/*apaga o upload lixo do tempor·rio*/
		ASSIGN FILE-INFO:FILE-NAME = vOrigem.		
		MESSAGE 'FILE-INFO:FULL-PATHNAME.: ' FILE-INFO:FULL-PATHNAME.
		IF FILE-INFO:FULL-PATHNAME <> ? THEN
			RUN pi-limpa-diretorio(INPUT FILE-INFO:FULL-PATHNAME).

		ASSIGN pMsgResponse	= manifestacao.id-manifestacao.

		/*Envia email ao grupo respons·vel pela manifestacao*/
		ASSIGN c-body = pMsgResponse.
		ASSIGN c-email = fi-get-email-destinatario(INPUT manifestacao.cod-grp-usuar)
			   .
	    RUN pi-envia-email(INPUT app_config.email_remetente_solic, INPUT c-email, INPUT ('Nova ' + pParecerTecnico + ': ') + manifestacao.nr-protocolo, INPUT (c-body), OUTPUT c-status, INPUT 'Finalizada').
        
        IF ( manifestacao.ds-tpo-manifestacao <> 'reclamacao' ) THEN DO:
            
            ASSIGN c-email = ''
                   c-email = fi-get-email-destinatario(INPUT 'OUT').
            IF c-email <> '' THEN
                RUN pi-envia-email(INPUT app_config.email_remetente_solic, INPUT c-email, INPUT ('Nova ' + pParecerTecnico + ': ') + manifestacao.nr-protocolo, INPUT (c-body), OUTPUT c-status, INPUT 'Finalizada').    
        END.
        
		RUN pi-grava-tarefa-manifestcacao(INPUT pMsgResponse, INPUT 'Tarefa Criada', INPUT 'ABERTA', INPUT usuarioCorrente, OUTPUT i-id-tar-manifestacao, INPUT manifestacao.cod-grp-usuar, INPUT '', INPUT usuarioCorrente).
		//run pi-grava-envia-email(INPUT pMsgResponse, INPUT i-id-tar-manifestacao, INPUT c-body, INPUT c-status).
		RUN pi-grava-historico-manifestcacao(INPUT pMsgResponse, INPUT pParecerTecnico + ' Criada.' , INPUT 'ABERTA', INPUT usuarioCorrente, INPUT manifestacao.cod-grp-usuar, INPUT '', INPUT usuarioCorrente).	
		
        ASSIGN pMsgResponse						= "protocolo: " + manifestacao.nr-protocolo.
	end.

	/*Limpando os dados da tepor·ria*/
	FOR EACH portal-manifestacao-form EXCLUSIVE-LOCK
	 WHERE portal-manifestacao-form.finalizado 	= NO AND portal-manifestacao-form.cod-usu-corrente = usuarioCorrente:
		DELETE portal-manifestacao-form.
	END.

	FOR EACH portal-anexo-manifestacao-form EXCLUSIVE-LOCK
            WHERE portal-anexo-manifestacao-form.cod-usu-corrente   = usuarioCorrente AND portal-anexo-manifestacao-form.token = get-cookie("SessionContextToken"):
		DELETE portal-anexo-manifestacao-form. //delete o registro tempor·rio
	END.

	FOR EACH item-portal-manifestacao-form EXCLUSIVE-LOCK
		WHERE item-portal-manifestacao-form.cod-usu-corrente = usuarioCorrente :
		DELETE item-portal-manifestacao-form.
	END.


END PROCEDURE.

PROCEDURE pi-tramita-manifestacao:

	DEFINE INPUT-OUTPUT PARAMETER pRetOK      		    AS LOGICAL   NO-UNDO.
	DEFINE INPUT-OUTPUT PARAMETER pMsgResponse          AS CHARACTER NO-UNDO.
    DEFINE INPUT        PARAMETER pIdTarManifestacao    AS CHARACTER NO-UNDO.
    DEFINE INPUT        PARAMETER pIdManifestacao       AS CHARACTER NO-UNDO.
    DEFINE INPUT        PARAMETER pTpItem               AS CHARACTER NO-UNDO.
    DEFINE INPUT        PARAMETER pParecerTecnico       AS CHARACTER NO-UNDO.
    DEFINE INPUT        PARAMETER pConclusao            AS CHARACTER NO-UNDO.
    DEFINE INPUT        PARAMETER pAcao                 AS CHARACTER NO-UNDO.

	DEFINE VARIABLE vDestino        		AS CHAR NO-UNDO. 
	DEFINE VARIABLE vOrigem	        		AS CHAR NO-UNDO. 
	DEFINE VARIABLE i-id-anexo-manifestacao	AS INT  NO-UNDO.
	DEFINE VARIABLE c-status        		AS CHAR NO-UNDO.
	DEFINE VARIABLE i-id-tar-manifestacao	AS INT  NO-UNDO.
    DEFINE VARIABLE c-acao                  AS CHAR NO-UNDO.
    DEFINE VARIABLE cUsuarioCorrente        AS CHAR NO-UNDO.

    ASSIGN c-acao           = pAcao
           cUsuarioCorrente = usuarioCorrente.
    
    IF pTpItem = 'SAC' THEN
        ASSIGN c-acao = "solucionada".  

	FIND FIRST manifestacao NO-LOCK
		WHERE manifestacao.id-manifestacao = pIdManifestacao NO-ERROR.

	IF AVAIL(manifestacao) THEN DO:
        
        IF ( lnkNewManifestacao <> "#" ) THEN DO:
            FIND FIRST tar-manifestacao NO-LOCK
                WHERE tar-manifestacao.id-manifestacao  = manifestacao.id-manifestacao
                  AND tar-manifestacao.ds-status        <> 'FINALIZADA' 
                  AND tar-manifestacao.ds-status        <> 'SOLUCIONADA'
                  AND tar-manifestacao.dt-execucao      = ? NO-ERROR.
            IF ( tar-manifestacao.cod-grp-usuar <> '' ) THEN
                ASSIGN pTpItem = tar-manifestacao.cod-grp-usuar.
        END.
            

        FOR EACH portal-anexo-manifestacao-form NO-LOCK
            WHERE portal-anexo-manifestacao-form.cod-usu-corrente   = cUsuarioCorrente
              AND portal-anexo-manifestacao-form.token				= get-cookie("SessionContextToken"):
			
			ASSIGN i-id-anexo-manifestacao = fi-get-next-id-anexo-manifestacao().

			FIND FIRST anexo-manifestacao EXCLUSIVE-LOCK WHERE anexo-manifestacao.id-anexo-manifestacao = i-id-anexo-manifestacao NO-ERROR.
			message 'avail.: ' AVAIL(anexo-manifestacao).

			IF NOT AVAIL(anexo-manifestacao) THEN
				CREATE anexo-manifestacao.

			ASSIGN anexo-manifestacao.id-anexo-manifestacao		= i-id-anexo-manifestacao
					anexo-manifestacao.id-manifestacao			= manifestacao.id-manifestacao
					anexo-manifestacao.path-anexo				= 'tram-' + portal-anexo-manifestacao-form.path-anexo
					NO-ERROR.
			
			IF ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 THEN DO:
				DO ix = 1 TO ERROR-STATUS:NUM-MESSAGES:
					ASSIGN pMsgResponse = pMsgResponse + STRING (ERROR-STATUS:GET-NUMBER(ix)) + " " + ERROR-STATUS:GET-MESSAGE(ix) + ". "
							pRetOK		  = FALSE.
				END.
				RETURN.
			END.

			ASSIGN vDestino = app_config.caminho_img_anexo + manifestacao.id-manifestacao
				   vOrigem	= get-config("fileUploadDirectory":U) + '\' + portal-anexo-manifestacao-form.token.

			MESSAGE 'vDestino.: ' vDestino skip
					'vOrigem.: ' vOrigem.
			/* Verifica se a pasta existe */
			ASSIGN FILE-INFO:FILE-NAME = vDestino.

			/* Se n√£o a pasta n√£o existir cria */
			IF FILE-INFO:FULL-PATHNAME = ? then
				OS-CREATE-DIR VALUE(vDestino).

			ASSIGN FILE-INFO:FILE-NAME = vDestino.
    		IF FILE-INFO:FULL-PATHNAME <> ? THEN DO:
				MESSAGE  'DELETOU.: ' vOrigem + "\" + portal-anexo-manifestacao-form.path-anexo.
					
				/* verifica se arquivo foi gerado */	 
				FILE-INFO:FILE-NAME = vDestino + "\" + anexo-manifestacao.path-anexo.
				
				IF FILE-INFO:PATHNAME = ? THEN DO:
					/*move do tempor·rio para definitivo*/
					OS-COPY VALUE(vOrigem + "\" + portal-anexo-manifestacao-form.path-anexo) VALUE(vDestino + "\" + anexo-manifestacao.path-anexo).
					
				END.
			END.

		END.

		/*apaga o upload lixo do tempor·rio*/
		ASSIGN FILE-INFO:FILE-NAME = vOrigem.		
		MESSAGE 'FILE-INFO:FULL-PATHNAME.: ' FILE-INFO:FULL-PATHNAME.
		IF FILE-INFO:FULL-PATHNAME <> ? THEN
			RUN pi-limpa-diretorio(INPUT FILE-INFO:FULL-PATHNAME).

		ASSIGN pMsgResponse	= manifestacao.id-manifestacao.

		/*Envia email ao grupo respons·vel pela manifestacao*/
		ASSIGN c-body = pMsgResponse.
                        
		ASSIGN c-email = fi-get-email-destinatario(INPUT manifestacao.cod-grp-usuar)
			   .
       
	    
        IF pTpItem = 'SAC' THEN DO:
            RUN pi-envia-email(INPUT app_config.email_remetente_solic, INPUT c-email, INPUT cpc('ManifestaÁ„o ') + manifestacao.nr-protocolo + ' ' + c-acao + ' por ' + cUsuarioCorrente, INPUT (c-body), OUTPUT c-status, INPUT '').
            RUN pi-finaliza-tarefa-manifestcacao(INPUT INT(pIdTarManifestacao)).
            RUN pi-grava-tarefa-manifestcacao(INPUT pIdManifestacao, INPUT ((pParecerTecnico)) , INPUT 'SOLUCIONADA', INPUT cUsuarioCorrente, OUTPUT i-id-tar-manifestacao, INPUT pTpItem, INPUT ((pConclusao)), INPUT cUsuarioCorrente).
            RUN pi-grava-historico-manifestcacao(INPUT pIdManifestacao, INPUT ((pParecerTecnico)) , INPUT 'SOLUCIONADA', INPUT cUsuarioCorrente, INPUT pTpItem, INPUT ((pConclusao)), INPUT usuarioCorrente).
        END.
        ELSE IF pConclusao = 'Procede' THEN DO:
            RUN pi-envia-email(INPUT app_config.email_remetente_solic, INPUT c-email, INPUT cpc('ManifestaÁ„o ') + manifestacao.nr-protocolo + ' ' + c-acao + ' por ' + cUsuarioCorrente, INPUT (c-body), OUTPUT c-status, INPUT pConclusao).
            RUN pi-finaliza-tarefa-manifestcacao(INPUT INT(pIdTarManifestacao)).
            RUN pi-grava-tarefa-manifestcacao(INPUT pIdManifestacao, INPUT ((pParecerTecnico)) , INPUT 'TRANSFERIDA', INPUT app_config.user_rnc, OUTPUT i-id-tar-manifestacao, INPUT '', INPUT ((pConclusao)), INPUT cUsuarioCorrente).
            RUN pi-grava-historico-manifestcacao(INPUT pIdManifestacao, INPUT ((pParecerTecnico)) , INPUT 'TRANSFERIDA', INPUT app_config.user_rnc, INPUT '', INPUT ((pConclusao)), INPUT usuarioCorrente).
        END.
        ELSE DO:
           RUN pi-envia-email(INPUT app_config.email_remetente_solic, INPUT c-email, INPUT cpc('ManifestaÁ„o ') + manifestacao.nr-protocolo + ' ' + c-acao + ' por ' + cUsuarioCorrente, INPUT (c-body), OUTPUT c-status, INPUT ''). 
           FIND FIRST tar-manifestacao NO-LOCK WHERE tar-manifestacao.id-tar-manifestacao = INT(pIdTarManifestacao) NO-ERROR.
           IF AVAIL (tar-manifestacao) THEN
                ASSIGN  cUsuarioCorrente    = tar-manifestacao.cod-usuar
                        pTpItem             = tar-manifestacao.cod-grp-usuar.
           RUN pi-grava-historico-manifestcacao(INPUT pIdManifestacao, INPUT ((pParecerTecnico)) , INPUT UPPER(c-acao), INPUT cUsuarioCorrente, INPUT pTpItem, INPUT ((pConclusao)), INPUT usuarioCorrente).
        END.
        
	end.

     FIND FIRST manifestacao EXCLUSIVE-LOCK 
            WHERE manifestacao.id-manifestacao = pIdManifestacao NO-ERROR.
            
    IF AVAIL (manifestacao) THEN
       ASSIGN manifestacao.cd-status            = IF pTpItem = 'SAC' THEN 4 ELSE manifestacao.cd-status
              manifestacao.cod-usuar            = ''
              manifestacao.conclusao-parecer    = pConclusao
              pMsgResponse						= "protocolo: " + manifestacao.nr-protocolo.

END PROCEDURE.



PROCEDURE pi-finaliza-edicao-manifestacao:

	DEFINE INPUT-OUTPUT PARAMETER pRetOK      		    AS LOGICAL   NO-UNDO.
	DEFINE INPUT-OUTPUT PARAMETER pMsgResponse          AS CHARACTER NO-UNDO.
    DEFINE INPUT        PARAMETER pIdManifestacao       AS CHARACTER NO-UNDO.
    DEFINE INPUT        PARAMETER pParecerTecnico       AS CHARACTER NO-UNDO.
    	
    DEFINE VARIABLE vDestino        		AS CHAR NO-UNDO. 
	DEFINE VARIABLE vOrigem	        		AS CHAR NO-UNDO. 
	DEFINE VARIABLE i-id-anexo-manifestacao	AS INT  NO-UNDO.
	DEFINE VARIABLE c-status        		AS CHAR NO-UNDO.
	DEFINE VARIABLE i-id-tar-manifestacao	AS INT  NO-UNDO.
    DEFINE VARIABLE c-acao                  AS CHAR NO-UNDO.
    DEFINE VARIABLE cUsuarioCorrente        AS CHAR NO-UNDO.
    DEFINE VARIABLE cTpItem                 AS CHAR NO-UNDO.

    FIND FIRST manifestacao NO-LOCK
		WHERE manifestacao.id-manifestacao = pIdManifestacao NO-ERROR.

	IF AVAIL(manifestacao) THEN DO:
        
        FIND FIRST tar-manifestacao NO-LOCK
            WHERE tar-manifestacao.id-manifestacao  = manifestacao.id-manifestacao
              AND tar-manifestacao.ds-status        <> 'FINALIZADA' 
              AND tar-manifestacao.ds-status        <> 'SOLUCIONADA'
              AND tar-manifestacao.dt-execucao      = ? NO-ERROR.

        ASSIGN cTpItem = ''.
        IF ( tar-manifestacao.cod-grp-usuar <> '' ) THEN
            ASSIGN cTpItem = tar-manifestacao.cod-grp-usuar.
            

        FOR EACH portal-anexo-manifestacao-form NO-LOCK
            WHERE portal-anexo-manifestacao-form.cod-usu-corrente   = usuarioCorrente
              AND portal-anexo-manifestacao-form.token				= get-cookie("SessionContextToken"):
			
			ASSIGN i-id-anexo-manifestacao = fi-get-next-id-anexo-manifestacao().

			FIND FIRST anexo-manifestacao EXCLUSIVE-LOCK WHERE anexo-manifestacao.id-anexo-manifestacao = i-id-anexo-manifestacao NO-ERROR.
            
			IF NOT AVAIL(anexo-manifestacao) THEN
				CREATE anexo-manifestacao.

			ASSIGN anexo-manifestacao.id-anexo-manifestacao		= i-id-anexo-manifestacao
				   anexo-manifestacao.id-manifestacao			= manifestacao.id-manifestacao
				   anexo-manifestacao.path-anexo				= 'edit-' + portal-anexo-manifestacao-form.path-anexo
				   NO-ERROR.
			
			IF ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 THEN DO:
				DO ix = 1 TO ERROR-STATUS:NUM-MESSAGES:
					ASSIGN pMsgResponse = pMsgResponse + STRING (ERROR-STATUS:GET-NUMBER(ix)) + " " + ERROR-STATUS:GET-MESSAGE(ix) + ". "
							pRetOK		  = FALSE.
				END.
				RETURN.
			END.

			ASSIGN vDestino = app_config.caminho_img_anexo + manifestacao.id-manifestacao
				   vOrigem	= get-config("fileUploadDirectory":U) + '\' + portal-anexo-manifestacao-form.token.

			MESSAGE 'vDestino.: ' vDestino skip
					'vOrigem.: ' vOrigem.
			/* Verifica se a pasta existe */
			ASSIGN FILE-INFO:FILE-NAME = vDestino.

			/* Se n√£o a pasta n√£o existir cria */
			IF FILE-INFO:FULL-PATHNAME = ? then
				OS-CREATE-DIR VALUE(vDestino).

			ASSIGN FILE-INFO:FILE-NAME = vDestino.
    		IF FILE-INFO:FULL-PATHNAME <> ? THEN DO:
				MESSAGE  'DELETOU.: ' vOrigem + "\" + portal-anexo-manifestacao-form.path-anexo.
					
				/* verifica se arquivo foi gerado */	 
				FILE-INFO:FILE-NAME = vDestino + "\" + anexo-manifestacao.path-anexo.
				
				IF FILE-INFO:PATHNAME = ? THEN DO:
					/*move do tempor·rio para definitivo*/
					OS-COPY VALUE(vOrigem + "\" + portal-anexo-manifestacao-form.path-anexo) VALUE(vDestino + "\" + anexo-manifestacao.path-anexo).
					
				END.
			END.

		END.

		/*apaga o upload lixo do tempor·rio*/
		ASSIGN FILE-INFO:FILE-NAME = vOrigem.		
		MESSAGE 'FILE-INFO:FULL-PATHNAME.: ' FILE-INFO:FULL-PATHNAME.
		IF FILE-INFO:FULL-PATHNAME <> ? THEN
			RUN pi-limpa-diretorio(INPUT FILE-INFO:FULL-PATHNAME).

		ASSIGN pMsgResponse	= manifestacao.id-manifestacao.

		/*Envia email ao grupo respons·vel pela manifestacao*/
		ASSIGN c-body = pMsgResponse.
		ASSIGN c-email = fi-get-email-destinatario(INPUT manifestacao.cod-grp-usuar)
			   .
        
        RUN pi-envia-email(INPUT app_config.email_remetente_solic, INPUT c-email, INPUT cpc('ManifestaÁ„o ') + manifestacao.nr-protocolo + ' editada por ' + usuarioCorrente, INPUT (c-body), OUTPUT c-status, INPUT 'Finalizada').
        //run pi-grava-envia-email(INPUT pIdManifestacao, INPUT i-id-tar-manifestacao, INPUT c-body, INPUT c-status).
        RUN pi-grava-historico-manifestcacao(INPUT pIdManifestacao, INPUT ((pParecerTecnico)) , INPUT 'EDITADA', INPUT usuarioCorrente, INPUT cTpItem, INPUT '', INPUT usuarioCorrente).
        
        ASSIGN pMsgResponse						= "protocolo: " + manifestacao.nr-protocolo.
	end.

END PROCEDURE.

PROCEDURE pi-transfere-manifestacao:

	DEFINE INPUT-OUTPUT PARAMETER pRetOK      		    AS LOGICAL   NO-UNDO.
	DEFINE INPUT-OUTPUT PARAMETER pMsgResponse          AS CHARACTER NO-UNDO.
    DEFINE INPUT        PARAMETER pIdTarManifestacao    AS CHARACTER NO-UNDO.
    DEFINE INPUT        PARAMETER pIdManifestacao       AS CHARACTER NO-UNDO.
    DEFINE INPUT        PARAMETER pTpItem               AS CHARACTER NO-UNDO.
    DEFINE INPUT        PARAMETER pParecerTecnico       AS CHARACTER NO-UNDO.
    DEFINE INPUT        PARAMETER pConclusao            AS CHARACTER NO-UNDO.

	DEFINE VARIABLE vDestino        		AS CHAR NO-UNDO. 
	DEFINE VARIABLE vOrigem	        		AS CHAR NO-UNDO. 
	DEFINE VARIABLE i-id-anexo-manifestacao	AS INT  NO-UNDO.
	DEFINE VARIABLE c-status        		AS CHAR NO-UNDO.
	DEFINE VARIABLE i-id-tar-manifestacao	AS INT  NO-UNDO.
    DEFINE VARIABLE c-acao                  AS CHAR NO-UNDO INIT "transferida".
    DEFINE VARIABLE cUsuarioCorrente        AS CHAR NO-UNDO.
    DEFINE VARIABLE cTpItem                 AS CHAR NO-UNDO.
    
    ASSIGN cTpItem          = pTpItem
           cUsuarioCorrente = usuarioCorrente.
    
    IF pTpItem = 'SAC' THEN
        ASSIGN c-acao = "solucionada".
    ELSE IF pTpItem <> 'SAI' AND pTpItem <> 'SAE' AND pTpItem <> 'SAL' AND pTpItem <> 'SAP' AND pTpItem <> 'SAC' THEN
        ASSIGN cUsuarioCorrente = pTpItem
               cTpItem          = ''.
    
    MESSAGE 'cTpItem          = ' cTpItem
           ' cUsuarioCorrente = ' cUsuarioCorrente.
           
            
	FIND FIRST manifestacao NO-LOCK
		WHERE manifestacao.id-manifestacao = pIdManifestacao NO-ERROR.

	IF AVAIL(manifestacao) THEN DO:

        ASSIGN pMsgResponse						= manifestacao.id-manifestacao.

		/*Envia email ao grupo respons·vel pela manifestacao*/
		ASSIGN c-body = pMsgResponse.
		ASSIGN c-email = fi-get-email-destinatario(INPUT manifestacao.cod-grp-usuar)
			   .
	    RUN pi-envia-email(INPUT app_config.email_remetente_solic, INPUT c-email, INPUT cpc('ManifestaÁ„o ') + manifestacao.nr-protocolo + ' ' + c-acao + ' por ' + usuarioCorrente, INPUT (c-body), OUTPUT c-status, INPUT 'Transferida').
        RUN pi-finaliza-tarefa-manifestcacao(INPUT INT(pIdTarManifestacao)).
        RUN pi-grava-tarefa-manifestcacao(INPUT pIdManifestacao, INPUT ((pParecerTecnico)) , INPUT 'TRANSFERIDA', INPUT cUsuarioCorrente, OUTPUT i-id-tar-manifestacao, INPUT cTpItem, INPUT ((pConclusao)), INPUT usuarioCorrente).
        //run pi-grava-envia-email(INPUT pIdManifestacao, INPUT i-id-tar-manifestacao, INPUT c-body, INPUT c-status).
        RUN pi-grava-historico-manifestcacao(INPUT pIdManifestacao, INPUT ((pParecerTecnico)) , INPUT 'TRANSFERIDA', INPUT cUsuarioCorrente, INPUT cTpItem, INPUT ((pConclusao)), INPUT usuarioCorrente).
        
	end.

     FIND FIRST manifestacao EXCLUSIVE-LOCK 
            WHERE manifestacao.id-manifestacao = pIdManifestacao NO-ERROR.
            
    IF AVAIL (manifestacao) THEN
       ASSIGN manifestacao.cd-status            = IF pTpItem = 'SAC' THEN 4 ELSE manifestacao.cd-status
              manifestacao.cod-usuar            = ''
              manifestacao.conclusao-parecer    = pConclusao
              pMsgResponse						= "protocolo: " + manifestacao.nr-protocolo.                                                                                                  
END PROCEDURE.

PROCEDURE pi-devolve-manifestacao:

	DEFINE INPUT-OUTPUT PARAMETER pRetOK      		    AS LOGICAL   NO-UNDO.
	DEFINE INPUT-OUTPUT PARAMETER pMsgResponse          AS CHARACTER NO-UNDO.
    DEFINE INPUT        PARAMETER pIdTarManifestacao    AS CHARACTER NO-UNDO.
    DEFINE INPUT        PARAMETER pIdManifestacao       AS CHARACTER NO-UNDO.
    DEFINE INPUT        PARAMETER pTpItem               AS CHARACTER NO-UNDO.
    DEFINE INPUT        PARAMETER pParecerTecnico       AS CHARACTER NO-UNDO.
    DEFINE INPUT        PARAMETER pConclusao            AS CHARACTER NO-UNDO.

	DEFINE VARIABLE vDestino        		AS CHAR NO-UNDO. 
	DEFINE VARIABLE vOrigem	        		AS CHAR NO-UNDO. 
	DEFINE VARIABLE i-id-anexo-manifestacao	AS INT  NO-UNDO.
	DEFINE VARIABLE c-status        		AS CHAR NO-UNDO.
	DEFINE VARIABLE i-id-tar-manifestacao	AS INT  NO-UNDO.
    DEFINE VARIABLE c-acao                  AS CHAR NO-UNDO INIT "devolvida".
    DEFINE VARIABLE cUsuarioCorrente        AS CHAR NO-UNDO.
    DEFINE VARIABLE cTpItem                 AS CHAR NO-UNDO.
              
            
	FIND FIRST manifestacao NO-LOCK
		WHERE manifestacao.id-manifestacao = pIdManifestacao NO-ERROR.

	IF AVAIL(manifestacao) THEN DO:

        ASSIGN pMsgResponse						= manifestacao.id-manifestacao.
        
        FIND LAST TAR-MANIFESTACAO NO-LOCK WHERE TAR-MANIFESTACAO.ID-MANIFESTACAO = manifestacao.id-manifestacao AND TAR-MANIFESTACAO.DS-STATUS = 'SOLUCIONADA' NO-ERROR.
        IF AVAIL(TAR-MANIFESTACAO) THEN
            ASSIGN cUsuarioCorrente = TAR-MANIFESTACAO.COD-USUAR-CORRENTE.        

		/*Envia email ao grupo respons·vel pela manifestacao*/
		ASSIGN c-body = pMsgResponse.
		ASSIGN c-email = fi-get-email-destinatario(INPUT manifestacao.cod-grp-usuar)
			   .
	    RUN pi-envia-email(INPUT app_config.email_remetente_solic, INPUT c-email, INPUT cpc('ManifestaÁ„o ') + manifestacao.nr-protocolo + ' ' + c-acao + ' por ' + usuarioCorrente, INPUT (c-body), OUTPUT c-status, INPUT 'Devolvida').
        RUN pi-finaliza-tarefa-manifestcacao(INPUT INT(pIdTarManifestacao)).
        RUN pi-grava-tarefa-manifestcacao(INPUT pIdManifestacao, INPUT ((pParecerTecnico)) , INPUT 'DEVOLVIDA', INPUT cUsuarioCorrente, OUTPUT i-id-tar-manifestacao, INPUT cTpItem, INPUT ((pConclusao)), INPUT usuarioCorrente).
        //run pi-grava-envia-email(INPUT pIdManifestacao, INPUT i-id-tar-manifestacao, INPUT c-body, INPUT c-status).
        RUN pi-grava-historico-manifestcacao(INPUT pIdManifestacao, INPUT ((pParecerTecnico)) , INPUT 'DEVOLVIDA', INPUT cUsuarioCorrente, INPUT cTpItem, INPUT ((pConclusao)), INPUT usuarioCorrente).
        
	end.

     FIND FIRST manifestacao EXCLUSIVE-LOCK 
            WHERE manifestacao.id-manifestacao = pIdManifestacao NO-ERROR.
            
    IF AVAIL (manifestacao) THEN
       ASSIGN manifestacao.cd-status            = 2
              pMsgResponse						= "protocolo: " + manifestacao.nr-protocolo.
       
END PROCEDURE.

PROCEDURE pi-red-json:
   	DEFINE INPUT-OUTPUT PARAMETER pRetOK      		AS LOGICAL   NO-UNDO.
	DEFINE INPUT-OUTPUT PARAMETER pMsgResponse      AS CHARACTER NO-UNDO.
   
	DEFINE VARIABLE ix						AS INT.

   ASSIGN pRetOK = TEMP-TABLE body:READ-JSON("HANDLE", WEB-CONTEXT, "MERGE").
  
   IF ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 THEN DO:
      DO ix = 1 TO ERROR-STATUS:NUM-MESSAGES:
         ASSIGN pMsgResponse = pMsgResponse + STRING (ERROR-STATUS:GET-NUMBER(ix)) + " " + ERROR-STATUS:GET-MESSAGE(ix) + ". ".
      END.                                                                                                       
   END.

	MESSAGE 'pRetOK....... ' pRetOK.
	MESSAGE 'pMsgResponse. ' pMsgResponse.
  	
END PROCEDURE.

procedure pi-limpa-diretorio:

    DEFINE INPUT PARAMETER vDiretorio AS CHARACTER NO-UNDO.

    DEFINE VARIABLE vArquivo   AS CHARACTER FORMAT "x(60)" NO-UNDO.
    DEFINE VARIABLE osComando  AS CHARACTER NO-UNDO.
    DEFINE VARIABLE arqOrigem  AS CHARACTER FORMAT "x(60)" NO-UNDO.
    
    ASSIGN osComando = "dir /b " + vDiretorio + "\*.*".
    INPUT THROUGH VALUE(osComando). /*** dir /b - lista os arquivo no modo verboso (depurado) ****/
    
    REPEAT : IMPORT UNFORMATTED vArquivo.
        ASSIGN arqOrigem = vDiretorio + "\" + vArquivo.      
        OS-DELETE VALUE(arqOrigem).

        FIND FIRST portal-anexo-manifestacao-form EXCLUSIVE-LOCK
            WHERE portal-anexo-manifestacao-form.cod-usu-corrente   = usuarioCorrente
              AND portal-anexo-manifestacao-form.token              = get-cookie("SessionContextToken") 
              AND portal-anexo-manifestacao-form.path-anexo         = vArquivo NO-ERROR.
        IF AVAIL (portal-anexo-manifestacao-form) THEN
            DELETE portal-anexo-manifestacao-form.
    END.

	OS-DELETE VALUE(vDiretorio).
end procedure. 
