# Ferramentas de Engenharia Reversa e Testes (Tools)

Este diretório contém os scripts de automação, pipelines de extração do SWF original e suítes de teste/verificação em Python e Node.js para o remake de Superfighters.

---

## 🛠️ Scripts Principais

### 1. Extração de Sprites e Metadados
- **`build-sprite-db.mjs`**: Pipeline em Node.js que consome o XML gerado pelo JPEXS FFDec (`tools/extract/swf.xml`), extrai todos os 845 sprites e MovieClips do SWF, parseia matrizes de transformação canônicas (twips para pixels, rotações, escalas e offsets) e mapeia todas as 55 labels de animação dos 10 personagens para `superfighters-web/src/data/generated/spriteDatabase.json`.

### 2. Simulação e Testes de Física em Python
- **`test_flash_physics_1to1.py`**: Simulador em Python da máquina de física e locomoção do ActionScript 3 (`Player.as` e `Maps.as`). Testa caminhada para direita e esquerda através do mapa Storage, subindo e descendo escadas com micro-passos de 0.1px.
- **`test_full_sim.py`**: Execução contínua de 250 ticks de física verificando se o jogador mantém contato de solo ininterrupto (`on_ground == True`).
- **`test_jump_crate.py`**: Simulação matemática de pulo e aterrissagem sobre caixas de madeira dinâmicas.
- **`test_poly_expansion.py`**: Validação da regra canônica `IncreaseCorners` (`MapPremadeItems.as:2807`), que expande vértices de rampas em 0.5px para evitar perdas de ponto no polígono.

### 3. Utilitários de Inspeção do Código Original
- **`inspect_player_movement.py`**: Inspeção de `MovePlayer`, `UpdateSimpleGroundMovement`, `WalkCollision` e `CanLandInMid` diretamente dos scripts AS3 descompilados.
- **`inspect_storage_map.py`**: Inspeção das caixas, polígonos e spawns de `GenerateMapStorage` (`Maps.as`).
- **`find_crates_barrels.py`** e **`find_dynamic_interactions.py`**: Mapeamento de como o Flash lida com caixas (`CRATE`), barris normais (`BARREL`) e explosivos (`BARREL_EXPLOSIVE`).

---

## 🚀 Como Executar os Testes em Python

```bash
# Executar teste de locomoção e escadas 1:1
python tools/test_flash_physics_1to1.py

# Executar simulação completa de 250 ticks
python tools/test_full_sim.py
```
