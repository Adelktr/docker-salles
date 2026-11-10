# TD 5 - Tout lancer avec une seule commande

**Objectif :** décrire l'application et sa base dans un seul fichier, `compose.yaml`, puis tout démarrer avec une seule commande. Fini les `docker run` à rallonge.

**Durée :** 50 min

Toutes les commandes se lancent depuis le dossier `docker-salles`. Il te faut le `app/Dockerfile` du TD 3 et le fichier `.env` du TD 4.

---

## Étape 0 - Faire de la place

Le conteneur `api` des TD précédents occupe encore le port 3000 :

```
docker rm -f api
```

**Tu dois voir :** `api`, ou `No such container: api` s'il était déjà supprimé. Les deux vont bien.

## Étape 1 - La base seule

À la racine de `docker-salles` (à côté de `.env`, **pas** dans `app`), crée un fichier `compose.yaml` :

```yaml
services:
  db:
    image: postgres:18-alpine
    environment:
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: ${POSTGRES_DB}
    volumes:
      - donnees:/var/lib/postgresql

volumes:
  donnees:
```

- `services` liste les conteneurs à lancer. Ici, un seul, nommé `db`.
- `${POSTGRES_USER}` est remplacé par la valeur de ton `.env`. Compose lit ce fichier tout seul : ton mot de passe n'est jamais écrit dans `compose.yaml`, que tu vas commiter.
- `volumes` en bas déclare le volume `donnees`, et `- donnees:/var/lib/postgresql` le branche dans le conteneur, comme ton `-v` du TD 4.

**Attention à l'indentation** : en YAML, ce sont les espaces qui donnent la structure. Utilise 2 espaces, jamais de tabulation.

Démarre :

```
docker compose up -d
```

**Tu dois voir :** `Network docker-salles_default Created`, `Volume "docker-salles_donnees" Created`, `Container docker-salles-db-1 Started`.

```
docker compose ps
```

**Tu dois voir :** une ligne `db` avec le statut `Up`.

## Étape 2 - Ajouter l'application

Complète `compose.yaml` en ajoutant le service `api` **au-dessus** de `db`, au même niveau d'indentation :

```yaml
services:
  api:
    build: ./app
    ports:
      - "3000:3000"
    environment:
      PGHOST: db
      PGUSER: ${POSTGRES_USER}
      PGPASSWORD: ${POSTGRES_PASSWORD}
      PGDATABASE: ${POSTGRES_DB}
    depends_on:
      - db

  db:
    image: postgres:18-alpine
    environment:
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: ${POSTGRES_DB}
    volumes:
      - donnees:/var/lib/postgresql

volumes:
  donnees:
```

| Ligne | Ce qu'elle veut dire |
|---|---|
| `build: ./app` | fabrique l'image à partir du Dockerfile de `app`, comme ton `docker build` |
| `ports: "3000:3000"` | comme ton `-p 3000:3000` |
| `PGHOST: db` | l'application doit chercher la base à l'adresse `db`, le **nom du service** |
| `PGUSER`, `PGPASSWORD`, `PGDATABASE` | les mêmes identifiants que la base, lus dans `.env` |
| `depends_on: - db` | démarre `db` avant `api` |

Démarre le tout. `--build` demande de fabriquer l'image de l'application :

```
docker compose up -d --build
```

**Tu dois voir :** le build de l'application, puis `Container docker-salles-db-1 Running` et `Container docker-salles-api-1 Started`.

> **Le réseau, en une phrase.** Compose crée un réseau privé pour ton projet (`docker-salles_default`) et y branche tous les services. Dans ce réseau, chaque service est joignable **par son nom** : c'est pour ça que `PGHOST: db` suffit. Pas besoin d'adresse IP, pas besoin d'ouvrir le port de la base sur ton ordinateur.

## Étape 3 - Vérifier

Ouvre <http://localhost:3000>.

**Tu dois voir :** le bandeau vert **« Base : connectée »** et 5 réservations d'exemple.

Regarde le journal de l'application en direct :

```
docker compose logs -f api
```

**Tu dois voir :** `Salles : application démarrée sur le port 3000`, peut-être une ligne `Base : non connectée` (la base n'était pas encore prête, l'application a réessayé), puis `Base : connectée`. `-f` suit le journal en direct : appuie sur **Ctrl+C** pour en sortir. Ça ne coupe pas l'application.

## Étape 4 - Les données survivent

Sur la page, ajoute une réservation avec le formulaire. Elle apparaît dans la liste.

Arrête et supprime **tous** les conteneurs du projet :

```
docker compose down
```

**Tu dois voir :** les conteneurs et le réseau `Removed`. Le volume, lui, n'est pas dans la liste.

Relance :

```
docker compose up -d
```

Recharge la page.

**Tu dois voir :** ta réservation est toujours là. Les conteneurs sont neufs, mais les données étaient dans le volume `donnees`.

## Étape 5 - Le bouton rouge

```
docker compose down -v
```

`-v` supprime **aussi** les volumes du projet.

```
docker compose up -d
```

**Tu dois voir :** sur la page, seulement les 5 réservations d'exemple. Ta réservation est perdue pour toujours. Retiens bien la différence : `down` garde les données, `down -v` les efface.

---

## Si ça ne marche pas

| Ce que tu vois | Ce qu'il faut faire |
|---|---|
| `WARN The "POSTGRES_PASSWORD" variable is not set. Defaulting to a blank string.` | Compose ne trouve pas ton `.env`. Il doit être dans le même dossier que `compose.yaml`, et tu dois lancer la commande depuis ce dossier. |
| `yaml: line 4: found character that cannot start any token` ou `mapping values are not allowed` | Problème d'indentation : une tabulation, ou un nombre d'espaces différent. Compare caractère par caractère avec le modèle. |
| `Bind for 0.0.0.0:3000 failed: port is already allocated` | Un ancien conteneur occupe le port. `docker ps` pour le trouver, puis `docker rm -f` suivi de son nom. |
| La page reste sur « Base : non connectée » | Lis `docker compose logs api`. `password authentication failed` : tu as changé le mot de passe dans `.env` **après** la création du volume, et la base garde l'ancien. Fais `docker compose down -v`, puis `docker compose up -d`. `getaddrinfo ENOTFOUND db` : vérifie `PGHOST: db` et le nom du service `db`. |
| `docker compose logs db` affiche `Error: in 18+, these Docker images are configured to store database data...` | Le volume est monté sur `/var/lib/postgresql/data`. Depuis PostgreSQL 18, c'est `/var/lib/postgresql`. Corrige, puis `docker compose down -v` et `docker compose up -d`. |
| `unknown shorthand flag: 'd' in -d` ou `docker: 'compose' is not a docker command` | Ta version de Docker est trop ancienne. Mets Docker Desktop à jour. N'utilise pas `docker-compose` avec un tiret, c'est l'ancienne version. |
| Ta modification du code n'apparaît pas | Il faut refabriquer l'image : `docker compose up -d --build`. |

## Bonus - changer le port de l'application

L'application lit la variable `PORT` (3000 par défaut). Fais-la écouter sur le port 4000 **dans** le conteneur, mais accessible sur le port 8000 de **ton ordinateur**. Il te faut deux modifications dans le service `api` : une ligne dans `environment`, et la ligne de `ports`.

Vérifie sur <http://localhost:8000>. Tu dois toujours voir « Base : connectée ».

---

## Ce que tu viens d'apprendre

- `compose.yaml` décrit tous les conteneurs d'un projet. `docker compose up -d --build` lance tout, `docker compose down` arrête tout.
- Les services d'un même projet Compose se parlent **par leur nom** (`db`), sur un réseau que Compose crée tout seul.
- `down` garde les volumes, `down -v` les détruit avec les données.
