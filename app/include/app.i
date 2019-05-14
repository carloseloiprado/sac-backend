{include/email.i}

/**
 * 
 * ---------------
 *
 *  - Portal de Manifestação de Clientes - SAC
 *
 * Autor: carloseloi.prado@gmail.com
 */

FUNCTION fi_seta_menu_html_active RETURNS CHARACTER (p_pagina_atual AS CHARACTER, p_pagina_menu AS CHARACTER) FORWARD.
FUNCTION retorna_cabecalho_mensagem_log RETURNS CHARACTER (cod_programa AS CHARACTER) FORWARD.
FUNCTION retorna_rodape_mensagem_log RETURNS CHARACTER (cod_programa AS CHARACTER) FORWARD.
FUNCTION toUtf8 RETURNS CHARACTER (inputString AS CHARACTER) FORWARD.
FUNCTION removePonto RETURNS CHARACTER (INPUT inputString AS CHARACTER) FORWARD.
FUNCTION fi-get-nomusuario RETURNS CHARACTER (INPUT pCodusuar AS CHARACTER) FORWARD.
FUNCTION fi-get-nomgrupo RETURNS CHARACTER (INPUT pCodGrp AS CHARACTER) FORWARD.
FUNCTION fi-get-next-id-hist-manifestacao RETURNS INT () FORWARD.
FUNCTION fi-get-next-id-tar-manifestacao RETURNS INT () FORWARD.

/** Variaveis de uso geral */
DEFINE VARIABLE c-label-disponivel					AS CHARACTER INITIAL "<span class='label label-success'>Dispon&iacute;vel</span>".
DEFINE VARIABLE c-label-indisponivel				AS CHARACTER INITIAL "<span class='label label-danger'>Indispon&iacute;vel</span>".
DEFINE VARIABLE i-cod-repres								AS INTEGER NO-UNDO.
DEFINE VARIABLE c-nome-gerente							AS CHARACTER NO-UNDO.
DEFINE VARIABLE c-email-gerente							AS CHARACTER NO-UNDO.


/** Parametros gerais */
FIND FIRST param-estoq NO-LOCK NO-ERROR.


/*Functions*/

FUNCTION fi-get-next-id-tar-manifestacao RETURNS INT ():

	DEF VAR i-id-tar-manifestacao AS INT INIT 0.
	DEF BUFFER b-tar-manifestacao FOR tar-manifestacao.

	FIND LAST b-tar-manifestacao NO-LOCK NO-ERROR.

	IF AVAIL(b-tar-manifestacao) THEN
		ASSIGN i-id-tar-manifestacao = b-tar-manifestacao.id-tar-manifestacao.

	REPEAT:

		FIND FIRST b-tar-manifestacao WHERE b-tar-manifestacao.id-tar-manifestacao = i-id-tar-manifestacao + 1 NO-LOCK NO-ERROR.
		ASSIGN i-id-tar-manifestacao = i-id-tar-manifestacao + 1 .

		IF NOT AVAIL(b-tar-manifestacao) THEN LEAVE.
	END.

	RETURN i-id-tar-manifestacao.
  
END FUNCTION.

FUNCTION fi-get-next-id-hist-manifestacao RETURNS INT ():

	DEF VAR i-id-hist-manifestacao AS INT INIT 0.
	DEF BUFFER b-hist-manifestacao FOR hist-manifestacao .

	FIND LAST b-hist-manifestacao NO-LOCK NO-ERROR.

	IF AVAIL(b-hist-manifestacao) THEN
		ASSIGN i-id-hist-manifestacao = b-hist-manifestacao.id-hist-manifestacao.

	REPEAT:

		FIND FIRST b-hist-manifestacao WHERE b-hist-manifestacao.id-hist-manifestacao = i-id-hist-manifestacao + 1 NO-LOCK NO-ERROR.
		ASSIGN i-id-hist-manifestacao = i-id-hist-manifestacao + 1 .

		IF NOT AVAIL(b-hist-manifestacao) THEN LEAVE.
	END.

	RETURN i-id-hist-manifestacao.
  
END FUNCTION.

/**Fun‡äes de conversÆo de charset*/
function cpc returns char (p-string as character):
    return codepage-convert(p-string,"iso8859-1","utf-8").
end function.

function cpc-in returns char (p-string as character):
    return codepage-convert(p-string,"utf-8","iso8859-1").
end function.

function cpc-out returns char (p-string as character):
    return codepage-convert(p-string,"iso8859-1","ibm850").
end function.

function cpc-lbl returns char (p-string as character):
    return codepage-convert(p-string,"ibm850","iso8859-1").
end function.

function cpc-Utf returns char (p-string as character):
    return codepage-convert(p-string,"ibm850","utf-8").
end function.
/***/

/** Define o Menu como active ou nÆo dependendo da pagina corrente */
FUNCTION fi_seta_menu_html_active RETURNS CHARACTER (p_pagina_atual AS CHARACTER, p_pagina_menu AS CHARACTER):

	IF INDEX(p_pagina_atual,p_pagina_menu) > 0 THEN
		RETURN "active".
	ELSE
		RETURN "".

END FUNCTION.

/** Cabe‡alho de mensagem de log */
FUNCTION retorna_cabecalho_mensagem_log RETURNS CHARACTER (cod_programa AS CHARACTER):

	RETURN CHR(10) +
		   "|--|" + cod_programa + "|" + FILL("-",20) +
		   CHR(10) +
		   "|Usuario: " + get-cookie("cod_usu_websession") +
		   CHR(10) +
		   "|Method.: " + request_method +
		   CHR(10) +
		   "|" + FILL("-", 24 + LENGTH(cod_programa) ).

END FUNCTION.

/** Rodape de mensagem de log */
FUNCTION retorna_rodape_mensagem_log RETURNS CHARACTER (cod_programa AS CHARACTER):

	RETURN "|" + FILL("-", 24 + LENGTH(cod_programa) ) + CHR(10).

END FUNCTION.

/** Converte string para utf8 */
FUNCTION toUtf8 RETURNS CHARACTER (inputString AS CHARACTER):

	RETURN CODEPAGE-CONVERT(inputString,"utf-8").

END FUNCTION.

/** Converte string para iso8859-1 */
FUNCTION fromUtf8ToIbm850 RETURNS CHARACTER (inputString AS CHARACTER):

	RETURN CODEPAGE-CONVERT(inputString,"ibm850","utf-8").

END FUNCTION.

FUNCTION fromISOtoIBM RETURNS CHARACTER (inputString AS CHARACTER):

	RETURN CODEPAGE-CONVERT(inputString,'ibm850','ISO8859-1').

END FUNCTION.

/** Remove os pontos de uma string */
FUNCTION removePonto RETURNS CHARACTER (INPUT inputString AS CHARACTER):

	RETURN REPLACE(inputString,".","").

END FUNCTION.

FUNCTION fi-get-nomusuario RETURNS CHARACTER (INPUT pCodusuar AS CHARACTER):

    FIND FIRST usuar_mestre USE-INDEX srmstr_id NO-LOCK WHERE usuar_mestre.cod_usuario = pCodusuar NO-ERROR.
    
    IF AVAIL(usuar_mestre) THEN RETURN usuar_mestre.nom_usuario.
    ELSE RETURN pCodusuar.

END FUNCTION.

FUNCTION fi-get-nomgrupo RETURNS CHARACTER (INPUT pCodGrp AS CHARACTER):

    FIND FIRST grp_usuar USE-INDEX grpusuar_grp NO-LOCK WHERE grp_usuar.cod_grp_usuar = pCodGrp NO-ERROR.
    
    IF AVAIL(grp_usuar) THEN RETURN grp_usuar.des_grp_usuar.	
    ELSE RETURN pCodGrp.

END FUNCTION.

/** Procedures ***/

/** Redireciona para pagina */
PROCEDURE pi-redireciona:

	DEFINE INPUT PARAMETER c-pagina 			AS CHARACTER.
	DEFINE INPUT PARAMETER i-mensagem			AS INTEGER.

	output-content-type("text/html;charset=UTF-8").

	IF i-mensagem > 0 THEN
		ASSIGN c-pagina = c-pagina + "?status=" + ENCODE(STRING(i-mensagem)).

	{&out} SKIP
	" <script> " skip
	"document.location = '" c-pagina "';" skip
	"</script>".

END PROCEDURE.

PROCEDURE pi-grava-historico-manifestcacao:
	DEFINE INPUT PARAMETER pIdManifestacao		AS CHARACTER 	NO-UNDO.
	DEFINE INPUT PARAMETER pDsParecer			AS CHARACTER 	NO-UNDO.
	DEFINE INPUT PARAMETER pDsStatus			AS CHARACTER 	NO-UNDO.
    DEFINE INPUT PARAMETER pUsuarioCorrente		AS CHARACTER 	NO-UNDO.
    DEFINE INPUT PARAMETER pGrpUsuario  		AS CHARACTER 	NO-UNDO.
    DEFINE INPUT PARAMETER pConclusao     		AS CHARACTER 	NO-UNDO.
    DEFINE INPUT PARAMETER pCodUsuarioCorrente	AS CHARACTER 	NO-UNDO.

	/*FIND FIRST hist-manifestacao EXCLUSIVE-LOCK 
		WHERE hist-manifestacao.id-manifestacao 	= pIdManifestacao
			AND hist-manifestacao.dt-cadastro 		= manifestacao.dt-cadastro
			AND hist-manifestacao.hr-cadastro 		= manifestacao.hr-cadastro
			//AND tar-manifestacao.ds-status        BEGINS 'ATR'
			AND tar-manifestacao.ds-status        BEGINS substr(pDsStatus,1,3)
			NO-ERROR.

	IF NOT AVAIL(hist-manifestacao) THEN*/
		CREATE hist-manifestacao.

	ASSIGN hist-manifestacao.id-hist-manifestacao	    = fi-get-next-id-hist-manifestacao()
            hist-manifestacao.id-manifestacao 			= pIdManifestacao
            hist-manifestacao.cod-grp-usuar				= pGrpUsuario	 
            hist-manifestacao.cod-usuar 				= pUsuarioCorrente
            hist-manifestacao.ds-parecer				= pDsParecer
            hist-manifestacao.ds-status					= pDsStatus
            hist-manifestacao.dt-cadastro				= TODAY
            hist-manifestacao.hr-cadastro				= TIME
            hist-manifestacao.conclusao-parecer         = pConclusao
            hist-manifestacao.cod-usuar-corrente        = pCodUsuarioCorrente
            .

END PROCEDURE.

PROCEDURE pi-grava-tarefa-manifestcacao:

	DEFINE INPUT PARAMETER pIdManifestacao		AS CHARACTER 	NO-UNDO.
	DEFINE INPUT PARAMETER pDsParecer			AS CHARACTER 	NO-UNDO.
	DEFINE INPUT PARAMETER pDsStatus			AS CHARACTER 	NO-UNDO.
    DEFINE INPUT PARAMETER pUsuarioCorrente		AS CHARACTER 	NO-UNDO.
	DEFINE OUTPUT PARAMETER pidTarManifestacao	AS INTEGER 	    NO-UNDO.
    DEFINE INPUT PARAMETER pGrpUsuario  		AS CHARACTER 	NO-UNDO.
    DEFINE INPUT PARAMETER pConclusao     		AS CHARACTER 	NO-UNDO.
    DEFINE INPUT PARAMETER pCodUsuarioCorrente	AS CHARACTER 	NO-UNDO.


	/*FIND FIRST tar-manifestacao EXCLUSIVE-LOCK 
		WHERE tar-manifestacao.id-manifestacao 	= pIdManifestacao
			AND tar-manifestacao.dt-cadastro 	= manifestacao.dt-cadastro
			AND tar-manifestacao.hr-cadastro 	= manifestacao.hr-cadastro
			//AND tar-manifestacao.ds-status        BEGINS 'ATR'
			AND tar-manifestacao.ds-status        BEGINS substr(pDsStatus,1,3)
			NO-ERROR.

	IF NOT AVAIL(tar-manifestacao) THEN*/
		CREATE tar-manifestacao.

	ASSIGN tar-manifestacao.id-tar-manifestacao	        = fi-get-next-id-tar-manifestacao()
            tar-manifestacao.id-manifestacao 			= pIdManifestacao
            tar-manifestacao.cod-grp-usuar				= pGrpUsuario 	 
            tar-manifestacao.cod-usuar 					= IF pGrpUsuario <> '' THEN '' ELSE pUsuarioCorrente
            tar-manifestacao.ds-tar-manifestacao	    = pDsParecer
            tar-manifestacao.ds-status					= pDsStatus
            tar-manifestacao.dt-cadastro				= TODAY
            tar-manifestacao.hr-cadastro				= TIME
            tar-manifestacao.dt-atribuicao				= TODAY
            tar-manifestacao.hr-atribuicao				= TIME
            pidTarManifestacao							= tar-manifestacao.id-tar-manifestacao
            tar-manifestacao.conclusao-parecer          = pConclusao
            tar-manifestacao.cod-usuar-corrente         = pCodUsuarioCorrente
            .
     
     IF pDsStatus = 'FINALIZADA' THEN
        ASSIGN tar-manifestacao.dt-execucao	= TODAY
               tar-manifestacao.hr-execucao	= TIME
               .      

END PROCEDURE.

PROCEDURE pi-finaliza-tarefa-manifestcacao:
	DEFINE INPUT PARAMETER pIdTarManifestacao		AS INTEGER 	NO-UNDO.

	FIND FIRST tar-manifestacao EXCLUSIVE-LOCK 
		WHERE tar-manifestacao.id-tar-manifestacao 	= pIdTarManifestacao.

	IF AVAIL(tar-manifestacao) THEN
		ASSIGN tar-manifestacao.dt-execucao			= TODAY
               tar-manifestacao.hr-execucao			= TIME
                .

END PROCEDURE.


define temp-table tt-erros-geral no-undo
       field identif-msg           as character format "X(60)"
       field num-sequencia-erro    as integer format "999"
       field cod-erro              as integer format "99999"
       field des-erro              as character format "X(60)"
       field nr_pre_pedido         like ped-venda.nr-pedcli
       field nome-abrev            like ped-venda.nome-abrev
			 field nr-requisicao				 like requisicao.nr-requisicao.


DEF TEMP-TABLE rowerrors no-undo
    FIELD errorsequence    as int
    FIELD errornumber      as int
    FIELD errordescription as char
    FIELD errorparameters  as char
    FIELD errortype        as char
    FIELD errorhelp        as char
    FIELD errorsubtype     as char.
    
 DEF TEMP-TABLE ttTpItem no-undo
    FIELD cod-grp-usuar    as CHAR
    FIELD nom-grp-usuar    as CHAR.
    
 CREATE ttTpItem. ASSIGN ttTpItem.cod-grp-usuar = 'SAI' ttTpItem.nom-grp-usuar = 'Produto'. 
 CREATE ttTpItem. ASSIGN ttTpItem.cod-grp-usuar = 'SAE' ttTpItem.nom-grp-usuar = 'Embalagens'. 
 CREATE ttTpItem. ASSIGN ttTpItem.cod-grp-usuar = 'SAL' ttTpItem.nom-grp-usuar = cpc-lbl('Transporte/Logística'). 
 CREATE ttTpItem. ASSIGN ttTpItem.cod-grp-usuar = 'SAP' ttTpItem.nom-grp-usuar = cpc-lbl('Produção').  
 
 DEF TEMP-TABLE ttTipo no-undo
    FIELD cod-tipo    as CHAR
    FIELD dsc-tipo    as CHAR.
    
 CREATE ttTipo. ASSIGN ttTipo.cod-tipo = 'elogio' ttTipo.dsc-tipo = 'Elogio'. 
 CREATE ttTipo. ASSIGN ttTipo.cod-tipo = 'informacao' ttTipo.dsc-tipo = cpc-lbl('Informação'). 
 CREATE ttTipo. ASSIGN ttTipo.cod-tipo = 'sugestao' ttTipo.dsc-tipo = cpc-lbl('Sugestão'). 
 CREATE ttTipo. ASSIGN ttTipo.cod-tipo = 'reclamacao' ttTipo.dsc-tipo = cpc-lbl('Reclamação'). 
 CREATE ttTipo. ASSIGN ttTipo.cod-tipo = 'solicitacao' ttTipo.dsc-tipo = cpc-lbl('Solicitação'). 
 CREATE ttTipo. ASSIGN ttTipo.cod-tipo = 'ondeencontrar' ttTipo.dsc-tipo = cpc-lbl('Onde Encontrar').

 DEF TEMP-TABLE ttParecer no-undo
    FIELD cod-parecer    as CHAR
    FIELD dsc-parecer    as CHAR.
    
 CREATE ttParecer. ASSIGN ttParecer.cod-parecer = 'solicitaramostra' ttParecer.dsc-parecer = 'Solicitar Amostra'. 
 CREATE ttParecer. ASSIGN ttParecer.cod-parecer = 'procede' ttParecer.dsc-parecer = 'Procede'. 
 CREATE ttParecer. ASSIGN ttParecer.cod-parecer = 'naoprocede' ttParecer.dsc-parecer = cpc-lbl('Não Procede'). 
 


 
  
    
    
    
    
    
    
