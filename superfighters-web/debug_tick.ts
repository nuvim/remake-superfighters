import * as planck from 'planck';
import { Container, Texture } from 'pixi.js';
import { StorageMap } from './src/stage/StorageMap';
import { Player } from './src/player/Player';

const world = new planck.World();
const dummyTexture = Texture.EMPTY;
const dummyLayer = new Container();
const map = new StorageMap(world, dummyTexture, {}, dummyLayer, dummyLayer);

const player = new Player(dummyTexture, 60, 255);
player.playerLands(255);

for (let tick = 0; tick < 50; tick++) {
  const beforeX = player.state.posX;
  const beforeY = player.state.posY;
  player.movePlayer(1, 1.7, map);
  if (!player.state.isGrounded) {
    console.log(`Failed at tick ${tick}: posX=${player.state.posX}, posY=${player.state.posY}`);
    console.log(`Before tick: x=${beforeX}, y=${beforeY}`);
    console.log(`collisionFeetMid(0, 1): ${player.collisionFeetMid(0, 1, map)}`);
    console.log(`canLandInMid: ${player.canLandInMid(map)}`);
    console.log(`collisionFeetSides: ${player.collisionFeetSides(0, map)}`);
    for (let loc1 = 0; loc1 <= 6; loc1 += 2) {
      console.log(`  hitTestWorld(${player.state.posX}, ${player.state.posY + loc1}): ${map.hitTestWorld(player.state.posX, player.state.posY + loc1)}`);
    }
    break;
  }
}
