import { Container } from 'pixi.js';

export interface Rect {
  x: number;
  y: number;
  width: number;
  height: number;
}

export interface Point {
  x: number;
  y: number;
}

/**
 * Camera — Port literal 1:1 de Cam.as (linhas 9-226).
 * Controla a translação e zoom do container dynamicMc do PixiJS.
 */
export class Camera {
  public static readonly sizeIncrease: number = 40;

  private _dynamicMc: Container;
  private _shakeContainer: Container;
  private _mapArea: Rect;
  private _camArea: Rect;

  private _scaleTarget: number = 1;
  private _posTarget: Point = { x: 0, y: 0 };
  private _scaleSpeed: number = 0;
  private _posSpeed: Point = { x: 0, y: 0 };
  private _zoomStepsLeft: number = 0;

  private _showAll: boolean = true;
  private _camOverrideDone: boolean = true;

  // Screen shake
  private _shakeIntensity: number = 0;
  private _shakeTimer: number = 0;

  // Manual debug override
  public isManualControl: boolean = false;

  constructor(dynamicMc: Container, shakeContainer: Container, mapArea: Rect) {
    this._dynamicMc = dynamicMc;
    this._shakeContainer = shakeContainer;
    this._mapArea = { ...mapArea };
    this._camArea = { ...mapArea };

    // Iniciar exibindo o mapa enquadrado
    this.recalculateCamArea(1, true);
  }

  public get mapArea(): Rect {
    return this._mapArea;
  }

  public get camArea(): Rect {
    return this._camArea;
  }

  public setMapArea(area: Rect): void {
    this._mapArea = { ...area };
    this.recalculateCamArea(8, true);
  }

  public get showAll(): boolean {
    return this._showAll;
  }

  public set showAll(value: boolean) {
    this._showAll = value;
    this.recalculateCamArea(8, true);
  }

  public get currentScale(): number {
    return this._dynamicMc.scale.x;
  }

  public get currentPosition(): Point {
    return { x: this._dynamicMc.position.x, y: this._dynamicMc.position.y };
  }

  /**
   * RecalculateCamArea — Transcrição exata da linha 127 de Cam.as.
   * Calcula o retângulo de visão ideal e as velocidades de transição (_posSpeed, _scaleSpeed).
   */
  public recalculateCamArea(steps: number = 8, force: boolean = false, targetArea?: Rect): void {
    if (this.isManualControl && !force) {
      return;
    }

    if (!force) {
      if (!this._camOverrideDone) {
        return;
      }
    } else {
      this._camOverrideDone = false;
    }

    let rect: Rect;
    if (!this._showAll && targetArea) {
      rect = { ...targetArea };
    } else {
      rect = {
        x: this._mapArea.x,
        y: this._mapArea.y,
        width: this._mapArea.width,
        height: this._mapArea.height
      };
    }

    const incX = Camera.sizeIncrease * 4;
    const incY = Camera.sizeIncrease * 3;
    rect.x -= incX / 2;
    rect.y -= incY / 2;
    rect.width += incX;
    rect.height += incY;

    if (rect.width > this._mapArea.width) {
      rect.width = this._mapArea.width;
    }
    if (rect.height > this._mapArea.height) {
      rect.height = this._mapArea.height;
    }
    if (rect.x < this._mapArea.x) {
      rect.x = this._mapArea.x;
    }
    if (rect.x + rect.width > this._mapArea.x + this._mapArea.width) {
      rect.x = this._mapArea.x + this._mapArea.width - rect.width;
    }
    if (rect.y < this._mapArea.y) {
      rect.y = this._mapArea.y;
    }
    if (rect.y + rect.height > this._mapArea.y + this._mapArea.height) {
      rect.y = this._mapArea.y + this._mapArea.height - rect.height;
    }

    // Altura base padrão da janela do Flash: 600 px (Cam.as linha 180)
    const scaleFactor = 1 / (rect.height / 600);
    this._scaleTarget = scaleFactor;
    this._posTarget.x = -rect.x * scaleFactor;
    this._posTarget.y = -rect.y * scaleFactor;

    this._camArea = rect;
    this._zoomStepsLeft = steps;

    this._posSpeed.x = (this._posTarget.x - this._dynamicMc.position.x) / this._zoomStepsLeft;
    this._posSpeed.y = (this._posTarget.y - this._dynamicMc.position.y) / this._zoomStepsLeft;
    this._scaleSpeed = (this._scaleTarget - this._dynamicMc.scale.x) / this._zoomStepsLeft;
  }

  /**
   * Update — Transcrição exata da linha 212 de Cam.as.
   * Aplica a translação e zoom suavemente por timestep.
   */
  public update(dtSpeed: number = 1): void {
    if (!this.isManualControl && this._zoomStepsLeft > 0) {
      this._dynamicMc.position.x += this._posSpeed.x * dtSpeed;
      this._dynamicMc.position.y += this._posSpeed.y * dtSpeed;
      this._dynamicMc.scale.x += this._scaleSpeed * dtSpeed;
      this._dynamicMc.scale.y += this._scaleSpeed * dtSpeed;

      this._zoomStepsLeft -= 1 * dtSpeed;
      if (this._zoomStepsLeft <= 0) {
        this._dynamicMc.position.x = this._posTarget.x;
        this._dynamicMc.position.y = this._posTarget.y;
        this._dynamicMc.scale.set(this._scaleTarget);
        this._camOverrideDone = true;
      }
    }

    // Screen Shake
    if (this._shakeTimer > 0) {
      this._shakeTimer -= dtSpeed;
      const ox = (Math.random() * 2 - 1) * this._shakeIntensity;
      const oy = (Math.random() * 2 - 1) * this._shakeIntensity;
      this._shakeContainer.position.set(ox, oy);
      if (this._shakeTimer <= 0) {
        this._shakeContainer.position.set(0, 0);
        this._shakeIntensity = 0;
      }
    }
  }

  public shake(intensity: number = 5, durationFrames: number = 10): void {
    this._shakeIntensity = intensity;
    this._shakeTimer = durationFrames;
  }

  // Debug: Pan manual
  public manualPan(dx: number, dy: number): void {
    this.isManualControl = true;
    this._dynamicMc.position.x += dx;
    this._dynamicMc.position.y += dy;
  }

  // Debug: Zoom manual
  public manualZoom(factor: number): void {
    this.isManualControl = true;
    const newScale = Math.max(0.5, Math.min(4.0, this._dynamicMc.scale.x * factor));
    this._dynamicMc.scale.set(newScale);
  }

  // Debug: Resetar câmera para o enquadramento original
  public resetCamera(): void {
    this.isManualControl = false;
    this.recalculateCamArea(8, true);
  }
}
