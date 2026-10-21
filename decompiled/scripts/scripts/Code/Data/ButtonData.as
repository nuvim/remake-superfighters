package Code.Data
{
   public class ButtonData
   {
      
      public var OnActivation:Function;
      
      public var OnActivationSound:String = "";
      
      public var Enabled:Boolean = true;
      
      public function ButtonData()
      {
         super();
         this.OnActivation = function():void
         {
         };
      }
      
      public function Activate() : void
      {
         this.OnActivation();
      }
   }
}

