[← Retour aux TD](../README.md)

# TD 3 - Une image plus légère, plus rapide, plus propre

**Objectif :** améliorer ton Dockerfile du TD 2 en appliquant cinq changements, un par un. Ton image va passer d'environ 1,1 Go à moins de 200 Mo.

**Durée :** 50 min

**Règle du TD :** aucune commande et aucune ligne de Dockerfile ne sont données. Tu as la syntaxe dans le [mémo](memo.md) et sur les slides.

Tu pars du `app/Dockerfile` du TD 2. Tout se lance depuis le dossier `docker-salles`.

---

## Critères d'acceptance

À la fin du TD, ton image `salles-api` doit respecter **tous** ces critères :

1. Elle part de l'image officielle de Node 24, dans sa variante la plus légère, et pèse **moins de 200 Mo** (colonne `DISK USAGE`).
2. **Une modification du HTML ne relance pas l'installation des dépendances.**
3. **Le fichier `.env` n'est pas dans l'image.**
4. Les dépendances sont installées avec **`npm ci`**, sans les dépendances de développement.
5. **L'application ne tourne pas en `root`**, mais avec l'utilisateur `node`.
6. L'application marche toujours sur <http://localhost:3000>.

**Comment vérifier les critères 3 et 5 :** lance un conteneur jetable à partir de `salles-api`, qui se supprime tout seul dès qu'il a fini (le mémo te dit quelle option fait ça), et qui exécute `ls -a` au lieu de démarrer l'application. Le mémo te montre comment remplacer la commande de démarrage d'une image. Fais pareil avec `whoami`.

---

## Étape 0 - Un faux secret

Pour pouvoir vérifier le critère 3, crée un faux fichier secret dans le dossier `app` : un fichier nommé `.env` (avec le point au début) qui contient une seule ligne :

```
SECRET=ne-doit-pas-finir-dans-l-image
```

Fais un build avec ton Dockerfile du TD 2, et vérifie : aujourd'hui, aucun des critères 1 à 5 n'est respecté. On les règle un par un.

## Étape 1 - Une image de base plus petite

Ton image de départ embarque un Linux complet, avec des centaines d'outils dont ton application ne se sert pas.

Retourne sur la page de l'image officielle de Node.js sur Docker Hub, et trouve la variante **la plus légère** de la **version 24**. Remplace ton image de départ par celle-ci.

Fais un build, et affiche l'image `salles-api` avec sa taille.

**Tu dois voir :** moins de **200 Mo**, environ six fois moins. C'est le plus gros gain du TD. **Critère 1 validé.**

## Étape 2 - L'ordre des instructions et le cache

Docker fabrique l'image **couche par couche**, une couche par instruction. Au build suivant, il réutilise chaque couche tant que rien n'a changé **au-dessus d'elle**. Dès qu'une couche change, toutes celles qui suivent sont refaites.

Aujourd'hui, ton Dockerfile copie tout le code **avant** d'installer les dépendances. Une virgule changée dans le HTML suffit à refaire toute l'installation.

Réorganise ton Dockerfile pour que l'installation des dépendances reste en cache quand seul le code change :

- d'abord, copie **uniquement** les deux fichiers qui décrivent les dépendances : `package.json` et `package-lock.json`. Une seule instruction suffit : cherche comment le joker `*` peut t'aider ;
- installe les dépendances ;
- **ensuite seulement**, copie le reste du code.

Fais un build. Puis modifie une lettre dans `app/public/index.html`, et refais un build. Regarde la ligne `RUN npm ...` dans ce qui défile.

**Tu dois voir :** `RUN npm install` est marqué `CACHED` : Docker a réutilisé l'installation précédente. **Critère 2 validé.**

## Étape 3 - Le fichier .dockerignore

Ton `.env` est encore **dans l'image** : vérifie-le avec `ls -a` (voir les critères). Quiconque récupère ton image peut lire ton mot de passe.

Crée dans le dossier `app` un fichier nommé exactement `.dockerignore` (avec le point, sans extension). Il fonctionne comme un `.gitignore` : ce qu'il liste n'est jamais envoyé à Docker pendant le build. Mets-y au moins :

- le dossier des dépendances installées sur ta machine (il ne doit pas écraser celui de l'image) ;
- ton fichier de secrets ;
- le journal d'erreurs de npm, `npm-debug.log`.

Fais un build, et refais la vérification avec `ls -a`.

**Tu dois voir :** `.env` a disparu de la liste. La taille ne bouge pas : c'est un gain de sécurité, pas de poids. **Critère 3 validé.**

Tu peux maintenant **supprimer le faux fichier `app/.env`**.

## Étape 4 - npm ci au lieu de npm install

`npm install` peut installer des versions un peu différentes d'un build à l'autre. `npm ci` installe **exactement** les versions notées dans `package-lock.json` : ton image est identique aujourd'hui et dans six mois.

Remplace `npm install` par `npm ci`, en demandant de **ne pas installer les dépendances de développement** (tests, linters), inutiles pour faire tourner l'application. Trouve la bonne option dans la [documentation de npm ci](https://docs.npmjs.com/cli/commands/npm-ci).

Fais un build.

**Tu dois voir :** le build passe, et la taille ne change presque pas. C'est normal : cette application n'a pas de dépendances de développement. Sur un vrai projet (React, TypeScript), le gain se compte en centaines de Mo. **Critère 4 validé.**

## Étape 5 - Ne pas tourner en root

Vérifie avec `whoami` (voir les critères) : tu obtiens `root`. Ton application a tous les droits dans le conteneur. Si quelqu'un trouve une faille dans ton code, il a tous les droits aussi.

L'image officielle de Node contient déjà un utilisateur sans privilèges. Trouve son nom dans les [bonnes pratiques de l'image Node](https://github.com/nodejs/docker-node/blob/main/docs/BestPractices.md#non-root-user), et fais tourner ton application avec cet utilisateur. Réfléchis à l'endroit où placer l'instruction : les étapes d'installation, elles, ont besoin des droits.

Fais un build, et refais la vérification avec `whoami`.

**Tu dois voir :** `node` au lieu de `root`. **Critère 5 validé.**

## Le résultat

Vérifie que l'application marche toujours : supprime l'ancien conteneur `api`, et relance-le comme au TD 2.

**Tu dois voir :** la page sur <http://localhost:3000>, toujours avec « Base : non connectée ». **Critère 6 validé** : relis la liste des critères en haut du TD, ils doivent tous être respectés.

Garde ce Dockerfile et ce `.dockerignore` : ce sont ceux de ton projet.

---

## Si ça ne marche pas

| Ce que tu vois | Ce qu'il faut faire |
|---|---|
| `npm ci` : `The npm ci command can only install with an existing package-lock.json` | Le fichier `package-lock.json` n'est pas copié avant l'installation. Ton `COPY` des fichiers de dépendances doit les prendre **tous les deux**. |
| `npm` n'est jamais `CACHED` | Vérifie que la copie des fichiers de dépendances et l'installation sont bien **avant** la copie du reste du code. Et modifie le HTML puis rebuild **deux fois** : le premier build après un changement du Dockerfile refait forcément tout. |
| `.env` est toujours dans l'image | Le fichier doit s'appeler exactement `.dockerignore`, être dans `app` (à côté du Dockerfile), sans extension `.txt`. |
| `whoami` affiche toujours `root` | L'instruction qui change d'utilisateur doit être après les `RUN` et avant `CMD`. Et il faut refaire le build. |
| `Error: Cannot find module 'express'` au lancement | L'installation des dépendances a disparu, ou elle est faite avant que les fichiers de dépendances soient copiés. |
| `unable to find user` | Le nom de l'utilisateur est mal écrit : vérifie-le dans les bonnes pratiques de l'image Node. |

## Bonus - jusqu'où peux-tu descendre ?

Essaie de faire encore maigrir l'image **sans casser l'application** : la page doit toujours s'afficher. Pistes : les autres variantes de l'image `node` sur Docker Hub, le *multi-stage build* (on en parle demain). Note ta meilleure taille.

---

## Ce que tu viens d'apprendre

- L'**image de base** décide de l'essentiel de la taille : la variante `alpine` divise le poids par six ou plus.
- Une image est faite de **couches** mises en cache : ce qui change rarement en haut, ce qui change souvent en bas.
- `.dockerignore` et un utilisateur sans privilèges ne font rien gagner en poids, mais évitent d'embarquer des secrets et de donner tous les droits à ton application.
