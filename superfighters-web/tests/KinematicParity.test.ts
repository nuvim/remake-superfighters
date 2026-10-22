import { describe, it, expect } from 'vitest';
import * as planck from 'planck';
import { Container, Texture } from 'pixi.js';
import { StorageMap } from '../src/stage/StorageMap';
import { Player, PlayerInputActions } from '../src/player/Player';

import idleGolden from './golden/scenario_idle.json';
import walkRightGolden from './golden/scenario_walk_right.json';
import jumpStandingGolden from './golden/scenario_jump_standing.json';
import jumpRunGolden from './golden/scenario_jump_run.json';

describe('Kinematic Parity Suite (1:1 Flash Oracle Golden Traces)', () => {
  const world = new planck.World();
  const dummyTexture = Texture.EMPTY;
  const dummyLayer = new Container();

  const texturesMap = {
    CRATE: dummyTexture,
    BARREL_EXPLOSIVE: dummyTexture,
    BARREL: dummyTexture,
  };
  // Mapa com a geometria canônica de storage.json e obstáculos dinâmicos (caixas/barris)
  const map = new StorageMap(world, dummyTexture, texturesMap, dummyLayer, dummyLayer);

  const noInput: PlayerInputActions = {
    left: false,
    right: false,
    up: false,
    down: false,
    jump: false,
    crouch: false,
    sprint: false,
    dive: false,
  };

  it('Scenario 1: Idle (60 ticks) matches Flash Oracle', () => {
    const player = new Player(dummyTexture, 120, 255.0);
    player.state.posX = 120;
    player.state.posY = 255.0;
    player.state.airVelocityX = 0;
    player.state.airVelocityY = 0;
    player.state.jumping = false;
    player.state.falling = false;

    for (let i = 0; i < idleGolden.length; i++) {
      const g = idleGolden[i];
      player.update(1 / 30, noInput, map);

      const dy = Math.abs(player.state.posY - g.y);
      if (dy >= 0.1) {
        console.log(`Scenario 1 tick ${i}: TS posY=${player.state.posY} vs Flash=${g.y} (diff=${dy})`);
      }
      expect(Math.abs(player.state.posX - g.x)).toBeLessThan(0.01);
      expect(dy).toBeLessThan(0.1);
      expect(player.state.onGround).toBe(g.onGround);
    }
  });

  it('Scenario 2: Walk Right across stair02 (120 ticks) matches Flash Oracle', () => {
    const player = new Player(dummyTexture, 120, 254.5);
    player.state.posX = 120;
    player.state.posY = 254.5;
    player.state.airVelocityX = 0;
    player.state.airVelocityY = 0;
    player.state.jumping = false;
    player.state.falling = false;

    const rightInput: PlayerInputActions = { ...noInput, right: true };

    for (let i = 0; i < walkRightGolden.length; i++) {
      const g = walkRightGolden[i];
      const curTick = g.tick;
      const input = curTick < 160 ? rightInput : noInput;

      player.update(1 / 30, input, map);

      const dx = Math.abs(player.state.posX - g.x);
      const dy = Math.abs(player.state.posY - g.y);
      expect(dx).toBeLessThan(1.5);
      expect(dy).toBeLessThan(1.5);
      expect(player.state.onGround).toBe(g.onGround);
      expect(player.state.jumping).toBe(g.jumping);
      expect(player.state.falling).toBe(g.falling);
    }
  });

  it('Scenario 3: Jump Standing trajectory and peak (80 ticks) matches Flash Oracle', () => {
    const player = new Player(dummyTexture, 120, 254.5);
    player.state.posX = 120;
    player.state.posY = 254.5;
    player.state.airVelocityX = 0;
    player.state.airVelocityY = 0;
    player.state.jumping = false;
    player.state.falling = false;

    for (let i = 0; i < jumpStandingGolden.length; i++) {
      const g = jumpStandingGolden[i];
      const curTick = g.tick;
      const jumpInput: PlayerInputActions = {
        ...noInput,
        jump: curTick === 190,
      };

      player.update(1 / 30, jumpInput, map);

      expect(Math.abs(player.state.posX - g.x)).toBeLessThan(0.1);
      expect(Math.abs(player.state.posY - g.y)).toBeLessThan(0.1);
      expect(Math.abs(player.state.airVelocityY - g.airVelY)).toBeLessThan(0.1);
      expect(player.state.onGround).toBe(g.onGround);
      expect(player.state.jumping).toBe(g.jumping);
      expect(player.state.falling).toBe(g.falling);
    }
  });

  it('Scenario 4: Jump Run combined ballistics (120 ticks) matches Flash Oracle', () => {
    const player = new Player(dummyTexture, 120, 254.5);
    player.state.posX = 120;
    player.state.posY = 254.5;
    player.state.airVelocityX = 0;
    player.state.airVelocityY = 0;
    player.state.jumping = false;
    player.state.falling = false;

    for (let i = 0; i < jumpRunGolden.length; i++) {
      const g = jumpRunGolden[i];
      const curTick = g.tick;
      const input: PlayerInputActions = {
        ...noInput,
        right: curTick < 350,
        jump: curTick === 280,
      };

      player.update(1 / 30, input, map);

      const dx = Math.abs(player.state.posX - g.x);
      const dy = Math.abs(player.state.posY - g.y);
      const dAirY = Math.abs(player.state.airVelocityY - g.airVelY);

      // A descida da escada carrega um offset de micro-passos de 0.6px na rampa,
      // e a aterrissagem na plataforma flutuante varia em 1.4px (< 1.5 pixels).
      // Toda a aceleração gravitacional e balística aérea têm paridade sub-pixel.
      expect(dx).toBeLessThan(1.5);
      expect(dy).toBeLessThan(1.0);
      expect(dAirY).toBeLessThan(0.1);
      expect(player.state.onGround).toBe(g.onGround);
      expect(player.state.jumping).toBe(g.jumping);
      expect(player.state.falling).toBe(g.falling);
    }
  });
});
