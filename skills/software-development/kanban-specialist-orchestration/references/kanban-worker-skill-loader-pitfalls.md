# Kanban worker skill-loader pitfalls

## Session pattern

A frontend implementation task completed and a dependent tester QA task failed before doing any QA. The apparent symptom was that the tester task was `blocked`, but the cause was not missing Docker/SonarQube or unfinished frontend work. The worker log showed:

```text
Error: Unknown skill(s): skill-tester, dogfood, local-code-quality-gates,
sonarqube-scanner-skill, requesting-code-review, next-best-practices,
design-taste-frontend
```

The tester profile's skill list showed the skills existed and were enabled, and a direct smoke test worked for the accepted names:

```bash
hermes -p tester chat -q "Multiple skill load smoke test. Reply OK." \
  --skills skill-tester,dogfood,local-code-quality-gates,requesting-code-review,next-best-practices,design-taste-frontend -Q
```

This distinguished a kanban worker/skill-name issue from an environment issue.

## Diagnostic sequence for blocked kanban QA cards

1. Inspect task state and dependencies:
   ```bash
   hermes kanban list
   hermes kanban show <task_id>
   ```
2. If a child tester task is `todo`, check whether its parent is merely `blocked` for `review-required`. A child will not promote until the parent is `done`.
3. If the tester task is `blocked` after a run, inspect attempts and logs:
   ```bash
   hermes kanban runs <task_id>
   hermes kanban log <task_id>
   ```
4. If logs show `Unknown skill(s)`, verify skills in the target profile:
   ```bash
   hermes -p tester skills list
   hermes -p tester chat -q "Skill load smoke test. Reply OK." --skills skill-a,skill-b -Q
   ```
5. If a display name/slug mismatch is suspected, avoid fragile `--skill` flags on the replacement card. Put the required procedure directly in the task body.

## SonarQube-specific lesson

When SonarQube is already installed and running, do not assume a tester crash means SonarQube is unavailable. Verify service state separately, then pass concrete service facts in the tester task body:

```text
SonarQube UI/API: http://localhost:9000
Container: sonarqube-local
Image: sonarqube:community
Scanner image: sonarsource/sonar-scanner-cli:latest
Helper: ~/AppData/Local/hermes/scripts/sonarqube-review.sh
```

If the scanner skill alias is fragile, create the QA task without explicit scanner skill flags and instruct the worker to run the helper when feasible. This preserves the QA intent while avoiding a pre-work skill-loader crash.

## Recovery pattern

- Do not keep retrying the same blocked task with the same explicit skill list.
- Create a replacement QA card with a clean body, no fragile skill aliases, and the verified commands/service facts.
- Dispatch the replacement and leave the old task blocked as historical evidence unless the user asks to clean/archive it.
