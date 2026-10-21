import * as planck from 'planck';
import { Application, Assets, Texture, TextureSource } from 'pixi.js';
import { Camera } from './engine/Camera';
import { DisplayLayers } from './engine/DisplayLayers';
import { GameLoop } from './engine/GameLoop';
import { InputManager } from './engine/Input';
import { Player } from './player/Player';
import { StorageMap } from './stage/StorageMap';
import './style.css';

// -------------------------------------------------------------------------
// REGRA ESTRITA 1: scaleMode = 'nearest' por padrão no PixiJS v8
// para manter a pixel art perfeitamente nítida, sem nenhum blur bilinear.
// -------------------------------------------------------------------------
TextureSource.defaultOptions.scaleMode = 'nearest';

async function bootstrap() {
  const container = document.getElementById('canvas-container')!;
  const playerInfo = document.getElementById('player-info')!;
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
  const [bgTexture, crateTexture, barrelExpTexture, barrelTexture, billyTexture] = await Promise.all([
    Assets.load<Texture>('/assets/images/28.png'),
    Assets.load<Texture>('/assets/sprites/DefineSprite_50_crate_01/1.png'),
    Assets.load<Texture>('/assets/sprites/DefineSprite_47_barrel_01/1.png'),
    Assets.load<Texture>('/assets/sprites/DefineSprite_75_barrel_02/1.png'),
    Assets.load<Texture>('/assets/sprites/DefineSprite_1372_player_billy/1.png'),
  ]);

  // Garantir amostragem nearest em cada textura carregada
  bgTexture.source.scaleMode = 'nearest';
  crateTexture.source.scaleMode = 'nearest';
  barrelExpTexture.source.scaleMode = 'nearest';
  barrelTexture.source.scaleMode = 'nearest';
  billyTexture.source.scaleMode = 'nearest';

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

  // 6. Instanciar o Jogador Billy (Player.as) e Entrada (Input.ts)
  const inputManager = new InputManager();
  const player = new Player(billyTexture, 120, 190, 0);
  await player.skin.preloadCoreAnimations();
  layers.playersLayer.addChild(player.container);

  // 7. Instanciar a Câmera 1:1 com Cam.as
  const camera = new Camera(layers.dynamicMc, layers.shakeContainer, storageMap.mapArea);

  // 8. Configurar Controles Interativos de Câmera e Debug
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
      player.setDebugHitboxVisible(active);
      modeInfo.textContent = `Hitboxes: ${active ? 'VISÍVEIS [Magenta=Solo, Ciano=Cloud, Amarelo=Ladder, Vermelho=Billy]' : 'OCULTAS'}`;
    } else if (key === 'C') {
      camera.showAll = !camera.showAll;
      camera.isManualControl = false;
      modeInfo.textContent = `Câmera: ${camera.showAll ? 'VISÃO GERAL DO MAPA' : 'SEGUINDO JOGADOR (Billy)'}`;
    } else if (key === ' ' || e.code === 'Space') {
      camera.resetCamera();
      camera.showAll = true;
      modeInfo.textContent = 'Camera: AUTO-FOCUS (Resetada para o enquadramento do mapa)';
    } else if (e.key === 'ArrowLeft' || key === 'A') {
      if (e.target !== document.body) return;
    }
  });

  // 9. Game Loop com lógica a 30 Hz fixo (GameMain.as:847, m_timeStep = 1/30)
  // e m_iterations = 20 (GameMain.as:152)
  const VELOCITY_ITERATIONS = 10;
  const POSITION_ITERATIONS = 10;

  const gameLoop = new GameLoop();
  gameLoop.onLogicUpdate = (dt) => {
    // 1. Atualizar lutador Billy com as entradas do teclado
    const playerActions = inputManager.getPlayer1Actions();
    player.update(dt, playerActions, storageMap);

    // 2. Passo físico Box2D Planck.js a 30 Hz fixo
    world.step(dt, VELOCITY_ITERATIONS, POSITION_ITERATIONS);

    // 3. Sincronizar posições dos itens dinâmicos
    storageMap.update();

    // 4. Se a câmera estiver em modo de perseguição, focar na área do jogador
    if (!camera.isManualControl && !camera.showAll) {
      camera.recalculateCamArea(10, false, {
        x: player.state.posX - 120,
        y: player.state.posY - 100,
        width: 240,
        height: 200,
      });
    }

    // 5. Atualizar câmera (translação e zoom)
    camera.update(1.0);

    // 6. Resetar estados transientes de entrada
    inputManager.endFrame();
  };

  gameLoop.onRender = () => {
    // Atualizar overlay de debug com dados de desempenho e física do Billy
    const camPos = camera.currentPosition;
    const pState = player.state;
    let stateDesc = 'Parado';
    if (pState.diving) stateDesc = 'MERGULHO (Dive)';
    else if (pState.rolling) stateDesc = 'ROLAMENTO (Roll)';
    else if (pState.kneeling) stateDesc = 'AGACHADO (Crouch)';
    else if (pState.jumping) stateDesc = 'SUBINDO (Jump)';
    else if (pState.falling) stateDesc = 'CAINDO (Air)';
    else if (pState.sprinting) stateDesc = 'CORRENDO (Sprint)';
    else if (pState.movingDirectionX !== 0) stateDesc = 'ANDANDO (Run)';

    const currentAnim = player.anim.currentAnimation;
    const currentFrame = player.anim.currentFrameInt;
    playerInfo.textContent = `Billy: Pos (${Math.round(pState.posX)}, ${Math.round(pState.posY)}) | Vel: (${pState.airVelocityX.toFixed(1)}, ${pState.airVelocityY.toFixed(1)}) | Grounded: ${pState.isGrounded ? 'SIM' : 'NÃO'} | Energy: ${Math.round(pState.sprintEnergy)}% | Anim: ${currentAnim} [f${currentFrame}] | State: ${stateDesc}`;
    camInfo.textContent = `Cam Pos: (${Math.round(camPos.x)}, ${Math.round(camPos.y)}) | Zoom: ${camera.currentScale.toFixed(2)}x | Modo: ${camera.isManualControl ? 'MANUAL' : (camera.showAll ? 'VISÃO GERAL' : 'SEGUINDO BILLY')}`;
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
