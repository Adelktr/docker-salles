[← Retour aux TD](../README.md)

# Escape game Docker

Un cargo est bloqué au port. Pour le libérer, il te faut un code de 4 mots, cachés à 4 endroits d'un conteneur. Tu as 30 minutes, en binôme.

Tu n'as besoin que des commandes vues aujourd'hui. **Ne lis pas les fichiers du dossier `escape-game/`** pour trouver les réponses, elles y sont encodées : utilise Docker.

## 1. Lancer le jeu

Ouvre un terminal **à la racine du repo** (le dossier qui contient `escape-game/`), puis tape ces deux commandes, l'une après l'autre :

```
docker build -t escape ./escape-game
```

```
docker run -d --name escape -v escape-data:/coffre-fort escape
```

- La première fabrique l'image du jeu à partir du `Dockerfile`.
- La seconde lance un conteneur `escape`, en tâche de fond (`-d`), avec un volume `escape-data` branché sur le dossier `/coffre-fort`.

## 2. Jouer

Commence par lire le journal du conteneur. Chaque morceau te donne la piste vers le suivant.

Bloqué ? Ouvre l'indice de l'étape où tu es, dans `escape-game/indices/` :

| Étape | Indice |
|---|---|
| 1 | `indices/etape-1.txt` |
| 2 | `indices/etape-2.txt` |
| 3 | `indices/etape-3.txt` |
| 4 | `indices/etape-4.txt` |

Ouvrir un indice n'est pas tricher : c'est fait pour ça.

## 3. Vérifier ton code

Les 4 mots, dans l'ordre, séparés par des tirets :

```
docker run --rm escape verifier MOT1-MOT2-MOT3-MOT4
```

Tu dois voir `BRAVO` ou `RATÉ`. Quand c'est `BRAVO`, lève la main.

## Rejouer depuis le début

```
docker rm -f escape
```

```
docker volume rm escape-data
```

Puis relance les deux commandes de la partie 1.

## Si ça ne marche pas

| Ce que tu vois | Ce qu'il faut faire |
|---|---|
| `Cannot connect to the Docker daemon` ou `error during connect` | Docker Desktop n'est pas lancé. Ouvre-le, attends que la baleine soit verte, recommence. |
| `unable to prepare context: path "./escape-game" not found` | Tu n'es pas à la racine du repo. Va dans le bon dossier avec `cd`. |
| `Conflict. The container name "/escape" is already in use` | Le conteneur existe déjà. Supprime-le avec `docker rm -f escape`, puis relance. |
| `toomanyrequests: You have reached your pull rate limit` | Connecte-toi à Docker Hub : `docker login`, puis recommence. |
| `exec /jeu/partie.sh: no such file or directory` | Problème de fins de ligne Windows. Lance `git config --global core.autocrlf input`, reclone le repo, recommence. |
| `the input device is not a TTY` | Tu es dans Git Bash. Sous Windows, utilise PowerShell. |
