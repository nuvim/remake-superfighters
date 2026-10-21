import { describe, it, expect } from 'vitest';
import { PlayerState } from '../src/player/PlayerState';

describe('PlayerState (Fase 2 Ground Truth Constants)', () => {
  it('should match exact physics constants from PlayerState.as', () => {
    expect(PlayerState.PLAYER_GRAVITY).toBe(0.6); // PlayerState.as:12
    expect(PlayerState.PLAYER_JUMP_POWER).toBe(-5.0); // PlayerState.as:20
    expect(PlayerState.PLAYER_JUMP_PUSH_POWER).toBe(-0.7); // PlayerState.as:24
    expect(PlayerState.PLAYER_JUMP_PUSH_TIME).toBe(4); // PlayerState.as:30
    expect(PlayerState.PLAYER_WALL_JUMP_POWER).toBe(-5.0); // PlayerState.as:34
    expect(PlayerState.FALL_TRIGGER_SPEED).toBe(8.5); // PlayerState.as:36
    expect(PlayerState.STAGGER_SPEED).toBe(1.0); // PlayerState.as:38
    expect(PlayerState.ROLL_SPEED).toBe(2.0); // PlayerState.as:40
    expect(PlayerState.DIVE_SPEED).toBe(3.5); // PlayerState.as:42
    expect(PlayerState.CLIMB_SPEED).toBe(1.5); // PlayerState.as:80
    expect(PlayerState.SLIDE_SPEED).toBe(3.0); // PlayerState.as:82
    expect(PlayerState.RUN_SPEED).toBe(1.7); // PlayerState.as:176
    expect(PlayerState.SPRINT_ENERGY_MAX).toBe(100); // PlayerState.as:220
    expect(PlayerState.MAX_HEALTH).toBe(100);
    expect(PlayerState.KNOCKDOWN_IMMUNITY_TIME).toBe(10);
  });

  it('should initialize with standard default values', () => {
    const state = new PlayerState(100, 200);
    expect(state.posX).toBe(100);
    expect(state.posY).toBe(200);
    expect(state.hp).toBe(100);
    expect(state.sprintEnergy).toBe(100);
    expect(state.lastDirX).toBe(1);
    expect(state.isGrounded).toBe(false);
  });
});
