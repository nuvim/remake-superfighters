import * as planck from 'planck';
import { Container, Graphics, Sprite, Texture } from 'pixi.js';
import type { Rect } from '../engine/Camera';
import { DestructibleItem, type DestructibleType } from './DestructibleItem';

export interface GroundBoxDef {
  material: 'ground' | 'metal';
  x: number;
  y: number;
  angle: number;
  width: number;
  height: number;
  type: 'NONE' | 'CLOUD' | 'LADDER';
}

export interface GroundPolyDef {
  material: 'ground' | 'metal';
  x: number;
  y: number;
  angle: number;
  vertices: [number, number][];
  type: 'NONE' | 'CLOUD' | 'LADDER';
  tiltValue?: number;
}

/**
 * StorageMap — Port literal 1:1 de Maps.as (GenerateMapStorage, linhas 2346-2435).
 * Todas as coordenadas e geometrias copiadas estritamente do código ActionScript original.
 */
export class StorageMap {
  public static readonly PTM_RATIO: number = 30.0;

  public readonly mapArea: Rect = {
    x: 23,
    y: -26,
    width: 477,
    height: 365
  };

  public readonly world: planck.World;
  public readonly bgSprite: Sprite;
  public readonly destructibles: DestructibleItem[] = [];
  public readonly debugGraphics: Graphics;
  public showHitboxes: boolean = false;

  private staticGroundBodies: planck.Body[] = [];

  constructor(
    world: planck.World,
    bgTexture: Texture,
    textures: Record<string, Texture>,
    levelContainer: Container,
    objectsContainer: Container
  ) {
    this.world = world;

    // Sprite do mapa Storage autêntico 1:1 do SWF original (28.png - 522x328)
    // Extraído de DefineShape 2211 com preenchimento Bitmap 28 em (0, 0)
    this.bgSprite = new Sprite(bgTexture);
    this.bgSprite.position.set(0, 0);
    levelContainer.addChild(this.bgSprite);

    // Camada gráfica para debug de hitboxes de colisão
    this.debugGraphics = new Graphics();
    levelContainer.addChild(this.debugGraphics);

    // 1. Criar geometrias estáticas de Maps.as
    this.createStaticGeometry();

    // 2. Instanciar caixas e barris dinâmicos de Maps.as
    this.createDynamicObjects(textures, objectsContainer);

    this.renderDebugHitboxes();
  }

  public readonly groundBoxes: GroundBoxDef[] = [
    // Linha 2350
    { material: 'ground', x: 176.5 / 30, y: 26.5 / 30, angle: 0, width: 351 / 30, height: 51 / 30, type: 'NONE' },
    // Linha 2351
    { material: 'ground', x: 431 / 30, y: 41.5 / 30, angle: 0, width: 184 / 30, height: 81 / 30, type: 'NONE' },
    // Linha 2352
    { material: 'ground', x: 345 / 30, y: 94 / 30, angle: 0, width: 12 / 30, height: 24 / 30, type: 'NONE' },
    // Linha 2353
    { material: 'ground', x: 495 / 30, y: 99.5 / 30, angle: 0, width: 56 / 30, height: 35 / 30, type: 'NONE' },
    // Linha 2354
    { material: 'ground', x: 411.5 / 30, y: 147 / 30, angle: 0, width: 145 / 30, height: 12 / 30, type: 'NONE' },
    // Linha 2355
    { material: 'ground', x: 503.5 / 30, y: 153 / 30, angle: 0, width: 39 / 30, height: 72 / 30, type: 'NONE' },
    // Linha 2356
    { material: 'ground', x: 495 / 30, y: 259 / 30, angle: 0, width: 56 / 30, height: 140 / 30, type: 'NONE' },
    // Linha 2357
    { material: 'ground', x: 475.5 / 30, y: 159 / 30, angle: 0, width: 17 / 30, height: 12 / 30, type: 'NONE' },
    // Linha 2358
    { material: 'ground', x: 27.5 / 30, y: 190.5 / 30, angle: 0, width: 53 / 30, height: 277 / 30, type: 'NONE' },
    // Linha 2359
    { material: 'metal', x: 104.5 / 30, y: 120 / 30, angle: 0, width: 73 / 30, height: 18 / 30, type: 'NONE' },
    // Linha 2360
    { material: 'ground', x: 90.5 / 30, y: 292 / 30, angle: 0, width: 73 / 30, height: 74 / 30, type: 'NONE' },
    // Linha 2361
    { material: 'ground', x: 230.5 / 30, y: 301 / 30, angle: 0, width: 147 / 30, height: 56 / 30, type: 'NONE' },
    // Linha 2364
    { material: 'ground', x: 400.5 / 30, y: 292 / 30, angle: 0, width: 133 / 30, height: 74 / 30, type: 'NONE' },

    // Plataformas semi-sólidas (CLOUD)
    // Linha 2367
    { material: 'metal', x: 246 / 30, y: 145 / 30, angle: 0, width: 102 / 30, height: 2 / 30, type: 'CLOUD' },
    // Linha 2368
    { material: 'metal', x: 197 / 30, y: 167 / 30, angle: 0, width: 50 / 30, height: 2 / 30, type: 'CLOUD' },
    // Linha 2369
    { material: 'metal', x: 105 / 30, y: 184 / 30, angle: 0, width: 102 / 30, height: 2 / 30, type: 'CLOUD' },
    // Linha 2370
    { material: 'metal', x: 221.5 / 30, y: 208 / 30, angle: 0, width: 93 / 30, height: 2 / 30, type: 'CLOUD' },
    // Linha 2371
    { material: 'metal', x: 221.5 / 30, y: 230 / 30, angle: 0, width: 93 / 30, height: 2 / 30, type: 'CLOUD' },
    // Linha 2372
    { material: 'metal', x: 221.5 / 30, y: 252 / 30, angle: 0, width: 93 / 30, height: 2 / 30, type: 'CLOUD' },
    // Linha 2373
    { material: 'metal', x: 392.5 / 30, y: 212 / 30, angle: 0, width: 93 / 30, height: 2 / 30, type: 'CLOUD' },
    // Linha 2374
    { material: 'metal', x: 392.5 / 30, y: 234 / 30, angle: 0, width: 93 / 30, height: 2 / 30, type: 'CLOUD' },
    // Linha 2375
    { material: 'metal', x: 423 / 30, y: 190 / 30, angle: 0, width: 88 / 30, height: 2 / 30, type: 'CLOUD' },
    // Linha 2376 (Rampa CLOUD inclinada)
    { material: 'metal', x: 167 / 30, y: 196 / 30, angle: 0.7853981633974483, width: 34 / 30, height: 3 / 30, type: 'CLOUD' },
    // Linha 2378 (Escada LADDER)
    { material: 'metal', x: 60 / 30, y: 139 / 30, angle: 0, width: 12 / 30, height: 83 / 30, type: 'LADDER' }
  ];

  /**
   * Cria todas as caixas de colisão de solo e plataformas nuvem (CLOUD)
   * copiadas literalmente de Maps.as:2350-2378.
   */
  private createStaticGeometry(): void {
    for (const b of this.groundBoxes) {
      // Regra de MapPremadeItems.as:171-172:
      // width += 0.5 / 30; height += 0.5 / 30; SetAsBox(width / 2, height / 2);
      const w = b.width + 0.5 / 30.0;
      const h = b.height + 0.5 / 30.0;

      const body = this.world.createBody({
        type: 'static',
        position: planck.Vec2(b.x, b.y),
        angle: b.angle
      });

      const friction = b.material === 'ground' ? 0.5 : 0.4;
      const restitution = b.material === 'ground' ? 0.2 : 0.1;

      body.createFixture({
        shape: planck.Box(w / 2.0, h / 2.0),
        density: 0.0,
        friction: friction,
        restitution: restitution
      });

      body.setUserData({
        isGround: true,
        type: b.type,
        width: w,
        height: h,
        material: b.material
      });

      this.staticGroundBodies.push(body);
    }

    // Polígonos de escadas (stair02 e stair01 de Maps.as:2362-2366)
    const groundPolys: GroundPolyDef[] = [
      // stair02 (Linha 2362)
      {
        material: 'ground',
        x: 143 / 30,
        y: 294 / 30,
        angle: 0,
        vertices: [
          [-16 / 30, -39 / 30],
          [-10 / 30, -39 / 30],
          [14 / 30, -21 / 30],
          [14 / 30, 35 / 30],
          [-16 / 30, 35 / 30]
        ],
        type: 'NONE',
        tiltValue: 2
      },
      // stair01 (Linha 2365)
      {
        material: 'ground',
        x: 320 / 30,
        y: 292 / 30,
        angle: 0,
        vertices: [
          [-16 / 30, -19 / 30],
          [8 / 30, -37 / 30],
          [14 / 30, -37 / 30],
          [14 / 30, 37 / 30],
          [-16 / 30, 37 / 30]
        ],
        type: 'NONE',
        tiltValue: -2
      }
    ];

    for (const p of groundPolys) {
      // Regra de MapPremadeItems.as:2807 IncreaseCorners:
      // Se v[0] < 0 => v[0] -= 0.5/30; se v[0] > 0 => v[0] += 0.5/30
      const expandedVecs: planck.Vec2[] = p.vertices.map(([vx, vy]) => {
        let x = vx;
        let y = vy;
        if (x < 0) x -= 0.5 / 30.0;
        else if (x > 0) x += 0.5 / 30.0;
        if (y < 0) y -= 0.5 / 30.0;
        else if (y > 0) y += 0.5 / 30.0;
        return planck.Vec2(x, y);
      });

      // Garantir ordem CCW para Planck.js
      let area = 0;
      for (let i = 0; i < expandedVecs.length; i++) {
        const j = (i + 1) % expandedVecs.length;
        area += expandedVecs[i].x * expandedVecs[j].y - expandedVecs[j].x * expandedVecs[i].y;
      }
      if (area < 0) {
        expandedVecs.reverse();
      }

      const body = this.world.createBody({
        type: 'static',
        position: planck.Vec2(p.x, p.y),
        angle: p.angle
      });

      body.createFixture({
        shape: planck.Polygon(expandedVecs),
        density: 0.0,
        friction: 0.5,
        restitution: 0.2
      });

      body.setUserData({
        isGround: true,
        type: p.type,
        vertices: expandedVecs,
        tiltValue: p.tiltValue,
        material: p.material
      });

      this.staticGroundBodies.push(body);
    }
  }

  /**
   * Instancia as caixas e barris com posições e rotações exatas de Maps.as:2411-2436.
   */
  private createDynamicObjects(
    textures: Record<string, Texture>,
    objectsContainer: Container
  ): void {
    const rawSpawns: Array<{ type: DestructibleType; x: number; y: number; angle?: number }> = [
      // Linha 2411
      { type: 'BARREL_EXPLOSIVE', x: 281.5 / 30, y: 136 / 30 },
      // Linha 2412
      { type: 'CRATE', x: 230 / 30, y: 137 / 30 },
      // Linha 2413
      { type: 'BARREL', x: 351 / 30, y: 203 / 30 },
      // Linha 2414
      { type: 'CRATE', x: 259 / 30, y: 137 / 30 },
      // Linha 2415
      { type: 'BARREL_EXPLOSIVE', x: 261 / 30, y: 244 / 30 },
      // Linha 2416
      { type: 'CRATE', x: 213 / 30, y: 200 / 30 },
      // Linha 2417
      { type: 'BARREL', x: 183 / 30, y: 243 / 30 },
      // Linha 2418
      { type: 'CRATE', x: 443.5 / 30, y: 248 / 30 },
      // Linha 2419
      { type: 'CRATE', x: 431 / 30, y: 247 / 30 },
      // Linha 2420
      { type: 'BARREL', x: 96 / 30, y: 247 / 30 },
      // Linha 2421
      { type: 'CRATE', x: 109 / 30, y: 103 / 30 },
      // Linha 2422
      { type: 'CRATE', x: 94 / 30, y: 104 / 30 },
      // Linha 2423
      { type: 'CRATE', x: 429 / 30, y: 203 / 30 },
      // Linha 2424 (Barril explosivo tombado horizontalmente: Math.PI / 2)
      { type: 'BARREL_EXPLOSIVE', x: 404 / 30, y: 182 / 30, angle: 1.5707963267948966 },
      // Linha 2425
      { type: 'BARREL', x: 260 / 30, y: 200 / 30 },
      // Linha 2426
      { type: 'BARREL_EXPLOSIVE', x: 132 / 30, y: 174 / 30 },
      // Linha 2427
      { type: 'CRATE', x: 101 / 30, y: 174 / 30 },
      // Linha 2429
      { type: 'CRATE', x: 221 / 30, y: 221 / 30 },
      // Linha 2430
      { type: 'CRATE', x: 211 / 30, y: 266 / 30 },
      // Linha 2431
      { type: 'CRATE', x: 355 / 30, y: 247 / 30 },
      // Linha 2432
      { type: 'BARREL_EXPLOSIVE', x: 375 / 30, y: 247 / 30 },
      // Linha 2433
      { type: 'CRATE', x: 392 / 30, y: 226 / 30 },
      // Linha 2434
      { type: 'BARREL_EXPLOSIVE', x: 390 / 30, y: 203 / 30 },
      // Linha 2436
      { type: 'CRATE', x: 221 / 30, y: 243 / 30 }
    ];

    for (const item of rawSpawns) {
      const tex = textures[item.type];
      if (!tex) continue;

      const destructible = new DestructibleItem(
        this.world,
        item.type,
        tex,
        item.x,
        item.y,
        item.angle ?? 0
      );

      objectsContainer.addChild(destructible.sprite);
      this.destructibles.push(destructible);
    }
  }

  /**
   * Atualiza a posição de todos os itens dinâmicos sincronizando física -> visual
   */
  public update(): void {
    for (const item of this.destructibles) {
      item.updateVisuals();
    }
  }

  /**
   * Desenha as hitboxes de colisão para conferência e validação técnica.
   */
  public renderDebugHitboxes(): void {
    this.debugGraphics.clear();
    if (!this.showHitboxes) return;

    // Desenhar mapArea (Rectangle 23, -26, 477, 365)
    this.debugGraphics.rect(this.mapArea.x, this.mapArea.y, this.mapArea.width, this.mapArea.height);
    this.debugGraphics.stroke({ color: 0xffff00, width: 1, alpha: 0.8 });

    // Desenhar corpos estáticos
    for (const body of this.staticGroundBodies) {
      const data = body.getUserData() as any;

      let color = 0xff00ff; // Magenta clássico do Flash para Ground
      if (data?.type === 'CLOUD') color = 0x00ffff; // Cyan para Cloud
      if (data?.type === 'LADDER') color = 0xffaa00; // Amarelo/laranja para Ladder

      const fixture = body.getFixtureList();
      if (!fixture) continue;
      const shape = fixture.getShape();

      if (shape.getType() === 'polygon') {
        const poly = shape as planck.Polygon;
        const count = poly.m_count;
        const vertices = poly.m_vertices;

        const worldPoints: { x: number; y: number }[] = [];
        for (let i = 0; i < count; i++) {
          const wp = body.getWorldPoint(vertices[i]);
          worldPoints.push({ x: wp.x * 30.0, y: wp.y * 30.0 });
        }

        if (worldPoints.length > 0) {
          this.debugGraphics.poly(worldPoints);
          this.debugGraphics.fill({ color: color, alpha: 0.35 });
          this.debugGraphics.stroke({ color: color, width: 1, alpha: 0.9 });
        }
      }
    }
  }

  public toggleHitboxes(): boolean {
    this.showHitboxes = !this.showHitboxes;
    this.renderDebugHitboxes();
    return this.showHitboxes;
  }

  /**
   * Verifica colisão dos pés do jogador com o solo estático e plataformas CLOUD (Player.as:8206-8236).
   */
  public checkFeetCollision(
    px: number,
    py: number,
    isFallingThroughCloud: boolean = false
  ): { collided: boolean; groundY: number } {
    for (const b of this.groundBoxes) {
      if (b.type === 'LADDER') continue;

      const minX = (b.x - b.width / 2) * 30.0;
      const maxX = (b.x + b.width / 2) * 30.0;
      const minY = (b.y - b.height / 2) * 30.0;
      const maxY = (b.y + b.height / 2) * 30.0;

      if (b.type === 'NONE') {
        // Bloco de solo ou metal sólido
        if (px >= minX && px <= maxX && py >= minY - 2 && py <= maxY) {
          return { collided: true, groundY: minY };
        }
      } else if (b.type === 'CLOUD' && !isFallingThroughCloud) {
        // Plataforma nuvem permeável: só apoia se vier de cima
        if (px >= minX && px <= maxX && py >= minY - 3 && py <= minY + 7) {
          return { collided: true, groundY: minY };
        }
      }
    }

    // 2. Rampas inclinadas de escada (stair02 e stair01 de Maps.as:2362-2366)
    // stair02: x de 127 a 157. Conecta o piso esquerdo (y=255) ao piso rebaixado (y=273)
    if (px >= 127 && px <= 157) {
      const rampY = px <= 133 ? 255 : 255 + (px - 133) * 0.75;
      if (py >= rampY - 4 && py <= rampY + 14) {
        return { collided: true, groundY: rampY };
      }
    }

    // stair01: x de 304 a 334. Conecta o piso rebaixado (y=273) ao piso direito (y=255)
    if (px >= 304 && px <= 334) {
      const rampY = px <= 328 ? 273 - (px - 304) * 0.75 : 255;
      if (py >= rampY - 4 && py <= rampY + 14) {
        return { collided: true, groundY: rampY };
      }
    }

    return { collided: false, groundY: py };
  }

  /**
   * Verifica colisão lateral do corpo do jogador com paredes sólidas.
   */
  public checkWallCollision(
    px: number,
    py: number,
    halfWidth: number = 6,
    height: number = 18
  ): { collided: boolean; pushX: number } {
    const left = px - halfWidth;
    const right = px + halfWidth;
    const top = py - height;
    const bottom = py - 2;

    for (const b of this.groundBoxes) {
      if (b.type !== 'NONE') continue; // Só blocos sólidos barram lateralmente

      const minX = (b.x - b.width / 2) * 30.0;
      const maxX = (b.x + b.width / 2) * 30.0;
      const minY = (b.y - b.height / 2) * 30.0;
      const maxY = (b.y + b.height / 2) * 30.0;

      // Teste de intersecção AABB
      if (right > minX && left < maxX && bottom > minY && top < maxY) {
        // Empurrar para fora do lado mais próximo
        const pushLeft = minX - right;
        const pushRight = maxX - left;
        const pushX = Math.abs(pushLeft) < Math.abs(pushRight) ? pushLeft : pushRight;
        return { collided: true, pushX };
      }
    }
    return { collided: false, pushX: 0 };
  }

  /**
   * Verifica se o ponto está dentro de uma escada (LADDER).
   */
  public checkLadderCollision(px: number, py: number): boolean {
    for (const b of this.groundBoxes) {
      if (b.type !== 'LADDER') continue;

      const minX = (b.x - b.width / 2) * 30.0;
      const maxX = (b.x + b.width / 2) * 30.0;
      const minY = (b.y - b.height / 2) * 30.0;
      const maxY = (b.y + b.height / 2) * 30.0;

      if (px >= minX && px <= maxX && py >= minY && py <= maxY) {
        return true;
      }
    }
    return false;
  }

  /**
   * Aplica impulso físico Box2D em caixas e barris próximos ao lutador (Dive / Chute).
   */
  public pushDynamicItem(px: number, py: number, dirX: number, impulsePower: number = 2.0): void {
    const pxMeters = px / 30.0;
    const pyMeters = py / 30.0;

    for (const item of this.destructibles) {
      const pos = item.body.getPosition();
      const dx = pos.x - pxMeters;
      const dy = pos.y - pyMeters;
      const distSq = dx * dx + dy * dy;

      // Se estiver a menos de 1 metro (30 pixels) de distância
      if (distSq < 1.0) {
        item.body.applyLinearImpulse(
          planck.Vec2(dirX * impulsePower, -0.5),
          pos
        );
      }
    }
  }
}
