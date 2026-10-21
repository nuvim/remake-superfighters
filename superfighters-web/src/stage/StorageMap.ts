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
  private stairBodies: planck.Body[] = [];

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
   * staticPolysPixel derivado dos fixtures dos corpos das escadas (vértices do corpo x 30).
   * PARIDADE: verificada por tests/StairGeometry.test.ts
   */
  public get staticPolysPixel(): [number, number][][] {
    return this.stairBodies.map((body) => {
      const fixture = body.getFixtureList();
      if (!fixture) return [];
      const poly = fixture.getShape() as planck.Polygon;
      const pts: [number, number][] = [];
      for (let i = 0; i < poly.m_count; i++) {
        const wp = body.getWorldPoint(poly.m_vertices[i]);
        pts.push([wp.x * 30.0, wp.y * 30.0]);
      }
      return pts;
    });
  }

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

      const isLadder = b.type === 'LADDER';
      const isCloud = b.type === 'CLOUD';

      body.createFixture({
        shape: planck.Box(w / 2.0, h / 2.0),
        density: 0.0,
        friction: friction,
        restitution: restitution,
        isSensor: isLadder,
        filterCategoryBits: isCloud ? 4 : (isLadder ? 8 : 1),
        filterMaskBits: isLadder ? 0 : 65535
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
      this.stairBodies.push(body);
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
   * Helper point-in-polygon (Ray-casting) para conferência de polígonos côncavos/convexos
   */
  private pointInPolygon(x: number, y: number, verts: [number, number][]): boolean {
    let inside = false;
    const n = verts.length;
    let p1x = verts[0][0];
    let p1y = verts[0][1];
    for (let i = 0; i <= n; i++) {
      const p2x = verts[i % n][0];
      const p2y = verts[i % n][1];
      if (y > Math.min(p1y, p2y) && y <= Math.max(p1y, p2y) && x <= Math.max(p1x, p2x)) {
        if (p1y !== p2y) {
          const xinters = ((y - p1y) * (p2x - p1x)) / (p2y - p1y) + p1x;
          if (p1x === p2x || x <= xinters) {
            inside = !inside;
          }
        }
      }
      p1x = p2x;
      p1y = p2y;
    }
    return inside;
  }

  /**
   * hitTestWorld 1:1 com _static_world_hitbox_mc.hitTestPoint(x, y, true) de Player.as:7916.
   * Testa colisão contra todas as caixas sólidas (NONE), polígonos de escadas (stair01, stair02)
   * e corpos dinâmicos de caixas/barris (OBJECTS_HITBOX).
   */
  public hitTestWorld(x: number, y: number, checkDynamic: boolean = true): boolean {
    // 1. Caixas estáticas sólidas (material ground ou metal com type NONE)
    for (const b of this.groundBoxes) {
      if (b.type !== 'NONE') continue;
      const minX = (b.x - b.width / 2) * 30.0 - 0.25;
      const maxX = (b.x + b.width / 2) * 30.0 + 0.25;
      const minY = (b.y - b.height / 2) * 30.0 - 0.25;
      const maxY = (b.y + b.height / 2) * 30.0 + 0.25;
      if (x >= minX && x <= maxX && y >= minY && y <= maxY) return true;
    }

    // 2. Polígonos de rampa (stair02 e stair01)
    for (const poly of this.staticPolysPixel) {
      if (this.pointInPolygon(x, y, poly)) return true;
    }

    // 3. Caixas e barris dinâmicos (_static_objects_hitbox_mc em Flash)
    if (checkDynamic) {
      for (const item of this.destructibles) {
        if (item.hp <= 0) continue;
        const pos = item.body.getPosition();
        const halfW = (item.def.sizeX + 1) / 2.0;
        const halfH = (item.def.sizeY + 1) / 2.0;
        const angle = item.body.getAngle();
        const dx = x - pos.x * 30.0;
        const dy = y - pos.y * 30.0;

        if (Math.abs(angle) < 0.01) {
          if (Math.abs(dx) <= halfW && Math.abs(dy) <= halfH) return true;
        } else {
          const cos = Math.cos(-angle);
          const sin = Math.sin(-angle);
          const lx = dx * cos - dy * sin;
          const ly = dx * sin + dy * cos;
          if (Math.abs(lx) <= halfW && Math.abs(ly) <= halfH) return true;
        }
      }
    }

    return false;
  }

  /**
   * hitTestCloud 1:1 com _static_world_cloud_hitbox_mc.hitTestPoint(x, y, true) de Player.as:7932.
   * Testa colisão contra plataformas nuvem permeáveis (CLOUD).
   */
  public hitTestCloud(x: number, y: number): boolean {
    for (const b of this.groundBoxes) {
      if (b.type !== 'CLOUD') continue;
      if (b.angle !== 0) {
        const dx = x - b.x * 30.0;
        const dy = y - b.y * 30.0;
        const cos = Math.cos(-b.angle);
        const sin = Math.sin(-b.angle);
        const lx = dx * cos - dy * sin;
        const ly = dx * sin + dy * cos;
        const hw = (b.width * 30.0) / 2.0;
        const hh = (b.height * 30.0) / 2.0;
        if (Math.abs(lx) <= hw && Math.abs(ly) <= hh + 1.0) return true;
      } else {
        const minX = (b.x - b.width / 2) * 30.0;
        const maxX = (b.x + b.width / 2) * 30.0;
        const minY = (b.y - b.height / 2) * 30.0;
        const maxY = (b.y + b.height / 2) * 30.0 + 1.0;
        if (x >= minX && x <= maxX && y >= minY && y <= maxY) return true;
      }
    }
    return false;
  }

  /**
   * hitTestLadder 1:1 com _static_ladder_hitbox_mc.hitTestPoint(x, y, true) de Player.as:4732.
   */
  public hitTestLadder(x: number, y: number): boolean {
    for (const b of this.groundBoxes) {
      if (b.type !== 'LADDER') continue;
      const minX = (b.x - b.width / 2) * 30.0;
      const maxX = (b.x + b.width / 2) * 30.0;
      const minY = (b.y - b.height / 2) * 30.0;
      const maxY = (b.y + b.height / 2) * 30.0;
      if (x >= minX && x <= maxX && y >= minY && y <= maxY) return true;
    }
    return false;
  }

  /**
   * Retorna o corpo dinâmico (Box2D Planck.js) presente nas coordenadas (px, py), se houver.
   */
  public getDynamicBodyAt(px: number, py: number): planck.Body | null {
    for (const item of this.destructibles) {
      if (item.hp <= 0) continue;
      const pos = item.body.getPosition();
      const halfW = (item.def.sizeX + 4) / 2.0;
      const halfH = (item.def.sizeY + 4) / 2.0;
      const angle = item.body.getAngle();
      const dx = px - pos.x * 30.0;
      const dy = py - pos.y * 30.0;

      if (Math.abs(angle) < 0.01) {
        if (Math.abs(dx) <= halfW && Math.abs(dy) <= halfH) return item.body;
      } else {
        const cos = Math.cos(-angle);
        const sin = Math.sin(-angle);
        const lx = dx * cos - dy * sin;
        const ly = dx * sin + dy * cos;
        if (Math.abs(lx) <= halfW && Math.abs(ly) <= halfH) return item.body;
      }
    }
    return null;
  }

  /**
   * Aplica impulso físico linear em um corpo dinâmico (ex: ao empurrar ou chutar).
   */
  public pushBody(body: planck.Body, dirX: number, power: number = 1.2): void {
    body.applyLinearImpulse(
      planck.Vec2(dirX * power, -0.1),
      body.getPosition()
    );
  }

  /**
   * Verifica se o ponto está dentro de uma escada (LADDER).
   */
  public checkLadderCollision(px: number, py: number): boolean {
    return this.hitTestLadder(px, py);
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

      if (distSq < 1.0) {
        item.body.applyLinearImpulse(
          planck.Vec2(dirX * impulsePower, -0.5),
          pos
        );
      }
    }
  }
}
