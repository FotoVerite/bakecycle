# README

## deployment

Circle CI deploys our staging env. The deploy script, pushes, migrates and restarts our app.

`rake deploy:staging` or `rake deploy:production`

## Heroku Remotes

 - `heroku git:remote -a bakecycle-staging -r staging`
 - `heroku git:remote -a bakecycle-production -r production`

## Bower

List packages in the `Bowerfile` and then run  `rake bower:install` to install them.

## Direnv
