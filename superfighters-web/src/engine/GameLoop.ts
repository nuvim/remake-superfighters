/**
 * GameLoop.ts — Loop de jogo a 30 Hz fixo com acumulador.
 * 
 * Regra F2 do Remake:
 * O jogo original roda estritamente a 30 Hz (GameMain.as:847, m_timeStep = 1 / (30 / Slowmotion)).
 * O renderizador PixiJS roda livre a 60+ Hz (rAF), enquanto a lógica e a física
 * avançam em fatias fixas de 1/30s (0.03333s).
 */
export class GameLoop {
  /**
   * Passo de tempo fixo de lógica: 1/30 s (33.333 ms), idêntico a GameMain.as:154.
   */
  public static readonly FIXED_TIMESTEP: number = 1 / 30; // 0.03333333333333333

  /**
   * Limite máximo de tempo acumulado por frame (evita o "spiral of death" se houver lag).
   */
  public static readonly MAX_ACCUMULATOR: number = 0.25;

  private _accumulator: number = 0;
  private _lastTime: number = 0;
  private _isRunning: boolean = false;

  // Estatísticas de performance
  private _logicTicksThisSecond: number = 0;
  private _fpsThisSecond: number = 0;
  private _lastStatsUpdate: number = 0;
  public logicHz: number = 30;
  public renderFps: number = 60;

  // Callbacks
  public onLogicUpdate?: (dt: number) => void;
  public onRender?: (alpha: number) => void;

  constructor() {
    this._lastStatsUpdate = performance.now();
  }

  /**
   * Inicia o loop de jogo.
   * @param initialTimeMs Timestamp inicial opcional (padrão: performance.now())
   */
  public start(initialTimeMs?: number): void {
    if (this._isRunning) return;
    this._isRunning = true;
    this._lastTime = initialTimeMs !== undefined ? initialTimeMs : performance.now();
    this._accumulator = 0;
  }

  /**
   * Pausa o loop de jogo.
   */
  public stop(): void {
    this._isRunning = false;
  }

  /**
   * Processa um frame a partir de um delta externo (ex: Pixi Ticker ou requestAnimationFrame).
   * @param currentTimeMs Timestamp atual em milissegundos (ex: performance.now())
   */
  public update(currentTimeMs: number): void {
    if (!this._isRunning) return;

    if (this._lastTime === 0) {
      this._lastTime = currentTimeMs;
      return;
    }

    let deltaSec = (currentTimeMs - this._lastTime) / 1000.0;
    this._lastTime = currentTimeMs;

    // Prevenir saltos gigantes se a aba ficar em background
    if (deltaSec > GameLoop.MAX_ACCUMULATOR) {
      deltaSec = GameLoop.MAX_ACCUMULATOR;
    }

    this._accumulator += deltaSec;
    this._fpsThisSecond++;

    // Executa fatias fixas de 30 Hz
    while (this._accumulator >= GameLoop.FIXED_TIMESTEP) {
      if (this.onLogicUpdate) {
        this.onLogicUpdate(GameLoop.FIXED_TIMESTEP);
      }
      this._accumulator -= GameLoop.FIXED_TIMESTEP;
      this._logicTicksThisSecond++;
    }

    // Alpha para interpolação visual entre estados físicos (0.0 a 1.0)
    const alpha = this._accumulator / GameLoop.FIXED_TIMESTEP;
    if (this.onRender) {
      this.onRender(alpha);
    }

    // Cálculo das métricas a cada segundo
    if (currentTimeMs - this._lastStatsUpdate >= 1000) {
      this.logicHz = this._logicTicksThisSecond;
      this.renderFps = this._fpsThisSecond;
      this._logicTicksThisSecond = 0;
      this._fpsThisSecond = 0;
      this._lastStatsUpdate = currentTimeMs;
    }
  }

  public get isRunning(): boolean {
    return this._isRunning;
  }
}
