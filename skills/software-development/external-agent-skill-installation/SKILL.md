---
name: external-agent-skill-installation
description: Use when installing, replacing, or auditing third-party Agent Skills from SkillsMP, Agent Skill Exchange, GitHub repos, or npx skills commands. Review source first, explain risks, install complete directories, and verify Hermes can load the result.
version: 1.0.0
author: Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [skills, installation, skillsmp, agentskillexchange, hermes]
    related_skills: [hermes-agent-skill-authoring]
---

# External Agent Skill Installation

## Overview

Use this skill when the user asks to install an Agent Skill from a marketplace page, GitHub repository, `npx skills add`, or any third-party skill source. The goal is not just to copy `SKILL.md`; it is to install a complete, reviewed skill package into the active Hermes profile and verify it is loadable.

## When to Use

- User says “install this Agent Skill for me.”
- User provides a SkillsMP / Agent Skill Exchange page plus a source repo.
- User provides a preferred install command such as `npx skills add ... --skill ...`.
- A previously installed skill is wrong, incomplete, or installed under the wrong folder name.

Do not use this for authoring new in-repo Hermes skills; use `hermes-agent-skill-authoring` for that.

## Workflow

1. **Load the relevant Hermes skill context.**
   - For Hermes skills/configuration, load `hermes-agent` if available.
   - For skill structure expectations, load `hermes-agent-skill-authoring` if available.
   - Completion: you know the active profile’s skill directory and the expected `SKILL.md` package shape.

2. **Review the marketplace page and source before installing.**
   - Open or fetch the skill page when possible.
   - Clone or inspect the source repository and locate the exact skill directory.
   - Read `SKILL.md` plus companion files under `references/`, `templates/`, `scripts/`, `assets/`, `agents/`, or other included subdirectories.
   - Completion: you can list every file that will be installed.

3. **Explain material risk before installation.**
   Check for:
   - executable scripts or shell blocks that may run commands;
   - network downloads (`curl`, `wget`, package installs);
   - destructive commands (`rm -rf`, volume deletion, credential writes);
   - token/secret handling;
   - stale or irrelevant upstream instructions.

   Low-risk does not mean useful: call out when the skill is only descriptive or its instructions are copied from an upstream repo rather than being a practical runbook.

4. **Prefer the user’s install command, but verify it actually installed the requested skill.**
   - Run the preferred command if shell is available.
   - If it reports “no matching skills” or installs under an unsuitable target for Hermes, fall back to a manual install.
   - Completion: either the command succeeded and verification proves the skill is present, or the fallback path is started.

5. **Manual fallback: copy the complete skill directory, never `SKILL.md` alone.**
   - Copy the entire source directory containing `SKILL.md` into the active profile’s skills folder.
   - Preserve relative folder structure and all companion files.
   - Use the requested/source slug as the target folder name when appropriate.
   - If replacing an incorrectly named or duplicate folder, back it up rather than deleting it blindly.
   - Completion: target directory contains `SKILL.md` and every source companion file.

6. **Verify from both filesystem and Hermes loader.**
   - Filesystem: list target files, confirm `SKILL.md`, optionally checksum it.
   - Hermes: use `skill_view` or `skills_list` to confirm the skill is loadable in the active profile.
   - Completion: report target path, loadable skill name/path, companion-file status, and any backup path.

## Common Pitfalls

1. **Trusting the marketplace title instead of the source directory.** Always inspect the actual repo path the user provided.

2. **Installing only `SKILL.md`.** This loses scripts, references, templates, assets, and agents. Copy the complete directory.

3. **Treating `npx skills add --skill <slug>` as proof.** Some catalogs match by displayed skill name instead of folder slug, and a slug can fail with “No matching skills found.” Verify the installed directory and Hermes loader output.

4. **Leaving duplicate active folders.** If the same skill exists under an old or wrong folder name, move it to a timestamped backup to avoid ambiguous loading.

5. **Recording transient setup failures as durable facts.** If a browser or CLI is missing in the current environment, report the setup state for this task but do not encode “tool X is broken” into skills.

## References

- `references/agentskillexchange-sonarqube-scanner-install.md` — example fallback install where `npx skills add` could not match the source slug, so the complete source skill directory was copied and verified.

## Verification Checklist

- [ ] Source page/repo inspected before installation
- [ ] `SKILL.md` and all companion files enumerated
- [ ] Risks/limitations explained before installing
- [ ] Preferred command attempted when available
- [ ] Manual fallback copied the whole directory if needed
- [ ] Old duplicate/misnamed active folder backed up, not silently destroyed
- [ ] Target skill directory contains `SKILL.md`
- [ ] Hermes loader can view/list the installed skill
- [ ] Final response includes target path, files installed, and limitations
