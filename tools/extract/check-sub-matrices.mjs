import fs from 'node:fs';
import readline from 'node:readline';

const subSpriteIds = [1236, 1242, 1259, 1239, 1246, 1249, 1267, 1262, 1255, 1256];

async function checkSubSpriteMatrices() {
  const fileStream = fs.createReadStream('tools/extract/swf.xml', { encoding: 'utf-8' });
  const rl = readline.createInterface({ input: fileStream, crlfDelay: Infinity });

  let currentSpriteId = null;

  for await (const line of rl) {
    if (line.includes('type="DefineSpriteTag"')) {
      const m = line.match(/spriteId="(\d+)"/);
      if (m) {
        const id = parseInt(m[1], 10);
        if (subSpriteIds.includes(id)) {
          currentSpriteId = id;
          console.log(`\n=== SubSprite ${id} ===`);
        } else {
          currentSpriteId = null;
        }
      }
    }

    if (currentSpriteId && line.includes('<matrix type="MATRIX"')) {
      console.log(line.trim());
    }
  }
}

checkSubSpriteMatrices();
