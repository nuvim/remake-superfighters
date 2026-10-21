package Code.Data.Players
{
   import Code.Box2D.Dynamics.b2Body;
   import Code.Data.ProjectileData;
   import Code.Data.Weapons.*;
   
   public class PlayerState
   {
      
      public static var KNOCKDOWN_IMMUNITY_TIME:Number = 10;
      
      public var PlayerGravity:Number = 0.6;
      
      public var UpdateYAxisDistance:Number = 3;
      
      public var PlayerEdgeDistance:Number = 4;
      
      public var PlayerFeetSize:Number = 4;
      
      public var PlayerJumpPower:Number = -5;
      
      public var PlayerJumpPushActivated:Boolean = false;
      
      public var PlayerJumpPushPower:Number = -0.7;
      
      public var PlayerJumpPushLevelOut:Boolean = false;
      
      public var PlayerJumpPushEnabled:Boolean = false;
      
      public var PlayerJumpPushTime:Number = 4;
      
      public var JumpPushTimeLeft:Number = 0;
      
      public var PlayerWallJumpPower:Number = -5;
      
      public var FallTriggerSpeed:Number = 8.5;
      
      public var StaggerSpeed:Number = 1;
      
      public var RollSpeed:Number = 2;
      
      public var DiveSpeed:Number = 3.5;
      
      public var StuckToRocket:Boolean = false;
      
      public var RocketRideProjectile:ProjectileData = null;
      
      public var Team:int;
      
      public var Mass:Number = 0.7;
      
      public var KickPower:Number = 1.6;
      
      public var CantRise:Boolean = false;
      
      public var CheckForCover:Boolean = false;
      
      public var FireRank1Attached:Boolean = false;
      
      public var FireRank2Attached:Boolean = false;
      
      public var StairBounce:Boolean = false;
      
      public var CurrentRangeWeapon:WeaponData;
      
      public var CurrentMeleeWeapon:WeaponMeleeData;
      
      public var CurrentThrowableWeapon:WeaponThrowableData;
      
      public var DefaultMeleeWeapon:WeaponMeleeData;
      
      public var CurrentPowerupWeapon:WeaponPowerupData;
      
      public var UsingMeleeWeapon:Boolean = false;
      
      public var CurrentAimPitch:Number = 0;
      
      public var CurrentChangePitchSpeed:Number = 0;
      
      public var ClimbSpeed:Number = 1.5;
      
      public var SlideSpeed:Number = 3;
      
      public var CurrentLadder:b2Body = null;
      
      public var DisableKneel:Boolean = false;
      
      public var CurrentWeaponCooldown:Number = 0;
      
      public var NextLadderEffect:Number = 4;
      
      public var LadderEffectRightSide:Boolean = false;
      
      public var FireDelayTimer:Number;
      
      public var FireDelayActivated:Boolean = false;
      
      public var FireDelayUpdated:Boolean = false;
      
      public var SlowmotionDelay:Number = 0;
      
      public var CurrentFireFrame:Number = 0;
      
      public var LastFireFrame:int = 0;
      
      public var AimMode:int = 0;
      
      public var FastTrigger:Boolean = false;
      
      public var Throwing:Boolean = false;
      
      public var ThrowTimer:Number = 0;
      
      public var Burned:Boolean = false;
      
      public var CritSmokeTimer:Number = 0;
      
      public var Gone:Boolean = false;
      
      public var FireRankWorldExtraDamage:Number = 0.2;
      
      public var FireRank1Damage:Number = 0.2;
      
      public var FireRank2Damage:Number = 0.4;
      
      public var FireRank1Minimum:Number = 15;
      
      public var FireRank2Minimum:Number = 100;
      
      public var StairBounceDamage:Number = 4;
      
      public var KickDamage:Number = 4;
      
      public var JumpKickDamage:Number = 4;
      
      public var AirbornTimer:Number = 0;
      
      public var QueueJumpKick:Boolean = false;
      
      public var LockRocketSteering:Boolean = false;
      
      public var RocketRideTimer:Number = 0;
      
      public var EmptyWeaponRecoilBack:int = 0;
      
      public var CharAnimWpnX:Number;
      
      public var CharAnimWpnY:Number;
      
      public var IgnoreMe:Boolean = false;
      
      public var ImmunityTimer:Number = 0;
      
      public var StopStaggerFunc:Function;
      
      public var ImmunityDisabled:Boolean = false;
      
      private var game_speed:Number = 1;
      
      private var kickHitMaterialSounds:Array = new Array(["WOOD","BULLET_HITDEFAULT"]);
      
      private var kickHitMaterialEffects:Array = new Array(["WOOD","HITDEFAULT_01"]);
      
      private var _hp_damage_timer:Number = 0;
      
      private var _showFlashEffect:Boolean = false;
      
      private var _flashEffectTimer:int = 0;
      
      private var _aimTurningAroundTimer:int = 0;
      
      private var _aimTurningAround:Boolean = false;
      
      public var PunchGlideSpeed:Number = 2;
      
      private var _runSpeed:Number = 1.7;
      
      private var _aiming:Boolean = false;
      
      private var _climbing:Boolean = false;
      
      private var _camera_ignore_me_timer:Number = 0;
      
      private var _diving:Boolean = false;
      
      private var _jumpKickPerformed:Boolean = false;
      
      private var _jumping:Boolean = false;
      
      private var _wallJumping:Boolean = false;
      
      private var _canRoll:Boolean = true;
      
      private var _canDive:Boolean = true;
      
      private var _inWorldFire:Number = 0;
      
      private var _stunAnimation:int = 1;
      
      private var _stunTimer:Number = 0;
      
      private var _puchbackDecreaseDelay:Number = 0;
      
      private var _currentPushbackPower:Number = 0;
      
      private var _drawDelay:int = 0;
      
      private var _backToIdleTimer:int = 0;
      
      private var _falling:Boolean = false;
      
      private var _kneeling:Boolean = false;
      
      private var _actionCooldown:Number = 0;
      
      private var _actionAvailable:Boolean = true;
      
      private var _rolling:Boolean = false;
      
      private var _sprintEnergy:Number = 100;
      
      private var _box2D_cover:b2Body;
      
      private var _cover_object_id:int;
      
      private var _taking_cover:Boolean = false;
      
      private var _staggerTimer:Number = 0;
      
      private var _staggering:Boolean = false;
      
      private var _deathKneel:Boolean = false;
      
      private var _knockdowned:Boolean = false;
      
      private var _knockdownGrade:int = 0;
      
      private var _decreaseKnockdownGradeTimer:Number = 0;
      
      private var _kickingCooldown:Number = 0;
      
      private var _kickingTimer:Number = 0;
      
      private var _kicking:Boolean = false;
      
      private var _doPunchCombo:Boolean = false;
      
      private var _punchComboNr:int = 1;
      
      private var _punching:Boolean = false;
      
      private var _punchHitPerformed:Boolean = false;
      
      private var _sprinting:Boolean = false;
      
      private var _running:Boolean = false;
      
      private var _shortDiveTimer:Number = 0;
      
      private var _shortDiveAvailable:Boolean = false;
      
      private var _sprintActivationDuration:int = 0;
      
      private var _reSprintActivationDuration:int = 0;
      
      private var _airVelocityY:Number = 0;
      
      private var _airVelocityX:Number = 0;
      
      private var _stairVelocityY:Number = 0;
      
      private var _stairVelocityX:Number = 0;
      
      private var _movingDirectionInversed:int = 0;
      
      private var _last_dir_x:int = 1;
      
      private var _inFireDelay:Number = 0;
      
      private var _burnState:Number = 0;
      
      private var _hp:Number = 100;
      
      private var _showHealthTimer:Number = -24;
      
      private var _healthBarSpeed:Number = 4;
      
      private var _barHP:Number = 100;
      
      private var _movingDirectionX:int = 1;
      
      private var _portalSpeedX:Number = 0;
      
      private var _portalDirectionX:int = 1;
      
      private var _grabbed_by_player:Boolean = false;
      
      private var _grabbed_player:Boolean = false;
      
      private var _grabbed_player_nr:int = 0;
      
      private var _grabbed_player_char_nr:int = 0;
      
      private var _char_nr:int = 0;
      
      public function PlayerState()
      {
         super();
      }
      
      public function get ShowFlashEffect() : Boolean
      {
         return this._showFlashEffect;
      }
      
      public function set ShowFlashEffect(param1:Boolean) : void
      {
         this._showFlashEffect = param1;
         if(param1)
         {
            this._flashEffectTimer = 8;
         }
         else
         {
            this._flashEffectTimer = 0;
         }
      }
      
      public function get FlashEffectTimer() : int
      {
         return this._flashEffectTimer;
      }
      
      public function get LowerAimPitch() : int
      {
         switch(this.AimMode)
         {
            case 0:
               return 90;
            case 1:
               return 90;
            default:
               return 45;
         }
      }
      
      public function get UpperAimPitch() : int
      {
         switch(this.AimMode)
         {
            case 0:
               return 90;
            case 1:
               return 90;
            default:
               return 90;
         }
      }
      
      public function get AimTurningAroundDelay() : Boolean
      {
         if(Boolean(this._aimTurningAround) || this._aimTurningAroundTimer > 0)
         {
            return true;
         }
         return false;
      }
      
      public function get AimTurningAround() : Boolean
      {
         return this._aimTurningAround;
      }
      
      public function set AimTurningAround(param1:Boolean) : void
      {
         this._aimTurningAround = param1;
         if(!param1)
         {
            this._aimTurningAroundTimer = 2;
         }
         else
         {
            this.BackToIdleTimer = 0;
         }
      }
      
      public function get AFSInProgress() : Boolean
      {
         return this.CurrentFireFrame > 0;
      }
      
      public function CancelAFS() : void
      {
         this.CurrentFireFrame = 0;
         this.LastFireFrame = 0;
         if(this.BackToIdleTimer < 6)
         {
            this.BackToIdleTimer = 6;
         }
      }
      
      public function get CurrentAimAngleThrowable() : Number
      {
         if(this.LastDirX == 1)
         {
            return this.CurrentAimPitch - 25;
         }
         return 180 - this.CurrentAimPitch + 25;
      }
      
      public function get CurrentAimAngle() : Number
      {
         if(this.LastDirX == 1)
         {
            return this.CurrentAimPitch;
         }
         return 180 - this.CurrentAimPitch;
      }
      
      public function get CurrentAimAngleRad() : Number
      {
         return this.CurrentAimAngle * (Math.PI / 180);
      }
      
      public function ResetChangePitchSpeed() : void
      {
         this.CurrentChangePitchSpeed = 0;
      }
      
      public function get MaxPlayerHeight() : Number
      {
         return 18;
      }
      
      public function get PlayerHeight() : Number
      {
         if(this._diving)
         {
            return 8;
         }
         if(this._knockdowned)
         {
            return 10;
         }
         if(this._falling)
         {
            return 12;
         }
         if(this._rolling)
         {
            return 14;
         }
         if(Boolean(this._kneeling) || this.TakingCover)
         {
            return 12;
         }
         return 18;
      }
      
      public function get RunSpeed() : Number
      {
         if(this._sprinting)
         {
            return this._runSpeed * 2;
         }
         return this._runSpeed;
      }
      
      public function get WallJumpSpeed() : Number
      {
         return this._runSpeed;
      }
      
      public function get Aiming() : Boolean
      {
         return this._aiming;
      }
      
      public function set Aiming(param1:Boolean) : void
      {
         this._aiming = param1;
         if(param1)
         {
            this.CurrentAimPitch = 0;
            this.ResetChangePitchSpeed();
            this.Kneeling = false;
         }
         else
         {
            this._backToIdleTimer = 0;
         }
      }
      
      public function get Climbing() : Boolean
      {
         return this._climbing;
      }
      
      public function set Climbing(param1:Boolean) : void
      {
         this._climbing = param1;
         if(!param1)
         {
            this.CurrentLadder = null;
            this.QueueJumpKick = false;
            this.JumpKickPerformed = false;
            this.AirbornTimer = 0;
         }
      }
      
      public function get ClimbingAround() : Boolean
      {
         if(this.AirVelocityX != 0 || this.AirVelocityY != 0)
         {
            return true;
         }
         return false;
      }
      
      public function get ClimbingDirection() : int
      {
         if(this.AirVelocityY < 0)
         {
            return -1;
         }
         if(this.AirVelocityY > 0)
         {
            return 1;
         }
         return 0;
      }
      
      public function get CameraIgnoreMe() : Boolean
      {
         if(this._hp > 0)
         {
            return false;
         }
         if(this._camera_ignore_me_timer > 0)
         {
            return false;
         }
         if(this._staggering)
         {
            return false;
         }
         return true;
      }
      
      public function get Diving() : Boolean
      {
         return this._diving;
      }
      
      public function set Diving(param1:Boolean) : void
      {
         this._diving = param1;
      }
      
      public function get JumpKickPerformed() : Boolean
      {
         return this._jumpKickPerformed;
      }
      
      public function set JumpKickPerformed(param1:Boolean) : void
      {
         this._jumpKickPerformed = param1;
      }
      
      public function get Jumping() : Boolean
      {
         return this._jumping;
      }
      
      public function set Jumping(param1:Boolean) : void
      {
         this._jumping = param1;
         if(!this._jumping)
         {
            this.JumpKickPerformed = false;
            this._airVelocityY = 0;
            this._wallJumping = false;
         }
         else
         {
            this.AirbornTimer = 0;
            this._rolling = false;
            this.TakingCover = false;
            this.DeathKneel = false;
            if(this._knockdowned)
            {
               this.Falling = true;
            }
         }
         this.QueueJumpKick = false;
      }
      
      public function get WallJumping() : Boolean
      {
         return this._wallJumping;
      }
      
      public function set WallJumping(param1:Boolean) : void
      {
         this._wallJumping = param1;
      }
      
      public function get CanRoll() : Boolean
      {
         if(!this._actionAvailable)
         {
            return false;
         }
         return this._canRoll;
      }
      
      public function set CanRoll(param1:Boolean) : void
      {
         this._canRoll = param1;
      }
      
      public function get CanDive() : Boolean
      {
         if(!this._actionAvailable)
         {
            return false;
         }
         return this._canDive;
      }
      
      public function set CanDive(param1:Boolean) : void
      {
         this._canDive = param1;
      }
      
      public function get OnGround() : Boolean
      {
         if(Boolean(this._falling) || Boolean(this._jumping) || Boolean(this._climbing))
         {
            return false;
         }
         return true;
      }
      
      public function get CanGrabWeapon() : Boolean
      {
         if(Boolean(this._falling) || Boolean(this._knockdowned) || Boolean(this._grabbed_by_player) || Boolean(this._climbing) || this.Throwing || Boolean(this._kicking) || this.Punching)
         {
            return false;
         }
         if(this.IsStunned || Boolean(this._staggering) || this.DeathKneel)
         {
            return false;
         }
         return true;
      }
      
      public function get BotInterrupt() : Boolean
      {
         if(Boolean(this._falling) || Boolean(this._knockdowned) || Boolean(this._grabbed_by_player))
         {
            return true;
         }
         if(this.IsStunned || Boolean(this._staggering))
         {
            return true;
         }
         return false;
      }
      
      public function get ControllAble() : Boolean
      {
         if(this._hp <= 0 || Boolean(this._falling) || Boolean(this._knockdowned) || Boolean(this._rolling) || Boolean(this._diving))
         {
            return false;
         }
         if(Boolean(this._grabbed_by_player) || Boolean(this._kicking) || this.Punching || this.Throwing || Boolean(this._staggering))
         {
            return false;
         }
         if(this.IsStunned || this.DeathKneel)
         {
            return false;
         }
         return true;
      }
      
      public function get AddSmokeEffect() : Boolean
      {
         if(this._burnState > 0)
         {
            if(!this.FireRank1Attached)
            {
               return true;
            }
         }
         if(this.CritSmokeTimer > 0)
         {
            return true;
         }
         return false;
      }
      
      public function Update(param1:Number) : void
      {
         this.game_speed = param1;
         if(this._flashEffectTimer > 0)
         {
            --this._flashEffectTimer;
         }
         if(this.SlowmotionDelay > 0)
         {
            --this.SlowmotionDelay;
         }
         if(this.ImmunityTimer > 0)
         {
            this.ImmunityTimer -= this.game_speed;
         }
         if(this.HP < 100 && this._hp_damage_timer <= 0)
         {
            this.HP += param1 * 0.1;
         }
         else if(this._hp_damage_timer > 0)
         {
            this._hp_damage_timer -= this.game_speed;
         }
         if(this.CritSmokeTimer > 0)
         {
            this.CritSmokeTimer -= this.game_speed;
         }
         if(this._inFireDelay > 0)
         {
            this._inFireDelay -= this.game_speed;
         }
         if(this.AddSmokeEffect)
         {
            if(this._inFireDelay <= 0)
            {
               this._burnState -= this.game_speed;
            }
            if(this._burnState < 0)
            {
               this._burnState = 0;
            }
         }
         if(this._kickingTimer > 0)
         {
            this._kickingTimer -= this.game_speed;
         }
         if(this._kickingCooldown > 0)
         {
            this._kickingCooldown -= this.game_speed;
         }
         if(this._drawDelay > 0)
         {
            --this._drawDelay;
         }
         if(this._aimTurningAroundTimer > 0)
         {
            --this._aimTurningAroundTimer;
            if(this._aimTurningAroundTimer <= 0)
            {
               if(this.AimTurningAround)
               {
                  this.AimTurningAround = false;
               }
            }
         }
         if(this._backToIdleTimer > 0)
         {
            --this._backToIdleTimer;
         }
         if(this._reSprintActivationDuration > 0)
         {
            --this._reSprintActivationDuration;
         }
         if(this._sprintActivationDuration > 0)
         {
            --this._sprintActivationDuration;
            if(this._sprintActivationDuration <= 0)
            {
               this._sprinting = false;
            }
         }
         if(this._shortDiveTimer > 0)
         {
            --this._shortDiveTimer;
            if(this._shortDiveTimer <= 0)
            {
               this._shortDiveAvailable = false;
            }
         }
         if(this._actionCooldown > 0)
         {
            this._actionCooldown -= this.game_speed;
            if(this._actionCooldown <= 0)
            {
               this._actionAvailable = true;
            }
         }
         if(this._showHealthTimer > -24)
         {
            --this._showHealthTimer;
            if(this._showHealthTimer >= 0)
            {
               this._barHP += this._healthBarSpeed;
            }
            if(this._showHealthTimer <= -24)
            {
               this._showHealthTimer = -24;
            }
         }
         if(this.OnGround && !this.Rolling)
         {
            if(Boolean(this._sprinting) && Boolean(this._running))
            {
               this._sprintEnergy -= this.game_speed * 1.2;
               if(this._sprintEnergy <= 0)
               {
                  this._sprintEnergy = 0;
                  this._sprinting = false;
               }
            }
            else if(this._sprintEnergy < 100)
            {
               if(this._running)
               {
                  this._sprintEnergy += this.game_speed;
               }
               else
               {
                  this._sprintEnergy += this.game_speed + this.game_speed;
               }
               if(this._sprintEnergy > 100)
               {
                  this._sprintEnergy = 100;
               }
            }
         }
         else if(this.Climbing)
         {
            this._sprintEnergy += this.game_speed;
            if(this._sprintEnergy > 100)
            {
               this._sprintEnergy = 100;
            }
         }
         if(this._puchbackDecreaseDelay > 0)
         {
            this._puchbackDecreaseDelay -= this.game_speed;
         }
         else if(this._currentPushbackPower > 0)
         {
            this._currentPushbackPower -= 10 * this.game_speed;
         }
         if(this._stunTimer > 0)
         {
            this._stunTimer -= this.game_speed;
         }
         if(this._camera_ignore_me_timer > 0)
         {
            if(this.OnGround)
            {
               --this._camera_ignore_me_timer;
            }
         }
         if(this.Jumping)
         {
            this.AirbornTimer += this.game_speed;
         }
         if(this.Staggering)
         {
            this.StaggerTimer -= this.game_speed;
            if(this.StaggerTimer <= 0)
            {
               this.StopStaggerFunc();
               this.Staggering = false;
               this.StaggerTimer = 0;
            }
         }
         if(this.Burned)
         {
            if(this._burnState > 0)
            {
               if(this.OnGround)
               {
                  this._burnState -= this.game_speed * 1.5;
                  if(this._burnState <= 0)
                  {
                     this._burnState = 0;
                  }
                  else if(this._burnState >= 90)
                  {
                     this._burnState = 90;
                  }
               }
            }
         }
         if(this._inWorldFire > 0)
         {
            this._inWorldFire -= this.game_speed;
         }
         if(!this.Knockdowned || this.HP <= 0)
         {
            if(this._decreaseKnockdownGradeTimer > 0)
            {
               this._decreaseKnockdownGradeTimer -= this.game_speed;
               if(this._decreaseKnockdownGradeTimer <= 0)
               {
                  --this._knockdownGrade;
                  if(this._knockdownGrade > 0)
                  {
                     this._decreaseKnockdownGradeTimer = 12;
                  }
               }
            }
         }
      }
      
      public function set InWorldFire(param1:Boolean) : void
      {
         if(param1)
         {
            this._inWorldFire = 2.5;
         }
         else
         {
            this._inWorldFire = 0;
         }
      }
      
      public function get InWorldFire() : Boolean
      {
         return this._inWorldFire > 0;
      }
      
      public function get StunTimer() : Number
      {
         return this._stunTimer;
      }
      
      public function set StunTimer(param1:Number) : void
      {
         this._stunTimer = param1;
         if(this._stunTimer > 0)
         {
            this.CancelAFS();
            this.Punching = false;
            this.DoPunchCombo = false;
         }
         if(this._stunAnimation < 2)
         {
            ++this._stunAnimation;
         }
         else
         {
            this._stunAnimation = 1;
         }
      }
      
      public function get IsStunned() : Boolean
      {
         return this._stunTimer > 0;
      }
      
      public function get StunAnimation() : int
      {
         return this._stunAnimation;
      }
      
      public function get CurrentPushbackPower() : Number
      {
         return this._currentPushbackPower;
      }
      
      public function set CurrentPushbackPower(param1:Number) : void
      {
         this._currentPushbackPower = param1;
         this._puchbackDecreaseDelay = 3;
      }
      
      public function get DrawDelay() : int
      {
         return this._drawDelay;
      }
      
      public function set DrawDelay(param1:int) : void
      {
         this._drawDelay = param1;
      }
      
      public function get BackToIdleTimer() : int
      {
         return this._backToIdleTimer;
      }
      
      public function set BackToIdleTimer(param1:int) : void
      {
         this._backToIdleTimer = param1;
      }
      
      public function set CameraIgnoreTimer(param1:Number) : void
      {
         this._camera_ignore_me_timer = param1;
      }
      
      public function UpdateCameraIgnoreTimer() : void
      {
         if(this._camera_ignore_me_timer > 0)
         {
            --this._camera_ignore_me_timer;
         }
      }
      
      public function get Falling() : Boolean
      {
         return this._falling;
      }
      
      public function set Falling(param1:Boolean) : void
      {
         this._falling = param1;
         if(this._falling)
         {
            this._camera_ignore_me_timer = 24 * 3;
            this.CancelAFS();
            this._stunTimer = 0;
            this.Throwing = false;
            this._diving = false;
            this._jumping = false;
            this.JumpKickPerformed = false;
            this._knockdowned = false;
            this._staggering = false;
            this.Punching = false;
            this._rolling = false;
            this.TakingCover = false;
            this._kicking = false;
            this._wallJumping = false;
            this.Aiming = false;
            this._climbing = false;
            this.DeathKneel = false;
         }
         else
         {
            this.AirVelocityX = 0;
            this.AirVelocityY = 0;
         }
      }
      
      public function get Kneeling() : Boolean
      {
         return this._kneeling;
      }
      
      public function set Kneeling(param1:Boolean) : void
      {
         this._kneeling = param1;
         if(this._kneeling)
         {
            this._sprinting = false;
            if(this.TakingCover)
            {
               this._kneeling = false;
            }
         }
      }
      
      public function get Rolling() : Boolean
      {
         return this._rolling;
      }
      
      public function set Rolling(param1:Boolean) : void
      {
         this._rolling = param1;
         if(this._rolling)
         {
            this._diving = false;
            this._sprinting = false;
         }
         else
         {
            this._kneeling = false;
            this._actionCooldown = 12;
            this._actionAvailable = false;
         }
      }
      
      public function get SprintEnergy() : Number
      {
         return this._sprintEnergy;
      }
      
      public function set SprintEnergy(param1:Number) : void
      {
         this._sprintEnergy = param1;
         if(this._sprintEnergy < 0)
         {
            this._sprintEnergy = 0;
         }
      }
      
      public function get Box2DCover() : b2Body
      {
         return this._box2D_cover;
      }
      
      public function set Box2DCover(param1:b2Body) : void
      {
         this._box2D_cover = param1;
         if(this._box2D_cover != null)
         {
            this._box2D_cover.GetUserData().objectData.PlayerCoverLevel = this._box2D_cover.GetUserData().objectData.PlayerCoverLevel + 1;
         }
      }
      
      public function get CoverObjectID() : int
      {
         if(!this.TakingCover)
         {
            return -1;
         }
         return this._cover_object_id;
      }
      
      public function set CoverObjectID(param1:int) : void
      {
         this._cover_object_id = param1;
      }
      
      public function get TakingCover() : Boolean
      {
         return this._taking_cover;
      }
      
      public function set TakingCover(param1:Boolean) : void
      {
         this._taking_cover = param1;
         if(!this._taking_cover)
         {
            if(this.Box2DCover != null)
            {
               --this.Box2DCover.GetUserData().objectData.PlayerCoverLevel;
               this.Box2DCover = null;
            }
         }
      }
      
      public function get StaggerTimer() : Number
      {
         return this._staggerTimer;
      }
      
      public function set StaggerTimer(param1:Number) : void
      {
         this._staggerTimer = param1;
      }
      
      public function get Staggering() : Boolean
      {
         return this._staggering;
      }
      
      public function set Staggering(param1:Boolean) : void
      {
         this._staggering = param1;
         if(!param1)
         {
            this._staggerTimer = 0;
         }
         else
         {
            this.Punching = false;
            this._knockdowned = false;
            this._falling = false;
            this._jumping = false;
         }
      }
      
      public function get DeathKneel() : Boolean
      {
         return this._deathKneel;
      }
      
      public function set DeathKneel(param1:Boolean) : void
      {
         this._deathKneel = param1;
         if(param1)
         {
            this.Staggering = false;
            this.Punching = false;
            this.CancelAFS();
         }
      }
      
      public function get Knockdowned() : Boolean
      {
         return this._knockdowned;
      }
      
      public function set Knockdowned(param1:Boolean) : void
      {
         this._knockdowned = param1;
         if(this._knockdowned)
         {
            this._stunTimer = 0;
            this._staggering = false;
            this.DeathKneel = false;
         }
      }
      
      public function IncreaseKnockdownGrade() : void
      {
         if(this.HP <= 0)
         {
            return;
         }
         if(this._knockdownGrade < 3)
         {
            this._knockdownGrade += 1;
            this._decreaseKnockdownGradeTimer = 12;
         }
      }
      
      public function get KnockdownGrade() : int
      {
         return this._knockdownGrade;
      }
      
      public function get KnockdownRiseSpeed() : Number
      {
         return 1;
      }
      
      public function get KickingCooldown() : Number
      {
         return this._kickingCooldown;
      }
      
      public function set KickingCooldown(param1:Number) : void
      {
         this._kickingCooldown = param1;
      }
      
      public function get KickingTimer() : Number
      {
         return this._kickingTimer;
      }
      
      public function set KickingTimer(param1:Number) : void
      {
         this._kickingTimer = param1;
      }
      
      public function get Kicking() : Boolean
      {
         return this._kicking;
      }
      
      public function set Kicking(param1:Boolean) : void
      {
         this._kicking = param1;
         if(this._kicking)
         {
            this.KickingTimer = 8;
            this._kickingCooldown = 8;
            this.TakingCover = false;
         }
      }
      
      public function get RangeWeaponTotalAmmo() : Number
      {
         if(this.CurrentRangeWeapon != null)
         {
            if(this.CurrentRangeWeapon.Properties.WeaponType == "FLAMETHROWER")
            {
               return this.CurrentRangeWeapon.Ammo / 10;
            }
            return this.CurrentRangeWeapon.Ammo;
         }
         return 0;
      }
      
      public function get RangeWeaponTotalDamage() : Number
      {
         if(this.CurrentRangeWeapon != null)
         {
            return this.CurrentRangeWeapon.TotalDamage;
         }
         return 0;
      }
      
      public function get RangeWeaponCanShootDown() : Boolean
      {
         if(this.CurrentRangeWeapon != null)
         {
            return this.CurrentRangeWeapon.CanShootDown;
         }
         return false;
      }
      
      public function get MeleeWeaponTotalDamage() : Number
      {
         return this.GetMeleeWeapon().TotalDamage;
      }
      
      public function get RangeWeaponRange() : Number
      {
         if(this.CurrentRangeWeapon != null)
         {
            return this.CurrentRangeWeapon.Properties.ShootRange;
         }
         return 40;
      }
      
      public function get RangeWeaponIsFlamethrower() : Boolean
      {
         if(this.CurrentRangeWeapon != null)
         {
            if(this.CurrentRangeWeapon.Properties.WeaponType == "FLAMETHROWER")
            {
               return true;
            }
         }
         return false;
      }
      
      public function get RangeWeaponIsBazooka() : Boolean
      {
         if(this.CurrentRangeWeapon != null)
         {
            if(this.CurrentRangeWeapon.Properties.WeaponType == "BAZOOKA")
            {
               return true;
            }
         }
         return false;
      }
      
      public function get MeleeWeaponRange() : Number
      {
         return this.GetMeleeWeapon().Properties.Range[this._punchComboNr - 1];
      }
      
      public function get MeleeWeaponHitSound() : String
      {
         return this.GetMeleeWeapon().Properties.HitSound;
      }
      
      public function get MeleeAnimation() : String
      {
         return this.GetMeleeWeapon().Properties.Animation;
      }
      
      public function get MeleeSwingSound() : String
      {
         return this.GetMeleeWeapon().Properties.SwingComboSounds[this._punchComboNr - 1];
      }
      
      public function get MeleeSwingEffect() : String
      {
         return this.GetMeleeWeapon().Properties.SwingComboEffects[this._punchComboNr - 1];
      }
      
      public function GetMeleeMaterialHitSound(param1:String) : String
      {
         param1 = param1.toUpperCase();
         var _loc2_:WeaponMeleeData = this.GetMeleeWeapon();
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_.Properties.HitMaterialSounds.length)
         {
            if(_loc2_.Properties.HitMaterialSounds[_loc3_][0] == param1)
            {
               return _loc2_.Properties.HitMaterialSounds[_loc3_][1];
            }
            _loc3_++;
         }
         return "";
      }
      
      public function GetMeleeMaterialHitEffect(param1:String) : String
      {
         param1 = param1.toUpperCase();
         var _loc2_:WeaponMeleeData = this.GetMeleeWeapon();
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_.Properties.HitMaterialEffects.length)
         {
            if(_loc2_.Properties.HitMaterialEffects[_loc3_][0] == param1)
            {
               return _loc2_.Properties.HitMaterialEffects[_loc3_][1];
            }
            _loc3_++;
         }
         return "";
      }
      
      public function GetKickMaterialHitSound(param1:String) : String
      {
         param1 = param1.toUpperCase();
         var _loc2_:int = 0;
         while(_loc2_ < this.kickHitMaterialSounds.length)
         {
            if(this.kickHitMaterialSounds[_loc2_][0] == param1)
            {
               return this.kickHitMaterialSounds[_loc2_][1];
            }
            _loc2_++;
         }
         return "";
      }
      
      public function GetKickMaterialHitEffect(param1:String) : String
      {
         param1 = param1.toUpperCase();
         var _loc2_:int = 0;
         while(_loc2_ < this.kickHitMaterialEffects.length)
         {
            if(this.kickHitMaterialEffects[_loc2_][0] == param1)
            {
               return this.kickHitMaterialEffects[_loc2_][1];
            }
            _loc2_++;
         }
         return "";
      }
      
      public function get HitPunchDamage() : Number
      {
         return this.GetMeleeWeapon().Properties.HitPunchFrameDamage[this._punchComboNr - 1];
      }
      
      public function GetMeleeWeapon() : WeaponMeleeData
      {
         if(this.CurrentMeleeWeapon != null)
         {
            return this.CurrentMeleeWeapon;
         }
         return this.DefaultMeleeWeapon;
      }
      
      public function get MinPunchComboFrame() : int
      {
         switch(this._punchComboNr)
         {
            case 1:
               return 6;
            case 2:
               return 7;
            case 3:
               return 8;
            default:
               return 0;
         }
      }
      
      public function get HitPunchComboFrame() : int
      {
         switch(this._punchComboNr)
         {
            case 1:
               return 4;
            case 2:
               return 5;
            case 3:
               return 6;
            default:
               return 0;
         }
      }
      
      public function get HitPunchStunTime() : Number
      {
         switch(this._punchComboNr)
         {
            case 1:
               return 3 + Math.random() * 5;
            case 2:
               return 4 + Math.random() * 5;
            case 3:
               return 5 + Math.random() * 5;
            default:
               return 0;
         }
      }
      
      public function get DoPunchCombo() : Boolean
      {
         return this._doPunchCombo;
      }
      
      public function set DoPunchCombo(param1:Boolean) : void
      {
         this._doPunchCombo = param1;
      }
      
      public function get PunchComboNr() : int
      {
         return this._punchComboNr;
      }
      
      public function set PunchComboNr(param1:int) : void
      {
         this.PunchHitPerformed = false;
         this._punchComboNr = param1;
      }
      
      public function get Punching() : Boolean
      {
         return this._punching;
      }
      
      public function set Punching(param1:Boolean) : void
      {
         if(!param1)
         {
            this.PunchComboNr = 1;
         }
         this._punching = param1;
      }
      
      public function get PunchHitPerformed() : Boolean
      {
         return this._punchHitPerformed;
      }
      
      public function set PunchHitPerformed(param1:Boolean) : void
      {
         this._punchHitPerformed = param1;
      }
      
      public function get Sprinting() : Boolean
      {
         return this._sprinting;
      }
      
      public function set Sprinting(param1:Boolean) : void
      {
         this._sprinting = param1;
      }
      
      public function get Running() : Boolean
      {
         return this._running;
      }
      
      public function set Running(param1:Boolean) : void
      {
         if(!param1)
         {
            if(this._sprinting)
            {
               this._sprinting = false;
               this._reSprintActivationDuration = 2;
            }
            else if(Boolean(this._running) && !this._jumping && !this.TakingCover)
            {
               this._sprintActivationDuration = 3;
            }
         }
         else if(this._reSprintActivationDuration > 0)
         {
            this._reSprintActivationDuration = 0;
            this._sprintActivationDuration = 0;
            this._sprinting = true;
         }
         else if(this._sprintActivationDuration > 0)
         {
            this._shortDiveAvailable = true;
            this._shortDiveTimer = 3;
            this._sprintActivationDuration = 0;
            this._sprinting = true;
         }
         this._running = param1;
      }
      
      public function get ShortDiveAvailable() : Boolean
      {
         return false;
      }
      
      public function set ShortDiveAvailable(param1:Boolean) : void
      {
         this._shortDiveAvailable = param1;
      }
      
      public function get AirVelocityY() : Number
      {
         return this._airVelocityY;
      }
      
      public function set AirVelocityY(param1:Number) : void
      {
         this._airVelocityY = param1;
      }
      
      public function get AirVelocityX() : Number
      {
         return this._airVelocityX;
      }
      
      public function set AirVelocityX(param1:Number) : void
      {
         this._airVelocityX = param1;
      }
      
      public function get TotalAirVelocity() : Number
      {
         return Math.sqrt(this._airVelocityX * this._airVelocityX + this._airVelocityY * this._airVelocityY);
      }
      
      public function get StairVelocityY() : Number
      {
         return this._stairVelocityY;
      }
      
      public function set StairVelocityY(param1:Number) : void
      {
         this._stairVelocityY = param1;
      }
      
      public function get StairVelocityX() : Number
      {
         return this._stairVelocityX;
      }
      
      public function set StairVelocityX(param1:Number) : void
      {
         this._stairVelocityX = param1;
      }
      
      public function get MovingDirectionInversed() : int
      {
         return this._movingDirectionInversed;
      }
      
      public function set MovingDirectionInversed(param1:int) : void
      {
         this._movingDirectionInversed = param1;
      }
      
      public function get LastDirX() : int
      {
         return this._last_dir_x;
      }
      
      public function set LastDirX(param1:int) : void
      {
         this._last_dir_x = param1;
      }
      
      public function get BurnState() : Number
      {
         if(this.Gone)
         {
            return 0;
         }
         return this._burnState;
      }
      
      public function set BurnState(param1:Number) : void
      {
         if(!this.Burned)
         {
            this._burnState = param1;
            this._inFireDelay = 3.5;
            if(this._burnState > 100)
            {
               this._burnState = 100;
            }
            else if(this._burnState < 0)
            {
               this._burnState = 0;
            }
         }
      }
      
      public function DecreaseBurnState() : void
      {
         if(this.BurnState < 100 && !this.Burned && !this.InWorldFire)
         {
            this.BurnState = 0;
         }
         else
         {
            this.BurnState -= 50;
            if(this.BurnState < 50)
            {
               this.BurnState = 50;
            }
         }
      }
      
      public function get BloodVisible() : Boolean
      {
         return this._hp <= 25 && !this.Burned;
      }
      
      public function set ForceHP(param1:Number) : void
      {
         this._barHP = param1;
         this._hp = param1;
      }
      
      public function get HP() : Number
      {
         return this._hp;
      }
      
      public function set HP(param1:Number) : void
      {
         if(this._hp <= 0)
         {
            return;
         }
         if(this._hp > param1)
         {
            this._hp_damage_timer = 24 * 3;
         }
         this._barHP = this._hp;
         this._hp = param1;
         if(this._hp <= 0)
         {
            this._hp = 0;
         }
         if(this._hp > 100)
         {
            this._hp = 100;
         }
         this._healthBarSpeed = (this._hp - this._barHP) / 6;
         this._showHealthTimer = 6;
      }
      
      public function get ShowHealthBar() : Boolean
      {
         if(this._showHealthTimer > -24)
         {
            return true;
         }
         return false;
      }
      
      public function get BarHP() : Number
      {
         return this._barHP;
      }
      
      public function get MovingDirectionX() : int
      {
         return this._movingDirectionX;
      }
      
      public function set MovingDirectionX(param1:int) : void
      {
         this._movingDirectionX = param1;
      }
      
      public function get PortalSpeedX() : Number
      {
         if(this.StuckToRocket)
         {
            return this.RocketRideProjectile.VelocityX;
         }
         if(this._staggering)
         {
            return -this.LastDirX * 10;
         }
         return this._portalSpeedX;
      }
      
      public function set PortalSpeedX(param1:Number) : void
      {
         this._portalSpeedX = param1;
      }
      
      public function get PortalDirectionX() : int
      {
         if(this.StuckToRocket)
         {
            return this.ConvertToDirection(this.RocketRideProjectile.VelocityX);
         }
         return this._portalDirectionX;
      }
      
      public function set PortalDirectionX(param1:int) : void
      {
         this._portalDirectionX = param1;
      }
      
      public function get CanBeKicked() : Boolean
      {
         if(this.IsImmune)
         {
            return false;
         }
         if(this._knockdownGrade >= 2)
         {
            return false;
         }
         if(this.GrabbedByPlayer)
         {
            return false;
         }
         if(this.IgnoreMe)
         {
            return false;
         }
         return true;
      }
      
      public function get GrabbedByPlayer() : Boolean
      {
         return this._grabbed_by_player;
      }
      
      public function set GrabbedByPlayer(param1:Boolean) : void
      {
         this._grabbed_by_player = param1;
      }
      
      public function get GrabbedPlayer() : Boolean
      {
         return this._grabbed_player;
      }
      
      public function set GrabbedPlayer(param1:Boolean) : void
      {
         this._grabbed_player = param1;
      }
      
      public function get GrabbedPlayerNr() : int
      {
         return this._grabbed_player_nr;
      }
      
      public function set GrabbedPlayerNr(param1:int) : void
      {
         this._grabbed_player = true;
         this._grabbed_player_nr = param1;
      }
      
      public function get GrabbedPlayerCharNr() : int
      {
         return this._grabbed_player_char_nr;
      }
      
      public function set GrabbedPlayerCharNr(param1:int) : void
      {
         this._grabbed_player_char_nr = param1;
      }
      
      public function set CharNr(param1:int) : void
      {
         this._char_nr = param1;
      }
      
      public function get CharNr() : int
      {
         return this._char_nr;
      }
      
      public function get IsImmune() : Boolean
      {
         return this.ImmunityTimer > 0 && !this.ImmunityDisabled;
      }
      
      private function ConvertToDirection(param1:Number) : int
      {
         if(param1 == 0)
         {
            return 0;
         }
         return param1 / Math.sqrt(param1 * param1);
      }
   }
}

