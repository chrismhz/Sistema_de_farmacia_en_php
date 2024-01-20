<?php

    class UsuarioControlador{

        /********************************
        LOGIN DE USUARIO
        ********************************/
        public function login(){

            if(isset($_POST["loginUsuario"])){
    
                $usuario = $_POST["loginUsuario"];
                $password = $_POST["loginPassword"];
    
                $respuesta = UsuarioModelo::mdlIniciarSesion($usuario, $password);
    
                if(count($respuesta) > 0){
    
                    $_SESSION["usuario"] = $respuesta[0];
    
                    echo '
                        <script>
                            window.location = "http://localhost/puntoventa";
                        </script>
                    
                    ';
                }else{
    
                    echo '
                        <script>
                            fncSweetAlert("error","Usuario y/o password inválido","http://localhost/puntoventa");
                        </script>
                    
                    ';
                }
    
            }
        }

        static public function ctrObtenerMenuUsuario($id_usuario){
            $menuUsuario = UsuarioModelo::mdlObtenerMenuUsuario($id_usuario);
            return $menuUsuario;
        }

        static public function ctrObtenerSubMenuUsuario($idMenu){
            $subMenuUsuario = UsuarioModelo::mdlObtenerSubMenuUsuario($idMenu);
            return $subMenuUsuario;
        }

    }

?>