import fs from 'node:fs';

const sprites = fs.readdirSync('superfighters-web/public/assets/sprites');
console.log('Total sprite folders:', sprites.length);

const playerFolders = sprites.filter(s => s.includes('player'));
console.log('Player folders:', playerFolders);
