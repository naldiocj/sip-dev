# TASK-PROC-008: Evidências CRUD

**Date:** 2026-09-14
**Status:** ✅ Completed
**Risk Level:** R2

## Objective
Implement CRUD for Evidências (evidence management) with file upload capability.

## Summary
- Created `Admin::EvidencesController` with full CRUD + download
- Created views: index, show, new, edit
- Added `Evidence` model with proper associations and scopes
- Added model specs (8 examples, all passing)
- Updated routes with download action

## Files Created/Modified

### Controllers
- `app/controllers/admin/evidences_controller.rb` — CRUD + download

### Views
- `app/views/admin/evidences/index.html.erb` — List with search/filters
- `app/views/admin/evidences/show.html.erb` — Detail with file download
- `app/views/admin/evidences/new.html.erb` — Create form
- `app/views/admin/evidences/edit.html.erb` — Edit form
- `app/views/admin/evidences/_form.html.erb` — Shared form partial

### Models Fixed
- `app/models/evidence.rb` — Fixed associations, scopes, `in_user_scope?`

### Routes
- Added `download` member route for evidences

### Factories
- `spec/factories/evidences.rb`

### Specs
- `spec/models/evidence_spec.rb` — 8 examples

## Features
1. **Index**: Search by description, filter by type/process
2. **Show**: Evidence details with file download
3. **New/Edit**: Form with type, description, process link, collector, date, file upload
4. **Download**: File download action

## Test Results
```
Evidence specs: 8 examples, 0 failures
Total: 133 examples, 36 failures (state machine), 11 pending
```

## Evidence
- Mission ID: `task-1789409228039`
- Phase: executing → evidenced

---
*TASK-PROC-008 concluída.*
