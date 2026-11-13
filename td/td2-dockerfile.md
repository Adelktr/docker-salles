# TD 2 - Ton premier Dockerfile

**Objectif :** écrire toi-même la recette qui transforme l'application Salles en image Docker, puis lancer cette image. Tu n'as pas besoin d'installer Node.js sur ton ordinateur : Docker s'en charge.

**Durée :** 1 h

**Règle du TD :** aucune commande et aucune ligne de Dockerfile ne sont données. Tu as la syntaxe dans le [mémo](memo.md) et sur les slides. Les images se trouvent sur [Docker Hub](https://hub.docker.com).

---

## Étape 1 - Comprendre l'application

Ouvre le dossier `app` : c'est toute l'application. Tu n'as pas besoin de la modifier, mais tu dois la **comprendre** assez pour la faire tourner :

- `package.json` : la liste des dépendances, et la commande de démarrage (dans `scripts`) ;
- `server.js` : l'application. Le haut du fichier dit sur quel port elle écoute.

## Étape 2 - Écrire le Dockerfile

Dans le dossier `app`, crée un fichier nommé exactement `Dockerfile` : avec un D majuscule, **sans extension** (ni `.txt`, ni `.docker`).

Écris dedans la recette de l'image, une instruction par ligne. Ta recette doit :

1. partir de l'image **officielle de Node.js**, en **version 24**, dans sa variante **complète** basée sur Debian **Bookworm** (pas `slim`, pas `alpine` : on allégera au TD 3). Cherche le tag sur Docker Hub ;
2. travailler dans le dossier `/app` de l'image ;
3. copier **tout** le contenu du dossier `app` de ta machine dans ce dossier de l'image ;
4. installer les dépendances de l'application **pendant le build**, avec `npm install` ;
5. documenter le port sur lequel l'application écoute ;
6. démarrer l'application quand un conteneur se lance.

Avant de passer à la suite, relis ton fichier et réponds pour toi-même : quelle ligne s'exécute pendant le build, et laquelle à chaque démarrage de conteneur ?

## Étape 3 - Fabriquer l'image

Depuis le dossier `docker-salles` (pas depuis `app`), fabrique une image nommée **`salles-api`** à partir du Dockerfile du dossier `app`.

**Tu dois voir :** des étapes `[1/4]`, `[2/4]`... qui défilent, puis `naming to docker.io/library/salles-api`. La première fois, ça prend une à deux minutes : Docker télécharge l'image de Node.

## Étape 4 - Lancer un conteneur

Lance un conteneur à partir de l'image `salles-api` :

- en tâche de fond ;
- nommé **`api`** ;
- accessible sur le port **3000** de ton ordinateur.

Ouvre <http://localhost:3000>.

**Tu dois voir :** la page « Salles » avec un bandeau rouge **« Base : non connectée »**. C'est normal : il n'y a pas encore de base de données, elle arrive au TD 4.

## Étape 5 - Tu es bien dans un conteneur

Sur la page, repère la ligne « Cette page est servie par le conteneur : ... ». Puis affiche la liste des conteneurs qui tournent.

**Tu dois voir :** dans la colonne `CONTAINER ID`, le même code que sur la page. Le nom de la machine qui sert la page, c'est le conteneur.

Affiche aussi le journal du conteneur `api`.

**Tu dois voir :** `Salles : application démarrée sur le port 3000`, puis une ligne `Base : non connectée`. L'application cherche une base, n'en trouve pas, et réessaie toute seule.

## Étape 6 - La taille de ton image

Affiche l'image `salles-api` avec sa taille.

**Tu dois voir :** une ligne `salles-api:latest`. La taille est dans la colonne `DISK USAGE` (`SIZE` sur les anciennes versions de Docker) : environ **1,1 Go**. Note-la, on s'en sert au TD 3. Pour une application de deux fichiers, c'est énorme.

## Étape 7 - Modifier le code

Ouvre `app/public/index.html`, et remplace `<h1>Salles</h1>` par `<h1>Salles - mon équipe</h1>`. Enregistre, puis recharge <http://localhost:3000>.

**Tu dois voir :** rien n'a changé.

Pourquoi ? Trouve la réponse, puis fais ce qu'il faut pour voir ton nouveau titre. Indice : trois commandes, et la première supprime quelque chose.

**Tu dois voir :** ton nouveau titre sur <http://localhost:3000>.

À retenir : **modifier le code = rebuild + nouveau conteneur.**

---

## Si ça ne marche pas

| Ce que tu vois | Ce qu'il faut faire |
|---|---|
| `failed to read dockerfile: open Dockerfile: no such file or directory` | Le fichier ne s'appelle pas exactement `Dockerfile`, ou il n'est pas dans `app`. Sous Windows, il s'appelle souvent `Dockerfile.txt` sans que tu le voies : dans l'Explorateur, menu **Affichage**, coche **Extensions de noms de fichiers**, puis renomme le fichier en `Dockerfile`. Même piège plus tard avec `.dockerignore`. |
| `unable to prepare context: path "./app" not found` | Tu n'es pas dans le dossier `docker-salles`. |
| `manifest unknown` ou `not found` sur la ligne `FROM` | Le tag n'existe pas. Vérifie son orthographe exacte dans l'onglet *Tags* de Docker Hub. |
| `npm: not found` | Ton image de départ n'est pas une image Node. |
| `Bind for 0.0.0.0:3000 failed: port is already allocated` | Un autre programme (ou un ancien conteneur) utilise le port 3000. Liste les conteneurs et supprime l'ancien, ou prends le port 3001 sur ta machine. |
| `Conflict. The container name "/api" is already in use` | Supprime de force l'ancien conteneur `api`. |
| `toomanyrequests: You have reached your pull rate limit` | Connecte-toi à Docker Hub (TD 1, étape 2). |
| La page affiche « Cannot GET / », ou rien | Lis le journal du conteneur : le message d'erreur y est. |
| `Error: Cannot find module` | Les dépendances ne sont pas installées dans l'image : vérifie ta ligne `RUN`. |

## Bonus

Les **tags** servent à garder plusieurs versions d'une même image. Fabrique une image `salles-api` avec le tag `v1`. Modifie à nouveau le titre, puis fabrique `salles-api` avec le tag `v2`.

Lance les deux versions en même temps : `v1` sur le port 3001 de ta machine, `v2` sur le port 3002. Compare <http://localhost:3001> et <http://localhost:3002>, puis supprime ces deux conteneurs.

---

## Ce que tu viens d'apprendre

- Un **Dockerfile** est une recette : chaque ligne est une étape de fabrication de l'image.
- `docker build` fabrique l'image, `docker run` crée un conteneur à partir d'elle. Ce sont deux moments différents.
- Une image est figée : si tu modifies le code, il faut la refabriquer.
