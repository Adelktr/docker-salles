# TD 4 - Des données qui survivent

**Objectif :** lancer une base de données PostgreSQL dans un conteneur, y écrire des données, **supprimer le conteneur**, et retrouver les données. Puis voir ce qui se passe sans volume.

**Durée :** 1 h

Toutes les commandes se lancent depuis le dossier `docker-salles`.

---

## Étape 1 - Le fichier .env

Le mot de passe de la base ne s'écrit jamais dans le code ni dans une commande que tu commites : il va dans un fichier `.env`, qui est dans le `.gitignore`.

Copie le modèle. Sous macOS :

```
cp .env.example .env
```

Sous Windows (PowerShell) :

```
Copy-Item .env.example .env
```

Tu peux aussi dupliquer le fichier `.env.example` dans ton éditeur et renommer la copie en `.env`.

Ouvre `.env` et remplace `a-remplacer` par un mot de passe de ton choix. Ne touche pas aux deux autres lignes.

**Tu dois voir :** un fichier `.env` à la racine de `docker-salles`, avec ton mot de passe. Vérifie avec `git status` qu'il n'apparaît **pas** dans la liste des fichiers à commiter.

## Étape 2 - Créer un volume

```
docker volume create donnees-td4
```

**Tu dois voir :** `donnees-td4`. Un volume est un espace de stockage géré par Docker, **indépendant** de tout conteneur.

## Étape 3 - Lancer PostgreSQL avec ce volume

```
docker run -d --name db-td4 --env-file .env -v donnees-td4:/var/lib/postgresql postgres:18-alpine
```

| Morceau | Ce qu'il veut dire |
|---|---|
| `--env-file .env` | passe au conteneur les variables de ton `.env` (utilisateur, mot de passe, nom de la base) |
| `-v donnees-td4:/var/lib/postgresql` | branche le volume `donnees-td4` sur le dossier où PostgreSQL range ses données |
| `postgres:18-alpine` | PostgreSQL version 18, sur base alpine |

Attends une dizaine de secondes, puis :

```
docker logs db-td4
```

**Tu dois voir :** `PostgreSQL init process complete; ready for start up.` puis, plus bas, `database system is ready to accept connections`. Si tu ne vois pas encore ces lignes, attends et relance la commande.

## Étape 4 - Écrire des données

Ouvre la console de la base, **dans** le conteneur :

```
docker exec -it db-td4 psql -U salles -d salles
```

**Tu dois voir :** une invite `salles=#`. Tape ces deux lignes (avec le point-virgule à la fin) :

```sql
CREATE TABLE notes (id serial PRIMARY KEY, texte text);
```

```sql
INSERT INTO notes (texte) VALUES ('Ma première donnée');
```

**Tu dois voir :** `CREATE TABLE`, puis `INSERT 0 1`. Pour sortir de la console :

```
\q
```

## Étape 5 - Détruire le conteneur

```
docker rm -f db-td4
```

```
docker ps -a
```

**Tu dois voir :** plus aucun conteneur `db-td4`. La base de données a disparu... ou pas ?

## Étape 6 - Recréer un conteneur, même volume

Relance **exactement** la même commande qu'à l'étape 3 :

```
docker run -d --name db-td4 --env-file .env -v donnees-td4:/var/lib/postgresql postgres:18-alpine
```

Attends quelques secondes (cette fois il n'y a pas d'initialisation, c'est plus rapide), puis :

```
docker exec -it db-td4 psql -U salles -d salles
```

```sql
SELECT * FROM notes;
```

**Tu dois voir :** ta ligne `Ma première donnée`. C'est un **nouveau** conteneur, mais les données étaient dans le volume, pas dans le conteneur. Sors avec `\q`.

## Étape 7 - Le contre-exemple : sans volume

Lance une autre base, **sans** l'option `-v` :

```
docker run -d --name db-sans-volume --env-file .env postgres:18-alpine
```

Attends une dizaine de secondes, puis crée la même table :

```
docker exec -it db-sans-volume psql -U salles -d salles
```

```sql
CREATE TABLE notes (id serial PRIMARY KEY, texte text);
```

Sors avec `\q`, puis supprime ce conteneur :

```
docker rm -f -v db-sans-volume
```

Ici, `-v` demande à Docker de supprimer aussi l'espace de stockage temporaire qu'il avait créé tout seul pour ce conteneur.

Relance-le et cherche ta table :

```
docker run -d --name db-sans-volume --env-file .env postgres:18-alpine
```

Attends une dizaine de secondes.

```
docker exec -it db-sans-volume psql -U salles -d salles
```

```sql
SELECT * FROM notes;
```

**Tu dois voir :** `ERROR: relation "notes" does not exist`. Sans volume nommé, les données sont parties avec le conteneur. Sors avec `\q`.

## Étape 8 - Observer les volumes

```
docker volume ls
```

**Tu dois voir :** `donnees-td4`, et peut-être des volumes aux noms illisibles : ce sont des volumes **anonymes**, que Docker crée tout seul quand une image en demande un et que tu ne lui en donnes pas.

```
docker volume inspect donnees-td4
```

**Tu dois voir :** un `Mountpoint` du type `/var/lib/docker/volumes/donnees-td4/_data`. C'est là que Docker range les fichiers. Sous macOS et Windows, ce dossier est dans la machine virtuelle de Docker Desktop : tu ne le trouveras pas dans ton explorateur de fichiers, et c'est voulu.

## Étape 9 - Faire le ménage

```
docker rm -f -v db-td4 db-sans-volume
```

```
docker volume rm donnees-td4
```

Pour le TD 5, ne supprime surtout pas ton fichier `.env`.

---

## Si ça ne marche pas

| Ce que tu vois | Ce qu'il faut faire |
|---|---|
| Le conteneur s'arrête tout de suite, et `docker logs db-td4` affiche `Error: in 18+, these Docker images are configured to store database data in a format...` | Tu as monté le volume sur `/var/lib/postgresql/data`, comme dans les tutos écrits pour les versions avant la 18. Depuis la 18, c'est `/var/lib/postgresql`. Supprime le conteneur **et** le volume, et recommence l'étape 2. |
| `Error: Database is uninitialized and superuser password is not specified` | Le conteneur n'a pas reçu ton `.env`. Vérifie que tu es dans `docker-salles`, que le fichier s'appelle bien `.env` et que tu as mis `--env-file .env`. |
| `psql: error: ... FATAL: database "salles" does not exist` ou `role "salles" does not exist` | La base est encore en train de s'initialiser : attends dix secondes et recommence. Si ça persiste, vérifie les lignes `POSTGRES_USER` et `POSTGRES_DB` de ton `.env`. |
| `Conflict. The container name "/db-td4" is already in use` | `docker rm -f db-td4`, puis relance. |
| `Error response from daemon: remove donnees-td4: volume is in use` | Un conteneur utilise encore le volume : supprime d'abord le conteneur. |
| Rien ne se passe après `\q` | Vérifie que tu as bien tapé `\q` (barre oblique inversée), puis Entrée. |

## Bonus - le bind mount

Un **bind mount** branche un dossier de **ton ordinateur** dans le conteneur. Parfait en développement : tu modifies un fichier, le conteneur le voit tout de suite, sans rebuild.

Crée un dossier `ma-page` dans `docker-salles`, avec dedans un fichier `index.html` qui contient `<h1>Ma page perso</h1>`. Puis :

```
docker run -d --name perso -p 8090:80 -v ./ma-page:/usr/share/nginx/html nginx:1.29-alpine
```

Ouvre <http://localhost:8090>. Modifie le titre dans `ma-page/index.html`, enregistre, recharge la page : le changement est immédiat. Compare avec le TD 2, où il fallait tout refabriquer.

Fais le ménage : `docker rm -f perso`

---

## Ce que tu viens d'apprendre

- Un conteneur est **jetable** : tout ce qu'il écrit disparaît avec lui, sauf ce qui est dans un volume.
- Un **volume nommé** est géré par Docker et survit aux conteneurs. Un **bind mount** relie un dossier de ton ordinateur.
- Les secrets vont dans un fichier `.env`, jamais commité, passé au conteneur avec `--env-file`.
