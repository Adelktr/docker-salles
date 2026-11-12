# TD 5 - Tout lancer avec Docker Compose

**Objectif :** décrire l'application et sa base dans un seul fichier, `compose.yaml`, puis tout démarrer d'un coup. Fini les `docker run` à rallonge.

**Durée :** 50 min

**Règle du TD :** aucune commande et aucune ligne de `compose.yaml` ne sont données. Tu as le modèle de fichier et les commandes dans le [mémo](memo.md), et sur les slides.

Tout se lance depuis le dossier `docker-salles`. Il te faut le `app/Dockerfile` du TD 3 et le fichier `.env` du TD 4.

---

## Étape 0 - Faire de la place

Le conteneur `api` des TD précédents occupe encore le port 3000 : supprime-le.

**Tu dois voir :** `api`, ou `No such container: api` s'il était déjà supprimé. Les deux vont bien.

## Étape 1 - La base seule

À la racine de `docker-salles` (à côté de `.env`, **pas** dans `app`), crée un fichier `compose.yaml`. Pour commencer, il décrit **un seul** service, nommé **`db`**, qui reprend tout ce que tu as fait au TD 4 :

- la même image PostgreSQL ;
- les trois variables `POSTGRES_...` de ton `.env`. Ne recopie **pas** leurs valeurs : fais-les lire dans le `.env` avec la syntaxe `${...}` du mémo. Ton mot de passe ne doit jamais apparaître dans `compose.yaml`, que tu vas commiter ;
- un volume nommé **`donnees`**, branché sur le même dossier qu'au TD 4. N'oublie pas de le déclarer aussi en bas du fichier.

**Attention à l'indentation :** en YAML, ce sont les espaces qui donnent la structure. Utilise 2 espaces, jamais de tabulation.

Démarre les services du projet en tâche de fond, puis affiche leur état.

**Tu dois voir :** au démarrage, `Network docker-salles_default Created`, `Volume "docker-salles_donnees" Created`, `Container docker-salles-db-1 Started`. Puis une ligne `db` avec le statut `Up`.

## Étape 2 - Ajouter l'application

Ajoute un deuxième service, nommé **`api`**, **au-dessus** de `db` et au même niveau d'indentation. Il doit :

- construire son image à partir du Dockerfile du dossier `app` ;
- être accessible sur le port **3000** de ta machine ;
- recevoir les variables qui disent à l'application **où** trouver la base et **comment** s'y connecter. Lesquelles ? Lis le commentaire en haut de `app/server.js` : il donne leurs noms. Leurs valeurs sont les mêmes que celles de la base, lues dans le `.env` ;
- démarrer **après** `db`.

La question piège : quelle adresse donner à l'application pour joindre la base ? Ce n'est pas `localhost`. Relis la slide sur le réseau Compose.

Démarre le tout, **en reconstruisant** l'image de l'application.

**Tu dois voir :** le build de l'application, puis `Container docker-salles-db-1 Running` et `Container docker-salles-api-1 Started`.

## Étape 3 - Vérifier

Ouvre <http://localhost:3000>.

**Tu dois voir :** le bandeau vert **« Base : connectée »** et 5 réservations d'exemple.

Suis le journal du service `api` **en direct**.

**Tu dois voir :** `Salles : application démarrée sur le port 3000`, peut-être une ligne `Base : non connectée` (la base n'était pas encore prête, l'application a réessayé), puis `Base : connectée`. Appuie sur **Ctrl+C** pour arrêter de suivre le journal : ça ne coupe pas l'application.

## Étape 4 - Les données survivent

Sur la page, ajoute une réservation avec le formulaire. Elle apparaît dans la liste.

Arrête et supprime **tous** les conteneurs du projet, **sans** toucher aux volumes.

**Tu dois voir :** les conteneurs et le réseau `Removed`. Le volume, lui, n'est pas dans la liste.

Relance les services, puis recharge la page.

**Tu dois voir :** ta réservation est toujours là. Les conteneurs sont neufs, mais les données étaient dans le volume `donnees`.

## Étape 5 - Le bouton rouge

Arrête tout, **en supprimant aussi les volumes** du projet. Puis relance les services et recharge la page.

**Tu dois voir :** seulement les 5 réservations d'exemple. Ta réservation est perdue pour toujours. Retiens bien la différence entre les deux façons d'arrêter le projet : l'une garde les données, l'autre les efface.

---

## Si ça ne marche pas

| Ce que tu vois | Ce qu'il faut faire |
|---|---|
| `WARN The "POSTGRES_PASSWORD" variable is not set. Defaulting to a blank string.` | Compose ne trouve pas ton `.env`. Il doit être dans le même dossier que `compose.yaml`, et tu dois lancer la commande depuis ce dossier. |
| `yaml: line 4: found character that cannot start any token` ou `mapping values are not allowed` | Problème d'indentation : une tabulation, ou un nombre d'espaces différent. Compare avec le modèle du mémo, niveau par niveau. |
| `Bind for 0.0.0.0:3000 failed: port is already allocated` | Un ancien conteneur occupe le port. Liste les conteneurs pour le trouver, puis supprime-le. |
| La page reste sur « Base : non connectée » | Lis le journal du service `api`. `getaddrinfo ENOTFOUND` : l'adresse de la base est fausse, ce doit être le **nom du service** de la base. `password authentication failed` : tu as changé le mot de passe dans `.env` **après** la création du volume, et la base garde l'ancien. Arrête tout en supprimant les volumes, puis relance. `ECONNREFUSED 127.0.0.1` : tu as donné `localhost` comme adresse. |
| Le journal de `db` affiche `Error: in 18+, these Docker images are configured to store database data...` | Le volume est monté sur l'ancien dossier. Reprends celui du TD 4, puis arrête tout en supprimant les volumes, et relance. |
| `docker: 'compose' is not a docker command` | Ta version de Docker est trop ancienne. Mets Docker Desktop à jour. N'utilise pas `docker-compose` avec un tiret, c'est l'ancienne version. |
| Ta modification du code n'apparaît pas | Il faut relancer en reconstruisant l'image. |

## Bonus - changer le port de l'application

L'application lit la variable `PORT` (3000 par défaut). Fais-la écouter sur le port 4000 **dans** le conteneur, mais accessible sur le port 8000 de **ton ordinateur**. Il te faut deux modifications dans le service `api`.

Vérifie sur <http://localhost:8000>. Tu dois toujours voir « Base : connectée ».

---

## Ce que tu viens d'apprendre

- `compose.yaml` décrit tous les conteneurs d'un projet. Une commande lance tout, une autre arrête tout.
- Les services d'un même projet Compose se parlent **par leur nom**, sur un réseau que Compose crée tout seul.
- Arrêter le projet garde les volumes, sauf si tu demandes explicitement de les supprimer.
