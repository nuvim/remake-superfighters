package Code.Handler
{
   import Code.Data.*;
   
   public class Projectiles
   {
      
      private var _Handler_Output:OutputTrace;
      
      private var p_pistol_bullet:ProjectileProperties = new ProjectileProperties();
      
      private var p_shotgun_bullet:ProjectileProperties = new ProjectileProperties();
      
      private var p_rifle_bullet:ProjectileProperties = new ProjectileProperties();
      
      private var p_uzi_bullet:ProjectileProperties = new ProjectileProperties();
      
      private var p_sniper_bullet:ProjectileProperties = new ProjectileProperties();
      
      private var p_magnum_bullet:ProjectileProperties = new ProjectileProperties();
      
      private var p_bazooka_rocket:ProjectileProperties = new ProjectileProperties();
      
      private var d_pistol_bullet:ProjectileData;
      
      private var d_shotgun_bullet:ProjectileData;
      
      private var d_rifle_bullet:ProjectileData;
      
      private var d_uzi_bullet:ProjectileData;
      
      private var d_sniper_bullet:ProjectileData;
      
      private var d_magnum_bullet:ProjectileData;
      
      private var d_bazooka_rocket:ProjectileData;
      
      public function Projectiles(param1:OutputTrace)
      {
         super();
         this._Handler_Output = param1;
         this.p_bazooka_rocket.Speed = 18;
         this.p_bazooka_rocket.Damage = 100;
         this.p_bazooka_rocket.CriticalChance = 0;
         this.p_bazooka_rocket.CriticalDamage = 0;
         this.p_bazooka_rocket.PushbackPower = 0;
         this.p_bazooka_rocket.TotalPenetrationDepth = 0;
         this.p_bazooka_rocket.SinglePenetrationDepth = 0;
         this.p_bazooka_rocket.BulletMC = "BAZOOKA_ROCKET";
         this.p_bazooka_rocket.BulletEffect = "";
         this.p_bazooka_rocket.BulletSlomoEffect = "";
         this.p_bazooka_rocket.Strength = 1;
         this.p_bazooka_rocket.ImpulseForce = 3;
         this.d_bazooka_rocket = new ProjectileData(this.p_bazooka_rocket);
         this.p_pistol_bullet.Speed = 30;
         this.p_pistol_bullet.Damage = 10;
         this.p_pistol_bullet.CriticalChance = 5;
         this.p_pistol_bullet.CriticalDamage = 15;
         this.p_pistol_bullet.PushbackPower = 15;
         this.p_pistol_bullet.TotalPenetrationDepth = 12;
         this.p_pistol_bullet.SinglePenetrationDepth = 5;
         this.p_pistol_bullet.BulletMC = "PISTOL_BULLET";
         this.p_pistol_bullet.BulletEffect = "BULLET_EFFECT_NORMAL";
         this.p_pistol_bullet.BulletSlomoEffect = "BULLET_EFFECT_SLOMO";
         this.p_pistol_bullet.Strength = 5;
         this.p_pistol_bullet.ImpulseForce = 0.6;
         this.d_pistol_bullet = new ProjectileData(this.p_pistol_bullet);
         this.p_shotgun_bullet.Speed = 30;
         this.p_shotgun_bullet.Damage = 6;
         this.p_shotgun_bullet.CriticalChance = 0;
         this.p_shotgun_bullet.CriticalDamage = 6;
         this.p_shotgun_bullet.PushbackPower = 33;
         this.p_shotgun_bullet.TotalPenetrationDepth = 12;
         this.p_shotgun_bullet.SinglePenetrationDepth = 5;
         this.p_shotgun_bullet.BulletMC = "SHOTGUN_BULLET";
         this.p_shotgun_bullet.BulletEffect = "BULLET_EFFECT_NORMAL";
         this.p_shotgun_bullet.BulletSlomoEffect = "BULLET_EFFECT_SLOMO";
         this.p_shotgun_bullet.Strength = 5;
         this.p_shotgun_bullet.ImpulseForce = 0.35;
         this.d_shotgun_bullet = new ProjectileData(this.p_shotgun_bullet);
         this.p_rifle_bullet.Speed = 35;
         this.p_rifle_bullet.Damage = 8;
         this.p_rifle_bullet.CriticalChance = 6;
         this.p_rifle_bullet.CriticalDamage = 10;
         this.p_rifle_bullet.PushbackPower = 20;
         this.p_rifle_bullet.TotalPenetrationDepth = 12;
         this.p_rifle_bullet.SinglePenetrationDepth = 5;
         this.p_rifle_bullet.BulletMC = "RIFLE_BULLET";
         this.p_rifle_bullet.BulletEffect = "BULLET_EFFECT_NORMAL";
         this.p_rifle_bullet.BulletSlomoEffect = "BULLET_EFFECT_SLOMO";
         this.p_rifle_bullet.Strength = 5;
         this.p_rifle_bullet.ImpulseForce = 0.45;
         this.d_rifle_bullet = new ProjectileData(this.p_rifle_bullet);
         this.p_uzi_bullet.Speed = 30;
         this.p_uzi_bullet.Damage = 7;
         this.p_uzi_bullet.CriticalChance = 4;
         this.p_uzi_bullet.CriticalDamage = 10;
         this.p_uzi_bullet.PushbackPower = 10;
         this.p_uzi_bullet.TotalPenetrationDepth = 12;
         this.p_uzi_bullet.SinglePenetrationDepth = 5;
         this.p_uzi_bullet.BulletMC = "UZI_BULLET";
         this.p_uzi_bullet.BulletEffect = "BULLET_EFFECT_NORMAL";
         this.p_uzi_bullet.BulletSlomoEffect = "BULLET_EFFECT_SLOMO";
         this.p_uzi_bullet.Strength = 5;
         this.p_uzi_bullet.ImpulseForce = 0.4;
         this.d_uzi_bullet = new ProjectileData(this.p_uzi_bullet);
         this.p_magnum_bullet.Speed = 40;
         this.p_magnum_bullet.Damage = 25;
         this.p_magnum_bullet.CriticalChance = 40;
         this.p_magnum_bullet.CriticalDamage = 35;
         this.p_magnum_bullet.PushbackPower = 50;
         this.p_magnum_bullet.TotalPenetrationDepth = 12;
         this.p_magnum_bullet.SinglePenetrationDepth = 5;
         this.p_magnum_bullet.BulletMC = "MAGNUM_BULLET";
         this.p_magnum_bullet.BulletEffect = "BULLET_EFFECT_NORMAL";
         this.p_magnum_bullet.BulletSlomoEffect = "BULLET_EFFECT_SLOMO";
         this.p_magnum_bullet.Strength = 15;
         this.p_magnum_bullet.ImpulseForce = 1.05;
         this.d_magnum_bullet = new ProjectileData(this.p_magnum_bullet);
         this.p_sniper_bullet.Speed = 40;
         this.p_sniper_bullet.Damage = 30;
         this.p_sniper_bullet.CriticalChance = 75;
         this.p_sniper_bullet.CriticalDamage = 60;
         this.p_sniper_bullet.PushbackPower = 50;
         this.p_sniper_bullet.TotalPenetrationDepth = 12;
         this.p_sniper_bullet.SinglePenetrationDepth = 5;
         this.p_sniper_bullet.BulletMC = "SNIPER_BULLET";
         this.p_sniper_bullet.BulletEffect = "BULLET_EFFECT_NORMAL";
         this.p_sniper_bullet.BulletSlomoEffect = "BULLET_EFFECT_SLOMO";
         this.p_sniper_bullet.Strength = 30;
         this.p_sniper_bullet.ImpulseForce = 1.25;
         this.d_sniper_bullet = new ProjectileData(this.p_sniper_bullet);
         this._Handler_Output.Trace("Projectiles Created");
      }
      
      public function get Pistol_Bullet() : ProjectileData
      {
         return this.d_pistol_bullet.Copy();
      }
      
      public function get Rifle_Bullet() : ProjectileData
      {
         return this.d_rifle_bullet.Copy();
      }
      
      public function get Uzi_Bullet() : ProjectileData
      {
         return this.d_uzi_bullet.Copy();
      }
      
      public function get Shotgun_Bullet() : ProjectileData
      {
         return this.d_shotgun_bullet.Copy();
      }
      
      public function get Sniper_Bullet() : ProjectileData
      {
         return this.d_sniper_bullet.Copy();
      }
      
      public function get Magnum_Bullet() : ProjectileData
      {
         return this.d_magnum_bullet.Copy();
      }
      
      public function get Bazooka_Rocket() : ProjectileData
      {
         return this.d_bazooka_rocket.Copy();
      }
   }
}

