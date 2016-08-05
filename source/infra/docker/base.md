## Informations générales

### Noeud principal
Une grande partie de notre stack applicatif est basé sur Docker. Le noeud principal pour les container docker est le serveur Biere (10.0.0.2). C'est ici que toutes les applications Ares doivent être déployées. Toute la définition de l'architecture docker est définit dans le dossier `/home/ares/ares`.

### Docker compose

Afin de gérer nos containers docker, nous nous basons essentiellement sur un l'outil docker-compose. Cet outil permet de définir une architecture de container en un fichier yml. Une fois ce fichier définit, il fournit un outil en CLI permettant d'effectuer certaines opérations usuelles sur les containers définit dans le fichier yml.

Le fichier `docker-compose.yml` ainsi que les autres fichiers nécessaires à son fonctionnement sont disponibles dans le repository [TODO](https://todo.fr/todo).

Pour que docker-compose puisse fonctionner, il faut lancer les commandes depuis le dossier ou se trouve le fichier `docker-compose.yml`. Ainsi pour la suite de cette documentation, nous supposerons que vous êtes dans le dossier `/home/ares/ares` de Biere.

Docker compose utilise sa propre convention de nommage pour les noms d'image et de fichier. Il utilise le nom du dossier parent du fichier `docker-compose.yml` comme nom de projet et le nom du noeud dans le fichier yaml comme le nom de l'app.
Ainsi si vous avez le fichier `docker-compose.yml` suivant dans un dossier nommé `ares`:

```yml
test:
  build: test
```

Le nom de l'image compilée sera donc: `NOM-DU-PROJET_NOM-DE-L-APP` dans notre cas: `ares_test`.

De même pour les containers, ils ont comme nom: `NOM-DU-PROJET_NOM-DE-L-APP_INDEX-DU-CONTAINER` dans notre cas pour le permier container: `ares_test_1`.

### Rappels sur docker

Docker fonctionne sur un principe d'image et de container. Une image est un snapshot du "disque dur" de votre application a un moment donné. Alors qu'un container est une instance de ce disque sur lequel nous avons lancé des processus afin d'éffectuer diverses opérations.

Un container n'est prévu que pour lancer un seul et unique processus. Une fois ce processus mort, le container meurt ainsi que toutes les données qui n'était pas présente sur l'image de laquelle est issue le container. Il est donc important de ne stocker aucune données importantes sur le disque du container.

Afin de stocker des données persistante, il est necessaire de monter un "volume". Un volume est un pont entre les données du container et les données de la machine sur laquelle tourne le container (une sorte de dossier partagé entre le container et la machine). Toutes les données importantes doivent être présents dans ce volume ou ils risquent de disparaitre au prochain redémarrage du container.

## Ajouter une application

### Depuis une image existante

Si vous voulez ajouter un service à l'infrastructure Ares, essayez de trouver une image docker déjà faite pour ce service. Des images pour a peu pret tout sont trouvable sur le [hub docker](https://hub.docker.com/).

Une fois l'image trouvée, il suffit de l'ajouter dans le `docker-compose.yml`.

```yml
mon-app:
  image: repo/app
```

### Créer une image

Si il s'agit d'une application interne ou qu'aucune image déjà existante est en place, créer un dossier pour votre app et écrivez le `Dockerfile` necessaire à la génération de l'image. Plus de détail sur l'écriture du dockerfile [ici](/infra/docker/dockerfile).

Une fois le dockerfile écrit, il suffit d'ajouter dans le `docker-compose.yml`.

```yml
mon-app:
  build: monapp/
```

### Les variables d'environement

Afin de simplifier la scalabilité et pour simplifier la maintenance, la configuration des applications doit se faire par variable d'environnement. Ainsi la seconde étape est de configurer les variables d'environnement de votre app. Cela se fait également dans le fichier `docker-compose.yml`

Ex:

```yml
mon-app:
  image: repo/app
  environment:
    - SMTP_HOST: 10.0.0.2
    - SMTP_PORT: 25
    - TOKEN: 132jké2832jksdns293
    ...
```

### Les ports

Si l'on a besoin de se connecter a votre application, il faut exporter son port sur la machine. Prenons l'exemple d'un serveur web. Ce serveur web écoute sur le port **3000**. Cependant le port **3000** de notre machine hote est déjà utilisé. Nous voulons donc lier le port **8081** de notre machine au port **3000** du container. Pour faire ce pont, il suffit de le définir dans le fichier `docker-compose.yml`. Bien sur il faut choisir un port disponible sur l'host pour que cela fonctionne.
Il aura la syntaxe suivante:

```yml
mon-app:
  image: repo/app
  ports:
    - PORT_DE_LA_MACHINE_HOTE:PORT_DU_CONTAINER
```

Dans notre cas:

```yml
mon-app:
  image: repo/app
  ports:
    - 8081:3000
```

> **Note:** Même exporté le port ne sera disponible que sur notre réseau interne. Pour rendre l'application disponible depuis le réseau externe il faut [ajouter une règle dans le reverse proxy](http://todo.fr/todo) s'il s'agit d'un site web ou [ajouter une règle de redirection sur le firewall](http://todo.fr/todo) sinon.

### Les volumes

Les données stockées dans un container sont volatiles. Pour permettre une persistance des données, il faut monter un volume dans le container. Sur l'infrastructure Ares, les données ne sont pas directement stockées sur le serveur Biere, mais nous utilisons Ronflex comme serveur de stockage. Ainsi pour monter un volume sur le container il faut utiliser un espace de stockage pré-éxistant sur le serveur ronflex (Ils sont généralement monté dans `/exports`), ou en [créer un](https://todo.fr/todo). Une fois le lieu de stockage définit, il suffit de le préciser dans le fichier `docker-compose.yml` avec la syntaxe suivante:

```yml
mon-app:
  image: repo/app
  volumes:
    - DOSSIER_SUR_LA_MACHINE_HOTE:DOSSIER_DANS_LE_CONTAINER
```

Par exemple si nous voulons relier le dossier `/exports/Infra/influx` de la machine au dossier `/data` du container.

```yml
mon-app:
  image: repo/app
  volumes:
    - /exports/Infra/influx:/data
```

## Lancer l'application

Une fois le fichier `docker-compose.yml` pret, vous pouvez lancer votre application avec la commande:

```bash
docker-compose up mon-app
```

Cela va lancer le container et lier les entrèes sorties standard a celles de votre terminal.
Si vous voulez le lancer sans lier les entrèes sorties (en arrière plan), il suffit d'ajouter le flag `-d`.

```bash
docker-compose up -d mon-app
```

*Si aucun nom d'application n'est précisé, docker-compose va automatiquement lancer toutes les applications définies dans le fichier `docker-compose.yml`*

## Relancer une application

Lorsqu'une application est stoppée, il suffit parfois de la relancer dans le même container. Pour cela, vous pouvez utiliser la même commande que pour lancer l'application.

Cependant, parfois il est necessaire de stopper l'application et de supprimer le container sur laquelle l'application tournait. Cela donne la procédure suivante (recommandée).

```bash
# Stop l'application
docker-compose stop mon-app

# Supprime le container de l'application
docker-compose rm mon-app

# Relance l'application dans un nouveau container
docker-compose up -d mon-app
```

## Mettre a jour une application

La procédure de mise a jour d'une application est différente en fonction du type d'application.
S'il s'agit d'une image provenant d'une source externe, il faut d'abord mettre à jour l'image:

```yml
docker-compose pull mon-app
```

S'il s'agit d'une image construite en locale, il faut commencer par re-construire l'image:

```yml
docker-compose build --no-cache mon-app
```
*Sur les applications internes comme l'intranet, les ragots, mailliie, etc. C'est la seule commande a lancer pour mettre a jour l'image d'une app. Il n'est pas necessaire de modifier le Dockerfile car ce dernier va automatiquement cherche la dernière version sur git lors de la compilation.*

Une fois l'image prête, il suffit de la relancer avec la commande:

```bash
docker-compose up -d mon-app
```
## Consulter les logs d'une application

Pour consulter les logs d'une application, docker-compose propose son propre outil:

```bash
docker-compose logs [app1] [app2] [app3] [...]
```

Cette commande va montrer les logs de toutes les applications passé en paramètre. Si aucune app n'est passé en paramêtre, il va montrer les logs de toutes les applications définies dans votre fichier `docker-compose.yml`.

Vous pouvez aussi directement utiliser docker pour consulter les logs (qui a plus d'options de configuration):

```bash
docker log ares_mon-app_1
```

## Liens utiles
 * [Manuel de docker-compose](http://todo.fr/todo)
 * [Manuel de docker](http://todo.fr/todo)
 * [Scripts utiles](/soft/scripts)