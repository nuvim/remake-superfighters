import { Container, Graphics, Texture } from 'pixi.js';
import type { PlayerInputActions } from '../engine/Input';
import type { StorageMap } from '../stage/StorageMap';
import { CharacterSkin } from './CharacterSkin';
import { PlayerAnimation } from './PlayerAnimation';
import { PlayerState } from './PlayerState';

/**
 * Player.ts — Port literal 1:1 do controlador cinemático de Code/Data/Players/Player.as.
 * Implementa a física exata de locomoção, subida e descida de rampas por micro-passos (0.1 px),
 * detecção de solo por hitTestWorld/hitTestCloud, pouso, salto variável e interação física com caixas/barris.
 */
export class Player {
  public readonly state: PlayerState;
  public readonly anim: PlayerAnimation;
  public readonly skin: CharacterSkin;
  public readonly container: Container;
  public readonly debugHitbox: Graphics;

  constructor(
    charTexture?: Texture,
    spawnX: number = 200,
    spawnY: number = 250,
    charNr: number = 0,
    charKey: string = 'player_billy'
  ) {
    this.state = new PlayerState(spawnX, spawnY);
    this.state.charNr = charNr;

    this.anim = new PlayerAnimation(this.state);
    this.skin = new CharacterSkin(charKey, charTexture);
    this.container = this.skin.container;
    this.container.position.set(spawnX, spawnY);

    // Hitbox de colisão para debug visual (Player.as:265-270)
    // Retângulo semitransparente: x de -6 a +6, y de -18 a +2
    this.debugHitbox = new Graphics();
    this.debugHitbox.rect(-6, -18, 12, 20);
    this.debugHitbox.fill({ color: 0xff0000, alpha: 0.35 });
    this.debugHitbox.stroke({ color: 0xff0000, width: 1, alpha: 0.8 });
    this.debugHitbox.visible = false;
    this.container.addChild(this.debugHitbox);
  }

  // =========================================================================
  // SISTEMA DE COLISÃO FLASH 1:1 (Player.as:8082-8313)
  // =========================================================================

  /**
   * WalkCollision 1:1 com Player.as:8082-8095.
   * Verifica se há parede bloqueando a caminhada na altura de y-4 e y-6.
   * Por NÃO testar no nível dos pés (y), rampas inclinadas e pequenos degraus
   * JAMAIS bloqueiam a caminhada.
   */
  public walkCollision(dirX: number, map: StorageMap): boolean {
    let loc3 = 2;
    while (loc3 <= 4) {
      if (map.hitTestWorld(this.state.posX + (loc3 - 1) * dirX, this.state.posY - 2 - loc3)) {
        return true;
      }
      loc3 += 2;
    }
    return false;
  }

  /**
   * CollisionSide 1:1 com Player.as:8160-8182.
   * Testa colisão lateral da cintura à cabeça (y - 6 até y - 16).
   */
  public collisionSide(dirX: number, map: StorageMap, dist: number = 6): boolean {
    if (dirX === 0) return false;
    const edgeX = this.state.posX + dist * (dirX > 0 ? 1 : -1);
    let loc3 = 6;
    while (loc3 <= this.state.playerHeight - 2) {
      if (map.hitTestWorld(edgeX, this.state.posY - loc3)) {
        return true;
      }
      loc3 += 2;
    }
    return false;
  }

  /**
   * CollisionFeetMid 1:1 com Player.as:8238-8268.
   * Testa se o ponto central dos pés (ou com desvio lateral offsetX) toca solo ou plataforma CLOUD.
   */
  public collisionFeetMid(
    offsetY: number = 0,
    offsetX: number = 0,
    map: StorageMap,
    ignoreCloud: boolean = false
  ): boolean {
    const px = this.state.posX;
    const py = this.state.posY + offsetY;

    if (!ignoreCloud && map.hitTestCloud(px, py)) return true;
    if (map.hitTestWorld(px, py)) return true;

    if (offsetX !== 0) {
      if (!ignoreCloud && (map.hitTestCloud(px + offsetX, py) || map.hitTestCloud(px - offsetX, py))) {
        return true;
      }
      if (map.hitTestWorld(px + offsetX, py) || map.hitTestWorld(px - offsetX, py)) {
        return true;
      }
    }
    return false;
  }

  /**
   * CanLandInMid 1:1 com Player.as:8184-8204.
   * Testa se há solo nos próximos 0, 2, 4, 6 pixels abaixo dos pés.
   */
  public canLandInMid(map: StorageMap, ignoreCloud: boolean = false): boolean {
    let loc1 = 0;
    while (loc1 <= this.state.playerEdgeDistance) {
      const py = this.state.posY + loc1;
      if (!ignoreCloud && map.hitTestCloud(this.state.posX, py)) return true;
      if (map.hitTestWorld(this.state.posX, py)) return true;
      loc1 += 2;
    }
    return false;
  }

  /**
   * CollisionFeetSides 1:1 com Player.as:8289-8313.
   * Testa colisão nos cantos esquerdo e direito dos pés (+-2, 4, 6 px).
   */
  public collisionFeetSides(offsetY: number = 0, map: StorageMap, ignoreCloud: boolean = false): boolean {
    let loc3 = 2;
    while (loc3 <= this.state.playerEdgeDistance) {
      const py = this.state.posY + offsetY;
      if (map.hitTestWorld(this.state.posX - loc3, py) || map.hitTestWorld(this.state.posX + loc3, py)) {
        return true;
      }
      if (!ignoreCloud) {
        if (map.hitTestCloud(this.state.posX - loc3, py) || map.hitTestCloud(this.state.posX + loc3, py)) {
          return true;
        }
      }
      loc3 += 2;
    }
    return false;
  }

  // =========================================================================
  // LOCOMOÇÃO CINEMÁTICA E AJUSTE DE RAMPA (Player.as:3883-4627)
  // =========================================================================

  /**
   * MovePlayer 1:1 com Player.as:3883-3932.
   * Desloca o jogador horizontalmente em micro-passos de 0.1 px,
   * permitindo subir rampas suavemente sem engasgar e sem cair pelo chão.
   */
  public movePlayer(dirX: number, speed: number, map: StorageMap): void {
    if (dirX === 0) return;
    this.state.lastDirX = dirX;
    this.state.movingDirectionX = dirX;

    const steps = Math.round(Math.abs(speed * 10));
    const stepDx = dirX * 0.1;

    for (let s = 1; s <= steps; s++) {
      // 1. Verificar colisão com parede ou caixa na altura da cintura
      if (this.walkCollision(dirX, map)) {
        // Tentar empurrar objeto dinâmico se houver contato
        const bodyAhead = map.getDynamicBodyAt(
          this.state.posX + dirX * (this.state.playerEdgeDistance + 4),
          this.state.posY - 8
        );
        if (bodyAhead) {
          map.pushBody(bodyAhead, dirX, this.state.sprinting ? 2.5 : 1.2);
        }
        return;
      }

      // 2. Avançar micro-passo de 0.1 px
      this.state.posX += stepDx;

      // 3. Se estiver no chão, ajustar altura na rampa/degrau
      if (this.state.isGrounded) {
        this.updateSimpleGroundMovement(false, map);
      }
    }
  }

  /**
   * UpdateSimpleGroundMovement 1:1 com Player.as:4551-4627.
   * O algoritmo canônico que mantém o lutador colado às rampas e solos irregulares:
   * - Se o pé penetrar o solo (subindo rampa): eleva posY de 0.1 em 0.1 px até desobstruir.
   * - Se o pé perder contato momentâneo (descendo rampa): desce posY de 0.1 em 0.1 px até tocar o chão.
   * - Se não houver solo num raio de PlayerEdgeDistance (6 px): inicia queda balística.
   */
  public updateSimpleGroundMovement(isFull: boolean, map: StorageMap): void {
    if (this.collisionFeetMid(0, 1, map)) {
      if (this.collisionFeetMid(-1, 1, map)) {
        let loc2 = 0;
        while (this.collisionFeetMid(-1, 1, map) && loc2 < 100) {
          this.state.posY -= 0.1;
          loc2++;
        }
        if (loc2 > 0) {
          this.state.posY += 0.1;
        }
      }
      if (isFull) {
        this.updateDynamicMovement(map);
      }
    } else if (this.canLandInMid(map)) {
      if (this.state.isGrounded) {
        while (!this.collisionFeetMid(0, 0, map)) {
          this.state.posY += 0.1;
        }
        if (isFull) {
          this.updateDynamicMovement(map);
        }
      }
    } else if (this.collisionFeetSides(0, map)) {
      // Apoiado na beirada de uma plataforma
      if (isFull) {
        this.updateDynamicMovement(map);
      }
    } else {
      // Deixou o solo — transição imediata para queda
      this.state.isGrounded = false;
      this.state.jumping = false;
      this.state.falling = true;
      this.state.airVelocityY = 0.1;
    }
  }

  /**
   * UpdateDynamicMovement 1:1 com Player.as:5953-6044.
   * Trata a interação física quando o jogador está em cima ou empurrando objetos dinâmicos (caixas/barris).
   */
  public updateDynamicMovement(map: StorageMap): void {
    const bodyBelow = map.getDynamicBodyAt(this.state.posX, this.state.posY + 2);
    if (bodyBelow) {
      // Exerce pressão gravitacional para baixo no objeto
      const mass = bodyBelow.getMass();
      map.pushBody(bodyBelow, 0, mass / 10.0);

      // Transmite a velocidade linear do objeto para o lutador caso o objeto esteja se movendo
      const vel = bodyBelow.getLinearVelocity();
      if (Math.abs(vel.x) > 0.05 || Math.abs(vel.y) > 0.05) {
        this.state.posX += vel.x;
        this.state.posY += vel.y;
      }
    }
  }

  // =========================================================================
  // CICLO PRINCIPAL DE ATUALIZAÇÃO (30 HZ)
  // =========================================================================

  /**
   * Atualização lógica do lutador executada estritamente a 30 Hz (Player.as).
   */
  public update(dt: number, actions: PlayerInputActions, map: StorageMap): void {
    this.state.updateTimers();

    // 1. Processar entradas horizontais
    let moveDir = 0;
    if (actions.right) moveDir += 1;
    if (actions.left) moveDir -= 1;
    this.state.movingDirectionX = moveDir;

    // 2. Máquina de estados: Solo vs Ar
    if (this.state.isGrounded) {
      // No chão
      if (actions.dive || (actions.sprint && actions.jump && moveDir !== 0)) {
        // Disparar Mergulho (Dive, Player.as:7719-7720)
        this.performDive();
      } else if (actions.jump) {
        // Pulo convencional (Player.as:7755)
        this.performJump();
      } else if (actions.crouch) {
        if (moveDir !== 0 && !this.state.rolling) {
          // Rolamento no chão (Roll, Player.as:40)
          this.state.rolling = true;
          this.state.rollTimer = 8;
          this.state.airVelocityX = this.state.lastDirX * PlayerState.ROLL_SPEED;
        } else if (!this.state.rolling) {
          // Agachamento / Cover
          this.state.kneeling = true;
          this.state.airVelocityX = 0;
        }
      } else {
        this.state.kneeling = false;
        if (this.state.rolling) {
          this.state.rollTimer--;
          if (this.state.rollTimer <= 0) {
            this.state.rolling = false;
          }
          this.movePlayer(this.state.lastDirX, PlayerState.ROLL_SPEED, map);
        } else if (moveDir !== 0) {
          if (actions.sprint && this.state.sprintEnergy > 10) {
            this.state.sprinting = true;
            this.state.sprintEnergy -= 1.0;
            const sprintSpeed = PlayerState.RUN_SPEED * 1.4;
            this.movePlayer(moveDir, sprintSpeed, map);
          } else {
            this.state.sprinting = false;
            this.movePlayer(moveDir, PlayerState.RUN_SPEED, map);
            if (this.state.sprintEnergy < PlayerState.SPRINT_ENERGY_MAX) {
              this.state.sprintEnergy += 0.5;
            }
          }
        } else {
          this.state.sprinting = false;
          this.state.airVelocityX = 0;
          if (this.state.sprintEnergy < PlayerState.SPRINT_ENERGY_MAX) {
            this.state.sprintEnergy += 0.5;
          }
        }
      }

      // Checagem contínua de solo no fim do frame
      if (this.state.isGrounded) {
        this.updateSimpleGroundMovement(true, map);
      }
    } else {
      // No ar (Gravidade e balística do salto)
      this.state.airVelocityY += PlayerState.PLAYER_GRAVITY;

      // Pulo variável: segurar botão de pulo dá impulso extra até 4 ticks (Player.as:3234)
      if (actions.jump && this.state.jumpPushTimeLeft > 0) {
        this.state.airVelocityY += PlayerState.PLAYER_JUMP_PUSH_POWER;
        this.state.jumpPushTimeLeft--;
      }

      // Se estiver em mergulho (Dive), mantém velocidade horizontal
      if (this.state.diving) {
        this.state.airVelocityX = this.state.lastDirX * PlayerState.DIVE_SPEED;
      } else if (moveDir !== 0) {
        // Controle aéreo suave
        this.state.airVelocityX = moveDir * (PlayerState.RUN_SPEED * 0.9);
      } else {
        this.state.airVelocityX *= 0.85;
      }

      // Transição para queda
      if (this.state.airVelocityY > 0) {
        this.state.jumping = false;
        this.state.falling = true;
      }

      // Deslocamento no ar subdividido por steps inteiros
      const totalSpeed = Math.max(1, Math.ceil(Math.abs(this.state.airVelocityY)));
      const stepDy = this.state.airVelocityY / totalSpeed;
      const stepDx = this.state.airVelocityX / totalSpeed;

      const ignoreCloud = actions.down; // Pressionar BAIXO permite descer através de plataformas CLOUD

      for (let s = 1; s <= totalSpeed; s++) {
        // Deslocamento horizontal no ar com teste de parede
        if (this.state.airVelocityX !== 0) {
          const dirX = this.state.airVelocityX > 0 ? 1 : -1;
          if (!this.collisionSide(dirX, map, 6)) {
            this.state.posX += stepDx;
          } else {
            this.state.airVelocityX = 0;
            // Se estiver em mergulho, interrompe ao bater em parede
            if (this.state.diving) {
              this.state.diving = false;
            }
          }
        }

        // Deslocamento vertical
        this.state.posY += stepDy;

        // Se estiver caindo (airVelocityY >= 0), testar aterrissagem nos pés
        if (this.state.airVelocityY >= 0) {
          if (
            this.collisionFeetSides(0, map, ignoreCloud) &&
            this.canLandInMid(map, ignoreCloud) &&
            this.collisionFeetMid(0, 0, map, ignoreCloud)
          ) {
            this.playerLands(this.state.posY);
            // Ajustar o pé exatamente à superfície
            while (!this.collisionFeetMid(0, 0, map, ignoreCloud)) {
              this.state.posY += 0.1;
            }
            break;
          }
        }
      }
    }

    // 3. Interação física com caixas e barris do cenário (Dive / Chute)
    if (this.state.diving) {
      map.pushDynamicItem(this.state.posX, this.state.posY, this.state.lastDirX, 3.5);
    }

    // 4. Atualizar skin visual e animações 1:1 do Flash
    this.skin.update(dt, this.state, this.anim);
  }

  /**
   * Dispara o pulo inicial (Player.as:7755).
   */
  public performJump(): void {
    this.state.isGrounded = false;
    this.state.jumping = true;
    this.state.falling = false;
    this.state.kneeling = false;
    this.state.airVelocityY = PlayerState.PLAYER_JUMP_POWER; // -5.0
    this.state.jumpPushTimeLeft = PlayerState.PLAYER_JUMP_PUSH_TIME; // 4 ticks
  }

  /**
   * Dispara o mergulho corporal (Dive, Player.as:7708-7720).
   */
  public performDive(): void {
    this.state.diving = true;
    this.state.isGrounded = false;
    this.state.jumping = false;
    this.state.kneeling = false;
    this.state.posY -= 6; // Elevação inicial de 6 pixels (Player.as:7719)
    this.state.airVelocityY = -3.0;
    this.state.airVelocityX = this.state.lastDirX * PlayerState.DIVE_SPEED; // 3.5
  }

  /**
   * Chamado quando o jogador aterrissa no solo (Player.as:4962).
   */
  public playerLands(groundY: number): void {
    this.state.posY = groundY;
    this.state.airVelocityY = 0;
    this.state.isGrounded = true;
    this.state.jumping = false;
    this.state.falling = false;
    this.state.diving = false;
    this.state.jumpKickPerformed = false;
  }

  /**
   * Alterna a visibilidade da hitbox de depuração.
   */
  public setDebugHitboxVisible(visible: boolean): void {
    this.debugHitbox.visible = visible;
  }
}
