/**
 * 
 * ---------------
 *
 *  - Portal de Solicitacoes
 *
 * Autor: carloseloi.prado@gmail.com
 *
 * Objetivo...: Include para ler o XML de configura��es e disponibilizar para todo o potal de solicitcoes
 * Observa��es: O arquivo de configura��es (config.xml) deve estar em app/config.
 */
 
/** Defini��o das fun��es locais */
FUNCTION fi_retorna_diretorio_fisico_propath RETURNS CHARACTER (p_string_busca AS CHARACTER, p_final_adicional AS CHARACTER) FORWARD.
  
  
/** Temp-table com as configura��es */
DEFINE TEMP-TABLE app_config NO-UNDO
   FIELD titulo_paginas   			AS CHARACTER FORMAT "x(200)"
   FIELD caminho_assets   			AS CHARACTER FORMAT "x(200)"
   FIELD caminho_fisico_assets  	AS CHARACTER FORMAT "x(200)"
   FIELD caminho_img_anexo			AS CHARACTER FORMAT "x(200)"
   FIELD href_img_anexo				AS CHARACTER FORMAT "x(200)"
   FIELD mensagem_footer			AS CHARACTER FORMAT "x(500)"
   FIELD nome_cliente				AS CHARACTER FORMAT "x(500)"
   FIELD habilita_log				AS LOGICAL
   FIELD email_remetente_solic		AS CHARACTER FORMAT "x(100)"
   FIELD timeout_sessao				AS CHARACTER FORMAT "x(2)"
   FIELD texto_resp_imediata		AS CHARACTER FORMAT "x(500)"
   FIELD email_rnc                  AS CHARACTER FORMAT "x(50)"
   FIELD user_rnc                   AS CHARACTER FORMAT "x(20)"
   FIELD environment                AS CHARACTER FORMAT "x(5)"
   FIELD user_environment           AS CHARACTER FORMAT "x(20)"
   FIELD email_user_environment     AS CHARACTER FORMAT "x(50)"
   .
 
 
/** Variaveis para leitura do XML */
DEFINE VARIABLE v-return-mode        AS LOGICAL   NO-UNDO.
DEFINE VARIABLE v-sourcetype         AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-read-xml           AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-read-xml-path      AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-readmode           AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-schemapath         AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-override-def-map   AS LOGICAL   NO-UNDO.
DEFINE VARIABLE v-field-type-map     AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-verify-schema-mode AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-test_xml           AS CHARACTER NO-UNDO. 
DEFINE VARIABLE v-slash-environment  AS CHARACTER NO-UNDO.


/** Defini��o de paramatro definir SO (libux ou Windows) */
 IF ( SERVER_SOFTWARE matches "*linux*" ) THEN ASSIGN v-slash-environment = "/" ELSE ASSIGN v-slash-environment = "\".


/** Defini��o de paramatros para leitura do XML */
ASSIGN v-sourcetype         = "FILE"
       v-read-xml           = "config.xml"
       v-read-xml-path      = fi_retorna_diretorio_fisico_propath("*app", v-slash-environment + "config" + v-slash-environment ) + v-read-xml
       v-readmode           = "EMPTY"
       v-schemapath         = ?
       v-override-def-map   = ?
       v-field-type-map     = ? 
       v-verify-schema-mode = ?.
	   
/** Verifica se conseguiu ler o XML */
v-return-mode = TEMP-TABLE app_config:READ-XML(v-sourcetype, 
											  v-read-xml-path , 
											  v-readmode, 
											  v-schemapath, 
											  v-override-def-map, 
											  v-field-type-map, 
											  v-verify-schema-mode) NO-ERROR.
 
/** Retorna erro se n�o conseguir ler o arquivo de configura��o */
IF v-return-mode THEN DO:
	FIND FIRST app_config NO-LOCK NO-ERROR.
END.
ELSE DO:
	output-content-type("text/html").
	{&out} 'erro de configuracao! verifique: ' v-read-xml-path.
	STOP.
END.


/** Funcao para retornar o um caminho fisico da propath */
FUNCTION fi_retorna_diretorio_fisico_propath RETURNS CHARACTER (p_string_busca AS CHARACTER, p_final_adicional AS CHARACTER):

	DEFINE VARIABLE i 				  AS INTEGER.
	DEFINE VARIABLE c_caminho_propath AS CHARACTER FORMAT "x(200)".
	
	REPEAT i = NUM-ENTRIES(PROPATH) TO 1 BY -1:
		IF ENTRY(i , PROPATH) MATCHES p_string_busca THEN DO:
			FILE-INFO:FILE-NAME = ENTRY(i , PROPATH).
			IF FILE-INFO:FILE-TYPE = ? OR NOT FILE-INFO:FILE-TYPE BEGINS "D" THEN 
				NEXT.
			ELSE
				ASSIGN c_caminho_propath = FILE-INFO:FILE-NAME + p_final_adicional.
		END.
	END.	
	
	RETURN c_caminho_propath.
    
END FUNCTION.


