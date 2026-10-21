import { PlayerState } from './PlayerState';

/**
 * PlayerAnimation.ts — Port literal 1:1 de Code/Data/Players/PlayerAnimation.as.
 * Gerencia a máquina de estados de animação, prioridade de labels, transições,
 * rotações dinâmicas de mergulho/queda e piscar de imunidade.
 */
export class PlayerAnimation {
  private _playerState: PlayerState;

  private _currentAnimation: string = '';
  private _currentFrame: number = 1;
  private _loopAnimation: boolean = false;
  private _animationDone: boolean = false;
  private _helpAnimation: boolean = false;
  private _aimAnimation: boolean = false;
  private _disableSlowmotionModifier: boolean = false;

  private _rotateSpeed: number = 0;
  private _rotateIncrease: number = 0;
  private _rotation: number = 0; // Graus de rotação (HELPMC)

  private _alpha: number = 1.0;
  private _nextBlinkTimer: number = 0;
  private _blinkDurationTimer: number = 0;

  constructor(playerState: PlayerState) {
    this._playerState = playerState;
  }

  public get currentAnimation(): string {
    return this._currentAnimation;
  }

  public get currentFrame(): number {
    return this._currentFrame;
  }

  public get currentFrameInt(): number {
    return Math.floor(this._currentFrame);
  }

  public get isAnimationDone(): boolean {
    return this._animationDone;
  }

  public get isLoopAnimation(): boolean {
    return this._loopAnimation;
  }

  public get isHelpAnimation(): boolean {
    return this._helpAnimation;
  }

  public get isAimAnimation(): boolean {
    return this._aimAnimation;
  }

  public get isDisableSlowmotionModifier(): boolean {
    return this._disableSlowmotionModifier;
  }

  public get rotation(): number {
    return this._rotation;
  }

  public get alpha(): number {
    return this._alpha;
  }

  /**
   * Determina a direção da queda com base na velocidade horizontal (PlayerAnimation.as:269-276).
   */
  public isFallingForward(): boolean {
    if (
      (this._playerState.lastDirX === 1 && this._playerState.airVelocityX >= 0) ||
      (this._playerState.lastDirX === -1 && this._playerState.airVelocityX < 0)
    ) {
      return true;
    }
    return false;
  }

  /**
   * Atualiza a animação com base na prioridade estrita de PlayerAnimation.as:84-267.
   */
  public updateAnimation(): void {
    // 1. Efeito de piscar de imunidade (PlayerAnimation.as:91-126)
    if (this._playerState.isImmune) {
      this._nextBlinkTimer--;
      if (this._nextBlinkTimer <= 0) {
        this._alpha = 0.2;
        this._blinkDurationTimer--;
        if (this._blinkDurationTimer <= 0) {
          this._blinkDurationTimer = 1;
          this._nextBlinkTimer = 3;
        }
      } else {
        this._alpha = 1.0;
      }
    } else {
      this._alpha = 1.0;
      this._nextBlinkTimer = 0;
      this._blinkDurationTimer = 1;
    }

    // 2. Prioridade canônica de estados (PlayerAnimation.as:127-267)
    if (this._playerState.ignoreMe) {
      this.showAnimation('EMPTY');
    } else if (this._playerState.stuckToRocket) {
      this.showAnimation('ROCKET_RIDE_R');
    } else if (this._playerState.deathKneel) {
      this.showAnimation('DEATH_KNEEL');
    } else if (this._playerState.grabbedByPlayer) {
      this.showAnimation('GRABBED');
    } else if (this._playerState.staggering) {
      this.showAnimation('STAGGER');
    } else if (this._playerState.climbing) {
      if (this._playerState.climbingDirection === 1) {
        this.showAnimation('SLIDE');
      } else {
        this.showAnimation('CLIMB');
      }
    } else if (this._playerState.knockdowned) {
      this.showAnimation('KNOCKDOWN');
    } else if (this._playerState.falling) {
      if (this.isFallingForward()) {
        this.showAnimation('FALL_F');
      } else {
        this.showAnimation('FALL_B');
      }
    } else if (this._playerState.isStunned) {
      this.showAnimation(`STUN_0${this._playerState.stunAnimation}`);
    } else if (this._playerState.aiming) {
      this.showAnimation('AIM_PISTOL');
    } else if (this._playerState.throwing) {
      this.showAnimation('THROW');
    } else if (this._playerState.diving) {
      this.showAnimation('DIVE');
    } else if (this._playerState.jumping) {
      if (this._playerState.jumpKickPerformed) {
        this.showAnimation('JUMPKICK');
      } else {
        this.showAnimation('JUMP');
      }
    } else if (this._playerState.rolling) {
      if (this._currentAnimation && this._animationDone) {
        this.showAnimation('ROLL', true);
      } else {
        this.showAnimation('ROLL');
      }
    } else if (this._playerState.kicking) {
      this.showAnimation('KICK');
    } else if (this._playerState.punching) {
      this.showAnimation(`${this._playerState.meleeAnimation}_0${this._playerState.punchComboNr}`);
    } else if (this._playerState.kneeling) {
      this.showAnimation('KNEEL');
    } else if (this._playerState.takingCover) {
      this.showAnimation('COVER');
    } else if (this._playerState.movingDirectionX === 0) {
      this.showAnimation('IDLE');
    } else if (this._playerState.sprinting) {
      this.showAnimation('SPRINT');
    } else {
      this.showAnimation('RUN');
    }
  }

  /**
   * Altera a animação ativa e configura flags e parâmetros de rotação (PlayerAnimation.as:278-364).
   */
  public showAnimation(animName: string, force: boolean = false): void {
    const target = animName ? animName.toUpperCase() : 'IDLE';

    if (this._currentAnimation !== target || force) {
      this._currentAnimation = target;
      this._currentFrame = 0;
      this._aimAnimation = false;
      this._animationDone = false;
      this._loopAnimation = false;
      this._helpAnimation = false;
      this._disableSlowmotionModifier = false;
      this._rotation = 0;

      switch (target) {
        case 'ROCKET_RIDE_L':
        case 'ROCKET_RIDE_R':
          this._loopAnimation = true;
          break;
        case 'AIM_TURN':
          this._disableSlowmotionModifier = true;
          break;
        case 'CLIMB':
        case 'IDLE':
        case 'STAGGER':
        case 'SPRINT':
        case 'GRABBED':
        case 'RUN':
          this._loopAnimation = true;
          break;
        case 'DIVE':
          this._helpAnimation = true;
          this._loopAnimation = true;
          this._rotateSpeed = 1.5;
          this._rotateIncrease = 0;
          break;
        case 'FALL_B':
        case 'FALL_F':
          this._helpAnimation = true;
          this._loopAnimation = true;
          if (target === 'FALL_B') {
            this._rotateSpeed = -10;
            this._rotateIncrease = -2;
          } else {
            this._rotateSpeed = 10;
            this._rotateIncrease = 2;
          }
          break;
        default:
          if (target.startsWith('AIM')) {
            this._aimAnimation = true;
            this._loopAnimation = true;
          }
          if (target.startsWith('START')) {
            this._disableSlowmotionModifier = true;
          }
          break;
      }
    }
  }

  /**
   * Avança a animação em dt ticks (PlayerAnimation.as:367-570).
   */
  public progressAnimation(dt: number = 1.0, totalFrames: number = 1): void {
    this.updateAnimation();

    if (!this._animationDone) {
      if (this._currentFrame === 0) {
        this._currentFrame = 1;
        return;
      }

      // 1. Rotação do HELPMC para DIVE e FALL
      if (this._helpAnimation) {
        this._rotation += this._rotateSpeed * dt;
        if (Math.abs(this._rotateSpeed) < 36) {
          this._rotateSpeed += this._rotateIncrease * dt;
        }
        this._currentFrame += dt;
      } else {
        this._currentFrame += dt;
      }

      // 2. Verificar fim do ciclo de animação (PlayerAnimation.as:531-544)
      const frameInt = Math.floor(this._currentFrame);
      if (frameInt > totalFrames) {
        this.animationDone();
        if (this._loopAnimation) {
          this._currentFrame = 1;
        } else {
          this._currentFrame = totalFrames;
          this._animationDone = true;
        }
      }
    } else {
      this.animationDone();
    }
  }

  /**
   * Reseta as flags de estado do jogador quando uma animação não-loop termina (PlayerAnimation.as:572-604).
   */
  public animationDone(): void {
    if (this._playerState.knockdowned) {
      this._playerState.knockdowned = false;
    }
    if (this._playerState.rolling) {
      this._playerState.rolling = false;
    }
    if (this._playerState.kicking) {
      this._playerState.kicking = false;
    }
    if (this._playerState.throwing) {
      this._playerState.throwing = false;
    }
    if (this._playerState.punching) {
      this._playerState.punching = false;
    }
    if (this._playerState.aimTurningAround) {
      this._playerState.aimTurningAround = false;
    }
    if (this._playerState.deathKneel) {
      this._playerState.falling = true;
      this._playerState.airVelocityX = this._playerState.lastDirX * 1.7;
      this._playerState.airVelocityY = -1.5;
    }
  }
}
