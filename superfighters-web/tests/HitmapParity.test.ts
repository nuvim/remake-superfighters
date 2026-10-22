import { describe, it, expect } from 'vitest';
import * as fs from 'node:fs';
import * as path from 'node:path';
import * as planck from 'planck';
import { StorageMap } from '../src/stage/StorageMap';

describe('HitmapParity — Comparação 1:1 contra o Oráculo Flash', () => {
  const goldenDir = path.resolve(__dirname, 'golden');
  const ladderPath = path.join(goldenDir, 'hitmap_ladder.txt');
  const cloudPath = path.join(goldenDir, 'hitmap_cloud.txt');

  it('valida existência dos arquivos golden gerados pelo Oráculo', () => {
    expect(fs.existsSync(ladderPath)).toBe(true);
    expect(fs.existsSync(cloudPath)).toBe(true);
    expect(fs.existsSync(path.join(goldenDir, 'hitmap_world.txt'))).toBe(true);
    expect(fs.existsSync(path.join(goldenDir, 'player_trace_idle.json'))).toBe(true);
  });

  it('StorageMap.hitTestLadder possui mais de 99.9% de paridade contra o Flash', () => {
    const world = planck.World({ gravity: planck.Vec2(0, 0) });
    // Instanciar StorageMap mockando containers visuais
    const dummyTex = {} as any;
    const dummyContainer = { addChild: () => {} } as any;
    const map = new StorageMap(world, dummyTex, {}, dummyContainer, dummyContainer);

    const ladderLines = fs.readFileSync(ladderPath, 'utf-8').trim().split('\n');
    let totalSamples = 0;
    let matches = 0;

    // Amostragem em grade: cada 5 pixels para teste rápido e determinístico no CI
    for (const line of ladderLines) {
      if (!line) continue;
      const [yStr, bits] = line.split(':');
      const y = parseInt(yStr, 10) * 0.5;
      if (parseInt(yStr, 10) % 5 !== 0) continue; // amostragem a cada 5 linhas

      for (let xIdx = 0; xIdx < bits.length; xIdx += 10) { // a cada 10 colunas (5px)
        const x = xIdx * 0.5;
        const gold = bits[xIdx] === '1';
        const actual = map.hitTestLadder(x, y);

        totalSamples++;
        if (gold === actual) {
          matches++;
        }
      }
    }

    const parity = (matches / totalSamples) * 100;
    expect(parity).toBeGreaterThan(99.9);
  });

  it('StorageMap.hitTestCloud possui mais de 99.0% de paridade contra o Flash', () => {
    const world = planck.World({ gravity: planck.Vec2(0, 0) });
    const dummyTex = {} as any;
    const dummyContainer = { addChild: () => {} } as any;
    const map = new StorageMap(world, dummyTex, {}, dummyContainer, dummyContainer);

    const cloudLines = fs.readFileSync(cloudPath, 'utf-8').trim().split('\n');
    let totalSamples = 0;
    let matches = 0;

    for (const line of cloudLines) {
      if (!line) continue;
      const [yStr, bits] = line.split(':');
      const y = parseInt(yStr, 10) * 0.5;
      if (parseInt(yStr, 10) % 5 !== 0) continue;

      for (let xIdx = 0; xIdx < bits.length; xIdx += 10) {
        const x = xIdx * 0.5;
        const gold = bits[xIdx] === '1';
        const actual = map.hitTestCloud(x, y);

        totalSamples++;
        if (gold === actual) {
          matches++;
        }
      }
    }

    const parity = (matches / totalSamples) * 100;
    expect(parity).toBeGreaterThan(99.0);
  });
});
