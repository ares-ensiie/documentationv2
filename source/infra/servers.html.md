## Serveurs physique

### Choucroute

IP:

- eth0: 10.0.0.1
- eth1: 130.79.243.34
- IPMI: 130.79.243.34

Serveur frontal. Il gère:

- Le DHCP pour le WIFI et les prises réseau des salles 1601 et 1604
- Le firewall
- Le serveur DNS

Comptes disponibles:

- root

### Lewi

IP :

- eth0: 10.0.0.4
- IPMI: 10.0.0.204

Comptes disponibles:

- ares

Il gére :

  - Les VM's [voir proxmox](https://todo.fr/todo)

### Biere
IP:

- eth0: 10.0.0.2
- IPMI: 10.0.0.202

Comptes disponibles:

- ares

Il gère :

  - L'infrastructure Docker

### Ronflex

IP:

- eth0: 10.0.0.3
- IPMI: 10.0.0.203

Serveur de stockage.

Il gère:

- Le serveur NFS
- Le PAAS

Comptes disponibles:

- ares

## Serveurs virtuels

### TM

Serveur virtuel tournant sur lewi.

IP:

 - ens18: 10.0.2.1

Il gère:

 - Les serveurs trackmania (2)


## Equipement réseau:

### Controlleur Cisco :
Géré par l'ISU il permet de gérer le WIFI. Nous n'avons aucune accès dessus.

IP: 10.0.0.100

### Gandalf :
Switch cisco en salle serveur:

IP : 10.0.1.1
