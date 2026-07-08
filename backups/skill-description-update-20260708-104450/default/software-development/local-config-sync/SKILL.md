---
name: local-config-sync
description: Safely put local application configuration directories under Git for reinstall/restore workflows while excluding secrets, runtime state, caches, generated install files, and machine-local config.
version: 1.0.0
author: Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [git, configuration, secrets, reinstall, restore, hygiene]
    related_skills: [github-repo-management, github-pr-workflow, hermes-agent]
---

# Local Config Sync

## When to Use

Use this skill when a user wants to Git-track a local application/config directory so future reinstall recovery is just `git pull`, especially for directories containing a mix of durable customizations and runtime/generated local state.

Examples:

- Hermes config/profile/skills directories under `AppData/Local/hermes` or `.hermes`.
- Tool configuration folders with custom scripts, skills, plugins, or templates.
- Reinstall/backup repos where the user says to ignore default install config and keep only self-configured pieces.

## Core Rule

Track **durable, intentional customizations**. Do not track **live secrets, raw machine-local config, runtime databases, locks, caches, logs, sessions, generated usage metadata, or default install files that will be recreated**.

## What to Track

- Hand-written or patched skills, scripts, templates, docs, and policy files.
- Specialist/profile skill copies when intentionally synchronized.
- Safe memory/profile notes that do not contain credentials.
- Restore policy docs such as `docs/HERMES_SYNC.md`.
- Redacted examples such as `config.example.yaml`, never live config.

## What to Ignore / Untrack

- Live config: `config.yaml`, `profiles/config.yaml`, `profiles/*/config.yaml` unless deliberately redacted into example files.
- Secrets/auth: `.env`, `auth.json`, OAuth stores, tokens, credentials, certificates, private keys.
- Runtime state: `*.db`, `*.db-shm`, `*.db-wal`, `*.lock`, `*.pid`, evidence DBs.
- Runtime folders: `cache/`, `sessions/`, `cron/`, `gateway/`, `kanban/`, `logs/`, local service folders.
- Generated skill/app metadata: `.usage.json`, `.usage.json.lock`, `.hub/`, `.curator_state`, prompt snapshots, update checks, provider/model caches.
- Nested repo backups and large generated dependency/build folders.

## Procedure

1. Inspect before editing:
   ```bash
   git status --short --branch
   git remote -v
   git ls-files | sed -n '1,200p'
   git ls-files --others --exclude-standard | sed -n '1,200p'
   ```
2. Write or update `.gitignore` before staging.
3. Remove unsafe/default/runtime files from the Git index without deleting local working files:
   ```bash
   git rm --cached -q $(git ls-files -ci --exclude-standard)
   git rm --cached -q config.yaml profiles/config.yaml profiles/*/config.yaml 2>/dev/null || true
   ```
4. Add a restore policy document that explains what is tracked, ignored, and how to restore after reinstall.
5. Stage after the ignore policy is in place:
   ```bash
   git add -A
   ```
6. Scan only staged added/modified content for secrets. Ignored local secrets may still exist in the working tree and should not be printed:
   ```bash
   python - <<'PY'
   import re, subprocess
   files = subprocess.check_output(['git','diff','--cached','--name-only','--diff-filter=AM'], text=True).splitlines()
   pat = re.compile(r'(sk-[A-Za-z0-9_-]{20,}|ghp_[A-Za-z0-9_]{20,}|github_pat_[A-Za-z0-9_]+|xox[baprs]-[A-Za-z0-9-]+|bot_token\s*:\s*["\']?[^\s"\']{8,}|api_key\s*[:=]\s*["\']?[^\s"\']{8,}|password\s*[:=]\s*["\']?[^\s"\']{8,})', re.I)
   hits=[]
   for f in files:
       if f.endswith(('.db','.db-shm','.db-wal','.png','.jpg','.jpeg','.webp','.zip')):
           continue
       try:
           data=open(f,'r',encoding='utf-8',errors='ignore').read()
       except Exception:
           continue
       if pat.search(data):
           hits.append(f)
   print('potential_secret_hits', len(hits))
   for f in hits: print(f)
   PY
   ```
7. Verify unsafe classes are not tracked:
   ```bash
   git ls-files | grep -E '(^|/)\.env$|auth\.json|config\.yaml|\.db($|-shm$|-wal$)|\.lock$|\.pid$|\.usage\.json|\.hub/' || true
   ```
8. Commit and push:
   ```bash
   git commit -m "Track custom config safely"
   git push origin $(git branch --show-current)
   ```

## Pitfalls

- `git rm --cached` is the correct operation for untracking secrets/generated files while keeping them on disk.
- Do not print secret values. Report counts and paths only, with values redacted as `[REDACTED]` if necessary.
- If a full-tree secret scan flags ignored local files, narrow the scan to staged content before deciding the commit is unsafe.
- A nested repository may leave `m nested-repo` in parent `git status`; treat it as separate from the config-sync commit.
- If live config contains useful settings, document them in a redacted restore guide or `*.example.yaml`; never commit the live config directly.

## Verification Checklist

- [ ] `.gitignore` covers live config, secrets, runtime DBs, locks/PIDs, caches/logs/sessions, generated metadata.
- [ ] Unsafe tracked files were removed with `git rm --cached`, not deleted from the user's machine.
- [ ] Staged added/modified content secret scan returns `potential_secret_hits 0` or all hits are understood false positives.
- [ ] `git ls-files` verification returns no unsafe tracked paths.
- [ ] Restore policy doc exists.
- [ ] Commit and push completed, with final `git status --short --branch` checked.
