# Shortener

Shortener is a URL shortener application built with Elixir!

**GitHub Pull Requests contain valuable information about decisions made during the
coding process. Please refer to them for more details.**

## Requirements

* [docker](https://www.docker.com/)

## Setup

_This setup covers installation using [docker](https://www.docker.com/). Make sure you have it up and running before continuing._

Clone the repository into your local machine:

```sh
$ git clone git@github.com:davidbrusius/shortener.git
```

Switch to the project directory:

```sh
cd shortener
```

Build docker images:

```sh
docker-compose build
```

Install deps:

```sh
docker-compose run shortener mix do deps.get, deps.compile
```

Setup Shortener database:

```sh
docker-compose run shortener mix ecto.setup
```

All done! You can now run the Shortener app!

## Running

Run the Shortener app:

```sh
$ docker-compose up
```

The app will be available at http://localhost:4000

Shutdown the app:

```sh
$ docker-compose down --remove-orphans
```

Run tests:

```sh
docker-compose run shortener mix test
```
