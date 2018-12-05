# GoClimateNeutral

This is the code that runs [http://goclimateneutral.org](http://goclimateneutral.org)

## Requirements

* Ruby and bundler
* PostgreSQL
* Firefox and geckodriver

## Getting started

* Install dependencies. 
  * [Install Ruby](https://www.ruby-lang.org/en/documentation/installation/).
    See `.ruby-version` for required version.
  * `gem install bundler`
  * `brew install postgresql geckodriver` 
  * [Get Firefox](https://www.mozilla.org/en-US/firefox/)
* Install project-specific gems.
  * `bundle install`  
* Setup the database
  * `initdb db/goclimateneutral`
  * `pg_ctl -D db/goclimateneutral -l logfile start`
  * `bin/rails db:setup db:seed`
* Set environment variables.
  * Copy `.env.sample` to `.env` and add your keys to the file.

## Running tests

* Watch for updates and continuosly run relevant specs: `bin/guard`
* To run just once: `bin/rspec`

## Running the development server

* `bin/rails server`
* Surf to [http://localhost:3000](http://localhost:3000)

## Stopping the development server

* `lsof -i :3000`
* Kill the process

## Troubleshooting

### Reseting your database

If you need to reset your database:

* Clear lifestyle choices and projects and reset their pk sequences:

  ```ruby
  LifestyleChoice.delete_all
  ActiveRecord::Base.connection.reset_pk_sequence!('lifestyle_choices')
  Project.delete_all
  ActiveRecord::Base.connection.reset_pk_sequence!('projects')
  ```

* Re-run `bin/rails db:seed`
