{src/web2/wrap-cgi.i}

procedure output-header:
    output-http-header ("Access-Control-Allow-Origin":U, "*":U).
    output-http-header ("Access-Control-Allow-Methods":U, "*":U).

    output-content-type("{1}").
    /*output-content-type("text/text"). */
end.

//output-content-type("{1}").
