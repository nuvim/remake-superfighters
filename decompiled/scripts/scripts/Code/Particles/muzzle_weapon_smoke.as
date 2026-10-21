package Code.Particles
{
   import flash.display.MovieClip;
   
   public class muzzle_weapon_smoke extends particle_base
   {
      
      private var _a:Number;
      
      private var _s:Number;
      
      private var _posX:Number;
      
      private var _posY:Number;
      
      private var _velX:Number;
      
      private var _velY:Number;
      
      private var _changeX:Number;
      
      private var _changeY:Number;
      
      private var _mc:MovieClip;
      
      public function muzzle_weapon_smoke(param1:particle_data)
      {
         super();
         this._changeX = Math.cos(param1.Rotation * (Math.PI / 180)) * 0.05;
         this._changeY = Math.sin(param1.Rotation * (Math.PI / 180)) * 0.07;
         this._velX = 0.4 + Math.random() * 0.3;
         this._velY = Math.random() * 0.6 - 0.3;
         this._posX = 0;
         this._posY = 0;
         this._a = 0.7;
         this._s = 1;
         this._mc = new smoke_weapon_muzzle();
         this._mc.alpha = 0.6;
         this.addChild(this._mc);
         SetUpdateEvent(this.UpdateParticle);
      }
      
      private function UpdateParticle() : *
      {
         this._velY -= this._changeX * game_speed;
         this._velX -= this._changeY * game_speed;
         this._posX += this._velX * game_speed;
         this._posY += this._velY * game_speed;
         this._mc.x = this._posX;
         this._mc.y = this._posY;
         this._a -= 0.05 * game_speed;
         this._s += 0.04 * game_speed;
         this._mc.alpha = this._a;
         this._mc.scaleX = this._s;
         this._mc.scaleY = this._s;
         if(this._a <= 0.1)
         {
            EndParticle();
         }
      }
   }
}

