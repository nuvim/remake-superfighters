import fs from 'node:fs';
import readline from 'node:readline';

async function run() {
  const fileStream = fs.createReadStream('tools/extract/swf.xml', { encoding: 'utf-8' });
  const rl = readline.createInterface({ input: fileStream, crlfDelay: Infinity });

  let in1236 = false;
  let count = 0;

  for await (const line of rl) {
    if (line.includes('type="DefineSpriteTag"') && line.includes('spriteId="1236"')) {
      in1236 = true;
      console.log('--- FOUND 1236 ---');
    }

    if (in1236) {
      console.log(line);
      count++;
      if (count > 40 || line.includes('</subTags>')) {
        break;
      }
    }
  }
}

run();
