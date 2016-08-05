Ares n'a qu'une seule IP publique. Cependant nous devons servir plusieurs site web différents.

Pour réaliser cela il n'y a que deux solutions:

* Soit chaque site écoute sur un port différent sur le serveur frontal. Cela implique qu'un seul site peut écouter sur les ports standard (80 et 443) et que pour les autres le port devra être passé dans l'URL lors de la connection.
* Soit tout le traffic est redirigé vers un seul serveur qui va re-router en interne le traffic vers le bon serveur.

Sur ares nous avons choisi la solution 2.

## Principe de fonctionnement

Ainsi dans nos DNS, nous avons la définition suivante:

```
ares-ensiie.eu   A     130.79.243.34
*.ares-ensiie.eu CNAME ares-ensiie.eu
```

Enfin, sur choucroute, nous avons les rêgles firewall suivaantes:

```
DEST PORT DESTINATION_IP DESTINATION_PORT
*    80   10.0.0.2       80
*    443  10.0.0.2       443
```

Donc tout le traffic venant du réseau externe sur les ports 80 et 443 est redirigé vers le serveur Biere.

Afin d'effectuer le routage sur le serveur Biere, nous utilisons un service nommé [haproxy](http://todo.fr/todo).

Ce service permet (entre autre) de filtrer et rediriger le traffic en fonction du nom de domaine recherché.

Sur Ares, la logique de base est la suivante:

* Si l'URL demandé ne se termine pas en ares-ensiie.eu : On DROP
* Sinon si il s'agit d'une application interne (hébergé sur Biere) : On forward vers cette application
* Sinon on envoie vers le PAAS pour gérer les autre noms de domaines.

## HTTPS

Toutes nos applications communiquent via une connection chiffré (HTTPS). Pour cela nous utilisons un certicat wildcard.
Un certificat wildcard permet de signer toutes les connections provenant d'un nom de domaine ou de l'un de ses sous nom de domaine.
Dans notre cas nous utilisons le certificat wildcard `*.ares-ensiie.eu`.

Afin d'éviter de dupliquer le certificat sur tous les services de notre infrastructure c'est également le reverse proxy qui se charge du chiffrement. Ainsi toutes les connections se font en claire à l'interieur du réseau et ne sont chiffrées qu'au moment de passer par le reverse proxy.

Enfin une règle supplémentaire à été ajouté afin de rediriger tout le traffic non sécurisé vers le port sécurisé.

## Haproxy

Pour effectuer ces opérations, nous utilisons une solution nommée`HAPROXY`. C'est cette solution qui permet le routage et le chiffrement HTTPS.

HAPROXY tourne sur Biere en tant que simple container docker. Son fichier de configuration est présent dans le volume Infra acessible par le chemin suivant: `/exports/Infra/haproxy/haproxy.cfg`.

### Configuration HTTPS

Afin de chiffrer la connection HTTPS. Nous bindons le port `443` et specifions le chemin d'accès vers le fichier certificat:

```
bind *:443 ssl crt /var/cert.pem
```

Pour rediriger le traffic non chiffré vers le port chiffré, nous utilisons la configuration suivante:

```
bind *:80
redirect scheme https if !{ ssl_fc }
```

La première ligne dit à Haproxy d'écouter sur le port 80. Et la seconde instaure une rêgle de redirection vers la même URL en https si la connection n'utilise pas SSL.

### Ajouter un site web

Pour ajouter un site web il faut définir 3 choses:

* Un filtre permettant de reconnaitre le nom de domaine
* Un backend définissant le serveur vers lequel il faut rediriger la requête
* Une règle redirigant la connection vers le backend si le filtre est vérifié.

Commencons par définir un filtre qui se base sur le nom de domaine.

Dans Haproxy, les filtres sont appelé des ACL.

Pour définir un ACL, la syntaxe est la suivante:

```
acl NOM CONDITION
```

Par exemple pour les ragots, nous allons définir un acl `is_ragots`:

```
acl is_ragots hdr(host) -i ragots.ares-ensiie.eu
```

La partie `hdr(host)` permet d'isoler le nom de domaine, mais il existe d'autre règle comme `hdr_end(host)` qui permet de tester si le nom de domaine ser termine par la chaine suivante.

Une fois l'acl définit, il nous faut définire un backend.

Un backend est définit dans un bloc de la forme:

```
backend NOM_DU_BACKEND
  balance TYPE_DE_REPARTITION
  server NOM_DU_SERVER IP:PORT check
  server NOM_DU_SERVER IP:PORT check
  ...
```

Le type de répartition permet, s'il y a plusieur serveurs, de choisir commment répartir le traffic entrant sur ces serveurs. Par exemple en mode `roundrobin` il le fera aléatoirement.

Dans notre cas nous voulons définir le backend `ragots` qui est disponible sur sur l'IP `10.0.0.2` sur le port `8087`. Cela nous donne donc le blog suivant:

```
backend ragots
  balance roundrobin
  server ragots_01 10.0.0.2:8087 check
```

Enfin il faut définir une règle de redirection pour cela il existe l'instruction `use_backend`. Dans notre cas:

```
use_backend ragots if is_ragots
```

Si l'on met toutes ces instructions ensemble, cela nous donne le fichier suivant:

```
defaults
  log     global
  mode    http
  option  httplog
  option  dontlognull
  retries 3
  option redispatch
  maxconn 10000
  timeout connect      5000
  timeout client      50000
  timeout server      50000

frontend http-in
  bind *:80
  bind *:443 ssl crt /var/cert.pem
  redirect scheme https if !{ ssl_fc }
  mode http

  option httpclose
  option forwardfor
  reqadd X-Forwarded-Proto:\ https

  acl is_ragots hdr(host) -i ragots.ares-ensiie.eu

  use_backend ragots if is_ragots

backend ragots
  balance roundrobin
  server ragots_01 10.0.0.2:8087 check
```