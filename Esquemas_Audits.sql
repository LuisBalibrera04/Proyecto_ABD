CREATE SCHEMA Negocio;
GO

CREATE SCHEMA Auditoria;
GO

CREATE SCHEMA Reportes;
GO

CREATE SCHEMA Config;
GO


CREATE TABLE Auditoria.SOCIO_Audit (
    audit_id INT IDENTITY(1,1) PRIMARY KEY,
    id_socio INT NOT NULL,
    operacion VARCHAR(10) NOT NULL,
    nombre_anterior VARCHAR(100),
    nombre_nuevo VARCHAR(100),
    email_anterior VARCHAR(100),
    email_nuevo VARCHAR(100),
    estado_anterior VARCHAR(20),
    estado_nuevo VARCHAR(20),
    usuario VARCHAR(100) DEFAULT SYSTEM_USER,
    fecha_operacion DATETIME DEFAULT GETDATE(),
    host_name VARCHAR(100) DEFAULT HOST_NAME(),
    app_name VARCHAR(100) DEFAULT APP_NAME()
);
GO

CREATE NONCLUSTERED INDEX IX_SOCIO_Audit_Fecha
ON Auditoria.SOCIO_Audit(fecha_operacion DESC, id_socio);
GO


CREATE TABLE Auditoria.FACTURA_Audit (
    audit_id INT IDENTITY(1,1) PRIMARY KEY,
    id_factura INT NOT NULL,
    operacion VARCHAR(10) NOT NULL,
    id_socio_anterior INT,
    id_socio_nuevo INT,
    monto_anterior DECIMAL(10,2),
    monto_nuevo DECIMAL(10,2),
    metodo_pago_anterior VARCHAR(50),
    metodo_pago_nuevo VARCHAR(50),
    fecha_pago_anterior DATE,
    fecha_pago_nuevo DATE,
    usuario VARCHAR(100) DEFAULT SYSTEM_USER,
    fecha_operacion DATETIME DEFAULT GETDATE(),
    host_name VARCHAR(100) DEFAULT HOST_NAME(),
    app_name VARCHAR(100) DEFAULT APP_NAME()
);
GO

CREATE NONCLUSTERED INDEX IX_FACTURA_Audit_Fecha
ON Auditoria.FACTURA_Audit(fecha_operacion DESC, id_factura);
GO


DROP TRIGGER IF EXISTS trg_SOCIO_Insert_Audit;
GO
CREATE TRIGGER trg_SOCIO_Insert_Audit
ON dbo.SOCIO
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Auditoria.SOCIO_Audit (
        id_socio, operacion, nombre_nuevo, email_nuevo, estado_nuevo
    )
    SELECT 
        i.id, 'INSERT', i.nombre, i.email, i.estado
    FROM inserted i;
END
GO


DROP TRIGGER IF EXISTS trg_SOCIO_Update_Audit;
GO
CREATE TRIGGER trg_SOCIO_Update_Audit
ON dbo.SOCIO
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Auditoria.SOCIO_Audit (
        id_socio, operacion, 
        nombre_anterior, nombre_nuevo,
        email_anterior, email_nuevo,
        estado_anterior, estado_nuevo
    )
    SELECT 
        i.id, 'UPDATE',
        d.nombre, i.nombre,
        d.email, i.email,
        d.estado, i.estado
    FROM inserted i
    INNER JOIN deleted d ON i.id = d.id;
END
GO


DROP TRIGGER IF EXISTS trg_SOCIO_Delete_Audit;
GO
CREATE TRIGGER trg_SOCIO_Delete_Audit
ON dbo.SOCIO
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Auditoria.SOCIO_Audit (
        id_socio, operacion, nombre_anterior, email_anterior, estado_anterior
    )
    SELECT 
        d.id, 'DELETE', d.nombre, d.email, d.estado
    FROM deleted d;
END
GO


DROP TRIGGER IF EXISTS trg_FACTURA_Insert_Audit;
GO
CREATE TRIGGER trg_FACTURA_Insert_Audit
ON dbo.FACTURA
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Auditoria.FACTURA_Audit (
        id_factura, operacion, 
        id_socio_nuevo, monto_nuevo, 
        metodo_pago_nuevo, fecha_pago_nuevo
    )
    SELECT 
        i.id, 'INSERT',
        i.id_socio, i.monto, i.metodo_pago, i.fecha_pago
    FROM inserted i;
END
GO


DROP TRIGGER IF EXISTS trg_FACTURA_Update_Audit;
GO
CREATE TRIGGER trg_FACTURA_Update_Audit
ON dbo.FACTURA
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Auditoria.FACTURA_Audit (
        id_factura, operacion,
        id_socio_anterior, id_socio_nuevo,
        monto_anterior, monto_nuevo,
        metodo_pago_anterior, metodo_pago_nuevo,
        fecha_pago_anterior, fecha_pago_nuevo
    )
    SELECT 
        i.id, 'UPDATE',
        d.id_socio, i.id_socio,
        d.monto, i.monto,
        d.metodo_pago, i.metodo_pago,
        d.fecha_pago, i.fecha_pago
    FROM inserted i
    INNER JOIN deleted d ON i.id = d.id;
END
GO


DROP TRIGGER IF EXISTS trg_FACTURA_Delete_Audit;
GO
CREATE TRIGGER trg_FACTURA_Delete_Audit
ON dbo.FACTURA
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Auditoria.FACTURA_Audit (
        id_factura, operacion,
        id_socio_anterior, monto_anterior,
        metodo_pago_anterior, fecha_pago_anterior
    )
    SELECT 
        d.id, 'DELETE',
        d.id_socio, d.monto,
        d.metodo_pago, d.fecha_pago
    FROM deleted d;
END
GO


DROP VIEW IF EXISTS Auditoria.vw_Auditoria_SOCIO;
GO
CREATE VIEW Auditoria.vw_Auditoria_SOCIO
AS
SELECT 
    a.audit_id,
    a.id_socio,
    s.nombre AS nombre_actual_socio,
    a.operacion,
    a.nombre_anterior,
    a.nombre_nuevo,
    a.email_anterior,
    a.email_nuevo,
    a.estado_anterior,
    a.estado_nuevo,
    a.usuario,
    a.fecha_operacion,
    a.host_name,
    a.app_name,
    CASE 
        WHEN a.nombre_anterior != a.nombre_nuevo THEN 'Cambió nombre'
        WHEN a.email_anterior != a.email_nuevo THEN 'Cambió email'
        WHEN a.estado_anterior != a.estado_nuevo THEN 'Cambió estado'
        ELSE 'Nuevo registro'
    END AS tipo_cambio
FROM Auditoria.SOCIO_Audit a
LEFT JOIN dbo.SOCIO s ON a.id_socio = s.id;
GO


DROP VIEW IF EXISTS Auditoria.vw_Auditoria_FACTURA;
GO
CREATE VIEW Auditoria.vw_Auditoria_FACTURA
AS
SELECT 
    a.audit_id,
    a.id_factura,
    a.operacion,
    ISNULL(s_ant.nombre, 'N/A') AS socio_anterior,
    ISNULL(s_nue.nombre, 'N/A') AS socio_nuevo,
    a.monto_anterior,
    a.monto_nuevo,
    a.monto_nuevo - a.monto_anterior AS diferencia_monto,
    a.metodo_pago_anterior,
    a.metodo_pago_nuevo,
    a.fecha_pago_anterior,
    a.fecha_pago_nuevo,
    a.usuario,
    a.fecha_operacion,
    a.host_name,
    a.app_name,
    CASE 
        WHEN a.monto_anterior != a.monto_nuevo THEN 'Cambió monto'
        WHEN a.metodo_pago_anterior != a.metodo_pago_nuevo THEN 'Cambió método de pago'
        WHEN a.fecha_pago_anterior != a.fecha_pago_nuevo THEN 'Cambió fecha'
        WHEN a.id_socio_anterior != a.id_socio_nuevo THEN 'Cambió socio'
        ELSE 'Nuevo registro'
    END AS tipo_cambio
FROM Auditoria.FACTURA_Audit a
LEFT JOIN dbo.SOCIO s_ant ON a.id_socio_anterior = s_ant.id
LEFT JOIN dbo.SOCIO s_nue ON a.id_socio_nuevo = s_nue.id;
GO


DROP PROCEDURE IF EXISTS Config.sp_ObtenerDimensionamientoTablas;
GO
CREATE PROCEDURE Config.sp_ObtenerDimensionamientoTablas
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        t.name AS nombre_tabla,
        s.name AS esquema,
        p.rows AS numero_registros,
        CAST(ROUND(((SUM(a.used_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) AS espacio_usado_mb,
        CAST(ROUND(((SUM(a.total_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) AS espacio_total_mb,
        CAST(ROUND(((SUM(a.total_pages) - SUM(a.used_pages)) * 8) / 1024.00, 2) AS NUMERIC(36, 2)) AS espacio_libre_mb,
        CAST(ROUND((SUM(a.used_pages) * 8) / 1024.00 / NULLIF(p.rows, 0) * 1024, 2) AS NUMERIC(36, 2)) AS kb_por_registro
    FROM 
        sys.tables t
    INNER JOIN sys.indexes i ON t.object_id = i.object_id
    INNER JOIN sys.partitions p ON i.object_id = p.object_id AND i.index_id = p.index_id
    INNER JOIN sys.allocation_units a ON p.partition_id = a.container_id
    INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
    WHERE t.is_ms_shipped = 0
      AND i.object_id > 255
    GROUP BY t.name, s.name, p.rows
    ORDER BY espacio_usado_mb DESC;
END
GO


DROP PROCEDURE IF EXISTS Auditoria.sp_ConsultarAuditoriaSocio;
GO
CREATE PROCEDURE Auditoria.sp_ConsultarAuditoriaSocio
    @fecha_inicio DATETIME = NULL,
    @fecha_fin DATETIME = NULL,
    @id_socio INT = NULL,
    @operacion VARCHAR(10) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * 
    FROM Auditoria.vw_Auditoria_SOCIO
    WHERE 
        (@fecha_inicio IS NULL OR fecha_operacion >= @fecha_inicio)
        AND (@fecha_fin IS NULL OR fecha_operacion <= @fecha_fin)
        AND (@id_socio IS NULL OR id_socio = @id_socio)
        AND (@operacion IS NULL OR operacion = @operacion)
    ORDER BY fecha_operacion DESC;
END
GO


DROP PROCEDURE IF EXISTS Auditoria.sp_ConsultarAuditoriaFactura;
GO
CREATE PROCEDURE Auditoria.sp_ConsultarAuditoriaFactura
    @fecha_inicio DATETIME = NULL,
    @fecha_fin DATETIME = NULL,
    @id_factura INT = NULL,
    @operacion VARCHAR(10) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * 
    FROM Auditoria.vw_Auditoria_FACTURA
    WHERE 
        (@fecha_inicio IS NULL OR fecha_operacion >= @fecha_inicio)
        AND (@fecha_fin IS NULL OR fecha_operacion <= @fecha_fin)
        AND (@id_factura IS NULL OR id_factura = @id_factura)
        AND (@operacion IS NULL OR operacion = @operacion)
    ORDER BY fecha_operacion DESC;
END
GO
