import { describe, it, expect, vi } from 'vitest';
import { GameLoop } from '../src/engine/GameLoop';

describe('GameLoop (30 Hz Fixed Step)', () => {
  it('should have a fixed timestep of exactly 1/30 seconds', () => {
    expect(GameLoop.FIXED_TIMESTEP).toBeCloseTo(1 / 30, 6);
  });

  it('should trigger logic updates in fixed 1/30s increments', () => {
    const loop = new GameLoop();
    const logicSpy = vi.fn();
    loop.onLogicUpdate = logicSpy;

    loop.start(1000);

    // Advance by 100ms (3.33 logic ticks)
    loop.update(1100);

    // Exactly 3 logic steps should have fired for 100ms at 30Hz
    expect(logicSpy).toHaveBeenCalledTimes(3);
    expect(logicSpy).toHaveBeenCalledWith(GameLoop.FIXED_TIMESTEP);
  });

  it('should prevent spiral of death with max accumulator clamp', () => {
    const loop = new GameLoop();
    const logicSpy = vi.fn();
    loop.onLogicUpdate = logicSpy;

    loop.start(1000);

    // Simulate 2000ms delay (e.g. browser tab suspended)
    loop.update(3000);

    // Max accumulator is 0.25s (7.5 ticks -> 7 ticks max)
    expect(logicSpy.mock.calls.length).toBeLessThanOrEqual(8);
  });
});
