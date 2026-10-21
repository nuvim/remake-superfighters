import fs from 'node:fs';
import readline from 'node:readline';

async function run() {
  const target = process.argv[2] || '1233';
  const fileStream = fs.createReadStream('tools/extract/swf.xml', { encoding: 'utf-8' });
  const rl = readline.createInterface({ input: fileStream, crlfDelay: Infinity });

  let found = false;
  let count = 0;

  for await (const line of rl) {
    if (line.includes(`shapeId="${target}"`)) {
      found = true;
    }
    if (found) {
      console.log(line);
      count++;
      if (count > 25) break;
    }
  }
}

run();
