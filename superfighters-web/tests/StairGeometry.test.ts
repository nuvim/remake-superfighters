// tests/StairGeometry.test.ts
import { describe, it, expect } from 'vitest';
import * as planck from 'planck';
import { Container, Texture } from 'pixi.js';
import { StorageMap } from '../src/stage/StorageMap';

// IncreaseCorners (MapPremadeItems.as:2807)
const inc = (v: number) => (v < 0 ? v - 0.5 / 30 : v > 0 ? v + 0.5 / 30 : v);
const expected = (cx: number, cy: number, verts: [number, number][]) =>
  verts.map(([x, y]) => [cx + inc(x / 30) * 30, cy + inc(y / 30) * 30]);

const sortXY = (a: number[][]) => [...a].sort((p, q) => p[0] - q[0] || p[1] - q[1]);

describe('stairs: pixel polygons == AS3 IncreaseCorners', () => {
  const m = new StorageMap(new planck.World(), Texture.EMPTY, {}, new Container(), new Container());
  const stair02 = expected(143, 294, [[-16,-39],[-10,-39],[14,-21],[14,35],[-16,35]]);
  const stair01 = expected(320, 292, [[-16,-19],[8,-37],[14,-37],[14,37],[-16,37]]);

  it.each([[0, stair02], [1, stair01]])('poly %i', (i, exp) => {
    const got = sortXY(m.staticPolysPixel[i as number] as number[][]);
    const want = sortXY(exp as number[][]);
    got.forEach((p, k) => {
      expect(p[0]).toBeCloseTo(want[k][0], 3);
      expect(p[1]).toBeCloseTo(want[k][1], 3);
    });
  });
});
