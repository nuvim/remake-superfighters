package Code.Data.Players
{
   import Code.Handler.OutputTrace;
   import flash.display.MovieClip;
   
   public class PlayerAnimation
   {
      
      private var _Handler_Output:OutputTrace;
      
      private var _current_frame:Number = 1;
      
      private var _loop_animation:Boolean = false;
      
      private var _animation_done:Boolean = false;
      
      private var _help_animation:Boolean = false;
      
      private var _aim_animation:Boolean = false;
      
      private var _disable_slowmotion_modifier:Boolean = false;
      
      private var _grabbed_player_updated:Boolean = false;
      
      private var _animation_done_func:Function;
      
      private var _current_animation:String = "";
      
      private var _is_rocket_ride:Boolean = false;
      
      private var _this:MovieClip;
      
      private var _blood:MovieClip;
      
      private var _this_gui:MovieClip;
      
      private var _blood_gui:MovieClip;
      
      private var _collision_mc:MovieClip;
      
      private var _PlayerState:PlayerState;
      
      private var _rotate_speed:Number = 0;
      
      private var _rotate_increase:Number = 0;
      
      private var _delay_frame:int = -1;
      
      private var _delay_timer:Number = 0;
      
      private var _next_blink_timer:Number = 0;
      
      private var _blink_duration_timer:Number = 0;
      
      public var UseGUI:Boolean = true;
      
      public function PlayerAnimation(param1:MovieClip, param2:MovieClip, param3:MovieClip, param4:PlayerState, param5:OutputTrace)
      {
         super();
         this._this = param1;
         this._blood = param2;
         this._collision_mc = param3;
         this._PlayerState = param4;
         this._Handler_Output = param5;
      }
      
      public function NewSkin(param1:MovieClip) : void
      {
         this._this = param1;
         this.ShowAnimation(this._current_animation,true);
      }
      
      public function SetGUISkin(param1:MovieClip, param2:MovieClip) : void
      {
         if(!this.UseGUI)
         {
            return;
         }
         this._this_gui = param1;
         this._blood_gui = param2;
         this.ShowAnimation(this._current_animation,true);
      }
      
      private function UpdateAnimation() : void
      {
         this._blood.visible = this._PlayerState.BloodVisible;
         if(this.UseGUI)
         {
            this._blood_gui.visible = this._PlayerState.BloodVisible;
         }
         if(this._PlayerState.IsImmune)
         {
            --this._next_blink_timer;
            if(this._next_blink_timer <= 0)
            {
               this._this.alpha = 0.2;
               if(this.UseGUI)
               {
                  this._this_gui.alpha = 0.2;
               }
               --this._blink_duration_timer;
               if(this._blink_duration_timer <= 0)
               {
                  this._blink_duration_timer = 1;
                  this._next_blink_timer = 3;
               }
            }
            else
            {
               this._this.alpha = 1;
               if(this.UseGUI)
               {
                  this._this_gui.alpha = 1;
               }
            }
         }
         else
         {
            this._this.alpha = 1;
            if(this.UseGUI)
            {
               this._this_gui.alpha = 1;
            }
            this._next_blink_timer = 0;
            this._blink_duration_timer = 1;
         }
         if(this._PlayerState.IgnoreMe)
         {
            this.ShowAnimation("EMPTY");
         }
         else if(this._PlayerState.StuckToRocket)
         {
            if(this._PlayerState.RocketRideProjectile.DirectionX > 0)
            {
               this.ShowAnimation("ROCKET_RIDE_R");
            }
            else
            {
               this.ShowAnimation("ROCKET_RIDE_L");
            }
         }
         else if(this._PlayerState.DeathKneel)
         {
            this.ShowAnimation("DEATH_KNEEL");
         }
         else if(this._PlayerState.GrabbedByPlayer)
         {
            this.ShowAnimation("GRABBED");
         }
         else if(this._PlayerState.Staggering)
         {
            this.ShowAnimation("STAGGER");
         }
         else if(this._PlayerState.Climbing)
         {
            if(this._PlayerState.ClimbingDirection == 1)
            {
               this.ShowAnimation("SLIDE");
            }
            else
            {
               this.ShowAnimation("CLIMB");
            }
         }
         else if(this._PlayerState.Knockdowned)
         {
            this.ShowAnimation("KNOCKDOWN");
         }
         else if(this._PlayerState.Falling)
         {
            if(this.FallingFoward())
            {
               this.ShowAnimation("FALL_F");
            }
            else
            {
               this.ShowAnimation("FALL_B");
            }
         }
         else if(this._PlayerState.IsStunned)
         {
            this.ShowAnimation("STUN_0" + this._PlayerState.StunAnimation);
         }
         else if(this._PlayerState.Aiming)
         {
            if(this._PlayerState.AimMode == 0)
            {
               if(this._PlayerState.AimTurningAround)
               {
                  this.ShowAnimation("start_" + this._PlayerState.CurrentRangeWeapon.Properties.AnimType);
               }
               else
               {
                  this.ShowAnimation("aim_" + this._PlayerState.CurrentRangeWeapon.Properties.AnimType);
               }
            }
            else if(this._PlayerState.AimMode == 1)
            {
               if(this._PlayerState.AimTurningAround)
               {
                  this.ShowAnimation("aim_turn");
               }
               else
               {
                  this.ShowAnimation("aim_" + this._PlayerState.CurrentThrowableWeapon.Properties.AnimType);
               }
            }
         }
         else if(this._PlayerState.Throwing)
         {
            this.ShowAnimation("THROW");
         }
         else if(this._PlayerState.Diving)
         {
            this.ShowAnimation("DIVE");
         }
         else if(this._PlayerState.Jumping)
         {
            if(this._PlayerState.JumpKickPerformed)
            {
               this.ShowAnimation("JUMPKICK");
            }
            else
            {
               this.ShowAnimation("JUMP");
            }
         }
         else if(this._PlayerState.Rolling)
         {
            if(Boolean(this._current_animation) && Boolean(this._animation_done))
            {
               this.ShowAnimation("ROLL",true);
            }
            else
            {
               this.ShowAnimation("ROLL");
            }
         }
         else if(this._PlayerState.Kicking)
         {
            this.ShowAnimation("KICK");
         }
         else if(this._PlayerState.Punching)
         {
            this.ShowAnimation(this._PlayerState.MeleeAnimation + "_0" + this._PlayerState.PunchComboNr);
         }
         else if(this._PlayerState.Kneeling)
         {
            this.ShowAnimation("KNEEL");
         }
         else if(this._PlayerState.TakingCover)
         {
            this.ShowAnimation("COVER");
         }
         else if(this._PlayerState.MovingDirectionX == 0)
         {
            this.ShowAnimation("IDLE");
         }
         else if(this._PlayerState.Sprinting)
         {
            this.ShowAnimation("SPRINT");
         }
         else
         {
            this.ShowAnimation("RUN");
         }
      }
      
      private function FallingFoward() : Boolean
      {
         if(this._PlayerState.LastDirX == 1 && this._PlayerState.AirVelocityX >= 0 || this._PlayerState.LastDirX == -1 && this._PlayerState.AirVelocityX < 0)
         {
            return true;
         }
         return false;
      }
      
      public function ShowAnimation(param1:String, param2:Boolean = false) : void
      {
         if(this._current_animation != param1.toUpperCase() || param2)
         {
            this._current_animation = param1.toUpperCase();
            if(param2)
            {
               this._this.gotoAndStop("IDLE");
               if(this.UseGUI)
               {
                  this._this_gui.gotoAndStop("IDLE");
                  this._blood_gui.gotoAndStop("IDLE");
               }
               this._collision_mc.gotoAndStop("IDLE");
               this._blood.gotoAndStop("IDLE");
            }
            if(param1 == "")
            {
               param1 = "IDLE";
            }
            this._this.gotoAndStop(param1.toUpperCase());
            if(this.UseGUI)
            {
               this._this_gui.gotoAndStop(param1.toUpperCase());
               this._blood_gui.gotoAndStop(param1.toUpperCase());
            }
            this._collision_mc.gotoAndStop(param1.toUpperCase());
            this._blood.gotoAndStop(param1.toUpperCase());
            this._current_frame = 0;
            this._aim_animation = false;
            this._animation_done = false;
            this._loop_animation = false;
            this._help_animation = false;
            this._grabbed_player_updated = false;
            this._disable_slowmotion_modifier = false;
            this._is_rocket_ride = false;
            switch(param1.toUpperCase())
            {
               case "ROCKET_RIDE_L":
               case "ROCKET_RIDE_R":
                  this._is_rocket_ride = true;
                  this._loop_animation = true;
                  break;
               case "AIM_TURN":
                  this._disable_slowmotion_modifier = true;
                  break;
               case "CLIMB":
               case "IDLE":
               case "STAGGER":
               case "SPRINT":
               case "GRABBED":
               case "RUN":
                  this._loop_animation = true;
                  break;
               case "DIVE":
                  this._help_animation = true;
                  this._loop_animation = true;
                  this._rotate_speed = 1.5;
                  this._rotate_increase = 0;
                  break;
               case "FALL_B":
               case "FALL_F":
                  this._help_animation = true;
                  this._loop_animation = true;
                  if(param1.toUpperCase() == "FALL_B")
                  {
                     this._rotate_speed = -10;
                     this._rotate_increase = -2;
                  }
                  else
                  {
                     this._rotate_speed = 10;
                     this._rotate_increase = 2;
                  }
                  break;
               default:
                  if(param1.toUpperCase().substr(0,3) == "AIM")
                  {
                     this._aim_animation = true;
                     this._loop_animation = true;
                  }
                  if(param1.toUpperCase().substr(0,5) == "START")
                  {
                     this._disable_slowmotion_modifier = true;
                  }
            }
         }
      }
      
      public function ProgressAnimation(param1:Number) : void
      {
         var _loc2_:int = 0;
         var _loc3_:MovieClip = null;
         var _loc4_:MovieClip = null;
         var _loc5_:MovieClip = null;
         var _loc6_:MovieClip = null;
         var _loc7_:MovieClip = null;
         var _loc8_:int = 0;
         this.UpdateAnimation();
         if(!this._animation_done)
         {
            if(this._delay_frame == this.CurrentFrame)
            {
               if(this._delay_timer > 0)
               {
                  this._delay_timer -= param1;
                  if(this._delay_timer <= 0)
                  {
                     this._delay_frame = -1;
                  }
                  return;
               }
            }
            if(this._current_frame == 0)
            {
               this._current_frame = 1;
               return;
            }
            if(this._is_rocket_ride)
            {
               this._PlayerState.LastDirX = 1;
               this._this.ANIM.rotation = this._PlayerState.RocketRideProjectile.Angle;
               if(this.UseGUI)
               {
                  this._this_gui.ANIM.rotation = this._PlayerState.RocketRideProjectile.Angle;
                  this._blood_gui.ANIM.rotation = this._PlayerState.RocketRideProjectile.Angle;
               }
               this._collision_mc.ANIM.rotation = this._PlayerState.RocketRideProjectile.Angle;
               this._blood.ANIM.rotation = this._PlayerState.RocketRideProjectile.Angle;
               this._current_frame += 1;
            }
            else if(this._help_animation)
            {
               this._current_frame += 1;
            }
            else
            {
               if(this._aim_animation)
               {
                  this._this.ANIM_WPN.rotation = this._PlayerState.CurrentAimPitch;
                  if(this.UseGUI)
                  {
                     this._this_gui.ANIM_WPN.rotation = this._PlayerState.CurrentAimPitch;
                     this._blood_gui.ANIM_WPN.rotation = this._PlayerState.CurrentAimPitch;
                  }
                  this._collision_mc.ANIM_WPN.rotation = this._PlayerState.CurrentAimPitch;
                  this._blood.ANIM_WPN.rotation = this._PlayerState.CurrentAimPitch;
                  if(this._PlayerState.AFSInProgress)
                  {
                     _loc2_ = int(this._PlayerState.CurrentRangeWeapon.Properties.FireSequence[this._PlayerState.LastFireFrame - 1].FrameNr);
                  }
                  else
                  {
                     _loc2_ = 1;
                  }
                  this._this.ANIM_WPN.gotoAndStop(_loc2_);
                  if(this.UseGUI)
                  {
                     this._this_gui.ANIM_WPN.gotoAndStop(_loc2_);
                     this._blood_gui.ANIM_WPN.gotoAndStop(_loc2_);
                  }
                  this._collision_mc.ANIM_WPN.gotoAndStop(_loc2_);
                  this._blood.ANIM_WPN.gotoAndStop(_loc2_);
                  return;
               }
               if(this._current_animation == "CLIMB" && !this._PlayerState.ClimbingAround)
               {
                  _loc2_ = Math.floor(this._current_frame);
                  this._this.ANIM.gotoAndStop(_loc2_);
                  if(this.UseGUI)
                  {
                     this._this_gui.ANIM.gotoAndStop(_loc2_);
                     this._blood_gui.ANIM.gotoAndStop(_loc2_);
                  }
                  this._collision_mc.ANIM.gotoAndStop(_loc2_);
                  this._blood.ANIM.gotoAndStop(_loc2_);
                  return;
               }
               if(this._current_frame >= 4 && this._current_animation == "KNOCKDOWN" && (Boolean(this._PlayerState.CantRise) || this._PlayerState.HP <= 0))
               {
                  this._current_frame = 4;
               }
               else if(!this._disable_slowmotion_modifier)
               {
                  if(this._current_animation == "KNOCKDOWN")
                  {
                     if(this._current_frame < 9)
                     {
                        this._current_frame += param1 * this._PlayerState.KnockdownRiseSpeed;
                        if(this._current_frame >= 9)
                        {
                           this._PlayerState.ImmunityTimer = PlayerState.KNOCKDOWN_IMMUNITY_TIME;
                        }
                     }
                     else
                     {
                        this._current_frame += param1 * this._PlayerState.KnockdownRiseSpeed;
                     }
                  }
                  else
                  {
                     this._current_frame += param1;
                  }
               }
               else
               {
                  this._current_frame += 1;
               }
            }
            if(this._help_animation)
            {
               _loc3_ = this._this.ANIM.HELPMC;
               _loc4_ = this._collision_mc.ANIM.HELPMC;
               _loc5_ = this._blood.ANIM.HELPMC;
               if(this.UseGUI)
               {
                  _loc7_ = this._blood_gui.ANIM.HELPMC;
                  _loc6_ = this._this_gui.ANIM.HELPMC;
               }
               _loc3_.rotation += this._rotate_speed * param1;
               _loc4_.rotation = _loc3_.rotation;
               _loc5_.rotation = _loc3_.rotation;
               if(this.UseGUI)
               {
                  _loc6_.rotation = _loc3_.rotation;
                  _loc7_.rotation = _loc3_.rotation;
               }
               if(Math.sqrt(this._rotate_speed * this._rotate_speed) < 36)
               {
                  this._rotate_speed += this._rotate_increase * param1;
               }
               if(this._current_animation == "DIVE")
               {
                  if(this._PlayerState.GrabbedPlayer)
                  {
                     if(!this._grabbed_player_updated)
                     {
                        this._grabbed_player_updated = true;
                     }
                  }
               }
            }
            else
            {
               _loc3_ = this._this.ANIM;
               _loc4_ = this._collision_mc.ANIM;
               _loc5_ = this._blood.ANIM;
               if(this.UseGUI)
               {
                  _loc6_ = this._this_gui.ANIM;
                  _loc7_ = this._blood_gui.ANIM;
               }
            }
            _loc8_ = Math.floor(this._current_frame);
            if(_loc8_ > _loc3_.totalFrames)
            {
               this.AnimationDone();
               if(this._loop_animation)
               {
                  this._current_frame = 1;
                  _loc8_ = 1;
               }
               else
               {
                  this._animation_done = true;
               }
            }
            if(!this._grabbed_player_updated)
            {
               _loc3_.gotoAndStop(_loc8_);
               _loc4_.gotoAndStop(_loc8_);
               _loc5_.gotoAndStop(_loc8_);
               if(this.UseGUI)
               {
                  _loc6_.gotoAndStop(_loc8_);
                  _loc7_.gotoAndStop(_loc8_);
               }
            }
            if(this._collision_mc.currentFrame == this._this.currentFrame)
            {
               if(_loc4_.currentFrame == _loc3_.currentFrame)
               {
                  if(_loc5_.currentFrame != _loc3_.currentFrame)
                  {
                  }
               }
            }
         }
         else
         {
            this.AnimationDone();
         }
      }
      
      private function AnimationDone() : void
      {
         if(this._PlayerState.Knockdowned)
         {
            this._PlayerState.Knockdowned = false;
         }
         if(this._PlayerState.Rolling)
         {
            this._PlayerState.Rolling = false;
         }
         if(this._PlayerState.Kicking)
         {
            this._PlayerState.Kicking = false;
         }
         if(this._PlayerState.Throwing)
         {
            this._PlayerState.Throwing = false;
         }
         if(this._PlayerState.Punching)
         {
            this._PlayerState.Punching = false;
         }
         if(this._PlayerState.AimTurningAround)
         {
            this._PlayerState.AimTurningAround = false;
         }
         if(this._PlayerState.DeathKneel)
         {
            this._PlayerState.Falling = true;
            this._PlayerState.AirVelocityX = this._PlayerState.LastDirX * 1.7;
            this._PlayerState.AirVelocityY = -1.5;
         }
      }
      
      public function get GrabRotation() : Number
      {
         return this._this.ANIM.HELPMC.rotation;
      }
      
      public function set GrabRotation(param1:Number) : void
      {
         this._this.ANIM.DOLL.rotation = param1;
         this._collision_mc.ANIM.DOLL.rotation = param1;
         this._blood.ANIM.DOLL.rotation = param1;
      }
      
      public function DelayAnimation(param1:int, param2:Number) : void
      {
         this._delay_frame = param1;
         this._delay_timer = param2;
      }
      
      public function NextFrame(param1:Number) : int
      {
         return Math.floor(this._current_frame + param1);
      }
      
      public function get CurrentFrame() : int
      {
         return Math.floor(this._current_frame);
      }
      
      public function get LastFrame() : int
      {
         return this._this.ANIM.totalFrames;
      }
      
      public function get Progress() : Number
      {
         return this.CurrentFrame / this.LastFrame;
      }
   }
}

