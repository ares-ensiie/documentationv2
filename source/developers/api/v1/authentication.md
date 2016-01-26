# OAuth ARES

Dans un premier temps, il faut une application avec des `client_id` et `client_secret` ces informations peuvent être trouvées sur l'intranet [ici](https://ares-ensiie.eu/oauth/applications).

## Obtenir un access token

_Dans le protocole OAuth2, la procédure d'obtention d'un access_token se déroule en deux étapes, l'authorization et la récupération du token._

### Authorisation

La procédure d'autorisation permet de demander à l'utilisateur si il autorise votre application à accéder aux données que vous demandez.

C'est lors de cette étape que vous indiquez à quels informations vous souhaitez accéder. Pour l'instant aucune politique de scope est appliqué, vous pouvez donc laisser ce champ vide.

L'autorisation se réalise avec une double redirection, vous redirigez l'utilisateur vers une URL forgé, l'utilisateur autorise votre application puis il est redirigé vers une URL que vous avez spécifié dans votre redirection avec un paramètre, le `code`.

Les paramètres pour forger l'URL sont :

    REDIRECTION https://ares-ensiie.eu/oauth/authorize
- `response_type` : doit avoir la valeur "`code`"
- `client_id` : votre `client_id`
- `client_secret` : votre `client_secret`
- `scopes` : liste de scopes séparé par un plus `+`
- `redirect_uri` : adresse vers laquelle il faut rediriger l'utilisateur après l'authorisation.

Le `code` n'est valable que dix minutes.

## Obtention du token

Une fois muni de votre code, vous pouvez faire la demande d'un token d'accès en à l'aide d'une simple requête POST.

    POST http://ares-ensiie.eu/oauth/token
- `client_id` : votre `client_id`
- `client_secret` : votre `client_secret`
- `code` : le code obtenu lors de l'autorisation
- `grant_type` : passer la valeur "`authorization_code`" pour l'instant
- `redirect_uri` : l'adresse vers laquelle vous souhaitez que l'utilisateur soit redirigé.

## Exemple

Commencez d'abord par ajouter un lien pour se logger avec ARES.

```html
<a href="/auth/ares">Se logger avec ARES</a>
```

Definir des variables pour le `client_id`, le `client_secret` ainsi que le `redirect_uri`

```coffeescript
oAuthClientId = 'EXAMPLE'
oAuthClientSecret = 'EXAMPLE'
oAuthRedirectUri = 'http://HOST/auth'
```
Les requêtes vers `/auth/ares` doivent initier le processus d'autorisation.

```coffeescript
app.get '/auth/ares', (req, res) ->
  res.redirect "https://ares-ensiie.eu/oauth/authorize?response_type=code&client_id=#{oAuthClientId}&client_secret=#{oAuthClientSecret}&redirect_uri=#{redirect_uri}"
```

```coffeescript
app.get '/auth', (req, res) ->
  code = req.param 'code'
  if code
    request.post
      url: 'https://ares-ensiie.eu/oauth/token'
      form:
        client_id: oAuthClientId
        client_secret: oAuthClientSecret
        grant_type: 'authorization_code'
        redirect_uri: 'https://sxb-or.herokuapp.com/auth'
        code: code
      (err, response, body) ->
        body = JSON.parse(body)
        unless body.access_token?
          res.send body
        else
          request
            url: "http://ares-ensiie.eu/api/v1/me.json?access_token=#{body.access_token}"
            (err, response, currentUser) ->
              req.session.currentUser = JSON.parse(currentUser)
              res.redirect '/'
```
