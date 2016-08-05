# ARES documentation repository

## Contribuer à la documentation

### Mise en place environnement

- Avoir une installation de ruby
 
    ```bash
    sudo apt-get install ruby1.9.3 rubygems
    ```

- Installer bundler

    ```bash
    sudo gem install bundler
    ```

- Installer les dépendances du projet

    ```bash
    bundle install
    ```
- Lancer le server 

    ```bash
    bundle exec middleman server
    ```

- Vous pouvez maintenant modifier les fichier de la documentation
et consulter vos changement à l'adresse http://localhost:4567

### Coloration syntaxique

Il est possible d'avoir de la coloration syntaxique markdown avec

    ```ruby
    puts "toto"
    ```

```ruby
puts "toto"
```

pour le laguage ruby par exemple

## Déployer

Pour déployer, il faut builder les pages du site web:

```bash
bundle exec middleman build
```

Puis lancer puma:

```bash
puma
```