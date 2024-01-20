<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Farmacias del Ahorro | Login</title>

    <!-- Google Font: Source Sans Pro -->
    <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Source+Sans+Pro:300,400,400i,700&display=fallback">
    <!-- Font Awesome -->
    <link rel="stylesheet" href="vistas/assets/plugins/fontawesome-free/css/all.min.css">
    <!-- icheck bootstrap -->
    <link rel="stylesheet" href="vistas/assets/plugins/icheck-bootstrap/icheck-bootstrap.min.css">
    <!-- Theme style -->
    <link rel="stylesheet" href="vistas/assets/dist/css/adminlte.min.css">
</head>

 <!-- Estilo para el fondo de la página -->
 <style>
        body {
            background-image: url('https://i.pinimg.com/originals/83/54/cf/8354cf84ef66cf723189485abefa894f.jpg'); /* Reemplaza 'URL_DE_LA_IMAGEN' con la URL de la imagen de Google */
            background-size: cover;
            background-position: center;
            background-repeat: no-repeat;
        }

        .h1 {
            color: blue; /* Cambia 'blue' al color que desees */
        }

        .login-box .input-group-append .input-group-text {
            border-left: 0; /* Elimina el borde izquierdo */
            border-right: 1px solid #ccc; /* Añade un borde derecho */
        }
    </style>

<body class="hold-transition login-page" >

    <div class="login-box">

        <div class="card card-outline card-primary">

            <div class="card-header text-center">

                <!-- <h1 class="h1"><b>Farmacias del Ahorro</b></h1> -->
                <!-- Reemplazar el título con la imagen de Google -->
                <img class="logo-img" src="https://vozdelasempresas.org/wp-content/uploads/2020/11/FDahorro2Vozz.png" alt="Farmacias del Ahorro Logo">

                <style>
                    .logo-img {
                        max-width: 200px; /* Ajusta el ancho máximo de la imagen según tus necesidades */
                        height: auto;
                        display: block;
                        margin: 0 auto;
                    }
                </style>

            </div><!-- /.card-header -->

            <div class="card-body">

                <form method="post" class="needs-validation-login" novalidate>

                    <!-- USUARIO DEL SISTEMA -->
                    <div class="input-group mb-3">
                        <!-- Elimina esta parte si quieres quitar el icono -->
                        <!-- <div class="input-group-prepend">
                            <div class="input-group-text">
                                <span class="fas fa-user"></span>
                            </div>
                        </div> -->
                        <input type="text" class="form-control" placeholder="Ingrese usuario" name="loginUsuario" required>
                        <div class="invalid-feedback">Debe ingresar su usuario!</div>
                    </div><!-- /.input-group USUARIO -->

                    <!-- PASSWORD DEL USUARIO DEL SISTEMA -->
                    <div class="input-group mb-3">
                        <!-- Elimina esta parte si quieres quitar el icono -->
                        <!-- <div class="input-group-prepend">
                            <div class="input-group-text">
                                <span class="fas fa-lock"></span>
                            </div>
                        </div> -->
                        <input type="password" class="form-control" placeholder="Ingrese contraseña" name="loginPassword" required>
                        <div class="invalid-feedback">Debe ingresar su contraseña!</div>
                    </div><!-- /.input-group PASSWORD -->


                    <div class="row">

                        <?php

                            $login = new UsuarioControlador();
                            $login->login();

                        ?>

                        <div class="col-md-12 text-center">

                            <button type="submit" class="btn btn-danger" style="margin-top: 15px;">Ingresar</button>

                        </div>

                    </div>

                </form>

            </div><!-- /.card-body -->

        </div>

    </div>
    <!-- /.login-box -->

    <!-- jQuery -->
    <script src="vistas/assets/plugins/jquery/jquery.min.js"></script>
    <!-- Bootstrap 4 -->
    <script src="vistas/assets/plugins/bootstrap/js/bootstrap.bundle.min.js"></script>
    <!-- AdminLTE App -->
    <script src="vistas/assets/dist/js/adminlte.min.js"></script>
</body>

</html>