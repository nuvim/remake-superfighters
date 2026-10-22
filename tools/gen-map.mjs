import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const MAPS_AS_PATH = path.resolve(__dirname, '../decompiled/scripts/scripts/Code/Handler/Maps.as');
const OUTPUT_PATH = path.resolve(__dirname, '../superfighters-web/src/data/generated/storage.json');

// Map of default object sizes from MapPremadeItems.as:AddBox
const OBJECT_SIZES = {
  CRATE_HANGING: { width: 27, height: 14 },
  CRATE_HANGING_HOLDER: { width: 9, height: 6 },
  LAMP_1: { width: 20, height: 8 },
  LIFT_01: { width: 27, height: 6 },
  TABLE: { width: 33, height: 16 },
  CHAIR: { width: 14, height: 16 },
  CHAIR_R: { width: 14, height: 16 },
  DESK_1: { width: 33, height: 18 },
  COMFY_CHAIR: { width: 16, height: 18 },
  FILECAB: { width: 18, height: 26 },
  CRATE: { width: 20, height: 20 },
  BARREL: { width: 18, height: 22 },
  BARREL_EXPLOSIVE: { width: 18, height: 22 },
  GASCAN: { width: 14, height: 14 },
};

function parseMapsAS() {
  const content = fs.readFileSync(MAPS_AS_PATH, 'utf-8');
  
  // Find GenerateMapStorage function body
  const fnMatch = content.match(/private function GenerateMapStorage\(\)\s*:\s*void\s*\{([\s\S]*?)(?=\n\s*(?:private|public)\s+function|\n\s*\}\s*$)/);
  if (!fnMatch) {
    throw new Error('GenerateMapStorage not found in Maps.as');
  }
  const body = fnMatch[1];
  
  // 1. MapArea: this.mapArea = new Rectangle(23,-26,477,365);
  const mapAreaMatch = body.match(/this\.mapArea\s*=\s*new\s+Rectangle\(([^)]+)\)/);
  let mapArea = null;
  if (mapAreaMatch) {
    const [x, y, w, h] = mapAreaMatch[1].split(',').map(Number);
    mapArea = { x, y, width: w, height: h };
  }

  // 2. PlayerSpawns: new Point(130,247), ...
  const playerSpawns = [];
  const ptRegex = /new\s+Point\(\s*(-?[\d.]+)\s*,\s*(-?[\d.]+)\s*\)/g;
  const playerSpawnsMatch = body.match(/this\.playerSpawns\s*=\s*new\s+Array\(([\s\S]*?)\);/);
  if (playerSpawnsMatch) {
    let m;
    while ((m = ptRegex.exec(playerSpawnsMatch[1])) !== null) {
      playerSpawns.push({ x: Number(m[1]), y: Number(m[2]) });
    }
  }

  // 3. WeaponSpawns: new WeaponSpawnData(197,161,new Array(1,1,...))
  const weaponSpawns = [];
  const wpnRegex = /new\s+WeaponSpawnData\(\s*(-?[\d.]+)\s*,\s*(-?[\d.]+)\s*,\s*new\s+Array\(([^)]+)\)\)/g;
  let wm;
  while ((wm = wpnRegex.exec(body)) !== null) {
    weaponSpawns.push({
      x: Number(wm[1]),
      y: Number(wm[2]),
      chances: wm[3].split(',').map(v => Number(v.trim()))
    });
  }

  // 4. Portals: new PortalData(new Rectangle(...), new Rectangle(...), new Point(...), bool, bool)
  const portals = [];
  const portalRegex = /new\s+PortalData\(\s*new\s+Rectangle\(([^)]+)\)\s*,\s*new\s+Rectangle\(([^)]+)\)\s*,\s*new\s+Point\(([^)]+)\)\s*,\s*(true|false)\s*,\s*(true|false)\s*\)/g;
  let pm;
  while ((pm = portalRegex.exec(body)) !== null) {
    const r1 = pm[1].split(',').map(Number);
    const r2 = pm[2].split(',').map(Number);
    const d = pm[3].split(',').map(Number);
    portals.push({
      rect1: { x: r1[0], y: r1[1], width: r1[2], height: r1[3] },
      rect2: { x: r2[0], y: r2[1], width: r2[2], height: r2[3] },
      dir: { x: d[0], y: d[1] },
      allowPlayers: pm[4] === 'true',
      allowObjects: pm[5] === 'true'
    });
  }

  // Track created bodies for references like crate_hanging_1.GetPosition()
  const bodies = {};

  const evalNum = (expr) => {
    // Inject known bodies and b2 helpers
    const ctx = {
      ...bodies,
      Math,
      b2Vec2: class { constructor(x=0, y=0) { this.x = x; this.y = y; } }
    };
    const fn = new Function(...Object.keys(ctx), `"use strict"; return (${expr});`);
    return fn(...Object.values(ctx));
  };

  // Helper for IncreaseCorners (MapPremadeItems.as:2807)
  const increaseCorners = (verts) => {
    return verts.map(([vx, vy]) => {
      let x = vx;
      let y = vy;
      if (x < 0) x -= 0.5 / 30;
      else if (x > 0) x += 0.5 / 30;
      if (y < 0) y -= 0.5 / 30;
      else if (y > 0) y += 0.5 / 30;
      return [x, y];
    });
  };

  // 5. CreateGroundBox
  const groundBoxes = [];
  const boxRegex = /(?:(\w+)\s*=\s*)?this\.Handler_WorldItems\.CreateGroundBox\(\s*this\.Handler_WorldItems\.Material\.(\w+)\s*,\s*([^,]+)\s*,\s*([^,]+)\s*,\s*([^,]+)\s*,\s*([^,]+)\s*,\s*([^,]+)\s*,\s*new\s+Array\(([^)]+)\)\s*\);(?:\s*\n\s*\1\.GetUserData\(\)\.tiltValue\s*=\s*(-?\d+);)?/g;
  let bm;
  while ((bm = boxRegex.exec(body)) !== null) {
    const varName = bm[1] || null;
    const material = bm[2];
    const x = evalNum(bm[3]);
    const y = evalNum(bm[4]);
    const angle = evalNum(bm[5]);
    const rawWidth = evalNum(bm[6]);
    const rawHeight = evalNum(bm[7]);
    const tags = bm[8].split(',').map(s => s.replace(/["'\s]/g, ''));
    const tiltValue = bm[9] ? Number(bm[9]) : 0;

    // In MapPremadeItems.as:171-172:
    const widthExpanded = rawWidth + 0.5 / 30;
    const heightExpanded = rawHeight + 0.5 / 30;

    const boxObj = {
      varName,
      material,
      x,
      y,
      angle,
      rawWidth,
      rawHeight,
      widthExpanded,
      heightExpanded,
      tags,
      tiltValue
    };
    groundBoxes.push(boxObj);

    if (varName) {
      bodies[varName] = {
        GetPosition: () => ({ x, y }),
        GetUserData: () => ({ width: rawWidth * 30, height: rawHeight * 30, tiltValue })
      };
    }
  }

  // 6. CreateGroundPolygon
  const groundPolygons = [];
  const polyRegex = /(\w+)\s*=\s*this\.Handler_WorldItems\.CreateGroundPolygon\(\s*this\.Handler_WorldItems\.Material\.(\w+)\s*,\s*([^,]+)\s*,\s*([^,]+)\s*,\s*([^,]+)\s*,\s*new\s+Array\(([\s\S]*?)\)\s*,\s*new\s+Array\(([^)]+)\)\s*\);(?:\s*\n\s*\1\.GetUserData\(\)\.tiltValue\s*=\s*(-?\d+);)?/g;
  let pym;
  while ((pym = polyRegex.exec(body)) !== null) {
    const varName = pym[1];
    const material = pym[2];
    const x = evalNum(pym[3]);
    const y = evalNum(pym[4]);
    const angle = evalNum(pym[5]);
    
    const rawVertsStr = pym[6];
    const vertMatches = [...rawVertsStr.matchAll(/\[([^,]+),\s*([^\]]+)\]/g)];
    const rawVertices = vertMatches.map(m => [evalNum(m[1]), evalNum(m[2])]);
    const expandedVertices = increaseCorners(rawVertices);
    
    const tags = pym[7].split(',').map(s => s.replace(/["'\s]/g, ''));
    const tiltValue = pym[8] ? Number(pym[8]) : 0;

    const polyObj = {
      varName,
      material,
      x,
      y,
      angle,
      rawVertices,
      expandedVertices,
      tags,
      tiltValue
    };
    groundPolygons.push(polyObj);

    if (varName) {
      bodies[varName] = {
        GetPosition: () => ({ x, y }),
        GetUserData: () => ({ tiltValue })
      };
    }
  }

  // 7. AddObject
  const objects = [];
  const objRegex = /(?:(\w+)\s*=\s*)?this\.Handler_WorldItems\.AddObject\(\s*"([^"]+)"\s*,\s*([^,]+)\s*,\s*([^,]+)\s*,\s*([^,]+)\s*,\s*new\s+b2Vec2\([^)]*\)\s*,\s*([^)]+)\s*\);/g;
  let om;
  while ((om = objRegex.exec(body)) !== null) {
    const varName = om[1] || null;
    const typeString = om[2];
    const x = evalNum(om[3]);
    const y = evalNum(om[4]);
    const angle = evalNum(om[5]);
    const param6 = evalNum(om[6]);

    const primaryType = typeString.split(',')[0];
    const sz = OBJECT_SIZES[primaryType] || { width: 20, height: 20 };

    objects.push({
      varName,
      typeString,
      primaryType,
      x,
      y,
      angle,
      param6,
      pixelWidth: sz.width,
      pixelHeight: sz.height
    });

    if (varName) {
      bodies[varName] = {
        GetPosition: () => ({ x, y }),
        GetUserData: () => ({ width: sz.width, height: sz.height })
      };
    }
  }

  return {
    mapName: 'STORAGE',
    mapArea,
    playerSpawns,
    weaponSpawns,
    portals,
    groundBoxes,
    groundPolygons,
    objects
  };
}

const mapData = parseMapsAS();

// Write to JSON
fs.mkdirSync(path.dirname(OUTPUT_PATH), { recursive: true });
fs.writeFileSync(OUTPUT_PATH, JSON.stringify(mapData, null, 2), 'utf-8');

console.log(`Successfully generated ${OUTPUT_PATH}`);
console.log(`Map: ${mapData.mapName}`);
console.log(`- Player Spawns: ${mapData.playerSpawns.length}`);
console.log(`- Weapon Spawns: ${mapData.weaponSpawns.length}`);
console.log(`- Portals: ${mapData.portals.length}`);
console.log(`- Ground Boxes: ${mapData.groundBoxes.length}`);
console.log(`- Ground Polygons: ${mapData.groundPolygons.length}`);
console.log(`- Dynamic Objects: ${mapData.objects.length}`);
