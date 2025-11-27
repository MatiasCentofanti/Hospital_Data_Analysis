-- 1. Tabla de Empleados (Dimensión)
-- Esta tabla guarda la info única de cada médico/enfermero
CREATE TABLE Staff (
    staff_id VARCHAR(50) PRIMARY KEY,  -- PK: Identificador único
    staff_name VARCHAR(100),
    role VARCHAR(50),                  -- Ejemplo: Doctor, Nurse
    service VARCHAR(50)                -- Ejemplo: ICU, Emergency
);

-- 2. Tabla de Pacientes (Dimensión)
-- Información de cada persona que entra al hospital
CREATE TABLE Patients (
    patient_id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100),
    age INT,
    arrival_date DATE,
    departure_date DATE,
    service VARCHAR(50),
    satisfaction INT                   -- Escala 1-100
);

-- 3. Tabla de Horarios (Hechos)
-- Registro semanal de asistencia. Se conecta con Staff usando staff_id
CREATE TABLE Staff_Schedule (
    week INT,
    staff_id VARCHAR(50),
    staff_name VARCHAR(100),
    role VARCHAR(50),
    service VARCHAR(50),
    present INT,                       -- 1 = Presente, 0 = Ausente
    FOREIGN KEY (staff_id) REFERENCES Staff(staff_id) -- Conexión (Relación)
);

-- 4. Tabla de Métricas Semanales (Hechos Agregados)
-- Resumen operativo por semana y servicio
CREATE TABLE Services_Weekly (
    week INT,
    month INT,
    service VARCHAR(50),
    available_beds INT,
    patients_request INT,              -- Demanda total
    patients_admitted INT,             -- Pacientes aceptados
    patients_refused INT,              -- Pacientes rechazados por falta de espacio
    patient_satisfaction INT,
    staff_morale INT,
    event VARCHAR(50)                  -- Ejemplo: Flu, None, Donation
);