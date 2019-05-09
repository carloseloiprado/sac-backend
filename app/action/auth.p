&ANALYZE-SUSPEND _VERSION-NUMBER AB_v9r12
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Procedure
/*------------------------------------------------------------------------

  File:

  Description:

  Input Parameters:
      <none>

  Output Parameters:
      <none>

  Author:

  Created:

------------------------------------------------------------------------*/
/*           This .W file was created with the Progress AppBuilder.     */
/*----------------------------------------------------------------------*/

/* Create an unnamed pool to store all the widgets created
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
def var c-senha as character no-undo.
define temp-table tt-erros2 no-undo
    field cod-erro  as integer
    field desc-erro as character format "x(256)"
    field desc-arq  as character.
	/*
define temp-table tt-erros
    field cod-erro  as integer
    field desc-erro as character format "x(256)"
    field desc-arq  as character.
	*/

DEFINE VARIABLE c-msg-error AS CHARACTER  NO-UNDO.

DEFINE VARIABLE v_cod_usuario               AS CHARACTER  NO-UNDO.
DEFINE VARIABLE v_lnk_new_manifestacao  AS CHARACTER  NO-UNDO.
DEFINE VARIABLE v_cod_senha                 AS CHARACTER  NO-UNDO.
DEFINE VARIABLE l-login             AS LOGICAL    NO-UNDO.
DEFINE VARIABLE l-usuar-univ        AS LOGICAL    NO-UNDO.
DEFINE VARIABLE c_token_senha_expirada AS CHARACTER  NO-UNDO.


/* DEFINE VARIABLE v_cod_grp_usuar_lst AS CHARACTER  NO-UNDO. */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Procedure
&Scoped-define DB-AWARE no



/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Procedure
   Allow:
   Frames: 0
   Add Fields to: Neither
   Other Settings: CODE-ONLY
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB)
  CREATE WINDOW Procedure ASSIGN
         HEIGHT             = 14.13
         WIDTH              = 60.57.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB Procedure
/* ************************* Included-Libraries *********************** */

{src/web2/wrap-cgi.i}

/** Includes Especifica */
{include/config.i}
{include/app.i}



/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME





&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Procedure


/* ************************  Main Code Block  *********************** */

/* Process the latest Web event. */
RUN process-web-request.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&IF DEFINED(EXCLUDE-outputHeader) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE outputHeader Procedure
PROCEDURE outputHeader :
/*------------------------------------------------------------------------------
  Purpose:     Output the MIME header, and any "cookie" information needed
               by this procedure.
  Parameters:  <none>
  Notes:       In the event that this Web object is state-aware, this is
               a good place to set the webState and webTimeout attributes.
------------------------------------------------------------------------------*/

  /* To make this a state-aware Web object, pass in the timeout period
   * (in minutes) before running outputContentType.  If you supply a timeout
   * period greater than 0, the Web object becomes state-aware and the
   * following happens:
   *
   *   - 4GL variables webState and webTimeout are set
   *   - a cookie is created for the broker to id the client on the return trip
   *   - a cookie is created to id the correct procedure on the return trip
   *
   * If you supply a timeout period less than 1, the following happens:
   *
   *   - 4GL variables webState and webTimeout are set to an empty string
   *   - a cookie is killed for the broker to id the client on the return trip
   *   - a cookie is killed to id the correct procedure on the return trip
   *
   * Example: Timeout period of 5 minutes for this Web object.
   */
      /*setWebState (5.0).*/


  /*
   * Output additional cookie information here before running outputContentType.
   *      For more information about the Netscape Cookie Specification, see
   *      http://home.netscape.com/newsref/std/cookie_spec.html
   *
   *      Name         - name of the cookie
   *      Value        - value of the cookie
   *      Expires date - Date to expire (optional). See TODAY function.
   *      Expires time - Time to expire (optional). See TIME function.
   *      Path         - Override default URL path (optional)
   *      Domain       - Override default domain (optional)
   *      Secure       - "secure" or unknown (optional)
   *
   *      The following example sets cust-num=23 and expires tomorrow at (about) the
   *      same time but only for secure (https) connections.
   *
   *      RUN SetCookie IN web-utilities-hdl
   *        ("custNum":U, "23":U, TODAY + 1, TIME, ?, ?, "secure":U).
   */
/*
  run pi-view-trends.
  */
  /*
  run btb/btb910za.p (input codepage-convert(get-value("cod_usuario"),"ibm850","iso8859-1"), input codepage-convert(get-value("senha"),"ibm850","iso8859-1"), output table tt-erros).

  find tt-erros no-lock no-error.
  */
  /*message "avail tt-erros " avail tt-erros.*/

/************ AUTENTICACAO NO LICENSE SERVER **********************/
/** TOTVS!! */
/*
RUN btb/btapi910za.p (input get-value("cod_usuario"), INPUT get-value("senha"), output table tt-erros) NO-ERROR.
*/
  IF CAN-FIND(FIRST tt-erros) THEN DO:
   FOR EACH tt-erros:
       MESSAGE " ERROS: " + tt-erros.desc-erro.
   END.

  end.

  message "antes tt-erros".

  if not CAN-FIND(FIRST tt-erros) then do:
    
    message "not not not avail tt-erros".
    message lc(get-value("cod-usuario")).
    
	/*assign c-senha = BASE64-ENCODE(sha1-digest(get-value("senha"))).*/
    assign c-senha = BASE64-ENCODE(SHA1-DIGEST(lc(cpc-in(get-value("senha"))))).
    

    find first usuar_mestre
	     where usuar_mestre.cod_usuario = lc(get-value("cod-usuario"))
			   and usuar_mestre.cod_senha   = c-senha no-lock no-error.

    FIND FIRST usuar_grp_usuar  NO-LOCK WHERE usuar_grp_usuar.cod_usuar = lc(get-value("cod-usuario")) 
                                         AND (    usuar_grp_usuar.cod_grp_usuar = 'SAI' OR usuar_grp_usuar.cod_grp_usuar = 'SAE' 
                                               OR usuar_grp_usuar.cod_grp_usuar = 'SAL' OR usuar_grp_usuar.cod_grp_usuar = 'SAP' 
                                               OR usuar_grp_usuar.cod_grp_usuar = 'SAC' OR usuar_grp_usuar.cod_grp_usuar = 'OUT' )  NO-ERROR.
                                               
    
	if avail usuar_mestre AND AVAIL(usuar_grp_usuar) then do:
      message "avail usuar_mestre".
      message "logou!!!!!".

      FIND FIRST usuar_grp_usuar  NO-LOCK WHERE usuar_grp_usuar.cod_usuar = lc(get-value("cod-usuario")) 
                                              AND usuar_grp_usuar.cod_grp_usuar = 'SAC'  NO-ERROR.
      
      run pi-registra-entrada.
      ASSIGN v_cod_usuario     = lc(get-value("cod-usuario"))
             v_cod_senha       = get-value("senha")             
             .
      IF AVAIL(usuar_grp_usuar) THEN 
        ASSIGN v_lnk_new_manifestacao = "new-manifestacao".
      ELSE 
        ASSIGN v_lnk_new_manifestacao = "#".

      /*l-login
      v_cod_grp_usuar_lst*/

      RUN processa-login.
      /* RUN pi-limpa-contexto. */
      /* message "limpa contexto auth.p". */
		  /*run wpv001.r.*/
      RUN pi-redireciona(INPUT "../home", 0).
      stop.
      
    end.
    else do:
			message "login1".
			RUN pi-redireciona(INPUT "../login", 1 /* usuario ou senha incorreto */ ).
		  STOP.
      
    end.
  end.
  else do:
		message "login2".
  	RUN pi-redireciona(INPUT "../login", 1 /* usuario ou senha incorreto */ ).
		STOP.
    
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-pi-registra-entrada) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-registra-entrada Procedure
PROCEDURE pi-registra-entrada :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
/*
  create websession.
  assign websession.cod-usuario     = get-value("cod_usuario").
  assign websession.data            = today.
  assign websession.hora            = string(time, "HH:MM:SS").
  assign websession.remote-ip       = REMOTE_ADDR.
  assign websession.HTTP_USER_AGENT = HTTP_USER_AGENT.
  assign websession.function        = "Ainitial".
*/
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-process-web-request) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE process-web-request Procedure
PROCEDURE process-web-request :
/*------------------------------------------------------------------------------
  Purpose:     Process the web request.
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

  /*
   * Output the MIME header and set up the object as state-less or state-aware.
   * This is required if any HTML is to be returned to the browser.
   */
  RUN outputHeader.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-processa-login) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE processa-login Procedure
PROCEDURE processa-login :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

	/** Seguranca Ing */
	define variable h-prog          as handle    no-undo.
	define variable c-token         as character no-undo.

	define variable validadeSessao	as datetime no-undo.

	assign validadeSessao = now.
	assign validadeSessao = add-interval(validadeSessao, INT(app_config.timeout_sessao), "hours").

	run web/wutp/wu-sessao.p persistent set h-prog.
	run getToken in h-prog ( output c-token ).

	set-cookie('SessionContextToken', c-token, ?, ?, ?, ?, ?).

  MESSAGE 'SessionContextToken.: ' c-token.

	/** Totvs11 */
  FIND FIRST usuar_mestre WHERE usuar_mestre.cod_usuario = v_cod_usuario NO-LOCK NO-ERROR.
	
	/** EMS2 */
	/*
	FIND FIRST usuar_mestre WHERE usuar_mestre.cod_usuario = v_cod_usuario NO-LOCK NO-ERROR.
	RUN setContext IN h-prog ( INPUT "representanteCorrente", INPUT usuar_mestre.char-1 ).
	*/

	run setContext in h-prog ( input "sessionTimeout", input STRING(validadeSessao) ).
	run setContext in h-prog ( input "usuarioCorrente", input v_cod_usuario ).
    run setContext in h-prog ( input "lnkNewManifestacao", input v_lnk_new_manifestacao ).
     

	/** Ems2 */
	/*
	run setContext in h-prog ( input "credenciaisCorrentes", input STRING(ENCODE(v_cod_usuario + "|" + ENCODE(v_cod_senha))) ).
	*/

	/** Totvs11 */
	run setContext in h-prog ( input "credenciaisCorrentes", input STRING(ENCODE(v_cod_usuario + "|" + STRING(BASE64-ENCODE(SHA1-DIGEST(lc(cpc-in(get-value("senha")))))) )) ).

	/** Seguranca Ing */
  message "1processa-login".

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF
