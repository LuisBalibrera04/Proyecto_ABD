-- Inserciones para la tabla CLASE (50 registros)
-- 6 especialidades: Yoga, Spinning, CrossFit, Musculación, Calistenia, Pilates
-- Aproximadamente 8-9 clases por especialidad
-- Cupos entre 30 y 60 personas
-- IDs de entrenadores del 1 al 25

INSERT INTO Negocio.CLASE (tipo, horario, duracion_minutos, cupo, id_entrenador) VALUES
-- Clases de Yoga (8 clases) - Entrenadores: 1, 7, 13, 19, 25
('Yoga Matutino', '06:00:00', 60, 35, 1),
('Yoga Restaurativo', '08:00:00', 75, 42, 7),
('Hatha Yoga', '10:00:00', 60, 38, 13),
('Vinyasa Flow', '12:00:00', 60, 45, 19),
('Yoga Intermedio', '14:00:00', 75, 40, 25),
('Yoga Avanzado', '16:00:00', 90, 30, 1),
('Yoga Vespertino', '18:00:00', 60, 50, 7),
('Yoga Nocturno', '20:00:00', 60, 36, 13),

-- Clases de Spinning (9 clases) - Entrenadores: 2, 8, 14, 20
('Spinning Principiantes', '06:30:00', 45, 48, 2),
('Spinning Intensivo', '08:30:00', 60, 55, 8),
('Spinning Intervalos', '10:30:00', 50, 52, 14),
('Spinning Cardio', '12:30:00', 45, 60, 20),
('Spinning Power', '14:30:00', 60, 45, 2),
('Spinning Resistencia', '16:30:00', 55, 50, 8),
('Spinning Express', '18:30:00', 45, 58, 14),
('Spinning Avanzado', '19:30:00', 60, 42, 20),
('Spinning Nocturno', '21:00:00', 45, 38, 2),

-- Clases de CrossFit (8 clases) - Entrenadores: 3, 9, 15, 21
('CrossFit Básico', '07:00:00', 60, 32, 3),
('CrossFit WOD', '09:00:00', 75, 35, 9),
('CrossFit Strength', '11:00:00', 90, 30, 15),
('CrossFit Metcon', '13:00:00', 60, 40, 21),
('CrossFit Olympic', '15:00:00', 75, 28, 3),
('CrossFit Conditioning', '17:00:00', 60, 45, 9),
('CrossFit Competition', '19:00:00', 90, 30, 15),
('CrossFit Open Box', '20:30:00', 60, 38, 21),

-- Clases de Musculación (8 clases) - Entrenadores: 4, 10, 16, 22
('Musculación Principiantes', '06:00:00', 75, 35, 4),
('Fuerza y Masa', '08:00:00', 90, 40, 10),
('Musculación Tren Superior', '10:00:00', 60, 38, 16),
('Musculación Tren Inferior', '12:00:00', 75, 42, 22),
('Musculación Funcional', '14:00:00', 60, 45, 4),
('Hipertrofia', '16:00:00', 90, 32, 10),
('Powerlifting', '18:00:00', 75, 30, 16),
('Musculación Avanzada', '20:00:00', 90, 35, 22),

-- Clases de Calistenia (9 clases) - Entrenadores: 5, 11, 17, 23
('Calistenia Básica', '07:00:00', 60, 40, 5),
('Calistenia Skills', '09:00:00', 75, 35, 11),
('Calistenia Intermedia', '11:00:00', 60, 38, 17),
('Calistenia Freestyle', '13:00:00', 75, 32, 23),
('Calistenia Fuerza', '15:00:00', 60, 45, 5),
('Calistenia Estática', '17:00:00', 90, 30, 11),
('Calistenia Dinámica', '19:00:00', 60, 42, 17),
('Calistenia Avanzada', '20:00:00', 75, 28, 23),
('Calistenia Street Workout', '21:30:00', 60, 35, 5),

-- Clases de Pilates (8 clases) - Entrenadores: 6, 12, 18, 24
('Pilates Matinal', '06:00:00', 60, 36, 6),
('Pilates Reformer', '08:00:00', 60, 30, 12),
('Pilates Mat', '10:00:00', 60, 45, 18),
('Pilates Core', '12:00:00', 50, 40, 24),
('Pilates Intermedio', '14:00:00', 60, 38, 6),
('Pilates Terapéutico', '16:00:00', 75, 32, 12),
('Pilates Avanzado', '18:00:00', 60, 35, 18),
('Pilates Vespertino', '20:00:00', 60, 42, 24);

SELECT * FROM Negocio.CLASE;
