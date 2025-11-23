
USE GimnasioReservas;

-- FUNCIÓN VENTANA 1: RANKING DE SOCIOS POR GASTO TOTAL

SELECT
    s.nombre,
    SUM(f.monto) AS gasto_total,
    RANK() OVER (ORDER BY SUM(f.monto) DESC) AS ranking_gasto,
    SUM(SUM(f.monto)) OVER (ORDER BY SUM(f.monto) DESC) /
        SUM(SUM(f.monto)) OVER () * 100 AS porcentaje_acumulado
FROM SOCIO s
INNER JOIN FACTURA f ON s.id = f.id_socio
GROUP BY s.id, s.nombre, s.email, s.estado
ORDER BY gasto_total DESC;

-- ÍNDICES PARA OPTIMIZAR FUNCIÓN VENTANA 1

-- Índice compuesto para JOIN entre SOCIO y FACTURA

CREATE NONCLUSTERED INDEX IX_FACTURA_Socio_Monto
ON dbo.FACTURA(id_socio, monto)
INCLUDE (id, fecha_pago);


-- Índice para filtrar socios por estado

CREATE NONCLUSTERED INDEX IX_SOCIO_Estado_Nombre
ON dbo.SOCIO(estado, nombre)
INCLUDE (id, email);


-- FUNCIÓN VENTANA 2: ANÁLISIS DE OCUPACIÓN DE CLASES

SELECT
    c.tipo AS nombre_clase,
    e.especialidad,
    COUNT(r.id) AS total_reservas,
    CAST(COUNT(r.id) AS DECIMAL(10,2)) / c.cupo * 100 AS porcentaje_ocupacion,
    RANK() OVER (PARTITION BY e.especialidad ORDER BY COUNT(r.id) DESC) AS ranking_por_especialidad,
    COUNT(r.id) - AVG(COUNT(r.id)) OVER (PARTITION BY e.especialidad) AS diferencia_vs_promedio,
    CASE
        WHEN COUNT(r.id) >= c.cupo THEN 'LLENO'
        WHEN CAST(COUNT(r.id) AS DECIMAL(10,2)) / c.cupo >= 0.90 THEN 'CASI LLENO'
        ELSE 'DISPONIBLE/BAJA DEMANDA'
    END AS estado_visual
FROM CLASE c
INNER JOIN ENTRENADOR e ON c.id_entrenador = e.id
LEFT JOIN RESERVA r ON c.id = r.id_clase
GROUP BY c.id, c.tipo, c.cupo, e.nombre, e.especialidad
ORDER BY e.especialidad, porcentaje_ocupacion DESC;

-- ÍNDICES PARA OPTIMIZAR FUNCIÓN VENTANA 2

-- Índice para JOIN entre CLASE y RESERVA

CREATE NONCLUSTERED INDEX IX_RESERVA_Clase_FechaClase_Opt
ON dbo.RESERVA(id_clase, fecha_clase)
INCLUDE (id, id_socio);


-- Índice para CLASE con especialidad del entrenador

CREATE NONCLUSTERED INDEX IX_CLASE_Entrenador_Tipo
ON dbo.CLASE(id_entrenador, tipo, horario)
INCLUDE (cupo);


-- Índice para ENTRENADOR especialidad

CREATE NONCLUSTERED INDEX IX_ENTRENADOR_Especialidad_Opt
ON dbo.ENTRENADOR(especialidad)
INCLUDE (id, nombre, email);


-- FUNCIÓN VENTANA 3: ANÁLISIS TEMPORAL DE INGRESOS

WITH IngresosMensuales AS (
    SELECT
        YEAR(fecha_pago) AS anio,
        MONTH(fecha_pago) AS mes,
        SUM(monto) AS ingreso_mensual
    FROM FACTURA
    GROUP BY YEAR(fecha_pago), MONTH(fecha_pago)
)
SELECT
    anio,
    mes,
    ingreso_mensual,
    SUM(ingreso_mensual) OVER (
        PARTITION BY anio
        ORDER BY mes ROWS UNBOUNDED PRECEDING
    ) AS ingreso_acumulado_anio,
    ISNULL(
        (ingreso_mensual - LAG(ingreso_mensual, 1) OVER (ORDER BY anio, mes)) / 
        LAG(ingreso_mensual, 1) OVER (ORDER BY anio, mes) * 100
    , 0) AS crecimiento_porcentual,
    AVG(ingreso_mensual) OVER (
        ORDER BY anio, mes
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS promedio_movil_3meses
FROM IngresosMensuales
ORDER BY anio DESC, mes DESC;

-- ÍNDICES PARA OPTIMIZAR FUNCIÓN VENTANA 3

-- Índice para análisis temporal de facturas

CREATE NONCLUSTERED INDEX IX_FACTURA_FechaPago_Monto_Opt
ON dbo.FACTURA(fecha_pago, monto)
INCLUDE (id, metodo_pago);


-- Índice para agrupaciones por año/mes

CREATE NONCLUSTERED INDEX IX_FACTURA_AnioMes
ON dbo.FACTURA(fecha_pago)
INCLUDE (monto, id);


-- ACTUALIZAR ESTADÍSTICAS DESPUÉS DE CREAR ÍNDICES
UPDATE STATISTICS dbo.SOCIO WITH FULLSCAN;
UPDATE STATISTICS dbo.FACTURA WITH FULLSCAN;
UPDATE STATISTICS dbo.CLASE WITH FULLSCAN;
UPDATE STATISTICS dbo.ENTRENADOR WITH FULLSCAN;
UPDATE STATISTICS dbo.RESERVA WITH FULLSCAN;