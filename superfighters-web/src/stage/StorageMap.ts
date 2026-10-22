import * as planck from 'planck';
import { Container, Graphics, Sprite, Texture } from 'pixi.js';
import type { Rect } from '../engine/Camera';
import { DestructibleItem, type DestructibleType } from './DestructibleItem';
import storageData from '../data/generated/storage.json';

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
 * StorageMap — Geometria 1:1 derivada diretamente de storage.json (Maps.as:GenerateMapStorage).
 * Única fonte de verdade gerada via tools/gen-map.mjs.
 */
export class StorageMap {
  public static readonly PTM_RATIO: number = 30.0;

  public readonly mapArea: Rect = storageData.mapArea;

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

  public readonly groundBoxes: GroundBoxDef[] = storageData.groundBoxes.map(b => ({
    material: b.material.toLowerCase() as 'ground' | 'metal',
    x: b.x,
    y: b.y,
    angle: b.angle,
    width: b.rawWidth,
    height: b.rawHeight,
    type: b.tags.includes('CLOUD') ? 'CLOUD' : (b.tags.includes('LADDER') ? 'LADDER' : 'NONE')
  }));

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

    // Polígonos de escadas (stair02 e stair01) de storage.json
    const groundPolys: GroundPolyDef[] = storageData.groundPolygons.map(p => ({
      material: p.material.toLowerCase() as 'ground' | 'metal',
      x: p.x,
      y: p.y,
      angle: p.angle,
      vertices: p.rawVertices as [number, number][],
      type: p.tags.includes('CLOUD') ? 'CLOUD' : (p.tags.includes('LADDER') ? 'LADDER' : 'NONE'),
      tiltValue: p.tiltValue
    }));

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
    const rawSpawns: Array<{ type: DestructibleType; x: number; y: number; angle?: number }> = storageData.objects
      .filter(obj => ['CRATE', 'BARREL', 'BARREL_EXPLOSIVE'].includes(obj.primaryType))
      .map(obj => ({
        type: obj.primaryType as DestructibleType,
        x: obj.x,
        y: obj.y,
        angle: obj.angle
      }));

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
    if (inside) return true;

    // Stroke 0.5px de DrawPolyMC (MapPremadeItems.as:2865) -> raio de 0.25px (0.25^2 = 0.0625)
    for (let i = 0; i < n; i++) {
      const p1 = verts[i];
      const p2 = verts[(i + 1) % n];
      const dx = p2[0] - p1[0];
      const dy = p2[1] - p1[1];
      const l2 = dx * dx + dy * dy;
      if (l2 === 0) continue;
      let t = ((x - p1[0]) * dx + (y - p1[1]) * dy) / l2;
      t = Math.max(0, Math.min(1, t));
      const qx = p1[0] + t * dx;
      const qy = p1[1] + t * dy;
      const d2 = (x - qx) * (x - qx) + (y - qy) * (y - qy);
      // Stroke 0.5px de DrawPolyMC (MapPremadeItems.as:2865) com caps/joints circulares de 0.5px
      if (d2 <= 0.25) return true;
    }

    return false;
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
      // Expansão 1:1 com MapPremadeItems.as:171 (+0.5/30 Box2D) e DrawBoxMC lineStyle 0.5 (+0.25px stroke) => 0.5px total
      const minX = (b.x - b.width / 2) * 30.0 - 0.5;
      const maxX = (b.x + b.width / 2) * 30.0 + 0.5;
      const minY = (b.y - b.height / 2) * 30.0 - 0.5;
      const maxY = (b.y + b.height / 2) * 30.0 + 0.5;
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
