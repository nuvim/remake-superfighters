package Code.Data.Weapons
{
   public class WeaponPowerupData
   {
      
      private var t_time:int;
      
      private var t_properties:WeaponPowerupProperties;
      
      public function WeaponPowerupData(param1:int, param2:WeaponPowerupProperties)
      {
         super();
         this.t_time = param1;
         this.t_properties = param2;
      }
      
      public function get TotalDamage() : Number
      {
         return 10;
      }
      
      public function get Properties() : WeaponPowerupProperties
      {
         return this.t_properties;
      }
      
      public function get Ammo() : int
      {
         return this.t_time;
      }
      
      public function set Ammo(param1:int) : void
      {
         this.t_time = param1;
      }
      
      public function Copy() : WeaponPowerupData
      {
         return new WeaponPowerupData(this.t_time,this.t_properties);
      }
   }
}

