#!/usr/bin/env python3
"""
Generador del Dataset Perfecto para TempoSage ML Model
=====================================================

Este script genera un dataset completo y realista para entrenar el modelo ML unificado
de TempoSage, incluyendo todas las características necesarias para las 5 tareas del modelo.

Características del Dataset:
- 50,000 registros de entrenamiento
- 10,000 registros de validación
- 5,000 registros de prueba
- 95 características por registro
- Datos sintéticos realistas basados en patrones de productividad
- Distribución balanceada de categorías y patrones
"""

import pandas as pd
import numpy as np
import random
from datetime import datetime, timedelta
import json
import os
from typing import List, Dict, Any
import warnings
warnings.filterwarnings('ignore')

class TempoSageDatasetGenerator:
    def __init__(self, seed: int = 42):
        """Inicializa el generador de dataset con semilla para reproducibilidad."""
        np.random.seed(seed)
        random.seed(seed)
        
        # Configuración del dataset
        self.total_records = 65000  # 50k train + 10k val + 5k test
        self.train_size = 50000
        self.val_size = 10000
        self.test_size = 5000
        
        # Definir categorías y patrones
        self.categories = [
            'Trabajo', 'Estudio', 'Salud', 'Hogar', 'Finanzas', 
            'Social', 'Ocio', 'Personal', 'Formación', 'Creatividad'
        ]
        
        self.weather_conditions = [
            'Soleado', 'Nublado', 'Lluvioso', 'Tormentoso', 'Nevado'
        ]
        
        self.locations = [
            'Casa', 'Oficina', 'Gimnasio', 'Biblioteca', 'Café', 
            'Exterior', 'Universidad', 'Hospital', 'Centro Comercial'
        ]
        
        self.productivity_patterns = [
            'Productivo', 'Moderado', 'Bajo', 'Variable', 'Burnout'
        ]
        
        self.recommendation_types = [
            'Actividad', 'Hábito', 'TimeBlock', 'Descanso', 'Optimización'
        ]
        
        # Patrones temporales realistas
        self.energy_patterns = self._generate_energy_patterns()
        self.focus_patterns = self._generate_focus_patterns()
        self.optimal_time_blocks = self._generate_optimal_time_blocks()
        
    def _generate_energy_patterns(self) -> Dict[str, List[float]]:
        """Genera patrones de energía realistas por hora del día."""
        patterns = {
            'matutino': [0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 0.95, 0.9, 0.85, 0.8, 0.75, 0.7, 0.65, 0.6, 0.55, 0.5, 0.45, 0.4, 0.35, 0.3, 0.25, 0.2, 0.15],
            'vespertino': [0.2, 0.25, 0.3, 0.35, 0.4, 0.45, 0.5, 0.55, 0.6, 0.65, 0.7, 0.75, 0.8, 0.85, 0.9, 0.95, 0.9, 0.85, 0.8, 0.75, 0.7, 0.65, 0.6, 0.55],
            'nocturno': [0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4, 0.45, 0.5, 0.55, 0.6, 0.65, 0.7, 0.75, 0.8, 0.85, 0.9, 0.95, 0.9, 0.85, 0.8, 0.75, 0.7, 0.65],
            'variable': [0.4, 0.3, 0.5, 0.6, 0.4, 0.7, 0.5, 0.8, 0.6, 0.9, 0.7, 0.8, 0.6, 0.9, 0.5, 0.7, 0.6, 0.8, 0.5, 0.7, 0.6, 0.5, 0.4, 0.3]
        }
        return patterns
    
    def _generate_focus_patterns(self) -> Dict[str, List[float]]:
        """Genera patrones de enfoque realistas por hora del día."""
        patterns = {
            'concentrado': [0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 0.95, 0.9, 0.85, 0.8, 0.75, 0.7, 0.65, 0.6, 0.55, 0.5, 0.45, 0.4, 0.35, 0.3, 0.25, 0.2],
            'disperso': [0.5, 0.4, 0.6, 0.3, 0.7, 0.4, 0.8, 0.3, 0.9, 0.4, 0.8, 0.5, 0.7, 0.6, 0.8, 0.4, 0.9, 0.3, 0.8, 0.4, 0.7, 0.5, 0.6, 0.4],
            'variable': [0.3, 0.5, 0.4, 0.6, 0.5, 0.7, 0.6, 0.8, 0.7, 0.9, 0.8, 0.7, 0.6, 0.8, 0.5, 0.7, 0.6, 0.8, 0.5, 0.7, 0.6, 0.5, 0.4, 0.3]
        }
        return patterns
    
    def _generate_optimal_time_blocks(self) -> Dict[str, List[float]]:
        """Genera bloques de tiempo óptimos por categoría."""
        blocks = {}
        for category in self.categories:
            # Generar patrones específicos por categoría
            if category == 'Trabajo':
                blocks[category] = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 0.95, 0.9, 0.85, 0.8, 0.75, 0.7, 0.65, 0.6, 0.55, 0.5, 0.45, 0.4, 0.35, 0.3, 0.25]
            elif category == 'Estudio':
                blocks[category] = [0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 0.95, 0.9, 0.85, 0.8, 0.75, 0.7, 0.65, 0.6, 0.55, 0.5, 0.45, 0.4, 0.35, 0.3, 0.25, 0.2]
            elif category == 'Salud':
                blocks[category] = [0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 0.95, 0.9, 0.85, 0.8, 0.75, 0.7, 0.65, 0.6, 0.55, 0.5, 0.45, 0.4, 0.35, 0.3, 0.25, 0.2, 0.15]
            else:
                # Patrón general para otras categorías
                blocks[category] = [0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 0.85, 0.8, 0.75, 0.7, 0.65, 0.6, 0.55, 0.5, 0.45, 0.4, 0.35, 0.3, 0.25, 0.2, 0.15, 0.1]
        return blocks
    
    def _generate_user_context(self) -> Dict[str, float]:
        """Genera contexto del usuario realista."""
        return {
            'energy_level': np.random.beta(2, 2),  # Distribución centrada en 0.5
            'mood': np.random.beta(2, 2),
            'stress_level': np.random.beta(2, 3),  # Sesgado hacia valores bajos
            'focus_capacity': np.random.beta(2, 2),
            'sleep_quality': np.random.beta(2, 2),
            'exercise_level': np.random.beta(2, 3),
            'social_interaction': np.random.beta(2, 3)
        }
    
    def _generate_activity_features(self, category: str) -> Dict[str, Any]:
        """Genera características de actividad basadas en la categoría."""
        # Títulos y descripciones por categoría
        activity_templates = {
            'Trabajo': [
                ('Reunión de planificación', 'Reunión para planificar objetivos y tareas'),
                ('Análisis de datos', 'Análisis detallado de métricas y tendencias'),
                ('Seguimiento de proyectos', 'Revisión del progreso y seguimiento'),
                ('Finalizar informe', 'Completar y revisar informe'),
                ('Revisar tareas pendientes', 'Revisión y organización de tareas')
            ],
            'Estudio': [
                ('Estudiar conceptos teóricos', 'Estudio de conceptos teóricos para examen'),
                ('Continuar lecturas', 'Continuación de lecturas obligatorias'),
                ('Repasar contenido', 'Repaso intensivo para examen'),
                ('Investigación para proyecto', 'Investigación profunda para proyecto'),
                ('Preparación para clases', 'Preparación de material para clases')
            ],
            'Salud': [
                ('Rutina de ejercicio cardiovascular', 'Entrenamiento cardiovascular'),
                ('Entrenamiento de fuerza', 'Entrenamiento de fuerza y musculación'),
                ('Yoga y estiramiento', 'Sesión de yoga y estiramientos'),
                ('Entrenamiento completo', 'Entrenamiento intensivo'),
                ('Caminata de recuperación', 'Caminata suave de recuperación')
            ],
            'Hogar': [
                ('Limpieza de cocina y baño', 'Limpieza profunda de cocina y baños'),
                ('Organización de armarios', 'Organización y limpieza de armarios'),
                ('Limpieza general', 'Limpieza general y profunda'),
                ('Preparación de comidas', 'Preparación de comidas para la semana'),
                ('Mantenimiento del hogar', 'Tareas de mantenimiento y reparación')
            ],
            'Finanzas': [
                ('Revisión de gastos', 'Revisión y análisis de gastos'),
                ('Pago de facturas', 'Pago de facturas mensuales'),
                ('Planificación financiera', 'Planificación financiera mensual'),
                ('Inversiones', 'Revisión y análisis de inversiones'),
                ('Presupuesto', 'Elaboración y revisión de presupuesto')
            ]
        }
        
        # Seleccionar template aleatorio para la categoría
        if category in activity_templates:
            title, description = random.choice(activity_templates[category])
        else:
            title = f"Actividad de {category}"
            description = f"Descripción de actividad de {category}"
        
        # Generar características numéricas
        priority = np.random.choice([1, 2, 3, 4, 5], p=[0.1, 0.2, 0.4, 0.2, 0.1])
        duration = np.random.choice([15, 30, 45, 60, 90, 120, 180], p=[0.1, 0.2, 0.2, 0.2, 0.15, 0.1, 0.05])
        complexity = np.random.beta(2, 2)
        energy_required = np.random.beta(2, 2)
        focus_required = np.random.beta(2, 2)
        deadline_pressure = np.random.beta(2, 3)
        
        return {
            'title': title,
            'description': description,
            'priority': priority,
            'duration': duration,
            'complexity': complexity,
            'energy_required': energy_required,
            'focus_required': focus_required,
            'deadline_pressure': deadline_pressure
        }
    
    def _generate_habit_features(self, category: str) -> Dict[str, Any]:
        """Genera características de hábito basadas en la categoría."""
        streak = np.random.poisson(7)  # Distribución de Poisson para rachas
        frequency = np.random.beta(2, 2)
        success_rate = np.random.beta(3, 1)  # Sesgado hacia éxito
        days_since_last = np.random.poisson(1)
        difficulty = np.random.beta(2, 2)
        importance = np.random.beta(2, 1)  # Sesgado hacia importancia
        time_consistency = np.random.beta(2, 2)
        
        return {
            'streak': min(streak, 365),  # Máximo 1 año
            'frequency': frequency,
            'success_rate': success_rate,
            'days_since_last_completion': days_since_last,
            'difficulty': difficulty,
            'importance': importance,
            'time_consistency': time_consistency
        }
    
    def _generate_temporal_features(self) -> Dict[str, Any]:
        """Genera características temporales realistas."""
        # Generar timestamp aleatorio en el último año
        start_date = datetime.now() - timedelta(days=365)
        end_date = datetime.now()
        random_timestamp = start_date + timedelta(
            seconds=random.randint(0, int((end_date - start_date).total_seconds()))
        )
        
        weekday = random_timestamp.weekday()  # 0-6 (lunes-domingo)
        hour = random_timestamp.hour
        day_of_year = random_timestamp.timetuple().tm_yday
        month = random_timestamp.month
        is_weekend = weekday >= 5
        is_holiday = random.random() < 0.05  # 5% de probabilidad de ser festivo
        season = (month - 1) // 3  # 0-3 (invierno, primavera, verano, otoño)
        time_since_last = np.random.exponential(60)  # Exponencial para tiempo entre actividades
        
        return {
            'timestamp': int(random_timestamp.timestamp()),
            'weekday': weekday,
            'hour_of_day': hour,
            'day_of_year': day_of_year,
            'month': month,
            'is_weekend': int(is_weekend),
            'is_holiday': int(is_holiday),
            'season': season,
            'time_since_last_activity': time_since_last
        }
    
    def _generate_historical_features(self) -> Dict[str, Any]:
        """Genera características históricas del usuario."""
        completion_rate_week = np.random.beta(3, 1)  # Sesgado hacia éxito
        completion_rate_month = np.random.beta(3, 1)
        productivity_score_week = np.random.beta(3, 1)
        productivity_score_month = np.random.beta(3, 1)
        
        # Generar patrones de tiempo óptimo (7 días x 24 horas)
        optimal_morning = np.random.beta(2, 2)
        optimal_afternoon = np.random.beta(2, 2)
        optimal_evening = np.random.beta(2, 2)
        
        # Patrones de energía y enfoque
        energy_peak = np.random.beta(2, 2)
        energy_low = np.random.beta(2, 2)
        focus_peak = np.random.beta(2, 2)
        focus_low = np.random.beta(2, 2)
        
        return {
            'completion_rate_last_week': completion_rate_week,
            'completion_rate_last_month': completion_rate_month,
            'productivity_score_last_week': productivity_score_week,
            'productivity_score_last_month': productivity_score_month,
            'optimal_time_blocks_morning': optimal_morning,
            'optimal_time_blocks_afternoon': optimal_afternoon,
            'optimal_time_blocks_evening': optimal_evening,
            'energy_patterns_peak': energy_peak,
            'energy_patterns_low': energy_low,
            'focus_patterns_peak': focus_peak,
            'focus_patterns_low': focus_low
        }
    
    def _generate_contextual_features(self) -> Dict[str, Any]:
        """Genera características contextuales."""
        weather = random.choice(self.weather_conditions)
        location = random.choice(self.locations)
        device_usage = np.random.beta(2, 2)
        
        # Contextos mutuamente excluyentes
        contexts = ['social', 'work', 'study', 'personal']
        context_weights = np.random.dirichlet([1, 1, 1, 1])
        context_dict = {f"{ctx}_context": weight for ctx, weight in zip(contexts, context_weights)}
        
        return {
            'weather_condition': weather,
            'location_type': location,
            'device_usage_pattern': device_usage,
            **context_dict
        }
    
    def _generate_targets(self, user_context: Dict, activity_features: Dict, 
                         habit_features: Dict, temporal_features: Dict) -> Dict[str, Any]:
        """Genera las variables objetivo (targets) para el modelo."""
        # Calcular probabilidades de éxito basadas en características
        energy_factor = user_context['energy_level']
        mood_factor = user_context['mood']
        stress_factor = 1 - user_context['stress_level']
        focus_factor = user_context['focus_capacity']
        
        # Probabilidad de éxito de actividad
        activity_success = (energy_factor * 0.3 + mood_factor * 0.2 + 
                           stress_factor * 0.3 + focus_factor * 0.2)
        activity_success = min(max(activity_success, 0.1), 0.95)
        
        # Probabilidad de éxito de hábito
        habit_success = (habit_features['success_rate'] * 0.4 + 
                        habit_features['streak'] / 30 * 0.2 +  # Normalizar racha
                        energy_factor * 0.2 + mood_factor * 0.2)
        habit_success = min(max(habit_success, 0.1), 0.95)
        
        # Eficiencia de time block
        timeblock_efficiency = (activity_success * 0.4 + habit_success * 0.3 + 
                               energy_factor * 0.2 + focus_factor * 0.1)
        timeblock_efficiency = min(max(timeblock_efficiency, 0.1), 0.95)
        
        # Predicción de nivel de energía
        energy_predicted = energy_factor * 0.6 + mood_factor * 0.4
        energy_predicted = min(max(energy_predicted, 0.1), 0.95)
        
        # Probabilidad de fatiga
        fatigue_probability = ((1 - energy_factor) * 0.5 + stress_factor * 0.3 + 
                             (1 - user_context['sleep_quality']) * 0.2)
        fatigue_probability = min(max(fatigue_probability, 0.05), 0.9)
        
        # Patrón de productividad
        productivity_score = (activity_success + habit_success + timeblock_efficiency) / 3
        if productivity_score > 0.8:
            pattern = 'Productivo'
        elif productivity_score > 0.6:
            pattern = 'Moderado'
        elif productivity_score > 0.4:
            pattern = 'Variable'
        elif productivity_score > 0.2:
            pattern = 'Bajo'
        else:
            pattern = 'Burnout'
        
        # Riesgo de burnout
        burnout_risk = ((fatigue_probability * 0.4 + stress_factor * 0.3 + 
                       (1 - productivity_score) * 0.3))
        burnout_risk = min(max(burnout_risk, 0.05), 0.9)
        
        # Tiempos óptimos
        optimal_activity_time = temporal_features['hour_of_day'] + np.random.normal(0, 2)
        optimal_habit_time = temporal_features['hour_of_day'] + np.random.normal(0, 1)
        optimal_break_time = temporal_features['hour_of_day'] + np.random.normal(0, 3)
        
        # Duración predicha
        activity_duration_pred = activity_features['duration'] + np.random.normal(0, 10)
        habit_duration_pred = np.random.choice([15, 30, 45, 60]) + np.random.normal(0, 5)
        
        # Probabilidades de completado
        activity_completed = int(random.random() < activity_success)
        habit_completed = int(random.random() < habit_success)
        timeblock_completed = int(random.random() < timeblock_efficiency)
        
        return {
            'activity_completed': activity_completed,
            'habit_completed': habit_completed,
            'timeblock_completed': timeblock_completed,
            'activity_success_probability': activity_success,
            'habit_success_probability': habit_success,
            'timeblock_efficiency': timeblock_efficiency,
            'energy_level_predicted': energy_predicted,
            'fatigue_probability': fatigue_probability,
            'productivity_pattern': pattern,
            'recommendation_type': random.choice(self.recommendation_types),
            'burnout_risk': burnout_risk,
            'optimal_activity_time': max(0, min(23, optimal_activity_time)),
            'optimal_habit_time': max(0, min(23, optimal_habit_time)),
            'optimal_break_time': max(0, min(23, optimal_break_time)),
            'activity_duration_predicted': max(5, activity_duration_pred),
            'habit_duration_predicted': max(5, habit_duration_pred),
            'energy_required_predicted': activity_features['energy_required'],
            'focus_required_predicted': activity_features['focus_required'],
            'deadline_pressure_predicted': activity_features['deadline_pressure'],
            'streak_maintenance_probability': habit_success,
            'timeblock_priority_score': activity_features['priority'] / 5.0,
            'energy_peak_time': temporal_features['hour_of_day'] + np.random.normal(0, 2),
            'focus_peak_time': temporal_features['hour_of_day'] + np.random.normal(0, 1),
            'productivity_peak_time': temporal_features['hour_of_day'] + np.random.normal(0, 1.5),
            'rest_optimal_time': temporal_features['hour_of_day'] + np.random.normal(0, 3),
            'activity_category_confidence': np.random.beta(3, 1),
            'habit_completion_confidence': np.random.beta(3, 1),
            'timeblock_optimization_score': timeblock_efficiency,
            'energy_prediction_accuracy': np.random.beta(3, 1),
            'fatigue_prediction_accuracy': np.random.beta(3, 1),
            'pattern_recognition_confidence': np.random.beta(3, 1),
            'burnout_prediction_confidence': np.random.beta(3, 1),
            'recommendation_quality_score': np.random.beta(3, 1),
            'overall_success_probability': (activity_success + habit_success + timeblock_efficiency) / 3,
            'user_satisfaction_score': np.random.beta(3, 1),
            'model_confidence_score': np.random.beta(3, 1)
        }
    
    def generate_record(self) -> Dict[str, Any]:
        """Genera un registro completo del dataset."""
        # IDs únicos
        user_id = np.random.randint(1, 1001)  # 1000 usuarios únicos
        activity_id = np.random.randint(1, 10001)
        habit_id = np.random.randint(1, 5001)
        timeblock_id = np.random.randint(1, 20001)
        
        # Categoría principal
        category = random.choice(self.categories)
        
        # Generar todas las características
        user_context = self._generate_user_context()
        activity_features = self._generate_activity_features(category)
        habit_features = self._generate_habit_features(category)
        temporal_features = self._generate_temporal_features()
        historical_features = self._generate_historical_features()
        contextual_features = self._generate_contextual_features()
        
        # Generar targets
        targets = self._generate_targets(user_context, activity_features, 
                                       habit_features, temporal_features)
        
        # Combinar todo en un registro
        record = {
            'user_id': user_id,
            'activity_id': activity_id,
            'habit_id': habit_id,
            'timeblock_id': timeblock_id,
            **temporal_features,
            **user_context,
            'activity_title': activity_features['title'],
            'activity_description': activity_features['description'],
            'activity_category': category,
            'activity_priority': activity_features['priority'],
            'activity_duration': activity_features['duration'],
            'activity_complexity': activity_features['complexity'],
            'activity_energy_required': activity_features['energy_required'],
            'activity_focus_required': activity_features['focus_required'],
            'activity_deadline_pressure': activity_features['deadline_pressure'],
            **habit_features,
            'habit_category': category,
            **historical_features,
            **contextual_features,
            **targets
        }
        
        return record
    
    def generate_dataset(self) -> pd.DataFrame:
        """Genera el dataset completo."""
        print(f"Generando dataset de {self.total_records} registros...")
        
        records = []
        for i in range(self.total_records):
            if (i + 1) % 10000 == 0:
                print(f"Generados {i + 1} registros...")
            records.append(self.generate_record())
        
        df = pd.DataFrame(records)
        print(f"Dataset generado con {len(df)} registros y {len(df.columns)} características")
        
        return df
    
    def save_dataset(self, df: pd.DataFrame, output_dir: str = "data"):
        """Guarda el dataset en archivos CSV separados."""
        os.makedirs(output_dir, exist_ok=True)
        
        # Dividir en train, validation y test
        train_df = df.iloc[:self.train_size]
        val_df = df.iloc[self.train_size:self.train_size + self.val_size]
        test_df = df.iloc[self.train_size + self.val_size:]
        
        # Guardar archivos
        train_path = os.path.join(output_dir, "temposage_train.csv")
        val_path = os.path.join(output_dir, "temposage_validation.csv")
        test_path = os.path.join(output_dir, "temposage_test.csv")
        full_path = os.path.join(output_dir, "temposage_full_dataset.csv")
        
        train_df.to_csv(train_path, index=False)
        val_df.to_csv(val_path, index=False)
        test_df.to_csv(test_path, index=False)
        df.to_csv(full_path, index=False)
        
        print(f"Dataset guardado en:")
        print(f"  - Entrenamiento: {train_path} ({len(train_df)} registros)")
        print(f"  - Validación: {val_path} ({len(val_df)} registros)")
        print(f"  - Prueba: {test_path} ({len(test_df)} registros)")
        print(f"  - Completo: {full_path} ({len(df)} registros)")
        
        # Guardar metadatos
        metadata = {
            'total_records': len(df),
            'train_records': len(train_df),
            'validation_records': len(val_df),
            'test_records': len(test_df),
            'features': list(df.columns),
            'categories': self.categories,
            'weather_conditions': self.weather_conditions,
            'locations': self.locations,
            'productivity_patterns': self.productivity_patterns,
            'recommendation_types': self.recommendation_types,
            'generated_at': datetime.now().isoformat(),
            'description': 'Dataset completo para entrenamiento del modelo ML unificado de TempoSage'
        }
        
        metadata_path = os.path.join(output_dir, "dataset_metadata.json")
        with open(metadata_path, 'w', encoding='utf-8') as f:
            json.dump(metadata, f, indent=2, ensure_ascii=False)
        
        print(f"  - Metadatos: {metadata_path}")
        
        return {
            'train': train_path,
            'validation': val_path,
            'test': test_path,
            'full': full_path,
            'metadata': metadata_path
        }

def main():
    """Función principal para generar el dataset."""
    print("🚀 Generador del Dataset Perfecto para TempoSage ML Model")
    print("=" * 60)
    
    # Crear generador
    generator = TempoSageDatasetGenerator(seed=42)
    
    # Generar dataset
    df = generator.generate_dataset()
    
    # Guardar dataset
    file_paths = generator.save_dataset(df)
    
    # Mostrar estadísticas
    print("\n📊 Estadísticas del Dataset:")
    print(f"  - Total de registros: {len(df):,}")
    print(f"  - Total de características: {len(df.columns)}")
    print(f"  - Usuarios únicos: {df['user_id'].nunique()}")
    print(f"  - Categorías: {df['activity_category'].nunique()}")
    print(f"  - Patrones de productividad: {df['productivity_pattern'].nunique()}")
    
    print("\n📈 Distribución por categoría:")
    category_dist = df['activity_category'].value_counts()
    for category, count in category_dist.items():
        percentage = (count / len(df)) * 100
        print(f"  - {category}: {count:,} ({percentage:.1f}%)")
    
    print("\n🎯 Distribución de patrones de productividad:")
    pattern_dist = df['productivity_pattern'].value_counts()
    for pattern, count in pattern_dist.items():
        percentage = (count / len(df)) * 100
        print(f"  - {pattern}: {count:,} ({percentage:.1f}%)")
    
    print("\n✅ Dataset generado exitosamente!")
    print("El dataset está listo para entrenar el modelo ML unificado de TempoSage.")

if __name__ == "__main__":
    main()
