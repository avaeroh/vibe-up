---
name: swarm
description: Multi-agent orchestration skill that consults every available Vibe Up role, synthesizes their positions, and proposes the strongest next step. Use when Codex needs a panel-style decision, wants cross-functional agreement before acting, or should present a proposal with rationale, limitations, and follow-up questions.
---

# Swarm

Run a Vibe Up panel review across all available roles.

## Purpose

Collect the views of the full Vibe Up group, find the strongest area of agreement, and turn that into a concrete proposal for how to move forward.

## Roles To Consult

- Domain Researcher
- Senior Business Analyst
- Senior Systems Architect
- Senior Security Specialist
- QA Architect
- Senior QA Engineer
- UX Researcher

## Process

1. Restate the user request or problem in a short neutral summary.
2. Consult each available role and capture its recommendation, concerns, and preferred next step.
3. Compare the responses and identify where the roles agree, where they disagree, and what assumptions are driving the disagreement.
4. Choose the most supported path forward. If there is no clear consensus, choose the safest reasonable path and say why.
5. Produce a proposal that the user can approve, challenge, or refine.

## Output Format

Always return these sections:

### Consensus

State the path that received the strongest support across the consulted roles.

### Why This Path

Explain why it was chosen, including the key reasons shared by multiple roles.

### Role Notes

Summarize the important concerns or unique insights from each consulted role.

### Limitations

Call out the main risks, trade-offs, unresolved disagreements, or missing evidence.

### Follow-up Questions

Ask the user only the questions needed to confirm or refine the proposal.

## Working Rules

- Consult every listed role before presenting the proposal.
- Prefer the most agreed recommendation, not the loudest or most complex one.
- Preserve minority concerns when they materially affect risk, sequencing, scope, or user impact.
- Keep the final proposal concrete enough to turn into stories or implementation steps.
- If the user request is already at implementation depth, still synthesize before recommending action.
