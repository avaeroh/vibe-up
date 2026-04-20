---
name: implementation
description: Implementation workflow for delivering work on a feature branch with tests, contracts, security review, and QA gates. Use when Codex needs to run the Vibe Up implementation stage on approved stories.
---

# Implementation Workflow

Run the Vibe Up implementation stage.

## Purpose

Implement work on a feature branch with tests, contracts, and security checks in place.

## Participants

- Senior QA Engineer
- Senior Developer
- Senior Systems Architect
- Senior Security Specialist
- Senior Business Analyst
- Team Mum (optional facilitator)

## Steps

1. Validate that the story is testable.
2. Write tests first where practical.
3. Confirm the ticket is implementation-ready and resolve open questions with BA and QA.
4. Confirm the implementation follows the contract.
5. Agree the test approach with QA and implement on a feature branch.
6. Scan the work and block unsafe artifacts.
7. Verify coverage and behaviour.
8. Confirm the work still matches story intent.
9. Check coordination, unresolved handoffs, integration concerns, and missing follow-up work.
10. Close any debt introduced, update documentation, and confirm QA, Architecture, and BA are satisfied.
11. Merge only after all gates pass.

## Outputs

- Tests
- Implementation
- Security report
- QA verdict
- Coordination notes
- Merge decision
