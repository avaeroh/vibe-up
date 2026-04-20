---
name: swarm
description: Multi-agent orchestration skill that uses explicitly referenced Vibe Up roles first, or else selects the most relevant roles in priority order up to configured limits, then synthesizes the strongest next step. Use when Codex needs a panel-style decision, wants cross-functional agreement before acting, or should present a proposal with rationale, limitations, and follow-up questions.
---

# Swarm

Run a bounded Vibe Up panel review.

## Purpose

Collect the views of the referenced or most relevant Vibe Up roles, find the strongest area of agreement, and turn that into a concrete proposal for how to move forward.

## Guardrails

- Respect `workflow_config.yaml` as the authority for swarm limits.
- If `swarm.enabled` is `false`, stop immediately, consult nobody, and return only a short disabled notice plus optional non-swarm alternatives.
- Respect `swarm.selection_strategy` when deciding whether to use referenced roles first or the full panel.
- Do not trigger sub-swarms when `swarm.allow_sub_swarms` is `false`.
- Do not exceed `swarm.max_swarm_depth`.
- Use only one consultation pass when `swarm.consultation_rounds` is `1`.
- Do not exceed `swarm.max_roles_per_swarm`.
- Keep role summaries concise when `swarm.keep_role_notes_concise` is `true`.
- Keep each role note within `swarm.max_bullets_per_role_note`.
- Keep total role-note output within `swarm.max_tokens_per_swarm_notes`.
- If exact token metering is unavailable, treat the configured role-count and bullet limits as the hard backstop and err on the side of shorter notes.
- If deeper consultation is needed, emit it as `Future Actions` or `Next Steps` when `swarm.emit_recursive_requests_as_future_actions` is `true`.

## Role Selection

- In `referenced-first` mode, consult explicitly referenced roles first. If no roles are named, identify the most relevant roles in priority order and stop when `swarm.max_roles_per_swarm` or `swarm.max_tokens_per_swarm_notes` would be exceeded.
- In `full-panel` mode, consult the full Vibe Up panel only if it still fits within the configured role and token limits.
- In all modes, if additional relevant roles would help but the limit is reached, list them under `Future Actions` instead of consulting them now.
- Team Mum acts as the facilitator and coordination check only when `coordination.team_mum_enabled` is `true`.
- Resolve explicit role references through `role_definitions.*.aliases`.
- If no roles are explicitly named, rank candidates by `role_definitions.*.selection_hints` and break ties with `role_definitions.*.default_priority`.
- If a discovered role is missing required base configuration, exclude it from automatic selection and emit a `Configuration Warnings` section.

## Role Registry

The canonical role registry lives in `workflow_config.yaml` under `role_definitions`.
Do not treat this file as a second role list.
If a new role exists in the repo but is not registered there with aliases, selection hints, and priority, exclude it from automatic selection and emit a `Configuration Warnings` section instead.

## Process

1. Restate the user request or problem in a short neutral summary.
2. If `swarm.enabled` is `false`, stop immediately and return a short disabled notice without consulting any roles.
3. Select the consulted roles according to `swarm.selection_strategy` and the configured caps, then capture each role's recommendation, concerns, and preferred next step.
4. Use Team Mum, when enabled, to check that the right roles were consulted, concerns were surfaced, and no important handoff or integration issue was skipped.
5. Compare the responses and identify where the roles agree, where they disagree, and what assumptions are driving the disagreement.
6. Choose the most supported path forward. If there is no clear consensus, choose the safest reasonable path and say why.
7. Produce a proposal that the user can approve, challenge, or refine.
8. If additional cross-role discussion would help but recursion is disabled or the current limits are reached, list that as deferred follow-up work rather than executing it.

## Output Format

Always return these sections:

### Consensus

State the path that received the strongest support across the consulted roles.

### Why This Path

Explain why it was chosen, including the key reasons shared by multiple roles.

### Role Notes

Summarize the important concerns or unique insights from each consulted role in a bounded note, keeping each role within the configured bullet limit.

### Coordination Notes

Summarize Team Mum's view on missing perspectives, weak handoffs, integration concerns, or suggested follow-up work when Team Mum is enabled.

### Configuration Warnings

List any roles that were discovered or referenced but excluded because they were missing aliases, role registry entries, or other required base configuration.

### Future Actions

List deferred consultations, missing follow-on work, or next-step conversations that were intentionally not executed inside the current swarm.

### Limitations

Call out the main risks, trade-offs, unresolved disagreements, or missing evidence.

### Follow-up Questions

Ask the user only the questions needed to confirm or refine the proposal.

## Working Rules

- Consult only the roles selected by the configured swarm strategy, within the configured caps, before presenting the proposal.
- Use Team Mum, when enabled, to verify that consultation and handoffs were complete.
- Prefer the most agreed recommendation, not the loudest or most complex one.
- Preserve minority concerns when they materially affect risk, sequencing, scope, or user impact.
- Keep the final proposal concrete enough to turn into stories or implementation steps.
- If the user request is already at implementation depth, still synthesize before recommending action.
- Do not spawn recursive sub-swarms when the config forbids them.
- Convert recursive consultation pressure into bounded `Future Actions` instead of spending more tokens in the current run.
- Do not auto-select roles that are not registered in `role_definitions`.
