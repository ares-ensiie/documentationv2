## Schéma du réseau
Le réseau Ares est structuré comme tel :

![Réseau Ares](/assets/images/ares-network.png)

## Description

Ares est découpé en deux grands sous réseaux.
Le premier est le WAN. Il s'agit du réseau "externe". C'est sur ce réseau que nous disposons de notre accès à internet. Ainsi seul un serveur est directement connecté à ce réseau. Nous avons donc une pate venant du réseau Osiris (Réseau de l'université de strasbourg) nous fournissant notre accès à internet et une pate correspondant à notre serveur frontal Choucroute.

Le second est notre LAN. Il s'agit de notre réseau interne. C'est ici que tous nos serveurs ainsi que tous les clients venant du réseau WIFI ou du (des) réseau(x) cablés atterissent. Pour pouvoir en sortir et accéder à internet il est donc primordial de passer par Choucroute.

Les deux réseaux sont gérés par le même switch (Gandalf) en utilisant la puissance des VLANs.

## Choucroute

Vu que le WAN est principalement controlé par Osiris, nous essayons de minimiser les services connéctés à ce réseau.

Le seul serveur connécté à ce réseau est Choucroute. Ce serveur est notre serveur frontal. C'est à dire qu'il est le seul serveur visible depuis l'exterieur. Il joue donc le rôle de passerelle (Serveur par lequel on doit passer pour aller sur le réseau) et de Firewall (Filtrage des paquets entrants).

De plus ce serveur est en charge de toute la gestion du réseau LAN. C'est donc lui qui va attribuer les addresses IP aux PC connéctés sur le réseau WIFI et/ou cablé (DHCP).

Enfin, vu qu'il est le seul serveur atteignable depuis l'exterieur, toutes les requêtes voulant entrer dans le réseau doivent passer par lui. Il va donc rediriger chacune des requêtes sur le serveur concerné en utilisant des rêgles dans le FireWall.

## Plan d'adressage IP
### WAN
Sur le WAN nous ne disposons que d'une seule IP : `130.79.243.34`.

Les paramètres réseaux sont :

```
Addresse du réseau : 130.79.243.32
Masque : 255.255.255.0
Passerelle : 130.79.243.62
```

### LAN

Pour le LAN nous utilisons la classe privée `10.X.X.X`.
Nous avons donc la configuration suivante :

```
Addresse du réseau : 10.0.0.0
Masque : 255.0.0.0
Passerelle : 10.0.0.1
```

Par convention nous avons divisé ce réseau en plusieurs sous réseau.
Toutes les adresses commencant par `10.0.0.X` sont des serveurs. Sauf ceux sous la forme `10.0.0.1XX` qui sont des equipements de l'ISU.

De plus toutes les IPS commencant en `10.0.1.X` sont les addresses IP des ports de gestion des machines (IPMI, Remote access sur les switchs etc.)

Enfin historiquement les IPS commencant en `10.0.2.X` sont les IPS des machines virtuelles.

Finnalement les ordinateurs des étudiants et de l'administration sont addréssés par le DHCP sur la place `10.3.0.1` - `10.3.128.254`

## VLANs
Le réseau est actuellement divisé en deux VLANs.
Le premier est le VLAN 41. Les équipements de l'ISU l'utilisent pour réorienter les connections vers notre infrastructure. Nous l'avons donc utilisé pour designer notre LAN.
Le deuxième est le VLAN 410. Il est utilisé pour le WAN.

Plus généralement, nous avons décidé avec l'ISU qu'Ares disposera des VLANs 41 et ceux de type 41X (410-419). Il est possible d'en avoir plus, il faut en discuter avec les administrateurs système de l'ISU.

## Faiblesses et TODO
Il faut ajouter des réseaux. Le fait que le client et les serveurs soient sur le même réseau est très dangereux.
Ainsi il faut ajouter des réseau.

Proposition :

* LAN (Clients)
* WAN (OSIRIS)
* INTERNE (Serveurs)
* MAINTENANCE (Ports de maintenances des swtichs et IPMI)