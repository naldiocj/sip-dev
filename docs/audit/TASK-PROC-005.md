# TASK-PROC-005: Diligências CRUD

**Date:** 2026-09-14
**Status:** ✅ Completed
**Risk Level:** R2

## Objective
Implement CRUD for Diligências (investigative actions) with filtering and state management.

## Summary
- Created `Admin::DiligencesController` with full CRUD
- Created views: index, show, new, edit
- Added `Diligence` and `DiligenceType` models with proper associations
- Added migration for `diligencia_type_id` foreign key
- Created model specs (15 examples, all passing)

## Files Created/Modified

### Controllers
- `app/controllers/admin/diligences_controller.rb` — Full CRUD

### Views
- `app/views/admin/diligences/index.html.erb` — List with filters
- `app/views/admin/diligences/show.html.erb` — Detail view
- `app/views/admin/diligences/new.html.erb` — Create form
- `app/views/admin/diligences/edit.html.erb` — Edit form
- `app/views/admin/diligences/_form.html.erb` — Shared form partial

### Models Fixed
- `app/models/diligence.rb` — Fixed associations, scopes, `in_user_scope?`
- `app/models/diligence_type.rb` — Added validations, associations

### Migration
- `db/migrate/20260914215201_add_diligencia_type_ref_to_diligences.rb`

### Factories
- `spec/factories/diligences.rb`
- `spec/factories/diligence_types.rb`

### Specs
- `spec/models/diligence_spec.rb` — 11 examples
- `spec/models/diligence_type_spec.rb` — 4 examples

## Features
1. **Index**: Search by description, filter by state/type/responsible
2. **Show**: Full diligence details with process link
3. **New/Edit**: Form with type, description, state, responsible, dates
4. **Scopes**: `active`, `by_estado`, `by_type`, `by_responsavel`

## Test Results
```
107 examples, 0 failures, 14 pending
```

## Evidence
- Mission ID: `task-1789409228039`
- Phase: executing → evidenced

---
*TASK-PROC-005 concluída.*
