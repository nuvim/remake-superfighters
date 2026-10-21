import { Container, Graphics, Sprite, Texture } from 'pixi.js';
import type { PlayerInputActions } from '../engine/Input';
import type { StorageMap } from '../stage/StorageMap';
import { PlayerState } from './PlayerState';

/**
 * Player.ts — Controlador cinemático 1:1 de Code/Data/Players/Player.as.
 * Implementa o ciclo físico a 30 Hz com as equações originais de gravidade, pulo e colisão.
 */
export class Player {
  public readonly state: PlayerState;
  public readonly container: Container;
  public readonly sprite: Sprite;
  public readonly debugHitbox: Graphics;

  constructor(
    charTexture: Texture,
    spawnX: number = 200,
    spawnY: number = 250,
    charNr: number = 0
  ) {
    this.state = new PlayerState(spawnX, spawnY);
    this.state.charNr = charNr;

    // Container visual colocado na camada PLAYERS da DisplayList
    this.container = new Container();
    this.container.position.set(spawnX, spawnY);

    // Sprite representativo do lutador
    this.sprite = new Sprite(charTexture);
    // Ponto pivô do Flash: centralizado horizontalmente nos pés (24, 28)
    this.sprite.anchor.set(
      PlayerState.PIVOT_X / charTexture.width,
      PlayerState.PIVOT_Y / charTexture.height
    );
    this.container.addChild(this.sprite);

    // Hitbox de colisão para debug visual (Player.as:265-270)
    // Retângulo vermelho semitransparente: x de -6 a +6, y de -18 a +2
    this.debugHitbox = new Graphics();
    this.debugHitbox.rect(-6, -18, 12, 20);
    this.debugHitbox.fill({ color: 0xff0000, alpha: 0.35 });
    this.debugHitbox.stroke({ color: 0xff0000, width: 1, alpha: 0.8 });
    this.debugHitbox.visible = false;
    this.container.addChild(this.debugHitbox);
  }

  /**
   * Atualização lógica do lutador executada estritamente a 30 Hz (Player.as).
   */
  public update(_dt: number, actions: PlayerInputActions, map: StorageMap): void {
    this.state.updateTimers();

    // 1. Processar entradas horizontais
    let moveDir = 0;
    if (actions.right) moveDir += 1;
    if (actions.left) moveDir -= 1;
    this.state.movingDirectionX = moveDir;

    if (moveDir !== 0) {
      this.state.lastDirX = moveDir;
    }

    // 2. Movimentação no chão ou no ar
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
          this.state.rollTimer = 8; // 8 ticks a 30Hz
          this.state.airVelocityX = this.state.lastDirX * PlayerState.ROLL_SPEED;
        } else if (!this.state.rolling) {
          // Agachamento / Cover
          this.state.kneeling = true;
          this.state.airVelocityX = 0;
        }
      } else {
        // Corrida / Caminhada
        this.state.kneeling = false;
        if (this.state.rolling) {
          this.state.rollTimer--;
          if (this.state.rollTimer <= 0) {
            this.state.rolling = false;
          }
        } else {
          if (actions.sprint && this.state.sprintEnergy > 10 && moveDir !== 0) {
            this.state.sprinting = true;
            this.state.sprintEnergy -= 1.0;
            this.state.airVelocityX = moveDir * (PlayerState.RUN_SPEED * 1.4);
          } else {
            this.state.sprinting = false;
            this.state.airVelocityX = moveDir * PlayerState.RUN_SPEED;
            if (this.state.sprintEnergy < PlayerState.SPRINT_ENERGY_MAX) {
              this.state.sprintEnergy += 0.5;
            }
          }
        }
      }

      // Verificar se ainda há solo sob os pés
      const groundCheck = map.checkFeetCollision(this.state.posX, this.state.posY + 2);
      if (!groundCheck.collided) {
        this.state.isGrounded = false;
        this.state.falling = true;
      }
    } else {
      // No ar (Gravidade e balística do salto)
      // Gravidade fixa (Player.as:4973)
      this.state.airVelocityY += PlayerState.PLAYER_GRAVITY;

      // Pulo variável: segurar botão de pulo dá impulso extra até 4 ticks (Player.as:3234)
      if (actions.jump && this.state.jumpPushTimeLeft > 0) {
        this.state.airVelocityY += PlayerState.PLAYER_JUMP_PUSH_POWER;
        this.state.jumpPushTimeLeft--;
      }

      // Se estiver em mergulho (Dive), mantém velocidade horizontal e aplica rotação
      if (this.state.diving) {
        this.state.airVelocityX = this.state.lastDirX * PlayerState.DIVE_SPEED;
      } else {
        // Controle aéreo suave
        if (moveDir !== 0) {
          this.state.airVelocityX = moveDir * (PlayerState.RUN_SPEED * 0.9);
        }
      }

      // Verificar se começou a cair
      if (this.state.airVelocityY > 0) {
        this.state.jumping = false;
        this.state.falling = true;
      }

      // Verificar pouso nos pés
      if (this.state.airVelocityY >= 0) {
        const nextY = this.state.posY + this.state.airVelocityY;
        const groundHit = map.checkFeetCollision(this.state.posX, nextY, actions.down);
        if (groundHit.collided) {
          this.playerLands(groundHit.groundY);
        }
      }
    }

    // 3. Aplicar deslocamento horizontal e testar colisão com paredes
    this.state.posX += this.state.airVelocityX;
    const wallHit = map.checkWallCollision(this.state.posX, this.state.posY);
    if (wallHit.collided) {
      this.state.posX += wallHit.pushX;
      if (this.state.diving) {
        // Interrompe mergulho se colidir com parede sólida
        this.state.diving = false;
      }
    }

    // 4. Aplicar deslocamento vertical se estiver no ar
    if (!this.state.isGrounded) {
      this.state.posY += this.state.airVelocityY;
    }

    // 5. Interação física com caixas e barris do cenário
    if (this.state.diving || Math.abs(this.state.airVelocityX) > 1.0) {
      const impulse = this.state.diving ? 3.5 : 1.5;
      map.pushDynamicItem(this.state.posX, this.state.posY, this.state.lastDirX, impulse);
    }

    // 6. Atualizar container visual PixiJS
    this.container.position.set(this.state.posX, this.state.posY);
    this.container.scale.x = this.state.lastDirX; // Espelhamento horizontal instantâneo (scale.x = -1)
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
