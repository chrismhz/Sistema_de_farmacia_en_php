-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 12-07-2023 a las 20:08:09
-- Versión del servidor: 10.4.28-MariaDB
-- Versión de PHP: 8.0.28

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `puntoventa`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `prc_ListarProductos` ()  NO SQL BEGIN

SELECT '' AS detalles,
          p.id,
          p.codigo_producto,
          c.id_categoria,
          c.nombre_categoria,
          p.descripcion_producto,
          
          ROUND(p.precio_compra_producto,2) AS precio_compra,
          ROUND(p.precio_venta_producto,2) AS precio_venta,
          ROUND(p.utilidad,2) AS utilidad,

 CASE WHEN c.aplica_peso = 1 THEN concat(p.stock_producto, 'Kg(s)') ELSE concat(p.stock_producto, 'Und(s)') END AS stok,
 
 CASE WHEN c.aplica_peso = 1 THEN concat(p.minimo_stock_producto, 'Kg(s)') ELSE concat(p.minimo_stock_producto, 'Und(s)') END AS minimo_stock,
                                       
 CASE WHEN c.aplica_peso = 1 THEN concat(p.ventas_producto, 'Kg(s)') ELSE concat(p.ventas_producto, 'Und(s)') END AS ventas,

p.fecha_creacion_producto,
p.fecha_actualizacion_producto,
'' AS opciones
                                       
            
FROM productos p INNER JOIN categorias c ON p.id_categoria_producto = c.id_categoria ORDER BY p.id DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `prc_ListarProductosMasVendidos` ()   BEGIN

SELECT p.codigo_producto, p.descripcion_producto, sum(vd.cantidad) as cantidad, sum(ROUND(vd.total_venta,2)) as total_venta FROM venta_detalle vd INNER JOIN productos p on vd.codigo_producto = p.codigo_producto GROUP BY p.codigo_producto, p.descripcion_producto ORDER BY sum(ROUND(vd.total_venta,2)) DESC LIMIT 10;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `prc_ListarProductosPocoStock` ()   BEGIN

SELECT p.codigo_producto,
	   p.descripcion_producto,
       p.stock_producto,
       p.minimo_stock_producto
       FROM productos p WHERE p.stock_producto <= p.minimo_stock_producto
       ORDER BY p.stock_producto ASC;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `prc_ObtenerDatosDashboard` ()  NO SQL BEGIN
declare totalProductos int;
declare totalCompras float;
declare totalVentas float;
declare ganancias float;
declare productosPocoStock int;
declare ventasHoy float;

SET totalProductos = (SELECT count(*) FROM productos p);
SET totalCompras = (select sum(p.precio_compra_producto*p.stock_producto) from productos p);
set totalVentas = (select sum(vc.total_venta) from venta_cabecera vc where EXTRACT(MONTH FROM vc.fecha_venta) = EXTRACT(MONTH FROM curdate()) and EXTRACT(YEAR FROM vc.fecha_venta) = EXTRACT(YEAR FROM curdate()));
set ganancias = (select sum(vd.total_venta - (p.precio_compra_producto * vd.cantidad)) from venta_detalle vd inner join productos p on vd.codigo_producto = p.codigo_producto
                 where EXTRACT(MONTH FROM vd.fecha_venta) = EXTRACT(MONTH FROM curdate()) and EXTRACT(YEAR FROM vd.fecha_venta) = EXTRACT(YEAR FROM curdate()));
set productosPocoStock = (select count(1) from productos p where p.stock_producto <= p.minimo_stock_producto);
set ventasHoy = (select sum(vc.total_venta) from venta_cabecera vc where vc.fecha_venta = curdate());

SELECT IFNULL(totalProductos,0) AS totalProductos,
	   IFNULL(ROUND(totalCompras,2),0) AS totalCompras,
       IFNULL(ROUND(totalVentas,2),0) AS totalVentas,
       IFNULL(ROUND(ganancias,2),0) AS ganancias,
       IFNULL(productosPocoStock,0) AS productosPocoStock,
       IFNULL(ROUND(ventasHoy,2),0) AS ventasHoy;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `prc_obtenerNroBoleta` ()  NO SQL BEGIN

SELECT serie_boleta,
		IFNULL(LPAD(max(c.nro_correlativo_venta)+1,8,'0'),'00000001') nro_venta
        FROM empresa c;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `prc_ObtenerVentasMesActual` ()  NO SQL BEGIN

SELECT date(vc.fecha_venta) as fecha_venta, sum(round(vc.total_venta,2)) as total_venta FROM venta_cabecera vc WHERE date(vc.fecha_venta) >= date(last_day(now() - INTERVAL 1 month) + INTERVAL 1 day) and date(vc.fecha_venta) <= last_day(date(CURRENT_DATE)) GROUP BY date(vc.fecha_venta);

END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `categorias`
--

CREATE TABLE `categorias` (
  `id_categoria` int(11) NOT NULL,
  `nombre_categoria` text CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL,
  `aplica_peso` int(11) NOT NULL,
  `fecha_creacion_categoria` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `fecha_actualizacion_categoria` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `categorias`
--

INSERT INTO `categorias` (`id_categoria`, `nombre_categoria`, `aplica_peso`, `fecha_creacion_categoria`, `fecha_actualizacion_categoria`) VALUES
(691, 'Frutas', 1, '2023-06-16 15:49:31', '2023-06-16'),
(692, 'Verduras', 1, '2023-06-16 15:49:31', '2023-06-16'),
(693, 'Snack', 0, '2023-06-16 15:49:31', '2023-06-16'),
(694, 'Avena', 0, '2023-06-16 15:49:31', '2023-06-16'),
(695, 'Energizante', 0, '2023-06-16 15:49:31', '2023-06-16'),
(696, 'Jugo', 0, '2023-06-16 15:49:31', '2023-06-16'),
(697, 'Refresco', 0, '2023-06-16 15:49:31', '2023-06-16'),
(698, 'Mantequilla', 0, '2023-06-16 15:49:31', '2023-06-16'),
(699, 'Gaseosa', 0, '2023-06-16 15:49:31', '2023-06-16'),
(700, 'Aceite', 0, '2023-06-16 15:49:31', '2023-06-16'),
(701, 'Yogurt', 0, '2023-06-16 15:49:31', '2023-06-16'),
(702, 'Arroz', 0, '2023-06-16 15:49:31', '2023-06-16'),
(703, 'Leche', 0, '2023-06-16 15:49:31', '2023-06-16'),
(704, 'Papel Higiénico', 0, '2023-06-16 15:49:31', '2023-06-16'),
(705, 'Atún', 0, '2023-06-16 15:49:31', '2023-06-16'),
(706, 'Chocolate', 0, '2023-06-16 15:49:32', '2023-06-16'),
(707, 'Wafer', 0, '2023-06-16 15:49:32', '2023-06-16'),
(708, 'Golosina', 0, '2023-06-16 15:49:32', '2023-06-16'),
(709, 'Galletas', 0, '2023-06-16 15:49:32', '2023-06-16');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `empresa`
--

CREATE TABLE `empresa` (
  `id_empresa` int(11) NOT NULL,
  `razon_social` text NOT NULL,
  `ruc` bigint(20) NOT NULL,
  `direccion` text NOT NULL,
  `marca` text NOT NULL,
  `serie_boleta` varchar(4) NOT NULL,
  `nro_correlativo_venta` varchar(8) NOT NULL,
  `email` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `empresa`
--

INSERT INTO `empresa` (`id_empresa`, `razon_social`, `ruc`, `direccion`, `marca`, `serie_boleta`, `nro_correlativo_venta`, `email`) VALUES
(1, 'Glob-Arte', 17283945068, 'Jilotepec De Molina Enriquez Col. Cruz de Dendho', 'Glob-Arte', 'B001', '00000002', 'glob_arte@gmail.com');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `modulos`
--

CREATE TABLE `modulos` (
  `id` int(11) NOT NULL,
  `modulo` varchar(45) DEFAULT NULL,
  `padre_id` int(11) DEFAULT NULL,
  `vista` varchar(45) DEFAULT NULL,
  `icon_menu` varchar(45) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `modulos`
--

INSERT INTO `modulos` (`id`, `modulo`, `padre_id`, `vista`, `icon_menu`) VALUES
(1, 'Tablero Principal', NULL, 'dashboard.php', 'fas fa-tachometer-alt'),
(2, 'Ventas', NULL, '', 'fas fa-store-alt'),
(3, 'Punto de Venta', 2, 'ventas.php', 'far fa-circle'),
(4, 'Administrar Ventas', 2, 'administrar_ventas.php', 'far fa-circle'),
(5, 'Productos', NULL, NULL, 'fas fa-cart-plus'),
(6, 'Inventario', 5, 'productos.php', 'far fa-circle'),
(7, 'Carga Masiva', 5, 'carga_masiva_productos.php', 'far fa-circle'),
(8, 'Categorías', 5, 'categorias.php', 'far fa-circle'),
(10, 'Reportes', NULL, 'reportes.php', 'fas fa-chart-line'),
(11, 'Configuración', NULL, 'configuracion.php', 'fas fa-cogs'),
(12, 'Usuarios', NULL, 'usuarios.php', 'fas fa-users'),
(13, 'Modulos y Perfiles', NULL, 'modulos_perfiles.php', 'fas fa-tablet-alt');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `perfiles`
--

CREATE TABLE `perfiles` (
  `id_perfil` int(11) NOT NULL,
  `descripcion` varchar(45) DEFAULT NULL,
  `estado` tinyint(4) DEFAULT NULL,
  `fecha_creacion` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `fecha_actualizacion` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `perfiles`
--

INSERT INTO `perfiles` (`id_perfil`, `descripcion`, `estado`, `fecha_creacion`, `fecha_actualizacion`) VALUES
(1, 'Administrador', 1, '2023-06-15 01:25:50', '2023-06-15 00:31:51'),
(2, 'Vendedor', 1, '2023-06-15 01:26:01', '2023-06-15 00:31:51');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `perfil_modulo`
--

CREATE TABLE `perfil_modulo` (
  `idperfil_modulo` int(11) NOT NULL,
  `id_perfil` int(11) DEFAULT NULL,
  `id_modulo` int(11) DEFAULT NULL,
  `vista_inicio` tinyint(4) DEFAULT NULL,
  `estado` tinyint(4) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `perfil_modulo`
--

INSERT INTO `perfil_modulo` (`idperfil_modulo`, `id_perfil`, `id_modulo`, `vista_inicio`, `estado`) VALUES
(13, 1, 13, NULL, 1),
(25, NULL, 3, 0, 1),
(26, NULL, 2, 0, 1),
(27, NULL, 4, 0, 1),
(29, NULL, 1, 1, 1),
(30, NULL, 3, 0, 1),
(31, NULL, 2, 0, 1),
(32, NULL, 4, 0, 1),
(34, NULL, 1, 1, 1),
(35, NULL, 3, 0, 1),
(36, NULL, 2, 0, 1),
(37, NULL, 4, 0, 1),
(39, NULL, 1, 1, 1),
(40, NULL, 3, 1, 1),
(41, NULL, 2, 0, 1),
(42, NULL, 4, 0, 1),
(44, NULL, 1, 0, 1),
(45, NULL, 3, 1, 1),
(46, NULL, 2, 0, 1),
(47, NULL, 4, 0, 1),
(49, NULL, 1, 0, 1),
(50, NULL, 3, 1, 1),
(51, NULL, 2, 0, 1),
(52, NULL, 4, 0, 1),
(54, NULL, 1, 0, 1),
(55, NULL, 3, 1, 1),
(56, NULL, 2, 0, 1),
(57, NULL, 4, 0, 1),
(58, NULL, 10, 0, 1),
(59, NULL, 1, 0, 1),
(60, NULL, 3, 1, 1),
(61, NULL, 2, 0, 1),
(62, NULL, 4, 0, 1),
(63, NULL, 10, 0, 1),
(64, NULL, 1, 0, 1),
(65, NULL, 3, 1, 1),
(66, NULL, 2, 0, 1),
(67, NULL, 4, 0, 1),
(68, NULL, 10, 0, 1),
(69, NULL, 1, 0, 1),
(70, NULL, 3, 1, 1),
(71, NULL, 2, 0, 1),
(72, NULL, 4, 0, 1),
(73, NULL, 10, 0, 1),
(74, NULL, 1, 0, 1),
(75, NULL, 3, 0, 1),
(76, NULL, 2, 0, 1),
(77, NULL, 4, 0, 1),
(78, NULL, 10, 0, 1),
(79, NULL, 1, 1, 1),
(80, NULL, 3, 0, 1),
(81, NULL, 2, 0, 1),
(82, NULL, 4, 0, 1),
(83, NULL, 10, 0, 1),
(84, NULL, 1, 1, 1),
(126, 1, 1, 1, 1),
(127, 1, 3, 0, 1),
(128, 1, 2, 0, 1),
(129, 1, 4, 0, 1),
(130, 1, 6, 0, 1),
(131, 1, 5, 0, 1),
(132, 1, 7, 0, 1),
(133, 1, 8, 0, 1),
(134, 2, 1, 1, 1),
(135, 2, 3, 0, 1),
(136, 2, 2, 0, 1),
(137, 2, 4, 0, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `productos`
--

CREATE TABLE `productos` (
  `id` int(11) NOT NULL,
  `codigo_producto` bigint(13) NOT NULL,
  `id_categoria_producto` int(11) DEFAULT NULL,
  `descripcion_producto` text CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL,
  `precio_compra_producto` float NOT NULL,
  `precio_venta_producto` float NOT NULL,
  `precio_mayor_producto` float DEFAULT NULL,
  `precio_oferta_producto` float DEFAULT NULL,
  `utilidad` float NOT NULL,
  `stock_producto` float DEFAULT NULL,
  `minimo_stock_producto` float DEFAULT NULL,
  `ventas_producto` float DEFAULT NULL,
  `fecha_creacion_producto` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `fecha_actualizacion_producto` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `productos`
--

INSERT INTO `productos` (`id`, `codigo_producto`, `id_categoria_producto`, `descripcion_producto`, `precio_compra_producto`, `precio_venta_producto`, `precio_mayor_producto`, `precio_oferta_producto`, `utilidad`, `stock_producto`, `minimo_stock_producto`, `ventas_producto`, `fecha_creacion_producto`, `fecha_actualizacion_producto`) VALUES
(2805, 7755139002809, 698, 'Paisana extra 5k', 18.29, 20, NULL, NULL, 0, 1, 0, 0, '2023-06-16 15:49:32', '2023-06-16'),
(2806, 7755139002810, 699, 'Gloria Fresa 500ml', 3.79, 5, NULL, NULL, 0, 1, 3, 5, '2023-06-16 16:44:02', '2023-06-16'),
(2807, 7755139002811, 697, 'Gloria evaporada ligth 400g', 3.4, 5, NULL, NULL, 0, 24, 12, 0, '2023-06-16 15:49:32', '2023-06-16'),
(2808, 7755139002812, 691, 'soda san jorge 40g', 0.5, 0.8, NULL, NULL, 0, 0, 0, 0, '2023-06-16 15:49:32', '2023-06-16'),
(2809, 7755139002813, 691, 'vainilla field 37g', 0.33, 0.5, NULL, NULL, 0, 24, 10, 0, '2023-06-16 15:49:32', '2023-06-16'),
(2810, 7755139002814, 691, 'Margarita', 0.53, 0.6, NULL, NULL, 0, 12, 6, 0, '2023-06-16 15:49:32', '2023-06-16'),
(2811, 7755139002815, 691, 'soda field 34g', 0.37, 0.6, NULL, NULL, 0, 18, 5, 0, '2023-06-16 15:49:32', '2023-06-16'),
(2812, 7755139002816, 691, 'ritz original', 0.43, 0.7, NULL, NULL, 0, 24, 10, 0, '2023-06-16 15:49:32', '2023-06-16'),
(2813, 7755139002817, 691, 'ritz queso 34g', 0.68, 0.8, NULL, NULL, 0, 18, 5, 0, '2023-06-16 15:49:32', '2023-06-16'),
(2814, 7755139002818, 691, 'Chocobum', 0.62, 0.8, NULL, NULL, 0, 18, 9, 0, '2023-06-16 15:49:32', '2023-06-16'),
(2815, 7755139002819, 691, 'Picaras', 0.6, 0.8, NULL, NULL, 0, 24, 12, 0, '2023-06-16 15:49:32', '2023-06-16'),
(2816, 7755139002820, 691, 'oreo original 36g', 0.57, 0.8, NULL, NULL, 0, 30, 10, 0, '2023-06-16 15:49:32', '2023-06-16'),
(2817, 7755139002821, 691, 'club social 26g', 0.53, 0.8, NULL, NULL, 0, 36, 10, 0, '2023-06-16 15:49:33', '2023-06-16'),
(2818, 7755139002822, 691, 'frac vanilla 45.5g', 0.52, 0.8, NULL, NULL, 0, 18, 5, 0, '2023-06-16 15:49:33', '2023-06-16'),
(2819, 7755139002823, 691, 'frac chocolate 45.5g', 0.52, 0.8, NULL, NULL, 0, 18, 5, 0, '2023-06-16 15:49:33', '2023-06-16'),
(2820, 7755139002824, 691, 'frac chasica 45.5g', 0.52, 0.8, NULL, NULL, 0, 18, 5, 0, '2023-06-16 15:49:33', '2023-06-16'),
(2821, 7755139002825, 693, 'tuyo 22g', 0.5, 0.8, NULL, NULL, 0, 20, 5, 0, '2023-06-16 15:49:33', '2023-06-16'),
(2822, 7755139002826, 691, 'gn rellenitas 36g chocolate', 0.47, 0.8, NULL, NULL, 0, 18, 5, 0, '2023-06-16 15:49:33', '2023-06-16'),
(2823, 7755139002827, 691, 'gn rellenitas 36g coco', 0.47, 0.8, NULL, NULL, 0, 18, 5, 0, '2023-06-16 15:49:33', '2023-06-16'),
(2824, 7755139002828, 691, 'gn rellenitas 36g coco', 0.47, 0.8, NULL, NULL, 0, 18, 5, 0, '2023-06-16 15:49:33', '2023-06-16'),
(2825, 7755139002829, 694, 'cancun', 0.75, 0.9, NULL, NULL, 0, 24, 10, 0, '2023-06-16 15:49:33', '2023-06-16'),
(2826, 7755139002830, 701, 'Big cola 400ml', 1, 1, NULL, NULL, 0, 15, 10, 0, '2023-06-16 15:49:33', '2023-06-16'),
(2827, 7755139002831, 703, 'Zuko Piña', 0.9, 1, NULL, NULL, 0, 12, 6, 0, '2023-06-16 15:49:33', '2023-06-16'),
(2828, 7755139002832, 703, 'Zuko Durazno', 0.9, 1, NULL, NULL, 0, 12, 6, 0, '2023-06-16 15:49:33', '2023-06-16'),
(2829, 7755139002833, 692, 'chin chin 32g', 0.88, 1, NULL, NULL, 0, 16, 5, 0, '2023-06-16 15:49:33', '2023-06-16'),
(2830, 7755139002834, 691, 'Morocha 30g', 0.85, 1, NULL, NULL, 0, 24, 12, 0, '2023-06-16 15:49:33', '2023-06-16'),
(2831, 7755139002835, 703, 'Zuko Emoliente', 0.67, 1, NULL, NULL, 0, 12, 6, 0, '2023-06-16 15:49:33', '2023-06-16'),
(2832, 7755139002836, 691, 'Choco donuts', 0.56, 1, NULL, NULL, 0, 18, 9, 0, '2023-06-16 15:49:33', '2023-06-16'),
(2833, 7755139002837, 701, 'Pepsi 355ml', 1.5, 1.2, NULL, NULL, 0, 15, 10, 0, '2023-06-16 15:49:34', '2023-06-16'),
(2834, 7755139002838, 706, 'Quaker 120gr', 1.29, 1.2, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:34', '2023-06-16'),
(2835, 7755139002839, 704, 'Pulp Durazno 315ml', 1, 1.2, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:34', '2023-06-16'),
(2836, 7755139002840, 693, 'morochas wafer 37g', 1, 1.2, NULL, NULL, 0, 12, 5, 0, '2023-06-16 15:49:34', '2023-06-16'),
(2837, 7755139002841, 691, 'Wafer sublime', 0.92, 1.2, NULL, NULL, 0, 24, 12, 0, '2023-06-16 15:49:34', '2023-06-16'),
(2838, 7755139002842, 691, 'hony bran 33g', 0.9, 1.2, NULL, NULL, 0, 18, 5, 0, '2023-06-16 15:49:34', '2023-06-16'),
(2839, 7755139002843, 691, 'Sublime clásico', 1.06, 1.3, NULL, NULL, 0, 24, 12, 0, '2023-06-16 15:49:34', '2023-06-16'),
(2840, 7755139002844, 699, 'Gloria fresa 180ml', 1.5, 1.5, NULL, NULL, 0, 24, 12, 0, '2023-06-16 15:49:34', '2023-06-16'),
(2841, 7755139002845, 699, 'Gloria durazno 180ml', 1.5, 1.5, NULL, NULL, 0, 24, 12, 0, '2023-06-16 15:49:34', '2023-06-16'),
(2842, 7755139002846, 699, 'Frutado fresa vasito', 1.39, 1.5, NULL, NULL, 0, 12, 6, 0, '2023-06-16 15:49:34', '2023-06-16'),
(2843, 7755139002847, 699, 'Frutado durazno vasito', 1.39, 1.5, NULL, NULL, 0, 12, 6, 0, '2023-06-16 15:49:34', '2023-06-16'),
(2844, 7755139002848, 706, '3 ositos quinua', 1.9, 1.8, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:34', '2023-06-16'),
(2845, 7755139002849, 701, 'Seven Up 500ml', 1.8, 1.8, NULL, NULL, 0, 20, 10, 0, '2023-06-16 15:49:34', '2023-06-16'),
(2846, 7755139002850, 701, 'Fanta Kola Inglesa 500ml', 1.39, 1.8, NULL, NULL, 0, 12, 6, 0, '2023-06-16 15:49:34', '2023-06-16'),
(2847, 7755139002851, 701, 'Fanta Naranja 500ml', 1.39, 1.8, NULL, NULL, 0, 12, 6, 0, '2023-06-16 15:49:34', '2023-06-16'),
(2848, 7755139002852, 696, 'Noble pq 2 unid', 1.3, 1.8, NULL, NULL, 0, 10, 6, 0, '2023-06-16 15:49:34', '2023-06-16'),
(2849, 7755139002853, 696, 'Suave pq 2 unid', 1.99, 2, NULL, NULL, 0, 10, 6, 0, '2023-06-16 15:49:34', '2023-06-16'),
(2850, 7755139002854, 701, 'Pepsi 750ml', 2.8, 2.5, NULL, NULL, 0, 12, 6, 0, '2023-06-16 15:49:34', '2023-06-16'),
(2851, 7755139002855, 701, 'Coca cola 600ml', 2.6, 2.5, NULL, NULL, 0, 12, 6, 0, '2023-06-16 15:49:34', '2023-06-16'),
(2852, 7755139002856, 701, 'Inca Kola 600ml', 2.6, 2.5, NULL, NULL, 0, 12, 6, 0, '2023-06-16 15:49:35', '2023-06-16'),
(2853, 7755139002857, 696, 'Elite Megarrollo', 2.19, 2.8, NULL, NULL, 0, 12, 6, 0, '2023-06-16 15:49:35', '2023-06-16'),
(2854, 7755139002858, 697, 'Pura vida 395g', 2.6, 2.9, NULL, NULL, 0, 24, 12, 0, '2023-06-16 15:49:35', '2023-06-16'),
(2855, 7755139002859, 697, 'Ideal cremosita 395g', 3, 3.2, NULL, NULL, 0, 24, 12, 0, '2023-06-16 15:49:35', '2023-06-16'),
(2856, 7755139002860, 697, 'Ideal Light 395g', 2.8, 3.2, NULL, NULL, 0, 24, 12, 0, '2023-06-16 15:49:35', '2023-06-16'),
(2857, 7755139002861, 699, 'Fresa 370ml Laive', 2.19, 3.2, NULL, NULL, 0, 12, 6, 0, '2023-06-16 15:49:35', '2023-06-16'),
(2858, 7755139002862, 697, 'Gloria evaporada entera ', 3.2, 3.3, NULL, NULL, 0, 24, 12, 0, '2023-06-16 15:49:35', '2023-06-16'),
(2859, 7755139002863, 697, 'Laive Ligth caja 480ml', 2.8, 3.3, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:35', '2023-06-16'),
(2860, 7755139002864, 701, 'Pepsi 1.5L', 4.4, 3.5, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:35', '2023-06-16'),
(2861, 7755139002865, 699, 'Gloria durazno 500ml', 3.79, 3.5, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:35', '2023-06-16'),
(2862, 7755139002866, 699, 'Gloria Vainilla Francesa 500ml', 3.79, 3.5, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:35', '2023-06-16'),
(2863, 7755139002867, 699, 'Griego gloria', 3.65, 3.5, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:35', '2023-06-16'),
(2864, 7755139002868, 701, 'Sabor Oro 1.7L', 3.5, 3.5, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:35', '2023-06-16'),
(2865, 7755139002869, 697, 'Canchita mantequilla ', 3.25, 3.5, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:35', '2023-06-16'),
(2866, 7755139002870, 697, 'Canchita natural', 3.25, 3.5, NULL, NULL, 0, 3, 2, 0, '2023-06-16 15:49:35', '2023-06-16'),
(2867, 7755139002871, 697, 'Laive sin lactosa caja 480ml', 3.17, 3.5, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:35', '2023-06-16'),
(2868, 7755139002872, 698, 'Valle Norte 750g', 3.1, 3.5, NULL, NULL, 0, 10, 5, 0, '2023-06-16 15:49:35', '2023-06-16'),
(2869, 7755139002873, 699, 'Battimix', 2.89, 3.5, NULL, NULL, 0, 24, 12, 0, '2023-06-16 15:49:35', '2023-06-16'),
(2870, 7755139002874, 697, 'Pringles papas', 2.8, 3.5, NULL, NULL, 0, 12, 6, 0, '2023-06-16 15:49:35', '2023-06-16'),
(2871, 7755139002875, 698, 'Costeño 750g', 3.69, 4.2, NULL, NULL, 0, 20, 10, 0, '2023-06-16 15:49:35', '2023-06-16'),
(2872, 7755139002876, 698, 'Faraon amarillo 1k', 3.39, 4.2, NULL, NULL, 0, 10, 5, 0, '2023-06-16 15:49:35', '2023-06-16'),
(2873, 7755139002877, 695, 'A1 Trozos ', 5.17, 4.9, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:36', '2023-06-16'),
(2874, 7755139002878, 696, 'Nova pq 2 unid', 3.99, 4.9, NULL, NULL, 0, 6, 2, 0, '2023-06-16 15:49:36', '2023-06-16'),
(2875, 7755139002879, 696, 'Suave pq 4 unid', 4.58, 5, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:36', '2023-06-16'),
(2876, 7755139002880, 695, 'Florida Trozos ', 5.15, 5.5, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:36', '2023-06-16'),
(2877, 7755139002881, 696, 'Paracas pq 4 unid', 5, 5.5, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:36', '2023-06-16'),
(2878, 7755139002882, 695, 'Trozos de atún Campomar', 4.66, 5.5, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:36', '2023-06-16'),
(2879, 7755139002883, 695, 'A1 Filete', 4.65, 5.5, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:36', '2023-06-16'),
(2880, 7755139002884, 695, 'Real Trozos', 4.63, 5.5, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:36', '2023-06-16'),
(2881, 7755139002885, 699, 'Durazno 1L laive', 5.7, 5.7, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:36', '2023-06-16'),
(2882, 7755139002886, 699, 'Fresa 1L Laive', 5.7, 5.7, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:36', '2023-06-16'),
(2883, 7755139002887, 695, 'A1 Filete Ligth', 6.08, 5.8, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:36', '2023-06-16'),
(2884, 7755139002888, 699, 'Lúcuma 1L Gloria', 5.9, 5.9, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:36', '2023-06-16'),
(2885, 7755139002889, 699, 'Fresa 1L Gloria', 5.9, 5.9, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:36', '2023-06-16'),
(2886, 7755139002890, 699, 'Milkito fresa 1L', 5.9, 5.9, NULL, NULL, 0, 3, 1, 0, '2023-06-16 15:49:36', '2023-06-16'),
(2887, 7755139002891, 699, 'Gloria Durazno 1L', 5.9, 5.9, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:36', '2023-06-16'),
(2888, 7755139002892, 695, 'Filete de atún Campomar', 5.08, 5.9, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:36', '2023-06-16'),
(2889, 7755139002893, 695, 'Florida Filete Ligth', 5.63, 6, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:37', '2023-06-16'),
(2890, 7755139002894, 695, 'Filete de atún Florida ', 5.4, 6, NULL, NULL, 0, 12, 5, 0, '2023-06-16 15:49:37', '2023-06-16'),
(2891, 7755139002895, 701, 'Inca Kola 1.5L', 5.9, 6.5, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:37', '2023-06-16'),
(2892, 7755139002896, 701, 'Coca Cola 1.5L', 5.9, 6.5, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:37', '2023-06-16'),
(2893, 7755139002897, 705, 'Red Bull 250ml', 5.33, 6.9, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:37', '2023-06-16'),
(2894, 7755139002898, 701, 'Sprite 3L', 7.49, 7.5, NULL, NULL, 0, 4, 2, 0, '2023-06-16 15:49:37', '2023-06-16'),
(2895, 7755139002899, 701, 'Pepsi 3L', 8, 8, NULL, NULL, 0, 4, 2, 0, '2023-06-16 15:49:37', '2023-06-16'),
(2896, 7755139002900, 702, 'Laive 200gr', 8.9, 8.8, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:37', '2023-06-16'),
(2897, 7755139002901, 702, 'Gloria Pote con sal', 9.19, 9.2, NULL, NULL, 0, 3, 2, 0, '2023-06-16 15:49:37', '2023-06-16'),
(2898, 7755139002902, 700, 'Deleite 1L', 9.8, 9.5, NULL, NULL, 0, 4, 2, 0, '2023-06-16 15:49:37', '2023-06-16'),
(2899, 7755139002903, 700, 'Sao 1L', 12.1, 12.1, NULL, NULL, 0, 3, 1, 0, '2023-06-16 15:49:37', '2023-06-16'),
(2900, 7755139002904, 700, 'Cocinero 1L', 12.4, 12.4, NULL, NULL, 0, 3, 1, 0, '2023-06-16 15:49:37', '2023-06-16'),
(2901, 7755139002905, 698, 'Paisana extra 5k', 18.29, 20, NULL, NULL, 0, 1, 0, 0, '2023-06-16 15:49:37', '2023-06-16'),
(2902, 7755139002906, 699, 'Gloria Fresa 500ml', 3.79, 5, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:37', '2023-06-16'),
(2903, 7755139002907, 697, 'Gloria evaporada ligth 400g', 3.4, 5, NULL, NULL, 0, 24, 12, 0, '2023-06-16 15:49:37', '2023-06-16'),
(2904, 7755139002908, 691, 'soda san jorge 40g', 0.5, 0.8, NULL, NULL, 0, 0, 0, 0, '2023-06-16 15:49:37', '2023-06-16'),
(2905, 7755139002909, 691, 'vainilla field 37g', 0.33, 0.5, NULL, NULL, 0, 24, 10, 0, '2023-06-16 15:49:37', '2023-06-16'),
(2906, 7755139002910, 691, 'Margarita', 0.53, 0.6, NULL, NULL, 0, 12, 6, 0, '2023-06-16 15:49:37', '2023-06-16'),
(2907, 7755139002911, 691, 'soda field 34g', 0.37, 0.6, NULL, NULL, 0, 18, 5, 0, '2023-06-16 15:49:37', '2023-06-16'),
(2908, 7755139002912, 691, 'ritz original', 0.43, 0.7, NULL, NULL, 0, 24, 10, 0, '2023-06-16 15:49:37', '2023-06-16'),
(2909, 7755139002913, 691, 'ritz queso 34g', 0.68, 0.8, NULL, NULL, 0, 18, 5, 0, '2023-06-16 15:49:38', '2023-06-16'),
(2910, 7755139002914, 691, 'Chocobum', 0.62, 0.8, NULL, NULL, 0, 18, 9, 0, '2023-06-16 15:49:38', '2023-06-16'),
(2911, 7755139002915, 691, 'Picaras', 0.6, 0.8, NULL, NULL, 0, 24, 12, 0, '2023-06-16 15:49:38', '2023-06-16'),
(2912, 7755139002916, 691, 'oreo original 36g', 0.57, 0.8, NULL, NULL, 0, 30, 10, 0, '2023-06-16 15:49:38', '2023-06-16'),
(2913, 7755139002917, 691, 'club social 26g', 0.53, 0.8, NULL, NULL, 0, 36, 10, 0, '2023-06-16 15:49:38', '2023-06-16'),
(2914, 7755139002918, 691, 'frac vanilla 45.5g', 0.52, 0.8, NULL, NULL, 0, 18, 5, 0, '2023-06-16 15:49:38', '2023-06-16'),
(2915, 7755139002919, 691, 'frac chocolate 45.5g', 0.52, 0.8, NULL, NULL, 0, 18, 5, 0, '2023-06-16 15:49:38', '2023-06-16'),
(2916, 7755139002920, 691, 'frac chasica 45.5g', 0.52, 0.8, NULL, NULL, 0, 18, 5, 0, '2023-06-16 15:49:38', '2023-06-16'),
(2917, 7755139002921, 693, 'tuyo 22g', 0.5, 0.8, NULL, NULL, 0, 20, 5, 0, '2023-06-16 15:49:38', '2023-06-16'),
(2918, 7755139002922, 691, 'gn rellenitas 36g chocolate', 0.47, 0.8, NULL, NULL, 0, 18, 5, 0, '2023-06-16 15:49:38', '2023-06-16'),
(2919, 7755139002923, 691, 'gn rellenitas 36g coco', 0.47, 0.8, NULL, NULL, 0, 18, 5, 0, '2023-06-16 15:49:38', '2023-06-16'),
(2920, 7755139002924, 691, 'gn rellenitas 36g coco', 0.47, 0.8, NULL, NULL, 0, 18, 5, 0, '2023-06-16 15:49:38', '2023-06-16'),
(2921, 7755139002925, 694, 'cancun', 0.75, 0.9, NULL, NULL, 0, 24, 10, 0, '2023-06-16 15:49:38', '2023-06-16'),
(2922, 7755139002926, 701, 'Big cola 400ml', 1, 1, NULL, NULL, 0, 15, 10, 0, '2023-06-16 15:49:38', '2023-06-16'),
(2923, 7755139002927, 703, 'Zuko Piña', 0.9, 1, NULL, NULL, 0, 12, 6, 0, '2023-06-16 15:49:38', '2023-06-16'),
(2924, 7755139002928, 703, 'Zuko Durazno', 0.9, 1, NULL, NULL, 0, 12, 6, 0, '2023-06-16 15:49:38', '2023-06-16'),
(2925, 7755139002929, 692, 'chin chin 32g', 0.88, 1, NULL, NULL, 0, 16, 5, 0, '2023-06-16 15:49:38', '2023-06-16'),
(2926, 7755139002930, 691, 'Morocha 30g', 0.85, 1, NULL, NULL, 0, 24, 12, 0, '2023-06-16 15:49:38', '2023-06-16'),
(2927, 7755139002931, 703, 'Zuko Emoliente', 0.67, 1, NULL, NULL, 0, 12, 6, 0, '2023-06-16 15:49:38', '2023-06-16'),
(2928, 7755139002932, 691, 'Choco donuts', 0.56, 1, NULL, NULL, 0, 18, 9, 0, '2023-06-16 15:49:39', '2023-06-16'),
(2929, 7755139002933, 701, 'Pepsi 355ml', 1.5, 1.2, NULL, NULL, 0, 15, 10, 0, '2023-06-16 15:49:39', '2023-06-16'),
(2930, 7755139002934, 706, 'Quaker 120gr', 1.29, 1.2, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:39', '2023-06-16'),
(2931, 7755139002935, 704, 'Pulp Durazno 315ml', 1, 1.2, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:39', '2023-06-16'),
(2932, 7755139002936, 693, 'morochas wafer 37g', 1, 1.2, NULL, NULL, 0, 12, 5, 0, '2023-06-16 15:49:39', '2023-06-16'),
(2933, 7755139002937, 691, 'Wafer sublime', 0.92, 1.2, NULL, NULL, 0, 24, 12, 0, '2023-06-16 15:49:39', '2023-06-16'),
(2934, 7755139002938, 691, 'hony bran 33g', 0.9, 1.2, NULL, NULL, 0, 18, 5, 0, '2023-06-16 15:49:39', '2023-06-16'),
(2935, 7755139002939, 691, 'Sublime clásico', 1.06, 1.3, NULL, NULL, 0, 24, 12, 0, '2023-06-16 15:49:39', '2023-06-16'),
(2936, 7755139002940, 699, 'Gloria fresa 180ml', 1.5, 1.5, NULL, NULL, 0, 24, 12, 0, '2023-06-16 15:49:39', '2023-06-16'),
(2937, 7755139002941, 699, 'Gloria durazno 180ml', 1.5, 1.5, NULL, NULL, 0, 24, 12, 0, '2023-06-16 15:49:39', '2023-06-16'),
(2938, 7755139002942, 699, 'Frutado fresa vasito', 1.39, 1.5, NULL, NULL, 0, 12, 6, 0, '2023-06-16 15:49:39', '2023-06-16'),
(2939, 7755139002943, 699, 'Frutado durazno vasito', 1.39, 1.5, NULL, NULL, 0, 12, 6, 0, '2023-06-16 15:49:39', '2023-06-16'),
(2940, 7755139002944, 706, '3 ositos quinua', 1.9, 1.8, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:39', '2023-06-16'),
(2941, 7755139002945, 701, 'Seven Up 500ml', 1.8, 1.8, NULL, NULL, 0, 20, 10, 0, '2023-06-16 15:49:39', '2023-06-16'),
(2942, 7755139002946, 701, 'Fanta Kola Inglesa 500ml', 1.39, 1.8, NULL, NULL, 0, 12, 6, 0, '2023-06-16 15:49:39', '2023-06-16'),
(2943, 7755139002947, 701, 'Fanta Naranja 500ml', 1.39, 1.8, NULL, NULL, 0, 12, 6, 0, '2023-06-16 15:49:39', '2023-06-16'),
(2944, 7755139002948, 696, 'Noble pq 2 unid', 1.3, 1.8, NULL, NULL, 0, 10, 6, 0, '2023-06-16 15:49:40', '2023-06-16'),
(2945, 7755139002949, 696, 'Suave pq 2 unid', 1.99, 2, NULL, NULL, 0, 10, 6, 0, '2023-06-16 15:49:40', '2023-06-16'),
(2946, 7755139002950, 701, 'Pepsi 750ml', 2.8, 2.5, NULL, NULL, 0, 12, 6, 0, '2023-06-16 15:49:40', '2023-06-16'),
(2947, 7755139002951, 701, 'Coca cola 600ml', 2.6, 2.5, NULL, NULL, 0, 12, 6, 0, '2023-06-16 15:49:40', '2023-06-16'),
(2948, 7755139002952, 701, 'Inca Kola 600ml', 2.6, 2.5, NULL, NULL, 0, 12, 6, 0, '2023-06-16 15:49:40', '2023-06-16'),
(2949, 7755139002953, 696, 'Elite Megarrollo', 2.19, 2.8, NULL, NULL, 0, 12, 6, 0, '2023-06-16 15:49:40', '2023-06-16'),
(2950, 7755139002954, 697, 'Pura vida 395g', 2.6, 2.9, NULL, NULL, 0, 24, 12, 0, '2023-06-16 15:49:40', '2023-06-16'),
(2951, 7755139002955, 697, 'Ideal cremosita 395g', 3, 3.2, NULL, NULL, 0, 24, 12, 0, '2023-06-16 15:49:40', '2023-06-16'),
(2952, 7755139002956, 697, 'Ideal Light 395g', 2.8, 3.2, NULL, NULL, 0, 24, 12, 0, '2023-06-16 15:49:40', '2023-06-16'),
(2953, 7755139002957, 699, 'Fresa 370ml Laive', 2.19, 3.2, NULL, NULL, 0, 12, 6, 0, '2023-06-16 15:49:40', '2023-06-16'),
(2954, 7755139002958, 697, 'Gloria evaporada entera ', 3.2, 3.3, NULL, NULL, 0, 24, 12, 0, '2023-06-16 15:49:40', '2023-06-16'),
(2955, 7755139002959, 697, 'Laive Ligth caja 480ml', 2.8, 3.3, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:40', '2023-06-16'),
(2956, 7755139002960, 701, 'Pepsi 1.5L', 4.4, 3.5, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:40', '2023-06-16'),
(2957, 7755139002961, 699, 'Gloria durazno 500ml', 3.79, 3.5, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:40', '2023-06-16'),
(2958, 7755139002962, 699, 'Gloria Vainilla Francesa 500ml', 3.79, 3.5, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:40', '2023-06-16'),
(2959, 7755139002963, 699, 'Griego gloria', 3.65, 3.5, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:40', '2023-06-16'),
(2960, 7755139002964, 701, 'Sabor Oro 1.7L', 3.5, 3.5, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:41', '2023-06-16'),
(2961, 7755139002965, 697, 'Canchita mantequilla ', 3.25, 3.5, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:41', '2023-06-16'),
(2962, 7755139002966, 697, 'Canchita natural', 3.25, 3.5, NULL, NULL, 0, 3, 2, 0, '2023-06-16 15:49:41', '2023-06-16'),
(2963, 7755139002967, 697, 'Laive sin lactosa caja 480ml', 3.17, 3.5, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:41', '2023-06-16'),
(2964, 7755139002968, 698, 'Valle Norte 750g', 3.1, 3.5, NULL, NULL, 0, 10, 5, 0, '2023-06-16 15:49:41', '2023-06-16'),
(2965, 7755139002969, 699, 'Battimix', 2.89, 3.5, NULL, NULL, 0, 24, 12, 0, '2023-06-16 15:49:41', '2023-06-16'),
(2966, 7755139002970, 697, 'Pringles papas', 2.8, 3.5, NULL, NULL, 0, 12, 6, 0, '2023-06-16 15:49:41', '2023-06-16'),
(2967, 7755139002971, 698, 'Costeño 750g', 3.69, 4.2, NULL, NULL, 0, 20, 10, 0, '2023-06-16 15:49:41', '2023-06-16'),
(2968, 7755139002972, 698, 'Faraon amarillo 1k', 3.39, 4.2, NULL, NULL, 0, 10, 5, 0, '2023-06-16 15:49:41', '2023-06-16'),
(2969, 7755139002973, 695, 'A1 Trozos ', 5.17, 4.9, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:41', '2023-06-16'),
(2970, 7755139002974, 696, 'Nova pq 2 unid', 3.99, 4.9, NULL, NULL, 0, 6, 2, 0, '2023-06-16 15:49:41', '2023-06-16'),
(2971, 7755139002975, 696, 'Suave pq 4 unid', 4.58, 5, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:41', '2023-06-16'),
(2972, 7755139002976, 695, 'Florida Trozos ', 5.15, 5.5, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:41', '2023-06-16'),
(2973, 7755139002977, 696, 'Paracas pq 4 unid', 5, 5.5, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:41', '2023-06-16'),
(2974, 7755139002978, 695, 'Trozos de atún Campomar', 4.66, 5.5, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:41', '2023-06-16'),
(2975, 7755139002979, 695, 'A1 Filete', 4.65, 5.5, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:41', '2023-06-16'),
(2976, 7755139002980, 695, 'Real Trozos', 4.63, 5.5, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:41', '2023-06-16'),
(2977, 7755139002981, 699, 'Durazno 1L laive', 5.7, 5.7, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:41', '2023-06-16'),
(2978, 7755139002982, 699, 'Fresa 1L Laive', 5.7, 5.7, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:41', '2023-06-16'),
(2979, 7755139002983, 695, 'A1 Filete Ligth', 6.08, 5.8, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:42', '2023-06-16'),
(2980, 7755139002984, 699, 'Lúcuma 1L Gloria', 5.9, 5.9, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:42', '2023-06-16'),
(2981, 7755139002985, 699, 'Fresa 1L Gloria', 5.9, 5.9, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:42', '2023-06-16'),
(2982, 7755139002986, 699, 'Milkito fresa 1L', 5.9, 5.9, NULL, NULL, 0, 3, 1, 0, '2023-06-16 15:49:42', '2023-06-16'),
(2983, 7755139002987, 699, 'Gloria Durazno 1L', 5.9, 5.9, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:42', '2023-06-16'),
(2984, 7755139002988, 695, 'Filete de atún Campomar', 5.08, 5.9, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:42', '2023-06-16'),
(2985, 7755139002989, 695, 'Florida Filete Ligth', 5.63, 6, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:42', '2023-06-16'),
(2986, 7755139002990, 695, 'Filete de atún Florida ', 5.4, 6, NULL, NULL, 0, 12, 5, 0, '2023-06-16 15:49:42', '2023-06-16'),
(2987, 7755139002991, 701, 'Inca Kola 1.5L', 5.9, 6.5, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:42', '2023-06-16'),
(2988, 7755139002992, 701, 'Coca Cola 1.5L', 5.9, 6.5, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:42', '2023-06-16'),
(2989, 7755139002993, 705, 'Red Bull 250ml', 5.33, 6.9, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:42', '2023-06-16'),
(2990, 7755139002994, 701, 'Sprite 3L', 7.49, 7.5, NULL, NULL, 0, 4, 2, 0, '2023-06-16 15:49:42', '2023-06-16'),
(2991, 7755139002995, 701, 'Pepsi 3L', 8, 8, NULL, NULL, 0, 4, 2, 0, '2023-06-16 15:49:42', '2023-06-16'),
(2992, 7755139002996, 702, 'Laive 200gr', 8.9, 8.8, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:42', '2023-06-16'),
(2993, 7755139002997, 702, 'Gloria Pote con sal', 9.19, 9.2, NULL, NULL, 0, 3, 2, 0, '2023-06-16 15:49:42', '2023-06-16'),
(2994, 7755139002998, 700, 'Deleite 1L', 9.8, 9.5, NULL, NULL, 0, 4, 2, 0, '2023-06-16 15:49:43', '2023-06-16'),
(2995, 7755139002999, 700, 'Sao 1L', 12.1, 12.1, NULL, NULL, 0, 3, 1, 0, '2023-06-16 15:49:43', '2023-06-16'),
(2996, 7755139003000, 700, 'Cocinero 1L', 12.4, 12.4, NULL, NULL, 0, 3, 1, 0, '2023-06-16 15:49:43', '2023-06-16'),
(2997, 7755139003001, 698, 'Paisana extra 5k', 18.29, 20, NULL, NULL, 0, 1, 0, 0, '2023-06-16 15:49:43', '2023-06-16'),
(2998, 7755139003002, 699, 'Gloria Fresa 500ml', 3.79, 5, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:43', '2023-06-16'),
(2999, 7755139003003, 697, 'Gloria evaporada ligth 400g', 3.4, 5, NULL, NULL, 0, 24, 12, 0, '2023-06-16 15:49:43', '2023-06-16'),
(3000, 7755139003004, 691, 'soda san jorge 40g', 0.5, 0.8, NULL, NULL, 0, 0, 0, 0, '2023-06-16 15:49:43', '2023-06-16'),
(3001, 7755139003005, 691, 'vainilla field 37g', 0.33, 0.5, NULL, NULL, 0, 24, 10, 0, '2023-06-16 15:49:43', '2023-06-16'),
(3002, 7755139003006, 691, 'Margarita', 0.53, 0.6, NULL, NULL, 0, 12, 6, 0, '2023-06-16 15:49:43', '2023-06-16'),
(3003, 7755139003007, 691, 'soda field 34g', 0.37, 0.6, NULL, NULL, 0, 18, 5, 0, '2023-06-16 15:49:43', '2023-06-16'),
(3004, 7755139003008, 691, 'ritz original', 0.43, 0.7, NULL, NULL, 0, 24, 10, 0, '2023-06-16 15:49:43', '2023-06-16'),
(3005, 7755139003009, 691, 'ritz queso 34g', 0.68, 0.8, NULL, NULL, 0, 18, 5, 0, '2023-06-16 15:49:43', '2023-06-16'),
(3006, 7755139003010, 691, 'Chocobum', 0.62, 0.8, NULL, NULL, 0, 18, 9, 0, '2023-06-16 15:49:43', '2023-06-16'),
(3007, 7755139003011, 691, 'Picaras', 0.6, 0.8, NULL, NULL, 0, 24, 12, 0, '2023-06-16 15:49:43', '2023-06-16'),
(3008, 7755139003012, 691, 'oreo original 36g', 0.57, 0.8, NULL, NULL, 0, 30, 10, 0, '2023-06-16 15:49:43', '2023-06-16'),
(3009, 7755139003013, 691, 'club social 26g', 0.53, 0.8, NULL, NULL, 0, 36, 10, 0, '2023-06-16 15:49:43', '2023-06-16'),
(3010, 7755139003014, 691, 'frac vanilla 45.5g', 0.52, 0.8, NULL, NULL, 0, 18, 5, 0, '2023-06-16 15:49:43', '2023-06-16'),
(3011, 7755139003015, 691, 'frac chocolate 45.5g', 0.52, 0.8, NULL, NULL, 0, 18, 5, 0, '2023-06-16 15:49:43', '2023-06-16'),
(3012, 7755139003016, 691, 'frac chasica 45.5g', 0.52, 0.8, NULL, NULL, 0, 18, 5, 0, '2023-06-16 15:49:44', '2023-06-16'),
(3013, 7755139003017, 693, 'tuyo 22g', 0.5, 0.8, NULL, NULL, 0, 20, 5, 0, '2023-06-16 15:49:44', '2023-06-16'),
(3014, 7755139003018, 691, 'gn rellenitas 36g chocolate', 0.47, 0.8, NULL, NULL, 0, 18, 5, 0, '2023-06-16 15:49:44', '2023-06-16'),
(3015, 7755139003019, 691, 'gn rellenitas 36g coco', 0.47, 0.8, NULL, NULL, 0, 18, 5, 0, '2023-06-16 15:49:44', '2023-06-16'),
(3016, 7755139003020, 691, 'gn rellenitas 36g coco', 0.47, 0.8, NULL, NULL, 0, 18, 5, 0, '2023-06-16 15:49:44', '2023-06-16'),
(3017, 7755139003021, 694, 'cancun', 0.75, 0.9, NULL, NULL, 0, 24, 10, 0, '2023-06-16 15:49:44', '2023-06-16'),
(3018, 7755139003022, 701, 'Big cola 400ml', 1, 1, NULL, NULL, 0, 15, 10, 0, '2023-06-16 15:49:44', '2023-06-16'),
(3019, 7755139003023, 703, 'Zuko Piña', 0.9, 1, NULL, NULL, 0, 12, 6, 0, '2023-06-16 15:49:44', '2023-06-16'),
(3020, 7755139003024, 703, 'Zuko Durazno', 0.9, 1, NULL, NULL, 0, 12, 6, 0, '2023-06-16 15:49:44', '2023-06-16'),
(3021, 7755139003025, 692, 'chin chin 32g', 0.88, 1, NULL, NULL, 0, 16, 5, 0, '2023-06-16 15:49:44', '2023-06-16'),
(3022, 7755139003026, 691, 'Morocha 30g', 0.85, 1, NULL, NULL, 0, 24, 12, 0, '2023-06-16 15:49:44', '2023-06-16'),
(3023, 7755139003027, 703, 'Zuko Emoliente', 0.67, 1, NULL, NULL, 0, 12, 6, 0, '2023-06-16 15:49:44', '2023-06-16'),
(3024, 7755139003028, 691, 'Choco donuts', 0.56, 1, NULL, NULL, 0, 18, 9, 0, '2023-06-16 15:49:44', '2023-06-16'),
(3025, 7755139003029, 701, 'Pepsi 355ml', 1.5, 1.2, NULL, NULL, 0, 15, 10, 0, '2023-06-16 15:49:44', '2023-06-16'),
(3026, 7755139003030, 706, 'Quaker 120gr', 1.29, 1.2, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:44', '2023-06-16'),
(3027, 7755139003031, 704, 'Pulp Durazno 315ml', 1, 1.2, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:44', '2023-06-16'),
(3028, 7755139003032, 693, 'morochas wafer 37g', 1, 1.2, NULL, NULL, 0, 12, 5, 0, '2023-06-16 15:49:45', '2023-06-16'),
(3029, 7755139003033, 691, 'Wafer sublime', 0.92, 1.2, NULL, NULL, 0, 24, 12, 0, '2023-06-16 15:49:45', '2023-06-16'),
(3030, 7755139003034, 691, 'hony bran 33g', 0.9, 1.2, NULL, NULL, 0, 18, 5, 0, '2023-06-16 15:49:45', '2023-06-16'),
(3031, 7755139003035, 691, 'Sublime clásico', 1.06, 1.3, NULL, NULL, 0, 24, 12, 0, '2023-06-16 15:49:45', '2023-06-16'),
(3032, 7755139003036, 699, 'Gloria fresa 180ml', 1.5, 1.5, NULL, NULL, 0, 24, 12, 0, '2023-06-16 15:49:45', '2023-06-16'),
(3033, 7755139003037, 699, 'Gloria durazno 180ml', 1.5, 1.5, NULL, NULL, 0, 24, 12, 0, '2023-06-16 15:49:45', '2023-06-16'),
(3034, 7755139003038, 699, 'Frutado fresa vasito', 1.39, 1.5, NULL, NULL, 0, 12, 6, 0, '2023-06-16 15:49:45', '2023-06-16'),
(3035, 7755139003039, 699, 'Frutado durazno vasito', 1.39, 1.5, NULL, NULL, 0, 12, 6, 0, '2023-06-16 15:49:45', '2023-06-16'),
(3036, 7755139003040, 706, '3 ositos quinua', 1.9, 1.8, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:45', '2023-06-16'),
(3037, 7755139003041, 701, 'Seven Up 500ml', 1.8, 1.8, NULL, NULL, 0, 20, 10, 0, '2023-06-16 15:49:45', '2023-06-16'),
(3038, 7755139003042, 701, 'Fanta Kola Inglesa 500ml', 1.39, 1.8, NULL, NULL, 0, 12, 6, 0, '2023-06-16 15:49:45', '2023-06-16'),
(3039, 7755139003043, 701, 'Fanta Naranja 500ml', 1.39, 1.8, NULL, NULL, 0, 12, 6, 0, '2023-06-16 15:49:45', '2023-06-16'),
(3040, 7755139003044, 696, 'Noble pq 2 unid', 1.3, 1.8, NULL, NULL, 0, 10, 6, 0, '2023-06-16 15:49:45', '2023-06-16'),
(3041, 7755139003045, 696, 'Suave pq 2 unid', 1.99, 2, NULL, NULL, 0, 10, 6, 0, '2023-06-16 15:49:45', '2023-06-16'),
(3042, 7755139003046, 701, 'Pepsi 750ml', 2.8, 2.5, NULL, NULL, 0, 12, 6, 0, '2023-06-16 15:49:45', '2023-06-16'),
(3043, 7755139003047, 701, 'Coca cola 600ml', 2.6, 2.5, NULL, NULL, 0, 12, 6, 0, '2023-06-16 15:49:45', '2023-06-16'),
(3044, 7755139003048, 701, 'Inca Kola 600ml', 2.6, 2.5, NULL, NULL, 0, 12, 6, 0, '2023-06-16 15:49:45', '2023-06-16'),
(3045, 7755139003049, 696, 'Elite Megarrollo', 2.19, 2.8, NULL, NULL, 0, 12, 6, 0, '2023-06-16 15:49:45', '2023-06-16'),
(3046, 7755139003050, 697, 'Pura vida 395g', 2.6, 2.9, NULL, NULL, 0, 24, 12, 0, '2023-06-16 15:49:46', '2023-06-16'),
(3047, 7755139003051, 697, 'Ideal cremosita 395g', 3, 3.2, NULL, NULL, 0, 24, 12, 0, '2023-06-16 15:49:46', '2023-06-16'),
(3048, 7755139003052, 697, 'Ideal Light 395g', 2.8, 3.2, NULL, NULL, 0, 24, 12, 0, '2023-06-16 15:49:46', '2023-06-16'),
(3049, 7755139003053, 699, 'Fresa 370ml Laive', 2.19, 3.2, NULL, NULL, 0, 12, 6, 0, '2023-06-16 15:49:46', '2023-06-16'),
(3050, 7755139003054, 697, 'Gloria evaporada entera ', 3.2, 3.3, NULL, NULL, 0, 24, 12, 0, '2023-06-16 15:49:46', '2023-06-16'),
(3051, 7755139003055, 697, 'Laive Ligth caja 480ml', 2.8, 3.3, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:46', '2023-06-16'),
(3052, 7755139003056, 701, 'Pepsi 1.5L', 4.4, 3.5, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:46', '2023-06-16'),
(3053, 7755139003057, 699, 'Gloria durazno 500ml', 3.79, 3.5, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:46', '2023-06-16'),
(3054, 7755139003058, 699, 'Gloria Vainilla Francesa 500ml', 3.79, 3.5, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:46', '2023-06-16'),
(3055, 7755139003059, 699, 'Griego gloria', 3.65, 3.5, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:46', '2023-06-16'),
(3056, 7755139003060, 701, 'Sabor Oro 1.7L', 3.5, 3.5, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:46', '2023-06-16'),
(3057, 7755139003061, 697, 'Canchita mantequilla ', 3.25, 3.5, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:46', '2023-06-16'),
(3058, 7755139003062, 697, 'Canchita natural', 3.25, 3.5, NULL, NULL, 0, 3, 2, 0, '2023-06-16 15:49:46', '2023-06-16'),
(3059, 7755139003063, 697, 'Laive sin lactosa caja 480ml', 3.17, 3.5, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:46', '2023-06-16'),
(3060, 7755139003064, 698, 'Valle Norte 750g', 3.1, 3.5, NULL, NULL, 0, 10, 5, 0, '2023-06-16 15:49:47', '2023-06-16'),
(3061, 7755139003065, 699, 'Battimix', 2.89, 3.5, NULL, NULL, 0, 24, 12, 0, '2023-06-16 15:49:47', '2023-06-16'),
(3062, 7755139003066, 697, 'Pringles papas', 2.8, 3.5, NULL, NULL, 0, 12, 6, 0, '2023-06-16 15:49:47', '2023-06-16'),
(3063, 7755139003067, 698, 'Costeño 750g', 3.69, 4.2, NULL, NULL, 0, 20, 10, 0, '2023-06-16 15:49:47', '2023-06-16'),
(3064, 7755139003068, 698, 'Faraon amarillo 1k', 3.39, 4.2, NULL, NULL, 0, 10, 5, 0, '2023-06-16 15:49:47', '2023-06-16'),
(3065, 7755139003069, 695, 'A1 Trozos ', 5.17, 4.9, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:47', '2023-06-16'),
(3066, 7755139003070, 696, 'Nova pq 2 unid', 3.99, 4.9, NULL, NULL, 0, 6, 2, 0, '2023-06-16 15:49:47', '2023-06-16'),
(3067, 7755139003071, 696, 'Suave pq 4 unid', 4.58, 5, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:47', '2023-06-16'),
(3068, 7755139003072, 695, 'Florida Trozos ', 5.15, 5.5, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:47', '2023-06-16'),
(3069, 7755139003073, 696, 'Paracas pq 4 unid', 5, 5.5, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:47', '2023-06-16'),
(3070, 7755139003074, 695, 'Trozos de atún Campomar', 4.66, 5.5, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:47', '2023-06-16'),
(3071, 7755139003075, 695, 'A1 Filete', 4.65, 5.5, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:47', '2023-06-16'),
(3072, 7755139003076, 695, 'Real Trozos', 4.63, 5.5, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:47', '2023-06-16'),
(3073, 7755139003077, 699, 'Durazno 1L laive', 5.7, 5.7, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:47', '2023-06-16'),
(3074, 7755139003078, 699, 'Fresa 1L Laive', 5.7, 5.7, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:47', '2023-06-16'),
(3075, 7755139003079, 695, 'A1 Filete Ligth', 6.08, 5.8, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:47', '2023-06-16'),
(3076, 7755139003080, 699, 'Lúcuma 1L Gloria', 5.9, 5.9, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:48', '2023-06-16'),
(3077, 7755139003081, 699, 'Fresa 1L Gloria', 5.9, 5.9, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:48', '2023-06-16'),
(3078, 7755139003082, 699, 'Milkito fresa 1L', 5.9, 5.9, NULL, NULL, 0, 3, 1, 0, '2023-06-16 15:49:48', '2023-06-16'),
(3079, 7755139003083, 699, 'Gloria Durazno 1L', 5.9, 5.9, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:48', '2023-06-16'),
(3080, 7755139003084, 695, 'Filete de atún Campomar', 5.08, 5.9, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:48', '2023-06-16'),
(3081, 7755139003085, 695, 'Florida Filete Ligth', 5.63, 6, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:48', '2023-06-16'),
(3082, 7755139003086, 695, 'Filete de atún Florida ', 5.4, 6, NULL, NULL, 0, 12, 5, 0, '2023-06-16 15:49:48', '2023-06-16'),
(3083, 7755139003087, 701, 'Inca Kola 1.5L', 5.9, 6.5, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:48', '2023-06-16'),
(3084, 7755139003088, 701, 'Coca Cola 1.5L', 5.9, 6.5, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:48', '2023-06-16'),
(3085, 7755139003089, 705, 'Red Bull 250ml', 5.33, 6.9, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:48', '2023-06-16'),
(3086, 7755139003090, 701, 'Sprite 3L', 7.49, 7.5, NULL, NULL, 0, 4, 2, 0, '2023-06-16 15:49:48', '2023-06-16'),
(3087, 7755139003091, 701, 'Pepsi 3L', 8, 8, NULL, NULL, 0, 4, 2, 0, '2023-06-16 15:49:48', '2023-06-16'),
(3088, 7755139003092, 702, 'Laive 200gr', 8.9, 8.8, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:48', '2023-06-16'),
(3089, 7755139003093, 702, 'Gloria Pote con sal', 9.19, 9.2, NULL, NULL, 0, 3, 2, 0, '2023-06-16 15:49:48', '2023-06-16'),
(3090, 7755139003094, 700, 'Deleite 1L', 9.8, 9.5, NULL, NULL, 0, 4, 2, 0, '2023-06-16 15:49:48', '2023-06-16'),
(3091, 7755139003095, 700, 'Sao 1L', 12.1, 12.1, NULL, NULL, 0, 3, 1, 0, '2023-06-16 15:49:49', '2023-06-16'),
(3092, 7755139003096, 700, 'Cocinero 1L', 12.4, 12.4, NULL, NULL, 0, 3, 1, 0, '2023-06-16 15:49:49', '2023-06-16'),
(3093, 7755139003097, 698, 'Paisana extra 5k', 18.29, 20, NULL, NULL, 0, 1, 0, 0, '2023-06-16 15:49:49', '2023-06-16'),
(3094, 7755139003098, 699, 'Gloria Fresa 500ml', 3.79, 5, NULL, NULL, 0, 6, 3, 0, '2023-06-16 15:49:49', '2023-06-16'),
(3095, 7755139003099, 697, 'Gloria evaporada ligth 400g', 3.4, 5, NULL, NULL, 0, 24, 12, 0, '2023-06-16 15:49:49', '2023-06-16'),
(3096, 7755139003100, 691, 'soda san jorge 40g', 0.5, 0.8, NULL, NULL, 0, 0, 0, 0, '2023-06-16 15:49:49', '2023-06-16'),
(3097, 7755139003101, 691, 'vainilla field 37g', 0.33, 0.5, NULL, NULL, 0, 24, 10, 0, '2023-06-16 15:49:49', '2023-06-16'),
(3098, 7755139003102, 691, 'Margarita', 0.53, 0.6, NULL, NULL, 0, 12, 6, 0, '2023-06-16 15:49:49', '2023-06-16'),
(3099, 7755139003103, 691, 'soda field 34g', 0.37, 0.6, NULL, NULL, 0, 18, 5, 0, '2023-06-16 15:49:49', '2023-06-16'),
(3100, 7755139003104, 691, 'ritz original', 0.43, 0.7, NULL, NULL, 0, 24, 10, 0, '2023-06-16 15:49:49', '2023-06-16'),
(3101, 7755139003105, 691, 'ritz queso 34g', 0.68, 0.8, NULL, NULL, 0, 18, 5, 0, '2023-06-16 15:49:49', '2023-06-16'),
(3102, 7755139003106, 691, 'Chocobum', 0.62, 0.8, NULL, NULL, 0, 18, 9, 0, '2023-06-16 15:49:49', '2023-06-16'),
(3103, 7755139003107, 691, 'Picaras', 0.6, 0.8, NULL, NULL, 0, 24, 12, 0, '2023-06-16 15:49:49', '2023-06-16'),
(3104, 7755139003108, 691, 'oreo original 36g', 0.57, 0.8, NULL, NULL, 0, 30, 10, 0, '2023-06-16 15:49:49', '2023-06-16');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuarios`
--

CREATE TABLE `usuarios` (
  `id_usuario` int(11) NOT NULL,
  `nombre_usuario` varchar(100) DEFAULT NULL,
  `apellido_usuario` varchar(100) DEFAULT NULL,
  `usuario` varchar(100) DEFAULT NULL,
  `clave` text DEFAULT NULL,
  `id_perfil_usuario` int(11) DEFAULT NULL,
  `estado` tinyint(4) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `usuarios`
--

INSERT INTO `usuarios` (`id_usuario`, `nombre_usuario`, `apellido_usuario`, `usuario`, `clave`, `id_perfil_usuario`, `estado`) VALUES
(1, 'Anallely', 'Mendoza', 'any', '@globarte1', 1, 1),
(2, 'Emplead@', 'Glob - Arte', 'emp', 'glob@rte1', 2, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `venta_cabecera`
--

CREATE TABLE `venta_cabecera` (
  `id_boleta` int(11) NOT NULL,
  `nro_boleta` varchar(8) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `subtotal` float NOT NULL,
  `igv` float NOT NULL,
  `total_venta` float DEFAULT NULL,
  `fecha_venta` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `venta_cabecera`
--

INSERT INTO `venta_cabecera` (`id_boleta`, `nro_boleta`, `descripcion`, `subtotal`, `igv`, `total_venta`, `fecha_venta`) VALUES
(91, '00000001', 'Venta realizada con Nro Boleta: 00000001', 0, 0, 10, '2023-06-16 15:50:32'),
(92, '00000002', 'Venta realizada con Nro Boleta: 00000002', 0, 0, 15, '2023-06-16 16:44:02');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `venta_detalle`
--

CREATE TABLE `venta_detalle` (
  `id` int(11) NOT NULL,
  `nro_boleta` varchar(8) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `codigo_producto` bigint(20) NOT NULL,
  `cantidad` float NOT NULL,
  `total_venta` float NOT NULL,
  `fecha_venta` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `venta_detalle`
--

INSERT INTO `venta_detalle` (`id`, `nro_boleta`, `codigo_producto`, `cantidad`, `total_venta`, `fecha_venta`) VALUES
(686, '00000001', 7755139002810, 2, 10, '2023-06-16 15:50:32'),
(687, '00000002', 7755139002810, 3, 15, '2023-06-16 16:44:02');

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `categorias`
--
ALTER TABLE `categorias`
  ADD PRIMARY KEY (`id_categoria`);

--
-- Indices de la tabla `empresa`
--
ALTER TABLE `empresa`
  ADD PRIMARY KEY (`id_empresa`);

--
-- Indices de la tabla `modulos`
--
ALTER TABLE `modulos`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `perfiles`
--
ALTER TABLE `perfiles`
  ADD PRIMARY KEY (`id_perfil`);

--
-- Indices de la tabla `perfil_modulo`
--
ALTER TABLE `perfil_modulo`
  ADD PRIMARY KEY (`idperfil_modulo`),
  ADD KEY `id_perfil` (`id_perfil`),
  ADD KEY `id_modulo` (`id_modulo`);

--
-- Indices de la tabla `productos`
--
ALTER TABLE `productos`
  ADD PRIMARY KEY (`id`,`codigo_producto`);

--
-- Indices de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD PRIMARY KEY (`id_usuario`),
  ADD KEY `id_perfil_usuario` (`id_perfil_usuario`);

--
-- Indices de la tabla `venta_cabecera`
--
ALTER TABLE `venta_cabecera`
  ADD PRIMARY KEY (`id_boleta`);

--
-- Indices de la tabla `venta_detalle`
--
ALTER TABLE `venta_detalle`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `categorias`
--
ALTER TABLE `categorias`
  MODIFY `id_categoria` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=710;

--
-- AUTO_INCREMENT de la tabla `empresa`
--
ALTER TABLE `empresa`
  MODIFY `id_empresa` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `modulos`
--
ALTER TABLE `modulos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT de la tabla `perfiles`
--
ALTER TABLE `perfiles`
  MODIFY `id_perfil` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `perfil_modulo`
--
ALTER TABLE `perfil_modulo`
  MODIFY `idperfil_modulo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=138;

--
-- AUTO_INCREMENT de la tabla `productos`
--
ALTER TABLE `productos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3105;

--
-- AUTO_INCREMENT de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  MODIFY `id_usuario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `venta_cabecera`
--
ALTER TABLE `venta_cabecera`
  MODIFY `id_boleta` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=93;

--
-- AUTO_INCREMENT de la tabla `venta_detalle`
--
ALTER TABLE `venta_detalle`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=688;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `perfil_modulo`
--
ALTER TABLE `perfil_modulo`
  ADD CONSTRAINT `id_modulo` FOREIGN KEY (`id_modulo`) REFERENCES `modulos` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `id_perfil` FOREIGN KEY (`id_perfil`) REFERENCES `perfiles` (`id_perfil`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD CONSTRAINT `usuarios_ibfk_1` FOREIGN KEY (`id_perfil_usuario`) REFERENCES `perfiles` (`id_perfil`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
