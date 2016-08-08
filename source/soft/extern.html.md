Toute l'infrastructure Ares n'est pas basé que sur des services internes. Pour certains besoin nous acons préféré faire appels à des sociétés qui sont spécialisé dans ce domaine.

## Amazon S3

Pour le stockage des données de nos différents sites web (galeriie, intranet, drinkiit, etc.), nous utilisons un fournisseur d'object Storage nommé Amazon S3.
Nous payons par Go Stocké, Go uploadé et Go téléchargé. Actuellement les factures sont comprises entre 1 et 3$ par mois.

## OVH

Pour la gestion de nos noms de domaine ainsi que de leurs DNS associé, nous utilisons OVH.

Ainsi nous avons chez ovh les noms de domaine suivant:

 * ares-ensiie.eu
 * drinkiit.fr
 * iiens.eu

La facture annuelle d'OVH est généralement de moins de 30 euro.

## Google SMTP

Pour envoyer nos mails, les serveurs internes passent par les serveurs SMTP de google. Cela est une solution a court terme, en effet google surrécrit certains header SMTP et nous sommes soumis aux algorithmes de limitation. En effet l'utilisation de leurs serveurs comme relais SMTP n'est pas tout a fait prévu, il faudrai plutot passer par un système comme Amazon SES ou mailjet mais ces services demandent de whitelister toutes les addresses emails envoyant des emails par leurs services ce qui n'est pas possible dans notre infra (a cause du système de mailing list).

## Slack

En plus de notre communication interne, nous utilisons Slack pour remonter les alertes provenant des serveurs (Kapacitor) et des intégration externes (Rollbar, UptimeRobot, GitLab).

## Rollbar

Rollbar est un service permettant de regroupper et analyser les différentes erreurs générées par Ares. Dans l'idéal il faudrait qu'il soit intégré dans tous les projets d'Ares. Pour l'instant, il n'est disponible que dans certains projets rails.

## UptimeRobot

UptimeRobot permet de monitorer certains de nos sites web. Il envoie toutes les 5mn un ping vers biere, les serveurs SSH et une requête HTTP vers tous nos services web. Si jamais la requète ne revient pas ou qu'elle a généré une erreur, UptimeRobot va envoyer un email a la mailing list `ares@ares-ensiie.eu` ainsi que des notifications Slack.

## NewRelic

NewRelic est un outil d'analyse d'application web (Ruby On Rails). Il fournit une interface web permettant de profiler une application en production. Pour l'instant ce service n'est utilisé que sur l'intranet.
