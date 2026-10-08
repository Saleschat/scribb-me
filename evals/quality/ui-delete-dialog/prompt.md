---
description: UI copy. A shadcn/ui AlertDialog for a destructive action, plus its toasts.
tags: [ux-microcopy]
plugins: ["../../../plugin"]
max_turns: 15
timeout_seconds: 400
allowed_tools: [Read, Glob, Grep, Skill, Agent]
---

Create src/components/DeleteProjectDialog.tsx: a React component using shadcn/ui's AlertDialog that asks the user to confirm deleting a project. Props: projectName, dashboardCount, onConfirm. Include the trigger button, the dialog title and description, the cancel and confirm buttons, and sonner toasts for success and for failure. Write all the user-facing text.
