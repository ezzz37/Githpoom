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
    echo "Error: La ruta ingresada no es valida."
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
      echo "Error: El nombre de la rama no puede estar vacio."
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

clonar_repositorio() {
  read -p "Ingresa la URL del repositorio a clonar: " url_repo
  if [ -z "$url_repo" ]; then
    echo "Error: La URL del repositorio no puede estar vacia."
    return 1
  fi
  git clone "$url_repo" || { echo "Error: No se pudo clonar el repositorio."; return 1; }
  echo "Repositorio clonado con exito."
}

cambiar_rama() {
  if cambiar_ruta_repositorio; then
    read -p "Ingresa el nombre de la rama a la que deseas cambiar: " rama_destino
    if [ -z "$rama_destino" ]; then
      echo "Error: El nombre de la rama no puede estar vacio."
      return 1
    fi
    git checkout "$rama_destino" || { echo "Error: No se pudo cambiar a la rama '$rama_destino'."; return 1; }
    echo "Cambiado a la rama '$rama_destino'."
  fi
}

fusionar_rama() {
  if cambiar_ruta_repositorio; then
    read -p "Ingresa el nombre de la rama que deseas fusionar en la rama actual: " rama_fusionar
    if [ -z "$rama_fusionar" ]; then
      echo "Error: El nombre de la rama no puede estar vacio."
      return 1
    fi
    git merge "$rama_fusionar" || { echo "Error: No se pudo fusionar la rama '$rama_fusionar'."; return 1; }
    echo "Rama '$rama_fusionar' fusionada con exito en la rama actual."
  fi
}

revertir_commit() {
  if cambiar_ruta_repositorio; then
    read -p "Ingresa el hash del commit que deseas revertir: " hash_commit
    if [ -z "$hash_commit" ]; then
      echo "Error: El hash del commit no puede estar vacio."
      return 1
    fi
    git revert "$hash_commit" || { echo "Error: No se pudo revertir el commit '$hash_commit'."; return 1; }
    echo "Commit '$hash_commit' revertido con exito."
  fi
}

ver_historial() {
  if cambiar_ruta_repositorio; then
    echo "Historial de commits:"
    git log --oneline --graph --all || { echo "Error: No se pudo mostrar el historial de commits."; return 1; }
    read -p "Presiona Enter para continuar..."
  fi
}

restaurar_archivo() {
  if cambiar_ruta_repositorio; then
    read -p "Ingresa el nombre del archivo que deseas restaurar: " archivo
    if [ -z "$archivo" ]; then
      echo "Error: El nombre del archivo no puede estar vacio."
      return 1
    fi
    git restore "$archivo" || { echo "Error: No se pudo restaurar el archivo '$archivo'."; return 1; }
    echo "Archivo '$archivo' restaurado con exito."
  fi
}

#config de usuario y correo en repo remoto
configurar_usuario() {
  read -p "Ingresa tu nombre de usuario para Git: " nombre_usuario
  read -p "Ingresa tu correo electronico para Git: " correo_usuario
  if [ -z "$nombre_usuario" ] || [ -z "$correo_usuario" ]; then
    echo "Error: El nombre de usuario y el correo electronico no pueden estar vacios."
    return 1
  fi
  git config --global user.name "$nombre_usuario"
  git config --global user.email "$correo_usuario"
  echo "Configuracion de usuario actualizada:"
  git config --global --list
}

eliminar_archivos_preparados() {
  if cambiar_ruta_repositorio; then
    read -p "Ingresa el nombre del archivo(s) a eliminar del area de preparacion (separados por espacios): " archivos
    if [ -z "$archivos" ]; then
      echo "Error: El nombre del archivo no puede estar vacio."
      return 1
    fi
    git restore --staged $archivos || { echo "Error: No se pudieron eliminar los archivos del area de preparacion."; return 1; }
    echo "Archivos eliminados del area de preparacion."
  fi
}

reiniciar_repositorio() {
  if cambiar_ruta_repositorio; then
    read -p "Ingresa el hash del commit al que deseas reiniciar (o deja vacío para HEAD): " hash_commit
    if [ -z "$hash_commit" ]; then
      hash_commit="HEAD"
    fi
    git reset --hard "$hash_commit" || { echo "Error: No se pudo reiniciar el repositorio."; return 1; }
    echo "Repositorio reiniciado al estado del commit '$hash_commit'."
  fi
}

eliminar_archivo() {
  if cambiar_ruta_repositorio; then
    read -p "Ingresa el nombre del archivo a eliminar: " archivo
    if [ -z "$archivo" ]; then
      echo "Error: El nombre del archivo no puede estar vacío."
      return 1
    fi
    git rm "$archivo" || { echo "Error: No se pudo eliminar el archivo '$archivo'."; return 1; }
    git commit -m "Eliminado archivo '$archivo'" || { echo "Error: No se pudo realizar el commit."; return 1; }
    git push || { echo "Error: No se pudo sincronizar los cambios."; return 1; }
    echo "Archivo '$archivo' eliminado del repositorio local y remoto."
  fi
}

ver_diferencias() {
  if cambiar_ruta_repositorio; then
    read -p "Ingresa el hash del primer commit: " commit1
    read -p "Ingresa el hash del segundo commit: " commit2
    if [ -z "$commit1" ] || [ -z "$commit2" ]; then
      echo "Error: Ambos hashes de commits son necesarios."
      return 1
    fi
    git diff "$commit1" "$commit2" || { echo "Error: No se pudieron mostrar las diferencias."; return 1; }
  fi
}

configurar_gitignore() {
  if cambiar_ruta_repositorio; then
    echo "Editando el archivo .gitignore..."
    nano .gitignore || { echo "Error: No se pudo abrir el editor."; return 1; }
    git add .gitignore
    git commit -m "Actualizado archivo .gitignore" || { echo "Error: No se pudo realizar el commit."; return 1; }
    git push || { echo "Error: No se pudo sincronizar los cambios."; return 1; }
    echo "Archivo .gitignore configurado y sincronizado."
  fi
}

limpiar_archivos_no_rastreados() {
  if cambiar_ruta_repositorio; then
    echo "Eliminando archivos no rastreados..."
    git clean -f || { echo "Error: No se pudieron eliminar los archivos no rastreados."; return 1; }
    echo "Archivos no rastreados eliminados."
  fi
}

cambiar_url_remota() {
  if cambiar_ruta_repositorio; then
    read -p "Ingresa la nueva URL del repositorio remoto: " nueva_url
    if [ -z "$nueva_url" ]; then
      echo "Error: La URL no puede estar vacia."
      return 1
    fi
    git remote set-url origin "$nueva_url" || { echo "Error: No se pudo cambiar la URL remota."; return 1; }
    echo "URL remota cambiada a '$nueva_url'."
  fi
}

ver_estadisticas() {
  if cambiar_ruta_repositorio; then
    echo "Estadisticas del repositorio:"
    echo "Numero de commits:"
    git rev-list --count HEAD
    echo "Numero de ramas:"
    git branch | wc -l
    echo "Autores:"
    git shortlog -sn
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
  echo -e "${RED}[ * ] 14. Clonar un repositorio${NC}"
  echo -e "${RED}[ * ] 15. Cambiar de rama${NC}"
  echo -e "${RED}[ * ] 16. Fusionar ramas${NC}"
  echo -e "${RED}[ * ] 17. Revertir un commit${NC}"
  echo -e "${RED}[ * ] 18. Ver historial de commits${NC}"
  echo -e "${RED}[ * ] 19. Restaurar un archivo${NC}"
  echo -e "${RED}[ * ] 20. Configurar usuario de Git${NC}"
  echo -e "${RED}[ * ] 21. Eliminar archivos del área de preparación${NC}"
  echo -e "${RED}[ * ] 22. Reiniciar repositorio${NC}"
  echo -e "${RED}[ * ] 23. Eliminar un archivo del repositorio${NC}"
  echo -e "${RED}[ * ] 24. Ver diferencias entre commits${NC}"
  echo -e "${RED}[ * ] 25. Configurar archivo .gitignore${NC}"
  echo -e "${RED}[ * ] 26. Limpiar archivos no rastreados${NC}"
  echo -e "${RED}[ * ] 27. Cambiar URL del repositorio remoto${NC}"
  echo -e "${RED}[ * ] 28. Ver estadísticas del repositorio${NC}"
  echo -e "${RED}[ * ] 0. Salir${NC}"
  echo -e "${RED}====================================================================${NC}"
  read -p "Selecciona una opcion: " opcion

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
    14) clonar_repositorio;;
    15) cambiar_rama;;
    16) fusionar_rama;;
    17) revertir_commit;;
    18) ver_historial;;
    19) restaurar_archivo;;
    20) configurar_usuario;;
    21) eliminar_archivos_preparados;;
    22) reiniciar_repositorio;;
    23) eliminar_archivo;;
    24) ver_diferencias;;
    25) configurar_gitignore;;
    26) limpiar_archivos_no_rastreados;;
    27) cambiar_url_remota;;
    28) ver_estadisticas;;
    0) salir;;
    *) echo -e "${RED}Opción invalida${NC}"; read -p "Presiona Enter para continuar...";;
  esac
done
