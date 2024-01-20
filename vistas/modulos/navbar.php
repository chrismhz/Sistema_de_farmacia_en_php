<!-- Navbar -->
<nav class="main-header navbar navbar-expand navbar-white navbar-light"  style="background-color: #ffcccc;">
    
    <!-- Left navbar links -->
    <ul class="navbar-nav">
        <li class="nav-item">
            <a class="nav-link" data-widget="pushmenu" href="#" role="button"><i class="fas fa-bars"></i></a>
        </li>
    </ul>

    <!-- Right-aligned navbar links -->
    <div class="navbar-nav ml-auto">
        <ul class="navbar-nav">
            <li class="nav-item d-none d-sm-inline-block">
                <a style="cursor: pointer;" class="nav-link text-danger" onclick="CargarContenido('vistas/dashboard.php','content-wrapper')">
                        Inicio
                </a>
            </li>
            <li class="nav-item d-none d-sm-inline-block">
                <a style="cursor: pointer;" class="nav-link text-danger" onclick="CargarContenido('vistas/productos.php','content-wrapper')">
                        Inventario / Productos
                </a>
            </li>
            <li class="nav-item d-none d-sm-inline-block">
                <a style="cursor: pointer;" class="nav-link text-danger" onclick="CargarContenido('vistas/carga_masiva_productos.php','content-wrapper')">
                        Cargar Productos
                </a>
            </li>
            <li class="nav-item d-none d-sm-inline-block">
                <a style="cursor: pointer;" class="nav-link text-danger" onclick="CargarContenido('vistas/categorias.php','content-wrapper')">
                        Categorías
                </a>
            </li>
            <li class="nav-item d-none d-sm-inline-block">
                <a style="cursor: pointer;" class="nav-link text-danger" onclick="CargarContenido('vistas/ventas.php','content-wrapper')">
                    Ventas
                </a>
            </li>
        </ul>
    </div>
</nav>
<!-- /.navbar -->

<style>
    .custom-tab {
        color: #ffcccc; /* Reemplaza 'your-desired-color' con el color deseado */
    }
</style>