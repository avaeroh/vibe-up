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

- `$qa`
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
5. Keep stories in `templates/story_template.md` and include API contracts before implementation.
6. Run a strict review pass before merging feature branches to `main`.

## Default operating model

- `STRICT` mode is the default.
- `AUTO_APPROVE` can be enabled later for faster iteration.
- Security findings block artifacts unless the user explicitly overrides them.
- QA is the quality gate and should block merges that would introduce bugs.
- Stories should be BDD-driven and played back to the user before implementation.

## Suggested folder structure

```text
vibe-up/
├── README.md
├── workflow_config.yaml
├── agents/
│   ├── domain_researcher.md
│   ├── senior_security_specialist.md
│   ├── senior_systems_architect.md
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

### QA Architect
Defines CI, environments, test strategy, harnesses, and coverage goals.

### Senior QA Engineer
Writes tests first, ensures stories are testable, and blocks merges that would introduce defects.

### Senior Business Analyst
Owns stories, epics, clarification, and BDD acceptance criteria playback.

### UX Researcher
Keeps the user experience coherent and usable.

### Swarm
Pulls in every available Vibe Up role, compares their positions, and proposes the strongest path forward with reasons, limitations, and follow-up questions.

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
