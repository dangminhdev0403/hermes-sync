# Specialist model and confirmation-gate restore

This repository tracks the durable parts of the backend, frontend, dev-ops,
and tester profiles without committing live credentials or machine-local
runtime state.

## What is restored

- Specialist `SOUL.md`, durable `USER.md`, skills, manifests, and skill indexes.
- Brain/Codex routing through the local 9router OpenAI-compatible proxy.
- Profile-scoped `agent.confirmation_gate: true`.
- A Hermes Agent source patch that supports profile-specific Codex models and
  enforces plan -> confirmation -> approved execution without asking twice.

## Models

| Profile | Brain and Codex model |
| --- | --- |
| backend | `cx/gpt-5.6-sol` |
| frontend | `cx/gpt-5.6-sol` |
| dev-ops | `cx/gpt-5.6-luna` |
| tester | `cx/gpt-5.6-terra-review` |

All four use `http://127.0.0.1:20128/v1`, `provider: custom`,
`openai_runtime: codex_app_server`, and medium reasoning effort.

## Fresh-machine procedure

1. Install Hermes normally and complete `hermes setup`. This creates live
   config and local auth files. Do not replace those files from Git.
2. Clone this repository under the Hermes home directory.
3. Merge the safe templates into live profile config:

   ```bash
   uv run --with pyyaml --no-project python scripts/restore-specialist-config.py --dry-run
   uv run --with pyyaml --no-project python scripts/restore-specialist-config.py
   ```

4. Copy the tracked durable profile/skill directories into the Hermes home if
   the clone is not already overlaid there.
5. If the installed Hermes Agent does not yet contain the runtime changes,
   validate and apply the patch from the Hermes Agent repository root:

   ```bash
   git apply --check ../hermes-sync/patches/hermes-agent/specialist-codex-routing-and-confirmation-gate.patch
   git apply ../hermes-sync/patches/hermes-agent/specialist-codex-routing-and-confirmation-gate.patch
   ```

   Stop if `git apply --check` fails; the upstream source has drifted and the
   patch must be reviewed/rebased rather than forced.
6. Run the targeted tests:

   ```bash
   uv run --with pytest --with pytest-xdist --no-project python -m pytest \
     tests/run_agent/test_codex_app_server_integration.py \
     tests/agent/transports/test_codex_app_server_runtime.py \
     -q --tb=short -n 0
   ```

7. Start/restart the four specialist gateways and run a two-step behavior
   smoke test. Before approval, a file-write request must return a plan ending
   in `NEEDS_CONFIRMATION` and create nothing. After replying `ok triển khai`
   in the same Hermes session, the exact approved artifact must be created and
   read back without a second Codex approval prompt.

## Security and portability

- `config.yaml`, `.env`, auth stores, sessions, logs, databases, caches, and
  backups remain ignored.
- `config.example.yaml` files contain no credentials and are merged by
  allowlist; they do not replace machine-local config.
- 9router itself and Codex authentication must be configured independently on
  each machine.
- The patch is version-sensitive. Always run `git apply --check` first.
