For this user, QA/tester code review workflows should run the local SonarQube review gate for frontend/backend cleanliness only during explicit code review/tester verification, not during ordinary implementation. Local helper: ~/AppData/Local/hermes/scripts/sonarqube-review.sh; SonarQube UI/API: http://localhost:9000.
§
User prefers kanban work to follow a confirmation gate: before creating/dispatching kanban tasks, produce a detailed plan, map each specialist profile/deệ to suitable skills, list the selected skills for review, and ask for confirmation before execution.
§
User permits the agent to add, edit, and update specialist skills for backend/frontend/dev-ops/tester when it materially strengthens the project, after careful review. The agent should also keep corresponding skill-[specialist] synchronization skills updated to prevent specialist skill drift/missing skills.
§
When the user says “đồng bộ skills đệ” or similar wording, treat it as a request to repeat the specialist skill synchronization workflow: inventory skills/profiles, update skill-backend/skill-frontend/skill-dev-ops/skill-tester manifests, copy required skill directories into each specialist profile, and verify manifests/profile skill files.
§
For this user’s projects, the agent and delegated specialist profiles must not modify a project’s package.json without asking first. Prefer installing/using dependency versions already synchronized in package.json; if package.json changes are needed, ask for explicit approval before editing.
§
When a new skill appears and its structure does not match the adopted skill-selection convention, the agent may read the full skill once, then refactor it to include a concise frontmatter description/selection summary and conforming structure for future use.