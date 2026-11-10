# TD 2 - Ton premier Dockerfile

**Objectif :** écrire la recette qui transforme l'application Salles en image Docker, puis lancer cette image. Tu n'as pas besoin d'installer Node.js sur ton ordinateur : Docker s'en charge.

**Durée :** 1 h

---

## Étape 1 - Récupérer le projet

L'adresse du repo est postée sur le canal de la classe. Remplace `ADRESSE_DU_REPO` par cette adresse :

```
git clone ADRESSE_DU_REPO docker-salles
```

```
cd docker-salles
```

**Tu dois voir :** avec `ls` (macOS) ou `dir` (Windows), les dossiers `app`, `td` et `escape-game`.

Ouvre le dossier `docker-salles` dans ton éditeur (VS Code par exemple). Regarde `app/server.js` : c'est toute l'application. Tu n'as pas besoin de la modifier.

## Étape 2 - Créer le fichier Dockerfile

Dans le dossier `app`, crée un fichier nommé exactement `Dockerfile` : avec un D majuscule, **sans extension** (ni `.txt`, ni `.docker`).

Écris dedans, ligne par ligne, en lisant l'explication de chaque ligne :

```dockerfile
FROM node:24
```
Pars d'une image qui contient déjà Node.js, en version 24. On ne part jamais de rien.

```dockerfile
WORKDIR /app
```
Dans l'image, place-toi dans le dossier `/app` (il est créé s'il n'existe pas). Toutes les commandes suivantes s'exécutent là.

```dockerfile
COPY . .
```
Copie tout le contenu du dossier `app` de ton ordinateur (le premier `.`) dans le dossier courant de l'image, `/app` (le second `.`).

```dockerfile
RUN npm install
```
Pendant la fabrication de l'image, installe les dépendances (express, pg).

```dockerfile
EXPOSE 3000
```
Indique que l'application écoute sur le port 3000. C'est de la documentation : ça n'ouvre rien tout seul.

```dockerfile
CMD ["node", "server.js"]
```
La commande à lancer quand un conteneur démarre à partir de cette image.

Ton fichier complet :

```dockerfile
FROM node:24
WORKDIR /app
COPY . .
RUN npm install
EXPOSE 3000
CMD ["node", "server.js"]
```

## Étape 3 - Fabriquer l'image

Depuis le dossier `docker-salles` (pas depuis `app`) :

```
docker build -t salles-api ./app
```

`-t salles-api` donne un nom à l'image. `./app` indique le dossier qui contient le `Dockerfile`.

**Tu dois voir :** des étapes `[1/4]`, `[2/4]`... qui défilent, puis `naming to docker.io/library/salles-api`. La première fois, ça prend une à deux minutes : Docker télécharge l'image `node:24`.

## Étape 4 - Lancer un conteneur

```
docker run -d --name api -p 3000:3000 salles-api
```

Ouvre <http://localhost:3000>.

**Tu dois voir :** la page « Salles » avec un bandeau rouge **« Base : non connectée »**. C'est normal : il n'y a pas encore de base de données, elle arrive au TD 4.

## Étape 5 - Tu es bien dans un conteneur

Sur la page, repère la ligne « Cette page est servie par le conteneur : ... ». Puis :

```
docker ps
```

**Tu dois voir :** dans la colonne `CONTAINER ID`, le même code que sur la page. Le nom de la machine qui sert la page, c'est le conteneur.

Regarde aussi le journal :

```
docker logs api
```

**Tu dois voir :** `Salles : application démarrée sur le port 3000`, puis une ligne `Base : non connectée`. L'application cherche une base, n'en trouve pas, et réessaie toute seule.

## Étape 6 - La taille de ton image

```
docker image ls salles-api
```

**Tu dois voir :** une taille autour de **1 à 1,6 Go**. Note-la, on s'en sert au TD 3. Pour une application de deux fichiers, c'est énorme.

## Étape 7 - Modifier le code

Ouvre `app/public/index.html`, et remplace `<h1>Salles</h1>` par `<h1>Salles - mon équipe</h1>`. Enregistre, puis recharge <http://localhost:3000>.

**Tu dois voir :** rien n'a changé. Le conteneur a été créé à partir de l'image, et l'image a été fabriquée **avant** ta modification.

Pour voir ta modification, il faut refabriquer l'image et recréer le conteneur :

```
docker rm -f api
```

```
docker build -t salles-api ./app
```

```
docker run -d --name api -p 3000:3000 salles-api
```

**Tu dois voir :** ton nouveau titre sur <http://localhost:3000>.

À retenir : **modifier le code = rebuild + nouveau conteneur.**

---

## Si ça ne marche pas

| Ce que tu vois | Ce qu'il faut faire |
|---|---|
| `failed to read dockerfile: open Dockerfile: no such file or directory` | Le fichier ne s'appelle pas exactement `Dockerfile`, ou il n'est pas dans `app`. Sous Windows, il s'appelle souvent `Dockerfile.txt` sans que tu le voies : dans l'Explorateur, menu **Affichage**, coche **Extensions de noms de fichiers**, puis renomme le fichier en `Dockerfile`. Même piège plus tard avec `.dockerignore`. |
| `unable to prepare context: path "./app" not found` | Tu n'es pas dans le dossier `docker-salles`. Fais `cd docker-salles`. |
| `Bind for 0.0.0.0:3000 failed: port is already allocated` | Un autre programme (ou un ancien conteneur) utilise le port 3000. Lance `docker ps` et supprime l'ancien conteneur, ou utilise `-p 3001:3000` et ouvre <http://localhost:3001>. |
| `Conflict. The container name "/api" is already in use` | Supprime l'ancien conteneur : `docker rm -f api`. |
| `toomanyrequests: You have reached your pull rate limit` | Lance `docker login` (voir TD 1, étape 2). |
| La page affiche « Cannot GET / » ou rien | Lis `docker logs api` : le message d'erreur y est. |

## Bonus

Les **tags** servent à garder plusieurs versions d'une même image :

```
docker build -t salles-api:v1 ./app
```

Modifie à nouveau le titre, puis :

```
docker build -t salles-api:v2 ./app
```

```
docker run -d --name api-v1 -p 3001:3000 salles-api:v1
```

```
docker run -d --name api-v2 -p 3002:3000 salles-api:v2
```

Compare <http://localhost:3001> et <http://localhost:3002>. Puis fais le ménage : `docker rm -f api-v1 api-v2`.

---

## Ce que tu viens d'apprendre

- Un **Dockerfile** est une recette : chaque ligne est une étape de fabrication de l'image.
- `docker build` fabrique l'image, `docker run` crée un conteneur à partir d'elle. Ce sont deux moments différents.
- Une image est figée : si tu modifies le code, il faut la refabriquer.
