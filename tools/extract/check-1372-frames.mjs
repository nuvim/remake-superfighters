import fs from 'node:fs';

const dir = 'superfighters-web/public/assets/sprites/DefineSprite_1372_player_billy';
const files = fs.readdirSync(dir).filter(f => f.endsWith('.png'));
console.log('Total frames in DefineSprite_1372_player_billy:', files.length);

import { execSync } from 'node:child_process';
// Let's check swf.xml for FrameLabelTag in 1372
import readline from 'node:readline';

async function listLabels() {
  const fileStream = fs.createReadStream('tools/extract/swf.xml', { encoding: 'utf-8' });
  const rl = readline.createInterface({ input: fileStream, crlfDelay: Infinity });

  let in1372 = false;
  let currentFrame = 1;
  const labels = [];

  for await (const line of rl) {
    if (line.includes('type="DefineSpriteTag"') && line.includes('spriteId="1372"')) {
      in1372 = true;
    }
    if (in1372) {
      if (line.includes('type="FrameLabelTag"')) {
        const m = line.match(/name="([^"]+)"/);
        if (m) labels.push({ frame: currentFrame, name: m[1] });
      }
      if (line.includes('type="ShowFrameTag"')) {
        currentFrame++;
      }
      if (line.includes('</subTags>')) break;
    }
  }

  console.log('Labels in 1372:', labels);
}

listLabels();
