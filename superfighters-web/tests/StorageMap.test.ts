import { describe, it, expect } from 'vitest';
import * as planck from 'planck';
import { Container, Texture } from 'pixi.js';
import { StorageMap } from '../src/stage/StorageMap';

describe('StorageMap Ground & Ramp Collision (Bug Fix Verification)', () => {
  const world = new planck.World();
  const dummyTexture = Texture.EMPTY;
  const dummyLayer = new Container();
  const texturesMap = {
    CRATE: dummyTexture,
    BARREL_EXPLOSIVE: dummyTexture,
    BARREL: dummyTexture,
  };

  const map = new StorageMap(world, dummyTexture, texturesMap, dummyLayer, dummyLayer);

  it('should detect solid collision on the left platform at y = 255', () => {
    const res = map.checkFeetCollision(120, 255);
    expect(res.collided).toBe(true);
    expect(res.groundY).toBe(255);
  });

  it('should detect continuous collision along stair02 (x: 127 -> 157) without falling', () => {
    // Testar o ponto de transição exato onde o jogador caía (x = 128)
    const at128 = map.checkFeetCollision(128, 255);
    expect(at128.collided).toBe(true);
    expect(at128.groundY).toBe(255);

    // Testar no meio da rampa (x = 145)
    const expectedMidY = 255 + (145 - 133) * 0.75; // 264
    const atMid = map.checkFeetCollision(145, expectedMidY);
    expect(atMid.collided).toBe(true);
    expect(atMid.groundY).toBe(expectedMidY);

    // Testar na junção com o piso inferior (x = 157)
    const at157 = map.checkFeetCollision(157, 273);
    expect(at157.collided).toBe(true);
    expect(at157.groundY).toBe(273);
  });

  it('should detect collision on the lower floor at y = 273', () => {
    const res = map.checkFeetCollision(200, 273);
    expect(res.collided).toBe(true);
    expect(res.groundY).toBe(273);
  });

  it('should detect continuous collision along stair01 (x: 304 -> 334)', () => {
    const at304 = map.checkFeetCollision(304, 273);
    expect(at304.collided).toBe(true);
    expect(at304.groundY).toBe(273);

    const at328 = map.checkFeetCollision(328, 255);
    expect(at328.collided).toBe(true);
    expect(at328.groundY).toBe(255);
  });

  it('should verify continuous ground contact from left platform across both ramps to right platform (x: 60 to 450)', () => {
    let currentY = 255;
    for (let x = 60; x <= 450; x += 1) {
      const check = map.checkFeetCollision(x, currentY);
      expect(check.collided).toBe(true);
      currentY = check.groundY; // Segue o solo suavemente
    }
  });
});
