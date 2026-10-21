> ⚠️ **HISTÓRICO — substituído por [`superfighters-remake-plan.md`](superfighters-remake-plan.md) em 2026-10-21.**

# SUPERFIGHTERS REMAKE — PLANO DEFINITIVO DE ENGENHARIA REVERSA & ARQUITETURA 1:1

> **Objetivo:** Portar o jogo original *Superfighters* (Flash/AS3) para uma versão nativa e fiel, eliminando qualquer tipo de invenção, código ad-hoc ou aproximações visuais, utilizando rigorosamente os dados lógicos e visuais do diretório `decompiled/`.
> **Data:** Outubro de 2026  
> **Status:** Proposta de Planejamento Detalhado (Aguardando Aprovação)

---

## 1. Diagnóstico do Problema & Por Que a Tentativa Anterior Falhou

A captura de tela recente evidenciou claramente os defeitos da implementação anterior:
1. **Ausência do Sistema de Câmera (`Cam.as`)**: O jogo original não desenha as entidades diretamente em coordenadas estáticas da janela. Ele possui uma câmera dinâmica que calcula a área ocupada pelos lutadores (`GetCamArea`), suaviza a interpolação (`_posSpeed`, `_scaleSpeed`) e aplica transformação de matriz no container visual `_dynamic_mc`. Sem isso, o mundo fica deformado ou desenhado fora da visualização.
2. **Cascata de Frames (Sprite Atlas Mal Renderizado)**: Em vez de renderizar apenas o **frame único correspondente ao estado atual** do lutador com seu ponto pivô correto, o código renderizou múltiplos frames simultaneamente como se fossem uma grade no topo da tela.
3. **Falta de uma Hierarquia de Camadas (`DisplayList`)**: No Flash, os elementos são dispostos em camadas estritas:
   - `LEVEL` (Cenário de fundo)
   - `EFFECTSBEHIND` (Fogo/Fumaça de fundo)
   - `OBJECTS` (Caixotes e barris)
   - `SCRAP` (Estilhaços de madeira e destroços)
   - `PLAYERS` (Lutadores)
   - `WEAPONS` (Armas no chão)
   - `PROJECTILES` (Balas e foguetes)
   - `LEVEL_FRONT` (Pilares e grades frontais de cobertura)
   - `GUI` (Barras de vida e pontuação)
4. **Caminhos de Arquivos e Escala do Mapa**: A imagem de fundo precisa estar posicionada no retângulo do mapa definido em `Maps.as` (ex: `mapArea = Rectangle(23, -26, 477, 365)` para Storage), e não esticada arbitrariamente sem considerar a proporção de 30 pixels por metro do Box2D.

---

## 2. Análise Estrutural do Jogo Descompilado (`decompiled/`)

Toda a lógica e os dados do jogo original estão preservados no diretório `decompiled/`. Não há necessidade de adivinhar nenhuma regra:

| Componente Original Flash | Arquivo AS3 Fonte | Responsabilidade no Jogo Original |
| :--- | :--- | :--- |
| **Ciclo Principal** | `Code/Handler/GameMain.as` | Gerencia o loop de 30/60 Hz, inicialização de camadas e condições de vitória. |
| **Câmera Dinâmica** | `Code/Handler/Cam.as` | Enquadramento suave, cálculo de zoom dinâmico baseado na distância dos lutadores, limites de tela (`mapArea`) e efeito de screen shake. |
| **Geometria dos Mapas** | `Code/Handler/Maps.as` | Coordenadas exatas dos corpos Box2D (`CreateGroundBox`), plataformas permeáveis (`CLOUD`), escadas (`LADDER`), portais e pontos de spawn. |
| **Objetos e Móveis** | `Code/Handler/MapPremadeItems.as` | Criação de caixas (`CRATE`), barris comuns (`BARREL`), barris explosivos (`BARREL_EXPLOSIVE`), mesas, cadeiras e computadores. |
| **Física do Lutador** | `Code/Data/Players/Player.as` | Controles de movimento, gravidade (0.6), velocidade de corrida (1.7), mergulho (`Dive`, velocidade 3.5), rolamento (`Roll`, velocidade 2.0), pulo (-5.0) e impulso. |
| **Máquina de Animação** | `Code/Data/Players/PlayerAnimation.as` | Mapeia os estados do lutador para os frames exatos (1 a 56) da MovieClip de cada personagem, com rotação de membros e arma anexada (`ANIM_WPN`). |
| **Estados do Lutador** | `Code/Data/Players/PlayerState.as` | Todas as variáveis físicas, vida (100), estamina/energia (100), tempo de queimação (`BurnState`), tempos de imunidade e recarga. |
| **Armamento & Balística** | `Code/Handler/Weapons.as` & `ProjectilesUpdater.as` | Balística de projéteis (velocidade, dano, ricochete, penetração de madeira), recuo, munição e deflexão de tiros com armas brancas. |
| **Explosões & Fogo** | `Code/Handler/Explosions.as` & `Fires.as` | Raio de dano, onda de choque vetorial em caixas e lutadores, propagação de chamas por contato. |
| **IA & Pathfinding** | `Code/Handler/PathGrid.as` & `BotState.as` | Grid de nós para bots encontrarem rotas, desviarem de tiros (`BotDodgeBullet`) e pegarem armas. |

---

## 3. Decisão de Tecnologia: Por Que Continuar com C#?

O usuário perguntou se o problema é a linguagem. A resposta técnica é: **não, C# é ideal para essa tarefa**.
- **Compatibilidade 1:1 com AS3**: O ActionScript 3 é uma linguagem orientada a objetos com tipagem estática e sintaxe baseada em ECMAScript 4, que se traduz diretamente para classes, interfaces e records de C#.
- **Física Box2D**: O jogo original usa `Box2DFlashAS3`. A biblioteca **Box2DSharp** em C# é uma transcrição direta do Box2D em C++, garantindo equivalência exata de vetores, colisões e forças.
- **Renderização e Áudio**: **Raylib-cs** oferece carregamento direto de texturas PNG, reprodução de MP3 e desenho com aceleração de hardware sem complexidades de shaders desnecessárias.
- **Portabilidade**: Compila para executável binário independente (.exe) de alta performance.

---

## 4. Arquitetura da Solução em C#

Para evitar o erro de concentrar tudo em um único arquivo caótico, a arquitetura será dividida em módulos que espelham o jogo original:

```
superfighters-csharp/
├── src/
│   ├── Superfighters.Core/                 # Lógica de Jogo Pura (Sem dependência de Raylib)
│   │   ├── Physics/
│   │   │   ├── Box2DWorld.cs               # Instância b2World (30 px/m, timeStep = 1/60s)
│   │   │   └── CollisionFilters.cs         # Categorias de colisão (Player, Ground, Cloud, Projectile)
│   │   ├── Stage/
│   │   │   ├── MapDefinition.cs            # Dados do mapa (limites, retângulos, spawns)
│   │   │   ├── MapLoader.cs                # Port direto de GenerateMapStorage(), etc.
│   │   │   └── DestructibleItem.cs         # Caixas, barris e objetos com HP e impulso
│   │   ├── Players/
│   │   │   ├── Player.cs                   # Transcrição direta de Player.as
│   │   │   ├── PlayerState.cs              # Variáveis e constantes de PlayerState.as
│   │   │   ├── PlayerAnimationState.cs     # Seleção de frame (1..56) espelhando PlayerAnimation.as
│   │   │   └── BotController.cs            # Lógica de decisão de BotState.as
│   │   ├── Weapons/
│   │   │   ├── WeaponRegistry.cs           # Propriedades de todas as armas de Weapons.as
│   │   │   ├── ProjectileSystem.cs         # Atualização e colisão de balas e foguetes
│   │   │   └── ExplosionSystem.cs          # Explosões e impulsos radiais
│   │
│   └── Superfighters.Client/               # Renderização, Entrada e Áudio (Raylib-cs)
│       ├── Assets/
│       │   ├── AssetResolver.cs            # Localização de decompiled/assets
│       │   ├── TextureRegistry.cs          # Carregador de PNGs (sprites de personagens, armas, itens)
│       │   └── SoundRegistry.cs            # Carregador de MP3s com canais de áudio
│       ├── Camera/
│       │   └── GameCamera.cs               # Port exato de Cam.as (zoom suave e enquadramento)
│       ├── Rendering/
│       │   ├── SceneRenderer.cs            # Renderizador em camadas ordenadas (Z-order original)
│       │   ├── CharacterRenderer.cs        # Desenho do lutador: frame correto, espelhamento, arma na mão
│       │   └── HudRenderer.cs              # Barras de HP/estamina e armas no estilo original
│       └── Program.cs                      # Loop principal limpo (Update -> StepPhysics -> Render)
```

---

## 5. Roteiro de Execução em Fases

### Fase 1: Fundação do Renderizador e Câmera (`Cam.as`)
- Implementar o `AssetResolver` que carrega sem falhas os arquivos de `decompiled/assets/`.
- Implementar o `GameCamera` portando a matemática de `Cam.as` (zoom dinâmico, área de enquadramento dos jogadores e `mapArea`).
- Implementar o `SceneRenderer` com as camadas z-order originais.
- **Critério de Aceite da Fase 1:** O fundo do mapa (Storage `2240.png` ou `1022.png`) é renderizado enquadrado e centralizado pela câmera, sem distorção e sem barras pretas soltas.

### Fase 2: Geometria do Mapa & Caixas Físicas (`Maps.as`)
- Portar fielmente `GenerateMapStorage()` de `Maps.as`:
  - Retângulos de chão estático.
  - Plataformas permeáveis (`CLOUD` — o jogador pula por baixo e pousa por cima).
  - Escadas e portais.
- Spawnar caixas de madeira (`DefineSprite_50_crate_01`) e barris explosivos (`DefineSprite_47_barrel_01`) nas posições exatas do AS3.
- **Critério de Aceite da Fase 2:** As caixas caem sob gravidade, apoiam-se no chão do cenário, e empilham-se perfeitamente alinhadas com as plataformas do desenho original.

### Fase 3: Controlador do Jogador & Animações 1:1 (`Player.as` & `PlayerAnimation.as`)
- Configurar o corpo físico do lutador no Box2D (cápsula/caixa 16x32, atrito e trava de rotação).
- Implementar a máquina de estados de animação:
  - Carregar a pasta de frames do personagem (ex: `DefineSprite_1372_player_billy/` com frames `1.png` a `56.png`).
  - Desenhar **um único frame por vez**, centralizado no pivô físico do corpo, espelhando horizontalmente quando virado para a esquerda.
  - Portar os controles: Andar, Pular, Mergulho (`Shift+W`), Rolamento (`S`), Agachamento e Golpes corpo a corpo.
- **Critério de Aceite da Fase 3:** O jogador anda, pula, mergulha e rola pela fase Storage com a animação idêntica à do Flash original, sem nenhum frame duplicado na tela.

### Fase 4: Armas, Projéteis e Balística (`Weapons.as` & `ProjectilesUpdater.as`)
- Carregar os sprites das armas (`DefineSprite_140_wpn_pistol/1.png`, etc.) e renderizá-los acoplados ao ponto pivô da mão do personagem com rotação de mira (`AimPitch`).
- Implementar disparo com cadência, recuo, feixe de mira laser (Sniper e Magnum).
- Implementar projéteis reais: balas atingem alvos, criam lascas de madeira, e foguetes da bazooka explodem ao contato.
- Implementar deflexão de tiros com katana/espada/machado ao desferir golpes no timing correto.
- **Critério de Aceite da Fase 4:** Atirar com a pistola, rifle, espingarda e bazooka produz sons originais, consome munição, gera impacto físico e detona barris.

### Fase 5: Efeitos Visuais, HUD e Áudio (`Effects.as`, `Sounds.as`, `gui_holder`)
- Renderização de estilhaços (`CRATE_DEBRIS`), sangue e estojos de bala vazios (`EMPTY_SHELL`).
- Implementar o HUD original com barras de vida proporcionais, estamina e ícone da arma equipada.
- Sons espaciais estéreo com base na posição da câmera.
- **Critério de Aceite da Fase 5:** Partida jogável com vitória/derrota, HUD completo e sem nenhum elemento visual improvisado.

### Fase 6: IA dos Bots (`BotState.as`)
- Integrar os nós de navegação (`PathGrid.as`) para o bot saltar entre plataformas, recolher armas no chão e perseguir o jogador humano.
- **Critério de Aceite da Fase 6:** Bot Boris batalha autonomamente contra Billy no mapa Storage.
