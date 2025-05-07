#!/bin/bash

# Vérifie si l'image "micro-builder" existe déjà
if [[ "$(docker images -q micro-builder 2> /dev/null)" == "" ]]; then
    echo "Image 'micro-builder' non trouvée. Construction..."
    docker build -t micro-builder .
else
    echo "Image 'micro-builder' déjà présente. Skip build."
fi

# Crée le conteneur, copie le binaire, puis le supprime
docker create --name micro_container micro-builder
docker cp micro_container:/build/micro/micro ./micro
docker rm micro_container
