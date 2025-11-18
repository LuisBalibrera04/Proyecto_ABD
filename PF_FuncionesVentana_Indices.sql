USE GimnasioReservas;
GO

-- FUNCIÓN VENTANA 1: RANKING DE SOCIOS POR GASTO TOTAL
-- Caso de uso: Identificar los socios que más gastan para programas de fidelización
-- Muestra el ranking de socios por monto total de facturas con ventana de comparación

SELECT 
    s.id,
    s.nombre,
    s.email,
    s.estado,
    COUNT(f.id) AS total_facturas,
    SUM(f.monto) AS gasto_total,
    -- Ranking general por gasto total
    RANK() OVER (ORDER BY SUM(f.monto) DESC) AS ranking_gasto,
    -- Ranking por estado del socio
    RANK() OVER (PARTITION BY s.estado ORDER BY SUM(f.monto) DESC) AS ranking_por_estado,
    -- Porcentaje acumulado del gasto total
    SUM(SUM(f.monto)) OVER (ORDER BY SUM(f.monto) DESC) / 
        SUM(SUM(f.monto)) OVER () * 100 AS porcentaje_acumulado,
    -- Diferencia con el socio anterior en el ranking
    SUM(f.monto) - LAG(SUM(f.monto), 1) OVER (ORDER BY SUM(f.monto) DESC) AS diferencia_anterior
FROM SOCIO s
INNER JOIN FACTURA f ON s.id = f.id_socio
GROUP BY s.id, s.nombre, s.email, s.estado
ORDER BY gasto_total DESC;

-- ÍNDICE PARA OPTIMIZAR FUNCIÓN VENTANA 1
-- Índice compuesto para JOIN entre SOCIO y FACTURA
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_FACTURA_Socio_Monto' AND object_id = OBJECT_ID('dbo.FACTURA'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_FACTURA_Socio_Monto
    ON dbo.FACTURA(id_socio, monto)
    INCLUDE (id, fecha_pago);
END
GO

-- Índice para filtrar socios por estado
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_SOCIO_Estado_Nombre' AND object_id = OBJECT_ID('dbo.SOCIO'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_SOCIO_Estado_Nombre
    ON dbo.SOCIO(estado, nombre)
    INCLUDE (id, email);
END
GO

-- FUNCIÓN VENTANA 2: ANÁLISIS DE OCUPACIÓN DE CLASES
-- Caso de uso: Analizar qué clases tienen mayor demanda y cuáles necesitan promoción
-- Calcula reservas por clase con comparativas y tendencias
SELECT 
    c.id AS id_clase,
    c.tipo AS nombre_clase,
    c.horario,
    c.cupo AS capacidad_maxima,
    e.nombre AS entrenador,
    e.especialidad,
    COUNT(r.id) AS total_reservas,
    
    CASE 
        WHEN c.cupo - COUNT(r.id) < 0 THEN 0
        ELSE c.cupo - COUNT(r.id)
    END AS cupos_disponibles,
    
    CASE 
        WHEN CAST(COUNT(r.id) AS DECIMAL(10,2)) / c.cupo * 100 > 100 THEN 100.00
        ELSE CAST(COUNT(r.id) AS DECIMAL(10,2)) / c.cupo * 100
    END AS porcentaje_ocupacion,
    
    -- Ranking de clases más populares por especialidad
    RANK() OVER (PARTITION BY e.especialidad ORDER BY COUNT(r.id) DESC) AS ranking_por_especialidad,
    
    -- Promedio móvil de reservas por especialidad
    AVG(COUNT(r.id)) OVER (
        PARTITION BY e.especialidad 
        ORDER BY c.horario
        ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
    ) AS promedio_movil_reservas,
    
    -- Comparación con promedio de la especialidad
    COUNT(r.id) - AVG(COUNT(r.id)) OVER (PARTITION BY e.especialidad) AS diferencia_vs_promedio,
    
    -- Percentil de ocupación dentro de la especialidad
    PERCENT_RANK() OVER (PARTITION BY e.especialidad ORDER BY COUNT(r.id)) * 100 AS percentil_ocupacion,
    
    -- EXTRA: Indicador visual de estado
    CASE 
        WHEN COUNT(r.id) >= c.cupo THEN ' LLENO'
        WHEN CAST(COUNT(r.id) AS DECIMAL(10,2)) / c.cupo >= 0.90 THEN 'CASI LLENO'
        WHEN CAST(COUNT(r.id) AS DECIMAL(10,2)) / c.cupo >= 0.70 THEN 'DISPONIBLE'
        WHEN CAST(COUNT(r.id) AS DECIMAL(10,2)) / c.cupo >= 0.50 THEN ' MEDIA OCUPACIÓN'
        ELSE 'BAJA DEMANDA'
    END AS estado_visual
    
FROM CLASE c
INNER JOIN ENTRENADOR e ON c.id_entrenador = e.id
LEFT JOIN RESERVA r ON c.id = r.id_clase
GROUP BY c.id, c.tipo, c.horario, c.cupo, e.nombre, e.especialidad
ORDER BY e.especialidad, porcentaje_ocupacion DESC;
GO



-- ÍNDICES PARA OPTIMIZAR FUNCIÓN VENTANA 2
-- Índice para JOIN entre CLASE y RESERVA
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_RESERVA_Clase_FechaClase_Opt' AND object_id = OBJECT_ID('dbo.RESERVA'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_RESERVA_Clase_FechaClase_Opt
    ON dbo.RESERVA(id_clase, fecha_clase)
    INCLUDE (id, id_socio);
END
GO

-- Índice para CLASE con especialidad del entrenador
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_CLASE_Entrenador_Tipo' AND object_id = OBJECT_ID('dbo.CLASE'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_CLASE_Entrenador_Tipo
    ON dbo.CLASE(id_entrenador, tipo, horario)
    INCLUDE (cupo);
END
GO

-- Índice para ENTRENADOR especialidad
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_ENTRENADOR_Especialidad_Opt' AND object_id = OBJECT_ID('dbo.ENTRENADOR'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_ENTRENADOR_Especialidad_Opt
    ON dbo.ENTRENADOR(especialidad)
    INCLUDE (id, nombre, email);
END
GO


-- FUNCIÓN VENTANA 3: ANÁLISIS TEMPORAL DE INGRESOS
WITH IngresosMensuales AS (
    SELECT 
        YEAR(fecha_pago) AS anio,
        MONTH(fecha_pago) AS mes,
        DATEFROMPARTS(YEAR(fecha_pago), MONTH(fecha_pago), 1) AS fecha_mes,
        SUM(monto) AS ingreso_mensual,
        COUNT(id) AS cantidad_facturas,
        AVG(monto) AS ticket_promedio
    FROM FACTURA
    GROUP BY YEAR(fecha_pago), MONTH(fecha_pago)
)
SELECT 
    anio,
    mes,
    FORMAT(fecha_mes, 'MMMM yyyy', 'es-ES') AS periodo,
    ingreso_mensual,
    cantidad_facturas,
    ticket_promedio,
    -- Ingreso acumulado del año
    SUM(ingreso_mensual) OVER (
        PARTITION BY anio 
        ORDER BY mes
        ROWS UNBOUNDED PRECEDING
    ) AS ingreso_acumulado_anio,
    -- Comparación con mes anterior (NULL = 0)
    ISNULL(ingreso_mensual - LAG(ingreso_mensual, 1) OVER (ORDER BY anio, mes), 0) AS diferencia_mes_anterior,
    -- Porcentaje de crecimiento vs mes anterior (NULL = 0)
    ISNULL(
        CASE 
            WHEN LAG(ingreso_mensual, 1) OVER (ORDER BY anio, mes) IS NOT NULL 
            THEN ((ingreso_mensual - LAG(ingreso_mensual, 1) OVER (ORDER BY anio, mes)) / 
                  LAG(ingreso_mensual, 1) OVER (ORDER BY anio, mes)) * 100
            ELSE 0
        END
    , 0) AS crecimiento_porcentual,
    -- Promedio móvil de 3 meses
    AVG(ingreso_mensual) OVER (
        ORDER BY anio, mes
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS promedio_movil_3meses,
    -- Ranking de mejores meses
    RANK() OVER (ORDER BY ingreso_mensual DESC) AS ranking_mejor_mes,
    -- Comparación con mismo mes del año anterior (NULL = 0)
    ISNULL(ingreso_mensual - LAG(ingreso_mensual, 12) OVER (ORDER BY anio, mes), 0) AS vs_mismo_mes_anio_anterior,
    -- Percentil del mes dentro de todos los meses
    PERCENT_RANK() OVER (ORDER BY ingreso_mensual) * 100 AS percentil_ingreso
FROM IngresosMensuales
ORDER BY anio DESC, mes DESC;

-- ÍNDICES PARA OPTIMIZAR FUNCIÓN VENTANA 3
-- Índice para análisis temporal de facturas
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_FACTURA_FechaPago_Monto_Opt' AND object_id = OBJECT_ID('dbo.FACTURA'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_FACTURA_FechaPago_Monto_Opt
    ON dbo.FACTURA(fecha_pago, monto)
    INCLUDE (id, metodo_pago);
END
GO

-- Índice adicional para agrupaciones por año/mes
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_FACTURA_AnioMes' AND object_id = OBJECT_ID('dbo.FACTURA'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_FACTURA_AnioMes
    ON dbo.FACTURA(fecha_pago)
    INCLUDE (monto, id);
END
GO

-- ACTUALIZAR ESTADÍSTICAS DESPUÉS DE CREAR ÍNDICES
UPDATE STATISTICS dbo.SOCIO WITH FULLSCAN;
UPDATE STATISTICS dbo.FACTURA WITH FULLSCAN;
UPDATE STATISTICS dbo.CLASE WITH FULLSCAN;
UPDATE STATISTICS dbo.ENTRENADOR WITH FULLSCAN;
UPDATE STATISTICS dbo.RESERVA WITH FULLSCAN;
GO
