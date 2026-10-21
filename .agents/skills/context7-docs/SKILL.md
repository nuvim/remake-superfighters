---
name: context7-docs
description: >-
  Consult live, up-to-date documentation and official code snippets for modern libraries and frameworks (Next.js, React 19, Tailwind v4, Supabase, Vite, etc.) using Context7 MCP (`resolve-library-id` and `query-docs`). Prevents writing outdated, deprecated, or hallucinatory code.
when_to_use: "Use when implementing, refactoring, or debugging code that relies on external frameworks, libraries, SDKs, or APIs where version drift or deprecations could occur."
allowed-tools: Read, Write, Edit, Bash
version: 1.0.0
---

# Context7 Live Documentation

Consult the latest official documentation and verified code snippets for libraries and frameworks directly via Context7 MCP.

## Why Use Context7

LLMs have knowledge cutoff dates and frequently hallucinate deprecated methods (e.g. Next.js App Router vs Pages Router differences, React 19 hooks, Tailwind v4 CSS-first config). Context7 fetches the exact, live documentation and up-to-date code examples.

## How to Query Documentation

### Step 1: Resolve Library ID
Before querying documentation, find the canonical library ID:
- Tool: `resolve-library-id` (Server: `context7`)
- Args: `libraryName` (e.g., `"Next.js"`, `"Tailwind CSS"`, `"Supabase"`), `query` (e.g., `"App Router Server Actions"`)

### Step 2: Query Documentation
Using the resolved `libraryId` (e.g. `"/vercel/next.js"`):
- Tool: `query-docs` (Server: `context7`)
- Args:
  - `libraryId`: Canonical ID from Step 1
  - `query`: Specific topic (e.g., `"How to handle form submission with Server Actions in Next.js"`)
  - `language`: Target programming language (e.g., `"TypeScript"`)

## Best Practices
- Query **before** writing complex integrations with third-party SDKs.
- Limit queries to 1-3 targeted questions per task to preserve context window.
- If a method looks unfamiliar or deprecated in existing code, verify it with Context7.
