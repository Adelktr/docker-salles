[← Retour aux TD](../README.md)

# TD 4 - Des données qui survivent

**Objectif :** lancer une base de données PostgreSQL dans un conteneur, y écrire des données, **supprimer le conteneur**, et retrouver les données.

**Durée :** jusqu'à la fin de la journée. Pas fini ? Termine-le chez toi avant mardi matin : le TD 5 en a besoin.

**Règle du TD :** aucune commande Docker n'est donnée. Tu as la syntaxe dans le [mémo](memo.md) et sur les slides. Pour PostgreSQL, ta référence est la page de l'image officielle sur [Docker Hub](https://hub.docker.com) : lis-la, tout ce qu'il te faut y est.

Tout se lance depuis le dossier `docker-salles`.

---

## Étape 1 - Le fichier .env

Le mot de passe de la base ne s'écrit jamais dans le code ni dans une commande que tu commites : il va dans un fichier `.env`, qui est dans le `.gitignore`.

Crée un fichier `.env` à la racine de `docker-salles`, en copiant le modèle `.env.example`. Ouvre-le et remplace `a-remplacer` par un mot de passe de ton choix. Ne touche pas aux deux autres lignes.

Ces trois variables ne sont pas inventées : ouvre la page de l'image **postgres** sur Docker Hub, section *Environment Variables*, et lis à quoi sert chacune.

**Tu dois voir :** avec `git status`, ton `.env` n'apparaît **pas** dans la liste des fichiers à commiter.

## Étape 2 - Créer un volume

Crée un volume nommé **`donnees-td4`**.

**Tu dois voir :** `donnees-td4`. Un volume est un espace de stockage géré par Docker, **indépendant** de tout conteneur.

## Étape 3 - Lancer PostgreSQL avec ce volume

Lance un conteneur PostgreSQL :

- l'image : l'image **officielle** de PostgreSQL, en **version 18**, dans sa variante **la plus légère** ;
- en tâche de fond, nommé **`db-td4`** ;
- avec les variables de ton fichier `.env` ;
- avec le volume `donnees-td4` branché sur le dossier où PostgreSQL range ses données.

Quel est ce dossier ? Cherche sur la page Docker Hub de l'image, sections *PGDATA* et *Where to Store Data*. **Attention :** il a changé avec la version 18. La plupart des tutos, et beaucoup d'IA, donnent encore l'ancien.

Attends une dizaine de secondes, puis lis le journal du conteneur.

**Tu dois voir :** `PostgreSQL init process complete; ready for start up.` puis, plus bas, `database system is ready to accept connections`. Si tu ne vois pas encore ces lignes, attends et relis le journal.

## Étape 4 - Écrire des données

Ouvre la console de la base, `psql`, **dans** le conteneur `db-td4`. `psql` a besoin de deux options : `-U <utilisateur>` et `-d <base>`. Les valeurs sont dans ton `.env`.

**Tu dois voir :** une invite `salles=#`. Tape ces deux lignes (avec le point-virgule à la fin) :

```sql
CREATE TABLE notes (id serial PRIMARY KEY, texte text);
```

```sql
INSERT INTO notes (texte) VALUES ('Ma première donnée');
```

**Tu dois voir :** `CREATE TABLE`, puis `INSERT 0 1`. Pour sortir de la console, tape `\q`.

## Étape 5 - Détruire le conteneur

Supprime le conteneur `db-td4`, de force, puis affiche tous les conteneurs.

**Tu dois voir :** plus aucun conteneur `db-td4`. La base de données a disparu... ou pas ?

## Étape 6 - Recréer un conteneur, même volume

Relance **exactement** la même commande qu'à l'étape 3. Attends quelques secondes (cette fois il n'y a pas d'initialisation, c'est plus rapide), puis rouvre `psql` dans le conteneur et tape :

```sql
SELECT * FROM notes;
```

**Tu dois voir :** ta ligne `Ma première donnée`. C'est un **nouveau** conteneur, mais les données étaient dans le volume, pas dans le conteneur. Sors avec `\q`.

Pour le TD 5, garde ton fichier `.env` : tu en auras besoin.

---

## Si ça ne marche pas

| Ce que tu vois | Ce qu'il faut faire |
|---|---|
| Le conteneur s'arrête tout de suite, et son journal affiche `Error: in 18+, these Docker images are configured to store database data in a format...` | Tu as monté le volume sur l'ancien dossier, celui des versions avant la 18. Relis la section *PGDATA* de la page Docker Hub. Supprime le conteneur **et** le volume, et recommence à l'étape 2. |
| `Error: Database is uninitialized and superuser password is not specified` | Le conteneur n'a pas reçu ton `.env`. Vérifie que tu es dans `docker-salles`, que le fichier s'appelle bien `.env`, et que tu passes bien ce fichier au conteneur. |
| `psql: error: ... FATAL: database "salles" does not exist` ou `role "salles" does not exist` | La base est encore en train de s'initialiser : attends dix secondes et recommence. Si ça persiste, vérifie les lignes `POSTGRES_USER` et `POSTGRES_DB` de ton `.env`. |
| `Conflict. The container name "/db-td4" is already in use` | Supprime de force l'ancien conteneur, puis relance. |
| `the input device is not a TTY` | Tu es dans Git Bash. Utilise **PowerShell**. |
| Rien ne se passe après `\q` | Vérifie que tu as bien tapé `\q` (barre oblique inversée), puis Entrée. |

## Bonus - le bind mount

Un **bind mount** branche un dossier de **ton ordinateur** dans le conteneur. Parfait en développement : tu modifies un fichier, le conteneur le voit tout de suite, sans rebuild.

Crée un dossier `ma-page` dans `docker-salles`, avec dedans un fichier `index.html` qui contient `<h1>Ma page perso</h1>`. Lance un nginx (le même qu'au TD 1), nommé `perso`, accessible sur le port 8090 de ta machine, avec ton dossier `ma-page` branché à la place des pages de nginx. Au TD 1, tu as vu dans quel dossier du conteneur elles sont rangées.

Ouvre <http://localhost:8090>. Modifie le titre dans `ma-page/index.html`, enregistre, recharge la page : le changement est immédiat. Compare avec le TD 2, où il fallait tout refabriquer.

Fais le ménage : supprime le conteneur `perso`.

---

## Ce que tu viens d'apprendre

- Un conteneur est **jetable** : tout ce qu'il écrit disparaît avec lui, sauf ce qui est dans un volume.
- Un **volume nommé** est géré par Docker et survit aux conteneurs. Un **bind mount** relie un dossier de ton ordinateur.
- La page Docker Hub d'une image est sa documentation : variables, dossiers, pièges de version.
- Les secrets vont dans un fichier `.env`, jamais commité, passé au conteneur au démarrage.
