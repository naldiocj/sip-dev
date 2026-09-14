---
name: security-review
description: >
  Detecta riscos de segurança antes de considerar implementação concluída.
  Verifica auth, RBAC, injection, secrets, PII etc. Produz .ai/evidence/security-review.md
---

# security-review

## Objetivo
Detectar riscos de segurança antes de considerar uma implementação concluída.

Verifica, conforme aplicável:
- authentication
- authorization
- RBAC
- input validation
- output validation
- secrets
- environment variables
- cookies
- sessions
- CSRF
- CORS
- XSS
- SQL injection
- command injection
- SSRF
- file uploads
- path traversal
- rate limiting
- logging
- PII
- sensitive data exposure
- webhooks
- signatures
- replay attacks
- dependency vulnerabilities

Não inventa vulnerabilidades.

Cada finding deve possuir:
- ID
- severity
- localização
- evidência
- impacto
- recomendação
- estado

Classificação: CRITICAL, HIGH, MEDIUM, LOW, INFO

A revisão deve respeitar a arquitetura e stack real do projeto.
Não altera código durante uma operação explicitamente marcada como audit-only.

## Saída
Produz: `.ai/evidence/security-review.md`

## Workflow
1. `grep` secrets, `read` auth configs
2. `bos_truth` para libs de segurança
3. Gerar relatório com severities
