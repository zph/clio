# Clio

# Clio accepts and parses SYSLOG drains via Heroku's drains:add feature

`heroku drains:add https://USER:PASSWORD@HOST/logplex/new -a clio-deploy-name-on-heroku`

Clio currrently just displays this information via websockets on the page at "/".

To start your Phoenix app:

  1. Install dependencies with `mix deps.get`
  2. Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  3. Start Phoenix endpoint with `mix phoenix.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
