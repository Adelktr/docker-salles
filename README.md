# docker-salles

Repo de départ du cours **Initiation à Docker** (IIM, A3 Web development & Innovations).

**Salles** est une petite application de réservation de salles de l'école : une page web, une API Node.js et une base PostgreSQL. Toutes les données sont fictives.

L'application est **déjà écrite**. Ton travail, c'est de la faire tourner dans Docker : écrire le `Dockerfile`, le `.dockerignore` et le `compose.yaml`.

## Avant le cours

1. Installe [Docker Desktop](https://www.docker.com/products/docker-desktop/). Sous Windows, accepte l'installation de WSL 2 quand elle t'est proposée.
2. Crée un compte gratuit sur [Docker Hub](https://hub.docker.com/signup).
3. Ouvre Docker Desktop et attends que la baleine indique que Docker est démarré.

Tu n'as **pas besoin** d'installer Node.js ni PostgreSQL : tout tourne dans Docker.

**Quel terminal ?** Sous Windows, utilise **PowerShell**, pas Git Bash : Git Bash casse `docker exec -it`. Sous macOS, le **Terminal**.

## Structure

```
docker-salles/
  app/
    server.js          toute l'application (tu n'as pas besoin de la modifier)
    public/index.html  la page web
    package.json       les dépendances
  td/                  les énoncés des TD, à faire dans l'ordre, et le mémo des commandes
  escape-game/         le jeu bonus, si tu as fini le TD 4
  .env.example         le modèle de fichier de configuration
```

Ce que **tu** ajoutes au fil des TD :

```
  app/Dockerfile       TD 2 et 3
  app/.dockerignore    TD 3
  .env                 TD 4 (jamais commité)
  compose.yaml         TD 5
```

## Les TD, dans l'ordre

| TD | Sujet | Durée |
|---|---|---|
| [TD 1](td/td1-premiers-conteneurs.md) | Tes premiers conteneurs | 40 min |
| [TD 2](td/td2-dockerfile.md) | Ton premier Dockerfile | 1 h |
| [TD 3](td/td3-couches-et-cache.md) | Une image plus légère, plus rapide, plus propre | 50 min |
| [TD 4](td/td4-volumes.md) | Des données qui survivent | fin de lundi, à finir chez toi si besoin |
| [TD 5](td/td5-compose.md) | Tout lancer avec Docker Compose | 50 min |

Les TD ne donnent **aucune commande** : c'est à toi de les écrire, à partir du [mémo](td/memo.md), et de trouver les images sur [Docker Hub](https://hub.docker.com). Chaque étape te dit ce que tu dois voir pour savoir si tu as réussi, et chaque TD a une section « Si ça ne marche pas » avec les erreurs les plus courantes. Lis-la avant de lever la main.

## Escape game

Un bonus pour ceux qui ont fini le TD 4 : [escape-game/LANCER.md](escape-game/LANCER.md). Il se fait dans le repo `docker-salles`.

## Lancer l'application

À compléter par ton binôme pendant le projet : ce qu'il faut installer, comment créer le `.env`, la commande de lancement et l'URL à ouvrir.
