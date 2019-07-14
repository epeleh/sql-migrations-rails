# Sql Migrations Rails
This gem allows you to write plain SQL migrations without Ruby code.

## Usage
In the console type:
```bash
$ bin/rails generate sql_migration AddPartNumberToProducts
```

This will create two empty migration files:
```bash
create db/migrate/20190714142718_add_part_number_to_products.up.sql
create db/migrate/20190714142718_add_part_number_to_products.down.sql
```

Fill them with SQL code and run:
```bash
$ bin/rails db:migrate
```

This works along with common Ruby migrations.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'sql-migrations-rails'
```

And then execute:
```bash
$ bundle
```
