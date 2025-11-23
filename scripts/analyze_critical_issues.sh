#!/bin/bash

# Script para analizar y priorizar issues críticos de SonarQube
# Autor: TempoSage Team
# Fecha: 9 de Octubre, 2025

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar que SonarQube esté ejecutándose
if ! curl -s http://localhost:9000/api/system/status | grep -q "UP"; then
    log_error "SonarQube no está ejecutándose. Ejecuta primero: docker-compose up -d"
    exit 1
fi

log_info "Analizando issues críticos en SonarQube..."

# Obtener issues críticos
log_info "Obteniendo issues críticos..."
CRITICAL_ISSUES=$(curl -u admin:admin "http://localhost:9000/api/issues/search?componentKeys=temposage-movil&severities=CRITICAL&ps=50" 2>/dev/null)

if [ $? -eq 0 ]; then
    echo "$CRITICAL_ISSUES" | jq '.issues[] | {
        key: .key,
        rule: .rule,
        severity: .severity,
        message: .message,
        component: .component,
        line: .line,
        effort: .effort
    }' > critical_issues.json
    
    CRITICAL_COUNT=$(echo "$CRITICAL_ISSUES" | jq '.total')
    log_success "Encontrados $CRITICAL_COUNT issues críticos"
else
    log_error "No se pudieron obtener los issues críticos"
    exit 1
fi

# Obtener bugs críticos
log_info "Obteniendo bugs críticos..."
CRITICAL_BUGS=$(curl -u admin:admin "http://localhost:9000/api/issues/search?componentKeys=temposage-movil&severities=CRITICAL&types=BUG&ps=50" 2>/dev/null)

if [ $? -eq 0 ]; then
    echo "$CRITICAL_BUGS" | jq '.issues[] | {
        key: .key,
        rule: .rule,
        severity: .severity,
        message: .message,
        component: .component,
        line: .line,
        effort: .effort
    }' > critical_bugs.json
    
    BUG_COUNT=$(echo "$CRITICAL_BUGS" | jq '.total')
    log_success "Encontrados $BUG_COUNT bugs críticos"
fi

# Generar reporte de priorización
log_info "Generando reporte de priorización..."

cat > docs/CRITICAL_ISSUES_PRIORITIZATION.md << EOF
# ANÁLISIS DE ISSUES CRÍTICOS - TEMPOSAGE

**Fecha:** $(date)  
**Total Issues Críticos:** $CRITICAL_COUNT  
**Total Bugs Críticos:** $BUG_COUNT  

## 🚨 PRIORIZACIÓN DE ISSUES CRÍTICOS

### Criterios de Priorización:
1. **Seguridad:** Issues que afecten la seguridad del sistema
2. **Funcionalidad:** Bugs que rompan funcionalidades críticas
3. **Estabilidad:** Problemas que causen crashes o comportamientos inesperados
4. **Rendimiento:** Issues que afecten significativamente el rendimiento
5. **Mantenibilidad:** Problemas que dificulten el mantenimiento del código

### 📋 ISSUES CRÍTICOS IDENTIFICADOS:

EOF

# Procesar issues críticos
if [ -f critical_issues.json ]; then
    jq -r '. | "#### 🔴 " + (.rule // "Unknown") + "\n- **Archivo:** " + (.component // "Unknown") + "\n- **Línea:** " + (.line // "N/A" | tostring) + "\n- **Mensaje:** " + (.message // "No message") + "\n- **Esfuerzo:** " + (.effort // "Unknown") + "\n- **Key:** " + (.key // "Unknown") + "\n"' critical_issues.json >> docs/CRITICAL_ISSUES_PRIORITIZATION.md
fi

cat >> docs/CRITICAL_ISSUES_PRIORITIZATION.md << EOF

## 🎯 PLAN DE ACCIÓN RECOMENDADO

### Fase 1: Issues de Seguridad (Prioridad ALTA)
- [ ] Revisar y corregir issues relacionados con validación de entrada
- [ ] Verificar manejo seguro de datos sensibles
- [ ] Corregir problemas de autenticación y autorización

### Fase 2: Bugs Funcionales (Prioridad ALTA)
- [ ] Corregir bugs que afecten funcionalidades core
- [ ] Verificar lógica de negocio crítica
- [ ] Corregir problemas de validación de datos

### Fase 3: Issues de Estabilidad (Prioridad MEDIA)
- [ ] Corregir problemas de manejo de excepciones
- [ ] Verificar gestión de memoria
- [ ] Corregir problemas de concurrencia

### Fase 4: Issues de Rendimiento (Prioridad MEDIA)
- [ ] Optimizar consultas de base de datos
- [ ] Mejorar algoritmos ineficientes
- [ ] Corregir memory leaks

### Fase 5: Issues de Mantenibilidad (Prioridad BAJA)
- [ ] Refactorizar código complejo
- [ ] Mejorar documentación
- [ ] Simplificar lógica de negocio

## 📊 MÉTRICAS DE SEGUIMIENTO

| Métrica | Actual | Objetivo | Fecha Límite |
|---------|--------|----------|--------------|
| Issues Críticos | $CRITICAL_COUNT | 0 | 2 semanas |
| Bugs Críticos | $BUG_COUNT | 0 | 1 semana |
| Tiempo Promedio de Resolución | - | <2 días | - |

## 🔗 ENLACES ÚTILES

- **Dashboard SonarQube:** http://localhost:9000/dashboard?id=temposage-movil
- **Issues Críticos:** http://localhost:9000/project/issues?id=temposage-movil&severities=CRITICAL
- **Bugs Críticos:** http://localhost:9000/project/issues?id=temposage-movil&severities=CRITICAL&types=BUG

---

*Reporte generado automáticamente por el script de análisis de SonarQube*
EOF

log_success "Reporte de priorización generado: docs/CRITICAL_ISSUES_PRIORITIZATION.md"

# Mostrar resumen
log_info "=== RESUMEN DEL ANÁLISIS ==="
echo "🔴 Issues Críticos: $CRITICAL_COUNT"
echo "🐛 Bugs Críticos: $BUG_COUNT"
echo "📄 Reporte generado: docs/CRITICAL_ISSUES_PRIORITIZATION.md"
echo "📊 Datos JSON: critical_issues.json, critical_bugs.json"

# Limpiar archivos temporales
rm -f critical_issues.json critical_bugs.json

log_success "Análisis de issues críticos completado!"
