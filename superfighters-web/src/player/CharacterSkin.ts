import { Assets, Container, Sprite, Texture } from 'pixi.js';
import spriteDb from '../data/generated/spriteDatabase.json';
import { PlayerAnimation } from './PlayerAnimation';
import { PlayerState } from './PlayerState';

interface MatrixDef {
  x: number;
  y: number;
  scaleX: number;
  scaleY: number;
  rotation: number;
}

interface LabelDef {
  frameNumber: number;
  childId: number;
  childName: string;
  matrix: MatrixDef;
}

interface SubSpriteDef {
  spriteId: number;
  dirName: string;
  frameCount: number;
  basePath: string;
}

/**
 * CharacterSkin.ts — Gerenciador de renderização visual 1:1 do lutador Flash.
 * Carrega e alterna sub-sprites do MovieClip ANIM com fidelidade pixel-perfect
 * e alinhamento pela matriz de transformação canônica.
 */
export class CharacterSkin {
  public readonly container: Container;
  public readonly animContainer: Container;
  public readonly sprite: Sprite;

  private _charKey: string;
  private _characterDef: { spriteId: number; frameCount: number; labels: Record<string, LabelDef> };
  private _subSprites: Record<string, SubSpriteDef>;
  private _textureCache: Map<string, Texture> = new Map();
  private _loadingPaths: Set<string> = new Set();

  constructor(charKey: string = 'player_billy', fallbackTexture?: Texture) {
    this._charKey = charKey;
    const db = spriteDb as unknown as {
      characters: Record<string, { spriteId: number; frameCount: number; labels: Record<string, LabelDef> }>;
      subSprites: Record<string, SubSpriteDef>;
    };

    this._characterDef = db.characters[charKey] || db.characters.player_billy;
    this._subSprites = db.subSprites;

    // Container raiz do lutador (recebe espelhamento horizontal scale.x = lastDirX)
    this.container = new Container();

    // Container ANIM posicionado pela matriz twips/20 do Flash
    this.animContainer = new Container();
    this.container.addChild(this.animContainer);

    // Sprite que exibe o frame ativo com anchor nos pés (centralizado horizontalmente, base no chão)
    this.sprite = new Sprite(fallbackTexture || Texture.EMPTY);
    this.sprite.anchor.set(0.5, 1.0);
    this.animContainer.addChild(this.sprite);
  }

  public get charKey(): string {
    return this._charKey;
  }

  /**
   * Pré-carrega texturas essenciais de locomoção para evitar quedas de frame.
   */
  public async preloadCoreAnimations(): Promise<void> {
    const coreLabels = ['IDLE', 'RUN', 'SPRINT', 'JUMP', 'FALL_F', 'FALL_B', 'DIVE', 'ROLL', 'KNEEL'];
    const loadPromises: Promise<void>[] = [];

    for (const label of coreLabels) {
      const labelDef = this._characterDef.labels[label];
      if (!labelDef) continue;

      const subSprite = this._subSprites[labelDef.childId.toString()];
      if (!subSprite) continue;

      for (let f = 1; f <= subSprite.frameCount; f++) {
        const path = `${subSprite.basePath}${f}.png`;
        if (!this._textureCache.has(path) && !this._loadingPaths.has(path)) {
          this._loadingPaths.add(path);
          loadPromises.push(
            Assets.load<Texture>(path).then((tex) => {
              tex.source.scaleMode = 'nearest';
              this._textureCache.set(path, tex);
              this._loadingPaths.delete(path);
            }).catch(() => {
              this._loadingPaths.delete(path);
            })
          );
        }
      }
    }

    await Promise.all(loadPromises);
  }

  /**
   * Atualiza a animação visual e seleciona a textura correta para o tick a 30 Hz.
   */
  public update(dt: number, state: PlayerState, anim: PlayerAnimation): void {
    // 1. Identificar a label ativa do estado
    anim.updateAnimation();
    const labelName = anim.currentAnimation;
    const labelDef = this._characterDef.labels[labelName] || this._characterDef.labels.IDLE;

    if (!labelDef) return;

    const subSprite = this._subSprites[labelDef.childId.toString()];
    const totalFrames = subSprite ? subSprite.frameCount : 1;

    // 2. Progredir a animação lógica (computa rotações de mergulho/queda e loops)
    anim.progressAnimation(dt, totalFrames);

    // 3. Posicionar e transformar o ANIM container de acordo com a matriz canônica
    this.animContainer.position.set(labelDef.matrix.x, labelDef.matrix.y);
    this.animContainer.scale.set(labelDef.matrix.scaleX, labelDef.matrix.scaleY);

    if (anim.isHelpAnimation) {
      // DIVE e FALL aplicam rotação contínua (graus para radianos)
      this.animContainer.rotation = (anim.rotation * Math.PI) / 180.0;
    } else {
      this.animContainer.rotation = 0;
    }

    // 4. Selecionar o frame e aplicar a textura
    if (subSprite) {
      const currentFrame = Math.max(1, Math.min(totalFrames, anim.currentFrameInt));
      const texturePath = `${subSprite.basePath}${currentFrame}.png`;

      const cached = this._textureCache.get(texturePath);
      if (cached) {
        this.sprite.texture = cached;
      } else if (!this._loadingPaths.has(texturePath)) {
        this._loadingPaths.add(texturePath);
        Assets.load<Texture>(texturePath).then((tex) => {
          tex.source.scaleMode = 'nearest';
          this._textureCache.set(texturePath, tex);
          this._loadingPaths.delete(texturePath);
          this.sprite.texture = tex;
        }).catch(() => {
          this._loadingPaths.delete(texturePath);
        });
      }
    }

    // 5. Aplicar posição, espelhamento horizontal e transparência (imunidade)
    this.container.position.set(state.posX, state.posY);
    this.container.scale.x = state.lastDirX; // -1 quando virado para a esquerda
    this.container.alpha = anim.alpha; // 0.2 quando piscando em imunidade
  }
}
