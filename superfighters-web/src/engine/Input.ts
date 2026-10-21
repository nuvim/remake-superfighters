/**
 * Input.ts — Sistema de captura de entrada desacoplado e mapeado para o teclado original.
 * Espelha as ações de Code/Data/Players/Player.as (KEY_UP, KEY_DOWN, KEY_LEFT, KEY_RIGHT, KEY_MELEE, etc.)
 * e Code/Handler/InputKeyboard.as.
 */
export interface PlayerInputActions {
  left: boolean;
  right: boolean;
  up: boolean;
  down: boolean;
  jump: boolean;
  sprint: boolean;
  crouch: boolean;
  melee: boolean;
  fire: boolean;
  throw: boolean;
  dive: boolean;
}

export class InputManager {
  private _keysDown: Set<string> = new Set();
  private _keysJustPressed: Set<string> = new Set();
  private _keysJustReleased: Set<string> = new Set();

  constructor() {
    this.setupListeners();
  }

  private setupListeners(): void {
    window.addEventListener('keydown', (e) => {
      const code = e.code;
      if (!this._keysDown.has(code)) {
        this._keysJustPressed.add(code);
      }
      this._keysDown.add(code);
    });

    window.addEventListener('keyup', (e) => {
      const code = e.code;
      this._keysDown.delete(code);
      this._keysJustReleased.add(code);
    });
  }

  /**
   * Reseta os estados transientes (just pressed / released) no final de cada frame.
   */
  public endFrame(): void {
    this._keysJustPressed.clear();
    this._keysJustReleased.clear();
  }

  public isKeyDown(code: string): boolean {
    return this._keysDown.has(code);
  }

  public isKeyJustPressed(code: string): boolean {
    return this._keysJustPressed.has(code);
  }

  /**
   * Mapeamento de ações do Jogador 1.
   * Suporta controles modernos (WASD + Setas + J/K/L / N/M) compatíveis com o original.
   */
  public getPlayer1Actions(): PlayerInputActions {
    const left = this.isKeyDown('KeyA') || this.isKeyDown('ArrowLeft');
    const right = this.isKeyDown('KeyD') || this.isKeyDown('ArrowRight');
    const up = this.isKeyDown('KeyW') || this.isKeyDown('ArrowUp');
    const down = this.isKeyDown('KeyS') || this.isKeyDown('ArrowDown');
    const sprint = this.isKeyDown('ShiftLeft') || this.isKeyDown('ShiftRight');
    const jump = this.isKeyDown('KeyW') || this.isKeyDown('ArrowUp') || this.isKeyDown('Space');
    const crouch = this.isKeyDown('KeyS') || this.isKeyDown('ArrowDown');
    const melee = this.isKeyDown('KeyJ') || this.isKeyDown('KeyN');
    const fire = this.isKeyDown('KeyK') || this.isKeyDown('KeyM');
    const throwWpn = this.isKeyDown('KeyL') || this.isKeyDown('Comma');
    const dive = (sprint && jump) || (sprint && (left || right));

    return {
      left,
      right,
      up,
      down,
      jump,
      sprint,
      crouch,
      melee,
      fire,
      throw: throwWpn,
      dive
    };
  }
}
