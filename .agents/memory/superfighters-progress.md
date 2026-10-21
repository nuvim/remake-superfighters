---
type: project
created: 2026-10-21
updated: 2026-10-21
---

# Superfighters Remake — Log de Progresso (passo a passo)

> Atualizar ao FINAL de cada sessão. Plano vivo: `superfighters-remake-plan.md` (raiz).
> Datas de 20/10 reconstruídas pelos timestamps dos arquivos (conversa original perdida).

## Sessão 1 — 2026-10-20 (reconstruída)
1. **Engenharia reversa:** REA MCP rejeitou SWF (formato não suportado). Usado JPEXS FFDec (`tools/ffdec/`) →
   `decompiled/scripts/scripts/Code/` (442 classes AS3), `decompiled/assets/` (PNGs, 74 sons, 776 pastas DefineSprite).
2. **Tentativa C# (.NET 8 + Raylib-cs + Box2DSharp)** em `superfighters-csharp/` (Core/Data/Client; `run.ps1`).
   Último edit `Program.cs` 16:42. Falhou visualmente: sem câmera, frames desenhados em grade, sem camadas.
3. **17:47** `PLANO_DEFINITIVO_SUPERFIGHTERS_REMAKE.md` (diagnóstico da falha, ainda em C#).
4. **17:50** Usuário aprovou migração → `PLANO_DEFINITIVO_TS_PIXIJS.md` (TS + PixiJS v8 + planck.js).
5. **17:52–18:05** Scaffold `superfighters-web/` (Vite, pixi.js, planck, howler).
6. **21:45–22:38** Implementados: `DisplayLayers.ts`, `Camera.ts` (Cam.as), `DestructibleItem.ts`,
   `StorageMap.ts` (Maps.as:2346-2435, fundo `28.png`), `main.ts` (pan/zoom debug, `H` hitboxes).
   Passos 1–3 do plano TS concluídos.

## Sessão 2 — 2026-10-21
1. Contexto recuperado a partir dos arquivos. `npm run build` OK.
2. **Auditoria contra o AS3** revelou:
   - Física deve rodar a 30 Hz (`GameMain.as:847`); `main.ts` usa 1/60 → bug.
   - Animação é por **labels** + MovieClip filho `ANIM` (`PlayerAnimation.as:278-365`);
     os 56 PNGs do Billy são só frames externos achatados; sub-frames `ANIM` não exportados.
   - Constantes confirmadas em `PlayerState.as` (gravity 0.6, jump -5, run 1.7, roll 2, dive 3.5…).
3. Criado plano mestre v2 `superfighters-remake-plan.md` (Fases 0–10 + X). Planos antigos = histórico.
4. **Parado aqui. Próximo passo:** Fase 0 (git init, loop 30 Hz, Vitest) → Fase 1 (pipeline swf2xml).
