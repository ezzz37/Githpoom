#!/bin/bash

RED='\033[0;31m'
NC='\033[0m'

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
    git add . || { echo "Error: No se pudieron agregar los archivos."; return 1; }
    echo "Archivos agregados correctamente"
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
    if git diff-index --quiet HEAD --; then
      echo "No hay cambios para hacer commit."
      return 1
    fi
    read -p "Mensaje del commit: " commit_msg
    git commit -m "$commit_msg" || { echo "Error: No se pudo realizar el commit."; return 1; }
    echo "Commit realizado con exito."
  fi
}

subir_y_sincronizar() {
  if cambiar_ruta_repositorio; then
    rama_actual=$(git branch --show-current)
    if [ -z "$rama_actual" ]; then
      echo "Error: No se pudo determinar la rama actual."
      return 1
    fi
    echo "Sincronizando la rama '$rama_actual'..."
    git push -u origin "$rama_actual" || { echo "Error: No se pudo sincronizar la rama '$rama_actual'."; return 1; }
    echo "Rama '$rama_actual' sincronizada con exito."
  fi
}

forzar_subida() {
  if cambiar_ruta_repositorio; then
    rama_actual=$(git branch --show-current)
    if [ -z "$rama_actual" ]; then
      echo "Error: No se pudo determinar la rama actual."
      return 1
    fi
    echo "Forzando la subida de la rama '$rama_actual'..."
    git push origin "$rama_actual" --force || { echo "Error: No se pudo forzar la subida de la rama '$rama_actual'."; return 1; }
    echo "Rama '$rama_actual' subida con éxito (forzado)."
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
    if [ -z "$nueva_rama" ]; then
      echo "Error: El nombre de la rama no puede estar vacio."
      return 1
    fi
    git checkout -b "$nueva_rama"
    git push -u origin "$nueva_rama"
    echo "Rama '$nueva_rama' creada local y remotamente."
  fi
}

eliminar_rama() {
  if cambiar_ruta_repositorio; then
    read -p "Nombre de la rama a eliminar: " rama_eliminar
    if [ -z "$rama_eliminar" ]; then
      echo "Error: El nombre de la rama no puede estar vacio."
      return 1
    fi

    rama_actual=$(git branch --show-current)
    if [ "$rama_actual" == "$rama_eliminar" ]; then
      echo "La rama '$rama_eliminar' esta actualmente activa. Cambiando a otra rama..."
      git checkout master 2>/dev/null || git checkout main 2>/dev/null || {
        echo "Error: No se pudo cambiar a otra rama. Asegurate de que 'master' o 'main' existan."
        return 1
      }
    fi

    git branch -D "$rama_eliminar" && echo "Rama local '$rama_eliminar' eliminada." || {
      echo "Error: No se pudo eliminar la rama local '$rama_eliminar'."
      return 1
    }

    git push origin --delete "$rama_eliminar" && echo "Rama remota '$rama_eliminar' eliminada." || {
      echo "Error: No se pudo eliminar la rama remota '$rama_eliminar'. Verifica si existe."
      return 1
    }
  fi
}

Pull_rama_Con_rebase(){
  if cambiar_ruta_repositorio; then
    read -p "Nombre de la rama a actualizar: " rama_actualizar
    if [ -z "$rama_actualizar" ]; then
      echo "Error: El nombre de la rama no puede estar vacío."
      return 1
    fi
    git checkout "$rama_actualizar"
    git pull --rebase origin "$rama_actualizar"
    echo "Rama '$rama_actualizar' actualizada con rebase."
  fi
}

ver_ramas() {
  if cambiar_ruta_repositorio; then
    echo "Ramas locales:"
    git branch
    echo ""
    echo "Ramas remotas:"
    git branch -r
    read -p "Presiona Enter para continuar..."
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
  echo -e "${RED}[ * ] 12. Actualizar rama con rebase${NC}"
  echo -e "${RED}[ * ] 13. Ver ramas locales y remotas${NC}"
  echo -e "${RED}[ * ] 0. Salir${NC}"
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
    12) Pull_rama_Con_rebase;;
    13) ver_ramas;;
    0) salir;;
    *) echo -e "${RED}Opción inválida${NC}"; read -p "Presiona Enter para continuar...";;
  esac
done
