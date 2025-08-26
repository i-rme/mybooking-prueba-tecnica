# Mybooking - Interview test

## Prerequesites

- Ruby 3.3.0

## Database

The file prueba_tecnica.sql is a dump of the db to be used.

You can setup the sqlite db by using ./init_db.rb
(You must create an empty db folder)

## Preparing the environment
```
bundle install
````

Create an .env file at project root with the following variables

```ruby
COOKIE_SECRET="THE-COOKIE-SECRET"
DATABASE_URL=sqlite://$(pwd)/db/development.sqlite3
TEST_DATABASE_URL=sqlite://$(pwd)/db/test.sqlite3
```

## Running the application

```
bundle exec rackup
```

Then, you can open the browser and check

http://localhost:9292
http://localhost:9292/api/sample

## Running tests

The project uses rspec as testing library

````
bundle exec rspec spec
````

## Working with Rake for command line utils

A basic task, foo:bar, has been implemented to show how it works

```
bundle exec rake foo:bar
```

## Details

This is a sample application for Mybooking technical interview. 
It's a Ruby Sinatra webapp that uses bootstrap 5.0 as the css framework.

## Debugging

Install the extension rdbg and use this as lauch.json

````
{
    // Use IntelliSense para saber los atributos posibles.
    // Mantenga el puntero para ver las descripciones de los existentes atributos.
    // Para más información, visite: https://go.microsoft.com/fwlink/?linkid=830387
    "version": "0.2.0",
    "configurations": [
        {
            "type": "rdbg", // "rdbg" is the type of the debugger
            "name": "Debug Ruby Sinatra",
            "request": "attach",
            "debugPort": "1235",  // The same port as in the config.ru file
            "localfs": true       // To be able to debug the local files using breakpoints
        }
    ]
}
````

