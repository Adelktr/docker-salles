# TD 3 - Une image plus légère, plus rapide, plus propre

**Objectif :** améliorer ton Dockerfile du TD 2 en appliquant cinq changements, un par un, et **mesurer** l'effet de chacun. Ton image va passer d'environ 1,5 Go à environ 200 Mo.

**Durée :** 50 min

Tu pars du `app/Dockerfile` du TD 2. Toutes les commandes se lancent depuis le dossier `docker-salles`.

---

## Le tableau à remplir

Recopie ce tableau dans un fichier ou sur une feuille. Tu le complètes à chaque étape.

| Étape | Taille de l'image | `npm install` rejoué après une modif du HTML ? | `.env` présent dans l'image ? | Utilisateur dans le conteneur |
|---|---|---|---|---|
| 0. Départ (TD 2) | | | | |
| 1. Image alpine | | | | |
| 2. Ordre des COPY | | | | |
| 3. .dockerignore | | | | |
| 4. npm ci | | | | |
| 5. USER node | | | | |

Les trois mesures, que tu refais à chaque étape :

**Mesure A - la taille :**

```
docker image ls salles-api
```

**Mesure B - le cache :** modifie une lettre dans `app/public/index.html`, enregistre, puis relance le build et regarde la ligne `RUN npm ...` :

```
docker build -t salles-api ./app
```

Si la ligne `RUN npm ...` est suivie de `CACHED`, Docker a réutilisé le résultat précédent. Sinon, il a tout réinstallé. Note aussi le temps total affiché en haut (`Building 8.4s`, par exemple).

**Mesure C - le contenu et l'utilisateur :**

```
docker run --rm salles-api ls -a
```

```
docker run --rm salles-api whoami
```

`--rm` supprime le conteneur dès que la commande est finie. `ls -a` et `whoami` remplacent, juste pour cette fois, le `CMD` du Dockerfile.

---

## Étape 0 - Mesurer le point de départ

Pour que la mesure C ait du sens, crée un faux fichier secret dans le dossier `app` : un fichier nommé `.env` (avec le point au début) qui contient une seule ligne :

```
SECRET=ne-doit-pas-finir-dans-l-image
```

Puis fais un build, et les trois mesures A, B et C.

**Tu dois voir :** une image d'environ 1 à 1,6 Go ; `RUN npm install` **sans** `CACHED` ; `.env` dans la liste des fichiers ; `root` comme utilisateur. Quatre problèmes : on les règle un par un.

## Étape 1 - Une image de base plus petite

Remplace la première ligne :

```dockerfile
FROM node:24-alpine
```

`alpine` est une version de Linux minuscule (quelques Mo), faite pour les conteneurs. `node:24` embarque un Linux complet, avec des centaines d'outils dont ton application ne se sert pas.

Build, puis mesures A, B et C.

**Tu dois voir :** la taille tombe autour de **150 à 250 Mo**. C'est le plus gros gain du TD.

## Étape 2 - L'ordre des instructions et le cache

Docker fabrique l'image **couche par couche**, une couche par instruction. Au build suivant, il réutilise chaque couche tant que rien n'a changé **au-dessus d'elle**. Dès qu'une couche change, toutes celles qui suivent sont refaites.

Aujourd'hui, `COPY . .` copie tout le code **avant** `npm install`. Une virgule changée dans le HTML suffit à faire refaire `npm install`.

On sépare en deux : d'abord la liste des dépendances (qui change rarement), puis le reste du code (qui change tout le temps). Ton Dockerfile devient :

```dockerfile
FROM node:24-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD ["node", "server.js"]
```

`package*.json` veut dire `package.json` et `package-lock.json`.

Fais un build, puis la mesure B **deux fois** : la première reconstruit tout (le Dockerfile a changé), la seconde montre l'effet.

**Tu dois voir :** à la deuxième modification du HTML, `RUN npm install` est suivi de `CACHED`, et le build ne prend plus qu'une ou deux secondes.

## Étape 3 - Le fichier .dockerignore

La mesure C montre encore ton `.env` **dans l'image**. Quiconque récupère ton image peut lire ton mot de passe.

Crée dans le dossier `app` un fichier nommé exactement `.dockerignore` (avec le point, sans extension) :

```
node_modules
npm-debug.log
.env
```

Il fonctionne comme un `.gitignore` : ces fichiers ne sont jamais envoyés à Docker pendant le build.

Build, puis mesure C.

**Tu dois voir :** `.env` a disparu de la liste. La taille ne bouge pas : c'est un gain de sécurité, pas de poids.

Tu peux maintenant **supprimer le faux fichier `app/.env`**.

## Étape 4 - npm ci au lieu de npm install

Remplace la ligne `RUN npm install` par :

```dockerfile
RUN npm ci --omit=dev
```

- `npm ci` installe **exactement** les versions notées dans `package-lock.json`. Ton image est identique aujourd'hui et dans six mois.
- `--omit=dev` n'installe pas les outils de développement (tests, linters), inutiles pour faire tourner l'application.

Build, puis mesure A.

**Tu dois voir :** presque pas de changement de taille, et c'est normal. Cette application n'a pas d'outils de développement. Sur un vrai projet (React, TypeScript), le gain se compte en centaines de Mo.

## Étape 5 - Ne pas tourner en root

La mesure C affiche `root` : ton application a tous les droits dans le conteneur. Si quelqu'un trouve une faille dans ton code, il a tous les droits aussi.

L'image `node` contient déjà un utilisateur sans privilèges, nommé `node`. Ajoute cette ligne juste **avant** `CMD` :

```dockerfile
USER node
```

Build, puis mesure C.

**Tu dois voir :** `node` au lieu de `root`.

## Le résultat

Ton Dockerfile final :

```dockerfile
FROM node:24-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev
COPY . .
EXPOSE 3000
USER node
CMD ["node", "server.js"]
```

Vérifie que l'application marche toujours :

```
docker rm -f api
```

```
docker run -d --name api -p 3000:3000 salles-api
```

**Tu dois voir :** la page sur <http://localhost:3000>, toujours avec « Base : non connectée ».

Garde ce Dockerfile et ce `.dockerignore` : ce sont ceux de ton projet.

---

## Si ça ne marche pas

| Ce que tu vois | Ce qu'il faut faire |
|---|---|
| `npm ci` : `The npm ci command can only install with an existing package-lock.json` | Le fichier `package-lock.json` n'est pas copié. Vérifie la ligne `COPY package*.json ./` (avec l'étoile). |
| `npm install` n'est jamais `CACHED` | Vérifie que `COPY package*.json ./` et `RUN npm ...` sont bien **avant** `COPY . .`. Et refais la mesure deux fois : la première suit forcément un changement du Dockerfile. |
| `.env` est toujours dans l'image | Le fichier doit s'appeler exactement `.dockerignore`, être dans `app` (à côté du Dockerfile), sans extension `.txt`. |
| `whoami` affiche toujours `root` | La ligne `USER node` doit être après les `RUN` et avant `CMD`. Et il faut refaire le build. |
| `Error: Cannot find module 'express'` au lancement | `RUN npm ...` a disparu ou est après `COPY . .` avec un `.dockerignore` mal écrit. Compare avec le Dockerfile final ci-dessus. |

## Bonus - jusqu'où peux-tu descendre ?

Essaie de faire encore maigrir l'image **sans casser l'application** : la page doit toujours s'afficher. Pistes : d'autres variantes de l'image `node` sur [hub.docker.com/_/node](https://hub.docker.com/_/node), le *multi-stage build* (on en parle demain). Note ta meilleure taille.

---

## Ce que tu viens d'apprendre

- L'**image de base** décide de l'essentiel de la taille : `alpine` divise le poids par six ou plus.
- Une image est faite de **couches** mises en cache : ce qui change rarement en haut, ce qui change souvent en bas.
- `.dockerignore` et `USER node` ne font rien gagner en poids, mais évitent d'embarquer des secrets et de donner tous les droits à ton application.
