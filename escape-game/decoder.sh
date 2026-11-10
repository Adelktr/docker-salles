#!/bin/sh
# Décode une variable d'environnement encodée en base64 : decoder NOM_DE_LA_VARIABLE
if [ -z "$1" ] || [ -z "$(printenv "$1")" ]; then
  echo "Usage : decoder NOM_DE_LA_VARIABLE (exemple : decoder MORCEAU_2)"
  exit 1
fi
printenv "$1" | base64 -d
