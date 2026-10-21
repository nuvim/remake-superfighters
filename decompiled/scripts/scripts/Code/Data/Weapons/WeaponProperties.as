package Code.Data.Weapons
{
   import Code.Data.ProjectileData;
   
   public class WeaponProperties
   {
      
      public var WeaponType:String;
      
      public var AnimType:String;
      
      public var WeaponCooldown:int;
      
      public var AccuracyDeflection:Number;
      
      public var AimSound:String;
      
      public var EmptySound:String;
      
      public var PickupSound:String;
      
      public var BulletType:String;
      
      public var PickupRadius:Number;
      
      public var LaserSight:Boolean;
      
      public var ShootRange:Number;
      
      public var LaserDeflection:Number;
      
      public var MuzzleFlashEffect:String;
      
      public var ShellEffect:String;
      
      public var FireSequence:Array = new Array();
      
      public var Projectile:ProjectileData;
      
      public function WeaponProperties()
      {
         super();
      }
   }
}

