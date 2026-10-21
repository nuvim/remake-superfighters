import { describe, it, expect } from 'vitest';
import * as planck from 'planck';
import { Container, Texture } from 'pixi.js';
import { StorageMap } from '../src/stage/StorageMap';
import { Player } from '../src/player/Player';

describe('StorageMap Ground, Ramps & Player Kinematics (Flash 1:1)', () => {
  const world = new planck.World();
  const dummyTexture = Texture.EMPTY;
  const dummyLayer = new Container();

  // Mapa de terreno limpo (sem caixas/barris no caminho) para teste puro de rampas e escadas
  const terrainOnlyMap = new StorageMap(world, dummyTexture, {}, dummyLayer, dummyLayer);

  // Mapa completo com caixas e barris
  const texturesMap = {
    CRATE: dummyTexture,
    BARREL_EXPLOSIVE: dummyTexture,
    BARREL: dummyTexture,
  };
  const fullMap = new StorageMap(world, dummyTexture, texturesMap, dummyLayer, dummyLayer);

  it('should detect solid collision on the left platform at y = 255', () => {
    expect(terrainOnlyMap.hitTestWorld(120, 255)).toBe(true);
    expect(terrainOnlyMap.hitTestWorld(120, 250)).toBe(false);
  });

  it('should detect ramp polygon collision along stair02 (x: 127 -> 157)', () => {
    expect(terrainOnlyMap.hitTestWorld(128, 256)).toBe(true);
    expect(terrainOnlyMap.hitTestWorld(145, 265)).toBe(true);
    expect(terrainOnlyMap.hitTestWorld(157, 274)).toBe(true);
  });

  it('should detect ramp polygon collision along stair01 (x: 304 -> 334)', () => {
    expect(terrainOnlyMap.hitTestWorld(305, 274)).toBe(true);
    expect(terrainOnlyMap.hitTestWorld(320, 262)).toBe(true);
    expect(terrainOnlyMap.hitTestWorld(333, 256)).toBe(true);
  });

  it('CRITICAL TEST: Player walks RIGHT from x=60 to x=400 across stair02, lower floor, stair01 and stays grounded 100% of the time', () => {
    const player = new Player(dummyTexture, 60, 255);
    player.playerLands(255);
    expect(player.state.isGrounded).toBe(true);

    for (let tick = 0; tick < 250; tick++) {
      player.movePlayer(1, 1.7, terrainOnlyMap);
      if (!player.state.isGrounded) {
        console.log(`Lost ground at tick ${tick}: posX=${player.state.posX}, posY=${player.state.posY}`);
      }
      expect(player.state.isGrounded).toBe(true);
      expect(player.state.posY).toBeLessThanOrEqual(275);
      expect(player.state.posY).toBeGreaterThanOrEqual(254);
    }

    expect(player.state.posX).toBeGreaterThan(380);
    expect(player.state.posY).toBeGreaterThanOrEqual(254);
    expect(player.state.posY).toBeLessThanOrEqual(256);
  });

  it('CRITICAL TEST: Player walks LEFT from x=400 back to x=60 across stair01, lower floor, stair02 and stays grounded 100% of the time (Stairs climbing bug fix)', () => {
    const player = new Player(dummyTexture, 400, 255);
    player.playerLands(255);
    expect(player.state.isGrounded).toBe(true);

    for (let tick = 0; tick < 250; tick++) {
      player.movePlayer(-1, 1.7, terrainOnlyMap);
      expect(player.state.isGrounded).toBe(true);
      expect(player.state.posY).toBeLessThanOrEqual(275);
      expect(player.state.posY).toBeGreaterThanOrEqual(254);
    }

    expect(player.state.posX).toBeLessThan(80);
    expect(player.state.posY).toBeGreaterThanOrEqual(254);
    expect(player.state.posY).toBeLessThanOrEqual(256);
  });

  it('should detect and interact with dynamic crates and barrels as physical obstacles', () => {
    expect(fullMap.destructibles.length).toBeGreaterThan(0);
    const firstCrate = fullMap.destructibles.find((d) => d.def.type === 'CRATE');
    expect(firstCrate).toBeDefined();

    if (firstCrate) {
      const pos = firstCrate.body.getPosition();
      const px = pos.x * 30.0;
      const py = pos.y * 30.0;
      // hitTestWorld com checagem dinâmica ativada detecta o item
      expect(fullMap.hitTestWorld(px, py, true)).toBe(true);
      // hitTestWorld puramente estático ignora o item
      expect(fullMap.hitTestWorld(px, py, false)).toBe(false);
      expect(fullMap.getDynamicBodyAt(px, py)).toBe(firstCrate.body);
    }
  });

  it('should stop player when walking into a crate/barrel obstacle', () => {
    // No fullMap, há um barril em x=96, y=247
    const player = new Player(dummyTexture, 60, 255);
    player.playerLands(255);

    for (let tick = 0; tick < 50; tick++) {
      player.movePlayer(1, 1.7, fullMap);
    }

    // Player deve ser bloqueado antes do barril (por volta de x=88) e não atravessá-lo
    expect(player.state.posX).toBeLessThan(95);
    expect(player.state.posX).toBeGreaterThan(85);
  });
});
