---
name: consult
description: Use this skill when the user wants other agents or models to weigh in on a plan, design, code change, or technical judgment. It gathers independent opinions from Codex, Claude, and Gemini, then synthesizes consensus, disagreements, and next actions. Trigger with requests like "consult others", "ask the other agents", or "get other models' opinions".
---

# Consult

## Overview

Use this skill when a single-model answer is not enough and the user wants a multi-agent review. It builds one shared brief from the current task, consults Codex, Claude, and Gemini in parallel, then returns a synthesized judgment plus short per-provider appendices.

## When To Use

- The user asks to "consult others", "ask the other agents", or "get other models' opinions".
- The task is a design, implementation, architecture, review, or risk call where independent second opinions are useful.

Do not use this skill for routine factual lookup or when the user only wants the current agent's answer.

## Workflow

1. Distill the current conversation and workspace state into a compact shared brief. Keep it focused on the decision at hand.
2. Derive a clean consult question from the user's latest ask. If the user only says "consult others", turn the current request into a direct question before continuing.
3. Resolve `scripts/run_consult.py` relative to this skill directory, then run it outside the sandbox with escalated permissions. Pass the shared brief with exactly one of `--context-file` or `--context-stdin`. Always redirect stdout to a temporary file (e.g. `/tmp/consult_result.json`) and read it back afterward — direct stdout capture may not work reliably.
4. If the script reports more than one provider failure, tell the user the consult could not complete reliably and include the provider errors.
5. If the script reports zero or one provider failure, synthesize the returned opinions into one final judgment.

## Response Format

Structure the final answer in this order:

- Overall judgment
- Strongest consensus points
- Key disagreements
- Recommended next action
- Appendix with short Codex / Claude / Gemini summaries

Keep appendices short. Do not dump full raw outputs unless the user asks for them.

## Guardrails

- Treat this as consultation, not delegation. The three consulted agents may read, search, and web fetch if their CLI allows it, but they should not be asked to modify files or execute actions for the user.
- The orchestration script is additive. It does not replace the current host agent's reasoning; it supplies external opinions.
- Preserve the user's original framing. Do not soften or broaden the consult question unless the current request is too vague to execute.
- Do not run `scripts/run_consult.py` inside the sandbox. Claude CLI cannot reliably access its auth state there, and consults may fail or misreport login state.
