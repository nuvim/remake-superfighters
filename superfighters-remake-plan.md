# Superfighters Remake — Plano Mestre (v2, refinado)

> **Status:** Fonte única da verdade. Substitui `PLANO_DEFINITIVO_SUPERFIGHTERS_REMAKE.md`, `PLANO_DEFINITIVO_TS_PIXIJS.md` e `PLANO_REMAKE_CSHARP.md` (mantidos só como histórico).
> **Atualizado:** 2026-10-21 · **Stack:** TypeScript + Vite + PixiJS v8 + planck.js · **Projeto ativo:** `superfighters-web/`
> **Histórico de sessões:** `.agents/memory/superfighters-progress.md`

## Objetivo
Port 1:1 do *Superfighters* (Flash/AS3) para web, onde **todo número, regra e frame vem do SWF descompilado** — zero invenção.

---

## 1. Contrato de Fidelidade (regras invioláveis)

| # | Regra | Como aplicar |
|---|-------|--------------|
| F1 | Toda constante cita a fonte | Comentário `// Player.as:7708` ao lado do valor |
| F2 | Lógica roda a **30 Hz fixo** | `GameMain.as:847` → `m_timeStep = 1 / (30 / Slowmotion)` |
| F3 | Escala física 30 px = 1 m | `GameMain.as:856` (`GetPosition().x * 30`) |
| F4 | Gravidade do mundo `(0, 10)` | `Maps.as:118` |
| F5 | Pixel art nítida | `scaleMode = 'nearest'`, `roundPixels`, sem antialias |
| F6 | Animação = **labels** + filho `ANIM` | `PlayerAnimation.as:278-365` (não é "frame 1..56") |
| F7 | Dados vêm de extração, não de digitação | JSON gerado pelo pipeline da Fase 1 |
| F8 | Na dúvida, investigar o AS3 — nunca chutar | Registrar a dúvida na seção 7 |

---

## 2. Estado Atual (verificado em 2026-10-21)

| Módulo | Arquivo | Estado |
|--------|---------|--------|
| Scaffold Vite + Pixi + planck | `superfighters-web/package.json` | ✅ `npm run build` passa |
| DisplayList (9 camadas Flash) | `src/engine/DisplayLayers.ts` | ✅ |
| Câmera (port `Cam.as`) + pan/zoom debug | `src/engine/Camera.ts` | ✅ (sem seguir jogadores ainda) |
| Mapa Storage (solo/cloud/ladder) | `src/stage/StorageMap.ts` | ✅ `Maps.as:2346-2435`, tecla `H` = hitboxes |
| Caixas/barris físicos | `src/stage/DestructibleItem.ts` | ✅ massas de `MapPremadeItems.as` |
| Assets | `public/assets` → `decompiled/assets` | ✅ |

### Defeitos encontrados na auditoria (corrigir na Fase 0)
1. **Passo físico errado:** `main.ts` faz `world.step(1/60)` a cada tick do Pixi. Original = 1/30 a 30 Hz (F2). Velocidades e quedas estão em ritmo errado.
2. **Modelo de animação errado nos planos antigos:** os 56 PNGs de `DefineSprite_1372_player_billy` são os *frames rotulados externos* achatados. Cada label (`IDLE`, `RUN`, `DIVE`…) contém um MovieClip filho `ANIM` (e `HELPMC`, `ANIM_WPN`, `DOLL`) com sub-frames próprios — **que não estão exportados**.
3. Labels de frame e matrizes de `PlaceObject` (pivôs/offsets) não foram extraídos.
4. Sem repositório git, sem testes, boilerplate do Vite (`counter.ts`, `hero.png`) ainda presente.

---

## 3. Arquitetura Alvo

```
superfighters-web/
├── tools/extract/            # Pipeline SWF → JSON (Node, roda offline)
│   ├── swf2xml.ps1           # ffdec-cli -swf2xml
│   └── build-sprite-db.ts    # XML → src/data/generated/*.json
├── public/assets/            # PNGs/MP3s (+ sub-sprites exportados)
├── src/
│   ├── main.ts               # bootstrap apenas
│   ├── data/generated/       # sprites.json, labels.json (NÃO editar à mão)
│   ├── engine/  GameLoop.ts (30 Hz fixo) · Camera.ts · DisplayLayers.ts · Input.ts
│   ├── stage/   StorageMap.ts · DestructibleItem.ts · Ladders/Clouds (contact filter)
│   ├── player/  PlayerState.ts · Player.ts · PlayerAnimation.ts · CharacterSkin.ts
│   ├── weapons/ WeaponRegistry.ts · ProjectilesUpdater.ts
│   ├── destruction/ Explosions.ts · Fires.ts
│   ├── audio/   Sounds.ts
│   ├── ui/      PlayerBars.ts
│   └── ai/      BotState.ts · PathGrid.ts
└── tests/                    # Vitest — ports puros (sem Pixi)
```

**Princípios:** lógica (`player/`, `weapons/`, `ai/`) sem dependência de Pixi → testável; Pixi só em `*Skin`/renderers; input abstraído em ações (`left/right/up/down/attack/jump/sprint`), mapeadas a teclas de `InputKeyboard.as`.

---

## 4. Roteiro por Fases

> Cada fase termina com app rodando em `npm run dev` + verificação visível. Não avançar com fase vermelha.

### Fase 0 — Higiene e loop correto *(pré-requisito)*
- [x] `git init` na raiz + `.gitignore` (node_modules, dist, bin, obj, `superfighters-flash-game/*.zip`) → Verify: `git status` limpo após commit inicial
- [x] Remover `counter.ts`, `src/assets/*` do Vite → Verify: build passa
- [x] Criar `GameLoop.ts` com acumulador fixo 1/30 s, render a cada rAF → Verify: overlay mostra `logic: 30 Hz`
- [x] Trocar `world.step(1/60, 8, 3)` por `step(1/30)` com iterações de `GameMain.as` (`m_iterations = 20`) → Verify: física correta a 30Hz
- [x] Instalar Vitest + 1 teste trivial → Verify: `npx vitest run` verde (3 testes passando)

### Fase 1 — Pipeline de extração de sprites *(caminho crítico, desbloqueia tudo)*
- [x] `tools/ffdec/ffdec-cli.exe -swf2xml superfighters.swf tools/extract/swf.xml` → XML de 25MB gerado com tags FrameLabelTag
- [x] Script `build-sprite-db.mjs`: extrai para cada lutador `{spriteId, frameCount, labels{frameNumber, childId, childName, matrix}}`
- [x] Sub-sprites `ANIM`/`HELPMC`/`ANIM_WPN` validados em `decompiled/assets/sprites/DefineSprite_*` (ex: 1236 IDLE 61 frames, 1242 RUN 12 frames)
- [x] Offset de matriz (twips/20 = px) extraído por frame para alinhamento pixel-perfect
- [x] Gerado `superfighters-web/src/data/generated/spriteDatabase.json` com todos os 9 lutadores e todas as 55 labels
- [x] Teste de integração Vitest (`SpriteDatabase.test.ts`) validando os 9 lutadores e as 55 labels do Billy
- [ ] Rodar o SWF original no **Ruffle** (desktop/web) como referência visual lado a lado → Verify: Storage abre no Ruffle

### Fase 2 — PlayerState + física do lutador
- [x] **Investigar antes de codar:** comprovado que o jogador usa controlador cinemático desacoplado (`Player.as:4973` com `airVelocityX/Y`, gravidade própria `0.6` e colisão de solo/paredes), não um b2Body puro empurrado pelo Box2D.
- [x] Port de `PlayerState.as` (constantes exatas e estados, `PlayerState.ts` com testes em `PlayerState.test.ts` 100% verdes).
- [x] `Input.ts` desacoplado espelhando `InputKeyboard.as` com suporte a teclado (WASD, Setas, Shift, Crouch, Dive).
- [x] Movimentação: caminhar, correr (sprint com dreno de energia), pular (+jump push com impulso até 4 ticks), gravidade e pouso.
- [x] Rolamento (`rollTimer 8`, `RollSpeed 2.0`), mergulho corporal (`posY -= 6`, `airVelocityY = -3`, `airVelocityX = 3.5`), agachamento e colisão com plataformas CLOUD e paredes.
- [x] Colisão dinâmica: mergulho e corrida aplicam impulso linear `applyLinearImpulse` em caixas e barris do cenário via Planck.js.

### Fase 3 — PlayerAnimation 1:1
- [x] Port literal de `UpdateAnimation()` (ordem de prioridade canônica dos estados, `PlayerAnimation.as:84-267`) → Testado em `PlayerAnimation.test.ts`.
- [x] `ShowAnimation()` com tabela de loop (`IDLE/RUN/SPRINT/CLIMB/STAGGER/GRABBED`), `DIVE` (rot 1.5), `FALL_B/F` (rot ∓10, inc ∓2, cap 36) → Testado em `PlayerAnimation.test.ts`.
- [x] `ProgressAnimation(dt)` com `_current_frame` fracionário a 30Hz, `AnimationDone()` resetando flags e estados de ROLL/KNEEL/etc.
- [x] `CharacterSkin.ts`: Container raiz + sub-container `ANIM` posicionado e transformado pelas matrizes canônicas extraídas de `spriteDatabase.json`; espelho horizontal instantâneo `scale.x = lastDirX` e posicionamento dinâmico `(frameOffset.x, frameOffset.y)` com `anchor (0, 0)` eliminando jitter/recortes imperfeitos.
- [x] Correção de rampas e escadas de `Maps.as:2362-2366` (`stair01` e `stair02`) em `StorageMap.ts`, garantindo que o jogador não caia pelo chão na transição da escada.
- [x] Piscar de imunidade com alpha 0.2 e timers 3/1 de `PlayerAnimation.as:91-126`.
- [x] 21 testes unitários em Vitest 100% passando (`npm run test`), incluindo varredura contínua de colisão de solo em `StorageMap.test.ts`.
- [x] Verificado visualmente no browser via `browser_subagent`: Billy renderizado no mapa Storage em IDLE ciclando 61 frames perfeitamente, caminhando sobre a rampa sem cair, pulando e retornando à esquerda. Zero erros de console.

### Fase 4 — Câmera seguindo jogadores
- [ ] Port de `GetCamArea` (bounds dos jogadores + `sizeIncrease 40`) ligado ao `Camera.ts` → Verify: câmera enquadra 2 jogadores sem sair de `mapArea`
- [ ] Debug manual só com tecla de toggle → Verify: modo AUTO por padrão

### Fase 5 — Combate corpo a corpo e dano
- [ ] Soco/combo (`MeleeAnimation_0N`), chute, jump kick (`JumpKickDamage 4`), stun, knockdown, stagger → Verify: Billy derruba Boris parado
- [ ] Hitareas a partir de `DefineSprite_409_player_hitarea` → Verify: hitbox debug alinhada à animação
- [ ] HP/morte (`DEATH_KNEEL` → queda) → Verify: round termina

### Fase 6 — Armas e projéteis
- [ ] `WeaponRegistry` gerado de `Weapons.as`/`Data/Weapons` (dano, cadência, munição, `FireSequence`, `AnimType`) → Verify: testes de tabela
- [ ] Mira (`aim_<AnimType>`, `ANIM_WPN.rotation = CurrentAimPitch`), spawn de armas (`WeaponSpawn.as`) → Verify: pegar pistola e mirar
- [ ] `ProjectilesUpdater` (raycast, penetração em madeira, ricochete, deflexão melee) → Verify: tiro quebra caixa

### Fase 7 — Destruição, explosões, fogo
- [ ] `Deconstructer.as` (debris), `Explosions.as` (raio, impulso radial, cadeia de barris), `Fires.as` (`BurnState`) → Verify: barril explosivo detona vizinho

### Fase 8 — HUD e áudio
- [ ] `PlayerBars.as` (HP com `_healthBarSpeed 4`, energia, arma) → Verify: barras idênticas ao Ruffle
- [ ] `Sounds.as` com os 74 sons (Web Audio; pan pela câmera) → Verify: tiro/soco audíveis

### Fase 9 — IA
- [ ] `PathGrid.as` + `BotState.as` (ticks 200/300/4000 ms, `BotDodgeBullet`, dificuldades) → Verify: Boris luta sozinho contra Billy

### Fase 10 — Conteúdo completo
- [ ] Demais mapas de `Maps.as`, `Portals.as`, `Slowmo.as`, `Scoreboard*`, `MenuMain.as` → Verify: partida completa menu→round→placar

### Fase X — Verificação final
- [ ] `npm run build` sem erros · `npx vitest run` verde · `tsc --noEmit` limpo
- [ ] Comparação lado a lado com Ruffle por mapa (screenshot + gravação)
- [ ] 60 FPS de render estável (Performance panel) com 4 jogadores

---

## 5. Estratégia de Testes
- **Unit (Vitest):** ports puros — `PlayerState`, seleção de label, `ProgressAnimation`, tabelas de armas, `GetCamArea`.
- **Integração:** mundo planck headless — caixa cai X px em N ticks; jogador pula altura esperada.
- **Referência visual:** Ruffle rodando o SWF original; mesmo input, comparar screenshots.

## 6. Riscos

| Risco | Impacto | Mitigação |
|-------|---------|-----------|
| Sub-sprites `ANIM` difíceis de exportar | Bloqueia Fase 3 | Fase 1 primeiro; fallback: renderizar SWF→PNG por frame no Ruffle |
| Box2DFlash 2.0 ≠ planck (v2.x) | Física levemente diferente | Testes de integração calibrados contra Ruffle |
| `Player.as` (325 KB) muito grande | Port lento/erros | Portar por subsistema, citar linhas, teste por subsistema |
| Escopo enorme | Abandono | Fases jogáveis incrementais; Fase 3 já entrega "Billy jogável" |

## 7. Dúvidas abertas (resolver investigando o AS3)
- [ ] Corpo do jogador: dinâmico Box2D ou controlador cinemático próprio? (`Player.as`)
- [ ] Valor de `m_iterations` (`GameMain.as`)
- [ ] Cam.as: atualiza a 30 Hz junto da lógica? (assumir sim até provar)
- [ ] Mapeamento exato de teclas P1/P2 (`InputKeyboard.as`, `Options.as`)

## Concluído quando
Partida Billy vs Boris (bot) no Storage é indistinguível do Flash no Ruffle em movimento, animação, câmera, combate, armas, HUD e som.
