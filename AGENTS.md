# Repository Guidance

This repository defines a custom multi-agent workflow for Codex. Treat the files in this repo as the source of truth for how work should be shaped, approved, implemented, and reviewed.

## Primary Entry Points

- Read `workflow_config.yaml` first to determine the current operating mode and gates.
- Use the markdown files in `agents/` as role prompts and responsibility definitions.
- Use the markdown files in `workflows/` to decide which stage the work is in and what outputs are required before moving forward.
- Use the templates in `templates/` when creating stories, contracts, and test plans.

## Working Rules

- Ask before assuming when requirements, scope, or acceptance criteria are unclear.
- Do not start implementation until the story is testable and the acceptance criteria have been played back for user approval.
- Define contracts before implementation when the work changes an interface, boundary, or API.
- Treat security and QA findings as blocking unless the user explicitly overrides them.
- Keep the process lean. Follow the repo workflow rather than inventing a new one.

## Workflow Selection

Choose the workflow document that matches the current phase:

- `workflows/01_initial_setup.md`: turn a raw idea into an approved foundation and epics.
- `workflows/02_proposal.md`: refine the idea into stories, BDD acceptance criteria, and contract notes.
- `workflows/03_implementation.md`: implement on a feature branch with tests, contract checks, and security review.
- `workflows/04_review.md`: review the latest implementation and capture follow-up improvements.

## Role Mapping

When a task needs one of these perspectives, load the corresponding file in `agents/`:

- `domain_researcher.md`
- `senior_business_analyst.md`
- `senior_systems_architect.md`
- `senior_security_specialist.md`
- `qa_architect.md`
- `senior_qa_engineer.md`
- `ux_researcher.md`

## Expected Outputs

Depending on phase, produce the artifacts defined by the active workflow, including:

- problem framing and epics
- stories with BDD acceptance criteria
- API contract notes
- tests before or alongside implementation where practical
- security findings
- QA verdicts
- review summaries and follow-up proposals
