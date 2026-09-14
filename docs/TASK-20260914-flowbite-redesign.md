# TASK-20260914 — Flowbite Design System Redesign

## Objective
Apply Flowbite design system professionally to all pages including Devise authentication views.

## Changes Made

### 1. Flowbite Component Classes Added to Tailwind CSS
- **Cards**: `fb-card`, `fb-card-header`, `fb-card-body`, `fb-card-footer`
- **Buttons**: `fb-btn`, `fb-btn-primary`, `fb-btn-secondary`, `fb-btn-danger`, `fb-btn-success`
- **Badges**: `fb-badge`, `fb-badge-blue/green/yellow/red/gray/purple/orange`
- **Tables**: `fb-table` with styled thead/tbody
- **Forms**: `fb-label`, `fb-input`, `fb-select`, `fb-textarea`, `fb-error`
- **Alerts**: `fb-alert`, `fb-alert-success/error/warning/info`
- **Stats**: `fb-stat-card`, `fb-stat-value`, `fb-stat-label`
- **Navigation**: Sidebar, topbar, breadcrumb classes
- **Modals**: Overlay, content, header, body, footer

### 2. Layout Updates
- Updated `application.html.erb` with proper Flowbite sidebar styling
- Added shared `_alert` partial for flash messages
- Added shared `_breadcrumb` partial for navigation

### 3. Devise Views Redesigned
- `sessions/new.html.erb` — Login form with Flowbite card
- `registrations/new.html.erb` — Registration form
- `passwords/new.html.erb` — Password recovery
- `passwords/edit.html.erb` — Password change
- `confirmations/new.html.erb` — Email confirmation
- `unlocks/new.html.erb` — Unlock request
- `shared/_links.html.erb` — Authentication links
- `shared/_error_messages.html.erb` — Validation errors

### 4. Admin Views Updated
- `admin/dashboard/index.html.erb` — Dashboard with stat cards
- `admin/processes/` — All process views (new structure)
- `admin/users/index.html.erb` — Users table with filters
- `admin/diligences/index.html.erb` — Diligences list
- `admin/documents/index.html.erb` — Documents table
- `admin/mandates/index.html.erb` — Mandates list
- `admin/organizations/index.html.erb` — Organization tree

### 5. Process Rename Completed
- Created `app/models/process.rb` (replaces `sip_process.rb`)
- Created `app/controllers/admin/processes_controller.rb`
- Created `app/policies/process_policy.rb`
- Created views in `app/views/admin/processes/`
- Removed old `SipProcess` references throughout codebase
- Updated routes to use `/admin/processes`

### 6. Helper Methods Updated
- `state_badge`, `priority_badge`, `estado_badge`, `status_badge` now use `fb-badge` classes

## Files Modified
- `app/assets/stylesheets/application.tailwind.css`
- `app/views/layouts/application.html.erb`
- `app/views/shared/_alert.html.erb` (new)
- `app/views/shared/_breadcrumb.html.erb` (new)
- `app/helpers/application_helper.rb`
- `config/importmap.rb`
- `app/javascript/application.js`
- `config/routes.rb`
- All devise views in `app/views/devise/`
- All admin views in `app/views/admin/`

## Next Steps
1. Run `bin/rails assets:precompile` to compile new CSS
2. Test authentication flow (login, register, password reset)
3. Verify all admin pages render correctly
4. Update any remaining JavaScript for interactive components
