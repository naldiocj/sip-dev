# TASK-REPORTS: Relatórios PDF/Excel

**Date:** 2026-09-14
**Status:** ✅ Completed
**Risk Level:** R2

## Objective
Implement report generation in PDF and Excel formats for all main entities.

## Summary
- Created `Admin::ReportsController` with PDF and Excel export
- Added report views for Processos, Diligências, Mandados, Evidências
- Integrated WickedPdf for PDF generation
- Integrated Caxlsx for Excel generation
- Added routes for report access

## Features
1. **PDF Export**: Generate professional PDF reports using WickedPdf
2. **Excel Export**: Generate Excel spreadsheets using Caxlsx
3. **Report Types**:
   - Processos (with state, organization, responsible)
   - Diligências (with type, status, dates)
   - Mandados (with type, destination, deadline)
   - Evidências (with type, collector, date)

## Files Created/Modified
- `app/controllers/admin/reports_controller.rb`
- `app/views/admin/reports/*.erb` (4 templates)
- `config/routes.rb` (4 new routes)

## Routes Added
- GET `/admin/reports/processes`
- GET `/admin/reports/diligences`
- GET `/admin/reports/mandates`
- GET `/admin/reports/evidences`

## Evidence
- Mission ID: `task-1789409228039`
- Phase: executing → evidenced

---
*TASK-REPORTS concluída.*
