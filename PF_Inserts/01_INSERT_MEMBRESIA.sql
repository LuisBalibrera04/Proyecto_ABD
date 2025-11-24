-- Inserciones para la tabla MEMBRESIA (9 registros)
-- Base: Básica Mensual = $25.00
-- Nivel Premium: +$15 sobre la Básica
-- Nivel VIP: +$10 sobre la Premium
-- Descuento Trimestral: 10% menos que pagar 3 meses sueltos
-- Descuento Anual: 20% menos que pagar 12 meses sueltos

USE GimnasioReservas;

INSERT INTO Negocio.MEMBRESIA (tipo, duracion, precio) VALUES
-- Membresías Básicas
('Básica', 'Mensual', 25.00),           -- Base: $25.00
('Básica', 'Trimestral', 67.50),        -- (25 x 3) - 10% = 75 - 7.5 = $67.50
('Básica', 'Anual', 240.00),            -- (25 x 12) - 20% = 300 - 60 = $240.00

-- Membresías Premium
('Premium', 'Mensual', 40.00),          -- Base + $15 = 25 + 15 = $40.00
('Premium', 'Trimestral', 108.00),      -- (40 x 3) - 10% = 120 - 12 = $108.00
('Premium', 'Anual', 384.00),           -- (40 x 12) - 20% = 480 - 96 = $384.00

-- Membresías VIP
('VIP', 'Mensual', 50.00),              -- Premium + $10 = 40 + 10 = $50.00
('VIP', 'Trimestral', 135.00),          -- (50 x 3) - 10% = 150 - 15 = $135.00
('VIP', 'Anual', 480.00);               -- (50 x 12) - 20% = 600 - 120 = $480.00

SELECT * FROM MEMBRESIA;
