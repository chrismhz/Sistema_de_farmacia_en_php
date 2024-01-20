<?php

$menuUsuario = UsuarioControlador::ctrObtenerMenuUsuario($_SESSION["usuario"]->id_usuario);

//var_dump($menuUsuario);

?>

<!-- Main Sidebar Container -->
<aside class="main-sidebar sidebar-dark-light elevation-4" style="background-color: #8b0000;">
  <!-- Brand Logo -->
  <a href="index.php" class="brand-link">
    <img src="vistas/assets/imagenes/fda.png" alt="AdminLTE Logo" class="brand-image img-circle elevation-3" style="opacity: .8">
    <span class="brand-text font-weight-light">MENU</span>
  </a>

  <div class="user-panel mt-3 pb-3 mb-3 d-flex">
    <div class="image">
      <img src="vistas/assets/imagenes/Medico.png" class="img-circle elevation-2" alt="User Image">
    </div>
    <div class="info">
      <h6 class="text-warning"><?php echo $_SESSION["usuario"]->nombre_usuario . ' ' . $_SESSION["usuario"]->apellido_usuario ?></h6>
    </div>
  </div>

  <!-- Sidebar Menu -->
  <nav class="mt-2">

    <ul class="nav nav-pills nav-sidebar flex-column nav-child-indent" data-widget="treeview" role="menu" data-accordion="false">

      <?php foreach ($menuUsuario as $menu) : ?>
        <li class="nav-item">

          <a style="cursor: pointer;" class="nav-link <?php if ($menu->vista_inicio == 1) : ?>
                                                        <?php echo 'active'; ?>
                                                      <?php endif; ?>" <?php if (!empty($menu->vista)) : ?> onclick="CargarContenido('vistas/<?php echo $menu->vista; ?>','content-wrapper')" <?php endif; ?>>
            <i class="nav-icon <?php echo $menu->icon_menu; ?>"></i>
            <p>
              <?php echo $menu->modulo ?>
              <?php if (empty($menu->vista)) : ?>
                <i class="right fas fa-angle-left"></i>
              <?php endif; ?>
            </p>
          </a>

          <?php if (empty($menu->vista)) : ?>

            <?php
            $subMenuUsuario = UsuarioControlador::ctrObtenerSubMenuUsuario($menu->id, $_SESSION["usuario"]->id_usuario);
            ?>

            <ul class="nav nav-treeview">

              <?php foreach ($subMenuUsuario as $subMenu) : ?>

                <li class="nav-item">
                  <a style="cursor: pointer;" class="nav-link" onclick="CargarContenido('vistas/<?php echo $subMenu->vista ?>','content-wrapper')">
                    <i class="<?php echo $subMenu->icon_menu; ?> nav-icon"></i>
                    <p><?php echo $subMenu->modulo; ?></p>
                  </a>
                </li>

              <?php endforeach; ?>

            </ul>

          <?php endif; ?>

        </li>
      <?php endforeach; ?>

      

      <!--
        <li class="nav-item">
            <a style="cursor: pointer;" href="#" class="nav-link active" onclick="CargarContenido('vistas/dashboard.php','content-wrapper')">
              <i class="nav-icon fas fa-th"></i>
              <p>
                TABLERO PRINCIPAL
              </p>
            </a>
          </li>

          <li class="nav-item">
            <a href="#" class="nav-link">
              <i class="nav-icon fas fa-tachometer-alt"></i>
              <p>
                PRODUCTOS
                <i class="right fas fa-angle-left"></i>
              </p>
            </a>
            <ul class="nav nav-treeview">
              <li class="nav-item">
              <a style="cursor: pointer;" href="#" class="nav-link" onclick="CargarContenido('vistas/productos.php','content-wrapper')">
                  <i class="far fa-circle nav-icon"></i>
                  <p>INVENTARIO</p>
                </a>
              </li>
              <li class="nav-item d-none d-sm-inline-block">
              <a style="cursor: pointer;" class="nav-link" onclick="CargarContenido('vistas/carga_masiva_productos.php','content-wrapper')">
                  <i class="far fa-circle nav-icon"></i>
                  <p>CARGA MASIVA</p>
              </a>
              </li>
              <li class="nav-item">
              <a style="cursor: pointer;" href="#" class="nav-link" onclick="CargarContenido('vistas/categorias.php','content-wrapper')">
                  <i class="far fa-circle nav-icon"></i>
                  <p>CATEGORIAS</p>
                </a>
              </li>

            </ul>
          </li>

          <li class="nav-item">
              <a href="#" class="nav-link">
                  <i class="nav-icon fas fa-store-alt"></i>
                  <p>Ventas<i class="right fas fa-angle-left"></i></p>
                </a>
                <ul class="nav nav-treeview">
                    <li class="nav-item">
                        <a href="#" class="nav-link" style="cursor:pointer;" onclick="CargarContenido('vistas/ventas.php','content-wrapper')">
                            <i class="far fa-circle nav-icon"></i>
                            <p>Punto de Venta</p>
                        </a>
                    </li>
                    <li class="nav-item">
                        <a href="#" class="nav-link" style="cursor:pointer;" onclick="CargarContenido('vistas/administrar_ventas.php','content-wrapper')">
                            <i class="far fa-circle nav-icon"></i>
                            <p>Administrar ventas</p>
                        </a>
                  </li>
              </ul>
            </li>

          <li class="nav-item">
          <a style="cursor: pointer;" href="#" class="nav-link" onclick="CargarContenido('vistas/reportes.php','content-wrapper')">
              <i class="nav-icon fas fa-chart-line text-ligth"></i>
              <p>
                REPORTES
              </p>
            </a>
          </li>

          <li class="nav-item">
          <a style="cursor: pointer;" href="#" class="nav-link" onclick="CargarContenido('vistas/compras.php','content-wrapper')">
              <i class="nav-icon fas fa-dolly text-ligth"></i>
              <p>
                COMPRAS
              </p>
            </a>
          </li>

          <li class="nav-item">
          <a style="cursor: pointer;" href="#" class="nav-link" onclick="CargarContenido('vistas/configuracion.php','content-wrapper')">
              <i class="nav-icon fas fa-cogs text-ligth"></i>
              <p>
                CONFIGURACION
              </p>
            </a>
          </li>-->

    <!-- Cerrar Sesión al final de la barra lateral -->
    <div class="sidebar-bottom">
      <ul class="nav nav-pills nav-sidebar flex-column">
        <li class="nav-item">
            <a style="cursor: pointer;" class="nav-link" href="http://localhost/puntoventa?cerrar_sesion=1">
                <i class="nav-icon fas fa-sign-out-alt"></i>
                <p>Salir</p>
            </a>
          </li>
        </ul>
      </div>
      
    </nav>
  <!-- /.sidebar-menu -->
</aside>



<script>
  $(".nav-link").on('click', function() {
    $(".nav-link").removeClass('active');
    $(this).addClass('active');
  })
</script>