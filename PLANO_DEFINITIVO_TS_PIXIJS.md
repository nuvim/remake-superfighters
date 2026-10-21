> ⚠️ **HISTÓRICO — substituído por [`superfighters-remake-plan.md`](superfighters-remake-plan.md) em 2026-10-21.**

# SUPERFIGHTERS REMAKE — PLANO ARQUITETURAL TYPESCRIPT + PIXIJS (1:1 COM ACTIONSCIPT 3)

> **Decisão Aprovada pelo Usuário:** Migração para **TypeScript + PixiJS + planck.js (Box2D)** devido à equivalência direta de 100% com a árvore de exibição (`DisplayList`) do Flash Player e a facilidade de transcrever linha por linha as classes ActionScript 3 descompiladas.
> **Ambiente Local:** Node.js v24.13.0, npm 11.6.2, Vite, PixiJS v8, planck.js v1.x (Box2D puro em JS/TS).

---

## 1. Por Que PixiJS É a Escolha Perfeita para Portar Flash (AS3)

No Flash original (`GameMain.as`, `PlayerAnimation.as`, `Cam.as`):
1. **Hierarquia de Containers (`DisplayList`)**:
   - Flash: `new MovieClip()`, `addChild()`, `removeChild()`, `scaleX`, `scaleY`, `x`, `y`, `rotation`.
   - PixiJS: `new Container()`, `addChild()`, `removeChild()`, `scale.x`, `scale.y`, `position.x`, `position.y`, `rotation`.
   *Correspondência direta, sem necessidade de converter coordenadas manualmente para Raylib ou desenhar loops procedurais.*

2. **Animação por Frames de MovieClip**:
   - Flash: Personagem Billy possui 56 frames (`1.png` a `56.png`) e executa `this.ANIM.gotoAndStop(frameNumber)`.
   - PixiJS: `AnimatedSprite` com o array das 56 texturas (`[Assets.get('billy_1'), ...]`).
   *Executa exatamente `anim.gotoAndStop(frameNumber - 1)`. Sem risco de desenhar spritesheets espalhados ou duplicados na tela.*

3. **Câmera (`Cam.as`)**:
   - Flash: O container `_dynamic_mc` sofre translação e escala contínua com base no enquadramento dos jogadores:
     ```as3
     _posSpeed.x = (_posTarget.x - _dynamic_mc.x) / zoomStepsLeft;
     _scaleSpeed = (_scaleTarget - _dynamic_mc.scaleX) / zoomStepsLeft;
     ```
   - PixiJS: A mesma matemática é aplicada diretamente no `dynamicContainer.position` e `dynamicContainer.scale`.

4. **Física Box2D (planck.js)**:
   - Planck.js é a reimplementação canônica em TypeScript/JavaScript do Box2D (a mesmíssima engine de `Box2DFlashAS3`).
   - Mesmas constantes: `PTM_RATIO = 30.0` (30 pixels = 1 metro), `b2World`, `b2Body`, `b2Vec2`, `b2PolygonShape`.

5. **Inspeção Visual Imediata**:
   - Roda via Vite na porta local em milissegundos.
   - Hot-reload instantâneo: qualquer alteração de física ou sprite reflete na tela sem precisar recompilar binários.

---

## 2. Mapeamento Direto das Classes AS3 para TypeScript

| Arquivo Original em `decompiled/scripts/scripts/Code/` | Arquivo TypeScript no Projeto (`src/`) | Função |
| :--- | :--- | :--- |
| `Handler/GameMain.as` | `src/engine/GameMain.ts` | Loop principal (60 FPS), árvore de containers, transição de rounds. |
| `Handler/Cam.as` | `src/engine/Camera.ts` | Enquadramento dinâmico dos lutadores, zoom suave e screen shake. |
| `Handler/Maps.as` | `src/stage/Maps.ts` | Criação das geometrias estáticas dos 8 mapas (Storage, Rooftops, etc.). |
| `Handler/MapPremadeItems.as` | `src/stage/MapPremadeItems.ts` | Instanciação de caixas (`CRATE`), barris explosivos e móveis. |
| `Data/Players/Player.as` | `src/player/Player.ts` | Física do lutador, salto, mergulho (`Dive`), rolamento (`Roll`), agachamento, golpe. |
| `Data/Players/PlayerAnimation.as` | `src/player/PlayerAnimation.ts` | Mapeamento de estado para os frames 1..56 de Billy, Boris, Johnny, etc. |
| `Data/Players/PlayerState.as` | `src/player/PlayerState.ts` | Variáveis de vida (100), estamina (100), tempos de recarga e flags físicas. |
| `Handler/Weapons.as` & `Data/Weapons/` | `src/weapons/WeaponSystem.ts` | Definições das 18 armas (dano, recuo, cadência, munição, mira laser). |
| `Handler/ProjectilesUpdater.as` | `src/weapons/ProjectilesUpdater.ts` | Balística de projéteis, penetração em madeira, ricochete e deflexão com espada. |
| `Handler/Explosions.as` | `src/destruction/Explosions.ts` | Ondas de choque radiais, dano em área e reação em cadeia com barris. |
| `Handler/Sounds.as` | `src/audio/SoundManager.ts` | Gerenciador de áudio (Howler.js ou Web Audio) com os 74 sons do jogo. |
| `Handler/PathGrid.as` & `Data/Players/BotState.as` | `src/ai/BotController.ts` | IA autônoma dos bots (desvio de projéteis, perseguição e saltos). |

---

## 3. Estrutura do Novo Projeto (`superfighters-web`)

```
superfighters-web/
├── public/
│   └── assets/                     # Link simbólico ou cópia de decompiled/assets/
│       ├── images/                 # Texturas de mapas (2240.png, 1022.png, etc.)
│       ├── sprites/                # Pastas com os frames PNG (DefineSprite_XXXX)
│       └── sounds/                 # Todos os efeitos sonoros MP3
├── src/
│   ├── main.ts                     # Ponto de entrada (Inicializa PixiJS Application)
│   ├── engine/
│   │   ├── GameMain.ts             # DisplayList e Game Loop
│   │   ├── Camera.ts               # Port exato de Cam.as
│   │   ├── LayerConstants.ts       # Nomes e ordenação Z-Order das camadas
│   │   └── PhysicsWorld.ts         # Wrapper de planck.js (escala 30 px/metro)
│   ├── stage/
│   │   ├── MapData.ts              # Definições de retângulos e spawns
│   │   ├── Maps.ts                 # Port de GenerateMapStorage(), etc.
│   │   └── DestructibleItem.ts     # Caixas e barris com física e HP
│   ├── player/
│   │   ├── Player.ts               # Port de Player.as
│   │   ├── PlayerState.ts          # Port de PlayerState.as
│   │   └── PlayerAnimation.ts      # Port de PlayerAnimation.as
│   ├── weapons/
│   │   ├── WeaponRegistry.ts       # Tabela de dados de armas
│   │   ├── Projectile.ts           # Instâncias de balas e foguetes
│   │   └── ProjectileSystem.ts     # Atualização e impacto de projéteis
│   ├── destruction/
│   │   └── ExplosionSystem.ts      # Explosões e impulsos
│   ├── audio/
│   │   └── SoundManager.ts         # Reprodução de sons com Howler.js
│   └── ui/
│       └── Hud.ts                  # Barra de HP, estamina e munição
├── index.html                      # Canvas container com estilo retrô
├── package.json                    # Dependências: pixi.js, planck, howler, vite
└── tsconfig.json
```

---

## 4. Plano de Execução Passo a Passo

1. **Passo 1 — Scaffold do Projeto Vite + PixiJS + Planck**:
   - Criar `superfighters-web` com Vite e TypeScript.
   - Instalar dependências essenciais: `pixi.js`, `planck`, `howler`.
   - Montar link/acesso direto aos assets em `decompiled/assets`.

2. **Passo 2 — DisplayList e Câmera (`Cam.as`)**:
   - Criar as camadas ordenadas (`levelContainer`, `objectsContainer`, `playersContainer`, `weaponsContainer`, `projectilesContainer`, `guiContainer`).
   - Portar `Camera.ts` com o enquadramento de `Cam.as` e carregar a arte autêntica de Storage (`2240.png` / `1022.png`).
   - Validar que o cenário aparece enquadrado e nítido.

3. **Passo 3 — Física Box2D e Caixas (`Maps.as`)**:
   - Portar os retângulos de colisão de Storage no Planck.js.
   - Instanciar caixas de madeira (`DefineSprite_50_crate_01`) e barris vermelhos explosivos (`DefineSprite_47_barrel_01`) com suas massas e tamanhos originais.

4. **Passo 4 — Player Controller & Animações 1:1 (`PlayerAnimation.as`)**:
   - Carregar as 56 texturas de Billy (`DefineSprite_1372_player_billy`) e Boris (`DefineSprite_799_player_boris`).
   - Configurar o `AnimatedSprite` com o pivô correto `(24, 28)`.
   - Implementar os comandos (A/D mover, W pular, Shift+W mergulho, S rolamento, K atirar, J soco).
   - Espelhamento horizontal instantâneo (`scale.x = -1`).

5. **Passo 5 — Armas e Projéteis (`Weapons.as`)**:
   - Anexar sprite da arma na mão do jogador (`ANIM_WPN`) com rotação de mira (`AimPitch`).
   - Disparos de projéteis com rastro visível, ricochete e foguete da bazooka.
   - Explosões com detonação de barris.

6. **Passo 6 — HUD, Áudio e Bot AI**:
   - HUD retrô com barras de vida proporcional e ícones de armas.
   - Áudio integral com tiros, socos e o grito Wilhelm.
   - Bot Boris controlado por IA para duelo no Storage.
