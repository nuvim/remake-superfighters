package Code.Particles
{
   import flash.display.MovieClip;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol502")]
   public class particle_blood extends particle_base
   {
      
      private var _a:Number;
      
      private var _posX:Number;
      
      private var _posY:Number;
      
      private var _velX:Number;
      
      private var _velY:Number;
      
      private var _mc:MovieClip;
      
      public function particle_blood(param1:particle_data)
      {
         super();
         this._velX = Math.random() * 1 - 0.5 + param1.ParticleVec.x;
         this._velY = Math.random() * 0.8 - 2;
         this._posX = 0;
         this._posY = 0;
         this._a = 1;
         switch(param1.DataArray[0])
         {
            case 0:
               this._mc = new blood_particle_big();
               break;
            case 1:
               this._mc = new blood_particle_small();
               break;
            default:
               this._mc = new blood_particle_small();
         }
         this.addChild(this._mc);
         SetUpdateEvent(this.UpdateParticle);
      }
      
      private function UpdateParticle() : *
      {
         this._velY += 0.3 * game_speed;
         this._posX += this._velX * game_speed;
         this._posY += this._velY * game_speed;
         this._mc.x = this._posX;
         this._mc.y = this._posY;
         this._a -= 0.04 * game_speed;
         if(this._a < 0.5)
         {
            this._mc.alpha = 1 - (0.5 - this._a) / 0.3;
         }
         if(this._a <= 0.2)
         {
            EndParticle();
         }
      }
   }
}

