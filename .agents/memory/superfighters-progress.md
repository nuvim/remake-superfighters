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
4. **Fase 0 Concluída:**
   - Git inicializado com commit baseline (11.300+ arquivos descompilados preservados).
   - Boilerplate do Vite removido (`counter.ts`, `src/assets/`).
   - `GameLoop.ts` criado com acumulador fixo a 30 Hz (`m_timeStep = 1/30` e `m_iterations = 20`, de `GameMain.as:152,847`).
   - Vitest instalado e suíte de testes unitários configurada (`npm run test`).
5. **Fase 1 Concluída:**
   - `tools/extract/swf.xml` (25.4 MB) gerado via `ffdec-cli -swf2xml`.
   - `build-sprite-db.mjs` desenvolvido e executado: extraiu 845 sprites e mapeou 100% das 55 labels de animação do Billy e dos 9 lutadores.
   - Confirmado que os sub-sprites com os frames reais (ex: 1236 IDLE com 61 frames, 1242 RUN com 12 frames) já estão exportados em `decompiled/assets/sprites/`.
   - Gerado `superfighters-web/src/data/generated/spriteDatabase.json`.
   - Teste unitário `SpriteDatabase.test.ts` adicionado e passando (6/6 testes verdes).
6. **Fase 2 Concluída:**
   - Confirmado pelo AS3 (`Player.as:4973`) que o movimento do jogador é um controlador cinemático desacoplado (gravidade própria 0.6, impulso de pulo até 4 ticks, colisão pés/parede).
   - `PlayerState.ts` implementado com todas as constantes canônicas e testes em `PlayerState.test.ts` (100% verde).
   - `Input.ts` implementado com mapeamento de teclado (WASD, Setas, Shift, Crouch, Dive).
   - `StorageMap.ts` enriquecido com `checkFeetCollision`, `checkWallCollision` e `pushDynamicItem`.
   - `Player.ts` implementado com pulo, mergulho (dive), rolamento (roll), agachamento e colisão com caixas/barris via Planck.js.
   - `main.ts` atualizado: textura do Billy carregada, player instanciado e adicionado à DisplayList, atualização a 30Hz e perseguição suave de câmera.
   - Suíte de testes passando (8/8) e build do Vite verificado sem erros (`npm run build`).
7. **Fase 3 Concluída:**
   - `PlayerAnimation.ts` implementado 1:1 com `PlayerAnimation.as:84-267` (prioridade estrita de labels, rotação angular em DIVE/FALL_B/FALL_F, loop table, piscar de imunidade com alpha 0.2, timers 3/1 e `AnimationDone()`).
   - `CharacterSkin.ts` desenvolvido para orquestrar os sub-sprites de `spriteDatabase.json`, aplicando transformações da matriz canônica (twips/20) para alinhar o MovieClip `ANIM` com a hitbox nos pés.
   - Pré-carregamento assíncrono de animações essenciais adicionado ao bootstrap de `main.ts`.
   - 16 testes unitários em Vitest 100% passando (`npm run test`).
   - Verificação visual no navegador real via `browser_subagent` com captura de screenshots confirmando Billy em pé e andando no mapa Storage com animação fluida, hitboxes perfeitas e sem erros de console.
8. **Correção de Bugs Críticos relatados pelo usuário:**
   - **Queda ao passar da escada:** `StorageMap.ts` ignorava os polígonos inclinados de rampa `stair02` (x: 127 a 157) e `stair01` (x: 304 a 334). Portada a fórmula de rampa de `Maps.as:2362-2366` (`dy = (x - 133) * 0.75` para stair02 e `dy = -(x - 304) * 0.75` para stair01). Criado `StorageMap.test.ts` testando varredura pixel a pixel de x=60 a x=450 comprovando 100% de contato no chão.
   - **Sprites mal recortados / desalinhados:** O script `build-sprite-db.mjs` ignorava matrizes quando `hasScale="false"`, zerando o offset de translação dos sub-sprites. O script foi corrigido para extrair `translateX` e `translateY` canônicos independentemente da escala e o `spriteDatabase.json` foi regenerado. Em `CharacterSkin.ts`, removido `anchor.set(0.5, 1.0)` hardcoded e adotado `anchor.set(0, 0)` posicionado no offset exato de cada sub-frame extraído da matriz do Flash.
   - **Testes Unitários:** 21/21 testes passando no Vitest (`npm run test`).
   - **Validação no Navegador:** Executado teste interativo com `browser_subagent` no Vite (`localhost:5173`). Billy andou para a direita, desceu a rampa suavemente (chegou em x=162, y=273 sem cair no poço), pulou sobre a plataforma e retornou à esquerda. Zero erros no console.
9. **Próximo passo:** Iniciar **Fase 4** (Câmera dinâmica: port de `GetCamArea` de `GameMain.as:1450-1490` / `Cam.as:112-143`, bounding box dinâmica de lutadores, padding de 40px, zoom e interpolação suave).

