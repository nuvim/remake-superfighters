import { describe, it, expect } from 'vitest';
import spriteDb from '../src/data/generated/spriteDatabase.json';

describe('Sprite Database (Fase 1 Ground Truth)', () => {
  it('should have all 9 original characters', () => {
    const characters = Object.keys(spriteDb.characters);
    expect(characters).toContain('player_billy');
    expect(characters).toContain('player_boris');
    expect(characters).toContain('player_johnny');
    expect(characters).toContain('player_agent');
    expect(characters).toContain('player_scott');
    expect(characters).toContain('player_funnyman');
    expect(characters).toContain('player_mac');
    expect(characters).toContain('player_jeff');
    expect(characters).toContain('player_hitarea');
  });

  it('should contain all required labels for Billy', () => {
    const billy = spriteDb.characters.player_billy;
    expect(billy).toBeDefined();
    expect(billy.spriteId).toBe(1372);
    expect(billy.frameCount).toBe(56);

    const requiredLabels = [
      'IDLE', 'RUN', 'SPRINT', 'JUMP', 'DIVE', 'ROLL',
      'FALL_F', 'FALL_B', 'KNOCKDOWN', 'KNEEL', 'COVER',
      'CLIMB', 'SLIDE', 'PUNCH_01', 'PUNCH_02', 'PUNCH_03',
      'START_PISTOL', 'AIM_PISTOL', 'JUMPKICK', 'DEATH_KNEEL'
    ];

    for (const label of requiredLabels) {
      expect(billy.labels[label]).toBeDefined();
      expect(billy.labels[label].childId).toBeGreaterThan(0);
      expect(billy.labels[label].matrix).toBeDefined();
    }
  });

  it('should have valid sub-sprites with positive frame counts', () => {
    const subSprites = spriteDb.subSprites;
    expect(Object.keys(subSprites).length).toBeGreaterThan(10);

    for (const [id, info] of Object.entries(subSprites)) {
      expect(info.frameCount).toBeGreaterThan(0);
      expect(info.basePath).toMatch(/^\/assets\/sprites\/DefineSprite_\d+\/$/);
    }
  });
});
