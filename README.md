# BakeCycle the baker app

We like bakers and their bread. Lets make life easier for them.

## Development Server

`foreman start` will start a unicorn server and a resque worker


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

## Databases
We use postgresql and redis

## Queue System

### To run a single worker
`env TERM_CHILD=1 QUEUE=* bundle exec rake resque:work`

### To access the front-end interface you must log in as an admin and visit `http://localhost:3000/resque`

