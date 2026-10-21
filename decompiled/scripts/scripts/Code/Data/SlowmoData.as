package Code.Data
{
   public class SlowmoData
   {
      
      private var _timeFadeIn:int;
      
      private var _timeStay:int;
      
      private var _timeFadeOut:int;
      
      private var _timeTotalDuration:int;
      
      private var _slowmotion:Number;
      
      private var _elapsedTime:int;
      
      private var _currentSlowmotion:Number;
      
      public function SlowmoData(param1:int, param2:int, param3:int, param4:Number)
      {
         super();
         this._timeFadeIn = param1;
         this._timeStay = param2;
         this._timeFadeOut = param3;
         this._timeTotalDuration = param1 + param2 + param3;
         this._slowmotion = param4;
         this._elapsedTime = 0;
      }
      
      public function ProgressTime(param1:int = 1) : void
      {
         this._elapsedTime += param1;
         if(this._elapsedTime < this._timeFadeIn)
         {
            this._currentSlowmotion = 1 - this._elapsedTime / this._timeFadeIn * (1 - this._slowmotion);
         }
         else if(this._elapsedTime <= this._timeFadeIn + this._timeStay)
         {
            this._currentSlowmotion = this._slowmotion;
         }
         else
         {
            this._currentSlowmotion = this._slowmotion + (this._elapsedTime - (this._timeFadeIn + this._timeStay)) / this._timeFadeOut * (1 - this._slowmotion);
         }
      }
      
      public function get CurrentSlowmotion() : Number
      {
         return this._currentSlowmotion;
      }
      
      public function get Completed() : Boolean
      {
         return this._elapsedTime >= this._timeTotalDuration;
      }
   }
}

