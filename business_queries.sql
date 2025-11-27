-- ===============================================================
-- ANÁLISIS DE NEGOCIO - HOSPITAL OPERATIONS 2025
-- Objetivo: Extraer insights clave directamente desde la BD
-- ===============================================================

-- 1. KPI BÁSICO: Panorama General
-- Muestra la escala total de la operación (Demanda vs. Capacidad).
SELECT 
    SUM(patients_request) AS total_demanda,
    SUM(patients_admitted) AS total_admitidos,
    SUM(patients_refused) AS total_rechazados,
    -- Casteamos a FLOAT para que no redondee a entero
    ROUND(AVG(CAST(patient_satisfaction AS FLOAT)), 2) AS satisfaccion_global_promedio
FROM Services_Weekly;


-- 2. CUELLOS DE BOTELLA (Análisis por Servicio)
-- ¿Qué departamento está rechazando más pacientes?
SELECT 
    service, 
    SUM(patients_request) AS demanda_total,
    SUM(patients_refused) AS pacientes_rechazados,
    -- Cálculo de % dentro de SQL
    ROUND((SUM(patients_refused) * 100.0 / NULLIF(SUM(patients_request), 0)), 2) AS tasa_rechazo_pct
FROM Services_Weekly
GROUP BY service
ORDER BY tasa_rechazo_pct DESC;


-- 3. PRODUCTIVIDAD DEL PERSONAL (Top 10 Doctores)
-- Cruzamos la tabla de Horarios con la de Personal para ver quién trabajó más.
SELECT TOP 10
    s.staff_name,
    s.role,
    s.service,
    COUNT(ss.week) AS semanas_registradas,
    SUM(ss.present) AS dias_presentes
FROM Staff s
JOIN Staff_Schedule ss ON s.staff_name = ss.staff_name -- Cruzamos por nombre (ya que arreglamos eso en el ETL)
WHERE s.role = 'doctor'
GROUP BY s.staff_name, s.role, s.service
ORDER BY dias_presentes DESC;


-- 4. RANKING DE CALIDAD (Window Functions)
-- Clasifica las semanas de mejor a peor según satisfacción, por cada servicio.
SELECT 
    week,
    service,
    patient_satisfaction,
    staff_morale,
    -- RANK() crea un ranking reiniciando el conteo para cada servicio
    RANK() OVER (PARTITION BY service ORDER BY patient_satisfaction DESC) AS ranking_satisfaccion
FROM Services_Weekly
ORDER BY service, ranking_satisfaccion;