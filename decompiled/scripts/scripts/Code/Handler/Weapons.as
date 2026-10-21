package Code.Handler
{
   import Code.Data.Weapons.*;
   
   public class Weapons
   {
      
      private var _Handler_Output:OutputTrace;
      
      private var p_pistol:WeaponProperties = new WeaponProperties();
      
      private var p_rifle:WeaponProperties = new WeaponProperties();
      
      private var p_uzi:WeaponProperties = new WeaponProperties();
      
      private var p_shotgun:WeaponProperties = new WeaponProperties();
      
      private var p_sniper:WeaponProperties = new WeaponProperties();
      
      private var p_magnum:WeaponProperties = new WeaponProperties();
      
      private var p_bazooka:WeaponProperties = new WeaponProperties();
      
      private var p_flamethrower:WeaponProperties = new WeaponProperties();
      
      private var w_pistol:WeaponData;
      
      private var w_rifle:WeaponData;
      
      private var w_uzi:WeaponData;
      
      private var w_shotgun:WeaponData;
      
      private var w_sniper:WeaponData;
      
      private var w_magnum:WeaponData;
      
      private var w_bazooka:WeaponData;
      
      private var w_flamethrower:WeaponData;
      
      private var pt_grenades:WeaponThrowableProperties = new WeaponThrowableProperties();
      
      private var pt_molotovs:WeaponThrowableProperties = new WeaponThrowableProperties();
      
      private var wt_grenades:WeaponThrowableData;
      
      private var wt_molotovs:WeaponThrowableData;
      
      private var pm_machete:WeaponMeleeProperties = new WeaponMeleeProperties();
      
      private var pm_sword:WeaponMeleeProperties = new WeaponMeleeProperties();
      
      private var pm_fists:WeaponMeleeProperties = new WeaponMeleeProperties();
      
      private var pm_axe:WeaponMeleeProperties = new WeaponMeleeProperties();
      
      private var wm_machete:WeaponMeleeData;
      
      private var wm_sword:WeaponMeleeData;
      
      private var wm_fists:WeaponMeleeData;
      
      private var wm_axe:WeaponMeleeData;
      
      private var w_slowmo_p_05:WeaponPowerupProperties = new WeaponPowerupProperties();
      
      private var w_slowmo_p_10:WeaponPowerupProperties = new WeaponPowerupProperties();
      
      private var w_slowmo_05:WeaponPowerupData;
      
      private var w_slowmo_10:WeaponPowerupData;
      
      private var w_health_p:WeaponPowerupProperties = new WeaponPowerupProperties();
      
      private var w_pills:WeaponPowerupData;
      
      private var w_medkit:WeaponPowerupData;
      
      private var w_projectiles:Projectiles;
      
      public function Weapons(param1:OutputTrace)
      {
         super();
         this._Handler_Output = param1;
         this.w_projectiles = new Projectiles(this._Handler_Output);
         this.pm_axe.WeaponType = "AXE";
         this.pm_axe.PickupSound = "MELEE_GRAB";
         this.pm_axe.PickupRadius = 10;
         this.pm_axe.HitPunchFrameDamage = new Array(11,12,13);
         this.pm_axe.Animation = "AXE";
         this.pm_axe.HitSound = "KATANA_HIT";
         this.pm_axe.Range = new Array(18,18,20);
         this.pm_axe.HitMaterialSounds = new Array(["WOOD","BULLET_HITDEFAULT"],["METAL","BULLET_HITMETAL"]);
         this.pm_axe.HitMaterialEffects = new Array(["WOOD","HITDEFAULT_01"]);
         this.pm_axe.SwingComboSounds = new Array("MELEE_SWING","MELEE_SWING","MELEE_SWING");
         this.pm_axe.SwingComboEffects = new Array("TRACE_AXE_01","TRACE_AXE_02","TRACE_AXE_03");
         this.wm_axe = new WeaponMeleeData(3,this.pm_axe);
         this.pm_sword.WeaponType = "SWORD";
         this.pm_sword.PickupSound = "MELEE_GRAB";
         this.pm_sword.PickupRadius = 10;
         this.pm_sword.HitPunchFrameDamage = new Array(13,14,15);
         this.pm_sword.Animation = "SWORD";
         this.pm_sword.HitSound = "KATANA_HIT";
         this.pm_sword.Range = new Array(18,18,23);
         this.pm_sword.HitMaterialSounds = new Array(["WOOD","BULLET_HITDEFAULT"],["METAL","BULLET_HITMETAL"]);
         this.pm_sword.HitMaterialEffects = new Array(["WOOD","HITDEFAULT_01"]);
         this.pm_sword.SwingComboSounds = new Array("MELEE_SWING","MELEE_SWING","MELEE_SWING");
         this.pm_sword.SwingComboEffects = new Array("TRACE_SWORD_01","TRACE_SWORD_02","TRACE_SWORD_03");
         this.wm_sword = new WeaponMeleeData(3,this.pm_sword);
         this.pm_machete.WeaponType = "MACHETE";
         this.pm_machete.PickupSound = "MELEE_GRAB";
         this.pm_machete.PickupRadius = 10;
         this.pm_machete.HitPunchFrameDamage = new Array(8,9,10);
         this.pm_machete.Animation = "MACHETE";
         this.pm_machete.HitSound = "KATANA_HIT";
         this.pm_machete.Range = new Array(13,13,19);
         this.pm_machete.HitMaterialSounds = new Array(["WOOD","BULLET_HITDEFAULT"],["METAL","BULLET_HITMETAL"]);
         this.pm_machete.HitMaterialEffects = new Array(["WOOD","HITDEFAULT_01"]);
         this.pm_machete.SwingComboSounds = new Array("MELEE_SWING","MELEE_SWING","MELEE_SWING");
         this.pm_machete.SwingComboEffects = new Array("TRACE_MACHETE_01","TRACE_MACHETE_02","TRACE_MACHETE_03");
         this.wm_machete = new WeaponMeleeData(3,this.pm_machete);
         this.pm_fists.WeaponType = "FISTS";
         this.pm_fists.PickupSound = "";
         this.pm_fists.PickupRadius = 0;
         this.pm_fists.HitPunchFrameDamage = new Array(6,7,8);
         this.pm_fists.Animation = "PUNCH";
         this.pm_fists.HitSound = "MELEE_HIT";
         this.pm_fists.Range = new Array(10,11,13);
         this.pm_fists.HitMaterialSounds = new Array(["WOOD","BULLET_HITDEFAULT"]);
         this.pm_fists.HitMaterialEffects = new Array(["WOOD","HITDEFAULT_01"]);
         this.pm_fists.SwingComboSounds = new Array("MELEE_SWING","MELEE_SWING","MELEE_SWING");
         this.pm_fists.SwingComboEffects = new Array("","","");
         this.wm_fists = new WeaponMeleeData(3,this.pm_fists);
         this.pt_grenades.WeaponType = "GRENADE";
         this.pt_grenades.AnimType = "GRENADE";
         this.pt_grenades.ThrowType = "GRENADE";
         this.pt_grenades.ThrowTimer = 24 * 3;
         this.pt_grenades.AimSound = "GRENADE_SAFE";
         this.pt_grenades.PickupSound = "GRENADE_SAFE";
         this.pt_grenades.PickupRadius = 10;
         this.wt_grenades = new WeaponThrowableData(3,this.pt_grenades);
         this.pt_molotovs.WeaponType = "MOLOTOV";
         this.pt_molotovs.AnimType = "MOLOTOV";
         this.pt_molotovs.ThrowType = "MOLOTOV";
         this.pt_molotovs.ThrowTimer = 0;
         this.pt_molotovs.AimSound = "SND_PLACEHOLDER";
         this.pt_molotovs.PickupSound = "GRENADE_SAFE";
         this.pt_molotovs.PickupRadius = 10;
         this.wt_molotovs = new WeaponThrowableData(3,this.pt_molotovs);
         this.p_pistol.WeaponType = "PISTOL";
         this.p_pistol.AnimType = "PISTOL";
         this.p_pistol.WeaponCooldown = 6;
         this.p_pistol.AccuracyDeflection = 1;
         this.p_pistol.AimSound = "PISTOL_AIM";
         this.p_pistol.EmptySound = "NOAMMO_LIGHT";
         this.p_pistol.PickupSound = "PISTOL_AIM";
         this.p_pistol.BulletType = "PISTOL_BULLET";
         this.p_pistol.PickupRadius = 10;
         this.p_pistol.LaserSight = false;
         this.p_pistol.MuzzleFlashEffect = "MUZZLE_FLASH_PISTOL";
         this.p_pistol.ShellEffect = "EMPTY_SHELL_SMALL";
         this.p_pistol.Projectile = this.w_projectiles.Pistol_Bullet;
         this.p_pistol.ShootRange = 300;
         this.p_pistol.FireSequence.push(new WeaponSequencePart(1,true,true,"PISTOL_FIRE",2));
         this.p_pistol.FireSequence.push(new WeaponSequencePart(0,false,false,"NONE",1,true));
         this.w_pistol = new WeaponData(12,this.p_pistol);
         this.p_rifle.WeaponType = "RIFLE";
         this.p_rifle.AnimType = "RIFLE";
         this.p_rifle.WeaponCooldown = 6;
         this.p_rifle.AccuracyDeflection = 3;
         this.p_rifle.AimSound = "RIFLE_AIM";
         this.p_rifle.EmptySound = "NOAMMO_HEAVY";
         this.p_rifle.PickupSound = "RIFLE_AIM";
         this.p_rifle.BulletType = "RIFLE_BULLET";
         this.p_rifle.PickupRadius = 16;
         this.p_rifle.LaserSight = false;
         this.p_rifle.MuzzleFlashEffect = "MUZZLE_FLASH_RIFLE";
         this.p_rifle.ShellEffect = "EMPTY_SHELL_SMALL";
         this.p_rifle.Projectile = this.w_projectiles.Rifle_Bullet;
         this.p_rifle.ShootRange = 300;
         this.p_rifle.FireSequence.push(new WeaponSequencePart(1,true,true,"RIFLE_FIRE",2));
         this.p_rifle.FireSequence.push(new WeaponSequencePart());
         this.p_rifle.FireSequence.push(new WeaponSequencePart(1,true,true,"RIFLE_FIRE",2));
         this.p_rifle.FireSequence.push(new WeaponSequencePart());
         this.p_rifle.FireSequence.push(new WeaponSequencePart(1,true,true,"RIFLE_FIRE",2));
         this.p_rifle.FireSequence.push(new WeaponSequencePart());
         this.p_rifle.FireSequence.push(new WeaponSequencePart(1,true,true,"RIFLE_FIRE",2));
         this.p_rifle.FireSequence.push(new WeaponSequencePart());
         this.p_rifle.FireSequence.push(new WeaponSequencePart(1,true,true,"RIFLE_FIRE",2));
         this.p_rifle.FireSequence.push(new WeaponSequencePart(0,false,false,"NONE",1,true));
         this.w_rifle = new WeaponData(5 * 5,this.p_rifle);
         this.p_uzi.WeaponType = "UZI";
         this.p_uzi.AnimType = "UZI";
         this.p_uzi.WeaponCooldown = 6;
         this.p_uzi.AccuracyDeflection = 6;
         this.p_uzi.AimSound = "UZI_AIM";
         this.p_uzi.EmptySound = "NOAMMO_LIGHT";
         this.p_uzi.PickupSound = "UZI_AIM";
         this.p_uzi.BulletType = "UZI_BULLET";
         this.p_uzi.PickupRadius = 16;
         this.p_uzi.LaserSight = false;
         this.p_uzi.MuzzleFlashEffect = "MUZZLE_FLASH_PISTOL";
         this.p_uzi.ShellEffect = "EMPTY_SHELL_SMALL";
         this.p_uzi.Projectile = this.w_projectiles.Uzi_Bullet;
         this.p_uzi.ShootRange = 200;
         this.p_uzi.FireSequence.push(new WeaponSequencePart(1,true,true,"UZI_FIRE",2));
         this.p_uzi.FireSequence.push(new WeaponSequencePart());
         this.p_uzi.FireSequence.push(new WeaponSequencePart(1,true,true,"UZI_FIRE",2));
         this.p_uzi.FireSequence.push(new WeaponSequencePart());
         this.p_uzi.FireSequence.push(new WeaponSequencePart(1,true,true,"UZI_FIRE",2));
         this.p_uzi.FireSequence.push(new WeaponSequencePart());
         this.p_uzi.FireSequence.push(new WeaponSequencePart(1,true,true,"UZI_FIRE",2));
         this.p_uzi.FireSequence.push(new WeaponSequencePart());
         this.p_uzi.FireSequence.push(new WeaponSequencePart(1,true,true,"UZI_FIRE",2));
         this.p_uzi.FireSequence.push(new WeaponSequencePart(0,false,false,"NONE",1,true));
         this.w_uzi = new WeaponData(5 * 5,this.p_uzi);
         this.p_shotgun.WeaponType = "SHOTGUN";
         this.p_shotgun.AnimType = "SHOTGUN";
         this.p_shotgun.WeaponCooldown = 3;
         this.p_shotgun.AccuracyDeflection = 4.3;
         this.p_shotgun.AimSound = "SHOTGUN_AIM";
         this.p_shotgun.EmptySound = "NOAMMO_HEAVY";
         this.p_shotgun.PickupSound = "SHOTGUN_AIM";
         this.p_shotgun.BulletType = "SHOTGUN_BULLET";
         this.p_shotgun.PickupRadius = 14;
         this.p_shotgun.LaserSight = false;
         this.p_shotgun.MuzzleFlashEffect = "MUZZLE_FLASH_SHOTGUN";
         this.p_shotgun.ShellEffect = "EMPTY_SHELL_SHOTGUN";
         this.p_shotgun.Projectile = this.w_projectiles.Shotgun_Bullet;
         this.p_shotgun.ShootRange = 200;
         this.p_shotgun.FireSequence.push(new WeaponSequencePart(4,true,false,"SHOTGUN_FIRE",2));
         this.p_shotgun.FireSequence.push(new WeaponSequencePart(0,false,false,"NONE",2));
         this.p_shotgun.FireSequence.push(new WeaponSequencePart());
         this.p_shotgun.FireSequence.push(new WeaponSequencePart());
         this.p_shotgun.FireSequence.push(new WeaponSequencePart());
         this.p_shotgun.FireSequence.push(new WeaponSequencePart(0,false,true,"SHOTGUN_PUMP_P1",3));
         this.p_shotgun.FireSequence.push(new WeaponSequencePart(0,false,false,"NONE",3));
         this.p_shotgun.FireSequence.push(new WeaponSequencePart(0,false,false,"NONE",3));
         this.p_shotgun.FireSequence.push(new WeaponSequencePart(0,false,false,"NONE",3));
         this.p_shotgun.FireSequence.push(new WeaponSequencePart());
         this.p_shotgun.FireSequence.push(new WeaponSequencePart(0,false,false,"SHOTGUN_PUMP_P2",1,true));
         this.w_shotgun = new WeaponData(8 * 4,this.p_shotgun);
         this.p_magnum.WeaponType = "MAGNUM";
         this.p_magnum.AnimType = "MAGNUM";
         this.p_magnum.WeaponCooldown = 8;
         this.p_magnum.AccuracyDeflection = 0.5;
         this.p_magnum.AimSound = "MAGNUM_AIM";
         this.p_magnum.EmptySound = "NOAMMO_HEAVY";
         this.p_magnum.PickupSound = "MAGNUM_AIM";
         this.p_magnum.BulletType = "MAGNUM_BULLET";
         this.p_magnum.PickupRadius = 10;
         this.p_magnum.LaserSight = false;
         this.p_magnum.LaserDeflection = 0.5;
         this.p_magnum.MuzzleFlashEffect = "MUZZLE_FLASH_SHOTGUN";
         this.p_magnum.ShellEffect = "EMPTY_SHELL_SMALL";
         this.p_magnum.Projectile = this.w_projectiles.Magnum_Bullet;
         this.p_magnum.ShootRange = 300;
         this.p_magnum.FireSequence.push(new WeaponSequencePart(1,true,false,"MAGNUM_FIRE",2));
         this.p_magnum.FireSequence.push(new WeaponSequencePart(0,false,false,"NONE",1,true));
         this.w_magnum = new WeaponData(6,this.p_magnum);
         this.p_sniper.WeaponType = "SNIPER";
         this.p_sniper.AnimType = "SNIPER";
         this.p_sniper.WeaponCooldown = 18;
         this.p_sniper.AccuracyDeflection = 0;
         this.p_sniper.AimSound = "SNIPER_AIM";
         this.p_sniper.EmptySound = "NOAMMO_HEAVY";
         this.p_sniper.PickupSound = "SNIPER_AIM";
         this.p_sniper.BulletType = "SNIPER_BULLET";
         this.p_sniper.PickupRadius = 16;
         this.p_sniper.LaserSight = true;
         this.p_sniper.LaserDeflection = 0.5;
         this.p_sniper.MuzzleFlashEffect = "MUZZLE_FLASH_SNIPER";
         this.p_sniper.ShellEffect = "EMPTY_SHELL_BIG";
         this.p_sniper.Projectile = this.w_projectiles.Sniper_Bullet;
         this.p_sniper.ShootRange = 900;
         this.p_sniper.FireSequence.push(new WeaponSequencePart(1,true,true,"SNIPER_FIRE",2));
         this.p_sniper.FireSequence.push(new WeaponSequencePart(0,false,false,"NONE",2));
         this.p_sniper.FireSequence.push(new WeaponSequencePart(0,false,false,"NONE",1,true));
         this.w_sniper = new WeaponData(5,this.p_sniper);
         this.p_bazooka.WeaponType = "BAZOOKA";
         this.p_bazooka.AnimType = "BAZOOKA";
         this.p_bazooka.WeaponCooldown = 10;
         this.p_bazooka.AccuracyDeflection = 2;
         this.p_bazooka.AimSound = "BAZOOKA_AIM";
         this.p_bazooka.EmptySound = "NOAMMO_HEAVY";
         this.p_bazooka.PickupSound = "BAZOOKA_AIM";
         this.p_bazooka.BulletType = "BAZOOKA_ROCKET";
         this.p_bazooka.PickupRadius = 16;
         this.p_bazooka.LaserSight = false;
         this.p_bazooka.MuzzleFlashEffect = "MUZZLE_FLASH_BAZOOKA";
         this.p_bazooka.ShellEffect = "";
         this.p_bazooka.Projectile = this.w_projectiles.Bazooka_Rocket;
         this.p_bazooka.ShootRange = 300;
         this.p_bazooka.FireSequence.push(new WeaponSequencePart(1,true,false,"BAZOOKA_FIRE",2));
         this.p_bazooka.FireSequence.push(new WeaponSequencePart(0,false,false,"NONE",2));
         this.p_bazooka.FireSequence.push(new WeaponSequencePart(0,false,false,"NONE",1,true));
         this.w_bazooka = new WeaponData(3,this.p_bazooka);
         this.p_flamethrower.WeaponType = "FLAMETHROWER";
         this.p_flamethrower.AnimType = "FLAMETHROWER";
         this.p_flamethrower.WeaponCooldown = 10;
         this.p_flamethrower.AccuracyDeflection = 6;
         this.p_flamethrower.AimSound = "FLAMETHROWER_AIM";
         this.p_flamethrower.EmptySound = "NOAMMO_LIGHT";
         this.p_flamethrower.PickupSound = "FLAMETHROWER_AIM";
         this.p_flamethrower.BulletType = "FLAME";
         this.p_flamethrower.PickupRadius = 16;
         this.p_flamethrower.LaserSight = false;
         this.p_flamethrower.MuzzleFlashEffect = "";
         this.p_flamethrower.ShellEffect = "";
         this.p_flamethrower.Projectile = null;
         this.p_flamethrower.ShootRange = 140;
         this.p_flamethrower.FireSequence.push(new WeaponSequencePart(1,false,false,"FLAMETHROWER_FIRE",1));
         this.p_flamethrower.FireSequence.push(new WeaponSequencePart(1,false,false,"NONE",1));
         this.p_flamethrower.FireSequence.push(new WeaponSequencePart(1,false,false,"NONE",1));
         this.p_flamethrower.FireSequence.push(new WeaponSequencePart(1,false,false,"NONE",1));
         this.p_flamethrower.FireSequence.push(new WeaponSequencePart(1,false,false,"NONE",1));
         this.p_flamethrower.FireSequence.push(new WeaponSequencePart(1,false,false,"NONE",1));
         this.p_flamethrower.FireSequence.push(new WeaponSequencePart(1,false,false,"NONE",1));
         this.p_flamethrower.FireSequence.push(new WeaponSequencePart(1,false,false,"NONE",1));
         this.p_flamethrower.FireSequence.push(new WeaponSequencePart(1,false,false,"NONE",1));
         this.p_flamethrower.FireSequence.push(new WeaponSequencePart(1,false,false,"NONE",1));
         this.p_flamethrower.FireSequence.push(new WeaponSequencePart(0,false,false,"NONE",1,true));
         this.w_flamethrower = new WeaponData(60,this.p_flamethrower);
         this.w_slowmo_p_05.WeaponType = "SLOMO05";
         this.w_slowmo_p_05.PickupSound = "SND_PLACEHOLDER";
         this.w_slowmo_p_05.PickupRadius = 12;
         this.w_slowmo_p_10.WeaponType = "SLOMO10";
         this.w_slowmo_p_10.PickupSound = "SND_PLACEHOLDER";
         this.w_slowmo_p_10.PickupRadius = 12;
         this.w_slowmo_05 = new WeaponPowerupData(5,this.w_slowmo_p_05);
         this.w_slowmo_10 = new WeaponPowerupData(10,this.w_slowmo_p_10);
         this.w_health_p.PickupSound = "GET_HEALTH";
         this.w_health_p.PickupRadius = 12;
         this.w_pills = new WeaponPowerupData(25,this.w_health_p);
         this.w_medkit = new WeaponPowerupData(50,this.w_health_p);
         this._Handler_Output.Trace("Weapons Created");
      }
      
      public function get Axe() : WeaponMeleeData
      {
         return this.wm_axe.Copy();
      }
      
      public function get Sword() : WeaponMeleeData
      {
         return this.wm_sword.Copy();
      }
      
      public function get Fists() : WeaponMeleeData
      {
         return this.wm_fists.Copy();
      }
      
      public function get Machete() : WeaponMeleeData
      {
         return this.wm_machete.Copy();
      }
      
      public function get Grenades() : WeaponThrowableData
      {
         return this.wt_grenades.Copy();
      }
      
      public function get Molotovs() : WeaponThrowableData
      {
         return this.wt_molotovs.Copy();
      }
      
      public function get Pistol() : WeaponData
      {
         return this.w_pistol.Copy();
      }
      
      public function get Rifle() : WeaponData
      {
         return this.w_rifle.Copy();
      }
      
      public function get Uzi() : WeaponData
      {
         return this.w_uzi.Copy();
      }
      
      public function get Shotgun() : WeaponData
      {
         return this.w_shotgun.Copy();
      }
      
      public function get Sniper() : WeaponData
      {
         return this.w_sniper.Copy();
      }
      
      public function get Magnum() : WeaponData
      {
         return this.w_magnum.Copy();
      }
      
      public function get Bazooka() : WeaponData
      {
         return this.w_bazooka.Copy();
      }
      
      public function get Flamethrower() : WeaponData
      {
         return this.w_flamethrower.Copy();
      }
      
      public function get Slowmo05() : WeaponPowerupData
      {
         return this.w_slowmo_05.Copy();
      }
      
      public function get Slowmo10() : WeaponPowerupData
      {
         return this.w_slowmo_10.Copy();
      }
      
      public function get Pills() : WeaponPowerupData
      {
         return this.w_pills.Copy();
      }
      
      public function get Medkit() : WeaponPowerupData
      {
         return this.w_medkit.Copy();
      }
   }
}

