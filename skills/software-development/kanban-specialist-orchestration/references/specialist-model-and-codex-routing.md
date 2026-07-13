# Specialist brain model vs Codex execution model

Use this note when assigning different models to `backend`, `frontend`, `dev-ops`, and `tester`, especially when profiles use `model.openai_runtime: codex_app_server`.

## Core distinction

Treat these as separate routing decisions:

1. **Specialist brain model** — analyzes the task, selects skills/tools, plans, and coordinates.
2. **Codex execution model** — performs repository-oriented implementation or review through Codex CLI/app-server.

Do not assume a profile's `model.default` automatically controls the model selected inside Codex app-server.

## Verification pattern

Inspect all three layers before proposing or changing model assignments:

1. Hermes profile config (`model.default`, provider, base URL, reasoning effort, `openai_runtime`).
2. Codex config (`CODEX_HOME/config.toml`, especially `model`, `model_provider`, and reasoning effort).
3. Hermes→Codex bridge behavior: inspect the `thread/start` request or runtime logs to determine whether Hermes passes an explicit model or lets Codex use its own config default.

A profile list or successful text reply proves profile availability, not Codex model identity. Verify effective Codex model through a redacted `codex doctor --json`, app-server request/log evidence, or another authoritative runtime trace.

## Known routing pitfall

In a Hermes implementation where `CodexAppServerSession.ensure_started()` sends only:

```json
{"cwd": "<workspace>"}
```

Codex chooses the model from its active `CODEX_HOME/config.toml`. Multiple specialist profiles may therefore all use the same global Codex model even when their Hermes `model.default` values differ.

Do not report a per-specialist Codex mapping as active until runtime evidence confirms it.

## Configuration design

For durable independent routing, prefer explicit profile-level settings such as:

```yaml
model:
  default: <specialist-brain-model>
  openai_runtime: codex_app_server
  codex_model: <implementation-model>
  codex_review_model: <review-model>
```

Recommended resolution order:

1. Explicit profile `codex_model` or task-level override.
2. Profile `model.default` as a compatibility fallback.
3. Codex global config only when neither is supplied.

The bridge must pass the resolved model to Codex using a supported app-server field or process/config override. Add tests for propagation and inspect actual runtime evidence after changes.

## Model selection policy

Choose by role and task shape, not by assigning the strongest model everywhere:

- Frontend visual/design work benefits from the strongest frontend/design model.
- Backend standard implementation can use a balanced reasoning/cost model; escalate architecture, concurrency, and migrations.
- DevOps routine YAML/scripts can use a fast coding model; escalate production incidents, Kubernetes, networking, and risky migrations.
- Tester should default to an independent review variant and should not implement unless given a separate fix task.

Keep implementation and review independent when practical:

```text
implementation model → tests/evidence → review model → approve/block
```

Use critical review models for auth, RBAC, payments, security, destructive infrastructure, and data migrations.

## Readiness gate

Before Kanban dispatch:

- Confirm every configured alias exists in the provider's current model catalog.
- Smoke-test the exact profile + model + skills combination.
- Verify tool calls and repository read/write behavior as required.
- Verify the effective Codex model, not merely that `codex_app_server` started.
- Stop before dispatch when profile/model/runtime identity is ambiguous or a probe fails.
