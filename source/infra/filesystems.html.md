## NFS

Sur le réseau deux machines permettent de partager des fichiers sur le réseau. Pour permettre le montage d'un système de fichier sur une machine distante nous utilisons le protocole `nfs`.

Ronflex est utilisé pour le stockage des données utilisateur et le stockage des applications/

- Le volume `/exports/Infra` est monté sur:
  - Biere : `/exports/Infra`
- Le volume `/exports/mysql` est monté sur:
  - Biere : `/exports/mysql`
- Le volume `/exports/git` est monté sur :
  - Biere : `/exports/git`
- Le volume `/exports/psql` est monté sur :
  - Biere : `/exports/psql`

### Exporter un dossier avec NFS

Pour pouvoir exporter un dossier assurez vous d'avoir installé le paquet `nfs-kernel-server`.

Une fois le paquet installé il suffit d'ajouter la ligne suivante au fichier `/etc/exports` :

```shell
<DOSSIER_A_EXPORTER> HOST_VERS_LEQUEL_EXPORTER(options)
```

Ex :

```shell
/exports/mysql 10.0.0.2(rw,sync,no_root_squash,no_subtree_check)
```

Puis recharger la configuration de `nfs-server`:

```shell
sudo service nfs-kernel-server reload
```

### Monter un dossier distant

Pour monter un fichier distant il suffit d'ajouter cette ligne au fichier `/etc/fstab`:

```
<HOST_NFS>:<CHEMIN_DU_VOLUME_DISTANT> <CHEMIN_LOCAL> nfs rw 0 0
```

Par exemple si je veux monter le dossier `/exports/mysql` de 10.0.0.3 dans mon dossier `/var/lib/mysql` :

```
10.0.0.3:/exports/mysql /var/lib/mysql nfs rw 0 0
```

Enfin créer l'endpoint local et monter les volumes :

```shell
sudo mkdir -p /var/lib/mysql
sudo mount -a
```

## LVM

Afin de permettre un maximum de fléxibilité sur les partitions, les serveurs utilisent le protocol NFS. Il permet d'ajouter, supprimer ou même redimentionner des partitions en toutes simplicitées.

Il est composé de 3 grands compostants:

- Les volumes physiques ('Physical Volumes' ou pv) ce sont les disques physiques présents sur la machines utilisés par LVM.
- Les groupes logiques ('Virtual Groups' ou vg) ce sont des regroupement de partitions Virtuelles.
- Les volumes logigues ('Logical Volumes' ou lv) ce sont les partitions virtulles crées par LVM.

### Utilisation

#### Informations

Lister les volumes physiques:

```shell
sudo pvdisplay
```

Lister les groupes logiques:

```shell
sudo vgdisplay
```

Lister les volumes logiques:

```shell
sudo lvdisplay
```

#### Ajouter un volume logique

Si vous voulez ajouter un volume logique il vous suffit de lancer la commange suivante :

```shell
sudo lvcreate -n <NOM_DU_VOLUME> -L <TAILLE_DU_VOLUME> <VIRTUAL_GROUP>
```

Par exemple pour créer le volume MySQL de 20Go dans le groupe Data :

```shell
sudo lvcreate -n MySQL -L 20g Data
```

Une fois le volume créé il faut le formater :

```shell
sudo mkfs -t ext4 /dev/<VIRTUAL_GROUP>/<NOM_DU_VOLUME>
```
Exemple :

```shell
sudo mkfs -t ext4 /dev/Data/MySQL
```

Enfin il faut dire au système de fichier de monter ce fichier.

Par exemple si je veux monter mon volume MySQL sur `/exports/mysql`, il faut modifier ajouter la ligne suivantes au fichier `/etc/fstab`:

```
/dev/Data/MySQL /exports/mysql ext4 defaults 0 1
```

Enfin il faut appliquer la configuration :

```shell
sudo mkdir -p /exports/mysql
sudo mount -a
```

## Points de montages

- Ronflex
  - `/dev/Data/Infra` => `/exports/Infra`
  - `/dev/Data/MySQL` => `/exports/mysql`
  - `/dev/Data/Git`   => `/exports/git`
  - `/dev/Data/PSQL`  => `/exports/psql`
  - `/dev/data/PAAS`  => `/exports/PAAS`

TODO : Ajouter les tailles des disques