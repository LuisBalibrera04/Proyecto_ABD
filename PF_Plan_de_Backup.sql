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

-- 1. FULL
RESTORE DATABASE GimnasioReservas
FROM DISK = 'Gym_Full.bak' WITH REPLACE, NORECOVERY;

-- 2. LOGs
RESTORE LOG GimnasioReservas
FROM DISK = 'Gym_Cadena.trn' WITH RECOVERY;

SELECT name FROM sys.databases;
