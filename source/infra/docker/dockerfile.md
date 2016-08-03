Beaucoup d'images sont disponibles sur le [docker hub](https://hub.docker.com/). Cependant, parfois il est necessaire de créer ses propres images.

## Le Dockerfile

Afin de définir une image, docker utilise un fichier nommé Dockerfile. Ce fichier commence par définir une image de base puis des opérations a effectuer par dessus.

Par convention et pour simplifier la gestion des images il est conseillé de réduire autant que possible la taille des images. Il ne faut installer que le **stricte necessaire** dans une image docker.

Ainsi tout Dockerfile commence par l'instruction suivante:

```Dockerfile
FROM image
```

D'après la convention il faut également définir une personne qui sera considérée comme le mainteneur officiel de l'image. Cela peut se faire via l'instruction suivante:

```Dockerfile
MAINTAINER Ares <ares@ares-ensiie.eu>
```

Une fois l'entête définie, il est possible d'éffectuer différentes opérations sur notre image.

## Opérations possibles dans un dockerfile

### RUN

L'instruction `RUN` permet de lancer une commande sur notre image de base. Par exemple:

```Dockerfile
RUN mkdir -p /app/src/code
```

### ENV

L'instruction `ENV` permet de définir une variable d'environement pour notre application. Cela peut être extrèmement pratique pour définir de la configuration ou pour changer d'utilisateur.

Exemple:

```Dockerfile
ENV PORT=3000
```

### ADD

L'instruction `ADD` permet d'ajouter un fichier du host dans l'image. Elle a la syntaxe suivante:

```Dockerfile
ADD FICHIER_SUR_LA_MACHINE FICHIER_DANS_LE_CONTAINER
```

### VOLUME

L'instruction `VOLUME` permet de définir un volume dans votre application. Cette instruction ne fait rien dans l'immédiat, mais elle permet de définir un point dans le système de fichier à sauvegarder pour préserver l'intégrité des données.

Exemple:

```Dockerfile
VOLUME /data
```

### EXPOSE

L'instruction `EXPOSE` permet d'indiquer les ports que sur lesquels l'application présente dans l'image écoute.

Exemple:

```Dockerfile
EXPOSE 8080
```

### CMD

L'instruction `CMD` permet de définir la commande qui sera executé au démarrage d'un container basé sur cette image.

Exemple:

```Dockerfile
CMD "bash /app/start.sh"
```

## Instruction spécifiques a Ares

### Clonage des repository gitlab

Afin de cloner les repository Gitlab, Ares utilise un utilisateur particulier: `Ares Robot`. Cet utilisateur est dans le groupe ares et doit avoir les droits de lecture sur tous les repository que l'on souhaite déployer (en l'ajoutant en collaborateur sur l'app).

Cet utilisateur a une paire de clef ssh associé a son compte Gitlab que nous répliquons dans tous les containers qui doivent cloner une application. Cette paire est disponible dans le [repository de configuration](https://todo.fr/todo).

## Un exemple: le Dockerfile de l'intranet

> TODO TODO TODO TOOOODOOOOO TOOOUT DOOOUX

## Liens utiles

* [La référence du Dockerfile](https://todo.fr/todo)
* [L'architecture docker Ares](/infra/docker/base)