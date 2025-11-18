-- =====================================================
-- 6. Plan de Backup
-- =====================================================

--FULL backup
ALTER DATABASE GimnasioReservas SET RECOVERY FULL;

BACKUP DATABASE GimnasioReservas
TO DISK = 'C:\Backups\Gym_Full.bak'
WITH COMPRESSION, NAME = 'GimnasioReserva full backup'

--Restaurar desde el backup
USE master
RESTORE DATABASE GimnasioReservas
FROM DISK = 'C:\Backups\Gym_Full.bak'
WITH REPLACE, RECOVERY;

SELECT name FROM sys.databases;