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
