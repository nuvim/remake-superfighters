package Code.Data.Weapons
{
   public class WeaponMeleeData
   {
      
      private var t_properties:WeaponMeleeProperties;
      
      private var t_charges:int;
      
      public function WeaponMeleeData(param1:int, param2:WeaponMeleeProperties)
      {
         super();
         this.t_charges = param1;
         this.t_properties = param2;
      }
      
      public function get TotalDamage() : Number
      {
         return this.Properties.HitPunchFrameDamage[0] + this.Properties.HitPunchFrameDamage[1] + this.Properties.HitPunchFrameDamage[2];
      }
      
      public function get Properties() : WeaponMeleeProperties
      {
         return this.t_properties;
      }
      
      public function get Ammo() : int
      {
         return this.t_charges;
      }
      
      public function set Ammo(param1:int) : void
      {
         this.t_charges = param1;
      }
      
      public function Copy() : WeaponMeleeData
      {
         return new WeaponMeleeData(this.t_charges,this.t_properties);
      }
   }
}

