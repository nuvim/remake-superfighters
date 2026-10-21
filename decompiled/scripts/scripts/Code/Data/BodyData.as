package Code.Data
{
   import Code.Box2D.Dynamics.b2Body;
   import Code.Handler.Deconstructer;
   import flash.display.MovieClip;
   
   public class BodyData
   {
      
      public static var DAMAGE_IMPACT:int = 0;
      
      public static var DAMAGE_FIRE:int = 1;
      
      public static var DAMAGE_BULLET:int = 2;
      
      public static var DAMAGE_EXPLOSION:int = 3;
      
      protected var _hp:Number;
      
      protected var _hp_max:Number;
      
      protected var _resistance_impact:Number;
      
      protected var _resistance_fire:Number;
      
      protected var _resistance_bullet:Number;
      
      protected var _resistance_explosion:Number;
      
      protected var _indestructible:Boolean;
      
      protected var _mc:MovieClip;
      
      private var _drawHitBox:Boolean = false;
      
      private var _drawCloudBox:Boolean = false;
      
      private var _drawShapeMC:Boolean = true;
      
      private var _collision_mc:MovieClip;
      
      private var _shape_mc:MovieClip;
      
      protected var _body:b2Body;
      
      protected var _Handler_Deconstructer:Deconstructer;
      
      private var _player_bounce:Boolean = false;
      
      private var _player_fragile:Boolean = false;
      
      private var _is_glass:Boolean = false;
      
      private var _kickable:Boolean = false;
      
      private var _kickPower:Number = 0;
      
      private var _kickWeightCalculation:Boolean = false;
      
      private var _can_gibb:Boolean = false;
      
      private var _can_crush:Boolean = false;
      
      private var _crush_damage:Number = 0;
      
      private var _canBlockExplosions:Boolean = false;
      
      private var _affectedByExplosions:Boolean = false;
      
      private var _canBlockFire:Boolean = false;
      
      private var _canBurn:Boolean = false;
      
      private var _canCarryFire:Boolean = false;
      
      private var _canSmoke:Boolean = false;
      
      private var _objectOnFire:Boolean = false;
      
      private var _objectSmokeGrade:int = 0;
      
      private var _canKnockDownPlayer:Boolean = true;
      
      private var _playerCoverLevel:int = 0;
      
      private var _bulletTransparent:Boolean = false;
      
      private var _aimTransparent:Boolean = false;
      
      private var _laserTransparent:Boolean = false;
      
      private var _laserVisibleOnObject:Boolean = false;
      
      private var _onlyBurnWhileWake:Boolean = false;
      
      private var _fireLifeSpan:Number = 0;
      
      private var _strength:int = 10;
      
      private var _inPortal:Boolean = false;
      
      private var _throughPortal:Boolean = false;
      
      private var _isHazard:Boolean = false;
      
      private var _isBurningHazard:Boolean = false;
      
      private var _isBulletHazard:Boolean = false;
      
      private var _isImpactHazard:Boolean = false;
      
      private var _isExplosionHazard:Boolean = false;
      
      private var _isActiveHazard:Boolean = false;
      
      private var _isThrowableFragile:Boolean = false;
      
      private var _isThrowableObject:Boolean = false;
      
      private var _botPreferJump:Boolean = false;
      
      private var _partOfStaticWorld:Boolean = false;
      
      private var _ignoreCoverID:int = -1;
      
      public var UserValues:Array = null;
      
      public var ObjectTimer:Number = 0;
      
      public var UpdateFunction:Function;
      
      private var _lastDamage:int;
      
      private var _isElevator:Boolean = false;
      
      public function BodyData(param1:MovieClip, param2:Deconstructer, param3:Number = 50, param4:Number = 1, param5:Number = 1, param6:Number = 1, param7:Number = 1, param8:Boolean = false)
      {
         var mc:MovieClip = param1;
         var dec:Deconstructer = param2;
         var h:Number = param3;
         var ri:Number = param4;
         var rf:Number = param5;
         var rb:Number = param6;
         var re:Number = param7;
         var ind:Boolean = param8;
         super();
         this._mc = mc;
         this._mc.stop();
         this._Handler_Deconstructer = dec;
         this._hp = h;
         this._hp_max = this.hp;
         this._resistance_impact = ri;
         this._resistance_fire = rf;
         this._resistance_bullet = rb;
         this._resistance_explosion = re;
         this._indestructible = ind;
         this._drawHitBox = false;
         this._lastDamage = 0;
         this.UserValues = new Array();
         this.UpdateFunction = function(param1:b2Body, param2:Number):void
         {
         };
      }
      
      public function SetResistance(param1:Number = 1, param2:Number = 1, param3:Number = 1, param4:Number = 1) : void
      {
         this._resistance_impact = param1;
         this._resistance_fire = param2;
         this._resistance_bullet = param3;
         this._resistance_explosion = param4;
      }
      
      public function get IsElevator() : Boolean
      {
         return this._isElevator;
      }
      
      public function set IsElevator(param1:Boolean) : void
      {
         this._isElevator = param1;
      }
      
      public function get LastDamage() : int
      {
         return this._lastDamage;
      }
      
      public function get ResistanceFire() : Number
      {
         return this._resistance_fire;
      }
      
      public function set PartOfStaticWorld(param1:Boolean) : void
      {
         this._partOfStaticWorld = param1;
      }
      
      public function get PartOfStaticWorld() : Boolean
      {
         return this._partOfStaticWorld;
      }
      
      public function set BotPreferJump(param1:Boolean) : void
      {
         this._botPreferJump = param1;
      }
      
      public function get BotPreferJump() : Boolean
      {
         return this._botPreferJump;
      }
      
      public function set IsActiveHazard(param1:Boolean) : void
      {
         this._isActiveHazard = param1;
      }
      
      public function get IsActiveHazard() : Boolean
      {
         return this._isActiveHazard;
      }
      
      public function set IsBurningHazard(param1:Boolean) : void
      {
         this._isBurningHazard = param1;
      }
      
      public function get IsBurningHazard() : Boolean
      {
         return this._isBurningHazard;
      }
      
      public function set IsBulletHazard(param1:Boolean) : void
      {
         this._isBulletHazard = param1;
      }
      
      public function get IsBulletHazard() : Boolean
      {
         return this._isBulletHazard;
      }
      
      public function set IsImpactHazard(param1:Boolean) : void
      {
         this._isImpactHazard = param1;
      }
      
      public function get IsImpactHazard() : Boolean
      {
         return this._isImpactHazard;
      }
      
      public function set IsExplosionHazard(param1:Boolean) : void
      {
         this._isExplosionHazard = param1;
      }
      
      public function get IsExplosionHazard() : Boolean
      {
         return this._isExplosionHazard;
      }
      
      public function get CanBeHazard() : Boolean
      {
         return Boolean(this._isActiveHazard) || Boolean(this._isBurningHazard) || Boolean(this._isBulletHazard) || Boolean(this._isImpactHazard) || Boolean(this._isExplosionHazard);
      }
      
      public function get IsHazard() : Boolean
      {
         if(this._isActiveHazard)
         {
            return true;
         }
         if(Boolean(this._isBurningHazard) && Boolean(this._objectOnFire))
         {
            return true;
         }
         if(Boolean(this._isImpactHazard) && !this._body.IsSleeping())
         {
            return true;
         }
         return false;
      }
      
      public function set IgnoreCoverID(param1:Number) : void
      {
         this._ignoreCoverID = param1;
      }
      
      public function get IgnoreCoverID() : Number
      {
         return this._ignoreCoverID;
      }
      
      public function set ThroughPortal(param1:Boolean) : void
      {
         this._throughPortal = param1;
      }
      
      public function get ThroughPortal() : Boolean
      {
         return this._throughPortal;
      }
      
      public function set FireLifeSpan(param1:Number) : void
      {
         this._fireLifeSpan = param1;
      }
      
      public function get FireLifeSpan() : Number
      {
         return this._fireLifeSpan;
      }
      
      public function set OnlyBurnWhileWake(param1:Boolean) : void
      {
         this._onlyBurnWhileWake = param1;
      }
      
      public function get OnlyBurnWhileWake() : Boolean
      {
         return this._onlyBurnWhileWake;
      }
      
      public function set InPortal(param1:Boolean) : void
      {
         this._inPortal = param1;
      }
      
      public function get InPortal() : Boolean
      {
         return this._inPortal;
      }
      
      public function set Indestructible(param1:Boolean) : void
      {
         this._indestructible = param1;
      }
      
      public function get Indestructible() : Boolean
      {
         return this._indestructible;
      }
      
      public function set Strength(param1:int) : void
      {
         this._strength = param1;
      }
      
      public function get Strength() : int
      {
         return this._strength;
      }
      
      public function set LaserTransparent(param1:Boolean) : void
      {
         this._laserTransparent = param1;
      }
      
      public function get LaserTransparent() : Boolean
      {
         return this._laserTransparent;
      }
      
      public function set LaserVisibleOnObject(param1:Boolean) : void
      {
         this._laserVisibleOnObject = param1;
      }
      
      public function get LaserVisibleOnObject() : Boolean
      {
         return this._laserVisibleOnObject;
      }
      
      public function set AimTransparent(param1:Boolean) : void
      {
         this._aimTransparent = param1;
      }
      
      public function get AimTransparent() : Boolean
      {
         return this._aimTransparent;
      }
      
      public function set BulletTransparent(param1:Boolean) : void
      {
         this._bulletTransparent = param1;
      }
      
      public function get BulletTransparent() : Boolean
      {
         return this._bulletTransparent;
      }
      
      public function set PlayerCoverLevel(param1:int) : void
      {
         this._playerCoverLevel = param1;
      }
      
      public function get PlayerCoverLevel() : int
      {
         return this._playerCoverLevel;
      }
      
      public function set CanKnockDownPlayer(param1:Boolean) : void
      {
         this._canKnockDownPlayer = param1;
      }
      
      public function get CanKnockDownPlayer() : Boolean
      {
         return this._canKnockDownPlayer;
      }
      
      public function set Kickable(param1:Boolean) : void
      {
         this._kickable = param1;
      }
      
      public function get Kickable() : Boolean
      {
         return this._kickable;
      }
      
      public function set KickPower(param1:Number) : void
      {
         this._kickPower = param1;
      }
      
      public function get KickPower() : Number
      {
         return this._kickPower;
      }
      
      public function set KickWeightCalculation(param1:Boolean) : void
      {
         this._kickWeightCalculation = param1;
      }
      
      public function get KickWeightCalculation() : Boolean
      {
         return this._kickWeightCalculation;
      }
      
      public function set PlayerFragile(param1:Boolean) : void
      {
         this._player_fragile = param1;
      }
      
      public function get PlayerFragile() : Boolean
      {
         return this._player_fragile;
      }
      
      public function set IsGlass(param1:Boolean) : void
      {
         this._is_glass = param1;
      }
      
      public function get IsGlass() : Boolean
      {
         return this._is_glass;
      }
      
      public function set IsThrowableFragile(param1:Boolean) : void
      {
         this._isThrowableFragile = param1;
      }
      
      public function get IsThrowableFragile() : Boolean
      {
         return this._isThrowableFragile;
      }
      
      public function set IsThrowableObject(param1:Boolean) : void
      {
         this._isThrowableObject = param1;
      }
      
      public function get IsThrowableObject() : Boolean
      {
         return this._isThrowableObject;
      }
      
      public function set PlayerBounce(param1:Boolean) : void
      {
         this._player_bounce = param1;
      }
      
      public function get PlayerBounce() : Boolean
      {
         return this._player_bounce;
      }
      
      public function set ObjectSmokeGrade(param1:int) : void
      {
         this._objectSmokeGrade = param1;
      }
      
      public function get ObjectSmokeGrade() : int
      {
         return this._objectSmokeGrade;
      }
      
      public function set ObjectOnFire(param1:Boolean) : void
      {
         this._objectOnFire = param1;
         if(this._objectOnFire)
         {
            this._objectSmokeGrade = 0;
         }
      }
      
      public function get ObjectOnFire() : Boolean
      {
         return this._objectOnFire;
      }
      
      public function set AffectedByExplosions(param1:Boolean) : void
      {
         this._affectedByExplosions = param1;
      }
      
      public function get AffectedByExplosions() : Boolean
      {
         return this._affectedByExplosions;
      }
      
      public function set CanBurn(param1:Boolean) : void
      {
         this._canBurn = param1;
      }
      
      public function get CanBurn() : Boolean
      {
         return this._canBurn;
      }
      
      public function set CanCarryFire(param1:Boolean) : void
      {
         this._canCarryFire = param1;
      }
      
      public function get CanCarryFire() : Boolean
      {
         return this._canCarryFire;
      }
      
      public function set CanSmoke(param1:Boolean) : void
      {
         this._canSmoke = param1;
      }
      
      public function get CanSmoke() : Boolean
      {
         return this._canSmoke;
      }
      
      public function set CanBlockExplosions(param1:Boolean) : void
      {
         this._canBlockExplosions = param1;
      }
      
      public function get CanBlockExplosions() : Boolean
      {
         return this._canBlockExplosions;
      }
      
      public function set CanBlockFire(param1:Boolean) : void
      {
         this._canBlockFire = param1;
      }
      
      public function get CanBlockFire() : Boolean
      {
         return this._canBlockFire;
      }
      
      public function set CanGibb(param1:Boolean) : void
      {
         this._can_gibb = param1;
      }
      
      public function get CanGibb() : Boolean
      {
         return this._can_gibb;
      }
      
      public function set CrushDamage(param1:Number) : void
      {
         this._crush_damage = param1;
      }
      
      public function get CrushDamage() : Number
      {
         return this._crush_damage;
      }
      
      public function get Body() : b2Body
      {
         return this._body;
      }
      
      public function set Body(param1:b2Body) : void
      {
         this._body = param1;
      }
      
      public function get CollisionMC() : MovieClip
      {
         return this._collision_mc;
      }
      
      public function set CollisionMC(param1:MovieClip) : void
      {
         this._collision_mc = param1;
      }
      
      public function get ShapeMC() : MovieClip
      {
         return this._shape_mc;
      }
      
      public function set ShapeMC(param1:MovieClip) : void
      {
         this._shape_mc = param1;
      }
      
      public function get MC() : MovieClip
      {
         return this._mc;
      }
      
      public function set MC(param1:MovieClip) : void
      {
         this._mc = param1;
      }
      
      public function set DrawCloudBox(param1:Boolean) : void
      {
         this._drawCloudBox = param1;
      }
      
      public function get DrawCloudBox() : Boolean
      {
         return this._drawCloudBox;
      }
      
      public function set DrawHitBox(param1:Boolean) : void
      {
         this._drawHitBox = param1;
      }
      
      public function get DrawHitBox() : Boolean
      {
         return this._drawHitBox;
      }
      
      public function set DrawShapeMC(param1:Boolean) : void
      {
         this._drawShapeMC = param1;
      }
      
      public function get DrawShapeMC() : Boolean
      {
         return this._drawShapeMC;
      }
      
      public function get hp() : Number
      {
         return this._hp;
      }
      
      public function get HP() : Number
      {
         return this._hp;
      }
      
      public function set HP(param1:Number) : void
      {
         this._hp = param1;
      }
      
      public function ForceDestruction() : void
      {
         this._Handler_Deconstructer.AddBody(this._body);
         this._hp = 0;
      }
      
      public function Damage_Bullet(param1:Number) : void
      {
         this._lastDamage = DAMAGE_BULLET;
         this.Damage(param1 * this._resistance_bullet);
      }
      
      public function Damage_Fire(param1:Number) : void
      {
         this._lastDamage = DAMAGE_FIRE;
         this.Damage(param1 * this._resistance_fire);
      }
      
      public function Damage_Explosion(param1:Number) : void
      {
         this._lastDamage = DAMAGE_EXPLOSION;
         this.Damage(param1 * this._resistance_explosion);
      }
      
      public function Damage_Impact(param1:Number) : void
      {
         this._lastDamage = DAMAGE_IMPACT;
         this.Damage(param1 * this._resistance_impact);
      }
      
      protected function Damage(param1:Number) : void
      {
         if(!this._indestructible)
         {
            this._hp -= param1;
            if(this._hp <= 0)
            {
               this._Handler_Deconstructer.AddBody(this._body);
            }
         }
      }
   }
}

