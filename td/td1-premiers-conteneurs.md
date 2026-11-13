[← Retour aux TD](../README.md)

# TD 1 - Tes premiers conteneurs

**Objectif :** lancer, observer, entrer dans un conteneur, puis le supprimer.

**Durée :** 40 min

**Règle du TD :** aucune commande n'est donnée. Pour chaque étape, écris toi-même la commande à partir du [mémo](memo.md) (et des slides), et trouve les images sur [Docker Hub](https://hub.docker.com). Vérifie ensuite que tu obtiens bien ce qui est indiqué sous « Tu dois voir ».

**Quel terminal ?** Sous Windows, utilise **PowerShell**, pas Git Bash : Git Bash casse `docker exec -it`. Sous macOS, le **Terminal**.

---

## Étape 1 - Vérifier que Docker tourne

Lance Docker Desktop et attends que l'icône de la baleine indique que Docker est démarré.

Affiche la version de Docker. La commande n'est pas dans le mémo : devine-la, ou cherche dans `docker --help`.

**Tu dois voir :** deux blocs, `Client` et `Server`. Si le bloc `Server` manque, Docker Desktop n'est pas lancé.

## Étape 2 - Te connecter à Docker Hub

Docker Hub est le magasin d'images. Sans compte, toute la classe partage la même limite de téléchargements, et elle sera atteinte en quelques minutes.

Connecte-toi à Docker Hub depuis le terminal. Pas encore de compte ? Crée-le gratuitement sur <https://hub.docker.com/signup>.

**Tu dois voir :** un code et un lien. Ouvre le lien, connecte-toi, puis reviens au terminal. À la fin : `Login Succeeded`.

## Étape 3 - Ton premier conteneur

Sur Docker Hub, trouve l'image officielle **hello-world**, et lance un conteneur à partir de sa version `latest`. C'est la seule fois du cours où `latest` est permis : cette image ne fait qu'afficher un message.

**Tu dois voir :** `Unable to find image 'hello-world:latest' locally`, un téléchargement, puis `Hello from Docker!`.

Docker n'avait pas l'image, il l'a téléchargée, il a créé un conteneur, le conteneur a affiché son message et s'est arrêté.

## Étape 4 - Un vrai serveur web

Lance le serveur web **nginx**, avec ces contraintes :

- l'image : l'image **officielle** de nginx, en **version 1.30**, dans sa variante **slim** construite sur **Alpine 3.24** (la plus légère). Trouve le bon tag dans l'onglet *Tags* de Docker Hub ;
- le conteneur tourne **en tâche de fond** : ton terminal doit rester libre ;
- il s'appelle **`web`** ;
- nginx écoute sur le port **80** du conteneur, et tu veux l'ouvrir sur le port **8080** de ton ordinateur.

**Tu dois voir :** une longue suite de lettres et de chiffres. C'est l'identifiant du conteneur.

Ouvre ton navigateur sur <http://localhost:8080>.

**Tu dois voir :** la page `Welcome to nginx!`

## Étape 5 - Lister les conteneurs

Affiche la liste des conteneurs qui tournent.

**Tu dois voir :** une ligne avec l'image nginx que tu as choisie, le statut `Up ...`, `0.0.0.0:8080->80/tcp` et le nom `web`.

## Étape 6 - Lire le journal du conteneur

Recharge la page dans le navigateur deux ou trois fois, puis affiche ce que le conteneur `web` a écrit.

**Tu dois voir :** des lignes `GET / HTTP/1.1" 200`. Chaque ligne est une visite de ta page.

## Étape 7 - Entrer dans le conteneur

Ouvre un terminal **à l'intérieur** du conteneur `web`. Le programme qui fait office de terminal dans les images alpine s'appelle `sh`.

**Tu dois voir :** une invite qui ressemble à `/ #`. Tu es maintenant **dans** le conteneur.

La page que tu as vue dans le navigateur est rangée dans le dossier `/usr/share/nginx/html`. Liste son contenu.

**Tu dois voir :** `50x.html  index.html`. Puis sors du conteneur.

## Étape 8 - Arrêter, puis supprimer

Arrête le conteneur `web`, puis affiche **tous** les conteneurs, y compris ceux qui sont arrêtés.

**Tu dois voir :** `web` est toujours là, avec le statut `Exited`. Un conteneur arrêté existe encore. Recharge le navigateur : la page ne répond plus.

Supprime le conteneur `web`, puis affiche à nouveau tous les conteneurs.

**Tu dois voir :** `web` a disparu.

## Étape 9 - Les images restent

Affiche la liste des images présentes sur ta machine.

**Tu dois voir :** `hello-world` et `nginx`, avec le tag que tu as choisi. Tu as supprimé le conteneur, mais l'image est toujours là : le prochain conteneur nginx démarrera instantanément.

---

## Si ça ne marche pas

| Ce que tu vois | Ce qu'il faut faire |
|---|---|
| `Cannot connect to the Docker daemon` ou `error during connect` | Docker Desktop n'est pas lancé. Ouvre-le, attends la baleine, recommence. |
| `toomanyrequests: You have reached your pull rate limit` | Tu n'es pas connecté à Docker Hub : refais l'étape 2. |
| `manifest unknown` ou `not found` | Le tag n'existe pas. Vérifie son orthographe exacte dans l'onglet *Tags* de Docker Hub. |
| Le conteneur s'arrête aussitôt (`Exited (127)`), et son journal affiche `8080:80: not found` | Tu as écrit le port **après** le nom de l'image. Tout ce qui suit l'image est pris comme la commande à lancer dans le conteneur. Les options (`-d`, `--name`, `-p`…) vont toutes **avant** l'image. Supprime le conteneur et relance. |
| `Bind for 0.0.0.0:8080 failed: port is already allocated` | Un autre programme utilise déjà le port 8080. Prends le port 8081 sur ta machine et ouvre <http://localhost:8081>. |
| `Conflict. The container name "/web" is already in use` | Un conteneur `web` existe déjà, même arrêté. Supprime-le de force, puis relance. |
| `You cannot remove a running container` | Arrête-le d'abord, ou force la suppression (voir le mémo). |
| `the input device is not a TTY` | Tu es dans Git Bash. Ferme-le et ouvre **PowerShell**. |
| La page du navigateur ne s'affiche pas | Vérifie que le conteneur tourne, et que tu as bien publié le port 80 du conteneur sur le port 8080 de ta machine. |
| Ton terminal reste bloqué sur les logs de nginx | Tu as oublié de lancer le conteneur en tâche de fond. Ctrl+C, supprime le conteneur, recommence. |

## Bonus

Lance **deux** serveurs nginx en même temps, à partir de la même image : `web1` sur le port 8081 de ta machine, `web2` sur le port 8082. Ouvre <http://localhost:8081> et <http://localhost:8082>.

Deux conteneurs, une seule image. Affiche les conteneurs qui tournent, puis supprime les deux **en une seule commande**.

---

## Ce que tu viens d'apprendre

- Une **image** est un modèle, un **conteneur** est une copie de ce modèle qui tourne. Une image peut donner autant de conteneurs que tu veux.
- Une image se trouve sur Docker Hub : l'image **officielle**, avec un **tag** précis.
- `-p` relie un port de ton ordinateur à un port du conteneur. Sans ça, rien n'est accessible depuis ton navigateur.
- `ps`, `logs`, `exec`, `stop` et `rm` suffisent pour observer et piloter n'importe quel conteneur.
