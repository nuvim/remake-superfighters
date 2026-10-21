# Superfighters Remake — Contexto, Arquitetura e Dificuldades Técnicas

> **Documento destinado à análise técnica, revisão arquitetural e planejamento estratégico.**
> Repositório oficial: [https://github.com/nuvim/remake-superfighters.git](https://github.com/nuvim/remake-superfighters.git)

---

## 1. Visão Geral e Objetivo Supremo

O objetivo deste projeto é recriar com **fidelidade matemática e comportamental 1:1** o clássico jogo em Flash **Superfighters (2011)**, desenvolvido originalmente pela *MythoLogic Interactive* (Johan Hjärpe e Alexander Lemetti).

A versão remake está sendo construída na web utilizando:
- **Linguagem:** TypeScript
- **Renderizador Gráfico:** PixiJS v8
- **Motor de Física 2D:** Planck.js (Box2D portado para JS)
- **Áudio:** Howler.js
- **Pipeline de Testes:** Vitest + Scripts de Teste em Python
- **Bundler:** Vite

### A "Fonte da Verdade" (Ground Truth)
Não estamos criando um jogo "inspirado" nem trabalhando com suposições. O arquivo original compilado em SWF foi descompilado via **JPEXS FFDec** e está 100% preservado no diretório:
```
decompiled/scripts/scripts/Code/
├── Data/         # Player.as, PlayerState.as, Projectiles.as, etc.
└── Handler/      # GameMain.as, Maps.as, MapPremadeItems.as, SoundHandler.as, etc.
```
Todas as constantes numéricas, fórmulas de colisão, tabelas de animação e geometrias dos mapas devem corresponder com rigor cirúrgico ao código ActionScript 3 (AS3) original.

---

## 2. O que já foi alcançado até agora

1. **Pipeline de Extração Completo (Fase 1):**
   - O arquivo SWF foi convertido para XML (`tools/extract/swf.xml`, 25.4 MB).
   - O script `tools/build-sprite-db.mjs` extraiu todos os 845 sprites e MovieClips do jogo, capturando as matrizes canônicas de transformação (escala, rotação, translação em twips/pixels) e mapeou 100% das 55 labels de animação dos 10 personagens para `superfighters-web/src/data/generated/spriteDatabase.json`.
2. **Loop de Jogo a 30 Hz Fixo (Fase 0):**
   - `GameLoop.ts` desacopla a taxa de renderização do monitor da taxa de atualização lógica, executando a física e a lógica estritamente a **30 Hz fixo** (`m_timeStep = 1/30` e `m_iterations = 20`, conforme `GameMain.as:152,847`).
3. **Controlador Cinemático do Jogador e Estado (Fase 2):**
   - `PlayerState.ts` modela todas as constantes de movimento (`RUN_SPEED = 1.7`, `PLAYER_GRAVITY = 0.6`, `PLAYER_JUMP_POWER = -5.0`, `DIVE_SPEED = 3.5`, `ROLL_SPEED = 2.0`, `playerEdgeDistance = 6`, `playerHeight = 18`).
   - `Player.ts` implementa movimentação horizontal em micro-passos de 0.1 px, pulo variável sustentado por até 4 ticks, mergulho corporal (*dive*), rolamento com esquiva e agachamento.
4. **Mapa de Armazém (StorageMap):**
   - Port literal 1:1 de `GenerateMapStorage` (`Maps.as:2346-2435`) com o bitmap de fundo original (`28.png`, 522x328), todas as caixas de solo sólidas, plataformas semi-sólidas (*CLOUD*), escadas de subida (*LADDER*) e polígonos de escadas inclinadas (`stair02` e `stair01`).
   - Spawns canônicos de caixas de madeira (`CRATE`), barris metálicos (`BARREL`) e barris de combustível explosivos (`BARREL_EXPLOSIVE`).
5. **Máquina de Animações (Fase 3):**
   - `PlayerAnimation.ts` porta a prioridade estrita de labels de animação do Flash (`PlayerAnimation.as:84-267`), manipulação angular de rotação durante mergulho e queda, e timers de transição.
   - `CharacterSkin.ts` instancia e posiciona os sub-sprites extraídos, alinhando a arte do personagem à hitbox física nos pés.
6. **Suíte de Testes Automatizados:**
   - 23 testes unitários no Vitest passando verde (`tests/StorageMap.test.ts`, `tests/PlayerAnimation.test.ts`, `tests/PlayerState.test.ts`, `tests/GameLoop.test.ts`, `tests/SpriteDatabase.test.ts`).
   - Simuladores de física em Python em `tools/test_flash_physics_1to1.py`.

---

## 3. As Dificuldades Críticas que Estamos Enfrentando

Apesar de termos a base funcional rodando no navegador, o projeto **ainda não atingiu o nível de perfeição e polimento do jogo original**. Abaixo estão detalhadas as dificuldades técnicas mais profundas:

---

### Dificuldade 1: O Motor Híbrido do Flash vs Box2D Planck.js

No jogo original, **o personagem NÃO é um corpo rígido do Box2D**. 
- O Box2D no Superfighters é utilizado prioritariamente para objetos dinâmicos (caixas, barris caindo, mesas, portas, fragmentos e projéteis).
- O personagem é uma entidade cinemática personalizada que realiza centenas de checagens manuais por frame através do método `_static_world_hitbox_mc.hitTestPoint(x, y, true)`.
- **A armadilha:** No Flash, `_static_objects_hitbox_mc` (as caixas e barris dinâmicos) é filho direto de `_static_world_hitbox_mc` (`GameMain.as:237`). Isso significa que `hitTestPoint` no Flash testa indistintamente tanto o terreno sólido quanto os objetos dinâmicos através do teste de pixel/vetor da engine gráfica da Adobe.
- **O desafio no TypeScript:** No Planck.js, o mundo físico é matemático. Tentar unificar o teste de solo entre polígonos estáticos e caixas dinâmicas que sofrem rotação gera pequenas discrepâncias de sub-pixel:
  - Se a caixa dinamicamente inclinar 1 grau, a matemática de AABB ou OBB pode gerar pequenas folgas ou prender o personagem nas quinas.
  - O "snagging" (fricção fantasma em costuras entre blocos adjacentes) exige tolerâncias cuidadosas.

---

### Dificuldade 2: Escadas Inclinadas e Micro-stepping em Solos Irregulares

No Flash original (`Player.as:3916-3932` e `Player.as:4551-4627`):
- O personagem desloca-se em micro-passos de `0.1 px`:
  ```actionscript
  var _loc3_:int = Math.abs(speed * 10);
  var _loc4_:Number = dirX * 0.1;
  while(_loc5_ <= _loc3_) {
      if(this.WalkCollision(dirX)) return;
      this._this_x += _loc4_;
      if(this.OnGround) this.UpdateSimpleGroundMovement(false);
      _loc5_++;
  }
  ```
- Em `UpdateSimpleGroundMovement`:
  - Se os pés penetrarem o solo (`CollisionFeetMid(-1, 1)`), um loop eleva `this._this_y -= 0.1` até desobstruir.
  - Se os pés perderem contato com o chão por até 6 pixels (`CanLandInMid()`), outro loop abaixa `this._this_y += 0.1` até restabelecer contato.
- **O desafio:** No encontro de rampas inclinadas de 45° (`stair02` e `stair01`) com o piso reto:
  - No Flash, os vértices foram expandidos com `IncreaseCorners` em 0.5px.
  - Qualquer mínima imprecisão na emenda faz o personagem alternar entre `isGrounded = true` e `isGrounded = false`, causando stutters (engasgos visuais) ou travamento na subida se o teste de parede na cintura (`WalkCollision`) encostar no degrau.

---

### Dificuldade 3: Alinhamento de Animação com MovieClips Aninhados

No Flash:
- Os personagens são MovieClips com uma hierarquia aninhada:
  `Player (Container)` -> `ANIM (MovieClip com labels)` -> `Sub-sprites (membros/frames)`.
- No Flash Player, cada frame possui uma matriz de transformação affine $2 \times 3$ com coordenadas em *twips* ($1\text{ twip} = 1/20\text{ px}$).
- No PixiJS v8:
  - Usamos texturas planas PNG renderizadas a partir dos bitmaps do SWF.
  - Quando o personagem troca de estado (ex: de `IDLE` para `RUN`, `CROUCH`, `DIVE` ou `FALL`), o ponto de pivô dos sub-sprites varia entre frames. Se a matriz canônica extraída do XML tiver 1 pixel de desvio, o lutador aparenta "afundar" ou "flutuar" em relação à hitbox do chão durante certos frames da animação.

---

### Dificuldade 4: O "Game Feel", Inércia e Empurrão de Caixas

O Superfighters tem uma jogabilidade reconhecida pela sensação de impacto e resposta imediata:
- **Empurrão de caixas:** Quando o jogador caminha contra uma caixa de madeira no chão, ela deve deslizar com atrito calculado. Se estiver correndo (*sprint*), ele deve ser capaz de empurrá-la com mais força. Se chutar ou mergulhar (*dive*), a caixa deve ser arremessada.
- **Subir em caixas:** Se uma caixa estiver empilhada, o lutador deve conseguir andar sobre ela como se fosse um piso sólido normal, sem oscilar verticalmente.
- **Pulos e Wall-jumps:** O pulo do Flash possui sustentação variável dependendo do tempo em que a tecla para cima permanece pressionada (até 4 ticks de impulso adicional).

---

### Dificuldade 5: Escala e Modularização do Código

Atualmente, grande parte da lógica cinemática está concentrada em [Player.ts](file:///h:/luizm/Documents/remake%20superfighters/superfighters-web/src/player/Player.ts). Conforme formos adicionando:
- Combate corpo a corpo (socos, chutes, agarrar, arremessar);
- Sistema de armas (pistolas, espingardas, metralhadoras, granadas, bazucas);
- Efeitos de dano, fogo, sangue e desmembramento (*gibs*);
- IA dos inimigos (bots);
- Outros mapas e itens de cenário;

Precisamos garantir que a arquitetura não vire um monólito frágil e seja de fácil manutenção e extensão.

---

## 4. O que Esperamos da Análise da IA

Caso você seja uma IA analisando este repositório para nos orientar, precisamos das suas respostas e propostas para as seguintes questões:

1. **Arquitetura de Colisão Solo/Rampa:**
   - Qual é a forma mais robusta e eficiente de manter a fidelidade 1:1 ao algoritmo de micro-stepping do Flash (`UpdateSimpleGroundMovement`), garantindo zero jitter e zero chance do personagem prender ou cair no limbo ao subir ou descer rampas?
2. **Integração Física de Corpos Dinâmicos:**
   - Como estruturar o relacionamento entre o controlador cinemático do jogador e os corpos dinâmicos do Planck.js (caixas e barris), permitindo ao mesmo tempo:
     - Bloqueio lateral natural ao colidir;
     - Apoio de solo ao caminhar por cima do objeto;
     - Aplicação de impulsos lineares proporcionais à velocidade do impacto?
3. **Pipeline de Animação e Alinhamento:**
   - Como garantir o alinhamento pixel-perfect das animações do Flash em PixiJS sem a necessidade de ajustes manuais em centenas de frames individuais?
4. **Próximos Passos Recomendados:**
   - Qual deve ser a ordem de prioridade para as próximas etapas (ex: Câmera com interpolação suave -> Combate Melee -> Sistema de Armas -> Áudio)?

---

## 5. Estrutura do Repositório

```
remake-superfighters/
├── .agents/                    # Memórias persistentes, regras e convenções do projeto
├── decompiled/                 # CÓDIGO FONTE ORIGINAL E ATIVOS DO FLASH
│   ├── assets/                 # Bitmaps, 74 sons WAV e centenas de pastas de sprites
│   └── scripts/scripts/Code/   # 442 arquivos .as (Data/, Handler/, etc.)
├── superfighters-web/          # APLICAÇÃO WEB PRINCIPAL (TypeScript + PixiJS + Planck.js)
│   ├── src/
│   │   ├── camera/             # Camera.ts (port de Cam.as)
│   │   ├── data/generated/     # spriteDatabase.json (metadados de animação)
│   │   ├── engine/             # GameLoop.ts (30 Hz fixo), DisplayLayers.ts
│   │   ├── input/              # Input.ts (gerenciamento de teclado)
│   │   ├── player/             # Player.ts, PlayerState.ts, PlayerAnimation.ts, CharacterSkin.ts
│   │   └── stage/              # StorageMap.ts, DestructibleItem.ts
│   └── tests/                  # Testes unitários com Vitest
├── tools/                      # SCRIPTS DE ENGENHARIA REVERSA E TESTES EM PYTHON
│   ├── build-sprite-db.mjs     # Parser do XML do SWF para JSON de animação
│   ├── test_flash_physics_1to1.py # Simulador da física do Flash em Python
│   └── inspect_*.py            # Scripts auxiliares de leitura de bytecode e fontes AS3
├── superfighters-remake-plan.md # Plano mestre de desenvolvimento fase a fase
└── CONTEXTO_E_DIFICULDADES.md  # Este documento
```

---

## 6. Como Rodar e Testar Localmente

```bash
# 1. Entrar na pasta do projeto web
cd superfighters-web

# 2. Instalar dependências
npm install

# 3. Rodar os testes automatizados
npm run test

# 4. Iniciar o servidor de desenvolvimento
npm run dev
# Acesse http://localhost:5173/ no navegador
```
