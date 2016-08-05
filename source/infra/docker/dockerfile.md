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

Pour l'intranet, la structure du dossier est la suivante:

```
|
|- config
| |- database.yml
| |- ldap.yml
| |- secret_key
|- keys
| |- id_rsa
| |- id_rsa.pub
| |- known_hosts
|- scripts
| |- install.sh
| |- run.sh
|- Dockerfile
```
Le dossier `configuration` continent tous les fichiers necessaires a la configuration de l'Intranet.

Le dossier `keys` contient les clef ssh du compte `Ares Robot`. Nous disposons donc de la paire de clef RSA: `id_rsa` et `id_rsa.pub` ainsi que du fichier `known_host` préconfiguré avec l'host Gitlab afin d'éviter le prompt nous demandons si nous voulons bien autoriser l'host distant (lors du clonage).

Le dossier `scripts` contient 2 fichiers:

* `install.sh` script d'installation lancé lors de la création de l'image
* `run.sh` script de lancement de l'application, lancé au démarrage du container.

Le fichier `Dockerfile` contient:

```Dockerfile
FROM ruby:2.3.1
MAINTAINER Ares <ares@ares-ensiie.eu>

ADD scripts/* /tmp/
ADD config/* /tmp/
ADD keys/* /root/.ssh/

RUN /tmp/install.sh

RUN rm /tmp/*

CMD /srv/run.sh
```

Ainsi, nous partons de l'image ruby (en version 2.3.1) et nous definissons le maintainer.
Puis nous ajoutons tous les fichiers necessaires à l'installation dans `/tmp` (c'est le script d'installation qui se chargera de la mise en place de ses fichiers).

Les clef ssh sont directement ajouté dans le dossier `.ssh` de root. Ainsi root utilisera ces clef pour toute connexion ssh (et donc pour cloner le repository).

L'installation des composants nécessaires au gitlab se font lors de la ligne suivante:

```Dockerfile
RUN /tmp/install.sh
```

Qui execute le fichier `install.sh` présent dans `scripts/install.sh` et ajouté dans le container dans `/tmp` par la ligne:

```Dockerfile
ADD scripts/* /tmp/
```

Ce fichier contient le code suivant:

```bash
#!/bin/bash

# Mise a jour des dépots
apt-get update

# Installation des différents composants nécessaires au fonctionnement de l'intranet
# - nodejs: pour la compilation des assets
# - git: pour récuperer le code source
# - imagemagick: pour la manipulation des images
apt-get install -y nodejs git imagemagick

# Mise en place de la structure de dossier
mkdir -p /srv/app/
cd /srv/app

# Clonage du repository git (en utilisant les clefs ssh d'Ares Robot)
git clone ssh://git@git.ares-ensiie.eu:2222/ares/Intranet.git

# Mise en place des fichiers de configuration
cp /tmp/ldap.yml /srv/app/Intranet/config/ldap.yml
cp /tmp/database.yml /srv/app/Intranet/config/database.yml
cp /tmp/secret_key /srv/secret_key

# Mis en place du fichier de lancement
cp /tmp/run.sh /srv/

cd Intranet/

# Opérations spécifiques a rails
bundle install --without development test
source /srv/secret_key ; rake db:create RAILS_ENV=production
source /srv/secret_key ; rake db:migrate RAILS_ENV=production
source /srv/secret_key ; rake assets:precompile RAILS_ENV=production
```

Une fois le script d'installation finit, nous définissons le point d'entré de notre application: `/srv/run.sh` avec l'instruction:

```Dockefile
CMD /srv/run.sh
```

Et l'image est prète!

## Liens utiles

* [La référence du Dockerfile](https://todo.fr/todo)
* [L'architecture docker Ares](/infra/docker/base)