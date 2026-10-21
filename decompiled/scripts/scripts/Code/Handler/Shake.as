package Code.Handler
{
   import flash.display.MovieClip;
   
   public class Shake
   {
      
      private var _Handler_Output:OutputTrace;
      
      private var _shake_mc:MovieClip;
      
      private var _shakeTimer:Number = 0;
      
      private var _shakeMangitude:Number = 0;
      
      private var _lastRnd:Number = 0;
      
      private var _tarX:Number = 0;
      
      private var _tarY:Number = 0;
      
      private var _speedX:Number = 0;
      
      private var _speedY:Number = 0;
      
      public function Shake(param1:OutputTrace, param2:MovieClip)
      {
         super();
         this._Handler_Output = param1;
         this._shake_mc = param2;
      }
      
      public function Add(param1:Number, param2:Number) : void
      {
         this._shakeTimer += param1;
         this._shakeMangitude += param2;
         if(this._shakeMangitude > 30)
         {
            this._shakeMangitude = 30;
         }
         if(this._shakeTimer > 20)
         {
            this._shakeTimer = 20;
         }
      }
      
      public function Update(param1:Number) : void
      {
         if(this._shakeTimer > 0)
         {
            if(this._lastRnd != Math.floor(this._shakeTimer))
            {
               this._tarX = Math.random() * this._shakeMangitude - this._shakeMangitude / 2;
               this._tarY = Math.random() * this._shakeMangitude - this._shakeMangitude / 2;
               this._speedX = this._tarX - this._shake_mc.x;
               this._speedY = this._tarY - this._shake_mc.y;
               this._lastRnd = Math.floor(this._shakeTimer);
            }
            this._shake_mc.x += this._speedX * param1;
            this._shake_mc.y += this._speedY * param1;
            this._shakeTimer -= param1;
            if(this._shakeTimer <= 0)
            {
               this._shakeTimer = 0;
               this._shake_mc.x = 0;
               this._shake_mc.y = 0;
               this._lastRnd = 0;
               this._shakeTimer = 0;
               this._shakeMangitude = 0;
            }
         }
      }
   }
}

