---
name: twentyfirst-dev
description: >-
  Access, search, and integrate over 10,000+ modern, polished UI components, interactive cards, animated menus, forms, pricing tables, and hero sections from the 21st.dev component ecosystem via CLI (`npx @21st-dev/cli@latest`) or MCP.
when_to_use: "Use when creating, styling, or upgrading frontend interfaces, looking for high-quality pre-built UI components, cards, or hero designs from 21st.dev."
allowed-tools: Read, Write, Edit, Bash
version: 1.0.0
---

# 21st.dev Component Integration

Access the 21st.dev component catalog to incorporate polished, modern UI components directly into React, Next.js, and Tailwind projects.

## Overview

21st.dev is a curated repository of production-ready UI components (shadcn-compatible, Tailwind CSS, Lucide icons, Framer Motion) created by top frontend designers.

## CLI Workflow

### Initialize 21st.dev CLI in project
```bash
npx @21st-dev/cli@latest init
```

### Search and Add Components
```bash
# Add a component directly
npx @21st-dev/cli@latest add <component-name>
```

## Best Practices
- Combine 21st.dev components with the project's existing design token system (`design-spec`).
- Audit imported components with `frontend-specialist` to ensure consistent color tokens, responsive behavior, and accessibility.
