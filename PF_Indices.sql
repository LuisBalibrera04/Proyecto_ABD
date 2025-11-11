USE GimnasioReservas;
GO

-- =====================================================
-- ÍNDICES PARA TABLA SOCIO
-- =====================================================

-- Índice para búsquedas por email
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_SOCIO_Email' AND object_id = OBJECT_ID('dbo.SOCIO'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_SOCIO_Email
    ON dbo.SOCIO(email)
    INCLUDE (nombre, telefono, estado);
END
GO

-- Índice para búsquedas por estado y fecha de registro
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_SOCIO_Estado_FechaRegistro' AND object_id = OBJECT_ID('dbo.SOCIO'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_SOCIO_Estado_FechaRegistro
    ON dbo.SOCIO(estado, fecha_registro DESC)
    INCLUDE (nombre, email);
END
GO

-- =====================================================
-- ÍNDICES PARA TABLA MEMBRESIA
-- =====================================================

-- Índice filtrado para membresías activas
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_MEMBRESIA_Estado' AND object_id = OBJECT_ID('dbo.MEMBRESIA'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_MEMBRESIA_Estado
    ON dbo.MEMBRESIA(estado)
    WHERE estado = 'activa';
END
GO

-- =====================================================
-- ÍNDICES PARA TABLA ENTRENADOR
-- =====================================================

-- Índice para búsquedas por especialidad
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_ENTRENADOR_Especialidad' AND object_id = OBJECT_ID('dbo.ENTRENADOR'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_ENTRENADOR_Especialidad
    ON dbo.ENTRENADOR(especialidad)
    INCLUDE (nombre, email);
END
GO

-- Índice para entrenadores activos (sin fecha final)
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_ENTRENADOR_Activos' AND object_id = OBJECT_ID('dbo.ENTRENADOR'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_ENTRENADOR_Activos
    ON dbo.ENTRENADOR(fecha_final_inscripcion)
    WHERE fecha_final_inscripcion IS NULL;
END
GO

-- =====================================================
-- ÍNDICES PARA TABLA CLASE
-- =====================================================

-- Índice para búsquedas por tipo y horario
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_CLASE_Tipo_Horario' AND object_id = OBJECT_ID('dbo.CLASE'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_CLASE_Tipo_Horario
    ON dbo.CLASE(tipo, horario)
    INCLUDE (duracion_minutos, cupo, id_entrenador);
END
GO

-- Índice para búsquedas por entrenador
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_CLASE_Entrenador' AND object_id = OBJECT_ID('dbo.CLASE'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_CLASE_Entrenador
    ON dbo.CLASE(id_entrenador)
    INCLUDE (tipo, horario, cupo);
END
GO

-- =====================================================
-- ÍNDICES PARA TABLA FACTURA
-- =====================================================

-- Índice para búsquedas por socio y fecha de pago
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_FACTURA_Socio_FechaPago' AND object_id = OBJECT_ID('dbo.FACTURA'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_FACTURA_Socio_FechaPago
    ON dbo.FACTURA(id_socio, fecha_pago DESC)
    INCLUDE (monto, metodo_pago, id_membresia);
END
GO

-- Índice para reportes por método de pago
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_FACTURA_MetodoPago' AND object_id = OBJECT_ID('dbo.FACTURA'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_FACTURA_MetodoPago
    ON dbo.FACTURA(metodo_pago, fecha_pago DESC)
    INCLUDE (monto);
END
GO

-- =====================================================
-- ÍNDICES PARA TABLA RESERVA
-- =====================================================

-- Índice para búsquedas por socio y fecha de clase
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_RESERVA_Socio_FechaClase' AND object_id = OBJECT_ID('dbo.RESERVA'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_RESERVA_Socio_FechaClase
    ON dbo.RESERVA(id_socio, fecha_clase DESC)
    INCLUDE (id_clase, fecha_reserva);
END
GO

-- Índice para búsquedas por clase
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_RESERVA_Clase_FechaClase' AND object_id = OBJECT_ID('dbo.RESERVA'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_RESERVA_Clase_FechaClase
    ON dbo.RESERVA(id_clase, fecha_clase)
    INCLUDE (id_socio);
END
GO

-- Índice filtrado para reservas futuras
IF NOT EXISTS (
    SELECT * 
    FROM sys.indexes 
    WHERE name = 'IX_RESERVA_FechasFuturas' 
      AND object_id = OBJECT_ID('dbo.RESERVA')
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_RESERVA_FechasFuturas
    ON dbo.RESERVA(fecha_clase);
END
GO


-- =====================================================
-- ACTUALIZAR ESTADÍSTICAS
-- =====================================================

UPDATE STATISTICS dbo.SOCIO WITH FULLSCAN;
UPDATE STATISTICS dbo.MEMBRESIA WITH FULLSCAN;
UPDATE STATISTICS dbo.ENTRENADOR WITH FULLSCAN;
UPDATE STATISTICS dbo.CLASE WITH FULLSCAN;
UPDATE STATISTICS dbo.FACTURA WITH FULLSCAN;
UPDATE STATISTICS dbo.RESERVA WITH FULLSCAN;
GO

