package Code.Particles
{
   [Embed(source="/_assets/assets.swf", symbol="symbol694")]
   public class blood_gib_trace extends particle_base
   {
      
      private var _a:Number;
      
      private var _s:Number;
      
      public function blood_gib_trace(param1:particle_data)
      {
         super();
         this._a = 1;
         this._s = 1;
         SetUpdateEvent(this.UpdateParticle);
      }
      
      private function UpdateParticle() : *
      {
         this._a -= game_speed * 0.07;
         this._s += game_speed * 0.04;
         this.alpha = this._a;
         this.scaleX = this._s;
         this.scaleY = this._s;
         if(this._a <= 0.4)
         {
            EndParticle();
         }
      }
   }
}

