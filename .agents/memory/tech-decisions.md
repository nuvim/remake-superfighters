---
type: project
created: 2026-07-18
updated: 2026-10-21
---

# Technical Decisions

- Component metadata uses SemVer while the toolkit release keeps CalVer.
- `manifest.json` and `manifest.lock.json` must remain synchronized with component frontmatter.

## Superfighters Remake
- Stack: TypeScript + Vite + PixiJS v8 + planck.js in `superfighters-web/` (C#/Raylib abandoned 2026-10-20).
- Ground truth = `decompiled/` (FFDec export). Zero invented values; cite AS3 file:line next to constants.
- Logic tick 30 Hz fixed (GameMain.as:847), PTM 30, world gravity (0,10) (Maps.as:118), nearest scaling.
- Player animation = frame labels + child `ANIM` clip; sprite data must come from `ffdec-cli -swf2xml` pipeline.
- Original SWF run in Ruffle as visual reference for side-by-side checks.
