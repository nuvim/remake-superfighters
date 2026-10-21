package Code.Particles
{
   import flash.display.MovieClip;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol90")]
   public class smoke_trace_effect extends particle_base
   {
      
      private var _mc:MovieClip;
      
      private var _a:Number;
      
      private var _posY:Number;
      
      private var _posX:Number;
      
      private var _s:Number;
      
      private var _speedX:Number;
      
      private var _speedY:Number;
      
      public function smoke_trace_effect(param1:particle_data)
      {
         super();
         if(param1.DataArray[0] == 2)
         {
            this._mc = new smoke_trace_01();
         }
         else if(param1.DataArray[0] == 1)
         {
            this._mc = new smoke_trace_light_01();
         }
         else
         {
            this._mc = new error_mc();
         }
         this._a = 0.6;
         this._mc.alpha = this._a;
         this._posX = 0;
         this._posY = 0;
         this._speedX = param1.ParticleVec.x * 0.1;
         this._speedY = param1.ParticleVec.y * 0.1;
         this._s = 0.8;
         this.addChild(this._mc);
         SetUpdateEvent(this.UpdateParticle);
      }
      
      private function UpdateParticle() : *
      {
         this._posX += this._speedX * game_speed;
         this._posY += (this._speedY - 0.5) * game_speed;
         this._a -= game_speed * 0.05;
         this._s += game_speed * 0.02;
         if(this._a <= 0.1)
         {
            EndParticle();
         }
         else
         {
            this._mc.scaleX = this._s;
            this._mc.scaleY = this._s;
            this._mc.alpha = this._a;
            this._mc.x = this._posX;
            this._mc.y = this._posY;
         }
      }
   }
}

