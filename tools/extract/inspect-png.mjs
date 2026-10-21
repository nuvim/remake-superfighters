import fs from 'node:fs';
import zlib from 'node:zlib';

function parsePNG(filePath) {
  const buf = fs.readFileSync(filePath);
  const width = buf.readUInt32BE(16);
  const height = buf.readUInt32BE(20);
  const bitDepth = buf[24];
  const colorType = buf[25];

  console.log(`\n=== ${filePath} ===`);
  console.log(`Dimensions: ${width}x${height}, BitDepth: ${bitDepth}, ColorType: ${colorType}`);

  // Find IDAT chunk
  let pos = 33;
  const idatChunks = [];
  while (pos < buf.length) {
    const len = buf.readUInt32BE(pos);
    const type = buf.slice(pos + 4, pos + 8).toString('ascii');
    if (type === 'IDAT') {
      idatChunks.push(buf.slice(pos + 8, pos + 8 + len));
    }
    pos += 12 + len;
  }

  const compressedData = Buffer.concat(idatChunks);
  const rawData = zlib.inflateSync(compressedData);

  // Scanline bytes: (1 + width * 4) per row for RGBA
  const stride = 1 + width * 4;
  const alphaValues = new Set();
  let semiTransparentCount = 0;
  let fullyOpaqueCount = 0;
  let fullyTransparentCount = 0;

  for (let y = 0; y < height; y++) {
    const rowOffset = y * stride + 1; // skip filter byte
    for (let x = 0; x < width; x++) {
      const idx = rowOffset + x * 4;
      const a = rawData[idx + 3];
      alphaValues.add(a);
      if (a === 0) fullyTransparentCount++;
      else if (a === 255) fullyOpaqueCount++;
      else semiTransparentCount++;
    }
  }

  console.log(`Alpha stats: Fully opaque (255): ${fullyOpaqueCount}, Transparent (0): ${fullyTransparentCount}, Semi-transparent: ${semiTransparentCount}`);
}

parsePNG('superfighters-web/public/assets/sprites/DefineSprite_1236/1.png');
parsePNG('superfighters-web/public/assets/sprites/DefineSprite_1372_player_billy/1.png');
