package Code.Particles
{
   import flash.display.MovieClip;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol431")]
   public class fire_effect_flamethrower extends particle_base
   {
      
      private var _a:Number;
      
      private var _posX:Number;
      
      private var _posY:Number;
      
      private var _velX:Number;
      
      private var _velY:Number;
      
      private var _percentage:Number;
      
      private var _mc:MovieClip;
      
      public function fire_effect_flamethrower(param1:particle_data)
      {
         super();
         this.scaleX = 1;
         this.scaleY = 1;
         this._mc = new fire_01_flamethrower();
         this.addChild(this._mc);
         this._a = 1;
         this._posX = param1.PosX;
         this._posY = param1.PosY;
         this._velX = param1.ParticleVec.x;
         this._velX *= 0.16;
         this._velY = param1.ParticleVec.y - 0.4;
         this._velY *= 0.16;
         SetUpdateEvent(this.UpdateParticle);
      }
      
      private function UpdateParticle() : *
      {
         this._posY += game_speed * this._velY;
         this._posX += game_speed * this._velX;
         this._a -= game_speed * 0.07;
         this._velY -= game_speed * 0.2;
         this.y = this._posY;
         this.x = this._posX;
         this.alpha = this._a;
         if(this._a <= 0.4)
         {
            EndParticle();
         }
         else
         {
            this._percentage = 1 - (this._a - 0.4) / 0.6;
            this._mc.gotoAndStop(Math.ceil(this._mc.totalFrames * this._percentage));
         }
      }
   }
}

