# TD 1 - Tes premiers conteneurs

**Objectif :** lancer, observer, entrer dans un conteneur, puis le supprimer. À la fin, les commandes de base de Docker n'ont plus de secret pour toi.

**Durée :** 40 min

**Quel terminal ?** Sous Windows, utilise **PowerShell**, pas Git Bash : Git Bash casse `docker exec -it`. Sous macOS, le **Terminal**.

Tape chaque commande **une par une**. Après chaque commande, vérifie que tu vois bien ce qui est indiqué sous « Tu dois voir ».

---

## Étape 1 - Vérifier que Docker tourne

Lance Docker Desktop et attends que l'icône de la baleine indique que Docker est démarré. Puis :

```
docker version
```

**Tu dois voir :** deux blocs, `Client` et `Server`. Si le bloc `Server` manque, Docker Desktop n'est pas lancé.

## Étape 2 - Te connecter à Docker Hub

Docker Hub est le magasin d'images. Sans compte, toute la classe partage la même limite de téléchargements et elle sera atteinte en quelques minutes.

```
docker login
```

**Tu dois voir :** un code et un lien. Ouvre le lien, connecte-toi avec ton compte Docker (gratuit), puis reviens au terminal. À la fin : `Login Succeeded`.

## Étape 3 - Ton premier conteneur

```
docker run hello-world
```

**Tu dois voir :** `Unable to find image 'hello-world:latest' locally`, un téléchargement, puis `Hello from Docker!`.

Docker n'avait pas l'image, il l'a téléchargée, il a créé un conteneur, le conteneur a affiché son message et s'est arrêté.

## Étape 4 - Un vrai serveur web

```
docker run -d --name web -p 8080:80 nginx:1.29-alpine
```

| Morceau | Ce qu'il veut dire |
|---|---|
| `-d` | lance le conteneur en tâche de fond (il ne bloque pas ton terminal) |
| `--name web` | donne-lui un nom, pour l'appeler facilement ensuite |
| `-p 8080:80` | le port 8080 de TON ordinateur mène au port 80 du conteneur |
| `nginx:1.29-alpine` | l'image à utiliser : le serveur web nginx, version 1.29 |

**Tu dois voir :** une longue suite de lettres et de chiffres. C'est l'identifiant du conteneur.

Ouvre ton navigateur sur <http://localhost:8080>.

**Tu dois voir :** la page `Welcome to nginx!`

## Étape 5 - Lister les conteneurs

```
docker ps
```

**Tu dois voir :** une ligne avec `nginx:1.29-alpine`, le statut `Up ...`, `0.0.0.0:8080->80/tcp` et le nom `web`.

## Étape 6 - Lire le journal du conteneur

Recharge la page dans le navigateur deux ou trois fois, puis :

```
docker logs web
```

**Tu dois voir :** des lignes `GET / HTTP/1.1" 200`. Chaque ligne est une visite de ta page.

## Étape 7 - Entrer dans le conteneur

```
docker exec -it web sh
```

**Tu dois voir :** une invite qui ressemble à `/ #`. Tu es maintenant **dans** le conteneur. Tape :

```
ls /usr/share/nginx/html
```

**Tu dois voir :** `50x.html  index.html`. C'est la page que tu as vue dans le navigateur. Pour sortir du conteneur :

```
exit
```

## Étape 8 - Arrêter, puis supprimer

```
docker stop web
```

```
docker ps -a
```

**Tu dois voir :** `web` est toujours là, avec le statut `Exited`. Un conteneur arrêté existe encore. Recharge le navigateur : la page ne répond plus.

```
docker rm web
```

```
docker ps -a
```

**Tu dois voir :** `web` a disparu.

## Étape 9 - Les images restent

```
docker images
```

**Tu dois voir :** `hello-world` et `nginx` (tag `1.29-alpine`). Tu as supprimé le conteneur, mais l'image est toujours là : le prochain `docker run` sera instantané.

---

## Si ça ne marche pas

| Ce que tu vois | Ce qu'il faut faire |
|---|---|
| `Cannot connect to the Docker daemon` ou `error during connect` | Docker Desktop n'est pas lancé. Ouvre-le, attends la baleine, recommence. |
| `toomanyrequests: You have reached your pull rate limit` | Tu n'es pas connecté à Docker Hub : refais l'étape 2. |
| `Bind for 0.0.0.0:8080 failed: port is already allocated` | Un autre programme utilise déjà le port 8080. Remplace `8080:80` par `8081:80` et ouvre <http://localhost:8081>. |
| `Conflict. The container name "/web" is already in use` | Un conteneur `web` existe déjà. Supprime-le avec `docker rm -f web`, puis relance. |
| `You cannot remove a running container` | Arrête-le d'abord avec `docker stop web`, ou force avec `docker rm -f web`. |
| `the input device is not a TTY` après `docker exec -it` | Tu es dans Git Bash. Ferme-le et ouvre **PowerShell**. |
| La page du navigateur ne s'affiche pas | Vérifie avec `docker ps` que le conteneur tourne et que tu as bien mis `-p 8080:80`. |

## Bonus

Lance **deux** serveurs nginx en même temps, sur deux ports différents :

```
docker run -d --name web1 -p 8081:80 nginx:1.29-alpine
```

```
docker run -d --name web2 -p 8082:80 nginx:1.29-alpine
```

Ouvre <http://localhost:8081> et <http://localhost:8082>. Deux conteneurs, la même image. Regarde `docker ps`, puis supprime-les :

```
docker rm -f web1 web2
```

---

## Ce que tu viens d'apprendre

- Une **image** est un modèle, un **conteneur** est une copie de ce modèle qui tourne. Une image peut donner autant de conteneurs que tu veux.
- `-p 8080:80` relie un port de ton ordinateur à un port du conteneur. Sans ça, rien n'est accessible depuis ton navigateur.
- `docker ps`, `logs`, `exec`, `stop` et `rm` suffisent pour observer et piloter n'importe quel conteneur.
