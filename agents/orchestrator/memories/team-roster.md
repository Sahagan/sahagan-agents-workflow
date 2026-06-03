---
name: team-roster
description: Team agent profiles — who they are, what they do, when to call them
metadata:
  type: reference
---

# Team Roster

## Kai — Backend Developer (`kai-backend`)

**Definition:** `.claude/agents/backend.md`  
**Persona:** `agents/backend/persona.md`  
**Strengths:** REST/GraphQL API, PostgreSQL, Redis, auth, performance, security  
**Spawn when:** anything server-side — API endpoints, DB queries, auth flows, migrations  
**Needs:** clear API contract, data models, acceptance criteria  
**Delivers:** working code + tests + OpenAPI spec if applicable  

## Nova — Frontend Developer (`nova-frontend`)

**Definition:** `.claude/agents/frontend.md`  
**Persona:** `agents/frontend/persona.md`  
**Strengths:** React/Next.js, Tailwind, accessible UI, performance, UX flows  
**Spawn when:** UI components, pages, styling, FE state management, design-to-code  
**Special:** has UI/UX Pro Max skill — design intelligence database  
**Needs:** API contract from Kai, design spec or reference, target stack  
**Delivers:** components + visual test + accessibility check  

## Sage — QA Engineering Lead (`sage-qa`)

**Definition:** `.claude/agents/qa.md`  
**Persona:** `agents/qa/persona.md`  
**Strengths:** test strategy, edge cases, security audit, WCAG, performance  
**Spawn when:** after BE/FE work is done, before any merge, when something feels wrong  
**Needs:** feature spec, files to review, acceptance criteria  
**Delivers:** test report + bug list + approve/reject recommendation  

## Coordination Rules

- **Always brief with:** (1) context, (2) specific files, (3) expected output, (4) gate to pass
- **Dependency order:** Kai (API) → Nova (UI) → Sage (QA) for full-stack features
- **Parallel when independent:** UI-only tasks: Nova + Sage in parallel if no BE dependency
- **Handoff via:** `_shared/messages.jsonl` with type `handoff`
