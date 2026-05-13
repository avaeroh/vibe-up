# Implementation Workflow

## Purpose
Implement work on a feature branch with tests, contracts, and security checks in place.

## Participants
- Senior QA Engineer
- Senior Systems Architect
- Senior Security Specialist
- Senior Developer
- Senior Business Analyst
- Team Mum (optional facilitator)

## Steps
1. QA Engineer validates that the story is testable.
2. QA Engineer writes requirement-aligned tests first at the correct level, whether unit, API, UI, or end-to-end.
3. Senior Developer confirms the ticket is implementation-ready and resolves open questions with BA and QA before production code starts.
4. Architect confirms the implementation follows the contract.
5. Senior Developer agrees the TDD approach with QA and implements on a feature branch only after the initial tests exist.
6. Security Specialist scans the work and blocks unsafe artifacts.
7. QA Engineer verifies coverage and behaviour.
8. BA confirms the work still matches the story intent.
9. Team Mum checks coordination, unresolved handoffs, integration concerns, and missing follow-up work.
10. Senior Developer closes any debt introduced, updates documentation, and confirms QA, Architecture, and BA are satisfied.
11. Merge only after all gates pass.

## Output
- Tests
- Implementation
- Security report
- QA verdict
- Coordination notes
- Merge decision
