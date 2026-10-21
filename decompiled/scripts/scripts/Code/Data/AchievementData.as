package Code.Data
{
   public class AchievementData
   {
      
      public var Name:String;
      
      public var Key:String;
      
      public var Earned:Boolean;
      
      public var IconIndex:Number;
      
      public function AchievementData(param1:String, param2:String, param3:Boolean, param4:Number)
      {
         super();
         this.Name = param1;
         this.Key = param2;
         this.Earned = param3;
         this.IconIndex = param4;
      }
   }
}

