/**
 * 
 * ---------------
 *
 *  - Portal de Manifestação de Clientes - SAC
 *
 * Autor: carloseloi.prado@gmail.com
 */


/** Variaveis de segurana */
DEFINE VARIABLE usuarioCorrente				LIKE usuar_mestre.cod_usuario NO-UNDO.
DEFINE VARIABLE lnkNewManifestacao			AS CHARACTER NO-UNDO.

DEFINE VARIABLE hSession				AS HANDLE NO-UNDO.
DEFINE VARIABLE timeoutSessao			AS CHARACTER NO-UNDO.
DEFINE VARIABLE credenciaisToken		AS CHARACTER NO-UNDO.
DEFINE VARIABLE novaValidadeSessao		AS DATETIME NO-UNDO.

DEFINE BUFFER b-seg-usuar_mestre FOR usuar_mestre.
/*DEFINE BUFFER b-seg-perm-mkt-outras-saidas FOR perm-mkt-outras-saidas.*/

/** Valida se o metodo http solicitado 'e valido para o programa chamado */
IF INDEX("{1}",request_method) > 0 THEN DO:

	/** sem token de sessao */
	IF LENGTH(get-cookie("SessionContextToken")) = 0 THEN DO:
		RUN pi-redireciona(INPUT "login", 2 /* sessão invalida */).
		STOP.
	END.

	/** Busca o contexto da sessao com base no token */
	RUN web/wutp/wu-sessao.p PERSISTENT SET hSession.
	RUN setToken IN hSession ( INPUT get-cookie("SessionContextToken") ).
	RUN getContext IN hSession ( INPUT "usuarioCorrente", OUTPUT usuarioCorrente).
    RUN getContext IN hSession ( INPUT "lnkNewManifestacao", OUTPUT lnkNewManifestacao).
	RUN getContext IN hSession ( INPUT "sessionTimeout", OUTPUT timeoutSessao ).
	RUN getContext IN hSession ( INPUT "credenciaisCorrentes", OUTPUT credenciaisToken ).

	/** Sessao expirada */
	IF DATETIME(timeoutSessao) < NOW THEN DO:
		RUN pi-redireciona(INPUT "login", 7 /* sessão expirada */).
		STOP.
	END.
	ELSE DO:
		ASSIGN novaValidadeSessao = NOW.
		ASSIGN novaValidadeSessao = ADD-INTERVAL(novaValidadeSessao, INT(app_config.timeout_sessao), "hours").
		RUN setContext IN hSession ( INPUT "sessionTimeout", INPUT STRING(novaValidadeSessao) ).
	END.

	/** Usuario logado */
	FIND FIRST b-seg-usuar_mestre WHERE b-seg-usuar_mestre.cod_usuario = usuarioCorrente NO-LOCK NO-ERROR.
	IF NOT AVAILABLE b-seg-usuar_mestre THEN DO:
		RUN pi-redireciona(INPUT "login", 2 /* sessão invalida */).
		STOP.
	END.
	ELSE DO:
		IF ENCODE(b-seg-usuar_mestre.cod_usuario + "|" + b-seg-usuar_mestre.cod_senha) <> credenciaisToken THEN DO:
			RUN pi-redireciona(INPUT "login", 2 /* sessão invalida */).
			STOP.
		END.
	END.

	RUN destroy IN hSession.

END.
ELSE DO:

	RUN destroy IN hSession.

	RUN pi-redireciona(INPUT "login", 2 /* sessão invalida */).
	STOP.

END.






 	/*
	FIND FIRST b1-configur WHERE b1-configur.idi_dtsul_usuar_mestre = b1-usuar_mestre.idi_dtsul and b1-configur.nom_configur = "cliente" NO-LOCK NO-ERROR.
	FIND FIRST b1-emitente WHERE b1-emitente.cod-emitente = int(b1-configur.des_val_configur) NO-LOCK NO-ERROR.
	*/
