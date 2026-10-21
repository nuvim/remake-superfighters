package Code.Data.Weapons
{
   public class WeaponData
   {
      
      private var w_properties:WeaponProperties;
      
      private var w_ammo:int;
      
      private var w_infinite_ammo:Boolean;
      
      public function WeaponData(param1:int, param2:WeaponProperties, param3:Boolean = false)
      {
         super();
         this.w_ammo = param1;
         this.w_properties = param2;
         this.w_infinite_ammo = param3;
      }
      
      public function set InfiniteAmmo(param1:Boolean) : void
      {
         this.w_infinite_ammo = param1;
      }
      
      public function get TotalDamage() : Number
      {
         if(this.Properties.WeaponType == "FLAMETHROWER")
         {
            return this.Ammo * 1;
         }
         return this.Ammo * this.Properties.Projectile.AverageDamage;
      }
      
      public function get TotalKnockdown() : Number
      {
         if(this.Properties.WeaponType == "FLAMETHROWER")
         {
            return 0;
         }
         return this.Ammo * this.Properties.Projectile.Properties.PushbackPower + this.Properties.Projectile.Properties.CriticalChance;
      }
      
      public function get CanShootDown() : Boolean
      {
         switch(this.Properties.WeaponType)
         {
            case "FLAMETHROWER":
               return false;
            default:
               return true;
         }
      }
      
      public function get Properties() : WeaponProperties
      {
         return this.w_properties;
      }
      
      public function get Ammo() : int
      {
         if(this.w_infinite_ammo)
         {
            return 99;
         }
         return this.w_ammo;
      }
      
      public function set Ammo(param1:int) : void
      {
         if(!this.w_infinite_ammo)
         {
            this.w_ammo = param1;
         }
      }
      
      public function Copy() : WeaponData
      {
         return new WeaponData(this.w_ammo,this.w_properties,this.w_infinite_ammo);
      }
   }
}

