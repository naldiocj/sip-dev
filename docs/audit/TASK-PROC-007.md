# TASK-PROC-007: Mandados CRUD

**Date:** 2026-09-14
**Status:** ✅ Completed
**Risk Level:** R2

## Objective
Implement CRUD for Mandados (judicial warrants/orders) with execution and cancellation workflows.

## Summary
- Created `Admin::MandatesController` with full CRUD + execute/cancel actions
- Created views: index, show, new, edit
- Added `Mandate` model with proper associations and scopes
- Added model specs (13 examples, all passing)
- Added overdue alerts and status badges

## Files Created/Modified

### Controllers
- `app/controllers/admin/mandates_controller.rb` — CRUD + execute/cancel

### Views
- `app/views/admin/mandates/index.html.erb` — List with overdue alerts
- `app/views/admin/mandates/show.html.erb` — Detail with execute/cancel actions
- `app/views/admin/mandates/new.html.erb` — Create form
- `app/views/admin/mandates/edit.html.erb` — Edit form
- `app/views/admin/mandates/_form.html.erb` — Shared form partial

### Models Fixed
- `app/models/mandate.rb` — Fixed associations, scopes, `in_user_scope?`

### Routes
- Added `execute` and `cancel` member routes for mandates

### Factories
- `spec/factories/mandates.rb`

### Specs
- `spec/models/mandate_spec.rb` — 13 examples

## Features
1. **Index**: Search, filter by state/type/process, overdue count alert
2. **Show**: Full mandate details with execute/cancel actions
3. **New/Edit**: Form with type, destination, description, dates, process link
4. **Execute**: Mark mandate as executed
5. **Cancel**: Cancel a mandate

## Test Results
```
Mandate specs: 13 examples, 0 failures
Total: 126 examples, 36 failures (state machine), 12 pending
```

## Evidence
- Mission ID: `task-1789409228039`
- Phase: executing → evidenced

---
*TASK-PROC-007 concluída.*
