package Code.Data.Players
{
   import Code.Box2D.Dynamics.b2World;
   import Code.Data.Weapons.WeaponData;
   import Code.Data.Weapons.WeaponMeleeData;
   import Code.Data.Weapons.WeaponThrowableData;
   import Code.Handler.Effects;
   import Code.Handler.InputKeyboard;
   import Code.Handler.Maps;
   import Code.Handler.OutputTrace;
   import Code.Handler.PathGrid;
   import Code.Handler.ProjectilesUpdater;
   import Code.Handler.Shake;
   import Code.Handler.Slowmo;
   import Code.Handler.Sounds;
   import flash.display.MovieClip;
   
   public class PlayersKeeperData
   {
      
      public var stg:*;
      
      public var m_world:b2World;
      
      public var game_mc:MovieClip;
      
      public var pSetupData:PlayerSetupData;
      
      public var Handler_Projectiles:ProjectilesUpdater;
      
      public var Handler_Output:OutputTrace;
      
      public var Handler_Keyboard:InputKeyboard;
      
      public var Handler_Shake:Shake;
      
      public var Handler_Effects:Effects;
      
      public var Handler_Maps:Maps;
      
      public var Handler_Sounds:Sounds;
      
      public var Handler_Slowmo:Slowmo;
      
      public var pathGrid:PathGrid;
      
      public var rangedStartWeapon:WeaponData;
      
      public var throwableStartWeapon:WeaponThrowableData;
      
      public var meleeStartWeapon:WeaponMeleeData;
      
      public var defaultMeleeWeapon:WeaponMeleeData;
      
      public function PlayersKeeperData()
      {
         super();
      }
   }
}

