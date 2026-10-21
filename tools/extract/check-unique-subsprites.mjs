import fs from 'node:fs';

const db = JSON.parse(fs.readFileSync('superfighters-web/src/data/generated/spriteDatabase.json', 'utf8'));
const subSpriteIds = new Set();

for (const char of Object.values(db.characters)) {
  for (const label of Object.values(char.labels)) {
    if (label.childId) {
      subSpriteIds.add(label.childId);
    }
  }
}

console.log('Total unique sub-sprite IDs across all characters:', subSpriteIds.size);
console.log('Sample IDs:', Array.from(subSpriteIds).slice(0, 20));
