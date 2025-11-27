import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import os

# --- CONFIGURACIÓN DE LA RUTA ---
carpeta_data = r'C:/Users/matia/Desktop/Hospital_Data_Analysis/data/'

print(f"Buscando archivos en: {carpeta_data}")

# --- 1. CARGA DE DATOS (ETL) ---
try:
    df_services = pd.read_csv(carpeta_data + 'services_weekly.csv')
    df_patients = pd.read_csv(carpeta_data + 'patients.csv')
    df_staff = pd.read_csv(carpeta_data + 'staff.csv')
    df_schedule = pd.read_csv(carpeta_data + 'staff_schedule.csv')
    print("✅ ¡Archivos cargados exitosamente!")
except FileNotFoundError as e:
    print("❌ Error: No se encuentra el archivo.")
    print(f"Por favor verifica que tus CSV estén exactamente en: {carpeta_data}")
    exit()

# --- 2. LIMPIEZA Y FEATURE ENGINEERING ---

# Convertir fechas
df_patients['arrival_date'] = pd.to_datetime(df_patients['arrival_date'])
df_patients['departure_date'] = pd.to_datetime(df_patients['departure_date'])

# Crear Length of Stay (Días de Estancia)
df_patients['length_of_stay'] = (df_patients['departure_date'] - df_patients['arrival_date']).dt.days

# Crear Tasa de Ocupación
df_services['occupancy_rate'] = df_services.apply(
    lambda x: x['patients_admitted'] / x['available_beds'] if x['available_beds'] > 0 else 0, axis=1
)

print("\n--- Vista Previa de Datos Transformados ---")
print(df_patients[['patient_id', 'arrival_date', 'length_of_stay']].head())


# --- 3. VISUALIZACIÓN 1: MATRIZ DE CORRELACIÓN ---
plt.figure(figsize=(10, 8))
sns.set_theme(style="white")

cols_analisis = ['available_beds', 'patients_admitted', 'patients_refused', 
                 'patient_satisfaction', 'staff_morale']
matriz_corr = df_services[cols_analisis].corr()

sns.heatmap(matriz_corr, annot=True, cmap='RdBu', vmin=-1, vmax=1, fmt=".2f")
plt.title('Correlación de Métricas Hospitalarias')

plt.savefig('correlation_heatmap.png', bbox_inches='tight')
print("\n✅ Gráfica 1 guardada: correlation_heatmap.png")
plt.show()


# --- 4. VISUALIZACIÓN 2: DISTRIBUCIÓN DE SATISFACCIÓN ---
plt.figure(figsize=(12, 6))
sns.set_theme(style="whitegrid")

orden_servicios = df_patients.groupby('service')['satisfaction'].median().sort_values().index

sns.boxplot(
    data=df_patients, 
    x='service', 
    y='satisfaction', 
    hue='service',
    order=orden_servicios, 
    palette='viridis', 
    legend=False
)

plt.title('Distribución de Satisfacción del Paciente por Departamento')
plt.xlabel('Departamento')
plt.ylabel('Puntaje de Satisfacción')

plt.savefig('satisfaction_boxplot.png', bbox_inches='tight')
print("✅ Gráfica 2 guardada: satisfaction_boxplot.png")
plt.show()


print("\n--- ANÁLISIS FINALIZADO ---")
