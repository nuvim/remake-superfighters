package Code.Particles
{
   [Embed(source="/_assets/assets.swf", symbol="symbol97")]
   public class particle_impact_wood extends particle_base
   {
      
      private var Scale:Number = 0;
      
      private var speedY:Number = 0;
      
      private var speedX:Number = 0;
      
      public function particle_impact_wood(param1:particle_data)
      {
         super();
         this.speedX = param1.ParticleVec.x * 0.1;
         if(Math.sqrt(this.speedX * this.speedX) > 1)
         {
            this.speedX /= Math.sqrt(this.speedX * this.speedX);
         }
         this.speedY = -0.1;
         this.Scale = 0.7;
         this.scaleX = this.Scale;
         this.scaleY = this.Scale;
         this.alpha = 0.5;
         SetUpdateEvent(this.UpdateParticle);
      }
      
      private function UpdateParticle() : *
      {
         this.speedY += 0.025 * game_speed;
         this.y += this.speedY * game_speed;
         this.x += this.speedX * game_speed;
         this.alpha -= 0.03 * game_speed;
         this.scaleX += 0.03 * game_speed;
         this.scaleY += 0.03 * game_speed;
         if(this.alpha <= 0)
         {
            EndParticle();
         }
      }
   }
}

