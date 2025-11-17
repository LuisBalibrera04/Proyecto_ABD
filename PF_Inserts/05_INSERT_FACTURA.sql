-- Inserciones para la tabla FACTURA (5000 registros)
-- Los id_socio van del 1 al 300
-- Los id_membresia van del 1 al 9

INSERT INTO FACTURA (metodo_pago, monto, fecha_pago, id_socio, id_membresia) VALUES
('efectivo', 25.00, '2024-01-15 10:30:00', 1, 1),
('tarjeta', 67.50, '2024-01-18 14:20:00', 2, 2),
('transferencia', 240.00, '2024-01-20 09:15:00', 3, 3),
('tarjeta', 40.00, '2024-01-22 16:45:00', 4, 4),
('efectivo', 108.00, '2024-01-25 11:00:00', 5, 5),
('transferencia', 384.00, '2024-01-28 13:30:00', 6, 6),
('tarjeta', 50.00, '2024-02-01 10:00:00', 7, 7),
('efectivo', 135.00, '2024-02-03 15:20:00', 8, 8),
('transferencia', 480.00, '2024-02-05 12:00:00', 9, 9),
('tarjeta', 25.00, '2024-02-08 09:30:00', 10, 1),
('efectivo', 67.50, '2024-02-10 14:15:00', 11, 2),
('transferencia', 240.00, '2024-02-12 11:45:00', 12, 3),
('tarjeta', 40.00, '2024-02-15 16:00:00', 13, 4),
('efectivo', 108.00, '2024-02-17 10:20:00', 14, 5),
('transferencia', 384.00, '2024-02-20 13:50:00', 15, 6),
('tarjeta', 50.00, '2024-02-22 09:00:00', 16, 7),
('efectivo', 135.00, '2024-02-25 15:30:00', 17, 8),
('transferencia', 480.00, '2024-02-27 12:15:00', 18, 9),
('tarjeta', 25.00, '2024-03-01 10:45:00', 19, 1),
('efectivo', 67.50, '2024-03-03 14:00:00', 20, 2),
('transferencia', 240.00, '2024-03-05 11:30:00', 21, 3),
('tarjeta', 40.00, '2024-03-08 16:20:00', 22, 4),
('efectivo', 108.00, '2024-03-10 10:10:00', 23, 5),
('transferencia', 384.00, '2024-03-12 13:40:00', 24, 6),
('tarjeta', 50.00, '2024-03-15 09:20:00', 25, 7),
('efectivo', 135.00, '2024-03-17 15:50:00', 26, 8),
('transferencia', 480.00, '2024-03-20 12:30:00', 27, 9),
('tarjeta', 25.00, '2024-03-22 10:00:00', 28, 1),
('efectivo', 67.50, '2024-03-25 14:25:00', 29, 2),
('transferencia', 240.00, '2024-03-27 11:15:00', 30, 3),
('tarjeta', 40.00, '2024-03-29 16:35:00', 31, 4),
('efectivo', 108.00, '2024-04-01 10:50:00', 32, 5),
('transferencia', 384.00, '2024-04-03 13:20:00', 33, 6),
('tarjeta', 50.00, '2024-04-05 09:40:00', 34, 7),
('efectivo', 135.00, '2024-04-08 15:10:00', 35, 8),
('transferencia', 480.00, '2024-04-10 12:45:00', 36, 9),
('tarjeta', 25.00, '2024-04-12 10:30:00', 37, 1),
('efectivo', 67.50, '2024-04-15 14:40:00', 38, 2),
('transferencia', 240.00, '2024-04-17 11:00:00', 39, 3),
('tarjeta', 40.00, '2024-04-20 16:50:00', 40, 4),
('efectivo', 108.00, '2024-04-22 10:25:00', 41, 5),
('transferencia', 384.00, '2024-04-25 13:55:00', 42, 6),
('tarjeta', 50.00, '2024-04-27 09:15:00', 43, 7),
('efectivo', 135.00, '2024-04-29 15:45:00', 44, 8),
('transferencia', 480.00, '2024-05-01 12:20:00', 45, 9),
('tarjeta', 25.00, '2024-05-03 10:35:00', 46, 1),
('efectivo', 67.50, '2024-05-05 14:05:00', 47, 2),
('transferencia', 240.00, '2024-05-08 11:50:00', 48, 3),
('tarjeta', 40.00, '2024-05-10 16:15:00', 49, 4),
('efectivo', 108.00, '2024-05-12 10:40:00', 50, 5);

-- Continuar con el mismo patrón para llegar a 5000 registros
-- Generando registros de manera eficiente y variada

INSERT INTO FACTURA (metodo_pago, monto, fecha_pago, id_socio, id_membresia) 
SELECT 
    CASE (ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) % 3)
        WHEN 0 THEN 'efectivo'
        WHEN 1 THEN 'tarjeta'
        ELSE 'transferencia'
    END,
    CASE ((ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) % 9) + 1)
        WHEN 1 THEN 25.00
        WHEN 2 THEN 67.50
        WHEN 3 THEN 240.00
        WHEN 4 THEN 40.00
        WHEN 5 THEN 108.00
        WHEN 6 THEN 384.00
        WHEN 7 THEN 50.00
        WHEN 8 THEN 135.00
        WHEN 9 THEN 480.00
    END,
    DATEADD(HOUR, (ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) % 24), 
           DATEADD(DAY, (ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) % 320), '2024-05-15')),
    ((ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) % 300) + 1),
    ((ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) % 9) + 1)
FROM sys.all_objects a1
CROSS JOIN sys.all_objects a2
WHERE ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) <= 4950;
