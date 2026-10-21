import { describe, it, expect, beforeEach } from 'vitest';
import { PlayerState } from '../src/player/PlayerState';
import { PlayerAnimation } from '../src/player/PlayerAnimation';

describe('PlayerAnimation (Fase 3 Ground Truth)', () => {
  let state: PlayerState;
  let anim: PlayerAnimation;

  beforeEach(() => {
    state = new PlayerState(100, 100);
    anim = new PlayerAnimation(state);
  });

  it('should initialize with IDLE when stationary and grounded', () => {
    anim.updateAnimation();
    expect(anim.currentAnimation).toBe('IDLE');
    expect(anim.isLoopAnimation).toBe(true);
  });

  it('should transition to RUN when moving on ground', () => {
    state.movingDirectionX = 1;
    state.isGrounded = true;
    anim.updateAnimation();
    expect(anim.currentAnimation).toBe('RUN');
    expect(anim.isLoopAnimation).toBe(true);
  });

  it('should transition to SPRINT when sprinting with energy', () => {
    state.movingDirectionX = 1;
    state.sprinting = true;
    state.isGrounded = true;
    anim.updateAnimation();
    expect(anim.currentAnimation).toBe('SPRINT');
    expect(anim.isLoopAnimation).toBe(true);
  });

  it('should transition to JUMP when in air and jumping', () => {
    state.jumping = true;
    state.isGrounded = false;
    anim.updateAnimation();
    expect(anim.currentAnimation).toBe('JUMP');
  });

  it('should transition to DIVE with correct rotation speed', () => {
    state.diving = true;
    state.isGrounded = false;
    anim.updateAnimation();
    expect(anim.currentAnimation).toBe('DIVE');
    expect(anim.isHelpAnimation).toBe(true);
    expect(anim.isLoopAnimation).toBe(true);
  });

  it('should correctly select FALL_F vs FALL_B based on velocity direction', () => {
    state.falling = true;
    state.isGrounded = false;

    // Caindo para frente (virado para direita, velX >= 0)
    state.lastDirX = 1;
    state.airVelocityX = 1.0;
    anim.updateAnimation();
    expect(anim.currentAnimation).toBe('FALL_F');

    // Caindo para trás (virado para direita, velX < 0)
    state.airVelocityX = -1.0;
    anim.updateAnimation();
    expect(anim.currentAnimation).toBe('FALL_B');
  });

  it('should reset rolling flag when ROLL animation finishes', () => {
    state.rolling = true;
    anim.updateAnimation();
    expect(anim.currentAnimation).toBe('ROLL');
    expect(anim.isLoopAnimation).toBe(false);

    // Avançar frames até concluir o ROLL
    for (let i = 0; i < 10; i++) {
      anim.progressAnimation(1.0, 8);
    }

    expect(state.rolling).toBe(false);
    expect(anim.currentAnimation).toBe('IDLE');
  });

  it('should blink with alpha 0.2 during immunity timer', () => {
    state.isImmune = true;
    state.immunityTimer = 10;

    // Ticks para disparar blink timer
    anim.updateAnimation();
    anim.updateAnimation();
    anim.updateAnimation();
    anim.updateAnimation();

    expect(anim.alpha).toBe(0.2);

    state.isImmune = false;
    anim.updateAnimation();
    expect(anim.alpha).toBe(1.0);
  });
});
