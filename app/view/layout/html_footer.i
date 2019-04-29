{&out} '  <!-- Bootstrap core JavaScript-->
' SKIP '    <script src="' app_config.caminho_assets '/vendor/jquery/jquery.min.js"></script>
' SKIP '    <script src="' app_config.caminho_assets '/vendor/bootstrap/js/bootstrap.bundle.min.js"></script>
  
' SKIP '    <!-- Core plugin JavaScript-->
' SKIP '    <script src="' app_config.caminho_assets '/vendor/jquery-easing/jquery.easing.min.js"></script>
  
' SKIP '    <!-- Custom scripts for all pages-->
' SKIP '    <script src="' app_config.caminho_assets '/js/sb-admin-2.min.js"></script>'.

IF APPPROGRAM MATCHES "*dashboard*" OR APPPROGRAM MATCHES "*home*" THEN DO:
    {&OUT} '    <!-- Page level plugins -->
    ' SKIP '    <script src="' app_config.caminho_assets '/vendor/chart.js/Chart.min.js"></script>
    
    ' SKIP '<!-- Page level custom scripts -->
    ' SKIP '    <!--script src="' app_config.caminho_assets '/js/demo/chart-area-demo.js"></script-->
    ' SKIP '    <script src="' app_config.caminho_assets '/js/demo/chart-pie-demo.js"></script>
    ' SKIP.

END.

{&OUT} '     <!-- Latest compiled and minified JavaScript -->
' SKIP '    <script src="' app_config.caminho_assets '/vendor/bootstrap-select/1.13.2/js/bootstrap-select.min.js"></script>
' SKIP '    <script src="' app_config.caminho_assets '/js/file-upload.js"></script>
' SKIP .

