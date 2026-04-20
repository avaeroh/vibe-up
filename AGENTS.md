# Repository Guidance

This repository defines a custom multi-agent workflow for Codex. Treat the files in this repo as the source of truth for how work should be shaped, approved, implemented, and reviewed.

## Primary Entry Points

- Read `workflow_config.yaml` first to determine the current operating mode and gates.
- Use the markdown files in `agents/` as role prompts and responsibility definitions.
- Use the markdown files in `workflows/` to decide which stage the work is in and what outputs are required before moving forward.
- Use the templates in `templates/` when creating stories, contracts, and test plans.
- Use `docs/workflow/` stage records as durable context when they are present.
- Treat `workflow_config.yaml` as authoritative for optional role participation, including whether `team_mum.md` should be active.
- Treat `workflow_config.yaml` `role_definitions` as the single source of truth for automatic role selection, alias resolution, and selection hints.

## Working Rules

- Ask before assuming when requirements, scope, or acceptance criteria are unclear.
- Do not start implementation until the story is testable and the acceptance criteria have been played back for user approval.
- Define contracts before implementation when the work changes an interface, boundary, or API.
- Treat security and QA findings as blocking unless the user explicitly overrides them.
- Keep the process lean. Follow the repo workflow rather than inventing a new one.
- When changing `workflow_config.yaml`, `agents/`, `plugins/vibe-up/skills/`, or stage-record paths, run `ruby scripts/validate_workflow.rb` before considering the work complete.
- Treat `swarm.enabled: false` as a hard no-op. If swarm is invoked while disabled, stop immediately, consult nobody, and return only a short disabled notice plus optional non-swarm alternatives.
- Treat `swarm.max_swarm_depth` and `swarm.allow_sub_swarms` as hard limits. Do not recurse into additional swarms when the config forbids it.
- When a consulted role implies more consultation is needed, emit that as a `Future Actions` or `Next Steps` item instead of executing another swarm when `swarm.emit_recursive_requests_as_future_actions` is `true`.
- Keep both swarm and Team Mum bounded by their configured consultation caps. Do not widen consultation beyond the configured role limits just because more opinions might be interesting.
- Exclude any role from automatic selection if it is missing a `role_definitions` entry or alias configuration when `role_selection.exclude_roles_missing_base_configuration_from_auto_selection` is `true`.
- Emit `Configuration Warnings` when roles exist in the repo but are missing required base configuration for automatic selection.
- Capture and maintain the configured stage records after initial setup and proposal when documentation capture is enabled.

## Workflow Selection

Choose the workflow document that matches the current phase:

- `workflows/01_initial_setup.md`: turn a raw idea into an approved foundation and epics.
- `workflows/02_proposal.md`: refine the idea into stories, BDD acceptance criteria, and contract notes.
- `workflows/03_implementation.md`: implement on a feature branch with tests, contract checks, and security review.
- `workflows/04_review.md`: review the latest implementation and capture follow-up improvements.

When using swarm-style orchestration, also honor these config rules from `workflow_config.yaml`:

- `swarm.enabled`
- `swarm.max_swarm_depth`
- `swarm.allow_sub_swarms`
- `swarm.consultation_rounds`
- `swarm.selection_strategy`
- `swarm.max_roles_per_swarm`
- `swarm.max_tokens_per_swarm_notes`
- `swarm.emit_recursive_requests_as_future_actions`
- `swarm.max_future_actions`
- `swarm.max_bullets_per_role_note`
- `coordination.team_mum_selection_strategy`
- `coordination.team_mum_max_consulted_roles`
- `coordination.team_mum_consultation_rounds`
- `coordination.team_mum_emit_extra_consultation_as_future_actions`
- `coordination.team_mum_max_future_actions`
- `coordination.team_mum_max_bullets_per_section`
- `coordination.team_mum_check_in_frequency`
- `coordination.team_mum_reflect_on_recent_agent_utilization`
- `role_selection.require_role_definition_for_auto_selection`
- `role_selection.require_aliases_for_auto_selection`
- `role_selection.warn_on_unregistered_roles`
- `role_selection.warn_on_roles_missing_base_configuration`
- `role_selection.exclude_roles_missing_base_configuration_from_auto_selection`
- `documentation.capture_initial_setup_record`
- `documentation.capture_proposal_record`
- `documentation.initial_setup_record_path`
- `documentation.proposal_record_path`
- `documentation.consult_stage_records_in_review`

## Role Mapping

When a task needs one of these perspectives, load the corresponding file in `agents/`.
For automatic selection, `workflow_config.yaml` `role_definitions` remains the canonical registry and must be updated before any new role is treated as swarm-safe or Team-Mum-safe.

- `domain_researcher.md`
- `senior_business_analyst.md`
- `senior_systems_architect.md`
- `senior_developer.md`
- `senior_security_specialist.md`
- `team_mum.md` when `coordination.team_mum_enabled` is `true`
- `qa_architect.md`
- `senior_qa_engineer.md`
- `ux_researcher.md`

## Expected Outputs

Depending on phase, produce the artifacts defined by the active workflow, including:

- problem framing and epics
- captured initial setup records when enabled
- stories with BDD acceptance criteria
- API contract notes
- captured proposal records when enabled
- tests before or alongside implementation where practical
- security findings
- QA verdicts
- review summaries and follow-up proposals
