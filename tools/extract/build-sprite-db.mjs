import fs from 'node:fs';
import path from 'node:path';
import readline from 'node:readline';

const XML_PATH = path.resolve('tools/extract/swf.xml');
const SPRITES_DIR = path.resolve('decompiled/assets/sprites');
const OUTPUT_DIR = path.resolve('superfighters-web/src/data/generated');
const OUTPUT_FILE = path.join(OUTPUT_DIR, 'spriteDatabase.json');

// Personagens conhecidos por ID e nome
const CHARACTER_SPRITES = {
  1372: 'player_billy',
  799: 'player_boris',
  649: 'player_johnny',
  1513: 'player_scott',
  1686: 'player_funnyman',
  1827: 'player_mac',
  1968: 'player_jeff',
  1162: 'player_agent',
  409: 'player_hitarea'
};

async function main() {
  console.log(`[build-sprite-db] Lendo XML de ${XML_PATH}...`);

  if (!fs.existsSync(XML_PATH)) {
    console.error(`Erro: Arquivo XML não encontrado em ${XML_PATH}`);
    process.exit(1);
  }

  const fileStream = fs.createReadStream(XML_PATH, { encoding: 'utf-8' });
  const rl = readline.createInterface({
    input: fileStream,
    crlfDelay: Infinity
  });

  const sprites = {};
  let currentSprite = null;
  let currentFrameIndex = 0;
  let currentFrameLabel = null;
  let currentPlaceObject = null;

  for await (const line of rl) {
    const trimmed = line.trim();

    // Início de DefineSpriteTag
    if (trimmed.includes('type="DefineSpriteTag"')) {
      const idMatch = trimmed.match(/spriteId="(\d+)"/);
      const framesMatch = trimmed.match(/frameCount="(\d+)"/);
      if (idMatch && framesMatch) {
        const spriteId = parseInt(idMatch[1], 10);
        const frameCount = parseInt(framesMatch[1], 10);
        currentSprite = {
          spriteId,
          frameCount,
          frames: [],
          labels: {}
        };
        currentFrameIndex = 1;
        currentFrameLabel = null;
        continue;
      }
    }

    if (!currentSprite) continue;

    // Fim de DefineSpriteTag
    if (trimmed === '</subTags>' || trimmed === '</item>') {
      // Checar se a tag atual fechou o sprite
      if (trimmed === '</item>' && currentSprite.subTagsClosed) {
        sprites[currentSprite.spriteId] = currentSprite;
        currentSprite = null;
        continue;
      }
      if (trimmed === '</subTags>') {
        currentSprite.subTagsClosed = true;
      }
    }

    // FrameLabelTag
    const labelMatch = trimmed.match(/<item type="FrameLabelTag"[^>]*name="([^"]+)"/);
    if (labelMatch) {
      currentFrameLabel = labelMatch[1].toUpperCase();
      continue;
    }

    // PlaceObject2Tag
    const placeMatch = trimmed.match(/<item type="PlaceObject2Tag"[^>]*characterId="(\d+)"[^>]*depth="(\d+)"(?:[^>]*name="([^"]+)")?/);
    if (placeMatch) {
      currentPlaceObject = {
        characterId: parseInt(placeMatch[1], 10),
        depth: parseInt(placeMatch[2], 10),
        name: placeMatch[3] || null,
        matrix: { x: 0, y: 0, scaleX: 1, scaleY: 1, rotation: 0 }
      };
      continue;
    }

    // Matrix dentro de PlaceObject2Tag
    if (currentPlaceObject) {
      const matrixMatch = trimmed.match(/<matrix[^>]*scaleX="([^"]+)"[^>]*scaleY="([^"]+)"[^>]*translateX="([^"]+)"[^>]*translateY="([^"]+)"/);
      if (matrixMatch) {
        currentPlaceObject.matrix.scaleX = parseFloat(matrixMatch[1]);
        currentPlaceObject.matrix.scaleY = parseFloat(matrixMatch[2]);
        // Em SWF, translateX e translateY estão em twips (1 pixel = 20 twips)
        currentPlaceObject.matrix.x = parseFloat(matrixMatch[3]) / 20.0;
        currentPlaceObject.matrix.y = parseFloat(matrixMatch[4]) / 20.0;
      }
    }

    // ShowFrameTag — avança o frame
    if (trimmed.startsWith('<item type="ShowFrameTag"')) {
      const frameData = {
        frameNumber: currentFrameIndex,
        label: currentFrameLabel,
        child: currentPlaceObject ? { ...currentPlaceObject } : null
      };

      if (currentFrameLabel) {
        currentSprite.labels[currentFrameLabel] = {
          frameNumber: currentFrameIndex,
          childId: currentPlaceObject?.characterId || null,
          childName: currentPlaceObject?.name || null,
          matrix: currentPlaceObject?.matrix || null
        };
      }

      currentSprite.frames.push(frameData);
      currentFrameIndex++;
      currentFrameLabel = null;
      currentPlaceObject = null;
    }
  }

  console.log(`[build-sprite-db] Processamento concluído. Encontrados ${Object.keys(sprites).length} sprites.`);

  // Validar frames existentes no disco para cada sub-sprite
  const spriteFrameCounts = {};
  for (const dirName of fs.readdirSync(SPRITES_DIR)) {
    const match = dirName.match(/^DefineSprite_(\d+)/);
    if (match) {
      const id = parseInt(match[1], 10);
      const fullPath = path.join(SPRITES_DIR, dirName);
      if (fs.statSync(fullPath).isDirectory()) {
        const files = fs.readdirSync(fullPath).filter(f => f.endsWith('.png'));
        spriteFrameCounts[id] = {
          dirName,
          frameCount: files.length,
          files: files.sort((a, b) => parseInt(a) - parseInt(b))
        };
      }
    }
  }

  // Montar banco de dados final focado nos lutadores
  const database = {
    generatedAt: new Date().toISOString(),
    characters: {},
    subSprites: {}
  };

  for (const [idStr, charName] of Object.entries(CHARACTER_SPRITES)) {
    const id = parseInt(idStr, 10);
    const sprite = sprites[id];
    if (sprite) {
      database.characters[charName] = {
        spriteId: id,
        frameCount: sprite.frameCount,
        labels: sprite.labels
      };

      // Registrar os sub-sprites referenciados
      for (const [label, info] of Object.entries(sprite.labels)) {
        if (info.childId && spriteFrameCounts[info.childId]) {
          database.subSprites[info.childId] = {
            spriteId: info.childId,
            dirName: spriteFrameCounts[info.childId].dirName,
            frameCount: spriteFrameCounts[info.childId].frameCount,
            basePath: `/assets/sprites/${spriteFrameCounts[info.childId].dirName}/`
          };
        }
      }
    }
  }

  // Garantir diretório de saída
  if (!fs.existsSync(OUTPUT_DIR)) {
    fs.mkdirSync(OUTPUT_DIR, { recursive: true });
  }

  fs.writeFileSync(OUTPUT_FILE, JSON.stringify(database, null, 2), 'utf-8');
  console.log(`[build-sprite-db] Salvo em ${OUTPUT_FILE}`);
  console.log(`[build-sprite-db] Billy labels mapeadas: ${Object.keys(database.characters['player_billy']?.labels || {}).length}`);
}

main().catch(err => {
  console.error('[build-sprite-db] Falha:', err);
  process.exit(1);
});
