package Code.Particles
{
   import flash.display.MovieClip;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol91")]
   public class fire_effect extends particle_base
   {
      
      private var _a:Number;
      
      private var _posX:Number;
      
      private var _posY:Number;
      
      private var _velX:Number;
      
      private var _percentage:Number;
      
      private var _mc:MovieClip;
      
      public function fire_effect(param1:particle_data)
      {
         super();
         this.scaleX = 1.25;
         this.scaleY = 1.25;
         var _loc2_:Number = Math.round(Math.random() * 2) + 1;
         switch(_loc2_)
         {
            case 1:
               this._mc = new fire_01();
               break;
            case 2:
               this._mc = new fire_02();
               break;
            case 3:
               this._mc = new fire_03();
         }
         this.addChild(this._mc);
         this._a = 1;
         this._posX = param1.PosX;
         this._posY = param1.PosY;
         this._velX = Math.random() - 0.5;
         this._velX *= 0.7;
         SetUpdateEvent(this.UpdateParticle);
      }
      
      private function UpdateParticle() : *
      {
         this._posY -= game_speed * 1.2;
         this._posX += game_speed * this._velX;
         this._a -= game_speed * 0.04;
         this.y = this._posY;
         this.x = this._posX;
         this.alpha = this._a;
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

