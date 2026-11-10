#!/bin/sh
# Escape game Docker.
# Les messages sont encodés pour que lire ce fichier ne donne pas les réponses.
# Joue le jeu : utilise les commandes Docker, pas ce fichier.

d() { echo "$1" | base64 -d; }

# --- Vérification du code : docker run --rm escape verifier MOT1-MOT2-MOT3-MOT4
if [ "$1" = "verifier" ]; then
  propose=$(printf '%s' "$2" | tr 'a-z' 'A-Z' | tr -d ' ')
  if [ "$(printf '%s' "$propose" | sha256sum | cut -d' ' -f1)" = "51e9923b1e43b43e4efc7c5bf8d7a06411b26dbc37b8e9a7e0ce84d9111deb3d" ]; then
    echo ""
    echo "  BRAVO ! Le cargo est libéré. Tu as fini l'escape game."
    echo ""
  else
    echo ""
    echo "  RATÉ. Vérifie tes 4 mots, dans l'ordre, séparés par des tirets."
    echo "  Exemple de format : docker run --rm escape verifier MOT1-MOT2-MOT3-MOT4"
    echo ""
    exit 1
  fi
  exit 0
fi

# --- Étape 3 : le dossier /cachette, avec un fichier caché parmi des leurres
if [ ! -d /cachette ]; then
  mkdir -p /cachette
  echo 'UmllbiBpY2kuIENoZXJjaGUgbWlldXguCg==' | base64 -d > /cachette/rien-ici.txt
  echo 'VG91am91cnMgcmllbi4gQ2VydGFpbnMgZmljaGllcnMgbmUgc2UgbW9udHJlbnQgcGFzIGZhY2lsZW1lbnQuCg==' | base64 -d > /cachette/toujours-rien.txt
  echo 'Q29yZGUsIGZpbGV0LCBnaWxldCBkZSBzYXV2ZXRhZ2UuCg==' | base64 -d > /cachette/liste-de-courses.txt
  echo 'CiAgTU9SQ0VBVSAzIDogQU5DUkUKCkRlcm5pw6hyZSDDqXRhcGUuIExlIG1vcmNlYXUgNCBzZXJhIGTDqXBvc8OpIGRhbnMgbGUgY29mZnJlLWZvcnQKKGxlIHZvbHVtZSBlc2NhcGUtZGF0YSwgbW9udMOpIHN1ciAvY29mZnJlLWZvcnQpIGF1IG1vbWVudCBvw7kgY2UKY29udGVuZXVyIHMnQVJSw4pURVJBIFBST1BSRU1FTlQuCgogIDEuIEFycsOqdGUgbGUgY29udGVuZXVyIGF2ZWMgZG9ja2VyIHN0b3AKICAgICAocGFzIGRvY2tlciBybSAtZiA6IGlsIHR1ZSBsZSBjb250ZW5ldXIgc2FucyBwcsOpdmVuaXIsCiAgICAgZXQgbGUgbW9yY2VhdSBuZSBzZXJhIGphbWFpcyDDqWNyaXQpLgogIDIuIExlIGNvbnRlbmV1ciBlc3QgYXJyw6p0w6kgOiB0dSBuZSBwZXV4IHBsdXMgZmFpcmUgZGUgZXhlYy4KICAgICBNYWlzIGxlIHZvbHVtZSwgbHVpLCBleGlzdGUgdG91am91cnMuIExhbmNlIHVuIEFVVFJFCiAgICAgY29udGVuZXVyIChhbHBpbmU6My4yMikgcXVpIG1vbnRlIGxlIHZvbHVtZSBlc2NhcGUtZGF0YSwKICAgICBldCBsaXMgbGUgZmljaGllciBtb3JjZWF1LTQudHh0LgoKQmxvcXXDqSA/IE91dnJlIGVzY2FwZS1nYW1lL2luZGljZXMvZXRhcGUtNC50eHQK' | base64 -d > /cachette/.morceau-3
fi

# --- Étape 4 : le morceau 4 n'est écrit dans le volume qu'à l'arrêt propre
ecrire_morceau_4() {
  mkdir -p /coffre-fort
  echo 'CiAgTU9SQ0VBVSA0IDogQk9VU1NPTEUKCkxlIGNvbnRlbmV1ciBlc3QgbW9ydCwgbWFpcyBsZSBmaWNoaWVyIGVzdCB0b3Vqb3VycyBsw6AgOgpjJ2VzdCB0b3V0IGwnaW50w6lyw6p0IGQndW4gdm9sdW1lLgoKVHUgYXMgbGVzIDQgbW9yY2VhdXguIFbDqXJpZmllIHRvbiBjb2RlLCBtb3RzIGRhbnMgbCdvcmRyZSwKc8OpcGFyw6lzIHBhciBkZXMgdGlyZXRzIDoKCiAgZG9ja2VyIHJ1biAtLXJtIGVzY2FwZSB2ZXJpZmllciBNT1QxLU1PVDItTU9UMy1NT1Q0Cg==' | base64 -d > /coffre-fort/morceau-4.txt
  echo "Arrêt demandé : le morceau 4 a été déposé dans le coffre-fort."
  exit 0
}
trap ecrire_morceau_4 TERM INT

# --- Étape 1 : le message d'accueil, dans le journal du conteneur
d 'Cj09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09CiAgRVNDQVBFIEdBTUUgRE9DS0VSCj09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09ClVuIGNhcmdvIGVzdCBibG9xdcOpIGF1IHBvcnQuIFBvdXIgbGUgbGliw6lyZXIsIGlsIHRlIGZhdXQgdW4KY29kZSBkZSA0IG1vdHMsIGNhY2jDqXMgw6AgNCBlbmRyb2l0cyBkZSBjZSBjb250ZW5ldXIuCgogIE1PUkNFQVUgMSA6IENBUkdPCgpMZSBtb3JjZWF1IDIgc2UgY2FjaGUgZGFucyBsZXMgVkFSSUFCTEVTIEQnRU5WSVJPTk5FTUVOVCBkZQpjZSBjb250ZW5ldXIuIFBvdXIgbGFuY2VyIHVuZSBjb21tYW5kZSDDgCBMJ0lOVMOJUklFVVIgZCd1bgpjb250ZW5ldXIgcXVpIHRvdXJuZSwgb24gdXRpbGlzZSA6IGRvY2tlciBleGVjCkxhIGNvbW1hbmRlIHF1aSBsaXN0ZSBsZXMgdmFyaWFibGVzIGQnZW52aXJvbm5lbWVudCA6IGVudgoKQmxvcXXDqSA/IE91dnJlIGVzY2FwZS1nYW1lL2luZGljZXMvZXRhcGUtMi50eHQKPT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT0K'

# Le conteneur reste en vie en attendant docker stop.
while true; do
  sleep 1 &
  wait $!
done
