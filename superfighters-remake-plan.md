# Superfighters Remake — Plano Mestre de Paridade

> **Substitui todos os outros planos.** Mova `PLANO_DEFINITIVO_*.md`, `PLANO_REMAKE_CSHARP.md` e `superfighters-remake-plan.md` para `docs/archive/`. Este é o único plano ativo.
>
> **Objetivo:** o remake se comporta **igual** ao Flash, medido por números, não por impressão visual.

---

## 0. Leia isto primeiro (regras do agente)

Estas regras valem para qualquer IA que mexa neste repositório.

1. **Portar não é reescrever.** Cada função AS3 vira uma função TS com a **mesma estrutura, mesma ordem de `if`/`while`, mesmos nomes de variável (pode renomear `_loc3_` para algo legível, mas sem mudar a lógica)**. Não simplifique, não "melhore", não junte ramos.
2. **Proibido inventar número.** Toda constante vem do AS3 com referência `// Player.as:LINHA`. Se não achar a origem, escreva `// TODO(AS3): origem desconhecida` e **pare**; não chute.
3. **Proibido escrever "1:1" em comentário** sem um teste de paridade (seção 5) cobrindo aquela função. Use `// PARIDADE: verificada por <nome do teste>` ou `// PARIDADE: NÃO VERIFICADA`.
4. **Ramo que você não portou fica explícito:** `// TODO(AS3 Player.as:4596): ramo Staggering não portado`. Nunca omita em silêncio.
5. **Uma tarefa = uma função (ou até ~150 linhas de AS3).** Cole o trecho AS3 na conversa antes de escrever o TS.
6. **Teste verde não prova paridade.** Os testes atuais conferem o port contra ele mesmo. Só vale o teste que compara com o **golden** gerado pelo jogo original (Fase B).
7. **Uma fonte de verdade por dado.** Geometria do mapa vem de um JSON gerado a partir de `Maps.as`. Nada digitado à mão em dois lugares.
8. Leia só: este arquivo, `README.md`, `tools/README.md`. Ignore `.agents/skills/*` (nada ali serve a este projeto).

---

## 1. Diagnóstico: por que "nunca fica igual"

Li o `Player.ts`, `StorageMap.ts`, `DestructibleItem.ts`, `GameLoop.ts` e `main.ts` e comparei com `Player.as` e `Maps.as`/`MapPremadeItems.as`. A causa raiz **não** é falta de dados (você já extraiu tudo). É o **processo**: o agente recria a lógica "no espírito" do original, rotula como 1:1 e valida com testes que ele mesmo escreveu.

### Evidências verificadas

| # | Achado | Onde | Impacto |
|---|--------|------|---------|
| 1 | **`Player.update()` é invenção, não port.** Sprint `RUN_SPEED * 1.4`, controle aéreo `* 0.9`, arrasto `* 0.85` não existem no `Player.as`. O comentário diz "1:1". | `Player.ts:296-340` | Movimento e pulo nunca batem |
| 2 | **`UpdateAirMovement` (Player.as:4628 até ~5150, ~520 linhas) não foi portado.** O original conta os micro-passos por `Math.ceil(TotalAirVelocity)` com `TotalAirVelocity = sqrt(vx²+vy²)` e move X e Y juntos a cada passo. O TS usa só `|vy|` e move X e Y separados. Faltam escada/bounce (`StairBounce`, `tiltValue`), ladder, `PlayerOutsideLevel`, impacto em objetos. | `Player.ts:348-388` | Pouso, quinas, mergulho e escadas divergem |
| 3 | **`MovePlayer`:** o original usa `Math.abs(speed*10)` como `int` (trunca) e multiplica o passo por `_game_speed`. O TS usa `Math.round` e ignora `_game_speed`. | `Player.as:3916-3925` vs `Player.ts:160` | Deriva de subpixel a cada tick |
| 4 | **`UpdateSimpleGroundMovement` simplificado.** Falta `!WorldCollisionHead()` no laço de subida (4559). O ramo final original faz `Jumping = true` e passa por `UpdateAirMovement`; o TS força `falling=true` e `airVelocityY=0.1`. O ramo `CollisionFeetSides` não reexecuta a checagem (4594-4604). | `Player.as:4551-4626` vs `Player.ts:194-230` | Engasgos na rampa e transição errada chão→ar |
| 5 | **Duas fontes de verdade para as escadas, e uma está errada.** `hitTestWorld` usa `staticPolysPixel` (digitado em pixels); a física usa `groundPolys`. Recalculei `IncreaseCorners` (`MapPremadeItems.as:2807`): **stair02** vértice 2 deveria ser `x=132.5` (TS: 133.5); **stair01** vértice 2 deveria ser `x=328.5` (TS: 327.5); vértices de baixo `y=329.5` (TS: 335.5). | `StorageMap.ts:129-146` | **A hitbox da rampa difere do mapa real** (a sua queixa) |
| 6 | **`hitTestPoint(x, y, true)` do Flash foi aproximado à mão.** A forma original é `DrawBoxMC(w+0.5px)` com traço `lineStyle(0.5)`, então a área efetiva tende a ser ±0.5px do centro-borda; o TS usa ±0.25px. O CLOUD ganhou um `+1.0` inventado e não aplica o `+0.5/30`. | `StorageMap.ts:hitTestWorld/hitTestCloud` vs `MapPremadeItems.as:171-172, 2847-2857` | Hitbox 0.25–1 px diferente em toda borda |
| 7 | **Motor de física diferente e iterações contraditórias.** O original usa **Box2DFlash 2.0** com `Step(1/30, 20)` (`GameMain.as:152,850`). O projeto usa `planck` (outra geração do Box2D, solver e mistura de atrito diferentes) com **10/10** em `main.ts`, enquanto a documentação diz "20". | `main.ts:~113`, `GameMain.as:152` | Caixas e barris nunca terão o mesmo "peso" |
| 8 | **Código morto/duplicado de colisão.** `checkFeetCollision`, `checkWallCollision` e a rampa com `0.75` fixo estão no `StorageMap.ts` e não são usados. | `StorageMap.ts` | Confunde o agente |
| 9 | **Sem oráculo.** Nenhum teste compara com o comportamento real do SWF. Por isso "ficou verde" e continua errado. | `tests/` | Causa-mãe de tudo |
| 10 | **Ruído de contexto.** 5 planos conflitantes na raiz, pastas `superfighters-csharp/` e `superfighters-flash-game/` abandonadas, dezenas de skills sem relação em `.agents/` (database, SEO, i18n, vídeo...). | raiz | O agente se perde e "renegocia" o plano toda sessão |

**Boa notícia:** os números de `groundBoxes` conferem com `GenerateMapStorage` (`Maps.as:2321+`). A transcrição das caixas está certa; o erro está na camada de teste de colisão, no movimento e na falta de verificação.

---

## 2. Estratégia: três mudanças

### Mudança 1 — Criar um oráculo (a peça que falta)
Fazer o **próprio SWF** produzir os números. Sem isso, qualquer plano vira "parece igual".

- **Golden trace:** posição, velocidades e flags do jogador a cada tick, para cenários de entrada fixos.
- **Golden hitmap:** o resultado de `hitTestPoint` do jogo original para uma grade de pontos do mapa. Isso responde de forma objetiva "a hitbox está igual?".

### Mudança 2 — Tradução mecânica em vez de reescrita
Função por função, na ordem do AS3, com o protocolo da seção 4. O Flash API (`hitTestPoint`, `MovieClip`, `b2World`) fica atrás de interfaces pequenas; a lógica do jogo fica idêntica.

*Opção a avaliar (spike de 1 dia, não testei):* conversores AS3→Haxe/TS (`as3hx`) ou rodar o código via OpenFL. Se funcionar, a lógica passa a ser idêntica por construção. Se o resultado for ilegível, volte à tradução manual guiada.

### Mudança 3 — Dados gerados, não digitados
`tools/gen-map.mjs` lê `Maps.as` (`CreateGroundBox`, `CreateGroundPolygon`, `AddObject`) e escreve `src/data/generated/storage.json`. Física, hit test e debug leem **o mesmo JSON**.

---

## 3. Sprint 0 — correções que já sei que estão erradas (1 sessão)

Faça antes de qualquer coisa nova. Cada item tem um teste.

1. **Arquivar planos e limpar a raiz:** mover os 4 planos antigos para `docs/archive/`; mover `superfighters-csharp/` e `superfighters-flash-game/` para `archive/` (ou remover); desativar as `.agents/skills/*` que não são deste projeto (mover para `.agents-disabled/`, sem apagar, caso sua ferramenta dependa delas). Atualizar o `README.md` para apontar só para este plano.
2. **Iterações:** `main.ts` → `world.step(dt, 20, 20)` até a Fase E (e registrar que o solver ainda é diferente).
3. **`MovePlayer`:** `steps = Math.trunc(Math.abs(speed * 10))`; multiplicar o passo por `gameSpeed` (constante 1 por enquanto, com a origem comentada).
4. **`UpdateSimpleGroundMovement`:** portar linha a linha de `Player.as:4551-4626`, incluindo `WorldCollisionHead()` e o ramo `CollisionFeetSides` com a recheck. Onde faltar estado (`Staggering`, `CheckAimDrop`), deixar `TODO(AS3:linha)`.
5. **Unificar as escadas:** transformar `staticPolysPixel` em um getter derivado dos fixtures (vértices do corpo × 30), sem nenhuma lista digitada. Remover `checkFeetCollision`, `checkWallCollision` e a rampa `0.75`.
6. **Teste que falha hoje** (por minha conta, não executei: o `npm install` não alcançou o registro neste ambiente) e passa depois do item 5:

```ts
// tests/StairGeometry.test.ts
import { describe, it, expect } from 'vitest';
import * as planck from 'planck';
import { Container, Texture } from 'pixi.js';
import { StorageMap } from '../src/stage/StorageMap';

// IncreaseCorners (MapPremadeItems.as:2807)
const inc = (v: number) => (v < 0 ? v - 0.5 / 30 : v > 0 ? v + 0.5 / 30 : v);
const expected = (cx: number, cy: number, verts: [number, number][]) =>
  verts.map(([x, y]) => [cx + inc(x / 30) * 30, cy + inc(y / 30) * 30]);

const sortXY = (a: number[][]) => [...a].sort((p, q) => p[0] - q[0] || p[1] - q[1]);

describe('stairs: pixel polygons == AS3 IncreaseCorners', () => {
  const m = new StorageMap(new planck.World(), Texture.EMPTY, {}, new Container(), new Container());
  const stair02 = expected(143, 294, [[-16,-39],[-10,-39],[14,-21],[14,35],[-16,35]]);
  const stair01 = expected(320, 292, [[-16,-19],[8,-37],[14,-37],[14,37],[-16,37]]);

  it.each([[0, stair02], [1, stair01]])('poly %i', (i, exp) => {
    const got = sortXY(m.staticPolysPixel[i as number] as number[][]);
    const want = sortXY(exp as number[][]);
    got.forEach((p, k) => {
      expect(p[0]).toBeCloseTo(want[k][0], 3);
      expect(p[1]).toBeCloseTo(want[k][1], 3);
    });
  });
});
```

**Critério de saída do Sprint 0:** `tsc` limpo, testes verdes, raiz com 1 plano, o jogador anda pelas duas escadas sem perder o chão.

---

## 4. Roteiro por fases (cada fase tem critério numérico)

### Fase A — Higiene
Feita no Sprint 0. Adicionar CI (GitHub Actions: `npm ci && npm run build && npm test`).

### Fase B — Oráculo (a fase mais importante)
**Meta:** arquivos `golden/*.json` gerados pelo jogo original.

Caminho principal (verifique a sintaxe na sua versão do FFDec, por exemplo `ffdec-cli -help replace`; não confirmei que recompila o AS3 descompilado sem erro):

1. Com o FFDec, edite `Player.as` dentro do SWF e adicione **instrumentação de depuração** no fim do tick do jogador:

```actionscript
// DEBUG-ORACLE (remover depois). Sketch; ajuste os nomes ao seu Player.as
trace("T," + (Player.dbgTick++) + "," + this._this_x + "," + this._this_y + ","
  + this._PlayerState.AirVelocityX + "," + this._PlayerState.AirVelocityY + ","
  + this._PlayerState.OnGround + "," + this._PlayerState.Jumping + "," + this._PlayerState.Falling);
```

2. **Hitmap:** uma função dentro de `Player.as` (para rodar no mesmo contexto de coordenadas dos testes reais) que varre o mapa em passos de 0.5 px chamando **as mesmas funções do jogo** (`HitTestWorldOnly`, `CollisionFeetMid`, o hitbox de cloud e o de ladder) e imprime uma linha por `y`:

```actionscript
public function DumpHitMap():void {
  for (var yy:int = -60; yy < 700; yy++) {        // y*0.5 px
    var row:String = "";
    for (var xx:int = 0; xx < 1050; xx++) {       // x*0.5 px
      row += this.HitTestWorldOnly(xx * 0.5, yy * 0.5) ? "1" : "0";
    }
    trace("HM," + yy + "," + row);
  }
}
```

3. **Entrada determinística:** em vez de teclado, uma tabela de cenário por tick que força os mesmos estados que `PressingLeft()/PressingRight()/_keyPressed[i]` leem (descubra os índices em `Player.as`/`InputKeyboard.as`). Evite cenários que usam `Math.random`.
4. Rode no **Ruffle desktop** (imprime `trace` no console) ou no Flash Player projector, e salve a saída em `golden/`.

**Cenários mínimos (nomes dos arquivos):**
`walk_right_flat`, `walk_up_stair02`, `walk_down_stair01`, `jump_standing`, `jump_hold_4ticks`, `jump_run`, `dive`, `roll`, `fall_from_cloud`, `drop_through_cloud`, `land_on_crate`, `push_crate`, `ladder_up`.

**Plano B se o FFDec não recompilar:** (a) gravar vídeo do Ruffle com o overlay do próprio jogo e medir a posição do personagem por diferença de imagem; (b) usar o AS3 como especificação e validar só os cenários simples (andar/pular) por captura de tela. A paridade fica menos rígida, mas ainda é medida.

**Critério de saída:** `golden/hitmap_world.txt`, `hitmap_cloud.txt`, `hitmap_ladder.txt` e pelo menos 10 traces comitados, mais `tools/README.md` explicando como regenerar.

### Fase C — Geometria única + HitMask
1. `tools/gen-map.mjs`: `Maps.as` → `storage.json` (caixas, polígonos com `IncreaseCorners` já aplicado, tipo, `tiltValue`, spawns, portais). Teste: contagem de objetos do JSON == contagem de chamadas no `.as`.
2. `HitMask`: implementar `hitTestPoint(x, y)` como **ponto dentro da forma OU a ≤ 0.25 px de uma aresta** (preenchimento + traço de 0.5 px), usando as formas exatas do `DrawBoxMC/DrawPolyMC` (largura `+0.5/30`, rotação, vértices expandidos). Isto é uma **hipótese**; o hitmap golden decide.
3. Teste de paridade: varrer a mesma grade do golden e exigir **0 pontos divergentes**. Se divergir, ajustar a regra (ex.: tolerância do traço) até zerar, e documentar a regra descoberta.

**Critério de saída:** `hitmap` TS == `hitmap` Flash em 100% dos pontos para world, cloud e ladder.

### Fase D — Cinemática do jogador (port mecânico, na ordem)
Localize cada função com `grep -n "function NOME" decompiled/scripts/scripts/Code/Data/Players/Player.as`. Ordem recomendada (cada item = uma tarefa, cada um fecha com o trace correspondente):

| Ordem | Funções (Player.as) | Golden que fecha |
|---|---|---|
| D1 | `WalkCollision` 8082, `CollisionSide` 8160, `WorldCollisionSide` 8097, `CanLandInMid` 8184, `CollisionFeetMid` 8238, `CollisionFeetSides` 8289, `CollisionFeetBothSides` 8270, `StandingOnCloud` 8145, `CloudCollisionUp` 8315, `WorldCollisionHead` | hitmap |
| D2 | `MovePlayer` 3883, `UpdateSimpleGroundMovement` 4551, `UpdateGroundMovement` 4497 | `walk_*`, `stair_*` |
| D3 | `UpdateAirMovement` 4628 a ~5150, em 3 a 4 pedaços (setup/ladder; laço de passos; colisão lateral e impacto em objetos; teto) | `jump_*`, `fall_*`, `dive` |
| D4 | `PlayerLands` 5153 (inclui `StairBounce`, `tiltValue`, `GetStairBodyAt`) | `land_*`, escadas na queda |
| D5 | Salto, mergulho, rolagem e agachar (`Roll`, `Jump`, `Dive`) e o pulo variável | `jump_hold`, `dive`, `roll` |
| D6 | Ladder e `jumpDown` de cloud (`_performJumpDownLevel`) | `ladder_*`, `drop_through_cloud` |

**Critério de saída por item:** o trace TS fica **idêntico** ao golden (diferença máxima de 1e-6 px em x/y, flags iguais) para todos os ticks do cenário. Se falhar, o agente corrige o **port**, nunca o teste.

### Fase E — Box2D idêntico (caixas e barris)
O código-fonte do motor exato está em `decompiled/scripts/scripts/Code/Box2D/` (74 arquivos, ~11,5 mil linhas de AS3). É a única forma de ter o mesmo "peso" e atrito de caixas e barris.

- **Decisão (portão):** depois de D3, meça: soltar uma caixa e comparar `y` por tick com o golden `crate_drop`. Se o `planck` divergir mais que o aceitável, **portar o Box2DFlash 2.0 para TS** (`src/box2d/`), mecânico e testável: contatos, solver (`Step(dt, 20)`), `SetMassFromShapes`, `filter.isCloud`, `categoryBits/maskBits`.
- Depois: `UpdateDynamicMovement` (5953), `UpdateObjectImpacts`, `GetDynamicBodyAt`, `Damage_Impact`, formas reais de `CollisionMC` (não aproximar barril como caixa sem conferir `MapPremadeItems.as`).

**Critério de saída:** `crate_drop`, `push_crate`, `land_on_crate` iguais ao golden.

### Fase F — Animação e alinhamento sem ajuste manual
Foi o que mais custou tempo no "storage". Troque o ajuste manual por **diff de imagem automático**:

1. Gerar PNGs de referência por (`personagem`, `label`, `frame`) com o FFDec (export de frames) ou capturas do Ruffle.
2. Renderizar o mesmo frame no Pixi (`CharacterSkin`) em um canvas isolado.
3. Comparar pixel a pixel; relatório com a lista dos frames acima de um limite.
4. Corrigir a **regra geral** (ex.: ordem de aplicação da matriz, arredondamento de twips), não frame a frame.

**Critério de saída:** 100% dos frames do Billy abaixo do limite de diferença definido.

### Fase G — O resto
Câmera seguindo (`GetCamArea`), combate, armas, explosões, HUD, áudio, IA, outros mapas. **Só começa depois que D e E passarem.** Cada módulo novo segue o mesmo ciclo: golden → port mecânico → teste de paridade.

---

## 5. Protocolo de port por função (copie para cada tarefa)

1. **Entrada:** cole o AS3 inteiro da função (e das funções que ela chama, se pequenas).
2. **Saída:** TS com a mesma estrutura. Cabeçalho obrigatório:
   ```ts
   /** Port de Player.as:4551-4626 UpdateSimpleGroundMovement
    *  PARIDADE: NÃO VERIFICADA (verificar com golden walk_up_stair02)
    *  NÃO PORTADO: CheckAimDrop (4608), Fall(false) (4598, 4610) */
   ```
3. **Checklist antes de entregar:** (a) cada `if`/`else` do AS3 tem um equivalente; (b) nenhuma constante nova; (c) `int` do AS3 virou `Math.trunc`/`|0` onde há conversão; (d) `Number` ficou `number` sem arredondar; (e) ordem das operações igual.
4. **Teste:** rodar o cenário golden correspondente. Falhou, corrige o port.
5. **Registro:** atualizar a tabela de status abaixo.

### Tabela de status (manter atualizada)

| Função | Status | Golden | Observação |
|---|---|---|---|
| WalkCollision | portada, não verificada | hitmap | |
| UpdateSimpleGroundMovement | divergente (ver diagnóstico 4) | walk_up_stair02 | |
| UpdateAirMovement | **não portada** | jump_* | substituir `Player.update()` inventado |

---

## 6. Riscos e planos B

| Risco | Plano B |
|---|---|
| FFDec não recompila o AS3 modificado | Capturas do Ruffle + medição por imagem (Fase B, plano B) |
| Ruffle difere do Flash Player em `hitTestPoint` ou física | Validar os mesmos cenários nos dois; se divergirem, preferir o comportamento do Flash Player projector |
| `UpdateAirMovement` é grande demais para uma tarefa | Dividir em 3 a 4 pedaços com checagens intermediárias (D3) |
| `planck` nunca igualar o Box2D 2.0 | Portar o Box2DFlash (Fase E) |
| Direitos autorais (código, sprites e sons originais no repositório) | Não publicar assets originais; manter um script que extrai do SWF do usuário; escolher licença para o código próprio |

---

## 7. O que eu verifiquei (e o que não)

**Verifiquei lendo o código:** `Player.ts`, `StorageMap.ts`, `DestructibleItem.ts`, `GameLoop.ts`, `main.ts` e a estrutura do repositório, contra `WalkCollision`, `CollisionSide`, `CanLandInMid`, `CollisionFeetMid`, `CollisionFeetSides`, `MovePlayer`, `UpdateSimpleGroundMovement`, o início de `UpdateAirMovement` e de `PlayerLands`, `GenerateMapStorage`, `CreateGroundBox/Polygon`, `DrawBoxMC/DrawPolyMC` e `GameMain.as` (iterações). As coordenadas dos vértices das escadas foram recalculadas por script.

**Não verifiquei:** não rodei o jogo nem os testes (o `npm install` não alcançou o registro aqui); não li `PlayerAnimation.ts`, `CharacterSkin.ts`, `Camera.ts`, `Input.ts`; não li o resto de `UpdateAirMovement` além do início; o efeito exato do traço de 0.5 px em `hitTestPoint` e a sintaxe do FFDec para editar scripts são hipóteses que a Fase B confirma.
