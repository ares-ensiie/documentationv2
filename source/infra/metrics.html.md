> **Note:** Note système de monitoring est ouvert à tous en `readonly`. Vous pouvez vous y connecter [en cliquant ici](https://grafana.ares-ensiie.eu) (User: guest, Password: guest).

Afin de monitorer les serveurs, nous utilisons plusieurs téchnologies qui permettent respectivement de:

* Récuperer les données sur les serveurs
* Les stocker
* Les afficher
* Gérer les alertes

## Le stockage des données

Pour stocker les données, nous utilisons une base de données en timeseries nomée InfluxDB. Cette base de donnée permet de stocker des données temporelles et de leurs ajouter un ou plusieurs tag. Il existe de nombreuses bases de données de ce genre comme [prometheus](https://todo.fr/todo), [hadoop](http://todo.fr/todo) ou encore [Wrap10](http://todo.fr/todo).

Sur ares nous avons choisi [influxdb](http://todo.fr/todo). Cette base de données n'est toujours pas en version stable mais est très prométeuse. Elle offre des performances plus que convenable et ne nécessite plus trop d'éspace disque (depuis la version 0.13). Elle met également a disposition un language d'intérrogation des données simple et puissant très proche du SQL. De plus elle est entourée d'un ecosystème très adapté à la remonté de ressources avec 3 autres composants a savoir:

* [Telegraf](https://todo.fr/todo): Un logiciel permettant la collecte de données
* [Kapacitor](https://todo.fr/todo): Un logiciel d'analayse de données permettant l'alerting
* [Graphviz](https://todo.fr/todo): Un logiciel de visualisation de données

La base Influx tourne sur Biere et écoute sur son port standard (todo). Les données de la base sont stockées dans le dossier `/exports/Infra/influx/`

## La collecte de données

Pour collecter les données sur le système, nous utilisons [telegraf](http://todo.fr/todo). Telegraf est un des composants de l'écosystème Influx et est donc très bien intégré avec Influx.

Pour l'instant nous collectons les données suivantes toutes les 10 secondes:

* Les informations CPU, RAM, SWAP des serveurs
* L'état des systèmes de fichiers
* La consommation réseau des serveurs
* Les statistiques provenant d'[HAProxy](/infra/reverse-proxy)
* Les statistiques provenant des différents container docker

La configuration de telegraf se fait sur le repository [configs](https://todo.fr/todo).

Si vous voulez mettre a jour la configuration, pushez une modiication sur le gitlab et connectez vous sur les serveurs Biere, Ronflex et Lewi et effectuez les manips suivantes:

```bash
cd ~/configs
git pull origin master
sudo cp NOM_DU_SERVEUR.conf /etc/telegraf/telegraf.conf
sudo service telegraf restart
```

## La visualisation des données

Pour visualiser les données, nous utilisons un logiciel nommé grafana. Grafana se présente sous la forme d'un site web disponible à l'adresse [https://grafana.ares-ensiie.eu//](https://grafana.ares-ensiie.eu).

Sur grafana deux comptes sont disponibles:

* Le compte guest (User: guest, Password: guest) en readonly
* Le compte Ares en admin

Chaque serveur a son propre dashboard, mais en ajouter est éxtrèmement simple via l'outil de création de requète intégré.

## Le système d'alerting

Il sera très simple d'ajouter un système d'alerting en se basant sur **Telegraf**. Cependant cela n'a pas encore été fait.