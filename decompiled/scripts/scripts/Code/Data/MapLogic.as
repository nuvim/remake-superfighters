package Code.Data
{
   import flash.utils.*;
   
   public class MapLogic
   {
      
      public var OnUpdate:Function;
      
      private var started:Boolean = false;
      
      private var refireInterval:int = 1000;
      
      private var updateTimer:Number;
      
      public function MapLogic()
      {
         super();
         this.OnUpdate = function():void
         {
         };
      }
      
      public function Start() : void
      {
         if(this.started)
         {
            this.Stop();
         }
         this.updateTimer = setInterval(this.OnUpdate,this.refireInterval);
         this.started = true;
      }
      
      public function Stop() : void
      {
         clearInterval(this.updateTimer);
         this.started = false;
      }
      
      public function get RefireInterval() : int
      {
         return this.refireInterval;
      }
      
      public function set RefireInterval(param1:int) : void
      {
         this.refireInterval = param1;
         if(this.started)
         {
            this.Start();
         }
      }
   }
}

