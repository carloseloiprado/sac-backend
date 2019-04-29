{&out} '  <!-- Topbar -->
' SKIP '          <nav class="navbar navbar-expand navbar-light bg-white topbar mb-4 static-top shadow">

' SKIP '            <!-- Sidebar Toggle (Topbar) -->
' SKIP '            <button id="sidebarToggleTop" class="btn btn-link d-md-none rounded-circle mr-3">
' SKIP '              <i class="fa fa-bars"></i>
' SKIP '            </button>

' SKIP '            <!-- Topbar Search -->
' SKIP '            <form class="d-none d-sm-inline-block form-inline mr-auto ml-md-3 my-2 my-md-0 mw-100 navbar-search">
' SKIP '              <div class="input-group">
' SKIP '                <input type="text" class="form-control" ng-enter="abreLink();" id="nrprotocolo" name="nrprotocolo" bg-light border-0 small border-left-primary" placeholder="Buscar um protocolo..." aria-label="Search" aria-describedby="basic-addon2">
' SKIP '                <div class="input-group-append">
' SKIP '                  <button class="btn btn-primary" type="button">
' SKIP '                    <a href="#" onclick="abreLink();" style="color: #FFFFFF"><i class="fas fa-search fa-sm"></i></a>
' SKIP '                  </button>                  
' SKIP '                </div>
' SKIP '              </div>
' SKIP '            </form>

' SKIP '            <!-- Topbar Navbar -->
' SKIP '            <ul class="navbar-nav ml-auto">

' SKIP '              <!-- Nav Item - Search Dropdown (Visible Only XS) -->
' SKIP '              <li class="nav-item dropdown no-arrow d-sm-none">
' SKIP '                <a class="nav-link dropdown-toggle" href="#" id="searchDropdown" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
' SKIP '                  <i class="fas fa-search fa-fw"></i>
' SKIP '                </a>
' SKIP '                <!-- Dropdown - Messages -->
' SKIP '               <div class="dropdown-menu dropdown-menu-right p-3 shadow animated--grow-in" aria-labelledby="searchDropdown">
' SKIP '                  <form class="form-inline mr-auto w-100 navbar-search">
' SKIP '                    <div class="input-group">
' SKIP '                      <input type="text" class="form-control bg-light border-0 small" placeholder="Search for..." aria-label="Search" aria-describedby="basic-addon2">
' SKIP '                      <div class="input-group-append">
' SKIP '                        <button class="btn btn-primary" type="button">
' SKIP '                          <i class="fas fa-search fa-sm"></i>
' SKIP '                        </button>
' SKIP '                      </div>
' SKIP '                    </div>
' SKIP '                  </form>
' SKIP '                </div>
' SKIP '              </li>

' SKIP '              <!-- Nav Item - Alerts -->
' SKIP '              <!--li class="nav-item dropdown no-arrow mx-1">
' SKIP '                <a class="nav-link dropdown-toggle" href="#" id="alertsDropdown" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
' SKIP '                  <i class="fas fa-bell fa-fw"></i-->
' SKIP '                  <!-- Counter - Alerts -->
' SKIP '                  <!--span class="badge badge-danger badge-counter">1+</span-->
' SKIP '                <!--/a-->
' SKIP '                <!-- Dropdown - Alerts -->
' SKIP '                <!--div class="dropdown-list dropdown-menu dropdown-menu-right shadow animated--grow-in" aria-labelledby="alertsDropdown">
' SKIP '                  <h6 class="dropdown-header">
' SKIP '                    Central de Alertas
' SKIP '                 </h6>
' SKIP '                  <a class="dropdown-item d-flex align-items-center" href="#">
' SKIP '                    <div class="mr-3">
' SKIP '                      <div class="icon-circle bg-primary">
' SKIP '                        <i class="fas fa-file-alt text-white"></i>
' SKIP '                      </div>
' SKIP '                    </div>
' SKIP '                    <div>
' SKIP '                      <div class="small text-gray-500">01/03/2019 12:43:45</div>
' SKIP '                      <span class="font-weight-bold">Manifesta&ccedil;&atilde;o 1234567890 inserida no sistema...</span>
' SKIP '                    </div>
' SKIP '                  </a>
' SKIP '                  
' SKIP '                  <a class="dropdown-item text-center small text-gray-500" href="open-manifestacao">Mostar Todas Abertas</a>
' SKIP '                </div>
' SKIP '              </li-->

' SKIP '              <div class="topbar-divider d-none d-sm-block"></div>

' SKIP '              <!-- Nav Item - User Information -->
' SKIP '              <li class="nav-item dropdown no-arrow">
' SKIP '                <a class="nav-link dropdown-toggle" href="#" id="userDropdown" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
' SKIP '                  <span class="mr-2 d-none d-lg-inline text-gray-600 small">' usuarioCorrente '</span>
' SKIP '                  <img class="img-profile rounded-circle" src="' app_config.caminho_assets '/img/icon-usu.jpg">
' SKIP '                </a>
' SKIP '                <!-- Dropdown - User Information -->
' SKIP '                <div class="dropdown-menu dropdown-menu-right shadow animated--grow-in" aria-labelledby="userDropdown">
' SKIP '                  <a class="dropdown-item" href="perfil">
' SKIP '                    <i class="fas fa-user fa-sm fa-fw mr-2 text-gray-400"></i>
' SKIP '                    Profile
' SKIP '                  </a>
' SKIP '                  <div class="dropdown-divider"></div>
' SKIP '                  <a class="dropdown-item" href="#" data-toggle="modal" data-target="#logoutModal">
' SKIP '                    <i class="fas fa-sign-out-alt fa-sm fa-fw mr-2 text-gray-400"></i>
' SKIP '                    Logout
' SKIP '                  </a>
' SKIP '                </div>
' SKIP '              </li>

' SKIP '            </ul>

' SKIP '          </nav>
' SKIP '          <!-- End of Topbar -->

' SKIP '          <script>
' SKIP '                
' SKIP '                function abreLink()' CHR(123) '
' SKIP '                    var str = document.getElementsByName("nrprotocolo")[0].value.split(" ").join("")
' SKIP '                    window.location.href = "home-protoc?"+str;
' SKIP '                ' CHR(125) '
' SKIP '          </script>'  SKIP.
