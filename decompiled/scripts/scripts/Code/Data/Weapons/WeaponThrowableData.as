package Code.Data.Weapons
{
   public class WeaponThrowableData
   {
      
      private var t_properties:WeaponThrowableProperties;
      
      private var t_amount:int;
      
      private var t_infinite_ammo:Boolean;
      
      public function WeaponThrowableData(param1:int, param2:WeaponThrowableProperties, param3:Boolean = false)
      {
         super();
         this.t_amount = param1;
         this.t_properties = param2;
         this.t_infinite_ammo = param3;
      }
      
      public function set InfiniteAmmo(param1:Boolean) : void
      {
         this.t_infinite_ammo = param1;
      }
      
      public function get TotalDamage() : Number
      {
         switch(this.Properties.WeaponType)
         {
            case "GRENADE":
               return 20;
            case "MOLOTOV":
               return 15;
            default:
               return 0;
         }
      }
      
      public function get Properties() : WeaponThrowableProperties
      {
         return this.t_properties;
      }
      
      public function get Ammo() : int
      {
         if(this.t_infinite_ammo)
         {
            return 99;
         }
         return this.t_amount;
      }
      
      public function set Ammo(param1:int) : void
      {
         if(!this.t_infinite_ammo)
         {
            this.t_amount = param1;
         }
      }
      
      public function Copy() : WeaponThrowableData
      {
         return new WeaponThrowableData(this.t_amount,this.t_properties,this.t_infinite_ammo);
      }
   }
}

