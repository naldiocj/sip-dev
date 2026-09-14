# Autenticação — SIP (Devise)

> Migrado do Rodauth para [Devise](https://github.com/heartcombo/devise) em 2026-09-14.

## Visão Geral

A autenticação do SIP usa o **Devise** com o modelo `Account` (tabela `accounts`).  
O `Account` partilha o mesmo PK com o modelo `User` (`has_one :user, foreign_key: :id`), mantendo a estrutura de perfis e capacidades da SIC.

## Modelos

| Modelo   | Tabela      | Papel |
|----------|-------------|-------|
| `Account` | `accounts` | Autenticação (login, password, lockout, confirmation) |
| `User`    | `users`    | Dados pessoais, perfis, capacidades, organização |

### Account (autenticação)

```ruby
devise :database_authenticatable, :registerable,
       :recoverable, :rememberable, :validatable,
       :lockable, :confirmable, :trackable
```

Campos relevantes na tabela `accounts`:

| Coluna | Devise | Negócio |
|--------|--------|---------|
| `password_hash` | ↔ `encrypted_password` | bcrypt hash |
| `login` | lookup column | nome de utilizador ou email |
| `email` | `:email` | email institucional |
| `locked_at` | `:lockable` | bloqueio pós 5 tentativas |
| `failed_login_count` | `:failed_attempts` | contagem manual |
| `verified_at` | `:confirmable` | conta confirmada |
| `verification_token` | `:confirmation_token` | token de confirmação |
| `reset_password_token` | `:reset_password_token` | recuperação de password |
| `remember_created_at` | `:rememberable` | remember token |
| `sign_in_count` | `:trackable` | nº de logins |
| `last_sign_in_at` | `:trackable` | último login |

## Rotas

Todas as rotas Devise estão sob `/auth/`:

| Rota | Path | Action |
|------|------|--------|
| `auth_login` | `GET /auth/login` | sessão nova |
| `auth_logout` | `DELETE /auth/logout` | destruir sessão |
| `new_account_registration` | `GET /auth/sign_up` | registo |
| `new_account_password` | `GET /auth/password/new` | recuperar password |
| `edit_account_password` | `GET /auth/password/edit` | definir nova password |

Rotas Devise completas:

```
GET  /auth/sign_in           → sessions#new
POST /auth/sign_in           → sessions#create
DELETE /auth/sign_out        → sessions#destroy
GET  /auth/sign_up           → registrations#new
POST /auth/sign_up           → registrations#create
GET  /auth/password/new      → passwords#new
POST /auth/password/new      → passwords#create
GET  /auth/password/edit     → passwords#edit
PATCH /auth/password         → passwords#update
GET  /auth/confirmation/new  → confirmations#new
GET  /auth/confirmation      → confirmations#show
```

## Controllers

| Controller | Caminho | Responsabilidade |
|------------|---------|-----------------|
| `SessionsController` | `app/controllers/sessions_controller.rb` | login/logout |
| `RegistrationsController` | `app/controllers/registrations_controller.rb` | registo |
| `PasswordsController` | `app/controllers/passwords_controller.rb` | recuperação |
| `ConfirmationsController` | `app/controllers/confirmations_controller.rb` | confirmação |

Todos herdam dos controllers base do Devise e override apenas os callbacks de redirect.

## Application Controller

```ruby
# Pundit callbacks são desativados para controllers Devise
after_action :verify_authorized, except: :index if _skip_pundit_callbacks?
after_action :verify_policy_scoped, only: :index if _skip_pundit_callbacks?

# current_user devolve o User associado ao Account autenticado
def current_user
  account = warden.authenticate(scope: :account)
  account&.user
end
```

`current_user` devolve o `User` associado ao `Account` autenticado, permitindo o uso transparente de Pundit e da lógica de perfis existente.

## Lockout

O lockout é gerido manualmente via `Account#increment_failed_logins!` e `Account#reset_failed_logins!`, mapeando para os campos `failed_login_count` e `locked_at`. O Devise `:lockable` está configurado para usar estes campos existentes.

- **5 tentativas falhadas** → conta bloqueada por 10 minutos
- **Login bem-sucedido** → reseta a contagem e desbloqueia

## Views

Os views Devise estão em `app/views/devise/` com estilo FlowBite (split-screen, cores SIC).

- `devise/sessions/new.html.erb` — login
- `devise/registrations/new.html.erb` — registo
- `devise/passwords/new.html.erb` — recuperação
- `devise/passwords/edit.html.erb` — nova password
- `devise/shared/_links.html.erb` — links entre páginas

## Migração Rodauth → Devise

| Rodauth | Devise |
|---------|--------|
| `Roda.plugin :rodauth` | `devise_for :accounts` |
| `session_key :rodauth_session` | Warden session |
| `after :login` hook | `after_sign_in_path_for` |
| `login_hash_method` | `database_authenticatable` |
| Custom views (ERB) | `devise:views` generator |
| `skip_status_checks?` | `confirmable` + `verified_at` |

O ficheiro `app/rodauth/` foi completamente removido.

## Testes

```bash
# Verificar login
bundle exec rails runner "
  a = Account.first
  puts a.valid_password?('test')
"

# Verificar rotas
bundle exec rails routes | grep devise
```
