# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

## Autenticação

O SIP usa **Devise** com o modelo `Account` para autenticação. Ver [docs/authentication.md](./docs/authentication.md) para detalhes.

- Login: `/auth/login`
- Registo: `/auth/sign_up`
- Recuperar password: `/auth/password/new`
- Logout: `/auth/logout` (DELETE)

## Stack

- Ruby 3.4 + Rails 8.0
- PostgreSQL (Sequel + ActiveRecord)
- Devise (autenticação)
- Pundit (autorização baseada em perfis/capacidades)
- Tailwind CSS + Flowbite (UI)
- Stimulus + Turbo (frontend)

## Autenticação

O SIP usa **Devise** com o modelo `Account` para autenticação. Ver [docs/authentication.md](./docs/authentication.md) para detalhes.

- Login: `/auth/login`
- Registo: `/auth/sign_up`
- Recuperar password: `/auth/password/new`
- Logout: `/auth/logout` (DELETE)

## Stack

- Ruby 3.4 + Rails 8.0
- PostgreSQL (Sequel + ActiveRecord)
- Devise (autenticação)
- Pundit (autorização baseada em perfis/capacidades)
- Tailwind CSS + Flowbite (UI)
- Stimulus + Turbo (frontend)
