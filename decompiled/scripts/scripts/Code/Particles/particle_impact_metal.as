package Code.Particles
{
   [Embed(source="/_assets/assets.swf", symbol="symbol118")]
   public class particle_impact_metal extends particle_base
   {
      
      private var Scale:Number = 0;
      
      private var speedY:Number = 0;
      
      private var speedX:Number = 0;
      
      public function particle_impact_metal(param1:particle_data)
      {
         super();
         this.speedX = param1.ParticleVec.x;
         this.speedY = param1.ParticleVec.y;
         var _loc2_:Number = Math.sqrt(this.speedX * this.speedX + this.speedY * this.speedY);
         if(_loc2_ > 1)
         {
            this.speedX *= 1 / _loc2_;
            this.speedY *= 1 / _loc2_;
         }
         this.Scale = 0.7;
         this.scaleX = this.Scale;
         this.scaleY = this.Scale;
         this.alpha = 0.7;
         SetUpdateEvent(this.UpdateParticle);
      }
      
      private function UpdateParticle() : *
      {
         this.y += this.speedY * game_speed;
         this.x += this.speedX * game_speed;
         this.alpha -= 0.1 * game_speed;
         if(this.alpha <= 0)
         {
            EndParticle();
         }
      }
   }
}

