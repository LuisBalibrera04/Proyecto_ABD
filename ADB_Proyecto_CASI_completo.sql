-- =====================================================
-- 1. CREAR BASE DE DATOS
-- =====================================================
CREATE DATABASE GimnasioReservas
CONTAINMENT = PARTIAL;
GO

USE GimnasioReservas;
GO

-- =====================================================
-- 2. CREAR TABLAS
-- =====================================================

-- Tabla: SOCIO
CREATE TABLE SOCIO (
    id INT IDENTITY(1,1) PRIMARY KEY,
    nombre NVARCHAR(100) NOT NULL,
    telefono NVARCHAR(20) NOT NULL,
    email NVARCHAR(100) NOT NULL UNIQUE,
    genero CHAR(1) NOT NULL CHECK (genero IN ('M', 'F')),
    fecha_registro DATE NOT NULL DEFAULT GETDATE(),
    estado NVARCHAR(20) NOT NULL DEFAULT 'activo' CHECK (estado IN ('activo', 'inactivo')),
    dui NVARCHAR(10) UNIQUE
);

-- Tabla: MEMBRESIA

CREATE TABLE MEMBRESIA (
    id INT IDENTITY(1,1) PRIMARY KEY,
    tipo NVARCHAR(50) NOT NULL CHECK (tipo IN ('Básica', 'Premium', 'VIP')),
    duracion NVARCHAR(20) NOT NULL CHECK (duracion IN ('Mensual', 'Trimestral', 'Anual')),
    precio DECIMAL(10,2) NOT NULL CHECK (precio > 0),
    CONSTRAINT UQ_MEMBRESIA_TIPO_DURACION UNIQUE (tipo, duracion)
);

-- Tabla: ENTRENADOR

CREATE TABLE ENTRENADOR (
    id INT IDENTITY(1,1) PRIMARY KEY,
    nombre NVARCHAR(100) NOT NULL,
    telefono NVARCHAR(20) NOT NULL,
    email NVARCHAR(100) NOT NULL UNIQUE,
    fecha_inicio_inscripcion DATE NOT NULL,
    fecha_final_inscripcion DATE NULL,
    salario DECIMAL(10,2) NOT NULL CHECK (salario > 0),
    especialidad NVARCHAR(100) NOT NULL CHECK (especialidad IN ('Yoga', 'Spinning', 'CrossFit', 'Musculación', 'Calistenia','Pilates'))
);

-- Tabla: FACTURA
CREATE TABLE FACTURA (
    id INT IDENTITY(1,1) PRIMARY KEY,
    metodo_pago NVARCHAR(50) NOT NULL CHECK (metodo_pago IN ('efectivo', 'tarjeta', 'transferencia')),
    monto DECIMAL(10,2) NOT NULL CHECK (monto > 0),
    fecha_pago DATETIME NOT NULL DEFAULT GETDATE(),
    id_socio INT NOT NULL,
    id_membresia INT NOT NULL,
    CONSTRAINT FK_FACTURA_SOCIO FOREIGN KEY (id_socio) REFERENCES SOCIO(id) ON DELETE CASCADE,
    CONSTRAINT FK_FACTURA_MEMBRESIA FOREIGN KEY (id_membresia) REFERENCES MEMBRESIA(id) ON DELETE CASCADE
);


-- Tabla: CLASE
CREATE TABLE CLASE (
    id INT IDENTITY(1,1) PRIMARY KEY,
    tipo NVARCHAR(50) NOT NULL,
    horario TIME NOT NULL,
    duracion_minutos INT NOT NULL CHECK (duracion_minutos BETWEEN 30 AND 120),
    cupo INT NOT NULL CHECK (cupo > 0),
    id_entrenador INT NOT NULL,
    CONSTRAINT FK_CLASE_ENTRENADOR FOREIGN KEY (id_entrenador) REFERENCES ENTRENADOR(id) ON DELETE CASCADE
);

-- Tabla: RESERVA
CREATE TABLE RESERVA (
    id INT IDENTITY(1,1) PRIMARY KEY,
    fecha_reserva DATE NOT NULL DEFAULT GETDATE(),
    fecha_clase DATE NOT NULL,
    id_socio INT NOT NULL,
    id_clase INT NOT NULL,
    CONSTRAINT FK_RESERVA_SOCIO FOREIGN KEY (id_socio) REFERENCES SOCIO(id) ON DELETE CASCADE,
    CONSTRAINT FK_RESERVA_CLASE FOREIGN KEY (id_clase) REFERENCES CLASE(id),
    CONSTRAINT UQ_RESERVA_SOCIO_CLASE_FECHA UNIQUE (id_socio, id_clase, fecha_clase),
    CONSTRAINT CK_RESERVA_FECHAS CHECK (fecha_clase >= fecha_reserva)
);

-- =====================================================
-- 3. CREAR USUARIOS
-- =====================================================

-- Usuario 1: Asistente Administrativo
CREATE USER U_Asistente WITH PASSWORD = 'Admin@ABD25';

-- Usuario 2: Contabilidad
CREATE USER U_Contabilidad WITH PASSWORD = 'Contabilidad@ABD25';

-- Usuario 3: Solo Lectura
CREATE USER U_Lector WITH PASSWORD = 'Lectura@ABD25';

-- Usuario 4: Solo Backups
CREATE USER U_Respaldos WITH PASSWORD = 'Backups@ABD25';

-- =====================================================
-- 4. CREAR ROLES Y ASIGNAR PERMISOS
-- =====================================================

-- Rol 1: Asistente Administrativo
-- Registrar nuevos socios, ver facturas y membresías, y reservar
CREATE ROLE R_Asistente_Administrativo;
GRANT SELECT, INSERT, UPDATE, DELETE ON SOCIO TO R_Asistente_Administrativo;
GRANT SELECT ON FACTURA TO R_Asistente_Administrativo;
GRANT SELECT ON MEMBRESIA TO R_Asistente_Administrativo;
GRANT SELECT, INSERT, UPDATE, DELETE ON RESERVA TO R_Asistente_Administrativo;
GRANT SELECT ON CLASE TO R_Asistente_Administrativo;
ALTER ROLE R_Asistente_Administrativo ADD MEMBER U_Asistente;

-- Rol 2: Contabilidad
-- Solo acceso a SOCIO y FACTURA (lectura y escritura)
CREATE ROLE R_Contabilidad;
GRANT SELECT, INSERT, UPDATE, DELETE ON SOCIO TO R_Contabilidad;
GRANT SELECT, INSERT, UPDATE, DELETE ON FACTURA TO R_Contabilidad;
ALTER ROLE R_Contabilidad ADD MEMBER U_Contabilidad;

-- Rol 3: Solo Lectura
-- Acceso de solo lectura a todas las tablas
CREATE ROLE R_Lector;
GRANT SELECT ON SCHEMA::dbo TO R_Lector;
ALTER ROLE R_Lector ADD MEMBER U_Lector;

-- Rol 4: Solo Backups
-- Permisos de backup de la base de datos
ALTER ROLE db_backupoperator ADD MEMBER U_Respaldos;

USE GimnasioReservas;
GO

-- =====================================================
-- 5. FUNCIONES VENTANA
-- =====================================================

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

-- ?NDICE PARA OPTIMIZAR FUNCI?N VENTANA 1
-- ?ndice compuesto para JOIN entre SOCIO y FACTURA
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_FACTURA_Socio_Monto' AND object_id = OBJECT_ID('dbo.FACTURA'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_FACTURA_Socio_Monto
    ON dbo.FACTURA(id_socio, monto)
    INCLUDE (id, fecha_pago);
END
GO

-- ?ndice para filtrar socios por estado
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_SOCIO_Estado_Nombre' AND object_id = OBJECT_ID('dbo.SOCIO'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_SOCIO_Estado_Nombre
    ON dbo.SOCIO(estado, nombre)
    INCLUDE (id, email);
END
GO

-- FUNCI?N VENTANA 2: AN?LISIS DE OCUPACI?N DE CLASES
-- Caso de uso: Analizar qu? clases tienen mayor demanda y cu?les necesitan promoci?n
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
    
    -- Ranking de clases m?s populares por especialidad
    RANK() OVER (PARTITION BY e.especialidad ORDER BY COUNT(r.id) DESC) AS ranking_por_especialidad,
    
    -- Promedio m?vil de reservas por especialidad
    AVG(COUNT(r.id)) OVER (
        PARTITION BY e.especialidad 
        ORDER BY c.horario
        ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
    ) AS promedio_movil_reservas,
    
    -- Comparaci?n con promedio de la especialidad
    COUNT(r.id) - AVG(COUNT(r.id)) OVER (PARTITION BY e.especialidad) AS diferencia_vs_promedio,
    
    -- Percentil de ocupaci?n dentro de la especialidad
    PERCENT_RANK() OVER (PARTITION BY e.especialidad ORDER BY COUNT(r.id)) * 100 AS percentil_ocupacion,
    
    -- EXTRA: Indicador visual de estado
    CASE 
        WHEN COUNT(r.id) >= c.cupo THEN ' LLENO'
        WHEN CAST(COUNT(r.id) AS DECIMAL(10,2)) / c.cupo >= 0.90 THEN 'CASI LLENO'
        WHEN CAST(COUNT(r.id) AS DECIMAL(10,2)) / c.cupo >= 0.70 THEN 'DISPONIBLE'
        WHEN CAST(COUNT(r.id) AS DECIMAL(10,2)) / c.cupo >= 0.50 THEN ' MEDIA OCUPACI?N'
        ELSE 'BAJA DEMANDA'
    END AS estado_visual
    
FROM CLASE c
INNER JOIN ENTRENADOR e ON c.id_entrenador = e.id
LEFT JOIN RESERVA r ON c.id = r.id_clase
GROUP BY c.id, c.tipo, c.horario, c.cupo, e.nombre, e.especialidad
ORDER BY e.especialidad, porcentaje_ocupacion DESC;
GO



-- ?NDICES PARA OPTIMIZAR FUNCI?N VENTANA 2
-- ?ndice para JOIN entre CLASE y RESERVA
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_RESERVA_Clase_FechaClase_Opt' AND object_id = OBJECT_ID('dbo.RESERVA'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_RESERVA_Clase_FechaClase_Opt
    ON dbo.RESERVA(id_clase, fecha_clase)
    INCLUDE (id, id_socio);
END
GO

-- ?ndice para CLASE con especialidad del entrenador
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_CLASE_Entrenador_Tipo' AND object_id = OBJECT_ID('dbo.CLASE'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_CLASE_Entrenador_Tipo
    ON dbo.CLASE(id_entrenador, tipo, horario)
    INCLUDE (cupo);
END
GO

-- ?ndice para ENTRENADOR especialidad
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_ENTRENADOR_Especialidad_Opt' AND object_id = OBJECT_ID('dbo.ENTRENADOR'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_ENTRENADOR_Especialidad_Opt
    ON dbo.ENTRENADOR(especialidad)
    INCLUDE (id, nombre, email);
END
GO


-- FUNCI?N VENTANA 3: AN?LISIS TEMPORAL DE INGRESOS
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
    -- Ingreso acumulado del a?o
    SUM(ingreso_mensual) OVER (
        PARTITION BY anio 
        ORDER BY mes
        ROWS UNBOUNDED PRECEDING
    ) AS ingreso_acumulado_anio,
    -- Comparaci?n con mes anterior (NULL = 0)
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
    -- Promedio m?vil de 3 meses
    AVG(ingreso_mensual) OVER (
        ORDER BY anio, mes
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS promedio_movil_3meses,
    -- Ranking de mejores meses
    RANK() OVER (ORDER BY ingreso_mensual DESC) AS ranking_mejor_mes,
    -- Comparaci?n con mismo mes del a?o anterior (NULL = 0)
    ISNULL(ingreso_mensual - LAG(ingreso_mensual, 12) OVER (ORDER BY anio, mes), 0) AS vs_mismo_mes_anio_anterior,
    -- Percentil del mes dentro de todos los meses
    PERCENT_RANK() OVER (ORDER BY ingreso_mensual) * 100 AS percentil_ingreso
FROM IngresosMensuales
ORDER BY anio DESC, mes DESC;

-- ?NDICES PARA OPTIMIZAR FUNCI?N VENTANA 3
-- ?ndice para an?lisis temporal de facturas
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_FACTURA_FechaPago_Monto_Opt' AND object_id = OBJECT_ID('dbo.FACTURA'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_FACTURA_FechaPago_Monto_Opt
    ON dbo.FACTURA(fecha_pago, monto)
    INCLUDE (id, metodo_pago);
END
GO

-- ?ndice adicional para agrupaciones por a?o/mes
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_FACTURA_AnioMes' AND object_id = OBJECT_ID('dbo.FACTURA'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_FACTURA_AnioMes
    ON dbo.FACTURA(fecha_pago)
    INCLUDE (monto, id);
END
GO

-- ACTUALIZAR ESTAD?STICAS DESPU?S DE CREAR ?NDICES
UPDATE STATISTICS dbo.SOCIO WITH FULLSCAN;
UPDATE STATISTICS dbo.FACTURA WITH FULLSCAN;
UPDATE STATISTICS dbo.CLASE WITH FULLSCAN;
UPDATE STATISTICS dbo.ENTRENADOR WITH FULLSCAN;
UPDATE STATISTICS dbo.RESERVA WITH FULLSCAN;
GO

-- =====================================================
-- 6. Plan de Backup
-- =====================================================

--FULL backup
ALTER DATABASE GimnasioReservas SET RECOVERY FULL;

BACKUP DATABASE GimnasioReservas
TO DISK = 'C:\Backups\Gym_Full.bak'
WITH COMPRESSION, NAME = 'GimnasioReserva full backup', INIT;

--LOG backup
BACKUP LOG GimnasioReservas
TO DISK = 'C:\Backups\Gym_Cadena.trn'
WITH NOINIT;

--Unico usuario
ALTER DATABASE GimnasioReservas
SET SINGLE_USER 
WITH ROLLBACK IMMEDIATE;

-- 1. FULL
RESTORE DATABASE GimnasioReservas
FROM DISK = 'C:\Backups\Gym_Full.bak' WITH REPLACE, NORECOVERY;

-- 2. LOGs
RESTORE LOG GimnasioReservas
FROM DISK = 'C:\Backups\Gym_Cadena.trn' WITH RECOVERY;

--Vuelvo a multiusario
ALTER DATABASE GimnasioReservas
SET MULTI_USER;

SELECT name FROM sys.databases;

SELECT name, state_desc
FROM sys.databases
WHERE name = 'GimnasioReservas';

EXEC Config.sp_ObtenerDimensionamientoTablas