# Mémo Docker

Les TD ne te donnent pas les commandes : c'est à toi de les écrire, à partir de ce mémo. Remplace chaque `<...>` par la bonne valeur, sans garder les chevrons.

Pour toutes les options d'une commande : `docker <commande> --help` (par exemple `docker run --help`).

## Trouver une image sur Docker Hub

1. Va sur <https://hub.docker.com> et cherche le nom du logiciel (nginx, node, postgres…).
2. Prends l'image marquée **Docker Official Image**. Les autres sont publiées par n'importe qui.
3. Ouvre l'onglet **Tags** : ce sont toutes les versions disponibles. Le nom complet d'une image, c'est `<image>:<tag>`.
4. Dans un tag, `alpine` désigne la variante la plus légère, construite sur Alpine Linux.
5. N'utilise jamais `latest` ni une image sans tag : écris toujours une version précise.

## Conteneurs

```
docker run <image>:<tag>                       # crée et lance un conteneur
docker run <image>:<tag> <commande>            # ... en remplaçant la commande de démarrage de l'image
```

Les options de `docker run` les plus utiles, à placer **avant** le nom de l'image :

| Option | Effet |
|---|---|
| `-d` | en tâche de fond : tu récupères ton terminal |
| `--name <nom>` | donne un nom au conteneur |
| `-p <port-machine>:<port-conteneur>` | le port de ta machine mène au port du conteneur |
| `--rm` | supprime le conteneur dès qu'il s'arrête |
| `--env-file <fichier>` | passe au conteneur les variables d'un fichier `.env` |
| `-v <nom-volume>:<dossier-dans-le-conteneur>` | branche un volume nommé |
| `-v <chemin-sur-ta-machine>:<dossier-dans-le-conteneur>` | branche un dossier de ta machine (bind mount) |

```
docker ps                              # les conteneurs qui tournent
docker ps -a                           # tous les conteneurs, même arrêtés
docker logs <nom>                      # ce que le conteneur a écrit
docker exec -it <nom> <commande>       # lance une commande dans un conteneur qui tourne
                                       # (sh : un terminal ; exit pour en sortir)
docker stop <nom>                      # arrête le conteneur
docker rm <nom>                        # le supprime (-f : même s'il tourne)
```

## Images

```
docker images                                  # les images sur ta machine
docker image ls <nom-image>                    # une seule image, avec sa taille
docker build -t <nom-image> <dossier>          # fabrique une image ; <dossier> contient le Dockerfile
docker build -t <nom-image>:<tag> <dossier>    # ... avec un tag
docker login                                   # se connecter à Docker Hub
```

## Dockerfile

Un fichier nommé exactement `Dockerfile`, sans extension. Une instruction par ligne, lue de haut en bas :

```dockerfile
FROM <image>:<tag>                 # l'image de départ, trouvée sur Docker Hub
WORKDIR <dossier>                  # le dossier de travail dans l'image
COPY <source> <destination>        # copie des fichiers de ta machine vers l'image
RUN <commande>                     # lance une commande pendant le build
EXPOSE <port>                      # documente le port de l'application (n'ouvre rien)
USER <utilisateur>                 # l'utilisateur qui lance l'application
CMD ["<programme>", "<argument>"]  # la commande lancée au démarrage du conteneur
```

- `RUN` s'exécute **une fois**, pendant le build. `CMD` s'exécute **à chaque** démarrage de conteneur.
- Chaque instruction crée une **couche**, mise en cache. Dès qu'une couche change, toutes celles qui suivent sont refaites.

Le fichier `.dockerignore`, à côté du Dockerfile, liste ce qui ne doit jamais entrer dans l'image : un fichier ou un dossier par ligne, comme un `.gitignore`.

## Volumes

```
docker volume create <nom-volume>
docker volume ls
docker volume inspect <nom-volume>
docker volume rm <nom-volume>
docker rm -f -v <nom>              # supprime un conteneur et ses volumes anonymes
```

## Docker Compose

Un fichier `compose.yaml`. L'indentation compte : 2 espaces, jamais de tabulation.

```yaml
services:
  <nom-service>:
    build: <dossier-du-Dockerfile>            # construit l'image depuis un Dockerfile
    ports:
      - "<port-machine>:<port-conteneur>"
    environment:
      <VARIABLE>: <valeur>                    # ou ${VARIABLE} : lue dans le .env
    depends_on:
      - <autre-service>                       # démarre l'autre service d'abord

  <autre-service>:
    image: <image>:<tag>                      # une image toute faite, de Docker Hub
    environment:
      <VARIABLE>: ${VARIABLE}
    volumes:
      - <nom-volume>:<dossier-dans-le-conteneur>

volumes:
  <nom-volume>:                               # déclare le volume nommé
```

Dans Compose, un service en joint un autre **par son nom** : `<nom-service>` sert d'adresse.

```
docker compose up -d               # lance tous les services
docker compose up -d --build       # ... en reconstruisant les images
docker compose ps                  # l'état des services
docker compose logs <service>      # le journal d'un service (-f : en direct, Ctrl+C pour sortir)
docker compose down                # arrête et supprime les conteneurs
docker compose down -v             # ... et les volumes : les données sont perdues
```

C'est `docker compose`, avec un espace. `docker-compose` avec un tiret est l'ancienne version.
