/**
 * PlayerState.ts — Transcrição literal de Code/Data/Players/PlayerState.as
 * Todas as constantes possuem citação direta de linha do código ActionScript 3 original.
 */
export class PlayerState {
  // Constantes de tempo e imunidade
  public static readonly KNOCKDOWN_IMMUNITY_TIME: number = 10; // PlayerState.as:10

  // Constantes físicas fundamentais
  public static readonly PLAYER_GRAVITY: number = 0.6; // PlayerState.as:12
  public static readonly PLAYER_JUMP_POWER: number = -5.0; // PlayerState.as:20
  public static readonly PLAYER_JUMP_PUSH_POWER: number = -0.7; // PlayerState.as:24
  public static readonly PLAYER_JUMP_PUSH_TIME: number = 4; // PlayerState.as:30
  public static readonly PLAYER_WALL_JUMP_POWER: number = -5.0; // PlayerState.as:34
  public static readonly FALL_TRIGGER_SPEED: number = 8.5; // PlayerState.as:36
  public static readonly STAGGER_SPEED: number = 1.0; // PlayerState.as:38
  public static readonly ROLL_SPEED: number = 2.0; // PlayerState.as:40
  public static readonly DIVE_SPEED: number = 3.5; // PlayerState.as:42
  public static readonly CLIMB_SPEED: number = 1.5; // PlayerState.as:80
  public static readonly SLIDE_SPEED: number = 3.0; // PlayerState.as:82
  public static readonly RUN_SPEED: number = 1.7; // PlayerState.as:176
  public static readonly SPRINT_ENERGY_MAX: number = 100; // PlayerState.as:220
  public static readonly MAX_HEALTH: number = 100; // PlayerState.as:286
  public static readonly MASS: number = 0.7; // PlayerState.as:50
  public static readonly KICK_DAMAGE: number = 4; // PlayerState.as:132
  public static readonly JUMP_KICK_DAMAGE: number = 4; // PlayerState.as:134

  // Geometria da hitbox física do personagem (-6 a +6 em X, -18 a +2 em Y, Player.as:265-270)
  public static readonly HITBOX_WIDTH: number = 12; // Player.as:265 (-6 a 6)
  public static readonly HITBOX_HEIGHT: number = 20; // Player.as:266 (-18 a 2)
  public static readonly PIVOT_X: number = 24; // Ponto pivô original do Flash
  public static readonly PIVOT_Y: number = 28;

  // Dimensões do corpo canônicas de PlayerState.as
  public playerEdgeDistance: number = 6; // PlayerState.as:16 (6px mantido para estabilidade de rampas/caixas)

  /**
   * MaxPlayerHeight getter 1:1 com PlayerState.as:430-433
   */
  public get maxPlayerHeight(): number {
    return 18;
  }

  /**
   * PlayerHeight getter 1:1 com PlayerState.as:435-460
   */
  public get playerHeight(): number {
    if (this.diving) return 8;
    if (this.knockdowned) return 10;
    if (this.falling) return 12;
    if (this.rolling) return 14;
    if (this.kneeling || this.takingCover) return 12;
    return 18;
  }

  // Estado vital
  public hp: number = PlayerState.MAX_HEALTH;
  public sprintEnergy: number = PlayerState.SPRINT_ENERGY_MAX;
  public team: number = 0;
  public charNr: number = 0; // 0 = Billy

  // Posição e velocidade (coordenadas de tela em pixels)
  public posX: number = 0;
  public posY: number = 0;
  public airVelocityX: number = 0;
  public airVelocityY: number = 0;

  /**
   * TotalAirVelocity getter 1:1 com PlayerState.as:1605-1608
   */
  public get totalAirVelocity(): number {
    return Math.sqrt(this.airVelocityX * this.airVelocityX + this.airVelocityY * this.airVelocityY);
  }

  // Direção de movimento (-1: esquerda, 0: parado, 1: direita)
  public movingDirectionX: number = 0;
  public lastDirX: number = 1; // 1 = direita, -1 = esquerda (Player.as:398)

  // Flags de controle de movimento e estado físico
  public jumping: boolean = false;
  public falling: boolean = false;
  public climbing: boolean = false;

  /**
   * OnGround getter 1:1 com PlayerState.as:636-643
   * return !this._falling && !this._jumping && !this._climbing;
   */
  public get onGround(): boolean {
    return !this.falling && !this.jumping && !this.climbing;
  }

  /**
   * Compatibilidade com interfaces anteriores
   */
  public get isGrounded(): boolean {
    return this.onGround;
  }

  public set isGrounded(val: boolean) {
    if (!val) {
      this.jumping = true;
    } else {
      this.jumping = false;
      this.falling = false;
      this.climbing = false;
    }
  }
  public climbingDirection: number = 0; // 1: descendo, -1: subindo
  public sprinting: boolean = false;
  public punching: boolean = false;
  public diving: boolean = false;
  public rolling: boolean = false;
  public kneeling: boolean = false;
  public takingCover: boolean = false;
  public kicking: boolean = false;
  public jumpKickPerformed: boolean = false;
  public knockdowned: boolean = false;
  public deathKneel: boolean = false;
  public staggering: boolean = false;
  public aiming: boolean = false;
  public aimMode: number = 0; // 0 = normal, 1 = throwable
  public aimTurningAround: boolean = false;
  public currentAimPitch: number = 0; // Graus de inclinação da mira
  public ignoreMe: boolean = false;
  public stuckToRocket: boolean = false;
  public grabbedByPlayer: boolean = false;
  public isStunned: boolean = false;
  public stunAnimation: number = 1;
  public throwing: boolean = false;
  public isImmune: boolean = false;
  public immunityTimer: number = 0;

  // Timers internos de física
  public jumpPushTimeLeft: number = 0;
  public rollTimer: number = 0;
  public diveTimer: number = 0;
  public punchComboNr: number = 1;
  public meleeAnimation: string = 'PUNCH'; // 'PUNCH', 'MACHETE', 'AXE', 'SWORD'

  // Animação ativa
  public currentAnimationLabel: string = 'IDLE';

  constructor(x: number = 0, y: number = 0) {
    this.posX = x;
    this.posY = y;
  }

  /**
   * Diminui temporizadores a cada tick lógico de 30 Hz.
   */
  public updateTimers(): void {
    if (this.immunityTimer > 0) {
      this.immunityTimer--;
      if (this.immunityTimer <= 0) {
        this.isImmune = false;
      }
    }
  }
}
