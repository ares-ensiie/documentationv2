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

Afin d'alerter quand l'utilisation du CPU, de la mémoire ou des Disques devient alarmant sur le système, nous utilisons un autre composant de la stack nommé [kapacitor](http://todo.fr/todo).

Telegraf est un système qui peut se brancher sur la sortie temps réel de différentes bases de données (Influx, Prometheus, etc.) ou accepter des données envoyé en [line format](https://todo.fr/todo). Sur un port UDP.

Une fois les données récupérées, ce logiciel permet de définir des scripts d'analyse de ces données en temps réel pouvant lancer des actions comme des alertes, des scripts, etc.

Dans notre cas nous utilisons uniquement la partie alerting. Les alertes sont générées par kapacitor et directement envoyées sur un channel Slack.

Pour l'instant, les seules données envoyées à kapacitor sont celles provenant de Telegraf. Elles sont disponibles dans la table "telegraf"."default" (base: "telegraf", retention policy: "default").

### Exemple de script TICK:

Le language qu'utilise Kapacitor pour définir un système d'analyse est assez simple. Voici par exemple celui utilisé pour l'alerting CPU.

```ick
stream
  |from()
    .measurement('cpu')
  |alert()
    .id('CPU usage of {{ index .Tags "host" }}/{{ index .Tags "cpu"}}')
    .warn(lambda: "usage_idle" < 30)
    .crit(lambda: "usage_idle" < 10)
    .slack()
```

Kapacitor supporte pluieurs types de récupération des données. La premiere ligne permet de spécifier que nous travaillons sur un type flux.

La seconde permet de spécifier la série sur laquelle nous travaillons (ici: `cpu`).

Une fois la définition de la collecte de donnée effectuée, on peut définir nous alertes.

La première ligne permet de mettre en forme l'indentiant de l'expediteur du message.

Les deux suivante permettent de définir des lambda expression permettant de définir un seuil d'inquiétude et un seuil critique pour l'utilisation CPU.

Enfin la dernière ligne permet de définit la sortie de l'alert (ici slack).

### Ajouter ou modifier un script Tick

Une fois le script tick écrit, il faut l'ajouter a la base de données kapacitor. Pour cela, kapacitor possède un outil en ligne de commande pré-installé sur Biere.

Pour définir un script (l'ajouter ou envoyer une nouvelle version), la syntaxe est la suivante:

```bash
kapacitor define [NOM DE LA TACHE] -tick [Fichier tick] -dbrp [Nom de la DB]
```

Dans notre cas:

```bash
kapacitor define cpu_alert -tick cpu_alert.tick -dbrp "telegraf"."default"
```

Une fois le script ajouté, il faut l'activer.

```bash
kapacitor enable [NOM DE LA TACHE]
```

Dans notre cas:

```ash
kapacitor enable cpu_alert
```


## Spécificitées liées a Ares

### Liaison Influx <-> kapacitor

Normalement en rempliccant le champ `influx` de la configuration de kapacitor, la liaison se fait automatiquement. Cependant dans notre cas kapacitor et influx sont incapable de communiquer entre eux, en effet kapacitor n'arrive pas a trouver correctement son IP et les données ne sont jamais transmises.

Pour remedier à ce problème nous utilisons la connection UDP de kapacitor sur le port `9100` que nous exportons sur Biere et nous spécifions que ces données proviennent de la base de donnée "telegraf"."default".

Config;

```ini
[[udp]]
  enabled = true
  bind-address = ":9100"
  database = "telegraf"
  retention-policy = "default"
```

Ensuite sur Influx, nous ajoutons manuellement une subscription:

```influxql
SUBSCRIPTION CREATE kapacitor0 ON "telegraf"."default" DESTINATIONS ALL ["udp://10.0.0.2:9100"]
```
