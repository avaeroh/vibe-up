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
- Senior Systems Architect
- Senior Security Specialist
- Developer or implementation agent
- Senior Business Analyst

## Steps

1. Validate that the story is testable.
2. Write tests first where practical.
3. Confirm the implementation follows the contract.
4. Implement on a feature branch.
5. Scan the work and block unsafe artifacts.
6. Verify coverage and behaviour.
7. Confirm the work still matches story intent.
8. Merge only after all gates pass.

## Outputs

- Tests
- Implementation
- Security report
- QA verdict
- Merge decision
