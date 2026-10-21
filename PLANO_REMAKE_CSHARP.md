> ⚠️ **HISTÓRICO — substituído por [`superfighters-remake-plan.md`](superfighters-remake-plan.md) em 2026-10-21.**

# Superfighters Remake: Relatório de Engenharia Reversa & Plano Arquitetural 1:1 em C#

> **Status:** Aprovado para Execução  
> **Target:** .NET 8 / C# + Raylib-cs + Box2DSharp  
> **Fonte Ground Truth:** 442 classes ActionScript 3 descompiladas do `superfighters.swf` (localizadas em `decompiled/scripts/scripts/Code/`)  
> **Regra Fundamental:** Zero invenção. Reprodução exata de valores, fórmulas, estados e sistemas do jogo original.

---

## 1. Diagnóstico de Engenharia Reversa (REA & Descompilação)

### 1.1 Invocação do REA MCP
Ao analisar o binário `superfighters.swf` e o bytecode bruto `superfighters.abc` via MCP `rea/open_binary`, o REA retornou explicitamente:
```json
{
  "error": "Cannot open artifact: unsupported binary format.",
  "details": {
    "path": "H:\\luizm\\Documents\\remake superfighters\\superfighters-flash-game\\superfighters.swf",
    "reason": "unsupported binary format",
    "constraint": "file_format_rejected"
  }
}
```
*Conclusão Técnica:* O REA é projetado para binários nativos de máquina (PE, ELF, Mach-O), executáveis gerenciados (.NET PE), APKs Android ou Web/JS (Electron/V8). Ele rejeita nativamente containers Flash SWF/AVM2.

### 1.2 Extração Completa via JPEXS FFDec
A descompilação de bytecode AVM2 (`DoABC`, tag 82) e mapeamento de símbolos (`SymbolClass`, tag 76) foi realizada com 100% de cobertura:
- **Código Fonte**: 442 classes ActionScript 3 em `decompiled/scripts/scripts/Code/`.
- **Texturas**: 242 arquivos PNG em `decompiled/assets/images/`.
- **Áudio**: 74 arquivos de áudio em `decompiled/assets/sounds/`.

---

## 2. Evidências do Código Original e Funcionamento das Features

### 2.1 A Arquitetura do Bot e IA Autônoma
No jogo original, **o Bot não é uma subclasse separada**. Dentro de `Code/Data/Players/Player.as` (linha 174), cada jogador possui uma instância de `BotState`:

```actionscript
// Code/Data/Players/BotState.as (linhas 9-32)
public static const EASY:int = 1;
public static const MEDIUM:int = 2;
public static const HARD:int = 3;

public static const IDLE:int = 0;
public static const AIM:int = 1;
public static const SHOOT:int = 2;
public static const CANCEL_AIM:int = 3;
public static const FOLLOW_PATH:int = 4;
public static const GRAB_WEAPON:int = 5;
public static const MELEE:int = 6;
public static const INTERRUPTED:int = -1;
```

#### Frequências de Decisão em `Player.as` (linhas 454-460)
- `BotChooseTarget_Tick` (**a cada 200ms**): Varre a lista de jogadores e escolhe o alvo de maior prioridade.
- `BotInSightCheck_Tick` (**a cada 300ms**): Dispara raycasts no Box2D para verificar linha de visão desobstruída.
- `BotRandomize` (**a cada 4000ms**): Ajusta o desvio estocástico (`RandomFireX`, `RandomFireY`) com base na dificuldade.
- `BotDodgeBullet()`: Se um projétil inimigo estiver vindo em sua direção, cancela a mira (`CANCEL_AIM`) e executa pulo, agachamento ou rolamento.
- Reação a fogo: Se `BurnState >= 60`, força `Roll()` chamando `_PlayerState.DecreaseBurnState()`.

### 2.2 Sistema Físico Box2D e Colisão de Mergulho (`Dive`)
Em `Code/Data/Players/PlayerState.as` e `Player.as`:
- **Escala de Conversão**: `PTM_RATIO = 30.0` (30 pixels = 1 metro).
- **Gravidade**: `PlayerGravity = 0.6`.
- **Mergulho (Dive)**: `DiveSpeed = 3.5`, `AirVelocityX += LastDirX * 3.5`, `AirVelocityY -= 3`, elevação inicial de 6 pixels (`_this_y -= 6`).
- **Colisão com Corpos Dinâmicos**: Ao colidir em mergulho com uma caixa ou jogador, executa:
  ```actionscript
  _loc13_ = new b2Vec2(this._PlayerState.LastDirX, 0);
  _loc14_ = new b2Vec2(this.MidPosX() + 6 * this._PlayerState.LastDirX, this.MidPosY());
  _loc14_.x /= 30; // Escala Box2D
  _loc14_.y /= 30;
  this.b.ApplyImpulse(_loc13_, _loc14_);
  this.b.GetUserData().objectData.Damage_Impact(2);
  ```
  Aplica impulso físico vetorial e 2 de dano de impacto (`Damage_Impact(2)`).

---

## 3. Arquitetura da Solução em C# (.NET 8)

A solução será dividida em 3 camadas desacopladas:

```
superfighters-csharp/
├── Superfighters.Data/             # Modelos e Serialização JSON (Mods / Editor)
│   ├── Weapons/                    # JSON com stats fiéis de Weapons.as
│   ├── Maps/                       # JSON dos 8 mapas originais (Tiles, Spawns, Juntas)
│   └── Characters/                 # Definição dos 8 personagens e skins
│
├── Superfighters.Core/             # Port 1:1 em C# puro (.NET 8)
│   ├── Physics/                    # Integração com Box2DSharp (30 px/m, juntas, motores)
│   ├── Players/                    # Player.cs, PlayerState.cs (1:1), BotState.cs, PathGrid.cs
│   ├── Weapons/                    # WeaponData.cs, Projectiles.cs, ProjectilesUpdater.cs
│   ├── Destruction/                # Deconstructer.cs, Explosions.cs, Fires.cs
│   └── Stage/                      # Maps.cs (Tutorial, Storage, Rooftops, etc.)
│
└── Superfighters.Client/           # Executável Raylib-cs
    ├── Rendering/                  # Render de texturas PNG extraídas do SWF
    ├── Audio/                      # Player com os 74 sons originais
    └── Program.cs                  # Loop fixo em 60 Hz
```

---

## 4. Fases de Execução

1. **Fase 1**: Instalação local do .NET 8 SDK (via `dotnet-install.ps1` sem requisição de privilégios de administrador) e criação da solution `Superfighters.sln`.
2. **Fase 2**: Criação dos 3 projetos (.csproj): `Superfighters.Core`, `Superfighters.Data` e `Superfighters.Client`.
3. **Fase 3**: Adição dos pacotes NuGet necessários: `Box2DSharp` (Física Box2D 1:1) e `Raylib-cs` (Render/Áudio).
4. **Fase 4**: Port 1:1 das classes de estado e física:
   - `PlayerState.cs` (constantes e flags de estado).
   - `Player.cs` (máquina de estados, movimento, dive, roll, jump, soco, chute).
   - `BotState.cs` e `PathGrid.cs` (IA original, raycast de linha de visão, esquiva e timers).
5. **Fase 5**: Port de armas, projéteis e destruição:
   - `Weapons.cs`, `WeaponData.cs`, `Projectiles.cs`, `ProjectilesUpdater.cs`.
   - `Explosions.cs`, `Fires.cs`, `Deconstructer.cs`.
6. **Fase 6**: Serialização JSON no `Superfighters.Data` para permitir modificações (mods) e futuros editores.
7. **Fase 7**: Camada de apresentação no `Superfighters.Client` com carregamento de texturas e sons originais.
8. **Fase 8**: Validação e testes de execução de combate e física.
