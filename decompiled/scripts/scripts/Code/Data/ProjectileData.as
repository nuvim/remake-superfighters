package Code.Data
{
   import Code.Data.Players.Player;
   import flash.display.*;
   
   public class ProjectileData
   {
      
      private var p_properties:ProjectileProperties;
      
      private var p_posX:Number;
      
      private var p_posY:Number;
      
      private var p_angle:Number;
      
      private var p_angle_rad:Number;
      
      private var p_directionX:Number;
      
      private var p_directionY:Number;
      
      private var p_owner:Player;
      
      private var p_strength:int;
      
      private var p_total_penetration:Number;
      
      private var p_current_penetration:Number;
      
      private var mc:MovieClip;
      
      private var bullet_mc:MovieClip;
      
      private var normal_effect_mc:MovieClip;
      
      private var effect_length:Number = 0;
      
      private var players_avoided:Array;
      
      private var isRocket:Boolean = false;
      
      private var playerStuck:Player = null;
      
      private var explode:Boolean = false;
      
      private var penetrating:Boolean = false;
      
      private var penetratingCloud:Boolean = false;
      
      private var _bullet_slomo_trace:Number = 5;
      
      public function ProjectileData(param1:ProjectileProperties)
      {
         super();
         this.p_posX = 0;
         this.p_posY = 0;
         this.p_angle = 0;
         this.p_angle_rad = 0;
         this.p_directionX = 1;
         this.p_directionY = 0;
         this.p_owner = null;
         this.p_properties = param1;
         this.p_strength = this.p_properties.Strength;
         this.p_total_penetration = this.p_properties.TotalPenetrationDepth;
         this.p_current_penetration = this.p_properties.SinglePenetrationDepth;
         switch(this.p_properties.BulletMC.toUpperCase())
         {
            case "PISTOL_BULLET":
               this.bullet_mc = new bullet_pistol();
               break;
            case "RIFLE_BULLET":
               this.bullet_mc = new bullet_rifle();
               break;
            case "UZI_BULLET":
               this.bullet_mc = new bullet_uzi();
               break;
            case "SHOTGUN_BULLET":
               this.bullet_mc = new bullet_shotgun();
               break;
            case "SNIPER_BULLET":
               this.bullet_mc = new bullet_sniper();
               break;
            case "MAGNUM_BULLET":
               this.bullet_mc = new bullet_magnum();
               break;
            case "BAZOOKA_ROCKET":
               this.isRocket = true;
               this.bullet_mc = new bazooka_rocket();
               break;
            default:
               this.bullet_mc = new bullet();
         }
         this.mc = new MovieClip();
         this.mc.addChild(this.bullet_mc);
         this.players_avoided = new Array();
         if(this.p_properties.BulletEffect == "BULLET_EFFECT_NORMAL")
         {
            this.normal_effect_mc = new bullet_effect_normal();
         }
         else
         {
            this.normal_effect_mc = new MovieClip();
         }
         this.normal_effect_mc.scaleX = this.effect_length;
         this.mc.addChild(this.normal_effect_mc);
      }
      
      public function get AverageDamage() : Number
      {
         return this.Properties.Damage + this.Properties.CriticalChance / 100 * this.Properties.CriticalDamage;
      }
      
      public function AddBulletTrace(param1:Number) : Boolean
      {
         if(this.isRocket)
         {
            if(this._bullet_slomo_trace <= 0)
            {
               this._bullet_slomo_trace = 2;
               return true;
            }
            this._bullet_slomo_trace -= param1;
         }
         else if(this.BulletGameSpeed < 0.8)
         {
            if(this._bullet_slomo_trace <= 0)
            {
               this._bullet_slomo_trace = 12;
               return true;
            }
            this._bullet_slomo_trace -= param1;
         }
         return false;
      }
      
      public function UpdateVisuals(param1:Number) : void
      {
         if(this.BulletGameSpeed >= 0.8)
         {
            this.bullet_mc.visible = false;
            this.normal_effect_mc.visible = true;
         }
         else
         {
            this.bullet_mc.visible = true;
            this.normal_effect_mc.visible = false;
         }
         if(this.effect_length < 30)
         {
            this.effect_length += param1;
            if(this.effect_length > 30)
            {
               this.effect_length = 30;
            }
            this.normal_effect_mc.alpha = 0.9 - this.effect_length / 100;
            this.normal_effect_mc.scaleX = this.effect_length / 10;
         }
      }
      
      public function Hide() : void
      {
         this.mc.visible = false;
      }
      
      public function Show() : void
      {
         this.mc.visible = true;
      }
      
      public function Explode() : void
      {
         this.explode = true;
      }
      
      public function get DoExplode() : Boolean
      {
         return this.explode;
      }
      
      public function get PlayerStuck() : Player
      {
         return this.playerStuck;
      }
      
      public function set PlayerStuck(param1:Player) : void
      {
         this.playerStuck = param1;
      }
      
      public function ResetPlayersAvoided() : void
      {
         this.players_avoided = new Array();
      }
      
      public function PlayerAvoided(param1:int) : Boolean
      {
         var _loc2_:int = 0;
         while(_loc2_ < this.players_avoided.length)
         {
            if(this.players_avoided[_loc2_] == param1)
            {
               return true;
            }
            _loc2_++;
         }
         return false;
      }
      
      public function AddPlayerAvoided(param1:int) : void
      {
         this.players_avoided.push(param1);
      }
      
      public function ClearPenetrationCurrentLeft() : void
      {
         this.p_current_penetration = this.p_properties.SinglePenetrationDepth;
         if(this.p_current_penetration > this.p_total_penetration)
         {
            this.p_current_penetration = this.p_total_penetration;
         }
      }
      
      public function get PenetrationCurrentLeft() : Number
      {
         return this.p_current_penetration;
      }
      
      public function set PenetrationCurrentLeft(param1:Number) : void
      {
         this.p_current_penetration = param1;
      }
      
      public function get PenetrationTotalLeft() : Number
      {
         return this.p_total_penetration;
      }
      
      public function set PenetrationTotalLeft(param1:Number) : void
      {
         this.p_total_penetration = param1;
      }
      
      public function get StrengthLeft() : int
      {
         return this.p_strength;
      }
      
      public function set StrengthLeft(param1:int) : void
      {
         this.p_strength = param1;
      }
      
      public function get Properties() : ProjectileProperties
      {
         return this.p_properties;
      }
      
      public function get Owner() : Player
      {
         return this.p_owner;
      }
      
      public function set Owner(param1:Player) : void
      {
         this.p_owner = param1;
      }
      
      public function get PosX() : Number
      {
         return this.p_posX;
      }
      
      public function set PosX(param1:Number) : void
      {
         this.p_posX = param1;
         this.mc.x = this.p_posX;
      }
      
      public function get PosY() : Number
      {
         return this.p_posY;
      }
      
      public function set PosY(param1:Number) : void
      {
         this.p_posY = param1;
         this.mc.y = this.p_posY;
      }
      
      public function get AngleRad() : Number
      {
         return this.p_angle_rad;
      }
      
      public function get Angle() : Number
      {
         return this.p_angle;
      }
      
      public function set Angle(param1:Number) : void
      {
         this.p_angle = param1;
         this.p_angle_rad = this.p_angle * (Math.PI / 180);
         this.p_directionX = Math.cos(this.p_angle_rad);
         this.p_directionY = Math.sin(this.p_angle_rad);
         this.mc.rotation = this.p_angle;
      }
      
      public function get DirectionX() : Number
      {
         return this.p_directionX;
      }
      
      public function set DirectionX(param1:Number) : void
      {
         this.p_directionX = param1;
         this.p_angle_rad = Math.atan2(this.DirectionY,this.DirectionX);
         this.Angle = this.p_angle_rad * (180 / Math.PI);
      }
      
      public function get DirectionY() : Number
      {
         return this.p_directionY;
      }
      
      public function set DirectionY(param1:Number) : void
      {
         this.p_directionY = param1;
         this.p_angle_rad = Math.atan2(this.DirectionY,this.DirectionX);
         this.Angle = this.p_angle_rad * (180 / Math.PI);
      }
      
      public function get VelocityX() : Number
      {
         return this.p_directionX * this.p_properties.Speed;
      }
      
      public function get VelocityY() : Number
      {
         return this.p_directionY * this.p_properties.Speed;
      }
      
      public function get MC() : MovieClip
      {
         return this.mc;
      }
      
      public function set MC(param1:MovieClip) : void
      {
         this.mc = param1;
      }
      
      public function get BulletGameSpeed() : Number
      {
         return this.p_owner.BulletGameSpeed;
      }
      
      public function Copy() : ProjectileData
      {
         return new ProjectileData(this.p_properties);
      }
      
      public function set Penetrating(param1:Boolean) : void
      {
         this.penetrating = param1;
      }
      
      public function get Penetrating() : Boolean
      {
         return this.penetrating;
      }
      
      public function set PenetratingCloud(param1:Boolean) : void
      {
         this.penetratingCloud = param1;
      }
      
      public function get PenetratingCloud() : Boolean
      {
         return this.penetratingCloud;
      }
   }
}

