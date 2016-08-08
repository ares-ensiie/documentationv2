# Ares API v1

_Ce document décrit le fonctionnement de l'API v1 de ARES_

## Sécurité

_On distingue les endpoint accessible par des application et ceux accessible par des utilisateurs. Les applications s'authentifient avec des **tokens d'application** et les utilisateur s'authentifient avec des **tokens utilisateur**._

### Accès application

Les endpoints qui ne manipulent pas de ressources appartenant à un utilisateur en particulier ne demandent pas d'authentifier un utilisateur. On peux accéder à ces endpoints simplement en passant les paramètres `client_id` et `client_secret` aux différents endpoints.

Les tokens sont généré à la création de votre application et vous pouvez les trouver dans les informations relatives à votre application. Si vous ne savez pas comment créer une application, nous vous invitons à [suivre le guide de création d'application](/doc/create_application).

_Dans la documentation anglo-saxonne, ces tokens sont appelés "userless tokens"._

### Accès utilisateur

Certains endpoints permettent d'accéder à des données utilisateur. Pour l'authentification et l'autorisation de vos applications, nous implémentons [le protocole OAuth2](http://oauth.net/2/).

Pour comprendre le fonctionnement du protocole OAuth2, nous vous conseillons de lire [le tutoriel qui vous expliquera comment créer l'application Strasbourg d'Or](/doc/strasbourg-d-or).

### Erreurs

Nous n'avons pas encore défini les réponses de notre API en cas d'erreur. Pour l'instant vous pouvez vous fier aux status code `401` et `50X`.

- `401` Unauthorized : Les tokens donnés ne fonctionnent pas
- `50X` : La faute viens de Ares, merci de [nous contacter sur notre bug tracker](https://bug.ares-ensiie.eu/projects/retour-utilisateurs/issues/new).

## Resources

### Utilisateurs

#### Utilisateur a qui appartien le token


Ce endpoint permet de récupérer des informations à propos de l'utilisateur a qui à été donné le token.

##### Exemple de requête

    GET /ap1/v1/me.json

##### Response

    Status: 200 OK
```json
{
   "uid": "hurter2017",
   "name": "John",
   "lastname": "John",
   "email": "moi@moi.fr",
   "promo": 2017,
   "phone": "+33612345678",
   "address": "4 rue des bananes 67100 Strasbourg",
   "avatar": "http://localhost:3000//users/avatars/000/000/015/original/john.jpg?1452176032",
   "avatar_thumb": "http://localhost:3000//users/avatars/000/000/015/thumb/john.jpg?1452176032",
   "cv": "http://localhost:3000//users/cvs/000/000/015/original/cv.pdf",
   "github": "https://github.com/me",
   "site": "http://me.fr",
   "facebook": "https://www.facebook.com/me",
   "twitter": "https://twitter.com/me",
   "linkedin": "https://fr.linkedin.com/pub/me/83/5a9/15a",
   "updated_at": "2016-01-15T09:33:59.250Z"
}
```