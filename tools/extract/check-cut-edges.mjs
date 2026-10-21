import fs from 'node:fs';
import zlib from 'node:zlib';

const dir = 'superfighters-web/public/assets/sprites/DefineSprite_1236';
const files = fs.readdirSync(dir);

function checkEdgePixels(file) {
  const buf = fs.readFileSync(`${dir}/${file}`);
  const w = buf.readUInt32BE(16);
  const h = buf.readUInt32BE(20);

  let pos = 33;
  const idatChunks = [];
  while (pos < buf.length) {
    const len = buf.readUInt32BE(pos);
    const type = buf.slice(pos + 4, pos + 8).toString('ascii');
    if (type === 'IDAT') idatChunks.push(buf.slice(pos + 8, pos + 8 + len));
    pos += 12 + len;
  }

  const raw = zlib.inflateSync(Buffer.concat(idatChunks));
  const stride = 1 + w * 4;

  let leftCut = 0, rightCut = 0, topCut = 0, bottomCut = 0;

  for (let y = 0; y < h; y++) {
    const row = y * stride + 1;
    if (raw[row + 3] > 0) leftCut++;
    if (raw[row + (w - 1) * 4 + 3] > 0) rightCut++;
  }

  for (let x = 0; x < w; x++) {
    if (raw[1 + x * 4 + 3] > 0) topCut++;
    if (raw[(h - 1) * stride + 1 + x * 4 + 3] > 0) bottomCut++;
  }

  console.log(`${file}: w=${w}, h=${h}, right=${rightCut}, left=${leftCut}, top=${topCut}, bottom=${bottomCut}`);
}

files.slice(0, 5).forEach(checkEdgePixels);
