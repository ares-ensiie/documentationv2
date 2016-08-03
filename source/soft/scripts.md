Afin de gérer l'infrastructure, quelques scripts ont été devellopé. Ils sont disponibles dans le repository [scripts](http://todo.fr/todo) sur le gitlab.

Ces scripts sont disponible sur les serveurs dans les dossiers suivants:

* Sur biere: /home/ares/scripts

## Scripts docker

### docker-enter.sh

Ce script permet d'entrer dans un container décrit dans le fichier `docker-compose.yml` définit dans `/home/ares/ares`.
Il va lancer un bash dans le container, utile pour différentes taches de debug.
Il ne demande qu'un seul argument: le nom de l'application tel qu'il est écrit dans le fichier `docker-compose.yml`.

Ex:
```bash
./docker-enter.sh intranet
```

### docker-rm-dangling.sh

Parfois, lors de compilation raté, il reste des images non tagguées sur le systèmes. Ce sont des images qui n'ont ni nim, ni tag, ni repository et qui du coup n'ont aucune utilité. Ce script va repérer et supprimer ces images.

### docker-rm-stopped.sh

Ce script permet de supprimer tous les container qui ne tournent pas/plus.
