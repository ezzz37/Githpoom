#!/bin/bash

# Colores
RED='\033[0;31m'
NC='\033[0m' # Sin color

# Función para solicitar la ruta del repositorio y cambiar a esa ruta
cambiar_ruta_repositorio() {
  read -p "Ingresa la ruta relativa o absoluta del repositorio: " ruta_repo
  if [ -d "$ruta_repo" ]; then
    cd "$ruta_repo" || { echo "Error: No se pudo acceder al repositorio."; return 1; }
    echo "Ahora estás en el repositorio: $ruta_repo"
    return 0
  else
    echo "Error: La ruta ingresada no es válida."
    return 1
  fi
}

autenticar_git() {
  if cambiar_ruta_repositorio; then
    echo "Iniciando autenticación con GitHub..."
    gh auth login
  fi
}

crear_repositorio() {
  if cambiar_ruta_repositorio; then
    read -p "Nombre del repositorio (en GitHub): " repo_name
    read -p "Privacidad (public o private): " privacidad
    gh repo create "$repo_name" --$privacidad --source=. --remote=origin
  fi
}

agregar_archivos_generales() {
  if cambiar_ruta_repositorio; then
    echo "Agregando todos los archivos..."
    git add .
  fi
}

agregar_archivos_puntuales() {
  if cambiar_ruta_repositorio; then
    read -p "Nombre del archivo(s) a agregar (separados por espacios): " archivos
    git add $archivos
  fi
}

hacer_commit() {
  if cambiar_ruta_repositorio; then
    read -p "Mensaje del commit: " commit_msg
    git commit -m "$commit_msg"
  fi
}

subir_y_sincronizar() {
  if cambiar_ruta_repositorio; then
    git branch -M main
    git push -u origin main
  fi
}

forzar_subida() {
  if cambiar_ruta_repositorio; then
    git push origin main --force
  fi
}

ver_estado() {
  if cambiar_ruta_repositorio; then
    git status
    read -p "Presiona Enter para continuar..."
  fi
}

ver_estado_detallado() {
  if cambiar_ruta_repositorio; then
    echo "Estado detallado del repositorio:"
    git status -s
    read -p "Presiona Enter para continuar..."
  fi
}

crear_rama() {
  if cambiar_ruta_repositorio; then
    read -p "Nombre de la nueva rama: " nueva_rama
    git checkout -b "$nueva_rama"
    git push -u origin "$nueva_rama"
    echo "Rama '$nueva_rama' creada local y remotamente."
  fi
}

eliminar_rama() {
  if cambiar_ruta_repositorio; then
    read -p "Nombre de la rama a eliminar: " rama_eliminar
    git branch -d "$rama_eliminar" || echo "Error al eliminar la rama local. Puede que no esté fusionada."
    git push origin --delete "$rama_eliminar" || echo "Error al eliminar la rama remota."
    echo "Rama '$rama_eliminar' eliminada local y remotamente."
  fi
}

salir() {
  echo "Saliendo..."
  exit 0
}

while true; do
  clear
  echo -e "${RED}====================================================================${NC}"
  echo -e "${RED}"
  echo " ██████╗ ██╗████████╗██╗  ██╗██████╗  ██████╗ ██████╗ ███╗   ███╗"
  echo "██╔════╝ ██║╚══██╔══╝██║  ██║██╔══██╗██╔═══██╗██╔══██╗████╗ ████║"
  echo "██║  ███╗██║   ██║   ███████║██████╔╝██║   ██║██║  ██║██╔████╔██║"
  echo "██║   ██║██║   ██║   ██╔══██║██╔═══╝ ██║   ██║██║  ██║██║╚██╔╝██║"
  echo "╚██████╔╝██║   ██║   ██║  ██║██║     ╚██████╔╝██████╔╝██║ ╚═╝ ██║"
  echo " ╚═════╝ ╚═╝   ╚═╝   ╚═╝  ╚═╝╚═╝      ╚═════╝ ╚═════╝ ╚═╝     ╚═╝"
  echo -e "${NC}"
  echo -e "${RED}====================================================================${NC}"
  echo -e "${RED}[ * ] 1. Autenticarse en GitHub${NC}"
  echo -e "${RED}[ * ] 2. Crear repositorio remoto${NC}"
  echo -e "${RED}[ * ] 3. Agregar todos los archivos${NC}"
  echo -e "${RED}[ * ] 4. Agregar archivos puntuales${NC}"
  echo -e "${RED}[ * ] 5. Hacer commit${NC}"
  echo -e "${RED}[ * ] 6. Subir y sincronizar repositorio${NC}"
  echo -e "${RED}[ * ] 7. Forzar subida al repositorio${NC}"
  echo -e "${RED}[ * ] 8. Ver estado del repositorio${NC}"
  echo -e "${RED}[ * ] 9. Ver estado detallado del repositorio${NC}"
  echo -e "${RED}[ * ] 10. Crear rama local y remota${NC}"
  echo -e "${RED}[ * ] 11. Eliminar rama local y remota${NC}"
  echo -e "${RED}[ * ] 12. Salir${NC}"
  echo -e "${RED}====================================================================${NC}"
  read -p "Selecciona una opción: " opcion

  case $opcion in
    1) autenticar_git;;
    2) crear_repositorio;;
    3) agregar_archivos_generales;;
    4) agregar_archivos_puntuales;;
    5) hacer_commit;;
    6) subir_y_sincronizar;;
    7) forzar_subida;;
    8) ver_estado;;
    9) ver_estado_detallado;;
    10) crear_rama;;
    11) eliminar_rama;;
    12) salir;;
    *) echo -e "${RED}Opción inválida${NC}"; read -p "Presiona Enter para continuar...";;
  esac
done
