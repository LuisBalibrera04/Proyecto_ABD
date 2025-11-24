-- Proyecto de catedra: GimnasioReserva --

-- 1. Preparación de la Base de Datos.

-- Creando base de datos.

CREATE DATABASE GimnasioReservas
CONTAINMENT = PARTIAL;

USE GimnasioReservas;

-- 2. Creando esquemas.

CREATE SCHEMA Negocio;
CREATE SCHEMA Auditoria;
CREATE SCHEMA Reportes;
CREATE SCHEMA Config;

-- Creando tablas principales.

-- Tabla: SOCIO
CREATE TABLE Negocio.SOCIO (
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
CREATE TABLE Negocio.MEMBRESIA (
    id INT IDENTITY(1,1) PRIMARY KEY,
    tipo NVARCHAR(50) NOT NULL CHECK (tipo IN ('Básica', 'Premium', 'VIP')),
    duracion NVARCHAR(20) NOT NULL CHECK (duracion IN ('Mensual', 'Trimestral', 'Anual')),
    precio DECIMAL(10,2) NOT NULL CHECK (precio > 0),
    CONSTRAINT UQ_MEMBRESIA_TIPO_DURACION UNIQUE (tipo, duracion)
);

-- Tabla: ENTRENADOR
CREATE TABLE Negocio.ENTRENADOR (
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
CREATE TABLE Negocio.FACTURA (
    id INT IDENTITY(1,1) PRIMARY KEY,
    metodo_pago NVARCHAR(50) NOT NULL CHECK (metodo_pago IN ('efectivo', 'tarjeta', 'transferencia')),
    monto DECIMAL(10,2) NOT NULL CHECK (monto > 0),
    fecha_pago DATETIME NOT NULL DEFAULT GETDATE(),
    id_socio INT NOT NULL,
    id_membresia INT NOT NULL,
    CONSTRAINT FK_FACTURA_SOCIO FOREIGN KEY (id_socio) REFERENCES Negocio.SOCIO(id) ON DELETE CASCADE,
    CONSTRAINT FK_FACTURA_MEMBRESIA FOREIGN KEY (id_membresia) REFERENCES Negocio.MEMBRESIA(id) ON DELETE CASCADE
);

-- Tabla: CLASE
CREATE TABLE Negocio.CLASE (
    id INT IDENTITY(1,1) PRIMARY KEY,
    tipo NVARCHAR(50) NOT NULL,
    horario TIME NOT NULL,
    duracion_minutos INT NOT NULL CHECK (duracion_minutos BETWEEN 30 AND 120),
    cupo INT NOT NULL CHECK (cupo > 0),
    id_entrenador INT NOT NULL,
    CONSTRAINT FK_CLASE_ENTRENADOR FOREIGN KEY (id_entrenador) REFERENCES Negocio.ENTRENADOR(id) ON DELETE CASCADE
);

-- Tabla: RESERVA
CREATE TABLE Negocio.RESERVA (
    id INT IDENTITY(1,1) PRIMARY KEY,
    fecha_reserva DATE NOT NULL DEFAULT GETDATE(),
    fecha_clase DATE NOT NULL,
    id_socio INT NOT NULL,
    id_clase INT NOT NULL,
    CONSTRAINT FK_RESERVA_SOCIO FOREIGN KEY (id_socio) REFERENCES Negocio.SOCIO(id) ON DELETE CASCADE,
    CONSTRAINT FK_RESERVA_CLASE FOREIGN KEY (id_clase) REFERENCES Negocio.CLASE(id),
    CONSTRAINT UQ_RESERVA_SOCIO_CLASE_FECHA UNIQUE (id_socio, id_clase, fecha_clase),
    CONSTRAINT CK_RESERVA_FECHAS CHECK (fecha_clase >= fecha_reserva)
);

-- Creando tablas de auditoria.

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