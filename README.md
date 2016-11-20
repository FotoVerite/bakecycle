# BakeCycle

Centuries old tradition doesn't need to be changed, centuries old technology does.

# URLS

- https://staging.bakecycle.com/
- https://www.bakecycle.com/

# Management
We use Pivotal Tracker for project management. [BakeCycle Tracker Board](https://www.pivotaltracker.com/n/projects/1187388)

# Operations

Can be found and logged at our errors site. http://errors.wizarddevelopment.com/

## Logs and Metrics
We use papertrail via heroku goto the dashboard

# Development

 - Clone repo
 - `npm install`
 - `bundle install`
 - Setup your direnv file
 - Decide what you want to do about workers (run your own or set the env file to run them inline)
 - Reset your database with development data `rake db:devdata`

## Server

`foreman start` will start a unicorn server and a resque worker

## deployment

Circle CI deploys our staging env. The deploy script, pushes, migrates and restarts our app.

`rake deploy:staging` or `rake deploy:production`

## Direnv

Is great, use it.

## Databases
We use postgresql and redis

## Queue System

### To run a single worker
`foreman start worker`

### To access the front-end interface visit `http://localhost:3000/resque` as an admin

## Dev Data

See (and modify) `dev_data.rake` to see what development data gets loaded. It creates users, plans, bakers, etc.

You can use the user `admin@example.com` or `user@example.com` with the password `foobarbaz`

## ERD Diagram
Run `bundle exec erd` to generate

## Integration tests

We use cucumber to run the integration tests. You can tag any test with `@javascript` to use a headless web browser and `@javascript @firefox` to use firefox.

HTML and png screenshots are taken on test failures and are available as test artifacts on the CI
