import { describe, it, expect } from 'vitest';
import * as fs from 'node:fs';
import * as path from 'node:path';
import storageJson from '../src/data/generated/storage.json';

describe('StorageMap generated data parity against Maps.as', () => {
  const mapsAsPath = path.resolve(__dirname, '../../decompiled/scripts/scripts/Code/Handler/Maps.as');
  const mapsContent = fs.readFileSync(mapsAsPath, 'utf-8');

  const fnMatch = mapsContent.match(/private function GenerateMapStorage\(\)\s*:\s*void\s*\{([\s\S]*?)(?=\n\s*(?:private|public)\s+function|\n\s*\}\s*$)/);
  const body = fnMatch ? fnMatch[1] : '';

  it('matches exact count of CreateGroundBox calls', () => {
    const boxCalls = (body.match(/this\.Handler_WorldItems\.CreateGroundBox/g) || []).length;
    expect(storageJson.groundBoxes.length).toBe(boxCalls);
    expect(storageJson.groundBoxes.length).toBe(24);
  });

  it('matches exact count of CreateGroundPolygon calls', () => {
    const polyCalls = (body.match(/this\.Handler_WorldItems\.CreateGroundPolygon/g) || []).length;
    expect(storageJson.groundPolygons.length).toBe(polyCalls);
    expect(storageJson.groundPolygons.length).toBe(2);
  });

  it('matches exact count of AddObject calls', () => {
    const objCalls = (body.match(/this\.Handler_WorldItems\.AddObject/g) || []).length;
    expect(storageJson.objects.length).toBe(objCalls);
    expect(storageJson.objects.length).toBe(51);
  });

  it('matches exact count of Player and Weapon spawns and Portals', () => {
    const playerSpawnsMatch = body.match(/this\.playerSpawns\s*=\s*new\s+Array\(([\s\S]*?)\);/);
    const playerSpawnsCount = (playerSpawnsMatch ? playerSpawnsMatch[1].match(/new\s+Point/g) || [] : []).length;
    expect(storageJson.playerSpawns.length).toBe(playerSpawnsCount);
    expect(storageJson.playerSpawns.length).toBe(26);

    const wpnCalls = (body.match(/new\s+WeaponSpawnData/g) || []).length;
    expect(storageJson.weaponSpawns.length).toBe(wpnCalls);
    expect(storageJson.weaponSpawns.length).toBe(6);

    const portalCalls = (body.match(/new\s+PortalData/g) || []).length;
    expect(storageJson.portals.length).toBe(portalCalls);
    expect(storageJson.portals.length).toBe(2);
  });

  it('verifies polygons have IncreaseCorners applied (+0.5/30 px)', () => {
    // stair02: raw [-16/30, -39/30] -> expanded [-16.5/30, -39.5/30]
    const stair02 = storageJson.groundPolygons.find(p => p.varName === 'stair02');
    expect(stair02).toBeDefined();
    expect(stair02!.expandedVertices[0][0]).toBeCloseTo(-16.5 / 30, 5);
    expect(stair02!.expandedVertices[0][1]).toBeCloseTo(-39.5 / 30, 5);
    expect(stair02!.tiltValue).toBe(2);

    // stair01: raw [14/30, 37/30] -> expanded [14.5/30, 37.5/30]
    const stair01 = storageJson.groundPolygons.find(p => p.varName === 'stair01');
    expect(stair01).toBeDefined();
    expect(stair01!.expandedVertices[3][0]).toBeCloseTo(14.5 / 30, 5);
    expect(stair01!.expandedVertices[3][1]).toBeCloseTo(37.5 / 30, 5);
    expect(stair01!.tiltValue).toBe(-2);
  });
});
