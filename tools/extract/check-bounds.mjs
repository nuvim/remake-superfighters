import fs from 'node:fs';
import zlib from 'node:zlib';

function getPixelBounds(filePath) {
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
  const stride = 1 + width * 4;

  let minX = width, maxX = 0, minY = height, maxY = 0;

  for (let y = 0; y < height; y++) {
    const rowOffset = y * stride + 1;
    for (let x = 0; x < width; x++) {
      const a = raw[rowOffset + x * 4 + 3];
      if (a > 0) {
        if (x < minX) minX = x;
        if (x > maxX) maxX = x;
        if (y < minY) minY = y;
        if (y > maxY) maxY = y;
      }
    }
  }

  console.log(`${filePath} bounds: [x: ${minX}..${maxX}, y: ${minY}..${maxY}], width: ${maxX - minX + 1}, height: ${maxY - minY + 1}`);
}

getPixelBounds('superfighters-web/public/assets/sprites/DefineSprite_1372_player_billy/1.png');
getPixelBounds('superfighters-web/public/assets/sprites/DefineSprite_1372_player_billy/2.png');
getPixelBounds('superfighters-web/public/assets/sprites/DefineSprite_1372_player_billy/3.png');
getPixelBounds('superfighters-web/public/assets/sprites/DefineSprite_1372_player_billy/4.png');
