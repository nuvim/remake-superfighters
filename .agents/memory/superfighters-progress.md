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
8. **Refinamento Absoluto da Fase 2 (Física Cinemática de Escadas e Caixas/Barris):**
   - **Feedback do Usuário:** "seus testes nao estao bem feitos, ele desce a escd mas nao sobe, e cai no limbo, a fisica dos objetos estao bugados... para de ser apressado e foque em cada fase individualmente, vamos melhorar o maximo possivel".
   - **Investigação Profunda no ActionScript 3 (`Player.as` e `Maps.as`):**
     - O movimento no Flash ocorre em micro-passos de 0.1 px (`dirX * 0.1`) em `MovePlayer` (`Player.as:3883`). A cada micro-passo, `UpdateSimpleGroundMovement` (`Player.as:4551`) ergue o jogador de 0.1 em 0.1 px se houver penetração (`CollisionFeetMid(-1, 1)`), ou abaixa de 0.1 em 0.1 px se estiver flutuando a até 6 px (`CanLandInMid`).
     - Em `Player.as:8082`, `WalkCollision` só testa colisão em `y - 4` e `y - 6` à frente, logo rampas nunca bloqueiam caminhada.
     - Em `GameMain.as:237`, `_static_world_hitbox_mc.addChild(_static_objects_hitbox_mc)`, ou seja, no Flash caixas e barris fazem parte da mesma árvore de colisão do mundo estático.
   - **Correção dos 2 Bugs Críticos:**
     1. **Subir Escadas & Limbo:** `playerEdgeDistance` estava faltando em `PlayerState.ts`, resultando em `undefined`. No JS, `loc1 <= undefined` avaliava para `false`, desativando `canLandInMid()` e `collisionFeetSides()` ao subir rampas, fazendo o Billy cair no limbo. Adicionados `playerEdgeDistance = 6`, `playerHeight = 18` e `maxPlayerHeight = 18`. Adicionada expansão de 0.5px `IncreaseCorners` (`MapPremadeItems.as:2807`) aos polígonos das escadas no `StorageMap.ts`, eliminando perdas de detecção no topo das rampas.
     2. **Física de Objetos (Caixas e Barris):** `hitTestWorld` agora verifica tanto geometria estática quanto corpos dinâmicos (`destructibles`). Caixas barram o jogador na cintura, suportam o jogador em cima (`CollisionFeetMid`), e podem ser empurradas com impulsos lineares (`pushBody` com 1.2 normal / 2.5 sprint).
   - **Validação com Testes:**
     - **Vitest Unitários:** 23/23 testes passando (`tests/StorageMap.test.ts` testa caminhada contínua para a direita de 60 a 400 e para a esquerda de 400 a 60, sem nenhuma perda de contato com o solo).
     - **Python Harnesses:** `tools/test_flash_physics_1to1.py` confirma 100% de estabilidade na simulação física do Flash.
     - **Browser Real (`browser_subagent`):** Billy desceu a `stair02` para o piso inferior (`Pos 297, 273, Grounded: SIM`), virou à esquerda e **SUBIU a `stair02` de volta até a plataforma superior (`Pos 98, 256, Grounded: SIM`) sem cair no limbo**. Ao encontrar uma caixa, foi bloqueado pela colisão, pulou com `W` e aterrissou perfeitamente no topo da caixa (`Pos 297, 259, Grounded: SIM`). Gravado no artefato `billy_stairs_and_physics_test_1792621320384.webp`.
9. **Status Atual:** Fase 2 concluída com rigor 1:1, aguardando validação do usuário antes de iniciar qualquer fase seguinte.

