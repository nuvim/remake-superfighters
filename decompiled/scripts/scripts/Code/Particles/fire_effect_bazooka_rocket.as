package Code.Particles
{
   import flash.display.MovieClip;
   
   public class fire_effect_bazooka_rocket extends particle_base
   {
      
      private var _a:Number;
      
      private var _posX:Number;
      
      private var _posY:Number;
      
      private var _velX:Number;
      
      private var _velY:Number;
      
      private var _percentage:Number;
      
      private var _s:Number;
      
      private var _mc:MovieClip;
      
      public function fire_effect_bazooka_rocket(param1:particle_data)
      {
         super();
         this._mc = new trace_bazooka_rocket();
         this.addChild(this._mc);
         this._a = 1;
         this._s = 1;
         this.scaleX = this._s;
         this.scaleY = this._s;
         this._posX = param1.PosX;
         this._posY = param1.PosY;
         this._velX = param1.ParticleVec.x + Math.random() * 2 - 1;
         this._velX *= 0.4;
         this._velY = param1.ParticleVec.y - Math.random();
         this._velY *= 0.4;
         SetUpdateEvent(this.UpdateParticle);
      }
      
      private function UpdateParticle() : *
      {
         this._posY += game_speed * this._velY;
         this._posX += game_speed * this._velX;
         this._a -= game_speed * 0.04;
         this._velY -= game_speed * 0.15;
         this._s += game_speed * 0.03;
         this.y = this._posY;
         this.x = this._posX;
         this.alpha = this._a;
         this.scaleX = this._s;
         this.scaleY = this._s;
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

