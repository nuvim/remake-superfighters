package Code.Data.Weapons
{
   public class WeaponSequencePart
   {
      
      public var Bullets:int;
      
      public var UseMuzzleEffect:Boolean;
      
      public var UseShellEffect:Boolean;
      
      public var FrameSound:String;
      
      public var FrameNr:int;
      
      public var End:Boolean;
      
      public function WeaponSequencePart(param1:int = 0, param2:Boolean = false, param3:Boolean = false, param4:String = "NONE", param5:int = 1, param6:Boolean = false)
      {
         super();
         this.Bullets = param1;
         this.UseMuzzleEffect = param2;
         this.UseShellEffect = param3;
         this.FrameSound = param4;
         this.FrameNr = param5;
         this.End = param6;
      }
   }
}

