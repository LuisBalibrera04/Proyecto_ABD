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
    nombre NVARCHAR(50) NOT NULL,
    duracion INT NOT NULL CHECK (duracion > 0),
    precio DECIMAL(10,2) NOT NULL CHECK (precio > 0),
    estado NVARCHAR(20) NOT NULL DEFAULT 'activa' CHECK (estado IN ('activa', 'inactiva'))
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
    especialidad NVARCHAR(100) NOT NULL
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
GO

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
GO

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