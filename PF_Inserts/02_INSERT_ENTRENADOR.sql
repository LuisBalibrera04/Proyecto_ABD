-- Inserciones para la tabla ENTRENADOR (25 registros)
-- Algunos tienen contratos vigentes (fechas futuras)
-- Algunos tienen contratos ya finalizados (fechas pasadas)

INSERT INTO Negocio.ENTRENADOR (nombre, telefono, email, fecha_inicio_inscripcion, fecha_final_inscripcion, salario, especialidad) VALUES
('Carolina Beatriz Morales Delgado', '503-7823-4567', 'carolina.morales@fitgym.com', '2022-03-15', '2027-03-15', 850.00, 'Yoga'),
('Roberto Francisco Salinas Castro', '503-6934-5678', 'roberto.salinas@fitgym.com', '2021-06-20', '2025-06-20', 950.00, 'Spinning'),
('Daniela Alejandra Fuentes Ramos', '503-7145-6789', 'daniela.fuentes@fitgym.com', '2023-01-10', '2028-01-10', 1100.00, 'CrossFit'),
('Miguel Eduardo Torres Méndez', '503-6856-7890', 'miguel.torres@fitgym.com', '2020-09-05', '2025-09-05', 1050.00, 'Musculación'),
('Andrea Sofía Guzmán Paredes', '503-7267-8901', 'andrea.guzman@fitgym.com', '2022-11-18', '2026-11-18', 900.00, 'Calistenia'),
('Fernando Javier Navarro Ortiz', '503-6978-9012', 'fernando.navarro@fitgym.com', '2021-04-22', '2024-04-22', 850.00, 'Pilates'),
('Gabriela Patricia Reyes Cortés', '503-7489-0123', 'gabriela.reyes@fitgym.com', '2023-05-08', '2026-05-08', 850.00, 'Yoga'),
('Carlos Alberto Domínguez Silva', '503-6590-1234', 'carlos.dominguez@fitgym.com', '2022-08-14', '2027-08-14', 950.00, 'Spinning'),
('Valeria Cristina Vargas Herrera', '503-7601-2345', 'valeria.vargas@fitgym.com', '2021-12-03', '2024-12-03', 1100.00, 'CrossFit'),
('Ricardo Andrés Peña Campos', '503-6712-3456', 'ricardo.pena@fitgym.com', '2020-07-25', '2025-07-25', 1050.00, 'Musculación'),
('Laura Michelle Contreras Molina', '503-7823-4560', 'laura.contreras@fitgym.com', '2023-02-16', '2025-02-16', 900.00, 'Calistenia'),
('Diego Sebastián Ramírez Padilla', '503-6934-5671', 'diego.ramirez@fitgym.com', '2022-06-30', '2026-06-30', 850.00, 'Pilates'),
('Mónica Isabel Cruz Ibarra', '503-7145-6782', 'monica.cruz@fitgym.com', '2021-10-12', '2024-10-12', 850.00, 'Yoga'),
('Alejandro Mauricio Guerrero Luna', '503-6856-7893', 'alejandro.guerrero@fitgym.com', '2023-04-05', '2027-04-05', 950.00, 'Spinning'),
('Natalia Carolina Flores Montes', '503-7267-8904', 'natalia.flores@fitgym.com', '2022-01-20', '2026-01-20', 1100.00, 'CrossFit'),
('Sergio Rafael Jiménez Ríos', '503-6978-9015', 'sergio.jimenez@fitgym.com', '2021-08-17', '2026-08-17', 1050.00, 'Musculación'),
('Paola Andrea Soto Figueroa', '503-7489-0126', 'paola.soto@fitgym.com', '2023-07-22', '2025-07-22', 900.00, 'Calistenia'),
('Esteban Ricardo Mendoza Rubio', '503-6590-1237', 'esteban.mendoza@fitgym.com', '2022-05-09', '2027-05-09', 850.00, 'Pilates'),
('Claudia Fernanda Escobar Acosta', '503-7601-2348', 'claudia.escobar@fitgym.com', '2021-11-28', '2024-11-28', 850.00, 'Yoga'),
('Leonardo Daniel Bravo Lara', '503-6712-3459', 'leonardo.bravo@fitgym.com', '2023-03-14', '2028-03-14', 950.00, 'Spinning'),
('Adriana Marcela Carrillo Palacios', '503-7823-4561', 'adriana.carrillo@fitgym.com', '2022-09-06', '2025-09-06', 1100.00, 'CrossFit'),
('Rodrigo Enrique León Sandoval', '503-6934-5672', 'rodrigo.leon@fitgym.com', '2020-12-19', '2025-12-19', 1050.00, 'Musculación'),
('Jessica Alejandra Ruiz Alvarado', '503-7145-6783', 'jessica.ruiz@fitgym.com', '2023-06-11', '2026-06-11', 900.00, 'Calistenia'),
('Julio César Maldonado Cervantes', '503-6856-7894', 'julio.maldonado@fitgym.com', '2022-02-24', '2024-08-31', 850.00, 'Pilates'),
('Mariana Victoria Ávila Espinoza', '503-7267-8905', 'mariana.avila@fitgym.com', '2021-07-13', '2024-07-13', 850.00, 'Yoga');

SELECT * FROM Negocio.ENTRENADOR;
