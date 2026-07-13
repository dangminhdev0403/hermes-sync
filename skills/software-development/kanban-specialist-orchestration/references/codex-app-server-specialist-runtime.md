# Codex app-server runtime for specialist profiles

Session learning: fixing Hermes/specialist profiles that report `codex CLI not found at 'codex'` even though the standalone Codex CLI is installed.

## Durable pattern

When enabling Codex mode for default plus specialist profiles (`backend`, `frontend`, `dev-ops`, `tester`), verify both layers:

1. **Binary discovery layer**
   - On Windows/npm/nvm installs, Codex may exist as `codex.cmd` under the Node/NVM symlink directory.
   - Python `subprocess.Popen(["codex", ...], env=custom_env)` can fail to resolve that shim in gateway/cron/specialist contexts even when an interactive shell sees `codex`.
   - The robust fix is to resolve the binary against the same child env before spawning:
     `shutil.which("codex", path=spawn_env.get("PATH"))`, with Windows fallbacks for `.cmd`, `.bat`, and `.exe`.
   - Use the resolved path for both `codex --version` checks and `codex app-server` spawns.

2. **Runtime routing layer**
   - `model.openai_runtime: codex_app_server` only takes effect for providers explicitly treated as OpenAI/Codex eligible by Hermes runtime routing.
   - If the profile uses API-key OpenAI routing, ensure the provider key being used (for example `openai-api`) is included in the eligibility set, not only OAuth-style `openai-codex`.

3. **Profile config layer**
   - Configure every specialist profile intentionally; do not assume default profile settings propagate.
   - Expected shape for API-key-backed Codex app-server mode:
     ```yaml
     model:
       provider: openai-api
       default: gpt-5.5
       base_url: https://api.openai.com/v1
       openai_runtime: codex_app_server
     ```
   - Store secrets through Hermes `.env`/secret helpers; never echo or persist raw API keys in reports or skill docs.

## Smoke tests

Use a layered smoke test before reporting success:

```bash
python -m py_compile hermes_cli/runtime_provider.py agent/transports/codex_app_server.py
python - <<'PY'
from agent.transports.codex_app_server import check_codex_binary, resolve_codex_binary
from tools.environments.local import hermes_subprocess_env
print(check_codex_binary())
print(resolve_codex_binary('codex', env=hermes_subprocess_env(inherit_credentials=True)))
PY
```

Then verify actual runtime, not just CLI presence:

```bash
hermes chat -q '/config' -Q
for p in backend frontend dev-ops tester; do
  hermes -p "$p" chat -q '/config' -Q
done
```

Evidence that the profile is using Codex app-server includes responses that mention Codex's sandbox/workspace context and `agent.log` lines like:

```text
agent.transports.codex_app_server_session: codex app-server thread started ... profile=workspace-write
```

## Pitfalls

- Do not treat `codex --version` in an interactive shell as sufficient. Test the Hermes check path and app-server spawn path.
- Do not print user-provided API keys; redact as `[REDACTED]` and report only boolean/length checks when needed.
- If using `openai-codex`, Hermes may require Hermes-managed Codex OAuth credentials; if the user supplies an API key instead, `openai-api` plus `openai_runtime: codex_app_server` may be the appropriate route.
- Plain/named OpenAI-compatible proxies may normalize to Hermes provider `custom`. Verify the resolver applies `model.openai_runtime: codex_app_server` after custom endpoint resolution; otherwise a successful text probe may silently use chat-completions instead of Codex. Require `agent.transports.codex_app_server_session: codex app-server thread started` in the profile log.
- A model appearing in the proxy `/v1/models` catalog does not guarantee Codex OAuth compatibility. On 9router, `cx/gpt-5.3-codex-spark` may return HTTP 400 (`model is not supported when using Codex with a ChatGPT account`) even while `cx/gpt-5.6-luna` works. Run a direct `codex exec -m <model> ...` probe and treat the raw provider response as authoritative rather than the generic Hermes “authentication failed” classifier.
- A simple text reply from a specialist confirms the profile can run, but file-write tests can be affected by Codex sandbox/approval behavior. Prefer `/config`/log evidence for runtime mode and separate file-write verification when write capability is the acceptance criterion.
- On Windows Kanban workers, a crash like `invalid type: string "[\\\"C:\\\\Users...\\\"]", expected a sequence in sandbox_workspace_write.writable_roots` means Codex parsed the `-c` override as a stringified list because the writable root used backslashes. Normalize the Kanban root for Codex app-server overrides with `os.path.normpath(root).replace("\\\\", "/")`, so the argument is a real TOML sequence such as `sandbox_workspace_write.writable_roots=["C:/Users/.../kanban/boards/<board>"]`. Verify with a subprocess capture/unit test and an actual `hermes -p <specialist> chat -q "..." -Q` smoke test before redispatching the Kanban task.
