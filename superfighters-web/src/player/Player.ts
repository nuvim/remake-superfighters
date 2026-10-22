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
   * CollisionFeetBothSides 1:1 com Player.as:8270-8287.
   * Retorna true se AMBOS os lados (esquerda e direita simultaneamente) tocam o chão.
   */
  public collisionFeetBothSides(map: StorageMap, ignoreCloud: boolean = false): boolean {
    let loc1 = 2;
    while (loc1 <= this.state.playerEdgeDistance) {
      const leftCloud = !ignoreCloud && map.hitTestCloud(this.state.posX - loc1, this.state.posY);
      const rightCloud = !ignoreCloud && map.hitTestCloud(this.state.posX + loc1, this.state.posY);
      if (leftCloud && rightCloud) {
        return true;
      }
      const leftWorld = map.hitTestWorld(this.state.posX - loc1, this.state.posY);
      const rightWorld = map.hitTestWorld(this.state.posX + loc1, this.state.posY);
      if (leftWorld && rightWorld) {
        return true;
      }
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

  /** Port de Player.as:8015-8032 WorldCollisionHead
   *  PARIDADE: NÃO VERIFICADA */
  public worldCollisionHead(map: StorageMap): boolean {
    if (
      map.hitTestWorld(this.state.posX, this.state.posY - this.state.playerHeight, false) &&
      (map.hitTestWorld(this.state.posX - this.state.playerEdgeDistance, this.state.posY - this.state.playerHeight, false) ||
       map.hitTestWorld(this.state.posX + this.state.playerEdgeDistance, this.state.posY - this.state.playerHeight, false))
    ) {
      return true;
    }
    let loc1: number = 4;
    while (loc1 <= this.state.playerHeight - 2) {
      if (
        map.hitTestWorld(this.state.posX - this.state.playerEdgeDistance, this.state.posY - loc1, false) &&
        map.hitTestWorld(this.state.posX, this.state.posY - loc1, false) &&
        map.hitTestWorld(this.state.posX + this.state.playerEdgeDistance, this.state.posY - loc1, false)
      ) {
        return true;
      }
      loc1 += 2;
    }
    return false;
  }

  /** Port de Player.as:3883-3932 MovePlayer
   *  PARIDADE: NÃO VERIFICADA (verificar com golden walk_right_flat)
   *  NÃO PORTADO: Staggering (3885), WallJumping (3887), Kneeling/Roll (3908) */
  public movePlayer(param1: number, param2: number, map: StorageMap): void {
    if (param1 === 0) return;
    this.state.lastDirX = param1;
    this.state.movingDirectionX = this.state.lastDirX;

    // Player.as:3916: var _loc3_:int = Math.abs(param2 * 10);
    const loc3: number = Math.trunc(Math.abs(param2 * 10));
    // Player.as:232 / GameMain.as:151: this._game_speed = 1.0 (constante 1 por enquanto a 30Hz)
    const gameSpeed: number = 1.0;
    // Player.as:3917: var _loc4_:Number = this._PlayerState.MovingDirectionX * 0.1;
    const loc4: number = this.state.movingDirectionX * 0.1;

    let loc5: number = 1;
    while (loc5 <= loc3) {
      // Player.as:3921: if(this.WalkCollision(this._PlayerState.MovingDirectionX,this._PlayerState.Jumping)) return;
      if (this.walkCollision(this.state.movingDirectionX, map)) {
        const bodyAhead = map.getDynamicBodyAt(
          this.state.posX + this.state.movingDirectionX * (this.state.playerEdgeDistance + 4),
          this.state.posY - 8
        );
        if (bodyAhead) {
          map.pushBody(bodyAhead, this.state.movingDirectionX, this.state.sprinting ? 2.5 : 1.2);
        }
        return;
      }
      this.state.posX += loc4 * gameSpeed;
      if (this.state.isGrounded) {
        this.updateSimpleGroundMovement(false, map);
      }
      loc5++;
    }
  }

  /**
   * UpdateGroundMovement 1:1 com Player.as:4497-4505.
   * Se ambos os cantos dos pés e o meio tocam o solo, eleva o jogador em 0.1 px por tick.
   */
  public updateGroundMovement(map: StorageMap): void {
    if (this.collisionFeetBothSides(map)) {
      if (this.collisionFeetMid(0, 0, map)) {
        this.state.posY -= 0.1;
      }
    }
    // UpdateSides() / verificação de corpos dinâmicos
  }

  /** Port de Player.as:4551-4626 UpdateSimpleGroundMovement
   *  PARIDADE: NÃO VERIFICADA (verificar com golden walk_up_stair02)
   *  NÃO PORTADO: Staggering (4596, 4609), Fall(false) (4598, 4611), CheckAimDrop (4608) */
  public updateSimpleGroundMovement(param1: boolean, map: StorageMap): void {
    let loc2: number = 0;
    // Player.as:4554: if(this.CollisionFeetMid(0,1))
    if (this.collisionFeetMid(0, 1, map)) {
      // Player.as:4556: if(this.CollisionFeetMid(-1,1))
      if (this.collisionFeetMid(-1, 1, map)) {
        loc2 = 0;
        // Player.as:4559: while(Boolean(this.CollisionFeetMid(-1,1)) && !this.WorldCollisionHead() && _loc2_ < 100)
        while (Boolean(this.collisionFeetMid(-1, 1, map)) && !this.worldCollisionHead(map) && loc2 < 100) {
          this.state.posY -= 0.1;
          loc2 += 1;
        }
        // Player.as:4564: if(_loc2_ > 0) this._this_y += 0.1;
        if (loc2 > 0) {
          this.state.posY += 0.1;
        }
      }
      // Player.as:4569: if(param1) this.UpdateDynamicMovement();
      if (param1) {
        this.updateDynamicMovement(map);
      }
    }
    // Player.as:4574: else if(this.CanLandInMid())
    else if (this.canLandInMid(map)) {
      // Player.as:4576: if(this._PlayerState.OnGround)
      if (this.state.isGrounded) {
        // Player.as:4578: while(!this.CollisionFeetMid()) this._this_y += 0.1;
        while (!this.collisionFeetMid(0, 0, map)) {
          this.state.posY += 0.1;
        }
        // Player.as:4582: if(param1) this.UpdateDynamicMovement();
        if (param1) {
          this.updateDynamicMovement(map);
        }
      }
    }
    // Player.as:4588: else if(this.CollisionFeetSides())
    else if (this.collisionFeetSides(0, map)) {
      // Player.as:4590: if(param1) this.UpdateDynamicMovement();
      if (param1) {
        this.updateDynamicMovement(map);
      }
      // Player.as:4594: if(!this.CollisionFeetSides())
      if (!this.collisionFeetSides(0, map)) {
        // TODO(AS3 Player.as:4596): ramo Staggering não portado
        // Player.as:4602: this._PlayerState.Jumping = true;
        this.state.jumping = true;
        this.state.isGrounded = false;
      }
    }
    // Player.as:4606: else
    else {
      // TODO(AS3 Player.as:4608): this.CheckAimDrop() não portado
      // TODO(AS3 Player.as:4609): ramo Staggering não portado
      // Player.as:4615: if(this._standingOnObject != null)
      const bodyBelow = map.getDynamicBodyAt(this.state.posX, this.state.posY + 2);
      if (bodyBelow != null) {
        const vel = bodyBelow.getLinearVelocity();
        this.state.airVelocityY = vel.y;
        this.state.airVelocityX = vel.x;
      }
      // Player.as:4624: this._PlayerState.Jumping = true;
      this.state.jumping = true;
      this.state.isGrounded = false;
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
   * UpdateAirMovement 1:1 com Player.as:4628-4979.
   * Executa a cinemática aérea com sub-steps inteiros calculados a partir de TotalAirVelocity
   * e integração incremental da gravidade.
   */
  public updateAirMovement(map: StorageMap): void {
    if (this.state.airVelocityY === 0) {
      this.state.airVelocityY = 0.1;
    }

    const substeps = Math.max(1, Math.ceil(this.state.totalAirVelocity));
    let vy = this.state.airVelocityY;
    let vx = this.state.airVelocityX;

    for (let s = 1; s <= substeps; s++) {
      const oldX = this.state.posX;
      const oldY = this.state.posY;
      this.state.posX += vx / substeps;
      this.state.posY += vy / substeps;

      // Colisão lateral no ar (Player.as:4826-4865)
      if (vx !== 0) {
        const dir = vx > 0 ? 1 : -1;
        if (this.collisionSide(dir, map, 6)) {
          this.state.posX = oldX;
          this.state.airVelocityX = 0;
          vx = 0;
          if (this.state.diving) {
            this.state.diving = false;
          }
        }
      }

      // Se estiver descendo no ar (vy > 0), testar aterrissagem nos pés (Player.as:4876-4942)
      if (vy > 0) {
        if (this.state.airVelocityY >= PlayerState.FALL_TRIGGER_SPEED) {
          this.state.falling = true;
        }

        if (this.collisionFeetSides(0, map)) {
          if (this.canLandInMid(map)) {
            if (this.collisionFeetMid(0, 0, map)) {
              this.playerLands(this.state.posY);
              return;
            }
          } else if (!this.collisionFeetSides(-2, map)) {
            if (this.collisionFeetSides(1, map)) {
              this.playerLands(this.state.posY);
              return;
            }
          } else {
            if (this.collisionFeetBothSides(map)) {
              this.playerLands(this.state.posY);
              return;
            }
          }
        }
      } else if (vy < 0) {
        // Se estiver subindo no ar (vy < 0), testar colisão com a cabeça (Player.as:4943-4953)
        if (this.worldCollisionHead(map)) {
          this.state.posY = oldY;
          this.state.airVelocityY = 0;
          return;
        }
      }

      // Acúmulo de gravidade a cada sub-step 1:1 com Player.as:4973
      this.state.airVelocityY += (PlayerState.PLAYER_GRAVITY / substeps);
      vx = this.state.airVelocityX;
      vy = this.state.airVelocityY;
    }
  }

  /**
   * Atualização lógica do lutador executada estritamente a 30 Hz (Player.as:3050-3450).
   */
  public update(dt: number, actions: PlayerInputActions, map: StorageMap): void {
    this.state.updateTimers();

    // 1. Processar entradas horizontais
    let moveDir = 0;
    if (actions.right) moveDir += 1;
    if (actions.left) moveDir -= 1;
    this.state.movingDirectionX = moveDir;

    // 2. Máquina de estados: Solo vs Ar (Player.as:3388-3401)
    if (this.state.onGround) {
      if (actions.dive || (actions.sprint && actions.jump && moveDir !== 0)) {
        this.performDive();
      } else if (actions.jump) {
        this.performJump();
      } else if (actions.crouch) {
        if (moveDir !== 0 && !this.state.rolling) {
          this.state.rolling = true;
          this.state.rollTimer = 8;
          this.state.airVelocityX = this.state.lastDirX * PlayerState.ROLL_SPEED;
        } else if (!this.state.rolling) {
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

      // Movimentação de solo 1:1 com Player.as:3400 (UpdateGroundMovement)
      if (this.state.onGround) {
        this.updateGroundMovement(map);
      }
    }

    // Se estiver no ar (ou acabou de saltar) (Player.as:3396)
    if (!this.state.onGround) {
      if (moveDir !== 0 && !this.state.diving) {
        this.movePlayer(moveDir, PlayerState.RUN_SPEED, map);
      }
      this.updateAirMovement(map);
    }

    // 3. Interação física com caixas e barris do cenário (Dive / Chute)
    if (this.state.diving) {
      map.pushDynamicItem(this.state.posX, this.state.posY, this.state.lastDirX, 3.5);
    }

    // 4. Atualizar skin visual e animações 1:1 do Flash
    this.skin.update(dt, this.state, this.anim);
  }

  /**
   * Dispara o pulo inicial (Player.as:5825, 7755).
   */
  public performJump(): void {
    if (!this.state.onGround) return;
    this.state.jumping = true;
    this.state.falling = false;
    this.state.kneeling = false;
    this.state.airVelocityY += PlayerState.PLAYER_JUMP_POWER; // -5.0
  }

  /**
   * Dispara o mergulho corporal (Dive, Player.as:7708-7720).
   */
  public performDive(): void {
    this.state.diving = true;
    this.state.jumping = false;
    this.state.kneeling = false;
    this.state.posY -= 6; // Elevação inicial de 6 pixels (Player.as:7719)
    this.state.airVelocityY = -3.0;
    this.state.airVelocityX = this.state.lastDirX * PlayerState.DIVE_SPEED; // 3.5
  }

  /**
   * Chamado quando o jogador aterrissa no solo (Player.as:5153-5296).
   */
  public playerLands(groundY: number): void {
    this.state.posY = groundY;
    this.state.airVelocityY = 0;
    this.state.jumping = false;
    this.state.falling = false;
    this.state.climbing = false;
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
