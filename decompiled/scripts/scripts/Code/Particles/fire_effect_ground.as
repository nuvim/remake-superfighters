package Code.Particles
{
   [Embed(source="/_assets/assets.swf", symbol="symbol228")]
   public class fire_effect_ground extends particle_base
   {
      
      private var _a:Number;
      
      private var _posX:Number;
      
      private var _posY:Number;
      
      private var _velX:Number;
      
      public function fire_effect_ground(param1:particle_data)
      {
         super();
         this.gotoAndStop(Math.round(Math.random() * (this.totalFrames - 1)) + 1);
         this.scaleX = 1.25;
         this.scaleY = 1.25;
         this._a = 1;
         this._posX = param1.PosX;
         this._posY = param1.PosY - 2;
         this._velX = Math.random() - 0.5;
         this._velX *= 1.2;
         SetUpdateEvent(this.UpdateParticle);
      }
      
      private function UpdateParticle() : *
      {
         this._posX += game_speed * this._velX;
         this._a -= game_speed * 0.04;
         this._posY -= game_speed * 0.01;
         this.x = this._posX;
         this.y = this._posY;
         this.alpha = this._a;
         if(this._a <= 0.4)
         {
            EndParticle();
         }
      }
   }
}

