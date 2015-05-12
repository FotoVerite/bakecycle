# BakeCycle the baker app

We like bakers and their bread. Lets make life easier for them.

## Errors

Can be found and logged at our errors site. http://errors.wizarddevelopment.com/

## Logs
We use papertrail via heroku goto the dashboard

## deployment

Circle CI deploys our staging env. The deploy script, pushes, migrates and restarts our app.

`rake deploy:staging` or `rake deploy:production`

## Bower

List packages in the `Bowerfile` and then run  `rake bower:install` to install them.

## Direnv

Is great, use it.

