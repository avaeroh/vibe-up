# Vibeup

A lean, startup-oriented multi-agent workflow for Codex. It keeps the original BMAD spirit, but trims the process for a smaller team and a faster loop.

This project is a work in progress. The workflow, packaging, and Codex integration points are still being refined.

## What this package contains

- A configurable workflow policy
- Separate persona prompts for each agent
- Stage-based workflows for:
  - Initial setup
  - Proposal
  - Implementation
  - Review
- Story, contract, and test templates
- Stage record templates for capturing initial setup and proposal outputs
- Security and QA gates that are strict by default

## How to use this in Codex

Open this folder in Codex and treat it like a working repository. Codex CLI can read, change, and run code in the selected directory, so this structure is designed to be edited in place as the workflow evolves.

This repo now includes a root `AGENTS.md` so Codex has a standard discovery entry point. The `AGENTS.md` file points Codex to `workflow_config.yaml`, `agents/`, `workflows/`, and `templates/`.

If you want the Vibe Up roles and workflow stages to appear in the Codex `$` picker, use the packaged plugin in `plugins/vibe-up/` as the primary installation path.

### Preferred install in Codex

This repo ships a Codex plugin package at `plugins/vibe-up/` and a local marketplace entry at `.agents/plugins/marketplace.json`.

1. Open this repo in Codex.
2. Install the `Vibe Up` plugin from the repo-local Codex marketplace.
3. Restart or reload Codex if the `$` picker does not refresh immediately.

After installation, typing any of these in the composer should surface a skill:

- `$team-mum`
- `$qa`
- `$developer`
- `$architect`
- `$security`
- `$proposal`
- `$implementation`
- `$swarm`

### Active development install

If your Codex build does not yet expose repo-local plugin installation, or if you are actively editing the skills and want changes to reflect immediately, install the skill folders directly from the repo root with symlinks:

```bash
mkdir -p "${CODEX_HOME:-$HOME/.codex}/skills"
ln -sfn "$PWD/plugins/vibe-up/skills/qa" "${CODEX_HOME:-$HOME/.codex}/skills/qa"
ln -sfn "$PWD/plugins/vibe-up/skills/team-mum" "${CODEX_HOME:-$HOME/.codex}/skills/team-mum"
ln -sfn "$PWD/plugins/vibe-up/skills/developer" "${CODEX_HOME:-$HOME/.codex}/skills/developer"
ln -sfn "$PWD/plugins/vibe-up/skills/architect" "${CODEX_HOME:-$HOME/.codex}/skills/architect"
ln -sfn "$PWD/plugins/vibe-up/skills/security" "${CODEX_HOME:-$HOME/.codex}/skills/security"
ln -sfn "$PWD/plugins/vibe-up/skills/business-analyst" "${CODEX_HOME:-$HOME/.codex}/skills/business-analyst"
ln -sfn "$PWD/plugins/vibe-up/skills/ux" "${CODEX_HOME:-$HOME/.codex}/skills/ux"
ln -sfn "$PWD/plugins/vibe-up/skills/domain-researcher" "${CODEX_HOME:-$HOME/.codex}/skills/domain-researcher"
ln -sfn "$PWD/plugins/vibe-up/skills/qa-architect" "${CODEX_HOME:-$HOME/.codex}/skills/qa-architect"
ln -sfn "$PWD/plugins/vibe-up/skills/initial-setup" "${CODEX_HOME:-$HOME/.codex}/skills/initial-setup"
ln -sfn "$PWD/plugins/vibe-up/skills/proposal" "${CODEX_HOME:-$HOME/.codex}/skills/proposal"
ln -sfn "$PWD/plugins/vibe-up/skills/implementation" "${CODEX_HOME:-$HOME/.codex}/skills/implementation"
ln -sfn "$PWD/plugins/vibe-up/skills/review" "${CODEX_HOME:-$HOME/.codex}/skills/review"
ln -sfn "$PWD/plugins/vibe-up/skills/swarm" "${CODEX_HOME:-$HOME/.codex}/skills/swarm"
```

Then restart Codex so it reindexes the installed skills.

If you prefer copying instead of symlinking, copy the folders from `plugins/vibe-up/skills/` into `${CODEX_HOME:-$HOME/.codex}/skills/` with the same directory names.

Recommended flow:

1. Open the repo in Codex.
2. Start with `workflow_config.yaml` to choose the operating mode.
3. Use the agent prompt files in `agents/` as role-specific instructions.
4. Use the workflow docs in `workflows/` to drive each stage.
5. Capture approved initial setup and proposal outputs in `docs/workflow/` using the stage record templates in `templates/`.
6. Keep stories in `templates/story_template.md` and include API contracts before implementation.
7. Run a strict review pass before merging feature branches to `main`.
8. Run `ruby scripts/validate_workflow.rb` after structural changes to agents, role definitions, skills, or workflow documentation.

### Validate structural changes

Run this from the repo root whenever you add or rename a role, skill, agent file, or stage-record path:

```bash
ruby scripts/validate_workflow.rb
```

The validator checks:

- every role in `workflow_config.yaml` has an agent file, skill directory, and agent metadata
- aliases and priorities are present and non-conflicting
- agent files and role skill directories are registered in `role_definitions`
- documentation capture paths and review references stay aligned
- the README install instructions still mention every shipped skill directory

GitHub Actions also runs the same validator on pushes and pull requests in `.github/workflows/validate-workflow.yml`.

## Default operating model

- `STRICT` mode is the default.
- `AUTO_APPROVE` can be enabled later for faster iteration.
- Security findings block artifacts unless the user explicitly overrides them.
- QA is the quality gate and should block merges that would introduce bugs.
- Stories should be BDD-driven and played back to the user before implementation.
- `coordination.team_mum_enabled: true` enables the optional Team Mum facilitator by default.
- `swarm.max_swarm_depth: 1` and `swarm.allow_sub_swarms: false` protect users from recursive sub-swarms by default.
- `swarm.selection_strategy: referenced-first` makes swarm use explicitly named roles first and otherwise choose the most relevant roles up to the configured limit.
- `workflow_config.yaml` `role_definitions` is the single source of truth for automatic role selection, aliases, and selection hints.

### Opt out of Team Mum

If you do not want Team Mum participating in proposal, implementation, review, or swarm-style coordination, set this in `workflow_config.yaml`:

```yaml
coordination:
  team_mum_enabled: false
  team_mum_mode: off
```

When this is off, skip the `team_mum.md` role and ignore Team Mum participation notes in the workflow documents.

### Swarm safety limits

Vibe Up treats swarm orchestration as a bounded consultation step, not an open-ended recursive process. The default `workflow_config.yaml` protects users from runaway token usage with:

```yaml
swarm:
  enabled: true
  selection_strategy: referenced-first
  max_swarm_depth: 1
  allow_sub_swarms: false
  consultation_rounds: 1
  max_roles_per_swarm: 5
  max_tokens_per_swarm_notes: 1200
  emit_recursive_requests_as_future_actions: true
  max_future_actions: 5
  keep_role_notes_concise: true
  max_bullets_per_role_note: 3
  full_panel_is_opt_in: true
```

What those limits mean:

- `max_swarm_depth: 1`: a swarm can run once, but cannot trigger another swarm beneath it.
- `allow_sub_swarms: false`: consulted roles must not open further swarm-style consultations.
- `consultation_rounds: 1`: each listed role gets one pass in the active swarm.
- `selection_strategy: referenced-first`: if the prompt names roles explicitly, swarm uses those first; if not, it identifies the most relevant roles in priority order up to the configured caps.
- `max_roles_per_swarm: 5`: limits the total number of roles consulted in a single swarm run.
- `max_tokens_per_swarm_notes: 1200`: caps the space spent summarizing role outputs. If the host app cannot meter tokens precisely, treat the role-count and bullet caps as the hard backstop and err shorter.
- `emit_recursive_requests_as_future_actions: true`: if a role implies that another cross-role discussion is needed, that is written out as a `Future Actions` or `Next Steps` item instead of being executed immediately.
- `max_future_actions: 5`: follow-on consultation requests must be summarised and capped.
- `keep_role_notes_concise: true`: role summaries should stay compact to avoid wasting context and tokens.
- `max_bullets_per_role_note: 3`: each consulted role should be summarized in a small bounded note instead of a long replay.
- `full_panel_is_opt_in: true`: full-panel swarm should stay off by default because it can sharply increase token use and overwhelm smaller contexts.

Recommended safety stance:

- Keep sub-swarms disabled by default.
- Treat additional consultation needs as queued follow-up work, not immediate execution.
- Use Team Mum to flag missing handoffs and future coordination work without triggering more consultation loops.
- Use `referenced-first` as the default stance in apps with tighter context windows.
- Cap both swarm and Team Mum outputs aggressively when working in smaller-context environments.
- Treat `swarm.enabled: false` as a hard stop: no consultation, no sub-swarm checks, and no role synthesis.

### Role reference aliases and base configuration

Automatic role selection should only use roles defined in `workflow_config.yaml` under `role_definitions`.

That registry now carries:

- the canonical role id
- the source agent file
- the matching skill
- aliases for explicit role references in prompts
- selection hints for relevance matching
- a default priority for tie-breaking

Example aliases in the current config:

- `business-analyst`: `ba`, `analyst`, `requirements`, `backlog`
- `architect`: `architect`, `architecture`, `systems architect`, `system design`
- `developer`: `developer`, `dev`, `engineer`, `implementation`
- `qa`: `qa`, `tester`, `quality engineer`
- `security`: `security`, `appsec`, `vulnerability`
- `team-mum`: `team mum`, `facilitator`, `coordinator`, `health check`

Recommended behavior for host apps:

- Resolve explicitly named roles through `role_definitions.*.aliases`.
- If no roles are named, rank candidate roles by `selection_hints`, then break ties with `default_priority`.
- If a role exists in the repo but has no `role_definitions` entry, no aliases, or other missing base configuration, exclude it from automatic selection and emit a `Configuration Warnings` section in the response.
- Do not assume new roles are safe for swarm or Team Mum until they are registered in config.

Base configuration for a new role should include:

- a `role_definitions` entry in `workflow_config.yaml`
- `agent_file`
- `skill`
- `aliases`
- `selection_hints`
- `default_priority`

If any of that is missing, swarm and Team Mum should treat the role as manually consultable only, not safe for automatic selection.

This is also where the “hard no-op” rule matters:

- if `swarm.enabled: false`, invoking swarm should stop immediately
- no role selection should happen
- no role consultation should happen
- the response should be a short disabled notice, plus optional non-swarm alternatives

### Enforcement model

These guardrails are defined in prompt/config form. Your host app still needs to load and honor `workflow_config.yaml` for them to be reliably enforced.

To make Vibe Up self-limiting even without perfect host enforcement, the prompts now also tell swarm and Team Mum to:

- stop early when disabled
- respect configured consultation caps
- defer deeper consultation into `Future Actions`
- exclude roles missing base configuration from automatic selection
- keep outputs bounded and concise
- fall back to smaller, relevance-based consultation when utilization or token-metering signals are missing

That means the repo is engineered to encourage safe behavior by default, but hard runtime enforcement still depends on the integrating app.

### Team Mum safety limits

Team Mum is also bounded so she behaves like a coordination health check instead of a second swarm:

```yaml
coordination:
  team_mum_enabled: true
  team_mum_mode: optional
  team_mum_selection_strategy: utilization-and-relevance
  team_mum_max_consulted_roles: 5
  team_mum_consultation_rounds: 1
  team_mum_emit_extra_consultation_as_future_actions: true
  team_mum_max_future_actions: 5
  team_mum_keep_notes_concise: true
  team_mum_max_bullets_per_section: 3
  team_mum_check_in_frequency: stage-or-handoff-risk
  team_mum_reflect_on_recent_agent_utilization: true
```

What those limits mean:

- `team_mum_selection_strategy: utilization-and-relevance`: Team Mum should check in with the most relevant and most-used roles first rather than trying to speak to everyone.
- If recent utilization data is not available, Team Mum should fall back to relevance-first selection rather than broadening the consultation set.
- `team_mum_max_consulted_roles: 5`: caps the width of a single coordination pass.
- `team_mum_consultation_rounds: 1`: keeps Team Mum to one pass per check.
- `team_mum_emit_extra_consultation_as_future_actions: true`: additional coordination needs are deferred instead of executed immediately.
- `team_mum_max_future_actions: 5`: follow-on coordination items are capped.
- `team_mum_keep_notes_concise: true` and `team_mum_max_bullets_per_section: 3`: keep each section bounded and compact.
- `team_mum_check_in_frequency: stage-or-handoff-risk`: Team Mum should check in once per active workflow stage or when a handoff risk appears.
- `team_mum_reflect_on_recent_agent_utilization: true`: Team Mum should consider whether the right roles have been used enough, not just whether they exist.

## Suggested folder structure

```text
vibe-up/
├── README.md
├── workflow_config.yaml
├── docs/
│   └── workflow/
│       └── README.md
├── agents/
│   ├── domain_researcher.md
│   ├── senior_security_specialist.md
│   ├── senior_systems_architect.md
│   ├── senior_developer.md
│   ├── team_mum.md
│   ├── qa_architect.md
│   ├── senior_qa_engineer.md
│   ├── senior_business_analyst.md
│   └── ux_researcher.md
├── workflows/
│   ├── 01_initial_setup.md
│   ├── 02_proposal.md
│   ├── 03_implementation.md
│   └── 04_review.md
└── templates/
    ├── initial_setup_record_template.md
    ├── proposal_record_template.md
    ├── story_template.md
    ├── api_contract_template.md
    └── test_plan_template.md
```

## How the workflow works

### Initial setup
The domain researcher, architect, security specialist, and BA shape the idea at a high level. Once approved, the BA turns the approved epics into stories and asks clarifying questions as acceptance criteria.

### Proposal
The BA coordinates user discussion with the architect, security specialist, and UX researcher to surface conflicts, risks, and roadmap impact before work starts.

### Implementation
The QA engineer writes tests first, the architect validates structure and contracts, development happens on a feature branch, and security/QA gate the merge.

### Review
The team checks the latest implementation, updates documentation, and proposes process or technical efficiencies.

## Roles at a glance

### Domain Researcher
Validates the problem space, assumptions, and constraints.

### Senior Security Specialist
Maintains scans, flags vulnerabilities, and blocks unsafe artifacts unless explicitly allowed.

### Senior Systems Architect
Defines system structure, APIs, and architecture diagrams.

### Senior Developer
Owns implementation quality, code clarity, technical discipline, documentation, and debt control.

### Team Mum
Acts as the optional facilitator who keeps roles aligned, handoffs complete, concerns voiced, and follow-up work visible.
She is essentially the regular health check for the project, making sure the team is being used properly and that nothing important is quietly going off the rails.
Because, obviously, the best products always have their mum's support.

### QA Architect
Defines CI, environments, test strategy, harnesses, and coverage goals.

### Senior QA Engineer
Writes tests first, ensures stories are testable, and blocks merges that would introduce defects.

### Senior Business Analyst
Owns stories, epics, clarification, and BDD acceptance criteria playback.

### UX Researcher
Keeps the user experience coherent and usable.

### Swarm
Uses explicitly referenced roles first, or else selects the most relevant roles in priority order up to the configured limits, then uses Team Mum as a coordination check and proposes the strongest path forward with reasons, limitations, and follow-up questions.

## Coordination Guidance

- Use Team Mum when work spans multiple roles, handoffs are risky, or scope is moving quickly.
- Keep Team Mum optional and facilitative; she should not replace BA, QA, Architecture, Security, or Development ownership.
- Use Team Mum to surface missing work, anti-patterns, integration concerns, and under-used roles before they become project issues.
- If `coordination.team_mum_enabled` is `false`, do not invoke Team Mum even if the workflow docs mention her as an optional facilitator.
- When swarm is active, use Team Mum to identify missing consultation as `Future Actions` or `Next Steps`, not as live sub-swarms.
- Bound Team Mum by `coordination.team_mum_max_consulted_roles` and `coordination.team_mum_consultation_rounds` so she remains a health check, not a second swarm.
- Treat Team Mum as a stage health check: once per active workflow stage, or when a handoff risk is detected.

## Story rules

- Stories must include contracts.
- Implementation must be interface-driven.
- ACs must be clear, testable, and BDD-based.
- The user should receive a playback of ACs before implementation begins.
- Security and QA can stop a story from progressing.

## Tuning the workflow

Adjust `workflow_config.yaml` over time to relax or tighten approvals, coverage targets, or vulnerability handling. Keep the defaults strict at first and only relax gates when you have confidence in the process.

## Next step

Use Codex to open the agent files and adapt them to your stack, then wire the templates into whatever issue tracker, docs system, or repo conventions you prefer.
