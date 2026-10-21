import { Container } from 'pixi.js';

/**
 * DisplayLayers — Árvore de Containers idêntica ao Flash original (GameMain.as:250-305).
 * 
 * Estrutura:
 * rootStage
 * └── game_window
 *     ├── shake_container
 *     │   └── dynamic_mc  <-- Container principal que a Câmera translada e aplica zoom
 *     │       ├── LEVEL           (Cenário de fundo / imagens do mapa)
 *     │       ├── EFFECTSBEHIND   (Fumaça e efeitos de fundo)
 *     │       ├── OBJECTS         (Caixas de madeira, barris explosivos, móveis)
 *     │       ├── SCRAP           (Estilhaços, cartuchos)
 *     │       ├── PLAYERS         (Lutadores Billy, Boris, etc.)
 *     │       ├── WEAPONS         (Armas caídas no chão)
 *     │       ├── EFFECTS         (Flashes de tiro, fagulhas)
 *     │       ├── PROJECTILES     (Projéteis, foguetes)
 *     │       └── LEVEL_FRONT     (Grades, parapeitos e primeiro plano)
 *     └── GUI_HOLDER      (HUD, barras de vida na tela)
 */
export class DisplayLayers {
  public readonly gameWindow: Container;
  public readonly shakeContainer: Container;
  public readonly dynamicMc: Container;

  public readonly levelLayer: Container;
  public readonly effectsBehindLayer: Container;
  public readonly objectsLayer: Container;
  public readonly scrapLayer: Container;
  public readonly playersLayer: Container;
  public readonly weaponsLayer: Container;
  public readonly effectsLayer: Container;
  public readonly projectilesLayer: Container;
  public readonly levelFrontLayer: Container;
  public readonly guiHolder: Container;

  constructor(stage: Container) {
    this.gameWindow = new Container();
    this.gameWindow.label = 'GAME_WINDOW';

    this.shakeContainer = new Container();
    this.shakeContainer.label = 'SHAKE_CONTAINER';

    this.dynamicMc = new Container();
    this.dynamicMc.label = 'DYNAMIC_MC';

    this.levelLayer = new Container();
    this.levelLayer.label = 'LEVEL';

    this.effectsBehindLayer = new Container();
    this.effectsBehindLayer.label = 'EFFECTSBEHIND';

    this.objectsLayer = new Container();
    this.objectsLayer.label = 'OBJECTS';

    this.scrapLayer = new Container();
    this.scrapLayer.label = 'SCRAP';

    this.playersLayer = new Container();
    this.playersLayer.label = 'PLAYERS';

    this.weaponsLayer = new Container();
    this.weaponsLayer.label = 'WEAPONS';

    this.effectsLayer = new Container();
    this.effectsLayer.label = 'EFFECTS';

    this.projectilesLayer = new Container();
    this.projectilesLayer.label = 'PROJECTILES';

    this.levelFrontLayer = new Container();
    this.levelFrontLayer.label = 'LEVEL_FRONT';

    this.guiHolder = new Container();
    this.guiHolder.label = 'GUI_HOLDER';

    // Montar hierarquia 1:1
    this.dynamicMc.addChild(this.levelLayer);
    this.dynamicMc.addChild(this.effectsBehindLayer);
    this.dynamicMc.addChild(this.objectsLayer);
    this.dynamicMc.addChild(this.scrapLayer);
    this.dynamicMc.addChild(this.playersLayer);
    this.dynamicMc.addChild(this.weaponsLayer);
    this.dynamicMc.addChild(this.effectsLayer);
    this.dynamicMc.addChild(this.projectilesLayer);
    this.dynamicMc.addChild(this.levelFrontLayer);

    this.shakeContainer.addChild(this.dynamicMc);
    this.gameWindow.addChild(this.shakeContainer);
    this.gameWindow.addChild(this.guiHolder);

    stage.addChild(this.gameWindow);
  }
}
