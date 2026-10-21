import * as planck from 'planck';
import { Sprite, Texture } from 'pixi.js';

export type DestructibleType = 'CRATE' | 'BARREL_EXPLOSIVE' | 'BARREL';

export interface DestructibleDef {
  type: DestructibleType;
  texturePath: string;
  sizeX: number;
  sizeY: number;
  pivotX: number;
  pivotY: number;
  density: number;
  friction: number;
  restitution: number;
}

/**
 * Propriedades físicas extraídas literalmente de MapPremadeItems.as e MaterialsData.as:
 * 
 * - CRATE: size=(14,14), size+=1 -> 15x15 px (SetAsBox: 15/60, 15/60). Material Wood (density 3, friction 0.6, restitution 0.3).
 * - BARREL_EXPLOSIVE: size=(9,13), size+=1 -> 10x14 px (SetAsBox: 10/60, 14/60). Material Metal (density 10, friction 0.4, restitution 0.1).
 * - BARREL: size=(9,13), size+=1 -> 10x14 px (SetAsBox: 10/60, 14/60). Material Metal (density 10, friction 0.4, restitution 0.1).
 */
export const DESTRUCTIBLE_CONFIGS: Record<DestructibleType, DestructibleDef> = {
  CRATE: {
    type: 'CRATE',
    texturePath: '/assets/sprites/DefineSprite_50_crate_01/1.png',
    sizeX: 14,
    sizeY: 14,
    pivotX: 8,
    pivotY: 8,
    density: 3.0,
    friction: 0.6,
    restitution: 0.3
  },
  BARREL_EXPLOSIVE: {
    type: 'BARREL_EXPLOSIVE',
    texturePath: '/assets/sprites/DefineSprite_47_barrel_01/1.png',
    sizeX: 9,
    sizeY: 13,
    pivotX: 6.5,
    pivotY: 8.5,
    density: 10.0,
    friction: 0.4,
    restitution: 0.1
  },
  BARREL: {
    type: 'BARREL',
    texturePath: '/assets/sprites/DefineSprite_75_barrel_02/1.png',
    sizeX: 9,
    sizeY: 13,
    pivotX: 5.5,
    pivotY: 7.5,
    density: 10.0,
    friction: 0.4,
    restitution: 0.1
  }
};

export class DestructibleItem {
  public readonly body: planck.Body;
  public readonly sprite: Sprite;
  public readonly def: DestructibleDef;
  public hp: number;

  constructor(
    world: planck.World,
    type: DestructibleType,
    texture: Texture,
    xMeters: number,
    yMeters: number,
    angleRad: number = 0
  ) {
    this.def = DESTRUCTIBLE_CONFIGS[type];
    this.hp = type === 'CRATE' ? 40 : 50; // MapPremadeItems.as: lines 1001, 1469

    // Criar Sprite PixiJS
    this.sprite = new Sprite(texture);
    this.sprite.anchor.set(
      this.def.pivotX / texture.width,
      this.def.pivotY / texture.height
    );

    // Criar corpo físico Box2D Planck.js
    this.body = world.createDynamicBody({
      position: planck.Vec2(xMeters, yMeters),
      angle: angleRad
    });

    // Box2D half-extents calculadas exatamente como no AS3:
    // (size.x + 1) / 60, (size.y + 1) / 60
    const halfWidth = (this.def.sizeX + 1) / 60.0;
    const halfHeight = (this.def.sizeY + 1) / 60.0;

    this.body.createFixture({
      shape: planck.Box(halfWidth, halfHeight),
      density: this.def.density,
      friction: this.def.friction,
      restitution: this.def.restitution,
      filterCategoryBits: 2
    });

    this.body.setUserData({
      type: this.def.type,
      item: this
    });

    this.updateVisuals();
  }

  public updateVisuals(): void {
    const pos = this.body.getPosition();
    this.sprite.position.set(pos.x * 30.0, pos.y * 30.0);
    this.sprite.rotation = this.body.getAngle();
  }
}
