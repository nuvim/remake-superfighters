import * as planck from 'planck';
import { Application, Assets, Texture, TextureSource } from 'pixi.js';
import { Camera } from './engine/Camera';
import { DisplayLayers } from './engine/DisplayLayers';
import { GameLoop } from './engine/GameLoop';
import { StorageMap } from './stage/StorageMap';
import './style.css';

// -------------------------------------------------------------------------
// REGRA ESTRITA 1: scaleMode = 'nearest' por padrão no PixiJS v8
// para manter a pixel art perfeitamente nítida, sem nenhum blur bilinear.
// -------------------------------------------------------------------------
TextureSource.defaultOptions.scaleMode = 'nearest';

async function bootstrap() {
  const container = document.getElementById('canvas-container')!;
  const camInfo = document.getElementById('cam-info')!;
  const physicsInfo = document.getElementById('physics-info')!;
  const modeInfo = document.getElementById('mode-info')!;

  // 1. Inicializar PixiJS v8 Application (800x600 - resolução canônica do Flash)
  const app = new Application();
  await app.init({
    width: 800,
    height: 600,
    backgroundColor: 0x000000,
    resolution: 1,
    antialias: false,
    roundPixels: true,
  });

  container.appendChild(app.canvas);

  // 2. Carregar texturas autênticas de decompiled/assets/
  const [bgTexture, crateTexture, barrelExpTexture, barrelTexture] = await Promise.all([
    Assets.load<Texture>('/assets/images/28.png'),
    Assets.load<Texture>('/assets/sprites/DefineSprite_50_crate_01/1.png'),
    Assets.load<Texture>('/assets/sprites/DefineSprite_47_barrel_01/1.png'),
    Assets.load<Texture>('/assets/sprites/DefineSprite_75_barrel_02/1.png'),
  ]);

  // Garantir amostragem nearest em cada textura carregada
  bgTexture.source.scaleMode = 'nearest';
  crateTexture.source.scaleMode = 'nearest';
  barrelExpTexture.source.scaleMode = 'nearest';
  barrelTexture.source.scaleMode = 'nearest';

  // 3. Montar DisplayList 1:1 com o Flash (GameMain.as:250-305)
  const layers = new DisplayLayers(app.stage);

  // 4. Criar mundo físico Planck.js (Box2D) com gravidade exata (0, 10.0) de Maps.as:118
  const world = new planck.World({
    gravity: planck.Vec2(0, 10.0),
  });

  // 5. Instanciar o mapa Storage (geometrias e itens copiados de Maps.as)
  const texturesMap = {
    CRATE: crateTexture,
    BARREL_EXPLOSIVE: barrelExpTexture,
    BARREL: barrelTexture,
  };

  const storageMap = new StorageMap(
    world,
    bgTexture,
    texturesMap,
    layers.levelLayer,
    layers.objectsLayer
  );

  // 6. Instanciar a Câmera 1:1 com Cam.as
  const camera = new Camera(layers.dynamicMc, layers.shakeContainer, storageMap.mapArea);

  // 7. Configurar Controles Interativos de Câmera e Debug
  let isDragging = false;
  let dragStart = { x: 0, y: 0 };

  app.canvas.addEventListener('mousedown', (e) => {
    isDragging = true;
    dragStart = { x: e.clientX, y: e.clientY };
  });

  window.addEventListener('mouseup', () => {
    isDragging = false;
  });

  window.addEventListener('mousemove', (e) => {
    if (!isDragging) return;
    const dx = e.clientX - dragStart.x;
    const dy = e.clientY - dragStart.y;
    camera.manualPan(dx, dy);
    dragStart = { x: e.clientX, y: e.clientY };
  });

  app.canvas.addEventListener('wheel', (e) => {
    e.preventDefault();
    const factor = e.deltaY < 0 ? 1.1 : 0.9;
    camera.manualZoom(factor);
  }, { passive: false });

  window.addEventListener('keydown', (e) => {
    const key = e.key.toUpperCase();
    if (key === 'H') {
      const active = storageMap.toggleHitboxes();
      modeInfo.textContent = `Hitboxes: ${active ? 'VISÍVEIS [Magenta=Solo, Ciano=Cloud, Amarelo=Ladder]' : 'OCULTAS'}`;
    } else if (key === ' ' || e.code === 'Space') {
      camera.resetCamera();
      modeInfo.textContent = 'Camera: AUTO-FOCUS (Resetada para o enquadramento do mapa)';
    } else if (e.key === 'ArrowLeft' || key === 'A') {
      camera.manualPan(20, 0);
    } else if (e.key === 'ArrowRight' || key === 'D') {
      camera.manualPan(-20, 0);
    } else if (e.key === 'ArrowUp' || key === 'W') {
      camera.manualPan(0, 20);
    } else if (e.key === 'ArrowDown' || key === 'S') {
      camera.manualPan(0, -20);
    } else if (key === 'Z') {
      camera.manualZoom(1.15);
    } else if (key === 'X') {
      camera.manualZoom(0.85);
    }
  });

  // 8. Game Loop com lógica a 30 Hz fixo (GameMain.as:847, m_timeStep = 1/30)
  // e m_iterations = 20 (GameMain.as:152)
  const VELOCITY_ITERATIONS = 10;
  const POSITION_ITERATIONS = 10;

  const gameLoop = new GameLoop();
  gameLoop.onLogicUpdate = (dt) => {
    // Passo físico Box2D Planck.js a 30 Hz fixo
    world.step(dt, VELOCITY_ITERATIONS, POSITION_ITERATIONS);

    // Sincronizar posições dos itens dinâmicos
    storageMap.update();

    // Atualizar câmera
    camera.update(1.0);
  };

  gameLoop.onRender = () => {
    // Atualizar overlay de debug com dados de desempenho reais
    const camPos = camera.currentPosition;
    camInfo.textContent = `Cam Pos: (${Math.round(camPos.x)}, ${Math.round(camPos.y)}) | Zoom: ${camera.currentScale.toFixed(2)}x | Modo: ${camera.isManualControl ? 'MANUAL' : 'AUTO-FOCUS'}`;
    physicsInfo.textContent = `Logic: ${gameLoop.logicHz} Hz (Fixed 30Hz) | Render: ${gameLoop.renderFps} FPS | Bodies: ${world.getBodyCount()} | PTM: 30.0`;
  };

  gameLoop.start();

  app.ticker.add(() => {
    gameLoop.update(performance.now());
  });
}

bootstrap().catch((err) => {
  console.error('Erro ao inicializar Superfighters Remake:', err);
});
