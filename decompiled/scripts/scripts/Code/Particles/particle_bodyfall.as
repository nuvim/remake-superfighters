package Code.Particles
{
   [Embed(source="/_assets/assets.swf", symbol="symbol453")]
   public class particle_bodyfall extends particle_base
   {
      
      private var Scale:Number = 0;
      
      private var speedY:Number = 0;
      
      private var speedX:Number = 0;
      
      public function particle_bodyfall(param1:particle_data)
      {
         super();
         this.speedX = Math.random() * 0.4 - 0.2;
         this.speedY = Math.random() * 0.6 - 0.4;
         this.Scale = 1;
         this.scaleX = this.Scale;
         this.scaleY = this.Scale;
         this.alpha = 0.5;
         SetUpdateEvent(this.UpdateParticle);
      }
      
      private function UpdateParticle() : *
      {
         this.speedY += 0.002 * game_speed;
         this.y += this.speedY * game_speed;
         this.x += this.speedX * game_speed;
         this.alpha -= 0.04 * game_speed;
         this.Scale += 0.04 * game_speed;
         this.scaleX = this.Scale;
         this.scaleY = this.Scale;
         if(this.alpha <= 0.1)
         {
            EndParticle();
         }
      }
   }
}

