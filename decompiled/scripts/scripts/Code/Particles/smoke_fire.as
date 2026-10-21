package Code.Particles
{
   import flash.display.MovieClip;
   
   public class smoke_fire extends particle_base
   {
      
      private var _mc:MovieClip;
      
      private var _a:Number;
      
      private var _posY:Number;
      
      private var _posX:Number;
      
      private var _s:Number;
      
      private var _speedX:Number;
      
      private var _speedY:Number;
      
      public function smoke_fire(param1:particle_data)
      {
         super();
         this._mc = new smoke_trace_01();
         this._a = 0.8;
         this._mc.alpha = this._a;
         this._posX = 0;
         this._posY = 0;
         this._speedX = 0;
         this._speedY = -2;
         this._s = 0.8;
         this.addChild(this._mc);
         SetUpdateEvent(this.UpdateParticle);
      }
      
      private function UpdateParticle() : *
      {
         this._posX += this._speedX * game_speed;
         this._posY += this._speedY * game_speed;
         this._a -= game_speed * 0.04;
         this._s += game_speed * 0.01;
         if(this._a <= 0)
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

