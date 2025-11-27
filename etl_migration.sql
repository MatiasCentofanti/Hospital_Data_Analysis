-- ===============================================================
-- MIGRACIÓN DE DATOS (ETL)
-- Trasvase de datos desde las tablas CSV importadas a las tablas oficiales
-- ===============================================================

-- 1. Migrar STAFF (Primero, porque es la tabla principal)
INSERT INTO Staff (staff_id, staff_name, role, service)
SELECT staff_id, staff_name, role, service
FROM [staff.csv]; 

-- 2. Migrar PATIENTS
INSERT INTO Patients (patient_id, name, age, arrival_date, departure_date, service, satisfaction)
SELECT patient_id, name, age, arrival_date, departure_date, service, satisfaction
FROM [patients.csv];

-- 3. Migrar SERVICES_WEEKLY
INSERT INTO Services_Weekly (week, month, service, available_beds, patients_request, patients_admitted, patients_refused, patient_satisfaction, staff_morale, event)
SELECT week, month, service, available_beds, patients_request, patients_admitted, patients_refused, patient_satisfaction, staff_morale, event
FROM [services_weekly.csv];

-- 4. Migrar STAFF_SCHEDULE (Último, porque depende de Staff)
-- Como los IDs están mal en los CSVs, unimos las tablas usando 'staff_name'
-- y traemos el 'staff_id' CORRECTO de la tabla Staff.
INSERT INTO Staff_Schedule (week, staff_id, staff_name, role, service, present)
SELECT 
    sch.week, 
    s.staff_id,      -- <--- Usamos el ID real de la tabla Staff (no el del CSV)
    sch.staff_name, 
    sch.role, 
    sch.service, 
    sch.present
FROM [staff_schedule.csv] sch
INNER JOIN Staff s ON sch.staff_name = s.staff_name; -- Cruzamos por Nombre

-- ===============================================================
-- VERIFICACIÓN DE CARGA
-- Confirma que los números coinciden
-- ===============================================================
SELECT 'Staff' as Tabla, COUNT(*) as Total_Filas FROM Staff
UNION ALL
SELECT 'Patients', COUNT(*) FROM Patients
UNION ALL
SELECT 'Services', COUNT(*) FROM Services_Weekly
UNION ALL
SELECT 'Schedule', COUNT(*) FROM Staff_Schedule;

