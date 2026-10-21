import fs from 'node:fs';
import zlib from 'node:zlib';

function decodePNG(filePath) {
  const buf = fs.readFileSync(filePath);
  const width = buf.readUInt32BE(16);
  const height = buf.readUInt32BE(20);

  let pos = 33;
  const idatChunks = [];
  while (pos < buf.length) {
    const len = buf.readUInt32BE(pos);
    const type = buf.slice(pos + 4, pos + 8).toString('ascii');
    if (type === 'IDAT') idatChunks.push(buf.slice(pos + 8, pos + 8 + len));
    pos += 12 + len;
  }

  const raw = zlib.inflateSync(Buffer.concat(idatChunks));
  return { width, height, raw };
}

const billy1 = decodePNG('superfighters-web/public/assets/sprites/DefineSprite_1372_player_billy/1.png');
const sub1 = decodePNG('superfighters-web/public/assets/sprites/DefineSprite_1236/1.png');

console.log('Billy 1372/1:', billy1.width, 'x', billy1.height);
console.log('Sub 1236/1:', sub1.width, 'x', sub1.height);

// Let's print ASCII art of non-transparent pixels of sub1
console.log('\n--- ASCII ART of 1236/1.png ---');
for (let y = 0; y < sub1.height; y++) {
  let line = '';
  const rowOffset = y * (1 + sub1.width * 4) + 1;
  for (let x = 0; x < sub1.width; x++) {
    const a = sub1.raw[rowOffset + x * 4 + 3];
    const r = sub1.raw[rowOffset + x * 4];
    const g = sub1.raw[rowOffset + x * 4 + 1];
    const b = sub1.raw[rowOffset + x * 4 + 2];
    if (a === 0) {
      line += ' ';
    } else if (r === 0 && g === 0 && b === 0) {
      line += '#';
    } else {
      line += '.';
    }
  }
  console.log(line);
}

console.log('\n--- ASCII ART of 1372/1.png (cropped to content) ---');
for (let y = 16; y <= 37; y++) {
  let line = '';
  const rowOffset = y * (1 + billy1.width * 4) + 1;
  for (let x = 15; x <= 30; x++) {
    const a = billy1.raw[rowOffset + x * 4 + 3];
    const r = billy1.raw[rowOffset + x * 4];
    const g = billy1.raw[rowOffset + x * 4 + 1];
    const b = billy1.raw[rowOffset + x * 4 + 2];
    if (a === 0) {
      line += ' ';
    } else if (r === 0 && g === 0 && b === 0) {
      line += '#';
    } else {
      line += '.';
    }
  }
  console.log(line);
}
