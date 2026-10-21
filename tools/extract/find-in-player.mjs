import fs from 'node:fs';
import readline from 'node:readline';

const query = process.argv[2];
if (!query) {
  console.log('Uso: node find-in-player.mjs <query>');
  process.exit(1);
}

const fileStream = fs.createReadStream('decompiled/scripts/scripts/Code/Data/Players/Player.as', { encoding: 'utf-8' });
const rl = readline.createInterface({ input: fileStream, crlfDelay: Infinity });

let lineNum = 0;
let matches = 0;

for await (const line of rl) {
  lineNum++;
  if (line.toLowerCase().includes(query.toLowerCase())) {
    console.log(`${lineNum}: ${line.trim()}`);
    matches++;
    if (matches >= 30) break;
  }
}
console.log(`Total de ocorrências: ${matches}`);
