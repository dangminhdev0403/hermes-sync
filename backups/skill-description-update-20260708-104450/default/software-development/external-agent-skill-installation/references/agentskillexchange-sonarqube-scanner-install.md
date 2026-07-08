# AgentSkillExchange SonarQube Scanner Skill Install Example

## Context

A user requested installation of the Agent Skill:

- Skill page: `https://skillsmp.com/creators/agentskillexchange/skills/skills-sonarqube-scanner-skill`
- Source URL: `https://github.com/agentskillexchange/skills/tree/main/skills/sonarqube-scanner-skill`
- Skill name / slug: `sonarqube-scanner-skill`
- Preferred command: `npx skills add https://github.com/agentskillexchange/skills --skill sonarqube-scanner-skill`

## Review Findings

The source repo contained the skill at:

```text
skills/sonarqube-scanner-skill/SKILL.md
```

No companion files were present:

```text
SKILL.md
```

Risk scan observations:

- No shell code blocks in `SKILL.md`.
- No companion scripts.
- No obvious destructive commands or secret-handling logic.
- The skill content was descriptive and included upstream SonarQube build guidance (`yarn`, `yarn build`, Java 17) rather than a practical scanner runbook.

## Installation Quirk

The preferred command was available but failed to match the source slug:

```bash
npx skills add https://github.com/agentskillexchange/skills --skill sonarqube-scanner-skill
```

Observed result:

```text
No matching skills found for: sonarqube-scanner-skill
```

The durable lesson is not “npx skills is broken”; it is that `--skill` matching may not accept the directory slug in some catalogs. Verify installation rather than trusting the command.

## Manual Fallback Pattern

When the preferred command fails but the source repo is available:

1. Clone or otherwise fetch the source repo.
2. Locate the exact source skill directory containing `SKILL.md`.
3. Copy the entire directory into the active Hermes profile skills folder, preserving all relative files.
4. Use the requested/source slug as the target folder name when appropriate.
5. If an older active copy exists under a different name, move it to a timestamped backup to avoid duplicate loading.
6. Verify with both filesystem listing and `skill_view`/`skills_list`.

Example installed target:

```text
C:\Users\Admin\AppData\Local\hermes\skills\sonarqube-scanner-skill\SKILL.md
```

Example verification output to capture:

```text
SKILL_MD=present
files:
SKILL.md 2070 bytes
sha256:
908fb6c2b73f895b0e259d2d5670d5abcdea147ec0683f511d8e219e19cf10ea
```

Hermes loader should show a loadable skill path similar to:

```text
path: sonarqube-scanner-skill\SKILL.md
readiness_status: available
```
