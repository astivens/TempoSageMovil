#!/bin/bash

# ====================================
# Script para ejecutar pruebas en TempoSage
# ====================================

# Colores para mensajes
RESET="\033[0m"
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
MAGENTA="\033[35m"
CYAN="\033[36m"
BOLD="\033[1m"
UNDERLINE="\033[4m"

# Símbolos
CHECK_MARK="✓"
CROSS_MARK="✗"
WARNING_MARK="⚠"
RUNNING_MARK="⟳"

# Funciones
function print_header() {
  echo -e "\n${BOLD}${CYAN}▓▒░ EJECUTOR DE PRUEBAS TEMPOSAGE ░▒▓${RESET}\n"
  echo -e "${BLUE}${UNDERLINE}Ejecutando pruebas en modo: $1${RESET}\n"
}

function print_section() {
  echo -e "\n${BOLD}${MAGENTA}▶ $1${RESET}"
}

function print_success() {
  echo -e "${GREEN}${CHECK_MARK} $1${RESET}"
}

function print_error() {
  echo -e "${RED}${CROSS_MARK} $1${RESET}"
}

function print_warning() {
  echo -e "${YELLOW}${WARNING_MARK} $1${RESET}"
}

function print_info() {
  echo -e "${BLUE}ℹ $1${RESET}"
}

function print_running() {
  echo -e "${YELLOW}${RUNNING_MARK} $1${RESET}"
}

function check_dart_installed() {
  if ! command -v dart &> /dev/null; then
    print_error "Dart no está instalado. Por favor, instala Flutter SDK para continuar."
    exit 1
  fi
  print_success "Dart encontrado: $(dart --version)"
}

function check_flutter_installed() {
  if ! command -v flutter &> /dev/null; then
    print_error "Flutter no está instalado. Por favor, instala Flutter SDK para continuar."
    exit 1
  fi
  print_success "Flutter encontrado: $(flutter --version | head -n 1)"
}

function print_help() {
  echo -e "${BOLD}${CYAN}▓▒░ AYUDA DEL EJECUTOR DE PRUEBAS ░▒▓${RESET}\n"
  echo -e "Uso: $0 [opciones]\n"
  echo -e "Opciones:"
  echo -e "  ${YELLOW}--all${RESET}              Ejecuta todas las pruebas"
  echo -e "  ${YELLOW}--unit${RESET}             Ejecuta pruebas unitarias"
  echo -e "  ${YELLOW}--widget${RESET}           Ejecuta pruebas de widget"
  echo -e "  ${YELLOW}--integration${RESET}      Ejecuta pruebas de integración"
  echo -e "  ${YELLOW}--performance${RESET}      Ejecuta pruebas de rendimiento"
  echo -e "  ${YELLOW}--coverage${RESET}         Genera informe de cobertura"
  echo -e "  ${YELLOW}--interactive${RESET}      Modo interactivo (por defecto)"
  echo -e "  ${YELLOW}--help${RESET}             Muestra esta ayuda\n"
  echo -e "Ejemplos:"
  echo -e "  $0 --unit          # Ejecuta pruebas unitarias"
  echo -e "  $0 --all --coverage # Ejecuta todas las pruebas con cobertura"
  echo -e "  $0                 # Inicia el modo interactivo"
}

# Verificación de entorno
function verify_environment() {
  print_section "Verificando entorno de desarrollo"
  
  # Verificar Dart y Flutter
  check_dart_installed
  check_flutter_installed
  
  # Verificar directorios importantes
  if [ ! -d "lib" ]; then
    print_warning "Directorio 'lib' no encontrado"
  else
    print_success "Directorio 'lib' encontrado"
  fi
  
  if [ ! -d "test" ]; then
    print_warning "Directorio 'test' no encontrado"
  else
    print_success "Directorio 'test' encontrado"
  fi
  
  # Verificar scripts/test_runner.dart
  if [ ! -f "scripts/test_runner.dart" ]; then
    print_error "No se encontró el script principal en scripts/test_runner.dart"
    print_info "Creando directorio scripts si no existe..."
    mkdir -p scripts
    exit 1
  else
    print_success "Script test_runner.dart encontrado"
  fi
  
  echo -e "\n${GREEN}${CHECK_MARK} Entorno verificado correctamente${RESET}\n"
}

# Iniciar el ejecutor interactivo
function start_interactive() {
  verify_environment
  print_section "Iniciando modo interactivo"
  print_running "Cargando ejecutor de pruebas..."
  dart scripts/test_runner.dart
}

# Ejecutar pruebas específicas
function run_tests() {
  local test_type=$1
  local coverage=$2
  
  verify_environment
  
  case $test_type in
    "unit")
      print_section "Ejecutando pruebas unitarias"
      if [ "$coverage" = true ]; then
        print_info "Generando cobertura de código"
        dart scripts/test_runner.dart 1 1
      else
        dart scripts/test_runner.dart 1 1
      fi
      ;;
    "widget")
      print_section "Ejecutando pruebas de widget"
      if [ "$coverage" = true ]; then
        print_info "Generando cobertura de código"
        dart scripts/test_runner.dart 2 1
      else
        dart scripts/test_runner.dart 2 1
      fi
      ;;
    "integration")
      print_section "Ejecutando pruebas de integración"
      dart scripts/test_runner.dart 4 1
      ;;
    "performance")
      print_section "Ejecutando pruebas de rendimiento"
      dart scripts/test_runner.dart 3 1
      ;;
    "all")
      print_section "Ejecutando todas las pruebas"
      if [ "$coverage" = true ]; then
        print_info "Generando cobertura de código"
        dart scripts/test_runner.dart 5 2
      else
        dart scripts/test_runner.dart 5 1
      fi
      ;;
    *)
      print_error "Tipo de prueba no reconocido: $test_type"
      print_help
      exit 1
      ;;
  esac
}

# Manejar argumentos
if [ $# -eq 0 ]; then
  start_interactive
  exit 0
fi

# Procesar argumentos
test_type=""
coverage=false

while [ $# -gt 0 ]; do
  case "$1" in
    --unit)
      test_type="unit"
      shift
      ;;
    --widget)
      test_type="widget"
      shift
      ;;
    --integration)
      test_type="integration"
      shift
      ;;
    --performance)
      test_type="performance"
      shift
      ;;
    --all)
      test_type="all"
      shift
      ;;
    --coverage)
      coverage=true
      shift
      ;;
    --interactive)
      start_interactive
      exit 0
      ;;
    --help)
      print_help
      exit 0
      ;;
    *)
      print_error "Opción no reconocida: $1"
      print_help
      exit 1
      ;;
  esac
done

# Ejecutar pruebas si se ha especificado un tipo
if [ -n "$test_type" ]; then
  run_tests "$test_type" "$coverage"
else
  print_warning "No se especificó ningún tipo de prueba"
  print_help
  exit 1
fi 