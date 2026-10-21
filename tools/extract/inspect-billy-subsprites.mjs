import fs from 'node:fs';
import readline from 'node:readline';

const db = JSON.parse(fs.readFileSync('superfighters-web/src/data/generated/spriteDatabase.json', 'utf8'));
const billy = db.characters.player_billy;
const subIds = new Set();
for (const [label, def] of Object.entries(billy.labels)) {
  if (def.childId) subIds.add(def.childId);
}

console.log('Billy unique sub-sprite IDs:', Array.from(subIds));

async function getSubMatrices() {
  const fileStream = fs.createReadStream('tools/extract/swf.xml', { encoding: 'utf-8' });
  const rl = readline.createInterface({ input: fileStream, crlfDelay: Infinity });

  let curId = null;
  const results = {};

  for await (const line of rl) {
    if (line.includes('type="DefineSpriteTag"')) {
      const m = line.match(/spriteId="(\d+)"/);
      if (m) {
        const id = parseInt(m[1], 10);
        curId = subIds.has(id) ? id : null;
        if (curId) results[curId] = [];
      }
    }

    if (curId && line.includes('<matrix type="MATRIX"')) {
      const tx = line.match(/translateX="(-?\d+)"/);
      const ty = line.match(/translateY="(-?\d+)"/);
      const x = tx ? parseInt(tx[1], 10) / 20.0 : 0;
      const y = ty ? parseInt(ty[1], 10) / 20.0 : 0;
      results[curId].push({ x, y });
    }
  }

  for (const [id, mats] of Object.entries(results)) {
    console.log(`SubSprite ${id}: ${mats.length} matrices. First:`, mats[0]);
  }
}

getSubMatrices();
