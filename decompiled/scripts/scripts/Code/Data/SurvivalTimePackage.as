package Code.Data
{
   public class SurvivalTimePackage
   {
      
      public var totalMins:int;
      
      public var totalSecs:int;
      
      public var totalParts:int;
      
      public var wave:int;
      
      public var kills:int;
      
      public var dmgbonus:int;
      
      public function SurvivalTimePackage()
      {
         super();
         this.totalMins = 0;
         this.totalSecs = 0;
         this.totalParts = 0;
         this.wave = 0;
         this.kills = 0;
         this.dmgbonus = 0;
      }
      
      public static function CalculateWaveScore(param1:SurvivalTimePackage) : Number
      {
         return param1.wave * 100;
      }
      
      public static function CalculateKillsScore(param1:SurvivalTimePackage) : Number
      {
         return param1.kills * 500;
      }
      
      public static function CalculateDmgBonusScore(param1:SurvivalTimePackage) : Number
      {
         return param1.dmgbonus * 5;
      }
      
      public static function CalculateTimeScore(param1:SurvivalTimePackage) : Number
      {
         return Math.round((param1.totalMins * 60 + param1.totalSecs + param1.totalParts * 0.01) * 50);
      }
      
      public static function CalculateTotalScore(param1:SurvivalTimePackage) : Number
      {
         return CalculateWaveScore(param1) + CalculateKillsScore(param1) + CalculateDmgBonusScore(param1) + CalculateTimeScore(param1);
      }
   }
}

