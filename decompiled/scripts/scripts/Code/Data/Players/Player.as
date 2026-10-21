package Code.Data.Players
{
   import Code.Box2D.Common.Math.*;
   import Code.Box2D.Dynamics.b2Body;
   import Code.Box2D.Dynamics.b2World;
   import Code.Data.*;
   import Code.Data.Weapons.*;
   import Code.Handler.Effects;
   import Code.Handler.Fires;
   import Code.Handler.InputKeyboard;
   import Code.Handler.Maps;
   import Code.Handler.OutputTrace;
   import Code.Handler.PathGrid;
   import Code.Handler.ProjectilesUpdater;
   import Code.Handler.Shake;
   import Code.Handler.Slowmo;
   import Code.Handler.Sounds;
   import Code.Particles.*;
   import fl.motion.*;
   import flash.display.*;
   import flash.geom.*;
   import flash.utils.*;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol54")]
   public class Player extends MovieClip
   {
      
      public static const KEY_UP:int = 0;
      
      public static const KEY_DOWN:int = 1;
      
      public static const KEY_LEFT:int = 2;
      
      public static const KEY_RIGHT:int = 3;
      
      public static const KEY_MELEE:int = 4;
      
      public static const KEY_FIRE:int = 5;
      
      public static const KEY_THROW:int = 6;
      
      public static const KEY_POWERUP:int = 7;
      
      public static const KEY_JUMP:int = 8;
      
      public static const KEY_KNEEL:int = 9;
      
      public static const KEY_SPRINT:int = 10;
      
      public static const AIM_SQUARE_DISTANCE:Number = 8;
      
      public static const HAZARDOUS_DISTANCE:Number = 25;
      
      public static const HAZARDOUS_DISTANCE_AVOID:Number = 45;
      
      public static const TEAM_SOLO:int = 0;
      
      public static const TEAM_1:int = 1;
      
      public static const TEAM_2:int = 2;
      
      public static const TEAM_3:int = 3;
      
      public static const TEAM_4:int = 4;
      
      private var _char:MovieClip;
      
      private var _game_mc:MovieClip;
      
      private var _Handler_Output:OutputTrace;
      
      private var _Handler_Keyboard:InputKeyboard;
      
      private var _Handler_Effects:Effects;
      
      private var _Handler_ProjectilesUpdater:*;
      
      private var _Handler_Maps:Maps;
      
      private var _Handler_Shake:Shake;
      
      private var _Handler_Sounds:Sounds;
      
      private var _Handler_Slowmo:Slowmo;
      
      private var _Handler_Fires:Fires;
      
      private var m_world:b2World;
      
      private var _PlayerState:PlayerState;
      
      private var _PlayerBars:PlayerBars;
      
      private var _PlayerAnimation:PlayerAnimation;
      
      private var _player_mc:MovieClip;
      
      private var _static_mc:MovieClip;
      
      private var _static_objects_hitbox_mc:MovieClip;
      
      private var _static_players_hitbox_mc:MovieClip;
      
      private var _static_players_area_mc:MovieClip;
      
      private var _static_world_hitbox_mc:MovieClip;
      
      private var _static_ladder_hitbox_mc:MovieClip;
      
      private var _static_world_cloud_hitbox_mc:MovieClip;
      
      private var _static_objects_cloud_hitbox_mc:MovieClip;
      
      private var _dynamic_mc:MovieClip;
      
      private var _lazer_mc:MovieClip;
      
      private var _aim_mc:MovieClip;
      
      private var _collision_mc:MovieClip;
      
      private var _player_area_mc:MovieClip;
      
      private var _blood_mc:MovieClip;
      
      private var _keys:Array;
      
      private var _keyPressed:Array;
      
      private var _bot:Boolean = false;
      
      private var _team:Number;
      
      private var _old_this_x:Number;
      
      private var _old_this_y:Number;
      
      private var _this_x:Number;
      
      private var _this_y:Number;
      
      private var _game_speed:Number = 1;
      
      private var _last_slowmotion:SlowmoData = null;
      
      private var _slowmotion_timer:int = 0;
      
      private var _slowmotion_modifier:Number = 1;
      
      private var _MapArea:PlayerAreaData;
      
      private var RecalculateCamArea:Function;
      
      private var _players:Array;
      
      private var _bullet_game_speed:Number = 1;
      
      private var _lazer_rnd:Number = 0;
      
      private var _startAimASAP:Boolean = false;
      
      private var _cancelAimingASAP:Boolean = false;
      
      private var _smokeDelay:Number = 0;
      
      private var _pathGrid:PathGrid;
      
      private var _deathScreamDone:Boolean = false;
      
      private var _lastBounceY:Number;
      
      private var _botTimer:Number;
      
      private var _BotState:BotState;
      
      private var _activated:Boolean = false;
      
      private var _char_gui:MovieClip;
      
      private var _blood_gui:MovieClip;
      
      private var _gui_mc:MovieClip;
      
      private var _despawnTimer:int = 96;
      
      private var b:b2Body;
      
      public var CameraFocus:Boolean = true;
      
      private var _indicationWeapon:b2Body = null;
      
      private var _performJumpDownLevel:Boolean = false;
      
      private var _jumpDownPosYDisable:Number = 0;
      
      private var _downTimer:Number;
      
      private var _enableJumpDownLevel:Boolean = false;
      
      private var objectImpactList:Array;
      
      private var _standingOnObject:b2Body = null;
      
      private var _flameAwayCounter:Number = 0;
      
      private var _flameAwayTimer:Number;
      
      private var _flameAwayActivated:Boolean = false;
      
      private var AFSUpdated:Boolean = false;
      
      private var _button_in_melee_range:Boolean = false;
      
      private var _button_to_activate:b2Body = null;
      
      internal var _headColl:Boolean;
      
      internal var _sideColl:Boolean;
      
      internal var _edgePositionL:Number;
      
      internal var _edgePositionR:Number;
      
      private var _staggerFragileObject:b2Body = null;
      
      internal var _edgePosition:Number;
      
      private var _playerNr:int;
      
      public function Player(param1:int, param2:MovieClip, param3:b2World, param4:Maps, param5:Sounds, param6:Slowmo, param7:Shake, param8:Effects, param9:ProjectilesUpdater, param10:OutputTrace, param11:Point, param12:Number, param13:int, param14:Function, param15:Array, param16:PathGrid)
      {
         super();
         this._game_mc = param2;
         this.m_world = param3;
         this._Handler_Output = param10;
         this._Handler_Effects = param8;
         this._Handler_ProjectilesUpdater = param9;
         this._Handler_Maps = param4;
         this._Handler_Sounds = param5;
         this._Handler_Slowmo = param6;
         this._Handler_Shake = param7;
         this._pathGrid = param16;
         this.PlayerNr = param13;
         this.RecalculateCamArea = param14;
         this._static_mc = MovieClip(this._game_mc.getChildByName("STATIC"));
         var _loc17_:MovieClip = MovieClip(this._game_mc.getChildByName("GAME_WINDOW"));
         this._dynamic_mc = MovieClip(MovieClip(_loc17_.getChildByName("DYNAMICHOLDER")).getChildByName("DYNAMIC"));
         this._static_ladder_hitbox_mc = MovieClip(this._static_mc.getChildByName("LADDER_HITBOX"));
         this._static_world_hitbox_mc = MovieClip(this._static_mc.getChildByName("WORLD_HITBOX"));
         this._static_world_cloud_hitbox_mc = MovieClip(this._static_mc.getChildByName("WORLD_CLOUD_HITBOX"));
         this._static_objects_cloud_hitbox_mc = MovieClip(this._static_world_cloud_hitbox_mc.getChildByName("OBJECTS_CLOUD_HITBOX"));
         this._static_objects_hitbox_mc = MovieClip(this._static_world_hitbox_mc.getChildByName("OBJECTS_HITBOX"));
         this._static_players_hitbox_mc = MovieClip(this._static_mc.getChildByName("PLAYERS_HITBOX"));
         this._static_players_area_mc = MovieClip(this._static_mc.getChildByName("PLAYERS_AREA"));
         this._lazer_mc = new MovieClip();
         this._lazer_mc.visible = false;
         this._aim_mc = new player_aim();
         this._aim_mc.visible = false;
         MovieClip(this._dynamic_mc.getChildByName("LAZERS")).addChild(this._lazer_mc);
         MovieClip(this._dynamic_mc.getChildByName("LAZERS")).addChild(this._aim_mc);
         this._collision_mc = new player_hitarea();
         this._player_area_mc = new MovieClip();
         this._player_area_mc.graphics.lineStyle(1,16711680,0.5);
         this._player_area_mc.graphics.beginFill(16711680,0.5);
         this._player_area_mc.graphics.moveTo(-6,2);
         this._player_area_mc.graphics.lineTo(-6,-18);
         this._player_area_mc.graphics.lineTo(6,-18);
         this._player_area_mc.graphics.lineTo(6,2);
         this._player_area_mc.graphics.lineTo(-6,2);
         this._player_area_mc.graphics.endFill();
         this._static_players_hitbox_mc.addChild(this._collision_mc);
         this._static_players_area_mc.addChild(this._player_area_mc);
         this._char = PlayerCharacter.Get(param1);
         this._char.x = 0;
         this._char.y = 0;
         this.addChild(this._char);
         this._blood_mc = new player_blood();
         this._blood_mc.visible = false;
         this.addChild(this._blood_mc);
         this._player_mc = MovieClip(this._dynamic_mc.getChildByName("PLAYERS"));
         this._player_mc.addChild(this);
         this.x = param11.x;
         this.y = param11.y;
         this._team = param12;
         if(this._team == 0)
         {
            this._team = -this.PlayerNr - 1;
         }
         this._keyPressed = new Array(20);
         var _loc18_:* = 0;
         while(_loc18_ < this._keyPressed.length)
         {
            this._keyPressed[_loc18_] = false;
            _loc18_++;
         }
         this._PlayerState = new PlayerState();
         this._PlayerState.Team = this._team;
         this._PlayerState.CharNr = param1;
         this._PlayerState.StopStaggerFunc = this.StopStaggerFunc;
         this._PlayerAnimation = new PlayerAnimation(this._char,this._blood_mc,this._collision_mc,this._PlayerState,this._Handler_Output);
         var _loc19_:MovieClip = MovieClip(this._dynamic_mc.parent.parent.getChildByName("GUI"));
         this._PlayerBars = new PlayerBars(this._PlayerState,_loc19_);
         this._players = param15;
         this._Handler_Output.Trace("Player Constructed at: " + param11);
      }
      
      public function set ShowBars(param1:Boolean) : void
      {
         if(param1)
         {
            this._PlayerBars.Show();
         }
         else
         {
            this._PlayerBars.Hide();
         }
      }
      
      public function NoGUI() : void
      {
         this._PlayerAnimation.UseGUI = false;
      }
      
      public function SetGUI(param1:MovieClip) : void
      {
         this._gui_mc = param1;
         this._gui_mc.visible = true;
         var _loc2_:MovieClip = new MovieClip();
         this._char_gui = PlayerCharacter.Get(this._PlayerState.CharNr);
         this._blood_gui = new player_blood();
         _loc2_.addChild(this._char_gui);
         _loc2_.scaleX = 1;
         _loc2_.scaleY = 1;
         this._gui_mc.addChild(_loc2_);
         this._gui_mc.addChild(this._blood_gui);
         _loc2_.x = this._gui_mc.player_mc.x;
         _loc2_.y = this._gui_mc.player_mc.y;
         this._blood_gui.x = this._gui_mc.player_mc.x;
         this._blood_gui.y = this._gui_mc.player_mc.y;
         this._PlayerAnimation.SetGUISkin(this._char_gui,this._blood_gui);
         this._PlayerAnimation.ShowAnimation("aim_pistol");
         this._PlayerBars.SetGUI(this._gui_mc);
      }
      
      private function SetNumTo(param1:MovieClip, param2:int) : void
      {
         var _loc3_:int = param2 % 10;
         var _loc4_:int = int((param2 - _loc3_) / 10);
         if(_loc3_ == 0)
         {
            param1.dig_1.gotoAndStop(10);
         }
         else
         {
            param1.dig_1.gotoAndStop(_loc3_);
         }
         if(_loc4_ == 0)
         {
            param1.dig_10.gotoAndStop(10);
         }
         else
         {
            param1.dig_10.gotoAndStop(_loc4_);
         }
      }
      
      public function UpdateGUI() : void
      {
         if(!this._PlayerAnimation.UseGUI)
         {
            return;
         }
         this._gui_mc.melee.gotoAndStop(this._PlayerState.GetMeleeWeapon().Properties.WeaponType);
         if(this._PlayerState.CurrentThrowableWeapon.Ammo <= 0)
         {
            this._gui_mc.throwable.gotoAndStop("EMPTY");
            this._gui_mc.throwable_num.visible = false;
         }
         else
         {
            this._gui_mc.throwable.gotoAndStop(this._PlayerState.CurrentThrowableWeapon.Properties.WeaponType);
            this._gui_mc.throwable_num.visible = true;
            this.SetNumTo(this._gui_mc.throwable_num,this._PlayerState.CurrentThrowableWeapon.Ammo);
         }
         this.UpdateGUIRanged();
         if(this._PlayerState.CurrentPowerupWeapon == null)
         {
            this._gui_mc.powerup.gotoAndStop("EMPTY");
         }
         else
         {
            this._gui_mc.powerup.gotoAndStop(this._PlayerState.CurrentPowerupWeapon.Properties.WeaponType);
         }
      }
      
      private function UpdateGUIRanged() : void
      {
         if(!this._PlayerAnimation.UseGUI)
         {
            return;
         }
         if(this._PlayerState.CurrentRangeWeapon == null)
         {
            this._gui_mc.ranged.gotoAndStop("EMPTY");
            this._gui_mc.ranged_num.visible = false;
         }
         else
         {
            this._gui_mc.ranged.gotoAndStop(this._PlayerState.CurrentRangeWeapon.Properties.WeaponType);
            this._gui_mc.ranged_num.visible = true;
            if(this._PlayerState.CurrentRangeWeapon.Properties.WeaponType == "SHOTGUN")
            {
               this.SetNumTo(this._gui_mc.ranged_num,this._PlayerState.CurrentRangeWeapon.Ammo / 4);
            }
            else
            {
               this.SetNumTo(this._gui_mc.ranged_num,this._PlayerState.CurrentRangeWeapon.Ammo);
            }
         }
      }
      
      public function SetSign(param1:int) : void
      {
         this._PlayerBars.SetSign(param1);
      }
      
      public function SetAI(param1:Number) : void
      {
         this._bot = true;
         this._BotState = new BotState();
         this._BotState.Difficulty = param1;
         if(this._BotState.Difficulty == BotState.EASY)
         {
            this._PlayerState.ImmunityDisabled = true;
         }
         this._Handler_Output.Trace("Bot difficulty set to: " + this._BotState.Difficulty);
      }
      
      public function SetControls(param1:InputKeyboard, param2:Array) : void
      {
         this._Handler_Keyboard = param1;
         this._keys = param2;
         this._Handler_Output.Trace("Controls set to: " + this._keys);
      }
      
      public function Activate() : void
      {
         this._activated = true;
         if(this._bot)
         {
            this._botTimer = setInterval(function():*
            {
               clearInterval(_botTimer);
               _BotState._targetChooseTimer = setInterval(BotChooseTarget_Tick,200);
               _botTimer = setInterval(function():*
               {
                  clearInterval(_botTimer);
                  _botTimer = setInterval(UpdateEventNPC,1000 / 24);
                  _BotState._targetInSightTimer = setInterval(BotInSightCheck_Tick,300);
                  _BotState._randomizTimer = setInterval(BotRandomize,4000);
               },25);
            },10 + this.PlayerNr * 3 % 20);
         }
         else
         {
            this._Handler_Keyboard.AddHandler(this._keys[KEY_POWERUP],this.UsePowerup);
            this._Handler_Keyboard.AddHandler(this._keys[KEY_THROW],this.ThrowDown,this.ThrowUp);
            this._Handler_Keyboard.AddHandler(this._keys[KEY_FIRE],this.RangedDown,this.RangedUp);
            this._Handler_Keyboard.AddHandler(this._keys[KEY_MELEE],this.Melee);
            this._Handler_Keyboard.AddHandler(this._keys[KEY_JUMP],this.Jump);
            this._Handler_Keyboard.AddHandler(this._keys[KEY_KNEEL],this.KneelPressed,this.KneelReleased);
            this._Handler_Keyboard.AddHandler(this._keys[KEY_SPRINT],this.ActivateSprint,this.DeactivateSprint);
            this._Handler_Keyboard.AddHandler(this._keys[KEY_UP],this.UpPressed);
            this._Handler_Keyboard.AddHandler(this._keys[KEY_DOWN],this.DownPressed);
         }
      }
      
      public function GiveStartItems(param1:WeaponData = null, param2:WeaponThrowableData = null, param3:WeaponMeleeData = null, param4:WeaponPowerupData = null) : void
      {
         this._PlayerState.CurrentRangeWeapon = param1;
         this._PlayerState.CurrentThrowableWeapon = param2;
         this._PlayerState.CurrentMeleeWeapon = param3;
         this._PlayerState.CurrentPowerupWeapon = param4;
      }
      
      public function GiveDefaultMelee(param1:WeaponMeleeData) : void
      {
         this._PlayerState.DefaultMeleeWeapon = param1;
      }
      
      public function Initialize(param1:PlayerAreaData) : void
      {
         this._MapArea = param1;
         var _loc2_:Number = 1;
         if(this._static_world_hitbox_mc.hitTestPoint(this.x,this.y,true))
         {
            _loc2_ = -1;
         }
         var _loc3_:* = 0;
         while(_loc3_ < 100)
         {
            if(!this._static_world_hitbox_mc.hitTestPoint(this.x,this.y,true) && !this._static_world_cloud_hitbox_mc.hitTestPoint(this.x,this.y,true))
            {
               this.y += _loc2_;
            }
            _loc3_++;
         }
         this._this_x = this.x;
         this._this_y = this.y;
         this._PlayerAnimation.ShowAnimation("idle");
      }
      
      public function LinkToFire(param1:Fires) : void
      {
         this._Handler_Fires = param1;
      }
      
      public function Update(param1:Number) : void
      {
         if(this._slowmotion_timer > 0)
         {
            --this._slowmotion_timer;
            this._game_speed = param1 * this._slowmotion_modifier;
            this._bullet_game_speed = param1 * this._slowmotion_modifier * 0.75;
            if(this._game_speed > 1)
            {
               this._game_speed = 1;
            }
            if(this._bullet_game_speed > 1)
            {
               this._bullet_game_speed = 1;
            }
         }
         else
         {
            this._game_speed = param1;
            this._bullet_game_speed = param1;
            if(param1 < 1)
            {
               this._bullet_game_speed *= 0.5;
            }
         }
         if(this._PlayerState.HP <= 0)
         {
            if(this._despawnTimer > 0)
            {
               --this._despawnTimer;
            }
            if(!this._deathScreamDone)
            {
               if(Math.random() < 0.02)
               {
                  this._Handler_Sounds.PlaySoundAt("WILHELM",this.PosX(),this.PosY());
               }
               this._deathScreamDone = true;
            }
         }
         if(this._PlayerState.IgnoreMe)
         {
            this._PlayerState.UpdateCameraIgnoreTimer();
            return;
         }
         if(this.RemoveFromList)
         {
            return;
         }
         if(!this._bot)
         {
            this.UpdateEventPC();
         }
         if(this._game_speed != 0)
         {
            if(!this._PlayerState.Gone)
            {
               this.MainUpdate();
               this._PlayerState.Update(this._game_speed);
               this._char_gui.scaleX = this.scaleX;
               this._blood_gui.scaleX = this.scaleX;
            }
         }
         this._PlayerAnimation.ProgressAnimation(this._game_speed);
         this._PlayerBars.Update(this.x,this.y,this._dynamic_mc.scaleX);
      }
      
      private function UpdateEventPC() : void
      {
         if(!this._activated)
         {
            return;
         }
         var _loc1_:* = 0;
         while(_loc1_ < this._keys.length)
         {
            if(this._Handler_Keyboard.KeyIsDown(this._keys[_loc1_]))
            {
               this._keyPressed[_loc1_] = true;
            }
            else
            {
               this._keyPressed[_loc1_] = false;
            }
            _loc1_++;
         }
      }
      
      private function UpdateEventNPC() : void
      {
         var _loc1_:int = 0;
         var _loc2_:Number = NaN;
         var _loc3_:int = 0;
         var _loc4_:* = undefined;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Boolean = false;
         var _loc13_:Boolean = false;
         if(this._PlayerState.HP <= 0)
         {
            clearInterval(this._botTimer);
            clearInterval(this._BotState._targetChooseTimer);
            clearInterval(this._BotState._targetInSightTimer);
            clearInterval(this._BotState._randomizTimer);
            return;
         }
         if(this._PlayerState.StuckToRocket)
         {
            clearInterval(this._BotState._targetChooseTimer);
            clearInterval(this._BotState._targetInSightTimer);
            clearInterval(this._BotState._randomizTimer);
            this.SetBotKey(KEY_UP,false);
            this.SetBotKey(KEY_DOWN,false);
            if(this._BotState.Difficulty < BotState.HARD)
            {
               this.SetBotKey(KEY_RIGHT,false);
               this.SetBotKey(KEY_LEFT,false);
               return;
            }
            _loc2_ = 99999;
            _loc3_ = -1;
            _loc1_ = 0;
            while(_loc1_ < this._players.length)
            {
               if(this._players[_loc1_].State.HP > 0 && this._players[_loc1_].Team != this.Team && _loc1_ != this.PlayerNr)
               {
                  _loc4_ = Math.sqrt(Math.pow(this._players[_loc1_].MidPosX() - this.MidPosX(),2) + Math.pow(this._players[_loc1_].MidPosY() - this.MidPosY(),2));
                  if(_loc4_ < _loc2_)
                  {
                     _loc2_ = _loc4_;
                     _loc3_ = _loc1_;
                  }
               }
               _loc1_++;
            }
            if(_loc3_ == -1)
            {
               this.SetBotKey(KEY_LEFT,false);
               this.SetBotKey(KEY_RIGHT,false);
               return;
            }
            this._BotState.TargetPlayer = this._players[_loc3_];
            if(!this._BotState.FirstRocketTurnDone && (this._PlayerState.RocketRideProjectile.DirectionX > 0 && this._BotState.TargetPlayer.MidPosX() < this.MidPosX() || this._PlayerState.RocketRideProjectile.DirectionX < 0 && this._BotState.TargetPlayer.MidPosX() > this.MidPosX()))
            {
               if(this._PlayerState.RocketRideProjectile.DirectionX < 0)
               {
                  this.SetBotKey(KEY_LEFT,false);
                  this.SetBotKey(KEY_RIGHT,true);
               }
               else
               {
                  this.SetBotKey(KEY_RIGHT,false);
                  this.SetBotKey(KEY_LEFT,true);
               }
               return;
            }
            this._BotState.FirstRocketTurnDone = true;
            _loc5_ = Math.atan2(this._BotState.TargetPlayer.MidPosY() - this.MidPosY(),this._BotState.TargetPlayer.MidPosX() - this.MidPosX());
            _loc6_ = Math.atan2(this._PlayerState.RocketRideProjectile.DirectionY,this._PlayerState.RocketRideProjectile.DirectionX);
            _loc7_ = _loc5_ * (180 / Math.PI);
            _loc8_ = _loc6_ * (180 / Math.PI);
            _loc9_ = 10;
            _loc10_ = _loc8_;
            _loc11_ = _loc8_;
            _loc1_ = 0;
            while(_loc1_ < 180)
            {
               _loc10_ -= 4;
               _loc11_ += 4;
               if(_loc10_ < -180)
               {
                  _loc10_ += 360;
               }
               if(_loc11_ > 180)
               {
                  _loc11_ -= 360;
               }
               _loc12_ = Math.abs(_loc10_ - _loc7_) < _loc9_;
               _loc13_ = Math.abs(_loc11_ - _loc7_) < _loc9_;
               if(_loc12_ && _loc13_)
               {
                  this.SetBotKey(KEY_LEFT,false);
                  this.SetBotKey(KEY_RIGHT,false);
               }
               else if(_loc12_)
               {
                  this.SetBotKey(KEY_RIGHT,false);
                  this.SetBotKey(KEY_LEFT,true);
               }
               else if(_loc13_)
               {
                  this.SetBotKey(KEY_LEFT,false);
                  this.SetBotKey(KEY_RIGHT,true);
               }
               _loc1_ += 4;
            }
            return;
         }
         if(this._BotState.TargetPlayer != null)
         {
            if(this._BotState.TargetPlayer.State.HP <= 0)
            {
               this._BotState.TargetPlayer = null;
            }
         }
         if(this._PlayerState.BotInterrupt)
         {
            _loc1_ = 0;
            while(_loc1_ <= 9)
            {
               this.SetBotKey(_loc1_,false);
               _loc1_++;
            }
            this._BotState.Phase = BotState.INTERRUPTED;
            return;
         }
         if(this._BotState.Phase == BotState.INTERRUPTED)
         {
            this.BotGoForReset(true);
            this.BotChooseTarget();
            this._BotState.Phase = BotState.IDLE;
         }
         if(this._BotState.PhaseDelay > 0)
         {
            --this._BotState.PhaseDelay;
            return;
         }
         if(this.BotDodgeRocket())
         {
            if(this._PlayerState.Aiming)
            {
               this._BotState.Phase = BotState.CANCEL_AIM;
            }
            else if(Math.random() < 0.7 || !this._PlayerState.CanRoll || Boolean(this.BotFacingEdge()))
            {
               this.SetBotKey(KEY_UP,true);
               this.SetBotKey(KEY_UP,false);
            }
            else
            {
               if(Boolean(this._keyPressed[KEY_LEFT]) && Boolean(this._keyPressed[KEY_RIGHT]))
               {
                  if(this._PlayerState.LastDirX == 1)
                  {
                     this.SetBotKey(KEY_LEFT,false);
                  }
                  else
                  {
                     this.SetBotKey(KEY_RIGHT,false);
                  }
               }
               else if(!this._keyPressed[KEY_LEFT] && !this._keyPressed[KEY_RIGHT])
               {
                  if(this._PlayerState.LastDirX == 1)
                  {
                     this.SetBotKey(KEY_RIGHT,true);
                  }
                  else
                  {
                     this.SetBotKey(KEY_LEFT,true);
                  }
               }
               this.SetBotKey(KEY_DOWN,true);
            }
         }
         if(Boolean(this.BotDodgeBullet()) || Boolean(this._BotState.DodgeBullet))
         {
            if(!this._PlayerState.Aiming)
            {
               this.BotCheckCover();
               if(this._PlayerState.CanRoll)
               {
                  if(Boolean(this._keyPressed[KEY_LEFT]) && Boolean(this._keyPressed[KEY_RIGHT]))
                  {
                     if(this._PlayerState.LastDirX == 1)
                     {
                        this.SetBotKey(KEY_LEFT,false);
                     }
                     else
                     {
                        this.SetBotKey(KEY_RIGHT,false);
                     }
                  }
                  else if(!this._keyPressed[KEY_LEFT] && !this._keyPressed[KEY_RIGHT])
                  {
                     if(this._PlayerState.LastDirX == 1)
                     {
                        this.SetBotKey(KEY_RIGHT,true);
                     }
                     else
                     {
                        this.SetBotKey(KEY_LEFT,true);
                     }
                  }
                  if(this.BotFacingEdge())
                  {
                     if(this.BotFacingEdge(-1))
                     {
                        this.SetBotKey(KEY_UP,false);
                        this.SetBotKey(KEY_UP,true);
                        this.SetBotKey(KEY_UP,false);
                        this._BotState.Phase = BotState.FOLLOW_PATH;
                        this._BotState.DodgeBullet = false;
                        return;
                     }
                     if(this._keyPressed[KEY_LEFT])
                     {
                        this.SetBotKey(KEY_LEFT,false);
                        this.SetBotKey(KEY_RIGHT,true);
                     }
                     else
                     {
                        this.SetBotKey(KEY_RIGHT,false);
                        this.SetBotKey(KEY_LEFT,true);
                     }
                  }
                  this.DisableJumpDownLevel();
                  this.SetBotKey(KEY_DOWN,true);
               }
               else
               {
                  if(this._BotState.NextResultNode != null)
                  {
                     if(this._BotState.NextResultNode.PrevBind != null)
                     {
                        switch(this._BotState.NextResultNode.PrevBind.MovementType)
                        {
                           case PathBind.SPRINTJUMP:
                           case PathBind.JUMP:
                           case PathBind.DIVE:
                           case PathBind.CLOUDDOWN:
                              this._BotState.DodgeBullet = false;
                              return;
                        }
                     }
                  }
                  this.SetBotKey(KEY_UP,true);
                  this.SetBotKey(KEY_UP,false);
               }
               this._BotState.DodgeBullet = false;
               return;
            }
            this._BotState.DodgeBullet = true;
            this._BotState.Phase = BotState.CANCEL_AIM;
         }
         if(this._PlayerState.BurnState >= 60 || !this._PlayerState.InWorldFire && this._PlayerState.BurnState > 20 && !this._BotState.RunAwayFromHazards || !this._PlayerState.InWorldFire && Boolean(this._PlayerState.FireRank1Attached) && this._PlayerState.HP < 10 && !this._BotState.RunAwayFromHazards)
         {
            if(this._PlayerState.Aiming)
            {
               if(this._PlayerState.HP < 10)
               {
                  this.SetBotKey(KEY_MELEE,!this._keyPressed[KEY_MELEE]);
                  this._BotState.Phase = BotState.FOLLOW_PATH;
                  return;
               }
               this._BotState.CancelAimSoon = true;
            }
            else if(this._PlayerState.CanRoll)
            {
               this.BotCheckCover();
               if(this._PlayerState.Sprinting)
               {
                  this.SetBotKey(KEY_LEFT,false);
                  this.SetBotKey(KEY_RIGHT,false);
                  return;
               }
               this.SetBotKey(KEY_MELEE,false);
               this.SetBotKey(KEY_UP,false);
               if(this._PlayerState.OnGround)
               {
                  if(!this._PlayerState.Rolling)
                  {
                     if(this._PlayerState.LastDirX == 1)
                     {
                        this.SetBotKey(KEY_LEFT,false);
                        this.SetBotKey(KEY_RIGHT,true);
                     }
                     else
                     {
                        this.SetBotKey(KEY_RIGHT,false);
                        this.SetBotKey(KEY_LEFT,true);
                     }
                     this.DisableJumpDownLevel();
                     this.SetBotKey(KEY_DOWN,true);
                     return;
                  }
                  this.SetBotKey(KEY_DOWN,false);
               }
               if(this._BotState.Phase == BotState.MELEE && this._PlayerState.BurnState >= 45)
               {
                  return;
               }
            }
         }
         if(!this._PlayerState.Sprinting && this._PlayerState.SprintEnergy > 40)
         {
            if(this._PlayerState.OnGround)
            {
               if(this._BotState.RunOften)
               {
                  if(this._PlayerState.Running)
                  {
                     this.SetBotKey(KEY_LEFT,false);
                     this.SetBotKey(KEY_RIGHT,false);
                     return;
                  }
               }
            }
         }
         if(this._BotState.Phase == BotState.IDLE)
         {
            this.SetBotKey(KEY_DOWN,false);
            if(this._PlayerState.ControllAble)
            {
               if(this._BotState.TargetPlayer != null || this._BotState.TargetWeapon != null || Boolean(this._BotState.RunAwayFromHazards))
               {
                  this._BotState.Phase = BotState.FOLLOW_PATH;
               }
               else if(Boolean(this._BotState.TargetInSight) && this._PlayerState.CurrentRangeWeapon != null && !BotState.FOLLOW_ONLY)
               {
                  this._BotState.Phase = BotState.AIM;
               }
            }
         }
         if(this._BotState.Phase == BotState.MELEE)
         {
            this.BotStateMelee();
         }
         else if(this._BotState.Phase == BotState.GRAB_WEAPON)
         {
            this.BotStateGrabWeapon();
         }
         else if(this._BotState.Phase == BotState.FOLLOW_PATH)
         {
            this.BotStateFollowPath();
         }
         else if(this._BotState.Phase == BotState.CANCEL_AIM)
         {
            this.BotStateCancelAim();
         }
         else if(this._BotState.Phase == BotState.AIM)
         {
            this.BotStateAim();
         }
         else if(this._BotState.Phase == BotState.SHOOT)
         {
            this.BotStateShoot();
         }
      }
      
      private function BotFacingEdgeMelee(param1:int = 1) : Boolean
      {
         return this.DetectEdge(this._PlayerState.LastDirX * param1,18,true);
      }
      
      private function BotFacingEdge(param1:int = 1) : Boolean
      {
         return this.DetectEdge(this._PlayerState.LastDirX * param1,45,true);
      }
      
      private function BotRandomize() : void
      {
         switch(Math.floor(Math.random() * 3.999))
         {
            case 0:
               this._BotState.FollowToAimMinimumDistance = 10;
               break;
            case 1:
               this._BotState.FollowToAimMinimumDistance = 30;
               break;
            case 2:
               this._BotState.FollowToAimMinimumDistance = 60;
               break;
            case 3:
               this._BotState.FollowToAimMinimumDistance = 100;
         }
         switch(this._BotState.Difficulty)
         {
            case BotState.EASY:
               this._BotState.RunOften = false;
               break;
            case BotState.MEDIUM:
               this._BotState.RunOften = Math.random() < 0.4;
               break;
            case BotState.HARD:
               this._BotState.RunOften = true;
         }
         if(this._BotState.Difficulty == BotState.EASY)
         {
            this._BotState.FollowToAimMinimumDistance += 40;
         }
         if(this._BotState.Difficulty == BotState.MEDIUM && Math.random() < 0.5)
         {
            this._BotState.FollowToAimMinimumDistance += 20;
         }
         this._BotState.MeleeToAimMinimumChance = 0.2 + Math.random() * 0.7;
         if(Math.random() < 0.4)
         {
            this._BotState.IgnoreDodgeBulletWhileAiming = true;
         }
         else
         {
            this._BotState.IgnoreDodgeBulletWhileAiming = false;
         }
      }
      
      private function BotDodgeRocket() : Boolean
      {
         if(this._BotState.Difficulty == BotState.EASY)
         {
            return false;
         }
         if(this._BotState.Difficulty == BotState.MEDIUM)
         {
            if(Math.random() < 0.5)
            {
               return false;
            }
         }
         if(!this._PlayerState.OnGround)
         {
            return false;
         }
         if(this._PlayerState.Aiming)
         {
            if(this._Handler_ProjectilesUpdater.RocketImpactFrameTime(this,0.1,16))
            {
               return true;
            }
         }
         else if(this._Handler_ProjectilesUpdater.RocketImpactFrameTime(this,0.1,16))
         {
            return true;
         }
         return false;
      }
      
      private function BotDodgeBullet() : Boolean
      {
         var _loc1_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         if(this._BotState.Difficulty == BotState.EASY)
         {
            return false;
         }
         if(this._BotState.DodgeBullet)
         {
            return true;
         }
         if(this._BotState.Difficulty == BotState.MEDIUM)
         {
            if(Math.random() < 0.7)
            {
               return false;
            }
         }
         if(!this._PlayerState.OnGround || Boolean(this._PlayerState.Punching))
         {
            return false;
         }
         if(!this._PlayerState.CanRoll && Boolean(this._PlayerState.Aiming))
         {
            return false;
         }
         if(!this._PlayerState.CanRoll && !this._PlayerState.Aiming && Math.random() < 0.7)
         {
            return false;
         }
         if(this._PlayerState.Aiming)
         {
            if(this._BotState.IgnoreDodgeBulletWhileAiming)
            {
               return false;
            }
            if(this._Handler_ProjectilesUpdater.BulletImpactFrameTime(this,3.1,8))
            {
               return true;
            }
         }
         else
         {
            if(this._Handler_ProjectilesUpdater.BulletImpactFrameTime(this,0,8))
            {
               return true;
            }
            if(this._BotState.TargetPlayer != null)
            {
               if(this._BotState.TargetPlayer.State.Aiming)
               {
                  _loc1_ = this._BotState.TargetPlayer.MidPosX() - this.MidPosX();
                  _loc2_ = this._BotState.TargetPlayer.MidPosY() - this.MidPosY();
                  _loc3_ = Math.sqrt(_loc1_ * _loc1_ + _loc2_ * _loc2_);
                  if(_loc3_ <= 25)
                  {
                     return true;
                  }
               }
            }
         }
         return false;
      }
      
      private function BotCloudAbove() : Boolean
      {
         var _loc1_:int = 0;
         while(_loc1_ < 20)
         {
            if(this._static_world_cloud_hitbox_mc.hitTestPoint(this._this_x,this._this_y - _loc1_,true))
            {
               return true;
            }
            _loc1_ += 2;
         }
         return false;
      }
      
      private function BotCheckCover() : void
      {
         if(this._PlayerState.TakingCover)
         {
            this.SetBotKey(KEY_UP,true);
            this.SetBotKey(KEY_UP,false);
            return;
         }
      }
      
      private function BotCheckObstacle(param1:int, param2:Boolean = false) : void
      {
         if(this.BotObstacleAt(param1))
         {
            if(!this._PlayerState.Jumping)
            {
               this.SetBotKey(KEY_UP,true);
               this.SetBotKey(KEY_UP,false);
            }
            else if(!this._PlayerState.JumpKickPerformed && (Math.abs(this._PlayerState.AirVelocityY) < 2 || param2))
            {
               this.SetBotKey(KEY_MELEE,!this._keyPressed[KEY_MELEE]);
            }
         }
      }
      
      private function BotCheckStandingOnObject() : Boolean
      {
         if(Boolean(this.BotStandingOnObjectAtX(0)) || Boolean(this.BotStandingOnObjectAtX(this._PlayerState.LastDirX * 6)))
         {
            if(this._PlayerState.KickingCooldown <= 0)
            {
               this.SetBotKey(KEY_MELEE,!this._keyPressed[KEY_MELEE]);
            }
            else
            {
               this.SetBotKey(KEY_MELEE,false);
            }
            return true;
         }
         if(this.BotStandingOnObjectAtX(-this._PlayerState.LastDirX * 6))
         {
            if(this._PlayerState.LastDirX == 1)
            {
               this.SetBotKey(KEY_LEFT,false);
               this.SetBotKey(KEY_RIGHT,true);
            }
            else
            {
               this.SetBotKey(KEY_LEFT,true);
               this.SetBotKey(KEY_RIGHT,false);
            }
            return true;
         }
         return false;
      }
      
      private function BotStandingOnObjectAtX(param1:Number) : Boolean
      {
         var _loc2_:Number = 0;
         while(_loc2_ <= 2)
         {
            if(this._static_objects_hitbox_mc.hitTestPoint(this._this_x + param1,this._this_y + _loc2_,true))
            {
               return true;
            }
            _loc2_ += 2;
         }
         return false;
      }
      
      private function BotStateMelee() : void
      {
         var _loc3_:Number = NaN;
         if(this._BotState.TargetPlayer == null)
         {
            this.BotGoForReset(true);
            this._BotState.Phase = BotState.IDLE;
            this.SetBotKey(KEY_RIGHT,false);
            this.SetBotKey(KEY_LEFT,false);
            this.SetBotKey(KEY_MELEE,false);
            return;
         }
         var _loc1_:Number = this._BotState.TargetPlayer.MidPosX() - this.MidPosX();
         this.BotCheckObstacle(_loc1_ / Math.abs(_loc1_),true);
         var _loc2_:Boolean = Boolean(this.BotTargetInMelee());
         if(this._PlayerState.Climbing)
         {
            this.SetBotKey(KEY_UP,false);
            this.SetBotKey(KEY_DOWN,true);
         }
         else
         {
            this.SetBotKey(KEY_DOWN,false);
            if(Math.abs(_loc1_) >= 40 || Math.abs(_loc1_) < this._PlayerState.MeleeWeaponRange && !_loc2_)
            {
               if(Boolean(this._BotState.TargetInSight) && this._PlayerState.CurrentRangeWeapon != null)
               {
                  this._BotState.Phase = BotState.AIM;
               }
               else
               {
                  this._BotState.Phase = BotState.FOLLOW_PATH;
               }
               this.SetBotKey(KEY_RIGHT,false);
               this.SetBotKey(KEY_LEFT,false);
               this.SetBotKey(KEY_MELEE,false);
               return;
            }
         }
         if(this._PlayerState.CurrentRangeWeapon != null)
         {
            if(Math.abs(_loc1_) >= 8)
            {
               if(this._BotState.TargetPlayer.State.Knockdowned)
               {
                  if(Math.random() < this._PlayerState.CurrentRangeWeapon.TotalKnockdown / 100 + this._BotState.MeleeToAimMinimumChance)
                  {
                     if(this._PlayerState.RangeWeaponCanShootDown)
                     {
                        this._BotState.ActionShotFired = false;
                     }
                     else
                     {
                        this._BotState.ActionShotFired = true;
                     }
                     this._BotState.Phase = BotState.AIM;
                  }
               }
            }
         }
         this.SetBotKey(KEY_RIGHT,false);
         this.SetBotKey(KEY_LEFT,false);
         if(this.BotFacingEdgeMelee())
         {
            if(this._PlayerState.LastDirX < 0 && _loc1_ > 0)
            {
               this.SetBotKey(KEY_RIGHT,true);
               this.SetBotKey(KEY_LEFT,false);
            }
            else if(this._PlayerState.LastDirX > 0 && _loc1_ < 0)
            {
               this.SetBotKey(KEY_RIGHT,false);
               this.SetBotKey(KEY_LEFT,true);
            }
         }
         else if(this._PlayerState.OnGround)
         {
            if(_loc1_ > 6 || this._PlayerState.LastDirX < 0 && _loc1_ > 0)
            {
               this.SetBotKey(KEY_RIGHT,true);
               this.SetBotKey(KEY_LEFT,false);
            }
            else if(_loc1_ < -6 || this._PlayerState.LastDirX > 0 && _loc1_ < 0)
            {
               this.SetBotKey(KEY_RIGHT,false);
               this.SetBotKey(KEY_LEFT,true);
            }
         }
         else if(_loc1_ > 0.5)
         {
            this.SetBotKey(KEY_RIGHT,true);
            this.SetBotKey(KEY_LEFT,false);
         }
         else if(_loc1_ < -0.5)
         {
            this.SetBotKey(KEY_RIGHT,false);
            this.SetBotKey(KEY_LEFT,true);
         }
         if(_loc1_ != 0)
         {
            if(this._PlayerState.CanRoll)
            {
               if(this._BotState.TargetPlayer.State.Aiming)
               {
                  this.SetBotKey(KEY_DOWN,true);
               }
               else if(this._PlayerState.Sprinting)
               {
                  if(Math.random() <= 0.08)
                  {
                     if(!this.BotFacingEdge())
                     {
                        this.SetBotKey(KEY_DOWN,true);
                     }
                  }
               }
            }
         }
         if(_loc2_)
         {
            if(!this._keyPressed[KEY_MELEE] && Boolean(this._PlayerState.OnGround) && Math.random() < 0.1 && this._BotState.Difficulty > BotState.EASY)
            {
               this.SetBotKey(KEY_UP,true);
               this.SetBotKey(KEY_UP,false);
            }
            else
            {
               if(this._BotState.Difficulty == BotState.EASY)
               {
                  if(Math.random() < 0.8)
                  {
                     return;
                  }
               }
               if(this._BotState.Difficulty == BotState.MEDIUM)
               {
                  if(Math.random() < 0.6)
                  {
                     return;
                  }
               }
               if(this._BotState.Difficulty == BotState.HARD)
               {
                  if(Math.random() < 0.3)
                  {
                     return;
                  }
               }
               this.SetBotKey(KEY_MELEE,!this._keyPressed[KEY_MELEE]);
            }
         }
         else if(Math.abs(_loc1_) < 4)
         {
            if(Boolean(this._PlayerState.OnGround) && Boolean(this._BotState.TargetPlayer.State.OnGround))
            {
               _loc3_ = this.MidPosY() - this._BotState.TargetPlayer.MidPosY();
               if(Math.abs(_loc3_) > 10)
               {
                  this._BotState.Phase = BotState.FOLLOW_PATH;
               }
            }
         }
      }
      
      private function BotStateGrabWeapon() : void
      {
         var _loc1_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Boolean = false;
         if(this._BotState.TargetWeapon == null)
         {
            this.SetBotKey(KEY_RIGHT,false);
            this.SetBotKey(KEY_LEFT,false);
            this.SetBotKey(KEY_DOWN,false);
            this.SetBotKey(KEY_MELEE,false);
            this.BotGoForReset(true);
            this._BotState.Phase = BotState.IDLE;
            return;
         }
         _loc1_ = this._BotState.TargetWeapon.GetPosition().x * 30 - this.MidPosX();
         _loc2_ = this._BotState.TargetWeapon.GetPosition().y * 30 - this.MidPosY();
         _loc3_ = Math.sqrt(_loc1_ * _loc1_ + _loc2_ * _loc2_);
         _loc4_ = 2;
         if(this._PlayerState.OnGround)
         {
            _loc4_ = this._BotState.TargetWeapon.GetUserData().weaponData.Properties.PickupRadius * 0.5;
         }
         this.SetBotKey(KEY_UP,false);
         _loc5_ = false;
         if(_loc1_ > _loc4_)
         {
            this.SetBotKey(KEY_RIGHT,true);
            this.SetBotKey(KEY_LEFT,false);
            this.BotCheckObstacle(_loc1_ / Math.abs(_loc1_));
         }
         else if(_loc1_ < -_loc4_)
         {
            this.SetBotKey(KEY_RIGHT,false);
            this.SetBotKey(KEY_LEFT,true);
            this.BotCheckObstacle(_loc1_ / Math.abs(_loc1_));
         }
         else
         {
            _loc5_ = true;
            this.SetBotKey(KEY_RIGHT,false);
            this.SetBotKey(KEY_LEFT,false);
            if(this._PlayerState.OnGround)
            {
               if(this.BotCheckStandingOnObject())
               {
                  return;
               }
            }
         }
         if(this._PlayerState.Climbing)
         {
            this.SetBotKey(KEY_UP,false);
            this.SetBotKey(KEY_DOWN,true);
            return;
         }
         if(this._PlayerState.OnGround)
         {
            if(_loc3_ <= this._BotState.TargetWeapon.GetUserData().weaponData.Properties.PickupRadius * 0.7)
            {
               this.SetBotKey(KEY_RIGHT,false);
               this.SetBotKey(KEY_LEFT,false);
               if(!this._PlayerState.Kneeling)
               {
                  this.DisableJumpDownLevel();
                  this.SetBotKey(KEY_DOWN,true);
                  return;
               }
               this.SetBotKey(KEY_MELEE,true);
               this.BotGoForReset();
            }
            else if(_loc5_)
            {
               this.SetBotKey(KEY_RIGHT,false);
               this.SetBotKey(KEY_LEFT,false);
               this.SetBotKey(KEY_DOWN,false);
               this.SetBotKey(KEY_MELEE,false);
               this.BotGoForReset(true);
               this._BotState.Phase = BotState.IDLE;
               return;
            }
         }
      }
      
      private function BotAutoPickupItem(param1:b2Body) : Boolean
      {
         if(param1.GetUserData().isRanged == true && this._PlayerState.CurrentRangeWeapon == null)
         {
            return true;
         }
         if(param1.GetUserData().isThrowable == true && this._PlayerState.CurrentThrowableWeapon == null)
         {
            return true;
         }
         if(param1.GetUserData().isMelee == true && this._PlayerState.CurrentMeleeWeapon == null)
         {
            return true;
         }
         if(param1.GetUserData().isPowerup == true && this._PlayerState.CurrentPowerupWeapon == null)
         {
            return true;
         }
         if(param1.GetUserData().isHealth == true && this._PlayerState.HP < 100)
         {
            return true;
         }
         return false;
      }
      
      private function BotStateFollowPath() : void
      {
         var _loc1_:Boolean = false;
         var _loc2_:PathResultNode = null;
         var _loc3_:int = 0;
         var _loc4_:Boolean = false;
         var _loc5_:PathNode = null;
         var _loc6_:* = undefined;
         var _loc7_:Number = NaN;
         var _loc8_:PathNode = null;
         if(this._PlayerState.BurnState <= 0)
         {
            this.SetBotKey(KEY_LEFT,false);
            this.SetBotKey(KEY_RIGHT,false);
            this.SetBotKey(KEY_UP,false);
            this.SetBotKey(KEY_DOWN,false);
         }
         if(this._PlayerState.Aiming)
         {
            this._BotState.Phase = BotState.AIM;
            return;
         }
         if(this._BotState.TargetPlayer == null && this._BotState.TargetWeapon == null && !this._BotState.RunAwayFromHazards)
         {
            this._BotState.Phase = BotState.IDLE;
            this.BotGoForReset();
            return;
         }
         if(this._BotState.Path.length <= 0)
         {
            this._BotState.RunAwayFromHazards = false;
            this._BotState.NextResultNode = null;
            _loc1_ = false;
            if(!BotState.FOLLOW_ONLY)
            {
               if(this._BotState.TargetWeapon != null)
               {
                  this.BotCalculatePathGrid(this._pathGrid.GetNodeAt(this._BotState.TargetWeapon.GetPosition().x * 30,this._BotState.TargetWeapon.GetPosition().y * 30));
                  if(this._BotState.Path.length <= 1)
                  {
                     this._BotState.Phase = BotState.GRAB_WEAPON;
                     this.SetBotKey(KEY_UP,false);
                  }
                  else
                  {
                     _loc1_ = true;
                  }
                  return;
               }
               if(this._BotState.TargetPlayer != null)
               {
                  this.BotCalculatePathGrid(this._pathGrid.GetNodeAt(this._BotState.TargetPlayer.MidPosX(),this._BotState.TargetPlayer.MidPosY()));
                  if(this._BotState.Path.length <= 1)
                  {
                     this._BotState.Phase = BotState.MELEE;
                  }
                  else
                  {
                     _loc1_ = true;
                  }
                  return;
               }
            }
            if(!_loc1_)
            {
               this.BotGoForReset(true);
               return;
            }
         }
         if(this._BotState.Path.length > 0)
         {
            this.BotCheckPathProgress();
            if(this._BotState.Path.length <= 0)
            {
               return;
            }
            this._BotState.NextResultNode = this._BotState.Path[this._BotState.Path.length - 1];
            if(!this._PlayerState.Climbing && !this._BotState.RunAwayFromHazards && !BotState.FOLLOW_ONLY)
            {
               if(this.BotTargetInMelee())
               {
                  if(!this.BotFacingEdgeMelee())
                  {
                     this._BotState.Phase = BotState.MELEE;
                  }
                  else if(this._PlayerState.Jumping)
                  {
                     this.SetBotKey(KEY_MELEE,true);
                     this.SetBotKey(KEY_MELEE,false);
                  }
               }
               else if(Boolean(this._PlayerState.OnGround) && Boolean(this._BotState.TargetInSight) && this._PlayerState.CurrentRangeWeapon != null)
               {
                  if(Math.sqrt(Math.pow(this._BotState.TargetPlayer.MidPosX() - this.MidPosX(),2) + Math.pow(this._BotState.TargetPlayer.MidPosY() - this.MidPosY(),2)) >= this._BotState.FollowToAimMinimumDistance)
                  {
                     this._BotState.Phase = BotState.AIM;
                     return;
                  }
               }
            }
            _loc2_ = this._BotState.NextResultNode;
            if(Boolean(this._BotState.DoFireCheck) && !this._BotState.RunAwayFromHazards)
            {
               if(this._PlayerState.BurnState <= 0)
               {
                  if(this._Handler_Fires.PlayerPosInFire(_loc2_.Node.PosX,_loc2_.Node.PosY + 4))
                  {
                     return;
                  }
               }
               this._BotState.DoFireCheck = false;
            }
            if(this._PlayerState.MovingDirectionInversed != 0)
            {
               this._BotState.Path.splice(this._BotState.Path.length - 1,1);
               this._PlayerState.MovingDirectionInversed = 0;
               return;
            }
            _loc3_ = 0;
            if(this.PosX() > _loc2_.Node.PosX + BotState.DISTANCE_WALK_TOLERANCE)
            {
               _loc3_ = -1;
            }
            else if(this.PosX() < _loc2_.Node.PosX - BotState.DISTANCE_WALK_TOLERANCE)
            {
               _loc3_ = 1;
            }
            this.BotCheckCover();
            _loc4_ = true;
            if(_loc2_.PrevBind != null)
            {
               if(!_loc2_.PrevBind.TargetNodeCloseEnough())
               {
                  _loc3_ = 0;
                  if(this.PosX() > _loc2_.PrevBind.SourceNode.PosX + BotState.DISTANCE_WALK_TOLERANCE)
                  {
                     _loc3_ = -1;
                  }
                  else if(this.PosX() < _loc2_.PrevBind.SourceNode.PosX - BotState.DISTANCE_WALK_TOLERANCE)
                  {
                     _loc3_ = 1;
                  }
                  if(_loc3_ == 0)
                  {
                     this.SetBotKey(KEY_LEFT,false);
                     this.SetBotKey(KEY_RIGHT,false);
                  }
                  else if(_loc3_ == 1)
                  {
                     this.SetBotKey(KEY_LEFT,false);
                     this.SetBotKey(KEY_RIGHT,true);
                  }
                  else
                  {
                     this.SetBotKey(KEY_LEFT,true);
                     this.SetBotKey(KEY_RIGHT,false);
                  }
                  this.SetBotKey(KEY_UP,false);
                  this.SetBotKey(KEY_DOWN,false);
                  return;
               }
               switch(_loc2_.PrevBind.MovementType)
               {
                  case PathBind.ROAD:
                     break;
                  case PathBind.JUMP:
                     if(_loc2_.Node.PosY < this.MidPosY())
                     {
                        this.BotGoForReset();
                     }
                     if(!this._PlayerState.Jumping)
                     {
                        this.SetBotKey(KEY_UP,true);
                        this.SetBotKey(KEY_UP,false);
                     }
                     else
                     {
                        this.SetBotKey(KEY_UP,false);
                     }
                     this.BotWalkAroundJumpObstalce();
                     break;
                  case PathBind.CLOUDDOWN:
                     _loc4_ = false;
                     if(!this._keyPressed[KEY_DOWN])
                     {
                        if(!this._PlayerState.Jumping)
                        {
                           if(this.BotCheckStandingOnObject())
                           {
                              return;
                           }
                           this.SetBotKey(KEY_DOWN,true);
                           this.SetBotKey(KEY_DOWN,false);
                           this.SetBotKey(KEY_DOWN,true);
                           this.SetBotKey(KEY_DOWN,false);
                           return;
                        }
                        this.SetBotKey(KEY_DOWN,false);
                     }
                     break;
                  case PathBind.DIVE:
                     if(!this._PlayerState.Running)
                     {
                        if(_loc3_ == -1)
                        {
                           this.SetBotKey(KEY_LEFT,false);
                           this.SetBotKey(KEY_RIGHT,true);
                        }
                        else
                        {
                           this.SetBotKey(KEY_LEFT,true);
                           this.SetBotKey(KEY_RIGHT,false);
                        }
                     }
                     else if(!this._PlayerState.Sprinting)
                     {
                        --this._BotState.ActivateSprintCounter;
                        if(this._BotState.ActivateSprintCounter <= 0)
                        {
                           this._BotState.ActivateSprintCounter = 2;
                           this.SetBotKey(KEY_RIGHT,false);
                           this.SetBotKey(KEY_LEFT,false);
                           return;
                        }
                     }
                     else if(!this._PlayerState.Diving && !this._PlayerState.ShortDiveAvailable)
                     {
                        this.SetBotKey(KEY_DOWN,true);
                     }
                     else if(this._PlayerState.Diving)
                     {
                        this.SetBotKey(KEY_DOWN,false);
                     }
                     break;
                  case PathBind.SPRINTJUMP:
                     if(!this._PlayerState.Sprinting)
                     {
                        --this._BotState.ActivateSprintCounter;
                        if(this._BotState.ActivateSprintCounter <= 0)
                        {
                           this._BotState.ActivateSprintCounter = 2;
                           this.SetBotKey(KEY_RIGHT,false);
                           this.SetBotKey(KEY_LEFT,false);
                           return;
                        }
                     }
                     else if(!this._PlayerState.Jumping)
                     {
                        this.SetBotKey(KEY_UP,true);
                        this.SetBotKey(KEY_UP,false);
                     }
                     else if(this.BotObstacleAt(_loc3_))
                     {
                        this.SetBotKey(KEY_MELEE,true);
                        this.SetBotKey(KEY_MELEE,false);
                     }
                     break;
                  case PathBind.ROLL:
                     this.SetBotKey(KEY_DOWN,true);
                     break;
                  case PathBind.LADDER:
                     if(_loc2_.Node.PosY < _loc2_.PrevBind.SourceNode.PosY && !_loc2_.PrevBind.Blocked)
                     {
                        if(Boolean(this._PlayerState.Climbing) && !this._static_ladder_hitbox_mc.hitTestPoint(this.MidPosX(),this.MidPosY() - 1,true))
                        {
                           this.SetBotKey(KEY_UP,false);
                           this.SetBotKey(KEY_UP,true);
                        }
                        if(this._BotState.TargetPlayer != null)
                        {
                           if(this._BotState.TargetPlayer.MidPosY() < this.MidPosY())
                           {
                              _loc6_ = false;
                              _loc7_ = Math.abs(this.MidPosX() - this._BotState.TargetPlayer.MidPosX());
                              if(_loc7_ < 35)
                              {
                                 if(!this._PlayerState.Climbing)
                                 {
                                    this.BotGoForReset(true);
                                    this.SetBotKey(KEY_UP,false);
                                    this.SetBotKey(KEY_DOWN,false);
                                    return;
                                 }
                                 this.SetBotKey(KEY_UP,false);
                                 this.SetBotKey(KEY_DOWN,true);
                              }
                           }
                        }
                        this.SetBotKey(KEY_UP,true);
                        _loc5_ = _loc2_.PrevBind.SourceNode;
                        if(_loc2_.Node.PosY - this.MidPosY() >= BotState.DISTANCE_LADDER_TOLERANCE_Y)
                        {
                           _loc5_ = _loc2_.Node;
                        }
                        if(this.PosX() > _loc5_.PosX + BotState.DISTANCE_LADDER_TOLERANCE_X)
                        {
                           this.SetBotKey(KEY_LEFT,true);
                           this.SetBotKey(KEY_RIGHT,false);
                        }
                        else if(this.PosX() < _loc5_.PosX - BotState.DISTANCE_LADDER_TOLERANCE_X)
                        {
                           this.SetBotKey(KEY_LEFT,false);
                           this.SetBotKey(KEY_RIGHT,true);
                        }
                        else
                        {
                           this.SetBotKey(KEY_LEFT,false);
                           this.SetBotKey(KEY_RIGHT,false);
                        }
                        return;
                     }
                     _loc8_ = _loc2_.Node;
                     this.SetBotKey(KEY_DOWN,true);
                     if(this.PosX() > _loc8_.PosX + BotState.DISTANCE_LADDER_TOLERANCE_X)
                     {
                        this.SetBotKey(KEY_LEFT,true);
                        this.SetBotKey(KEY_RIGHT,false);
                     }
                     else if(this.PosX() < _loc8_.PosX - BotState.DISTANCE_LADDER_TOLERANCE_X)
                     {
                        this.SetBotKey(KEY_LEFT,false);
                        this.SetBotKey(KEY_RIGHT,true);
                     }
                     else
                     {
                        this.SetBotKey(KEY_LEFT,false);
                        this.SetBotKey(KEY_RIGHT,false);
                     }
                     if(Boolean(this._PlayerState.OnGround) && Boolean(this._static_ladder_hitbox_mc.hitTestPoint(this.MidPosX(),this.MidPosY() - 1,true)))
                     {
                        this.BotGoForReset();
                     }
                     return;
               }
            }
            else
            {
               this.BotGoForReset();
            }
            if(this._PlayerState.AirVelocityY >= 0 && !this._PlayerState.OnGround && Boolean(this._static_ladder_hitbox_mc.hitTestPoint(this.MidPosX(),this.MidPosY() - 1,true)))
            {
               this.SetBotKey(KEY_DOWN,true);
               this.SetBotKey(KEY_UP,false);
               return;
            }
            if(_loc4_)
            {
               if(Boolean(this.BotCloudAbove()) && Boolean(this._PlayerState.OnGround) && Math.random() < 0.5)
               {
                  if(this.BotObstacleAt(_loc3_))
                  {
                     if(Boolean(this._BotState.PreferJumpOverObstacle) && !this._PlayerState.Jumping)
                     {
                        this.SetBotKey(KEY_UP,true);
                        this.SetBotKey(KEY_UP,false);
                     }
                     else
                     {
                        this.SetBotKey(KEY_MELEE,true);
                        this.SetBotKey(KEY_MELEE,false);
                     }
                  }
               }
               else
               {
                  this.BotCheckObstacle(_loc3_);
               }
            }
            if(this._PlayerState.Climbing)
            {
               this.SetBotKey(KEY_DOWN,true);
               this.SetBotKey(KEY_UP,false);
               return;
            }
            if(_loc3_ == -1)
            {
               this.SetBotKey(KEY_LEFT,true);
               this.SetBotKey(KEY_RIGHT,false);
            }
            else if(_loc3_ == 1)
            {
               this.SetBotKey(KEY_LEFT,false);
               this.SetBotKey(KEY_RIGHT,true);
            }
            else if(this.MidPosY() - _loc2_.Node.PosY >= 22)
            {
               this._BotState.NextResultNode = null;
               this.BotChooseTarget();
            }
            else if(Boolean(this._PlayerState.OnGround) || Boolean(this._PlayerState.Climbing))
            {
               if(this.MidPosY() - _loc2_.Node.PosY >= 0)
               {
                  if(!this._PlayerState.Jumping)
                  {
                     this.SetBotKey(KEY_UP,false);
                     this.SetBotKey(KEY_UP,true);
                  }
               }
               else
               {
                  this.BotCheckStandingOnObject();
               }
               this.BotGoForReset();
            }
         }
      }
      
      private function BotStateCancelAim() : void
      {
         var _loc1_:int = 0;
         if(this._PlayerState.Aiming)
         {
            this.SetBotKey(KEY_UP,false);
            this.SetBotKey(KEY_DOWN,false);
            this.SetBotKey(KEY_LEFT,false);
            this.SetBotKey(KEY_RIGHT,false);
            this.SetBotKey(KEY_MELEE,!this._keyPressed[KEY_MELEE]);
         }
         else
         {
            this.SetBotKey(KEY_MELEE,false);
            this.SetBotKey(KEY_FIRE,false);
            this._BotState.CancelAimSoon = false;
            if(this._BotState.RunAwayFromHazards)
            {
               this._BotState.Phase = BotState.FOLLOW_PATH;
            }
            else if(this.BotTargetInMelee())
            {
               this._BotState.Phase = BotState.MELEE;
            }
            else
            {
               this._BotState.Phase = BotState.IDLE;
            }
         }
      }
      
      private function BotStateAim() : void
      {
         var _loc1_:Number = NaN;
         if(Boolean(this._PlayerState.Jumping) || this._PlayerState.CurrentRangeWeapon == null)
         {
            this._BotState.Phase = BotState.CANCEL_AIM;
            return;
         }
         if(this._PlayerState.CurrentRangeWeapon.Ammo <= 0)
         {
            this._BotState.Phase = BotState.CANCEL_AIM;
            return;
         }
         if(this._BotState.TargetHazardousObject == null)
         {
            if(this._BotState.ActionShotFired)
            {
               if(!this._BotState.TargetInSight)
               {
                  this._BotState.Phase = BotState.CANCEL_AIM;
                  return;
               }
               if(Boolean(this.BotTargetInMelee()) && !this._BotState.TargetPlayer.State.Knockdowned)
               {
                  this._BotState.Phase = BotState.CANCEL_AIM;
                  return;
               }
            }
            else if(this._BotState.TargetPlayer == null)
            {
               this._BotState.Phase = BotState.CANCEL_AIM;
               return;
            }
         }
         this.SetBotKey(2,false);
         this.SetBotKey(3,false);
         if(this._BotState.TargetHazardousObject != null)
         {
            _loc1_ = this._BotState.TargetHazardousObject.GetPosition().x * 30 - this.MidPosX();
         }
         else
         {
            _loc1_ = this._BotState.TargetPlayer.MidPosX() - this.MidPosX();
         }
         if(Math.abs(_loc1_) > 5)
         {
            if(this._PlayerState.LastDirX * _loc1_ <= 0)
            {
               if(this._PlayerState.LastDirX > 0)
               {
                  this.SetBotKey(2,true);
               }
               else
               {
                  this.SetBotKey(3,true);
               }
               return;
            }
         }
         if(!this._PlayerState.Aiming)
         {
            this.SetBotKey(KEY_FIRE,!this._keyPressed[KEY_FIRE]);
         }
         this.BotAimY();
         if(this._BotState.TargetInAim)
         {
            if(this._PlayerState.CurrentWeaponCooldown <= 0 && !this._PlayerState.AimTurningAround)
            {
               if(this._BotState.TargetHazardousObject == null)
               {
                  if(Boolean(this._BotState.TargetPlayer.State.IsImmune) && this._BotState.Difficulty == BotState.HARD)
                  {
                     if(Math.random() < 0.9)
                     {
                        return;
                     }
                  }
                  if(Boolean(this._BotState.TargetPlayer.State.StuckToRocket) && this._PlayerState.CurrentRangeWeapon.Properties.WeaponType == "BAZOOKA")
                  {
                     if(this._BotState.TargetPlayer.State.RocketRideProjectile.DirectionX < 0 && this.MidPosX() > this._BotState.TargetPlayer.MidPosX() || this._BotState.TargetPlayer.State.RocketRideProjectile.DirectionX > 0 && this.MidPosX() < this._BotState.TargetPlayer.MidPosX())
                     {
                        return;
                     }
                  }
               }
               if(this._BotState.Difficulty == BotState.EASY)
               {
                  if(Math.random() < 0.85)
                  {
                     return;
                  }
               }
               if(this._BotState.Difficulty == BotState.MEDIUM)
               {
                  if(Math.random() < 0.75)
                  {
                     return;
                  }
               }
               if(this._BotState.Difficulty == BotState.HARD)
               {
                  if(Math.random() < 0.5)
                  {
                     return;
                  }
               }
               this._BotState.SetDelay();
               this._BotState.Phase = BotState.SHOOT;
               this.SetBotKey(5,false);
               this._BotState.RandomFirePosition = true;
               this._BotState.ActionShotFired = true;
            }
         }
      }
      
      private function BotStateShoot() : void
      {
         if(this._PlayerState.AFSInProgress)
         {
            if(this._char.ANIM_WPN == null)
            {
               this._BotState.Phase = BotState.CANCEL_AIM;
            }
            else
            {
               this.SetBotKey(5,true);
               this.BotAimY();
            }
         }
         else if(this._PlayerState.CurrentRangeWeapon != null)
         {
            if(this._PlayerState.CurrentRangeWeapon.Ammo <= 0)
            {
               this._BotState.Phase = BotState.CANCEL_AIM;
            }
            else if(this._BotState.CancelAimSoon)
            {
               this._BotState.Phase = BotState.CANCEL_AIM;
            }
            else
            {
               this.SetBotKey(KEY_UP,false);
               this.SetBotKey(KEY_DOWN,false);
               this._BotState.Phase = BotState.AIM;
            }
         }
         else
         {
            this._BotState.Phase = BotState.CANCEL_AIM;
         }
      }
      
      private function BotChooseTarget_Tick() : void
      {
         this.BotChooseTarget();
      }
      
      private function BotInSightCheck_Tick() : void
      {
         if(this._BotState.TargetPlayer != null)
         {
            this._BotState.TargetInSight = this.BotPositionInSight(this._BotState.TargetPlayer.MidPosX() + Math.random() * 6 - 3,this._BotState.TargetPlayer.MidPosY() + Math.random() * 4 - 2,this._BotState.TargetPlayer.PlayerNr);
         }
      }
      
      private function BotGoForReset(param1:Boolean = false) : void
      {
         this._BotState.ResetTimer += 1;
         if(this._BotState.ResetTimer >= 4 || param1)
         {
            this._BotState.NextResultNode = null;
            this._BotState.TargetPlayer = null;
            this._BotState.TargetWeapon = null;
            this._BotState.ResetTimer = 0;
            this._BotState.RunAwayFromHazards = false;
         }
      }
      
      private function BotTargetInMelee() : Boolean
      {
         if(this._BotState.TargetPlayer == null)
         {
            return false;
         }
         if(this._PlayerState.Jumping)
         {
            return this.CanKickPlayer(this._BotState.TargetPlayer,this._PlayerState.Jumping);
         }
         if(this.CanKickPlayer(this._BotState.TargetPlayer,false))
         {
            return true;
         }
         return this.InMeleeRange(this._BotState.TargetPlayer);
      }
      
      private function BotObstacleAt(param1:int) : Boolean
      {
         var _loc2_:b2Body = null;
         var _loc4_:Number = NaN;
         var _loc3_:Number = 0;
         loop0:
         while(_loc3_ <= 4)
         {
            _loc4_ = -12;
            while(true)
            {
               if(_loc4_ > 6)
               {
                  _loc3_ += 4;
                  continue loop0;
               }
               _loc2_ = this.GetDynamicBodyAt(this._this_x + param1 * this._PlayerState.PlayerEdgeDistance + param1 * _loc3_,this.MidPosY() + _loc4_,false);
               if(_loc2_ != null)
               {
                  break;
               }
               _loc4_ += 6;
            }
            this._BotState.PreferJumpOverObstacle = _loc2_.GetUserData().objectData.BotPreferJump;
            return true;
         }
         return false;
      }
      
      private function BotCanJump(param1:Number = 0) : Boolean
      {
         var _loc2_:b2Body = null;
         var _loc4_:Number = NaN;
         var _loc3_:Number = -this._PlayerState.PlayerEdgeDistance;
         loop0:
         while(_loc3_ <= this._PlayerState.PlayerEdgeDistance)
         {
            _loc4_ = 0;
            while(true)
            {
               if(_loc4_ > 20)
               {
                  _loc3_ += this._PlayerState.PlayerEdgeDistance * 2;
                  continue loop0;
               }
               _loc2_ = this.GetDynamicBodyAt(this._this_x + _loc3_ + param1,this._this_y - 16 - _loc4_,false);
               if(_loc2_ != null)
               {
                  break;
               }
               _loc4_ += 4;
            }
            return false;
         }
         return true;
      }
      
      private function BotWalkAroundJumpObstalce() : void
      {
         var _loc1_:int = 1;
         var _loc2_:int = int(this._PlayerState.PlayerEdgeDistance);
         while(_loc2_ <= this._PlayerState.PlayerEdgeDistance * 5)
         {
            if(this.BotCanJump(_loc2_))
            {
               _loc1_ = 1;
               _loc2_ = 100;
            }
            else if(this.BotCanJump(-_loc2_))
            {
               _loc1_ = -1;
               _loc2_ = 100;
            }
            _loc2_ += this._PlayerState.PlayerEdgeDistance;
         }
         if(_loc1_ == 1)
         {
            this.SetBotKey(KEY_RIGHT,true);
            this.SetBotKey(KEY_LEFT,false);
         }
         else
         {
            this.SetBotKey(KEY_RIGHT,false);
            this.SetBotKey(KEY_LEFT,true);
         }
         if(this.BotObstacleAt(_loc1_))
         {
            if(Boolean(this._BotState.PreferJumpOverObstacle) && !this._PlayerState.Jumping)
            {
               this.SetBotKey(KEY_UP,true);
               this.SetBotKey(KEY_UP,false);
            }
            else
            {
               this.SetBotKey(KEY_MELEE,!this._keyPressed[KEY_MELEE]);
            }
         }
      }
      
      private function BotCheckPathProgress() : void
      {
         var _loc4_:Number = NaN;
         var _loc1_:PathResultNode = this._BotState.Path[this._BotState.Path.length - 1];
         var _loc2_:Number = this.MidPosX() - _loc1_.Node.PosX;
         var _loc3_:Number = this.MidPosY() - _loc1_.Node.PosY;
         if(Math.abs(_loc2_) <= BotState.DISTANCE_NODE_TOLERANCE_X)
         {
            if(_loc3_ >= BotState.DISTANCE_NODE_TOLERANCE_Y_MAX && _loc3_ <= BotState.DISTANCE_NODE_TOLERANCE_Y_MIN)
            {
               if(_loc1_.NextBind != null)
               {
                  if(!this._PlayerState.OnGround)
                  {
                     if(_loc1_.NextBind.MovementType == PathBind.DIVE)
                     {
                        return;
                     }
                     if(_loc1_.NextBind.MovementType == PathBind.SPRINTJUMP || _loc1_.NextBind.MovementType == PathBind.JUMP)
                     {
                        if(this._PlayerState.AirVelocityY > this._PlayerState.PlayerJumpPower + 2)
                        {
                           return;
                        }
                     }
                  }
               }
               this._BotState.Path.splice(this._BotState.Path.length - 1,1);
               this._BotState.DoFireCheck = true;
               return;
            }
            if(_loc3_ < 0)
            {
               if(_loc1_.NextBind != null)
               {
                  if(_loc1_.NextBind.MovementType == PathBind.ROAD)
                  {
                     _loc4_ = Math.abs(_loc3_);
                     while(_loc4_ >= 2)
                     {
                        if(this._static_objects_hitbox_mc.hitTestPoint(this._this_x,this.MidPosY() + _loc4_,true))
                        {
                           this._BotState.Path.splice(this._BotState.Path.length - 1,1);
                           this._BotState.DoFireCheck = true;
                           return;
                        }
                        _loc4_ -= 2;
                     }
                  }
               }
            }
         }
      }
      
      private function BotChooseTarget(param1:Boolean = true) : void
      {
         var _loc5_:int = 0;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:b2Body = null;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc14_:b2Body = null;
         var _loc15_:int = 0;
         var _loc16_:PathNode = null;
         var _loc17_:Number = NaN;
         var _loc18_:PathNode = null;
         var _loc19_:Number = NaN;
         var _loc20_:Number = NaN;
         var _loc21_:PathNode = null;
         var _loc22_:PathNode = null;
         var _loc23_:Array = null;
         var _loc2_:int = -1;
         var _loc3_:Number = 99999;
         var _loc4_:Player = this._BotState.TargetPlayer;
         this._BotState.DoFireCheck = true;
         var _loc9_:Boolean = false;
         if(param1)
         {
            this._BotState.UpdateUnavailableStuff();
         }
         _loc5_ = 0;
         while(_loc5_ < this._players.length)
         {
            if(this.PlayerNr != _loc5_)
            {
               if(this._players[_loc5_].State.HP > 0 && this._players[_loc5_].Team != this._team)
               {
                  _loc9_ = true;
                  if(!this._BotState.IsPlayerUnavailable(this._players[_loc5_]))
                  {
                     _loc6_ = this._players[_loc5_].MidPosX() - this.MidPosX();
                     _loc7_ = this._players[_loc5_].MidPosY() - this.MidPosY();
                     _loc8_ = Math.sqrt(_loc6_ * _loc6_ + _loc7_ * _loc7_);
                     _loc8_ = _loc8_ * (1 - 0.33 * this.BotTargetThreat_Aim(this._players[_loc5_]));
                     _loc8_ = _loc8_ * (1 - 0.25 * this.BotTargetThreat_Weapon(this._players[_loc5_]));
                     _loc8_ = _loc8_ * (1 - 0.4 * this.BotTargetThreat_Weakness(this._players[_loc5_]));
                     _loc10_ = _loc8_ * 0.33;
                     if(_loc8_ < 50 && Math.abs(_loc7_) < 20)
                     {
                        _loc8_ = _loc10_;
                     }
                     else if(_loc10_ < _loc3_)
                     {
                        if(this._PlayerState.RangeWeaponRange < _loc10_)
                        {
                           if(this.BotPositionInSight(this._players[_loc5_].MidPosX() + Math.random() * 6 - 3,this._players[_loc5_].MidPosY() + Math.random() * 4 - 2,this._players[_loc5_].PlayerNr))
                           {
                              _loc8_ = _loc10_;
                           }
                        }
                     }
                     if(_loc8_ < _loc3_)
                     {
                        _loc2_ = _loc5_;
                        _loc3_ = _loc8_;
                     }
                  }
               }
            }
            _loc5_++;
         }
         this._BotState.OpponentExist = _loc9_;
         if(!this._BotState.OpponentExist)
         {
            this.BotCalculatePathGrid(this._pathGrid.GetNodeAt(this.MidPosX(),this.MidPosY()));
            return;
         }
         if(this._BotState.Difficulty > BotState.EASY && Boolean(this._PlayerState.OnGround) && _loc2_ != -1 && this._PlayerState.CurrentRangeWeapon != null && !BotState.FOLLOW_ONLY)
         {
            _loc5_ = 0;
            while(_loc5_ < this.m_world.HazardsList.length)
            {
               _loc11_ = this.m_world.HazardsList[_loc5_];
               if(_loc11_.GetUserData().objectData.IsBulletHazard)
               {
                  _loc12_ = _loc11_.GetPosition().x * 30;
                  _loc13_ = _loc11_.GetPosition().y * 30;
                  _loc6_ = _loc12_ - this._players[_loc2_].MidPosX();
                  _loc7_ = _loc13_ - this._players[_loc2_].MidPosY();
                  _loc8_ = Math.sqrt(_loc6_ * _loc6_ + _loc7_ * _loc7_);
                  if(_loc8_ <= HAZARDOUS_DISTANCE)
                  {
                     _loc6_ = _loc12_ - this.MidPosX();
                     _loc7_ = _loc13_ - this.MidPosY();
                     _loc8_ = Math.sqrt(_loc6_ * _loc6_ + _loc7_ * _loc7_);
                     if(_loc8_ > HAZARDOUS_DISTANCE_AVOID)
                     {
                        if(this.BotPositionInSight(_loc12_,_loc13_,9999,_loc11_))
                        {
                           this._BotState.TargetHazardousObject = _loc11_;
                           this._BotState.TargetPlayer = this._players[_loc2_];
                           this._BotState.Phase = BotState.AIM;
                           return;
                        }
                     }
                  }
               }
               _loc5_++;
            }
         }
         this._BotState.TargetHazardousObject = null;
         if(!BotState.FOLLOW_ONLY)
         {
            if(this._PlayerState.CurrentRangeWeapon == null || !this._BotState.TargetInSight)
            {
               _loc14_ = this._BotState.TargetWeapon;
               _loc15_ = -1;
               _loc5_ = 0;
               while(_loc5_ < this.m_world.WeaponList.length)
               {
                  this.b = this.m_world.WeaponList[_loc5_];
                  _loc16_ = this._pathGrid.GetNodeAt(this.b.GetPosition().x * 30,this.b.GetPosition().y * 30);
                  if(_loc16_ != null)
                  {
                     if(!_loc16_.Avoid)
                     {
                        if(this.b.GetUserData().weaponData.Ammo > 0)
                        {
                           if(!this._BotState.IsWeaponUnavailable(this.b))
                           {
                              _loc6_ = this.MidPosX() - this.b.GetPosition().x * 30;
                              _loc7_ = this.MidPosY() + 4 - this.b.GetPosition().y * 30;
                              _loc8_ = Math.sqrt(_loc6_ * _loc6_ + _loc7_ * _loc7_);
                              if(this.b.GetUserData().isRanged == true && this.b.GetUserData().weaponData.TotalDamage > this._PlayerState.RangeWeaponTotalDamage * 1.2)
                              {
                                 _loc8_ -= 0.25 * (this.b.GetUserData().weaponData.TotalDamage - this._PlayerState.RangeWeaponTotalDamage);
                              }
                              else if(this.b.GetUserData().isMelee == true && this.b.GetUserData().weaponData.TotalDamage > this._PlayerState.MeleeWeaponTotalDamage)
                              {
                                 _loc8_ -= 0.25 * (this.b.GetUserData().weaponData.TotalDamage - this._PlayerState.MeleeWeaponTotalDamage);
                              }
                              else if(this.b.GetUserData().isHealth == true && this._PlayerState.HP < 100 && this._BotState.Difficulty > BotState.EASY)
                              {
                                 _loc17_ = 100 - this._PlayerState.HP;
                                 if(_loc17_ > this.b.GetUserData().weaponData.Ammo)
                                 {
                                    _loc17_ = Number(this.b.GetUserData().weaponData.Ammo);
                                 }
                                 _loc8_ -= 0.5 * _loc17_;
                                 if(this._PlayerState.HP <= 25)
                                 {
                                    _loc8_ *= 0.7;
                                 }
                              }
                              else
                              {
                                 _loc8_ = 9999;
                              }
                              if(this.b == _loc14_)
                              {
                                 _loc8_ *= 0.8;
                              }
                              if(_loc8_ < _loc3_)
                              {
                                 _loc15_ = _loc5_;
                                 _loc3_ = _loc8_;
                                 _loc2_ = -1;
                              }
                           }
                        }
                     }
                  }
                  _loc5_++;
               }
               if(_loc15_ >= 0)
               {
                  this._BotState.TargetWeapon = this.m_world.WeaponList[_loc15_];
                  --this._BotState.PathGridCounter;
                  if(_loc14_ != this._BotState.TargetWeapon && this._BotState.Phase == BotState.GRAB_WEAPON)
                  {
                     this._BotState.Phase = BotState.IDLE;
                  }
                  if(_loc14_ != this._BotState.TargetWeapon || this._BotState.PathGridCounter <= 0)
                  {
                     this._BotState.PathGridCounter = 2;
                     _loc18_ = this._pathGrid.GetNodeAt(this._BotState.TargetWeapon.GetPosition().x * 30,this._BotState.TargetWeapon.GetPosition().y * 30);
                     this.BotCalculatePathGrid(_loc18_);
                     if(this._BotState.Path.length <= 0)
                     {
                        if(this._pathGrid.GetNodeAt(this.MidPosX(),this.MidPosY()) != _loc18_)
                        {
                           this._BotState.UnavailableWeapons.push([this._BotState.TargetWeapon,0]);
                           this._BotState.TargetWeapon = null;
                        }
                     }
                  }
               }
               else
               {
                  this._BotState.TargetWeapon = null;
               }
            }
         }
         if(_loc2_ >= 0)
         {
            this._BotState.TargetPlayer = this._players[_loc2_];
            --this._BotState.PathGridCounter;
            if(_loc4_ != this._BotState.TargetPlayer || this._BotState.PathGridCounter <= 0)
            {
               this._BotState.PathGridCounter = 2;
               _loc19_ = Number(this._BotState.TargetPlayer.MidPosX());
               _loc20_ = Number(this._BotState.TargetPlayer.MidPosY());
               _loc21_ = this._pathGrid.GetNodeAt(_loc19_,_loc20_);
               this.BotCalculatePathGrid(_loc21_);
               if(this._BotState.Path.length <= 0)
               {
                  _loc22_ = this._pathGrid.GetNodeAt(this.MidPosX(),this.MidPosY());
                  if(_loc22_ != null)
                  {
                     if(_loc22_.GetBindTo(_loc21_) != null || _loc22_ == _loc21_)
                     {
                        return;
                     }
                     if(this.BotPositionShootableFrom(_loc19_,_loc20_,_loc22_.PosX,_loc22_.PosY - 2))
                     {
                        this._BotState.IgnoreObjectCheckingTimer = BotState.UNAVAILABLE_PLAYER_TIMER;
                        return;
                     }
                     _loc23_ = this._pathGrid.GetConnectedNodes();
                     _loc5_ = 2;
                     while(_loc5_ < _loc23_.length)
                     {
                        if(this.BotPositionShootableFrom(_loc19_,_loc20_,_loc23_[_loc5_].PosX,_loc23_[_loc5_].PosY - 2))
                        {
                           this._BotState.IgnoreObjectCheckingTimer = BotState.UNAVAILABLE_PLAYER_TIMER;
                           this.BotCalculatePathGrid(_loc23_[_loc5_]);
                           return;
                        }
                        _loc5_ += 2;
                     }
                     this._BotState.UnavailablePlayers.push([this._BotState.TargetPlayer,0]);
                     this._BotState.TargetPlayer = null;
                     this.BotChooseTarget(false);
                  }
               }
            }
         }
         else
         {
            this._BotState.TargetPlayer = null;
         }
         if(_loc2_ == -1 && _loc15_ == -1)
         {
            this.BotCalculatePathGrid(this._pathGrid.GetNodeAt(this.MidPosX(),this.MidPosY()));
         }
      }
      
      private function BotCalculatePathGrid(param1:PathNode) : void
      {
         var _loc4_:int = 0;
         var _loc5_:* = 0;
         var _loc2_:PathNode = null;
         var _loc3_:PathBind = null;
         if(this._BotState.NextResultNode != null)
         {
            if(!this._PlayerState.OnGround)
            {
               _loc2_ = this._BotState.NextResultNode.Node;
            }
            if(this._BotState.NextResultNode.PrevBind != null)
            {
               _loc3_ = this._BotState.NextResultNode.PrevBind;
               if(Boolean(this._PlayerState.Climbing) && _loc3_.MovementType == PathBind.LADDER)
               {
                  return;
               }
               if(Boolean(this._PlayerState.Jumping) && _loc3_.MovementType == PathBind.SPRINTJUMP)
               {
                  return;
               }
               if(Boolean(this._PlayerState.Diving) && _loc3_.MovementType == PathBind.DIVE)
               {
                  return;
               }
            }
         }
         if(_loc2_ == null)
         {
            _loc2_ = this._pathGrid.GetNodeAt(this.MidPosX(),this.MidPosY());
         }
         this._BotState.Path = this._pathGrid.GetPath(_loc2_,param1);
         if(_loc2_ != null)
         {
            if(_loc2_.Avoid)
            {
               this._BotState.RunAwayFromHazards = true;
               if(this._PlayerState.Aiming)
               {
                  this._BotState.Phase = BotState.CANCEL_AIM;
               }
               else
               {
                  this._BotState.Phase = BotState.FOLLOW_PATH;
               }
            }
         }
         if(this._BotState.Path.length > 0)
         {
            this._BotState.Path[this._BotState.Path.length - 1].PrevBind = _loc3_;
         }
         if(this._BotState.NextResultNode != null)
         {
            _loc4_ = 0;
            _loc5_ = int(this._BotState.Path.length - 2);
            while(_loc5_ > _loc4_)
            {
               if(this._BotState.Path[_loc5_].Node == this._BotState.NextResultNode.Node)
               {
                  this._BotState.Path.splice(_loc5_ + 1,this._BotState.Path.length - (_loc5_ + 1));
               }
               _loc5_--;
            }
         }
      }
      
      private function BotTargetThreat_Aim(param1:Player) : Number
      {
         if(param1.State.Aiming)
         {
            return param1.PlayerInSightPercentage(this);
         }
         return 0;
      }
      
      private function BotTargetThreat_Weapon(param1:Player) : Number
      {
         return param1.State.RangeWeaponTotalDamage / 100;
      }
      
      private function BotTargetThreat_Weakness(param1:Player) : Number
      {
         return (100 - param1.State.HP) / 100;
      }
      
      private function BotAimY() : void
      {
         var _loc1_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         if(this._BotState.TargetPlayer == null)
         {
            return;
         }
         if(this._BotState.TargetHazardousObject != null)
         {
            _loc3_ = this.PosX() - this._PlayerState.LastDirX * 4 - this._BotState.TargetHazardousObject.GetPosition().x * 30;
            _loc4_ = this.PosY() - 14 - this._BotState.TargetHazardousObject.GetPosition().y * 30;
         }
         else
         {
            _loc3_ = this.PosX() - this._PlayerState.LastDirX * 4 - this._BotState.TargetPlayer.MidPosX();
            _loc7_ = -1;
            if(Math.abs(_loc3_) < 100)
            {
               if(!this._BotState.TargetPlayer.State.Kneeling && !this._BotState.TargetPlayer.State.TakingCover && !this._BotState.TargetPlayer.State.Knockdowned)
               {
                  _loc7_ -= 2;
               }
            }
            _loc4_ = this.PosY() - 14 - (this._BotState.TargetPlayer.MidPosY() + _loc7_);
         }
         _loc5_ = Math.sqrt(Math.pow(_loc3_,2) + Math.pow(_loc4_,2));
         if(this._BotState.RandomFirePosition)
         {
            if(this._BotState.Difficulty == BotState.EASY)
            {
               _loc9_ = 16 * (Math.PI / 180);
               _loc8_ = _loc5_ * Math.tan(_loc9_);
               if(_loc8_ > 22)
               {
                  _loc8_ = 22;
               }
            }
            else if(this._BotState.Difficulty == BotState.MEDIUM)
            {
               _loc9_ = 11 * (Math.PI / 180);
               _loc8_ = _loc5_ * Math.tan(_loc9_);
               if(_loc8_ > 16)
               {
                  _loc8_ = 16;
               }
            }
            else if(this._BotState.Difficulty == BotState.HARD)
            {
               _loc9_ = 6 * (Math.PI / 180);
               _loc8_ = _loc5_ * Math.tan(_loc9_);
               if(_loc8_ > 8)
               {
                  _loc8_ = 8;
               }
            }
            _loc10_ = Math.random() * Math.PI * 2;
            this._BotState.RandomFireX = Math.cos(_loc10_) * _loc8_;
            this._BotState.RandomFireY = Math.sin(_loc10_) * _loc8_;
            this._BotState.RandomFirePosition = false;
         }
         _loc3_ += this._BotState.RandomFireX;
         _loc4_ += this._BotState.RandomFireY;
         if(this._PlayerState.LastDirX == -1)
         {
            _loc1_ = this._PlayerState.CurrentAimAngle - 180;
            _loc2_ = Math.atan2(_loc4_,_loc3_) * (180 / Math.PI);
         }
         else
         {
            _loc1_ = Math.atan2(-_loc4_,-_loc3_) * (180 / Math.PI) + 180;
            _loc2_ = this._PlayerState.CurrentAimAngle + 180;
         }
         var _loc6_:Number = Math.atan(5 / _loc5_) * (180 / Math.PI);
         if(_loc4_ != 0)
         {
            _loc11_ = Math.abs(_loc3_) / Math.abs(_loc4_);
            if(_loc11_ < 1)
            {
               _loc6_ *= _loc11_;
            }
         }
         if(_loc6_ < 1.5)
         {
            _loc6_ = 1.5;
         }
         this._BotState.TargetInAim = false;
         if(_loc1_ + _loc6_ < _loc2_)
         {
            this.SetBotKey(1,false);
            this.SetBotKey(0,true);
         }
         else if(_loc1_ - _loc6_ > _loc2_)
         {
            this.SetBotKey(0,false);
            this.SetBotKey(1,true);
         }
         else
         {
            this.SetBotKey(1,false);
            this.SetBotKey(0,false);
            this._BotState.TargetInAim = true;
         }
      }
      
      public function PlayerInSightPercentage(param1:Player) : Number
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc4_:Number = this.PosX() - this._PlayerState.LastDirX * 4 - param1.MidPosX();
         var _loc5_:Number = this.PosY() - 14 - param1.MidPosY();
         if(this._PlayerState.LastDirX == -1)
         {
            _loc2_ = this._PlayerState.CurrentAimAngle - 180;
            _loc3_ = Math.atan2(_loc5_,_loc4_) * (180 / Math.PI);
         }
         else
         {
            _loc2_ = Math.atan2(-_loc5_,-_loc4_) * (180 / Math.PI) + 180;
            _loc3_ = this._PlayerState.CurrentAimAngle + 180;
         }
         if(_loc2_ < _loc3_)
         {
            _loc6_ = Math.round(_loc3_ - _loc2_) / 90;
         }
         else
         {
            _loc6_ = Math.round(_loc2_ - _loc3_) / 90;
         }
         if(_loc6_ > 1)
         {
            _loc6_ = 1;
         }
         return 1 - _loc6_;
      }
      
      public function BotPositionShootableFrom(param1:Number, param2:Number, param3:Number, param4:Number) : Boolean
      {
         var _loc16_:Point = null;
         var _loc17_:b2Body = null;
         var _loc18_:int = 0;
         var _loc5_:Point = new Point(param3,param4);
         var _loc6_:Point = new Point(param1,param2);
         var _loc7_:Number = _loc5_.x - _loc6_.x;
         var _loc8_:Number = _loc5_.y - _loc6_.y;
         var _loc9_:Number = Math.sqrt(_loc7_ * _loc7_ + _loc8_ * _loc8_);
         if(_loc9_ > this._PlayerState.RangeWeaponRange)
         {
            return false;
         }
         var _loc10_:b2Body = null;
         var _loc11_:b2Body = null;
         var _loc12_:int = _loc9_ / 4;
         var _loc13_:Number = -_loc7_ / _loc12_;
         var _loc14_:Number = -_loc8_ / _loc12_;
         var _loc15_:int = 1;
         while(_loc15_ <= _loc12_)
         {
            _loc5_.x += _loc13_;
            _loc5_.y += _loc14_;
            _loc6_.x -= _loc13_;
            _loc6_.y -= _loc14_;
            _loc17_ = null;
            _loc18_ = -1;
            while(_loc18_ <= 1)
            {
               if(_loc18_ == 1)
               {
                  _loc16_ = _loc5_;
                  _loc17_ = _loc10_;
               }
               else
               {
                  _loc16_ = _loc6_;
                  _loc17_ = _loc11_;
               }
               if(_loc17_ != null)
               {
                  if(!_loc17_.GetUserData().objectData.ShapeMC.hitTestPoint(_loc16_.x,_loc16_.y,true))
                  {
                     _loc17_ = null;
                  }
               }
               if(_loc17_ == null)
               {
                  if(this._static_objects_hitbox_mc.hitTestPoint(_loc16_.x,_loc16_.y,true))
                  {
                     _loc17_ = this.m_world.GetBulletSolidAt(_loc16_.x,_loc16_.y);
                  }
                  else
                  {
                     if(this._static_world_hitbox_mc.hitTestPoint(_loc16_.x,_loc16_.y,true))
                     {
                        return false;
                     }
                     if(_loc14_ > 0 && !this._PlayerState.RangeWeaponCanShootDown)
                     {
                        if(this._static_world_cloud_hitbox_mc.hitTestPoint(_loc16_.x,_loc16_.y,true))
                        {
                           return false;
                        }
                     }
                  }
               }
               if(_loc17_ != null)
               {
                  if(!this._PlayerState.RangeWeaponIsFlamethrower && !this._PlayerState.RangeWeaponIsBazooka)
                  {
                     if(_loc17_.GetUserData().objectData.Indestructible)
                     {
                        return false;
                     }
                  }
               }
               if(_loc18_ == 1)
               {
                  _loc10_ = _loc17_;
               }
               else
               {
                  _loc11_ = _loc17_;
               }
               _loc18_ += 2;
            }
            _loc15_ += 2;
         }
         return true;
      }
      
      public function BotPositionInSight(param1:Number, param2:Number, param3:Number, param4:b2Body = null) : Boolean
      {
         var _loc16_:Point = null;
         var _loc17_:b2Body = null;
         var _loc18_:int = 0;
         var _loc19_:int = 0;
         var _loc20_:Boolean = false;
         var _loc5_:Point = new Point(this.PosX() - this._PlayerState.LastDirX * 4,this.PosY() - 14);
         var _loc6_:Point = new Point(param1,param2);
         var _loc7_:Number = _loc5_.x - _loc6_.x;
         var _loc8_:Number = _loc5_.y - _loc6_.y;
         var _loc9_:Number = Math.sqrt(_loc7_ * _loc7_ + _loc8_ * _loc8_);
         if(_loc9_ > this._PlayerState.RangeWeaponRange)
         {
            return false;
         }
         var _loc10_:b2Body = null;
         var _loc11_:b2Body = null;
         var _loc12_:int = _loc9_ / 4;
         var _loc13_:Number = -_loc7_ / _loc12_;
         var _loc14_:Number = -_loc8_ / _loc12_;
         var _loc15_:int = 1;
         while(_loc15_ <= _loc12_)
         {
            _loc5_.x += _loc13_;
            _loc5_.y += _loc14_;
            _loc6_.x -= _loc13_;
            _loc6_.y -= _loc14_;
            _loc17_ = null;
            _loc18_ = -1;
            while(_loc18_ <= 1)
            {
               if(_loc18_ == 1)
               {
                  _loc16_ = _loc5_;
                  _loc17_ = _loc10_;
               }
               else
               {
                  _loc16_ = _loc6_;
                  _loc17_ = _loc11_;
               }
               if(_loc17_ != null)
               {
                  if(!_loc17_.GetUserData().objectData.ShapeMC.hitTestPoint(_loc16_.x,_loc16_.y,true))
                  {
                     _loc17_ = null;
                  }
               }
               if(_loc17_ == null)
               {
                  if(this._static_objects_hitbox_mc.hitTestPoint(_loc16_.x,_loc16_.y,true))
                  {
                     _loc17_ = this.m_world.GetBulletSolidAt(_loc16_.x,_loc16_.y);
                     if(_loc17_ == param4)
                     {
                        _loc17_ = null;
                     }
                  }
                  else
                  {
                     if(this._static_world_hitbox_mc.hitTestPoint(_loc16_.x,_loc16_.y,true))
                     {
                        return false;
                     }
                     if(_loc14_ > 0 && !this._PlayerState.RangeWeaponCanShootDown)
                     {
                        if(this._static_world_cloud_hitbox_mc.hitTestPoint(_loc16_.x,_loc16_.y,true))
                        {
                           return false;
                        }
                     }
                  }
               }
               if(_loc17_ != null)
               {
                  if(!this._PlayerState.RangeWeaponIsFlamethrower)
                  {
                     if(!this._BotState.IgnoreObjectChecking || !this._PlayerState.RangeWeaponIsBazooka)
                     {
                        if(_loc17_.GetUserData().objectData.Indestructible)
                        {
                           return false;
                        }
                     }
                     if(this._PlayerState.CurrentRangeWeapon != null)
                     {
                        _loc20_ = false;
                        if(_loc17_.GetUserData().objectData.IsBulletHazard)
                        {
                           if(Math.sqrt(Math.pow(_loc17_.GetPosition().x * 30 - this.MidPosX(),2) + Math.pow(_loc17_.GetPosition().y * 30 - this.MidPosY(),2)) <= HAZARDOUS_DISTANCE_AVOID)
                           {
                              return false;
                           }
                           _loc20_ = true;
                        }
                        if(!_loc20_ && !this._BotState.IgnoreObjectChecking)
                        {
                           if(this._PlayerState.CurrentRangeWeapon.Properties.Projectile.StrengthLeft < _loc17_.GetUserData().objectData.Strength)
                           {
                              return false;
                           }
                        }
                     }
                  }
               }
               if(_loc18_ == 1)
               {
                  _loc10_ = _loc17_;
               }
               else
               {
                  _loc11_ = _loc17_;
               }
               _loc19_ = 0;
               while(_loc19_ < this._players.length)
               {
                  if(this._players[_loc19_].State.HP <= 0)
                  {
                     if(_loc15_ + 2 <= _loc12_)
                     {
                        if(this._players[_loc19_].CollisionMC.hitTestPoint(_loc16_.x,_loc16_.y,true))
                        {
                           return false;
                        }
                     }
                  }
                  else if(this._players[_loc19_].PlayerNr != this.PlayerNr)
                  {
                     if(this._players[_loc19_].PlayerNr != param3)
                     {
                        if(this._players[_loc19_].Team == this.Team)
                        {
                           if(this._players[_loc19_].AreaMC.hitTestPoint(_loc16_.x,_loc16_.y,true))
                           {
                              return false;
                           }
                        }
                     }
                  }
                  _loc19_++;
               }
               _loc18_ += 2;
            }
            _loc15_ += 2;
         }
         return true;
      }
      
      private function SetBotKey(param1:int, param2:Boolean) : void
      {
         switch(param2)
         {
            case true:
               switch(param1)
               {
                  case 0:
                     if(!this._keyPressed[0])
                     {
                        this._keyPressed[0] = true;
                        this._keyPressed[8] = true;
                        this.UpPressed();
                        this.Jump();
                     }
                     break;
                  case 1:
                     if(!this._keyPressed[1])
                     {
                        this._keyPressed[1] = true;
                        this._keyPressed[9] = true;
                        this.DownPressed();
                        this.KneelPressed();
                     }
                     break;
                  case 2:
                     this._keyPressed[2] = true;
                     break;
                  case 3:
                     this._keyPressed[3] = true;
                     break;
                  case 4:
                     if(!this._keyPressed[4])
                     {
                        this._keyPressed[4] = true;
                        this.Melee();
                     }
                     break;
                  case 5:
                     if(!this._keyPressed[5])
                     {
                        this._keyPressed[5] = true;
                        this.RangedDown();
                     }
                     break;
                  case 6:
                     if(!this._keyPressed[6])
                     {
                        this._keyPressed[6] = true;
                        this.ThrowDown();
                     }
                     break;
                  case 7:
                     if(!this._keyPressed[7])
                     {
                        this._keyPressed[7] = true;
                        this.UsePowerup();
                     }
               }
               break;
            case false:
               switch(param1)
               {
                  case 0:
                     this._keyPressed[0] = false;
                     this._keyPressed[8] = false;
                     break;
                  case 1:
                     if(this._keyPressed[1])
                     {
                        this._keyPressed[1] = false;
                        this._keyPressed[9] = false;
                        this.KneelReleased();
                     }
                     break;
                  case 2:
                     this._keyPressed[2] = false;
                     break;
                  case 3:
                     this._keyPressed[3] = false;
                     break;
                  case 4:
                     this._keyPressed[4] = false;
                     break;
                  case 5:
                     if(this._keyPressed[5])
                     {
                        this._keyPressed[5] = false;
                        this.RangedUp();
                     }
                     break;
                  case 6:
                     if(this._keyPressed[6])
                     {
                        this._keyPressed[6] = false;
                        this.ThrowUp();
                     }
                     break;
                  case 7:
                     this._keyPressed[7] = false;
               }
         }
      }
      
      private function MainUpdate() : void
      {
         var _loc3_:Number = NaN;
         if(this._PlayerState.HP > 0 && Boolean(this._PlayerState.ShowFlashEffect))
         {
            if(this._PlayerState.FlashEffectTimer > 0)
            {
               this.UpdateFlashEffect();
            }
            else
            {
               this.StopFlashEffect();
            }
         }
         else if(this._PlayerState.ShowFlashEffect)
         {
            this.StopFlashEffect();
         }
         else if(!this._activated && !this._bot)
         {
            this._PlayerState.ShowFlashEffect = true;
         }
         if(this._PlayerState.GrabbedByPlayer)
         {
            return;
         }
         if(this._PlayerState.StuckToRocket)
         {
            this.AddSmokeTrace(1);
            this._PlayerState.RocketRideTimer += this._game_speed;
            if(this._PlayerState.RocketRideTimer > 150)
            {
               this._PlayerState.RocketRideProjectile.Explode();
               return;
            }
            if(this._keyPressed[3])
            {
               this._PlayerState.RocketRideProjectile.Angle += 20 * this._game_speed;
            }
            if(this._keyPressed[2])
            {
               this._PlayerState.RocketRideProjectile.Angle -= 20 * this._game_speed;
            }
            return;
         }
         this._old_this_x = this._this_x;
         this._old_this_y = this._this_y;
         this._PlayerState.MovingDirectionX = 0;
         this.UpdateInversedDirection();
         if(this._PlayerState.TakingCover)
         {
            if(!this.CanTakeCover(this._PlayerState.LastDirX))
            {
               this._PlayerState.TakingCover = false;
            }
         }
         if(this._PlayerState.ControllAble)
         {
            if(this._PlayerState.Aiming)
            {
               if(!this._PlayerState.AimTurningAroundDelay)
               {
                  if(this._keyPressed[1])
                  {
                     this.AimDown();
                  }
                  else if(this._keyPressed[0])
                  {
                     this.AimUp();
                  }
                  else
                  {
                     this.AimIdle();
                  }
                  this.AimLazer();
                  if(this.PressingLeft())
                  {
                     this.AimLeft();
                  }
                  else if(this.PressingRight())
                  {
                     this.AimRight();
                  }
               }
               else if(this._keyPressed[1])
               {
                  this.AimDown();
               }
               else if(this._keyPressed[0])
               {
                  this.AimUp();
               }
               else
               {
                  this.AimIdle();
               }
            }
            else
            {
               if(!this._PlayerState.Sprinting)
               {
                  if(this.KeyPressed(KEY_SPRINT))
                  {
                     if(this._PlayerState.SprintEnergy > 10)
                     {
                        this._PlayerState.Sprinting = true;
                     }
                  }
               }
               if(this._PlayerState.PlayerJumpPushActivated)
               {
                  if(Boolean(this._PlayerState.Jumping) && Boolean(this._PlayerState.PlayerJumpPushEnabled))
                  {
                     if(this._keyPressed[KEY_JUMP])
                     {
                        this._PlayerState.JumpPushTimeLeft -= this._game_speed;
                        if(this._PlayerState.JumpPushTimeLeft <= 0)
                        {
                           this._PlayerState.PlayerJumpPushEnabled = false;
                        }
                        else if(this._PlayerState.PlayerJumpPushLevelOut)
                        {
                           _loc3_ = this._PlayerState.JumpPushTimeLeft / this._PlayerState.PlayerJumpPushTime;
                           this._PlayerState.AirVelocityY += this._PlayerState.PlayerJumpPushPower * _loc3_ * this._game_speed;
                        }
                        else
                        {
                           this._PlayerState.AirVelocityY += this._PlayerState.PlayerJumpPushPower * this._game_speed;
                        }
                     }
                     else
                     {
                        this._PlayerState.PlayerJumpPushEnabled = false;
                     }
                  }
               }
               if(this._keyPressed[KEY_UP])
               {
                  if(this._static_ladder_hitbox_mc.hitTestPoint(this.MidPosX(),this.MidPosY(),true))
                  {
                     this._PlayerState.Climbing = true;
                  }
               }
               else if(this._keyPressed[KEY_DOWN])
               {
                  if(!this._PlayerState.OnGround)
                  {
                     if(this._static_ladder_hitbox_mc.hitTestPoint(this.MidPosX(),this.MidPosY(),true))
                     {
                        this._PlayerState.Climbing = true;
                     }
                  }
               }
               if(Boolean(this._keyPressed[KEY_KNEEL]) && !this._PlayerState.TakingCover)
               {
                  if(this._PlayerState.OnGround)
                  {
                     if(!this._keyPressed[2] && !this._keyPressed[3])
                     {
                        if(!this._PlayerState.DisableKneel)
                        {
                           this._PlayerState.Kneeling = true;
                        }
                     }
                     else
                     {
                        if(!this.CheckForceKneeling())
                        {
                           this._PlayerState.Kneeling = false;
                        }
                        if(this._PlayerState.Sprinting)
                        {
                           if(Boolean(this._PlayerState.CanDive) || Boolean(this._PlayerState.ShortDiveAvailable))
                           {
                              this.Dive();
                           }
                        }
                        else if(this._PlayerState.ShortDiveAvailable)
                        {
                           this.Dive();
                        }
                        else if(this._PlayerState.CanRoll)
                        {
                           this.Roll();
                        }
                     }
                  }
               }
               else if(!this.CheckForceKneeling())
               {
                  this._PlayerState.Kneeling = false;
               }
               if(!this._PlayerState.Climbing)
               {
                  if(this.PressingLeft(true))
                  {
                     this.MoveDirection(-1);
                  }
                  else if(this.PressingRight(true))
                  {
                     this.MoveDirection(1);
                  }
                  else if(this._PlayerState.WallJumping)
                  {
                     this.MovePlayer(1,this._PlayerState.WallJumpSpeed);
                  }
               }
            }
            this.UpdateWeaponGrab();
            if(this._PlayerState.QueueJumpKick)
            {
               if(this._PlayerState.Jumping)
               {
                  if(!this._PlayerState.JumpKickPerformed && this._PlayerState.AirbornTimer >= 2.5 && !this._PlayerState.Climbing)
                  {
                     this._Handler_Sounds.PlaySoundAt("KICK_SWING",this.PosX(),this.PosY());
                     this.Kick(false,true);
                     this._PlayerState.JumpKickPerformed = true;
                  }
               }
            }
         }
         else
         {
            this._lazer_mc.visible = false;
            this._aim_mc.visible = false;
            if(this._PlayerState.Staggering)
            {
               if(this.CanStagger())
               {
                  if(this._staggerFragileObject != null)
                  {
                     this._staggerFragileObject.ApplyImpulse(new b2Vec2(-this._PlayerState.LastDirX * 0.5,0),new b2Vec2(0,0));
                     this._staggerFragileObject.GetUserData().objectData.ForceDestruction();
                     this._staggerFragileObject = null;
                  }
                  this.MovePlayer(this._PlayerState.LastDirX,this._PlayerState.LastDirX * this._PlayerState.StaggerSpeed);
               }
               else
               {
                  if(this._PlayerState.HP <= 0)
                  {
                     this.Fall(false);
                  }
                  this._PlayerState.Staggering = false;
               }
            }
            else if(this._PlayerState.Rolling)
            {
               this.MovePlayer(this._PlayerState.LastDirX,this._PlayerState.LastDirX * this._PlayerState.RollSpeed);
               this.UpdateWeaponGrab();
            }
            else if(!this._PlayerState.IsStunned)
            {
               if(this._PlayerState.Punching)
               {
                  if(!this._PlayerState.PunchHitPerformed)
                  {
                     if(this._PlayerAnimation.NextFrame(this._game_speed) < this._PlayerState.HitPunchComboFrame)
                     {
                        if(this.PressingLeft())
                        {
                           this.TurnLeft();
                        }
                        else if(this.PressingRight())
                        {
                           this.TurnRight();
                        }
                     }
                     else if(this._PlayerAnimation.NextFrame(this._game_speed) == this._PlayerState.HitPunchComboFrame)
                     {
                        this.MeleeStrike();
                     }
                  }
                  else if(this._PlayerState.PunchComboNr == 3)
                  {
                     this.MovePlayer(this._PlayerState.LastDirX,this._PlayerState.PunchGlideSpeed * this._PlayerState.LastDirX * (1 - this._PlayerAnimation.Progress));
                  }
               }
            }
         }
         if(!this._PlayerState.ControllAble || Boolean(this._PlayerState.Aiming) || !this._keyPressed[2] && !this._keyPressed[3] || Boolean(this._keyPressed[2]) && Boolean(this._keyPressed[3]))
         {
            this._PlayerState.Running = false;
         }
         this.UpdateObjectImpacts();
         this.UpdateStairBounce();
         if(!this._PlayerState.OnGround)
         {
            this.UpdateAirMovement();
         }
         else
         {
            this.UpdateGroundMovement();
         }
         if(this.Stuck())
         {
            this._this_x = this._old_this_x;
            this._this_y = this._old_this_y;
         }
         this.x = this._this_x;
         this.y = this._this_y;
         this._collision_mc.x = this._this_x;
         this._collision_mc.y = this._this_y;
         this._player_area_mc.x = this._this_x;
         this._player_area_mc.y = this._this_y;
         this._PlayerState.PortalSpeedX = Math.abs(this._this_x - this._old_this_x) / this._game_speed;
         var _loc1_:int = int(this.ConvertToDirection(this._this_x - this._old_this_x));
         if(_loc1_ != 0)
         {
            this._PlayerState.PortalDirectionX = _loc1_;
         }
         this.ProgressAFS();
         this.AFSUpdated = false;
         var _loc2_:int = 0;
         while(_loc2_ < this.m_world.MolotovList.length)
         {
            this.b = this.m_world.MolotovList[_loc2_];
            if(this.b.GetUserData().objectData.UserValues[0] != this.PlayerNr)
            {
               if(this.CollisionMC.hitTestObject(this.b.GetUserData().objectData.ShapeMC))
               {
                  if(this.CollisionMC.hitTestPoint(this.b.GetPosition().x * 30,this.b.GetPosition().y * 30,true))
                  {
                     this.b.GetUserData().objectData.ForceDestruction();
                  }
               }
            }
            _loc2_++;
         }
         if(this._PlayerState.EmptyWeaponRecoilBack > 0)
         {
            --this._PlayerState.EmptyWeaponRecoilBack;
            if(this._PlayerState.EmptyWeaponRecoilBack <= 0)
            {
               if(this._char.ANIM_WPN != null)
               {
                  this._char.ANIM_WPN.x = this._PlayerState.CharAnimWpnX;
                  this._char.ANIM_WPN.y = this._PlayerState.CharAnimWpnY;
               }
            }
         }
         if(this._PlayerState.AddSmokeEffect)
         {
            this.AddSmokeTrace(2);
         }
      }
      
      private function AddSmokeTrace(param1:Number = 0) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         this._smokeDelay -= this._game_speed;
         if(this._smokeDelay <= 0 || param1 == 0)
         {
            _loc2_ = Math.random() * 10 - 5;
            _loc3_ = Math.random() * 14 - 8;
            this._Handler_Effects.AddParticle(new particle_data("SMOKE_TRACE_EFFECT",this.MidPosX() + _loc2_ * 0.7,this.MidPosY() + _loc3_ * 0.7,new b2Vec2(),0,1,[1]));
            this._smokeDelay = param1;
         }
      }
      
      private function Stuck() : Boolean
      {
         if(this.HitTestWorldOnly(this._this_x,this._this_y - 2))
         {
            if(this.HitTestWorldOnly(this._this_x,this._this_y + 2))
            {
               return true;
            }
         }
         return false;
      }
      
      private function UpdateWeaponGrab() : void
      {
         var _loc1_:b2Body = this.GetClosestReachableWeapon();
         if(_loc1_ != null)
         {
            if(_loc1_.GetUserData().isRanged == true && this._PlayerState.CurrentRangeWeapon == null)
            {
               this._PlayerState.CurrentRangeWeapon = _loc1_.GetUserData().weaponData;
               this._Handler_Effects.AddParticle(new particle_data("PICKUP_" + _loc1_.GetUserData().weaponData.Properties.WeaponType,this.MidPosX(),this.MidPosY() - 10));
               _loc1_.GetUserData().objectData.ForceDestruction();
               this._Handler_Sounds.PlaySoundAt(this._PlayerState.CurrentRangeWeapon.Properties.PickupSound,this.PosX(),this.PosY());
               this.UpdateGUI();
               return;
            }
            if(_loc1_.GetUserData().isThrowable == true && this._PlayerState.CurrentThrowableWeapon.Ammo <= 0)
            {
               this._PlayerState.CurrentThrowableWeapon = _loc1_.GetUserData().weaponData;
               this._Handler_Effects.AddParticle(new particle_data("PICKUP_" + _loc1_.GetUserData().weaponData.Properties.WeaponType,this.MidPosX(),this.MidPosY() - 10));
               this._Handler_Sounds.PlaySoundAt(this._PlayerState.CurrentThrowableWeapon.Properties.PickupSound,this.PosX(),this.PosY());
               _loc1_.GetUserData().objectData.ForceDestruction();
               this.UpdateGUI();
               return;
            }
            if(_loc1_.GetUserData().isMelee == true && this._PlayerState.CurrentMeleeWeapon == null)
            {
               this._PlayerState.CurrentMeleeWeapon = _loc1_.GetUserData().weaponData;
               this._Handler_Effects.AddParticle(new particle_data("PICKUP_" + _loc1_.GetUserData().weaponData.Properties.WeaponType,this.MidPosX(),this.MidPosY() - 10));
               this._Handler_Sounds.PlaySoundAt(this._PlayerState.GetMeleeWeapon().Properties.PickupSound,this.PosX(),this.PosY());
               _loc1_.GetUserData().objectData.ForceDestruction();
               this.UpdateGUI();
               return;
            }
            if(_loc1_.GetUserData().isPowerup == true && this._PlayerState.CurrentPowerupWeapon == null)
            {
               this._PlayerState.CurrentPowerupWeapon = _loc1_.GetUserData().weaponData;
               this._Handler_Effects.AddParticle(new particle_data("PICKUP_" + _loc1_.GetUserData().weaponData.Properties.WeaponType,this.MidPosX(),this.MidPosY() - 10));
               this._Handler_Sounds.PlaySoundAt(this._PlayerState.CurrentPowerupWeapon.Properties.PickupSound,this.PosX(),this.PosY());
               _loc1_.GetUserData().objectData.ForceDestruction();
               this.UpdateGUI();
               return;
            }
            if(_loc1_.GetUserData().isHealth == true && this._PlayerState.HP < 100)
            {
               this._PlayerState.HP += _loc1_.GetUserData().weaponData.Ammo;
               this._Handler_Sounds.PlaySoundAt(_loc1_.GetUserData().weaponData.Properties.PickupSound,this.PosX(),this.PosY());
               _loc1_.GetUserData().objectData.ForceDestruction();
               this.StartFlashEffect();
               return;
            }
            if(this._indicationWeapon != _loc1_)
            {
               if(this._indicationWeapon != null)
               {
                  this._indicationWeapon.GetUserData().objectData.MC.indicator.gotoAndStop(1);
               }
               this._indicationWeapon = _loc1_;
               this._indicationWeapon.GetUserData().objectData.MC.indicator.gotoAndStop(2);
            }
         }
         else if(this._indicationWeapon != null)
         {
            this._indicationWeapon.GetUserData().objectData.MC.indicator.gotoAndStop(1);
            this._indicationWeapon = null;
         }
      }
      
      private function DisableJumpDownLevel() : void
      {
         this._enableJumpDownLevel = false;
         clearInterval(this._downTimer);
      }
      
      private function KneelPressed() : void
      {
         if(!this._PlayerState.Jumping)
         {
            if(this._enableJumpDownLevel)
            {
               this._enableJumpDownLevel = false;
               clearInterval(this._downTimer);
               this.AbortAiming();
               this._jumpDownPosYDisable = this._this_y + 10;
               this._performJumpDownLevel = true;
               this._PlayerState.AirVelocityX = 0;
               this._PlayerState.AirVelocityY = 0;
               this._PlayerState.Jumping = true;
            }
            else
            {
               if(!this._PlayerState.ControllAble || Boolean(this._PlayerState.Aiming))
               {
                  return;
               }
               clearInterval(this._downTimer);
               this._downTimer = setInterval(this.DisableJumpDownLevel,250);
               this._enableJumpDownLevel = true;
            }
         }
      }
      
      private function StopStaggerFunc() : void
      {
         if(this._PlayerState.HP <= 0)
         {
            this.Fall(false);
            return;
         }
         this.b = this.m_world.GetStairBodyAt(this._this_x,this._this_y + 2);
         if(this.b == null)
         {
            this.b = this.m_world.GetStairBodyAt(this._this_x,this._this_y + 4);
         }
         if(this.b != null)
         {
            if(this.CanBounceAtDirection(this.ConvertToDirection(this.b.GetUserData().tiltValue)))
            {
               this.Fall(false);
               this._PlayerState.StairBounce = true;
               if(this._PlayerState.StairVelocityY < -4)
               {
                  this._PlayerState.StairVelocityY = -4;
               }
               else if(this._PlayerState.StairVelocityY > -1)
               {
                  this._PlayerState.StairVelocityY = -1;
               }
               this._PlayerState.StairVelocityX = this.b.GetUserData().tiltValue;
            }
         }
      }
      
      private function UpdateInversedDirection() : void
      {
         if(this._PlayerState.MovingDirectionInversed != 0)
         {
            if(!this._keyPressed[3] && this._PlayerState.MovingDirectionInversed == 1)
            {
               this._PlayerState.MovingDirectionInversed = 0;
            }
            if(!this._keyPressed[2] && this._PlayerState.MovingDirectionInversed == -1)
            {
               this._PlayerState.MovingDirectionInversed = 0;
            }
         }
      }
      
      private function PressingLeft(param1:Boolean = false) : Boolean
      {
         if(this._PlayerState.MovingDirectionInversed != 0)
         {
            if(this._PlayerState.MovingDirectionInversed == -1)
            {
               return false;
            }
            if(this._keyPressed[3])
            {
               return true;
            }
         }
         else if(Boolean(this._keyPressed[2]) && (!this._keyPressed[3] || !param1))
         {
            return true;
         }
         return false;
      }
      
      private function PressingRight(param1:Boolean = false) : Boolean
      {
         if(this._PlayerState.MovingDirectionInversed != 0)
         {
            if(this._PlayerState.MovingDirectionInversed == 1)
            {
               return false;
            }
            if(this._keyPressed[2])
            {
               return true;
            }
         }
         else if(Boolean(this._keyPressed[3]) && (!this._keyPressed[2] || !param1))
         {
            return true;
         }
         return false;
      }
      
      private function KneelReleased() : void
      {
         this._PlayerState.DisableKneel = false;
      }
      
      private function CancelAFS() : void
      {
         this._PlayerState.CancelAFS();
         this._cancelAimingASAP = false;
         if(this._flameAwayActivated)
         {
            clearInterval(this._flameAwayTimer);
            this._flameAwayActivated = false;
         }
      }
      
      private function TurnLeft() : void
      {
         if(this._PlayerState.LastDirX == 1)
         {
            this.scaleX = -1;
            this._collision_mc.scaleX = this.scaleX;
            this._PlayerState.LastDirX = -1;
         }
      }
      
      private function TurnRight() : void
      {
         if(this._PlayerState.LastDirX == -1)
         {
            this.scaleX = 1;
            this._collision_mc.scaleX = this.scaleX;
            this._PlayerState.LastDirX = 1;
         }
      }
      
      private function AimLeft() : void
      {
         if(this._PlayerState.LastDirX == 1)
         {
            this._PlayerState.FastTrigger = false;
            this._lazer_mc.visible = false;
            this._aim_mc.visible = false;
            this.CancelAFS();
            this._PlayerState.AimTurningAround = true;
            this.scaleX = -1;
            this._collision_mc.scaleX = this.scaleX;
            this._PlayerState.LastDirX = -1;
            this._PlayerState.CurrentAimPitch = 0;
            this._PlayerState.CurrentChangePitchSpeed = 0;
         }
      }
      
      private function AimRight() : void
      {
         if(this._PlayerState.LastDirX == -1)
         {
            this._PlayerState.FastTrigger = false;
            this._lazer_mc.visible = false;
            this._aim_mc.visible = false;
            this.CancelAFS();
            this._PlayerState.AimTurningAround = true;
            this.scaleX = 1;
            this._collision_mc.scaleX = this.scaleX;
            this._PlayerState.LastDirX = 1;
            this._PlayerState.CurrentAimPitch = 0;
            this._PlayerState.CurrentChangePitchSpeed = 0;
         }
      }
      
      private function UpPressed() : void
      {
         if(this._PlayerState.ControllAble)
         {
            if(this._PlayerState.Aiming)
            {
               if(!this._PlayerState.AimTurningAroundDelay)
               {
                  this.AimUp(0.5);
               }
            }
         }
      }
      
      private function DownPressed() : void
      {
         if(this._PlayerState.ControllAble)
         {
            if(this._PlayerState.Aiming)
            {
               if(!this._PlayerState.AimTurningAroundDelay)
               {
                  this.AimDown(0.5);
               }
            }
         }
      }
      
      private function AimUp(param1:Number = 0) : void
      {
         if(this._PlayerState.CurrentAimPitch > -this._PlayerState.UpperAimPitch)
         {
            if(param1 != 0)
            {
               this._PlayerState.CurrentChangePitchSpeed = -param1;
            }
            if(this._PlayerState.CurrentChangePitchSpeed > 0)
            {
               this._PlayerState.CurrentChangePitchSpeed = 0;
            }
            this._PlayerState.CurrentAimPitch += this._PlayerState.CurrentChangePitchSpeed * this._game_speed;
            this._PlayerState.CurrentChangePitchSpeed -= 2;
            if(this._PlayerState.CurrentAimPitch < -this._PlayerState.UpperAimPitch)
            {
               this._PlayerState.CurrentAimPitch = -this._PlayerState.UpperAimPitch;
            }
         }
      }
      
      private function AimDown(param1:Number = 0) : void
      {
         if(this._PlayerState.CurrentAimPitch < this._PlayerState.LowerAimPitch)
         {
            if(param1 != 0)
            {
               this._PlayerState.CurrentChangePitchSpeed = param1;
            }
            if(this._PlayerState.CurrentChangePitchSpeed < 0)
            {
               this._PlayerState.CurrentChangePitchSpeed = 0;
            }
            this._PlayerState.CurrentAimPitch += this._PlayerState.CurrentChangePitchSpeed * this._game_speed;
            this._PlayerState.CurrentChangePitchSpeed += 2;
            if(this._PlayerState.CurrentAimPitch > this._PlayerState.LowerAimPitch)
            {
               this._PlayerState.CurrentAimPitch = this._PlayerState.LowerAimPitch;
            }
         }
      }
      
      private function AimIdle() : void
      {
         this._PlayerState.ResetChangePitchSpeed();
      }
      
      private function MoveDirection(param1:int) : void
      {
         if(this._PlayerState.TakingCover)
         {
            if(this._PlayerState.LastDirX == param1)
            {
               this._PlayerState.Running = false;
               return;
            }
            this._PlayerState.TakingCover = false;
         }
         if(!this._PlayerState.Running && Boolean(this._PlayerState.OnGround))
         {
            if(this.CanTakeCover(param1))
            {
               this._PlayerState.TakingCover = true;
               this.b = this.GetDynamicBodyAt(this._this_x + param1 * this._PlayerState.PlayerEdgeDistance + param1 * 4,this.MidPosY(),false);
               if(this.b != null)
               {
                  this._PlayerState.Box2DCover = this.b;
                  this._PlayerState.CoverObjectID = this.b.GetUserData().IDNumber;
               }
               else
               {
                  this.b = this.GetStaticCoverAt(this._this_x + param1 * this._PlayerState.PlayerEdgeDistance + param1 * 4,this.MidPosY());
                  if(this.b != null)
                  {
                     this._PlayerState.Box2DCover = null;
                     this._PlayerState.CoverObjectID = this.b.GetUserData().IDNumber;
                  }
               }
            }
         }
         this._PlayerState.Running = true;
         if(this._PlayerState.WallJumping)
         {
            this.MovePlayer(param1,this._PlayerState.WallJumpSpeed * param1 + this._PlayerState.LastDirX);
         }
         else
         {
            this.MovePlayer(param1,this._PlayerState.RunSpeed * param1);
         }
      }
      
      private function CanTakeCover(param1:int) : Boolean
      {
         var _loc3_:int = 0;
         var _loc2_:Number = param1 * this._PlayerState.PlayerEdgeDistance + param1 * 4;
         if(this._static_world_hitbox_mc.hitTestPoint(this._this_x + _loc2_,this.MidPosY(),true))
         {
            if(!this._PlayerState.TakingCover)
            {
               this.b = this.m_world.GetStairBodyAt(this._this_x + _loc2_,this.MidPosY());
               if(this.b != null)
               {
                  return false;
               }
            }
            _loc3_ = 0;
            while(_loc3_ <= 12)
            {
               if(!this._static_world_hitbox_mc.hitTestPoint(this._this_x + _loc2_,this._this_y - 22 + _loc3_,true))
               {
                  return true;
               }
               _loc3_ += 4;
            }
         }
         return false;
      }
      
      private function MovePlayer(param1:int, param2:Number) : void
      {
         if(!this._PlayerState.Staggering)
         {
            if(!this._PlayerState.WallJumping && Boolean(this._PlayerState.Jumping))
            {
               this._PlayerState.MovingDirectionX = param1;
            }
            else if(!this._PlayerState.WallJumping)
            {
               this.scaleX = param1;
               this._collision_mc.scaleX = this.scaleX;
               this._PlayerState.LastDirX = this.scaleX;
               this._PlayerState.MovingDirectionX = this._PlayerState.LastDirX;
            }
            else
            {
               this._PlayerState.LastDirX = this.scaleX;
               this._PlayerState.MovingDirectionX = this._PlayerState.LastDirX;
            }
         }
         else
         {
            this._PlayerState.MovingDirectionX = -this._PlayerState.LastDirX;
         }
         if(Boolean(this._PlayerState.Kneeling) && !this._PlayerState.Rolling)
         {
            if(this._PlayerState.CanRoll)
            {
               this.Roll();
            }
            return;
         }
         var _loc3_:int = Math.abs(param2 * 10);
         var _loc4_:Number = this._PlayerState.MovingDirectionX * 0.1;
         var _loc5_:int = 1;
         while(_loc5_ <= _loc3_)
         {
            if(this.WalkCollision(this._PlayerState.MovingDirectionX,this._PlayerState.Jumping))
            {
               return;
            }
            this._this_x += _loc4_ * this._game_speed;
            if(this._PlayerState.OnGround)
            {
               this.UpdateSimpleGroundMovement(false);
            }
            _loc5_++;
         }
      }
      
      private function UpdateObjectImpacts() : void
      {
         var _loc2_:Boolean = false;
         var _loc3_:MovieClip = null;
         var _loc6_:b2Vec2 = null;
         var _loc7_:b2Vec2 = null;
         var _loc8_:int = 0;
         if(this._PlayerState.Knockdowned)
         {
            if(this._PlayerState.HP > 0)
            {
               if(this._PlayerState.OnGround)
               {
                  this.b = this.GetDynamicBodyAt(this.MidPosX(),this.MidPosY() - 4,false);
                  if(this.b == null)
                  {
                     this.b = this.GetDynamicBodyAt(this.MidPosX(),this.MidPosY() - 8,false);
                  }
                  if(this.b == null)
                  {
                     this.b = this.GetDynamicBodyAt(this.MidPosX(),this.MidPosY() - 12,false);
                  }
                  if(this.b != null)
                  {
                     if(this.b.GetLinearVelocity().Length() < 0.5)
                     {
                        if(Boolean(this.b.GetUserData().objectData.CanGibb) && Boolean(this.b.IsSleeping()) || !this.b.GetUserData().objectData.CanGibb)
                        {
                           _loc6_ = new b2Vec2(this._PlayerState.LastDirX * this.b.GetMass(),-this.b.GetMass());
                           _loc7_ = new b2Vec2(this.MidPosX(),this.MidPosY() - 8);
                           _loc7_.x /= 30;
                           _loc7_.y /= 30;
                           this.b.ApplyImpulse(_loc6_,_loc7_);
                           this.b.GetUserData().objectData.Damage_Impact(1);
                        }
                     }
                  }
               }
            }
            return;
         }
         this.objectImpactList = new Array();
         var _loc1_:int = 0;
         while(_loc1_ < this.m_world.DynamicHitBoxObjectList.length)
         {
            this.b = this.m_world.DynamicHitBoxObjectList[_loc1_];
            if(this._standingOnObject != this.b)
            {
               if(this.b.GetUserData().objectData.CanKnockDownPlayer)
               {
                  if(this.b.GetUserData().objectData.CollisionMC.hitTestObject(this.CollisionMC))
                  {
                     this.objectImpactList.push([this.b,0,0]);
                  }
               }
            }
            _loc1_++;
         }
         if(this.objectImpactList.length <= 0)
         {
            return;
         }
         var _loc4_:int = 0;
         while(_loc4_ < this.objectImpactList.length)
         {
            _loc2_ = false;
            _loc3_ = this.objectImpactList[_loc4_][0].GetUserData().objectData.CollisionMC;
            _loc8_ = 0;
            while(_loc8_ <= this._PlayerState.PlayerHeight)
            {
               if(_loc3_.hitTestPoint(this._this_x - 5,this._this_y - _loc8_,true))
               {
                  _loc2_ = true;
                  this.objectImpactList[_loc4_][1] = this._this_x - 4;
                  this.objectImpactList[_loc4_][2] = this._this_y - _loc8_;
                  break;
               }
               if(_loc3_.hitTestPoint(this._this_x + 5,this._this_y - _loc8_,true))
               {
                  _loc2_ = true;
                  this.objectImpactList[_loc4_][1] = this._this_x + 4;
                  this.objectImpactList[_loc4_][2] = this._this_y - _loc8_;
                  break;
               }
               _loc8_ += 2;
            }
            if(!_loc2_)
            {
               if(_loc3_.hitTestPoint(this._this_x,this._this_y,true))
               {
                  this.objectImpactList[_loc4_][1] = this._this_x;
                  this.objectImpactList[_loc4_][2] = this._this_y;
               }
               else if(_loc3_.hitTestPoint(this._this_x,this._this_y - this._PlayerState.PlayerHeight,true))
               {
                  this.objectImpactList[_loc4_][1] = this._this_x;
                  this.objectImpactList[_loc4_][2] = this._this_y - this._PlayerState.PlayerHeight;
               }
               else
               {
                  this.objectImpactList.splice(_loc4_,1);
               }
            }
            _loc4_++;
         }
         if(this.objectImpactList.length <= 0)
         {
            return;
         }
         var _loc5_:int = 0;
         while(_loc5_ < this.objectImpactList.length)
         {
            this.CheckCollisionWithBody(this.objectImpactList[_loc5_]);
            _loc5_++;
         }
      }
      
      private function CheckCollisionWithBody(param1:Array) : void
      {
         var _loc14_:Boolean = false;
         var _loc15_:Boolean = false;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc18_:Number = NaN;
         var _loc19_:b2Vec2 = null;
         var _loc20_:int = 0;
         var _loc21_:Number = NaN;
         var _loc22_:Number = NaN;
         var _loc23_:Number = NaN;
         var _loc24_:b2Vec2 = null;
         var _loc25_:Number = NaN;
         var _loc2_:b2Body = param1[0];
         if(_loc2_.GetLinearVelocity().Length() < 2)
         {
            return;
         }
         var _loc3_:Number = _loc2_.GetLinearVelocity().Length();
         var _loc4_:Number = Number(param1[1]);
         var _loc5_:Number = Number(param1[2]);
         var _loc6_:Boolean = false;
         var _loc7_:b2Vec2 = new b2Vec2(_loc4_ / 30,_loc5_ / 30);
         var _loc8_:b2Vec2 = _loc2_.GetLinearVelocityFromWorldPoint(_loc7_);
         var _loc9_:b2Vec2 = new b2Vec2(this._PlayerState.AirVelocityX,this._PlayerState.AirVelocityY);
         var _loc10_:b2Vec2 = new b2Vec2(_loc8_.x,_loc8_.y);
         var _loc11_:b2Vec2 = new b2Vec2(_loc9_.x,_loc9_.y);
         var _loc12_:Number = _loc2_.GetMass();
         var _loc13_:Number = Number(this._PlayerState.Mass);
         if(_loc5_ < this._this_y - 1)
         {
            _loc14_ = Boolean(this.CheckCollisionTowardsPlayer(_loc4_,this.MidPosX(),this.ConvertToDirection(_loc8_.x)));
            _loc15_ = Boolean(this.CheckCollisionTowardsPlayer(_loc5_,this.MidPosY(),this.ConvertToDirection(_loc8_.y)));
            if(_loc14_ && _loc15_)
            {
               _loc10_.y = (_loc8_.y * (_loc12_ - _loc13_) + 2 * _loc13_ * _loc9_.y) / (_loc12_ + _loc13_);
               _loc11_.y = (_loc9_.y * (_loc13_ - _loc12_) + 2 * _loc12_ * _loc8_.y) / (_loc12_ + _loc13_);
               if(Boolean(this._PlayerState.OnGround) && !this._PlayerState.Knockdowned)
               {
                  if(_loc2_.GetUserData().objectData.CrushDamage > 0)
                  {
                     if((_loc14_ || _loc8_.x == 0) && _loc15_)
                     {
                        this._PlayerState.HP -= _loc2_.GetUserData().objectData.CrushDamage;
                        _loc10_.y = -2;
                        _loc6_ = true;
                        if(this._PlayerState.HP <= 0)
                        {
                           this.Fall(false);
                        }
                     }
                  }
                  else
                  {
                     _loc6_ = true;
                  }
                  if(_loc10_.x > -1 && _loc10_.x < 1)
                  {
                     _loc10_.x = this.ConvertToDirection(_loc10_.x);
                     if(_loc10_.x == 0)
                     {
                        _loc10_.x = this.ConvertToDirection(_loc4_ - this.MidPosX());
                     }
                  }
               }
               else if(!_loc2_.GetUserData().objectData.CanGibb)
               {
                  _loc6_ = true;
               }
            }
         }
         else if(_loc14_ || _loc15_)
         {
            if(Boolean(this._PlayerState.OnGround) && !this._PlayerState.Knockdowned)
            {
               if(_loc2_.GetUserData().objectData.CrushDamage > 0)
               {
                  if((_loc14_ || _loc8_.x == 0) && _loc15_)
                  {
                     _loc11_.y = (_loc9_.y * (_loc13_ - _loc12_) + 2 * _loc12_ * _loc8_.y) / (_loc12_ + _loc13_);
                     this._PlayerState.HP -= _loc2_.GetUserData().objectData.CrushDamage;
                     _loc10_.y = -2;
                     _loc6_ = true;
                     if(this._PlayerState.HP <= 0)
                     {
                        this.Fall(false);
                     }
                  }
               }
            }
         }
         if(_loc6_)
         {
            if(!_loc2_.GetUserData().objectData.CanGibb)
            {
               _loc20_ = 0;
               _loc21_ = _loc2_.m_linearVelocity.x / _loc2_.m_linearVelocity.Length() / 30;
               _loc22_ = _loc2_.m_linearVelocity.y / _loc2_.m_linearVelocity.Length() / 30;
               while(_loc20_ < 0 && Boolean(_loc2_.m_userData.objectData.CollisionMC.hitTestPoint(_loc4_,_loc5_,true)))
               {
                  _loc2_.SetXForm(new b2Vec2(_loc2_.GetPosition().x - _loc21_,_loc2_.GetPosition().y - _loc22_),_loc2_.GetAngle());
                  _loc2_.m_userData.objectData.ShapeMC.x = _loc2_.GetPosition().x * 30;
                  _loc2_.m_userData.objectData.ShapeMC.y = _loc2_.GetPosition().y * 30;
                  _loc2_.m_userData.objectData.ShapeMC.rotation = _loc2_.GetAngle() * (180 / Math.PI);
                  _loc2_.m_userData.objectData.CollisionMC.x = _loc2_.m_userData.objectData.ShapeMC.x;
                  _loc2_.m_userData.objectData.CollisionMC.y = _loc2_.m_userData.objectData.ShapeMC.y;
                  _loc2_.m_userData.objectData.CollisionMC.rotation = _loc2_.m_userData.objectData.ShapeMC.rotation;
                  _loc20_ += 1;
               }
            }
            this.UpdateSides();
            _loc2_.SetLinearVelocity(_loc10_);
            _loc16_ = _loc4_ - this.MidPosX();
            _loc17_ = _loc5_ - this.MidPosY();
            _loc18_ = Math.atan2(_loc17_,_loc16_);
            _loc19_ = new b2Vec2(Math.cos(_loc18_) * 2,Math.sin(_loc18_) * 4);
            if(_loc2_.GetUserData().objectData.CanGibb)
            {
               _loc19_ = new b2Vec2(Math.cos(_loc18_) * 0.5,Math.sin(_loc18_) * 1);
            }
            _loc2_.ApplyImpulse(_loc19_,_loc7_);
            this._Handler_Sounds.PlaySoundAt("MELEE_HIT",this._this_x,this._this_y);
            this._PlayerState.AirVelocityX = _loc11_.x;
            this._PlayerState.AirVelocityY = _loc11_.y;
            if(this._PlayerState.AirVelocityY > -2)
            {
               this._PlayerState.AirVelocityY = -2;
            }
            if(_loc4_ < this.MidPosX())
            {
               if(_loc2_.GetLinearVelocity().x > this._PlayerState.AirVelocityX)
               {
                  this._PlayerState.AirVelocityX = _loc2_.GetLinearVelocity().x + 1;
               }
            }
            else if(_loc2_.GetLinearVelocity().x < this._PlayerState.AirVelocityX)
            {
               this._PlayerState.AirVelocityX = _loc2_.GetLinearVelocity().x - 1;
            }
            this._this_y -= 0.5;
            this.Fall();
            _loc2_.GetUserData().objectData.Damage_Impact(5);
            if(_loc2_.GetLinearVelocity().Length() > _loc3_)
            {
               _loc23_ = _loc3_ / _loc2_.GetLinearVelocity().Length();
               _loc24_ = _loc2_.GetLinearVelocity();
               _loc24_.x *= _loc23_ * 0.8;
               _loc24_.y *= _loc23_ * 0.8;
               _loc2_.SetLinearVelocity(_loc24_);
            }
            if(this._PlayerState.TotalAirVelocity > _loc3_)
            {
               _loc25_ = _loc3_ / this._PlayerState.TotalAirVelocity;
               this._PlayerState.AirVelocityX *= _loc25_;
               this._PlayerState.AirVelocityY *= _loc25_;
            }
         }
      }
      
      public function UpdatePositionToProjectile() : void
      {
         this._this_x = this._PlayerState.RocketRideProjectile.PosX;
         this._this_y = this._PlayerState.RocketRideProjectile.PosY;
         this.x = this._this_x;
         this.y = this._this_y;
         this._collision_mc.x = this._this_x;
         this._collision_mc.y = this._this_y;
         this._player_area_mc.x = this._this_x;
         this._player_area_mc.y = this._this_y;
      }
      
      public function StuckToProjectile(param1:ProjectileData) : void
      {
         if(!this._PlayerState.StuckToRocket)
         {
            this.DropGrabbedPlayer();
            this.Disarm();
            this.CancelAFS();
            this._PlayerState.StuckToRocket = true;
            this._PlayerState.BurnState = 0;
         }
         this._PlayerState.LastDirX = 1;
         this.scaleX = 1;
         this._collision_mc.scaleX = 1;
         this._PlayerState.RocketRideTimer = 0;
         this._PlayerState.RocketRideProjectile = param1;
         this._Handler_Slowmo.AddSlowmotion(new SlowmoData(0,12,6,0.01));
      }
      
      public function RocketWillHit() : Boolean
      {
         if(this._PlayerState.IsImmune)
         {
            return false;
         }
         if(Boolean(this._PlayerState.Rolling) || Boolean(this._PlayerState.Diving))
         {
            if(Math.random() < 0.5)
            {
               return false;
            }
         }
         return true;
      }
      
      public function BulletWillHit() : Boolean
      {
         if(this._PlayerState.IsImmune)
         {
            return false;
         }
         if(Boolean(this._PlayerState.Rolling) || Boolean(this._PlayerState.Diving))
         {
            if(Math.random() < 0.9)
            {
               return false;
            }
         }
         return true;
      }
      
      public function BulletDamage(param1:ProjectileData) : void
      {
         var _loc4_:int = 0;
         if(this._PlayerState.IsImmune)
         {
            return;
         }
         if(this._PlayerState.DeathKneel)
         {
            return;
         }
         var _loc2_:Boolean = false;
         if(this._PlayerState.HP <= 0)
         {
            _loc2_ = true;
         }
         var _loc3_:Boolean = false;
         if(Math.random() * 100 <= param1.Properties.CriticalChance)
         {
            _loc3_ = true;
         }
         if(this._PlayerState.StuckToRocket)
         {
            if(_loc3_)
            {
               this._PlayerState.RocketRideProjectile.Explode();
               if(this.ActivateSlowmotion(this.PlayerNr))
               {
                  this._Handler_Slowmo.AddSlowmotion(new SlowmoData(0,24 * 2,24 * 1,0.2));
               }
            }
            return;
         }
         this._PlayerState.CurrentPushbackPower += param1.Properties.PushbackPower;
         if(_loc3_)
         {
            this._PlayerState.HP -= param1.Properties.CriticalDamage;
         }
         else
         {
            this._PlayerState.HP -= param1.Properties.Damage;
         }
         if(this._PlayerState.GrabbedByPlayer)
         {
            return;
         }
         if(_loc3_ || !_loc2_ && this._PlayerState.HP <= 0 || this._PlayerState.CurrentPushbackPower >= 100)
         {
            this._PlayerState.CritSmokeTimer = 36;
            this._Handler_Effects.AddEffectAt("HITDEFAULT_01",param1.PosX,param1.PosY);
            if(this._PlayerState.OnGround)
            {
               --this._this_y;
            }
            if(this._PlayerState.HP > 0 || _loc2_)
            {
               this._PlayerState.AirVelocityX += param1.DirectionX * 2;
               this._PlayerState.AirVelocityY = -2;
            }
            else if(Boolean(this._PlayerState.OnGround) && Math.random() < 0.5)
            {
               this._PlayerState.AirVelocityX = this._PlayerState.LastDirX * this._PlayerState.RunSpeed;
               this._PlayerState.AirVelocityY = -2;
            }
            else
            {
               this._PlayerState.AirVelocityX += param1.DirectionX * 2;
               this._PlayerState.AirVelocityY = -2;
            }
            this._PlayerState.LastDirX = -this.ConvertToDirection(param1.DirectionX);
            if(this._PlayerState.LastDirX == 0)
            {
               this._PlayerState.LastDirX = 1;
            }
            this._PlayerState.CurrentPushbackPower = 0;
            this.scaleX = this._PlayerState.LastDirX;
            this._collision_mc.scaleX = this.scaleX;
            if(this._PlayerState.HP <= 0)
            {
               this.Disarm();
               if(!_loc2_ && Boolean(this._PlayerState.OnGround) && !this._PlayerState.Knockdowned || Boolean(this._PlayerState.Staggering))
               {
                  _loc4_ = int(this.EdgeStaggerDistance());
                  if(_loc4_ > 6)
                  {
                     this.StartStagger();
                     this._PlayerState.StaggerTimer = _loc4_ - 4;
                  }
                  else if(this.DetectEdge(this._PlayerState.LastDirX))
                  {
                     this._PlayerState.DeathKneel = true;
                     this._PlayerState.CameraIgnoreTimer = 3 * 24;
                  }
                  else
                  {
                     if(Math.random() < 0.5)
                     {
                        this.Fall(false);
                     }
                     else if(Math.random() < 0.5)
                     {
                        this.StartStagger();
                     }
                     else
                     {
                        this._PlayerState.DeathKneel = true;
                        this._PlayerState.CameraIgnoreTimer = 3 * 24;
                     }
                     this._Handler_Shake.Add(2,2);
                  }
               }
               else
               {
                  this.Fall(false);
                  this._Handler_Shake.Add(2,2);
               }
            }
            else if(Math.random() < 0.25 || Boolean(this._PlayerState.Knockdowned))
            {
               this.Fall(false);
               this._Handler_Shake.Add(2,2);
            }
            else
            {
               this.StartStagger();
            }
         }
         if(!_loc2_ && this._PlayerState.HP <= 0)
         {
            if(this.ActivateSlowmotion(this.PlayerNr))
            {
               this._Handler_Slowmo.AddSlowmotion(new SlowmoData(0,24 * 2,24 * 1,0.2));
            }
            if(Boolean(this._PlayerState.OnGround) && !this._PlayerState.Staggering && !this._PlayerState.DeathKneel)
            {
               this.Fall(false);
            }
         }
      }
      
      public function StartStagger(param1:int = 0) : void
      {
         if(this._PlayerState.Aiming)
         {
            if(this._PlayerState.AimMode == 1)
            {
               this.DropThrowable();
            }
         }
         this._PlayerState.CurrentFireFrame = 0;
         this._PlayerState.LastFireFrame = 0;
         if(param1 != 0)
         {
            this._PlayerState.LastDirX = param1;
         }
         this.scaleX = this._PlayerState.LastDirX;
         this._collision_mc.scaleX = this.scaleX;
         if(Boolean(this._PlayerState.OnGround) && Boolean(this.CanStagger()))
         {
            this._PlayerState.Staggering = true;
            if(this._PlayerState.StaggerTimer < 6)
            {
               this._PlayerState.StaggerTimer = 6 + Math.random() * 8;
            }
         }
         else
         {
            this.Fall(false);
         }
      }
      
      private function EdgeStaggerDistance() : int
      {
         var _loc3_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Boolean = false;
         var _loc7_:Number = NaN;
         var _loc8_:Boolean = false;
         var _loc1_:int = 0;
         var _loc2_:Number = Number(this._this_y);
         var _loc4_:Number = 0;
         while(_loc4_ <= 36)
         {
            _loc1_ = this._this_x - this._PlayerState.LastDirX * this._PlayerState.StaggerSpeed * _loc4_;
            _loc5_ = 4;
            while(_loc5_ < 12)
            {
               _loc3_ = _loc2_ - _loc5_;
               if(this._static_world_hitbox_mc.hitTestPoint(_loc1_,_loc3_,true))
               {
                  if(this.m_world.GetGlassAt(_loc1_,_loc3_) == null)
                  {
                     return 0;
                  }
               }
               _loc5_ += 2;
            }
            _loc6_ = true;
            _loc7_ = -2;
            while(_loc7_ <= 10)
            {
               _loc3_ = _loc2_ + _loc7_;
               _loc8_ = Boolean(this._static_world_cloud_hitbox_mc.hitTestPoint(_loc1_,_loc3_,true));
               if(Boolean(this._static_world_hitbox_mc.hitTestPoint(_loc1_,_loc3_,true)) || _loc8_)
               {
                  if(Boolean(this.HitTestWorldOnly(_loc1_,_loc3_)) || this.m_world.GetGlassAt(_loc1_,_loc3_) == null || _loc8_)
                  {
                     _loc2_ = _loc3_;
                     _loc6_ = false;
                     _loc7_ = 12;
                  }
               }
               _loc7_ += 1;
            }
            if(_loc6_)
            {
               this._Handler_Output.Trace("Edge Found: " + _loc4_);
               return _loc4_;
            }
            _loc4_ += 2;
         }
         return 0;
      }
      
      private function UpdateGroundMovement() : void
      {
         if(this.CollisionFeetBothSides())
         {
            if(this.CollisionFeetMid())
            {
               this._this_y -= 0.1;
            }
         }
         this.UpdateSides();
         if(!this._PlayerState.Knockdowned && !this._PlayerState.Falling)
         {
            if(this.CheckForceKnockdown())
            {
               this.Fall();
               this._PlayerState.Falling = false;
               this._PlayerState.Knockdowned = true;
               this._PlayerState.CantRise = true;
               this._PlayerAnimation.ShowAnimation("knockdown",true);
               if(this.CheckGibPlayer())
               {
                  return;
               }
            }
            else if(this.CheckForceKneeling())
            {
               this._PlayerState.Kneeling = true;
            }
         }
         else if(this._PlayerState.CantRise)
         {
            if(!this.CheckForceKnockdown())
            {
               this._PlayerState.CantRise = false;
            }
            else if(this.CheckGibPlayer())
            {
               return;
            }
         }
         else if(this.CheckForceKnockdown())
         {
            if(this.CheckForceKnockdown())
            {
               this._PlayerState.CantRise = true;
               if(this.CheckGibPlayer())
               {
                  return;
               }
            }
         }
         this.UpdateSimpleGroundMovement(true);
      }
      
      private function UpdateSimpleGroundMovement(param1:Boolean) : void
      {
         var _loc2_:int = 0;
         if(this.CollisionFeetMid(0,1))
         {
            if(this.CollisionFeetMid(-1,1))
            {
               _loc2_ = 0;
               while(Boolean(this.CollisionFeetMid(-1,1)) && !this.WorldCollisionHead() && _loc2_ < 100)
               {
                  this._this_y -= 0.1;
                  _loc2_ += 1;
               }
               if(_loc2_ > 0)
               {
                  this._this_y += 0.1;
               }
            }
            if(param1)
            {
               this.UpdateDynamicMovement();
            }
         }
         else if(this.CanLandInMid())
         {
            if(this._PlayerState.OnGround)
            {
               while(!this.CollisionFeetMid())
               {
                  this._this_y += 0.1;
               }
               if(param1)
               {
                  this.UpdateDynamicMovement();
               }
            }
         }
         else if(this.CollisionFeetSides())
         {
            if(param1)
            {
               this.UpdateDynamicMovement();
            }
            if(!this.CollisionFeetSides())
            {
               if(this._PlayerState.Staggering)
               {
                  this.Fall(false);
               }
               else
               {
                  this._PlayerState.Jumping = true;
               }
            }
         }
         else
         {
            this.CheckAimDrop();
            if(this._PlayerState.Staggering)
            {
               this.Fall(false);
            }
            else
            {
               if(this._standingOnObject != null)
               {
                  if(this._standingOnObject.GetUserData().objectData.IsElevator)
                  {
                     this.UpdateDynamicMovement();
                     return;
                  }
               }
               this._PlayerState.Jumping = true;
            }
         }
      }
      
      private function UpdateAirMovement() : void
      {
         var _loc7_:Number = NaN;
         var _loc8_:Boolean = false;
         var _loc9_:int = 0;
         var _loc10_:b2Vec2 = null;
         var _loc11_:b2Vec2 = null;
         var _loc12_:Boolean = false;
         var _loc13_:b2Vec2 = null;
         var _loc14_:b2Vec2 = null;
         var _loc15_:Number = NaN;
         if(this._PlayerState.AirVelocityY == 0)
         {
            this._PlayerState.AirVelocityY = 0.1;
         }
         if(this._this_y > this._jumpDownPosYDisable)
         {
            this._performJumpDownLevel = false;
         }
         if(this._PlayerState.Climbing)
         {
            if(Boolean(this._keyPressed[1]) && !this._keyPressed[0])
            {
               this._PlayerState.AirVelocityY = this._PlayerState.SlideSpeed;
               this._PlayerState.AirVelocityX = 0;
               if(this._PlayerState.CurrentLadder == null)
               {
                  this._PlayerState.CurrentLadder = this.m_world.GetLadderBodyAt(this.MidPosX(),this.MidPosY());
               }
               if(this._PlayerState.CurrentLadder != null)
               {
                  this._PlayerState.DisableKneel = true;
                  this._this_x = this._PlayerState.CurrentLadder.GetPosition().x * 30;
               }
               this.LadderSliding();
            }
            else
            {
               if(this._keyPressed[0])
               {
                  this._PlayerState.AirVelocityY = -this._PlayerState.ClimbSpeed;
               }
               else
               {
                  this._PlayerState.AirVelocityY = 0;
               }
               if(this.PressingLeft())
               {
                  this._PlayerState.AirVelocityX = -this._PlayerState.ClimbSpeed;
                  this.scaleX = -1;
                  this._collision_mc.scaleX = this.scaleX;
                  this._PlayerState.LastDirX = -1;
               }
               else if(this.PressingRight())
               {
                  this._PlayerState.AirVelocityX = this._PlayerState.ClimbSpeed;
                  this.scaleX = 1;
                  this._collision_mc.scaleX = this.scaleX;
                  this._PlayerState.LastDirX = 1;
               }
               else
               {
                  this._PlayerState.AirVelocityX = 0;
               }
            }
         }
         else if(!this._PlayerState.Knockdowned && this._PlayerState.HP <= 0)
         {
            this.Fall(false);
         }
         var _loc1_:Number = Math.ceil(this._PlayerState.TotalAirVelocity);
         if(_loc1_ <= 1)
         {
            _loc1_ = 1;
         }
         var _loc2_:Number = this._PlayerState.AirVelocityY * this._game_speed;
         var _loc3_:Number = this._PlayerState.AirVelocityX * this._game_speed;
         if(this._PlayerState.ControllAble)
         {
            if(this.PressingLeft())
            {
               this.TurnLeft();
            }
            else if(this.PressingRight())
            {
               this.TurnRight();
            }
         }
         var _loc4_:Number = Number(this._this_x);
         var _loc5_:Number = Number(this._this_y);
         var _loc6_:int = 1;
         while(_loc6_ <= _loc1_)
         {
            _loc4_ = Number(this._this_x);
            _loc5_ = Number(this._this_y);
            this._this_x += _loc3_ / _loc1_;
            this._this_y += _loc2_ / _loc1_;
            if(this.PlayerOutsideLevel())
            {
               this.IgnorePlayer();
               return;
            }
            if(this._PlayerState.Climbing)
            {
               if(!this._static_ladder_hitbox_mc.hitTestPoint(this.MidPosX(),this.MidPosY(),true))
               {
                  if(_loc2_ < 0)
                  {
                     this._this_y = _loc5_;
                     if(!this._static_ladder_hitbox_mc.hitTestPoint(this.MidPosX(),this.MidPosY(),true))
                     {
                        this._PlayerState.Climbing = false;
                        this._PlayerState.AirVelocityX = 0;
                     }
                     else
                     {
                        this._PlayerState.AirVelocityY = 0;
                     }
                  }
                  else
                  {
                     this._PlayerState.Climbing = false;
                     this._PlayerState.AirVelocityX = 0;
                  }
               }
               else if(_loc2_ > 0)
               {
                  this._PlayerState.NextLadderEffect -= _loc2_;
                  if(this._PlayerState.NextLadderEffect <= 0)
                  {
                     if(this._PlayerState.LadderEffectRightSide)
                     {
                        _loc7_ = 1;
                     }
                     else
                     {
                        _loc7_ = -1;
                     }
                     if(Math.random() * 10 < 5)
                     {
                        this._Handler_Effects.AddParticle(new particle_data("METAL",this.PosX() + 6 * _loc7_,this.PosY() - 16,new b2Vec2(Math.random() * _loc7_ * 0.5,-Math.random() * 0.5)));
                     }
                     else
                     {
                        this._Handler_Effects.AddParticle(new particle_data("METAL",this.PosX() + 6 * _loc7_,this.PosY(),new b2Vec2(Math.random() * _loc7_ * 0.5,Math.random() * 0.5)));
                     }
                     this._PlayerState.LadderEffectRightSide = !this._PlayerState.LadderEffectRightSide;
                     this._PlayerState.NextLadderEffect = 14 + Math.random() * 4;
                  }
               }
            }
            if(this._PlayerState.Falling)
            {
               if(this.CollisionSide(_loc3_))
               {
                  _loc8_ = false;
                  _loc9_ = int(this.ConvertToDirection(this._PlayerState.AirVelocityX));
                  this.b = this.GetDynamicBodyAt(this.MidPosX() + (this._PlayerState.PlayerEdgeDistance + 2) * _loc9_,this.MidPosY(),false);
                  if(this.b != null)
                  {
                     _loc10_ = new b2Vec2(this._PlayerState.LastDirX,0);
                     _loc11_ = new b2Vec2(this.MidPosX() + (this._PlayerState.PlayerEdgeDistance + 2) * _loc9_,this.MidPosY());
                     _loc11_.x /= 30;
                     _loc11_.y /= 30;
                     this.b.ApplyImpulse(_loc10_,_loc11_);
                     if(this.b.GetUserData().objectData.PlayerFragile)
                     {
                        _loc8_ = true;
                        this.b.GetUserData().objectData.ForceDestruction();
                        this._PlayerState.AirVelocityX *= 0.6;
                        return;
                     }
                     this.b.GetUserData().objectData.Damage_Impact(2);
                  }
                  this._Handler_Sounds.PlaySoundAt("MELEE_HIT",this._this_x,this._this_y);
                  this._this_x = _loc4_;
                  if(this.CanLandInMid())
                  {
                     this._PlayerState.AirVelocityX = 0;
                  }
                  else if(!this.CollisionHead())
                  {
                     this._PlayerState.AirVelocityX = -this._PlayerState.AirVelocityX * 0.5;
                     this._PlayerState.AirVelocityY = -Math.abs(this._PlayerState.AirVelocityY) * 0.7;
                     if(Math.abs(this._PlayerState.AirVelocityX) > 2)
                     {
                        this._PlayerState.AirVelocityX = -_loc9_ * 2;
                     }
                     if(this._PlayerState.AirVelocityY < -2.5)
                     {
                        this._PlayerState.AirVelocityY = -2.5;
                     }
                     return;
                  }
               }
            }
            else
            {
               _loc12_ = false;
               if(this.CollisionSide(_loc3_))
               {
                  if(this._PlayerState.Diving)
                  {
                     this.b = this.GetDynamicBodyAt(this.MidPosX() + 6 * this._PlayerState.LastDirX,this.MidPosY(),false);
                     if(this.b != null)
                     {
                        _loc13_ = new b2Vec2(this._PlayerState.LastDirX,0);
                        _loc14_ = new b2Vec2(this.MidPosX() + 6 * this._PlayerState.LastDirX,this.MidPosY());
                        _loc14_.x /= 30;
                        _loc14_.y /= 30;
                        this.b.ApplyImpulse(_loc13_,_loc14_);
                        this.b.GetUserData().objectData.Damage_Impact(2);
                        if(this.b.GetUserData().objectData.HP > 0)
                        {
                           _loc12_ = true;
                           this._PlayerState.Diving = false;
                           this._PlayerState.Sprinting = false;
                           this._PlayerState.AirVelocityY = 0;
                           this._PlayerState.AirVelocityX = 0;
                           _loc3_ = 0;
                        }
                     }
                     else
                     {
                        _loc12_ = true;
                        this._PlayerState.Diving = false;
                        this._PlayerState.Sprinting = false;
                        this._PlayerState.AirVelocityY = 0;
                        this._PlayerState.AirVelocityX = 0;
                        _loc3_ = 0;
                     }
                  }
                  else
                  {
                     this._PlayerState.AirVelocityX = 0;
                     _loc3_ = 0;
                  }
               }
               this.UpdateSides(false);
               if(_loc12_)
               {
                  this.DropGrabbedPlayer();
               }
            }
            if(this._PlayerState.Diving)
            {
               this.CheckDivePlayerImpact();
            }
            if(_loc2_ > 0)
            {
               if(!this._PlayerState.Climbing)
               {
                  if(!this._PlayerState.Falling && !this._PlayerState.Diving)
                  {
                     if(this._PlayerState.AirVelocityY >= this._PlayerState.FallTriggerSpeed)
                     {
                        if(this._PlayerState.MovingDirectionInversed != 0)
                        {
                           if(Boolean(this._keyPressed[2]) && !this.CollisionSide(1,this._PlayerState.PlayerEdgeDistance + 1))
                           {
                              this._PlayerState.AirVelocityX += this._PlayerState.RunSpeed * 0.8;
                           }
                           if(Boolean(this._keyPressed[3]) && !this.CollisionSide(-1,this._PlayerState.PlayerEdgeDistance + 1))
                           {
                              this._PlayerState.AirVelocityX -= this._PlayerState.RunSpeed * 0.8;
                           }
                        }
                        else
                        {
                           if(Boolean(this._keyPressed[2]) && !this.CollisionSide(-1,this._PlayerState.PlayerEdgeDistance + 1))
                           {
                              this._PlayerState.AirVelocityX -= this._PlayerState.RunSpeed * 0.8;
                           }
                           if(Boolean(this._keyPressed[3]) && !this.CollisionSide(1,this._PlayerState.PlayerEdgeDistance + 1))
                           {
                              this._PlayerState.AirVelocityX += this._PlayerState.RunSpeed * 0.8;
                           }
                        }
                        this._PlayerState.Falling = true;
                     }
                  }
               }
               if(this.CollisionHead())
               {
                  this.CheckObjectHeadImpactSpeeds();
               }
               if(this.CollisionFeetSides())
               {
                  if(this.CanLandInMid())
                  {
                     if(this.CollisionFeetMid())
                     {
                        this.PlayerLands();
                        return;
                     }
                  }
                  else if(!this.CollisionFeetSides(-2))
                  {
                     if(this.CollisionFeetSides(1,this._PlayerState.PlayerEdgeDistance - 1))
                     {
                        this.PlayerLands();
                        return;
                     }
                  }
                  else
                  {
                     if(this.CollisionFeetBothSides())
                     {
                        this.PlayerLands();
                        return;
                     }
                     this.UpdateSides();
                  }
               }
            }
            else if(_loc2_ < 0)
            {
               if(Boolean(this.CollisionHead()) || Boolean(this.WorldCollisionHead()))
               {
                  _loc15_ = Number(this._PlayerState.AirVelocityY);
                  this._this_y = _loc5_;
                  this._PlayerState.AirVelocityY = 0;
                  this.CheckObjectHeadImpactSpeeds();
                  this.CheckHeadToObjectImpacts(Math.abs(_loc15_) * 0.1);
                  return;
               }
               if(this._PlayerState.AirVelocityY != this._PlayerState.PlayerJumpPower)
               {
                  if(this.CollisionFeetSides())
                  {
                     if(this.CanLandInMid())
                     {
                        if(this.CollisionFeetMidUp(-2,0))
                        {
                           this.PlayerLands();
                           return;
                        }
                     }
                  }
               }
            }
            this.UpdateGrabbedPlayer();
            this.UpdatePlayerFallingOnPlayer();
            if(!this._PlayerState.Climbing)
            {
               this._PlayerState.AirVelocityY += this._PlayerState.PlayerGravity * this._game_speed / _loc1_;
               _loc3_ = this._PlayerState.AirVelocityX * this._game_speed;
               _loc2_ = this._PlayerState.AirVelocityY * this._game_speed;
            }
            _loc6_++;
         }
      }
      
      private function LadderJump() : void
      {
         if(!this._static_ladder_hitbox_mc.hitTestPoint(this.MidPosX(),this.MidPosY() - 1,true))
         {
            this._PlayerState.Climbing = false;
            --this._this_y;
            this.BeginJump();
         }
      }
      
      public function LadderKnockdown(param1:int) : *
      {
         if(param1 == 0)
         {
            if(Math.random() * 10 < 5)
            {
               param1 = 1;
            }
            else
            {
               param1 = -1;
            }
         }
         this._PlayerState.AirVelocityX = param1;
         this._PlayerState.AirVelocityY = -1;
         this.Fall();
      }
      
      private function LadderSliding() : void
      {
         var _loc1_:* = 0;
         while(_loc1_ < this._players.length)
         {
            if(_loc1_ != this.PlayerNr)
            {
               if(this._players[_loc1_].State.Climbing)
               {
                  if(this._players[_loc1_].PosY() > this.PosY())
                  {
                     if(this.hitTestObject(this._players[_loc1_].MC))
                     {
                        this._players[_loc1_].LadderKnockdown(this.ConvertToDirection(this._players[_loc1_].PosX() - this.PosX()));
                     }
                  }
               }
            }
            _loc1_++;
         }
      }
      
      private function CheckGibPlayer() : Boolean
      {
         var _loc1_:* = 0;
         if(Boolean(this._PlayerState.OnGround) && Boolean(this._PlayerState.Knockdowned))
         {
            this.b = this.GetDynamicBodyAt(this._this_x,this._this_y - 6,false);
            if(this.b != null)
            {
               if(this.b.GetUserData().objectData.CanGibb)
               {
                  _loc1_ = 4;
                  while(_loc1_ >= 1)
                  {
                     if(Boolean(this._static_world_hitbox_mc.hitTestPoint(this._this_x,this._this_y + _loc1_,true)) || Boolean(this._static_world_cloud_hitbox_mc.hitTestPoint(this._this_x,this._this_y + _loc1_,true)))
                     {
                        if(!this.b.GetUserData().objectData.CollisionMC.hitTestPoint(this._this_x,this._this_y + _loc1_,true))
                        {
                           this.GibPlayer();
                           return true;
                        }
                     }
                     _loc1_--;
                  }
               }
            }
         }
         return false;
      }
      
      private function CheckHeadToObjectImpacts(param1:Number) : void
      {
         var _loc3_:b2Vec2 = null;
         var _loc2_:int = -this._PlayerState.PlayerEdgeDistance;
         while(_loc2_ <= this._PlayerState.PlayerEdgeDistance)
         {
            this.b = this.GetDynamicBodyAt(this._this_x + _loc2_,this._this_y - this._PlayerState.PlayerHeight - 2,false);
            if(this.b != null)
            {
               _loc3_ = new b2Vec2((this._this_x + _loc2_) / 30,(this._this_y - this._PlayerState.PlayerHeight - 2) / 30);
               this.b.ApplyImpulse(new b2Vec2(0,-param1),_loc3_);
            }
            _loc2_ += this._PlayerState.PlayerEdgeDistance;
         }
      }
      
      private function CheckObjectHeadImpactSpeeds() : void
      {
         var _loc1_:int = -this._PlayerState.PlayerEdgeDistance;
         while(_loc1_ <= this._PlayerState.PlayerEdgeDistance)
         {
            this.b = this.GetDynamicBodyAt(this._this_x + _loc1_,this._this_y - this._PlayerState.PlayerHeight,false);
            if(this.b != null)
            {
               if(this.b.GetUserData().objectData.CanKnockDownPlayer)
               {
                  if(this.b.GetLinearVelocity().y + 1 > this._PlayerState.AirVelocityY)
                  {
                     this._PlayerState.AirVelocityY = this.b.GetLinearVelocity().y + 1;
                     break;
                  }
               }
            }
            _loc1_ += this._PlayerState.PlayerEdgeDistance;
         }
      }
      
      private function UpdateStairBounce() : void
      {
         if(this._PlayerState.StairBounce)
         {
            this._PlayerState.AirVelocityX = this._PlayerState.StairVelocityX;
            this._PlayerState.AirVelocityY = this._PlayerState.StairVelocityY;
            this._Handler_Sounds.PlaySoundAt("STAIRBOUNCE",this._this_x,this._this_y);
            this._PlayerState.Knockdowned = false;
            this._PlayerState.Jumping = true;
            this._PlayerState.Falling = true;
            this._PlayerState.StairBounce = false;
            this._PlayerState.DecreaseBurnState();
            if(this._PlayerState.HP > 0)
            {
               this._PlayerState.HP -= this._PlayerState.StairBounceDamage;
               if(this._PlayerState.HP <= 0)
               {
                  if(this.ActivateSlowmotion(this.PlayerNr))
                  {
                     this._Handler_Slowmo.AddSlowmotion(new SlowmoData(0,24 * 2,24 * 1,0.2));
                  }
               }
            }
         }
      }
      
      private function BodyDust() : void
      {
         var _loc1_:int = -2;
         while(_loc1_ < 3)
         {
            this._Handler_Effects.AddEffectAt("BODYFALL",this._this_x + _loc1_ * 3,this._this_y);
            _loc1_++;
         }
      }
      
      private function SidewayBounce() : Boolean
      {
         var _loc1_:Number = NaN;
         if(Math.abs(this._PlayerState.AirVelocityX) >= 4 && Math.abs(this._PlayerState.AirVelocityX) > Math.abs(this._PlayerState.AirVelocityY))
         {
            this._Handler_Sounds.PlaySoundAt("BODYFALL",this._this_x,this._this_y);
            this.BodyDust();
            _loc1_ = Number(this._PlayerState.TotalAirVelocity);
            this._PlayerState.AirVelocityY = -_loc1_ * 0.3;
            this._PlayerState.AirVelocityX = _loc1_ * 0.5 * this.ConvertToDirection(this._PlayerState.AirVelocityX);
            this._PlayerState.LastDirX *= -1;
            if(this._PlayerState.AirVelocityY > -2)
            {
               this._PlayerState.AirVelocityY = -2;
            }
            return true;
         }
         return false;
      }
      
      private function PlayerLands() : void
      {
         var _loc1_:Number = NaN;
         var _loc2_:Boolean = false;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:Boolean = false;
         var _loc6_:Boolean = false;
         var _loc7_:int = 0;
         this._PlayerState.Climbing = false;
         this._performJumpDownLevel = false;
         if(this._PlayerState.Falling)
         {
            _loc1_ = Math.abs(this._PlayerState.AirVelocityY);
            _loc1_ -= 3;
            _loc1_ *= 1.5;
            if(_loc1_ < 3)
            {
               _loc1_ = 0;
            }
            _loc2_ = false;
            _loc3_ = 0;
            while(_loc3_ <= 2)
            {
               if(this.HitTestWorldOnly(this._this_x,this._this_y + _loc3_))
               {
                  _loc2_ = true;
                  break;
               }
               _loc3_++;
            }
            _loc4_ = 0;
            while(_loc4_ <= 6)
            {
               this.b = this.m_world.GetStairBodyAt(this._this_x,this._this_y + _loc4_);
               if(this.b != null)
               {
                  if(this.CanBounceAtDirection(this.ConvertToDirection(this.b.GetUserData().tiltValue)))
                  {
                     this._PlayerState.StairBounce = true;
                     this._PlayerState.LastDirX *= -1;
                     this._PlayerState.StairVelocityY *= -0.7;
                     if(this._PlayerState.StairVelocityY < -4)
                     {
                        this._PlayerState.StairVelocityY = -4;
                     }
                     else if(this._PlayerState.StairVelocityY > -1)
                     {
                        this._PlayerState.StairVelocityY = -1;
                     }
                     this._PlayerState.StairVelocityX = this.b.GetUserData().tiltValue;
                     this._Handler_Sounds.PlaySoundAt("BODYFALL",this._this_x,this._this_y);
                     this.BodyDust();
                     this._PlayerState.IncreaseKnockdownGrade();
                     this._lastBounceY = this._this_y;
                     return;
                  }
               }
               _loc4_++;
            }
            if(!_loc2_)
            {
               _loc5_ = false;
               _loc6_ = false;
               _loc7_ = -4;
               while(_loc7_ <= this._PlayerState.PlayerEdgeDistance)
               {
                  this.b = this.GetDynamicBodyAt(this._this_x + _loc7_,this._this_y + 2,false);
                  if(this.b != null)
                  {
                     if(this.b.GetUserData().objectData.PlayerFragile)
                     {
                        this.b.GetUserData().objectData.ForceDestruction();
                        this._PlayerState.AirVelocityY *= 0.6;
                        this._PlayerState.LastDirX *= -1;
                        _loc5_ = true;
                     }
                  }
                  _loc7_ += 2;
               }
            }
            if(!_loc6_ && !_loc5_)
            {
               _loc6_ = Boolean(this.SidewayBounce());
            }
            if(_loc1_ != 0)
            {
               this._PlayerState.HP -= _loc1_;
            }
            if(_loc6_)
            {
               this._PlayerState.DecreaseBurnState();
               this._lastBounceY = this._this_y;
               return;
            }
            if(_loc5_)
            {
               this._lastBounceY = this._this_y;
               return;
            }
            this._Handler_Sounds.PlaySoundAt("BODYFALL",this._this_x,this._this_y);
            this.BodyDust();
            this._PlayerState.IncreaseKnockdownGrade();
            this._PlayerState.Falling = false;
            this._PlayerState.Knockdowned = true;
            this.scaleX = this._PlayerState.LastDirX;
            this._collision_mc.scaleX = this.scaleX;
            this._PlayerState.DecreaseBurnState();
            if(this._PlayerState.HP <= 0)
            {
               this.CheckDeathBounce();
               this._lastBounceY = this._this_y;
            }
         }
         else if(this._PlayerState.Diving)
         {
            this.b = this.m_world.GetGlassAt(this._this_x,this._this_y);
            if(this.b == null)
            {
               this.b = this.m_world.GetGlassAt(this._this_x,this._this_y + 2);
            }
            if(this.b != null)
            {
               this.b.GetUserData().objectData.ForceDestruction();
               return;
            }
            this.DropGrabbedPlayer();
            this._PlayerState.Jumping = false;
            this.Roll();
            return;
         }
         if(this._PlayerState.Jumping)
         {
            this._PlayerState.Jumping = false;
            if(this._keyPressed[KEY_JUMP])
            {
               this.Jump();
            }
         }
         else
         {
            this.UpdateDynamicMovement();
         }
      }
      
      private function DetectEdge(param1:int, param2:int = 14, param3:Boolean = false) : Boolean
      {
         var _loc6_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Boolean = false;
         var _loc4_:int = 0;
         var _loc5_:Number = Number(this._this_y);
         var _loc7_:Number = 4;
         while(_loc7_ <= param2)
         {
            _loc4_ = this._this_x + param1 * _loc7_;
            _loc8_ = 4;
            while(_loc8_ < 12)
            {
               _loc6_ = _loc5_ - _loc8_;
               if(Boolean(this._static_world_hitbox_mc.hitTestPoint(_loc4_,_loc6_,true)) || Boolean(this._static_world_cloud_hitbox_mc.hitTestPoint(_loc4_,_loc6_,true)))
               {
                  if(this.m_world.GetPartWorldAt(_loc4_,_loc6_) == null)
                  {
                     return false;
                  }
               }
               _loc8_ += 2;
            }
            _loc10_ = true;
            _loc9_ = -2;
            while(_loc9_ <= 10)
            {
               _loc6_ = _loc5_ + _loc9_;
               if(Boolean(this._static_world_hitbox_mc.hitTestPoint(_loc4_,_loc6_,true)) || Boolean(this._static_world_cloud_hitbox_mc.hitTestPoint(_loc4_,_loc6_,true)))
               {
                  _loc10_ = false;
                  _loc9_ = 12;
               }
               _loc9_ += 1;
            }
            if(_loc10_)
            {
               this._Handler_Output.Trace("Edge Found: " + _loc7_);
               if(param3)
               {
                  _loc9_ = 12;
                  while(_loc9_ <= 40)
                  {
                     _loc6_ = _loc5_ + _loc9_;
                     if(Boolean(this._static_world_hitbox_mc.hitTestPoint(_loc4_,_loc6_,true)) || Boolean(this._static_world_cloud_hitbox_mc.hitTestPoint(_loc4_,_loc6_,true)))
                     {
                        return false;
                     }
                     _loc9_ += 4;
                  }
               }
               return true;
            }
            _loc7_ += 2;
         }
         return false;
      }
      
      private function CheckDeathBounce() : void
      {
         var _loc5_:int = 0;
         var _loc6_:Boolean = false;
         var _loc1_:Boolean = true;
         var _loc2_:Boolean = true;
         var _loc3_:Boolean = true;
         if(this._lastBounceY + 5 > this._this_y)
         {
            _loc3_ = false;
            _loc1_ = false;
            _loc2_ = false;
         }
         else
         {
            _loc1_ = Boolean(this.DetectEdge(1));
            _loc2_ = Boolean(this.DetectEdge(-1));
         }
         if(!_loc1_ && !_loc2_)
         {
            _loc6_ = true;
            _loc5_ = 0;
            while(_loc5_ < 6)
            {
               if(this.HitTestWorldOnly(this._this_x,this._this_y + _loc5_))
               {
                  _loc6_ = false;
               }
               _loc5_ += 2;
            }
            if(_loc6_)
            {
               _loc5_ = 0;
               while(_loc5_ < 4)
               {
                  if(this._static_world_cloud_hitbox_mc.hitTestPoint(this._this_x,this._this_y + _loc5_,true))
                  {
                     this._jumpDownPosYDisable = this._this_y + 10;
                     this._performJumpDownLevel = true;
                     this.Fall(false);
                     this.scaleX *= -1;
                     this._collision_mc.scaleX = this.scaleX;
                     this._PlayerState.LastDirX *= -1;
                     this._PlayerState.AirVelocityX = Math.random() * 3 - 1.5;
                     this._PlayerState.AirVelocityY = -1.5;
                     return;
                  }
                  _loc5_ += 2;
               }
            }
            return;
         }
         if(!_loc3_)
         {
            return;
         }
         if(_loc1_ && _loc2_)
         {
            if(Math.random() < 0.5)
            {
               _loc1_ = false;
            }
            else
            {
               _loc2_ = false;
            }
         }
         var _loc4_:int = 0;
         if(_loc1_)
         {
            _loc4_ = 1;
         }
         else if(_loc2_)
         {
            _loc4_ = -1;
         }
         this.Fall(false);
         this.scaleX *= -1;
         this._collision_mc.scaleX = this.scaleX;
         this._PlayerState.LastDirX *= -1;
         this._PlayerState.AirVelocityX = _loc4_ * 1.5;
         this._PlayerState.AirVelocityY = -1.5;
      }
      
      private function UpdateSides(param1:Boolean = true) : void
      {
         var _loc2_:Boolean = false;
         var _loc3_:Boolean = false;
         var _loc4_:int = 0;
         var _loc5_:b2Vec2 = null;
         var _loc6_:int = 0;
         if(this.CanLandInMid())
         {
            _loc4_ = -this._PlayerState.PlayerEdgeDistance - 1;
            while(_loc4_ <= this._PlayerState.PlayerEdgeDistance + 1)
            {
               this.b = this.GetDynamicBodyAt(this._this_x + _loc4_,this._this_y - this._PlayerState.PlayerHeight,false);
               if(this.b != null)
               {
                  if(this.b.GetUserData().objectData.CanGibb)
                  {
                     _loc5_ = this.b.GetLinearVelocity();
                     if(Math.abs(_loc5_.x) > 0.1)
                     {
                        if(this.CheckCollisionTowardsPlayer(this.b.GetPosition().x * 30,this._this_x,this.ConvertToDirection(_loc5_.x)))
                        {
                           return;
                        }
                     }
                  }
               }
               _loc4_ += this._PlayerState.PlayerEdgeDistance + 1;
            }
         }
         _loc2_ = Boolean(this.CollisionSide(1));
         _loc3_ = Boolean(this.CollisionSide(-1));
         if(_loc2_ || _loc3_)
         {
            _loc6_ = 1;
            while(_loc6_ <= this._PlayerState.PlayerEdgeDistance * 10)
            {
               _loc2_ = Boolean(this.CollisionSide(1,_loc6_ / 10));
               _loc3_ = Boolean(this.CollisionSide(-1,_loc6_ / 10));
               if(!(_loc3_ && _loc2_))
               {
                  if(_loc2_)
                  {
                     if(!this.WorldCollisionSide(-1,this._PlayerState.PlayerEdgeDistance))
                     {
                        this._this_x -= 0.1;
                        if(param1)
                        {
                           this._PlayerState.AirVelocityX -= 0.02;
                        }
                     }
                     else
                     {
                        this._this_x += 0.1;
                        if(param1)
                        {
                           this._PlayerState.AirVelocityX += 0.02;
                        }
                     }
                  }
                  else if(_loc3_)
                  {
                     if(!this.WorldCollisionSide(1,this._PlayerState.PlayerEdgeDistance))
                     {
                        this._this_x += 0.1;
                        if(param1)
                        {
                           this._PlayerState.AirVelocityX += 0.02;
                        }
                     }
                     else
                     {
                        this._this_x -= 0.1;
                        if(param1)
                        {
                           this._PlayerState.AirVelocityX -= 0.02;
                        }
                     }
                  }
               }
               _loc6_++;
            }
            this._PlayerState.AirVelocityX *= 0.9;
         }
      }
      
      private function GetBodyAbovePlayer() : b2Body
      {
         var _loc1_:b2Body = null;
         _loc1_ = this.GetDynamicBodyAt(this._this_x,this._this_y - this._PlayerState.PlayerHeight,false);
         if(_loc1_ != null)
         {
            return _loc1_;
         }
         _loc1_ = this.GetDynamicBodyAt(this._this_x - 4,this._this_y - this._PlayerState.PlayerHeight,false);
         if(_loc1_ != null)
         {
            return _loc1_;
         }
         _loc1_ = this.GetDynamicBodyAt(this._this_x + 4,this._this_y - this._PlayerState.PlayerHeight,false);
         if(_loc1_ != null)
         {
            return _loc1_;
         }
         return null;
      }
      
      private function GetGibBodyNearPlayer() : b2Body
      {
         var _loc1_:b2Body = null;
         var _loc2_:int = 0;
         _loc2_ = -4;
         while(_loc2_ <= 4)
         {
            _loc1_ = this.GetDynamicBodyAt(this._this_x + _loc2_,this._this_y - 4,false);
            if(_loc1_ != null)
            {
               if(_loc1_.GetUserData().objectData.CanGibb)
               {
                  if(Boolean(this._static_world_hitbox_mc.hitTestPoint(this._this_x,this._this_y + 2,true)) && !_loc1_.GetUserData().objectData.CollisionMC.hitTestPoint(this._this_x,this._this_y + 2,true))
                  {
                     return _loc1_;
                  }
                  if(Boolean(this._static_world_hitbox_mc.hitTestPoint(this._this_x + _loc2_,this._this_y + 2,true)) && !_loc1_.GetUserData().objectData.CollisionMC.hitTestPoint(this._this_x + _loc2_,this._this_y + 2,true))
                  {
                     return _loc1_;
                  }
               }
            }
            _loc2_ += 4;
         }
         return null;
      }
      
      private function UpdateFlashEffect() : void
      {
         var _loc1_:Color = null;
         _loc1_ = new Color();
         _loc1_.brightness = this._PlayerState.FlashEffectTimer / 8 * 1;
         this.transform.colorTransform = _loc1_;
      }
      
      private function StopFlashEffect() : void
      {
         var _loc1_:Color = null;
         if(this._PlayerState.ShowFlashEffect)
         {
            _loc1_ = new Color();
            _loc1_.brightness = 0;
            this.transform.colorTransform = _loc1_;
         }
         this._PlayerState.ShowFlashEffect = false;
      }
      
      private function StartFlashEffect() : void
      {
         var _loc1_:Color = null;
         _loc1_ = new Color();
         _loc1_.brightness = 1;
         this.transform.colorTransform = _loc1_;
         this._PlayerState.ShowFlashEffect = true;
      }
      
      public function FireContact(param1:Boolean = false, param2:Number = 1) : void
      {
         var _loc3_:MovieClip = null;
         if(this._PlayerState.IsImmune)
         {
            return;
         }
         if(this._PlayerState.StuckToRocket)
         {
            return;
         }
         this._PlayerState.BurnState += this._game_speed * param2;
         if(param1 && this._PlayerState.BurnState < 100)
         {
            this._PlayerState.InWorldFire = true;
         }
         if(this._PlayerState.BurnState < this._PlayerState.FireRank1Minimum)
         {
            return;
         }
         if(this._PlayerState.HP <= 0)
         {
            if(!this._PlayerState.Burned)
            {
               this.DropGrabbedPlayer();
               this.StopFlashEffect();
               this.removeChild(this._char);
               this._char = new player_burnt();
               this.addChild(this._char);
               this._PlayerAnimation.NewSkin(this._char);
               _loc3_ = MovieClip(this._char_gui.parent);
               _loc3_.removeChild(this._char_gui);
               this._char_gui = new player_burnt();
               _loc3_.addChild(this._char_gui);
               this._PlayerAnimation.SetGUISkin(this._char_gui,this._blood_gui);
               this._Handler_Effects.AddEffectAt("PLAYER_BURNED",this.MidPosX(),this.MidPosY());
               this._PlayerState.BurnState = 100;
               this._PlayerState.Burned = true;
               if(!this._PlayerState.Knockdowned && !this._PlayerState.DeathKneel && !this._PlayerState.Staggering)
               {
                  if((Boolean(this.DetectEdge(this._PlayerState.LastDirX)) || Math.random() < 0.5) && Boolean(this._PlayerState.OnGround))
                  {
                     if(this._PlayerState.Sprinting)
                     {
                        this.Fall(false);
                     }
                     else
                     {
                        this._PlayerState.DeathKneel = true;
                        this._PlayerState.CameraIgnoreTimer = 3 * 24;
                     }
                  }
                  else
                  {
                     this.Fall(false);
                  }
                  this._Handler_Shake.Add(2,2);
               }
            }
            return;
         }
         if(param1)
         {
            this._PlayerState.HP -= this._PlayerState.FireRankWorldExtraDamage * this._game_speed * param2;
         }
         if(this._PlayerState.BurnState >= this._PlayerState.FireRank2Minimum)
         {
            this._PlayerState.HP -= this._PlayerState.FireRank2Damage * this._game_speed * param2;
         }
         else
         {
            this._PlayerState.HP -= this._PlayerState.FireRank1Damage * this._game_speed * param2;
         }
         if(this._PlayerState.HP <= 0)
         {
            --this._PlayerState.AirVelocityY;
            this.Disarm();
            this.Fall(true);
            if(this.ActivateSlowmotion(this.PlayerNr))
            {
               this._Handler_Slowmo.AddSlowmotion(new SlowmoData(0,24 * 2,24 * 1,0.2));
            }
         }
      }
      
      public function ExplosionHit(param1:Number, param2:Number, param3:Number) : void
      {
         var _loc4_:int = 0;
         if(this._PlayerState.IsImmune)
         {
            return;
         }
         this._PlayerState.CritSmokeTimer = 48;
         this._PlayerState.AirVelocityX += Math.cos(param1) * param2;
         this._PlayerState.AirVelocityY += Math.sin(param1) * param2;
         if(this._PlayerState.AirVelocityY > -2)
         {
            if(!this._PlayerState.Falling)
            {
               this._PlayerState.AirVelocityY = -2;
            }
         }
         this.DropGrabbedPlayer();
         if(this._PlayerState.HP > 0)
         {
            this._PlayerState.HP -= param3;
            if(this._PlayerState.HP <= 0)
            {
               this.Disarm();
               if(this.ActivateSlowmotion(this.PlayerNr))
               {
                  this._Handler_Slowmo.AddSlowmotion(new SlowmoData(0,24 * 2,24 * 1,0.2));
               }
            }
         }
         else if(param3 >= 20)
         {
            this.GibPlayer();
            return;
         }
         if(param3 <= 10)
         {
            if(this._PlayerState.HP > 0)
            {
               this.StartStagger(this.ConvertToDirection(-this._PlayerState.AirVelocityX));
            }
            else
            {
               _loc4_ = int(this.EdgeStaggerDistance());
               if(_loc4_ > 6)
               {
                  this.StartStagger(this.ConvertToDirection(-this._PlayerState.AirVelocityX));
                  this._PlayerState.StaggerTimer = _loc4_ - 4;
               }
               else
               {
                  this.CheckAimDrop();
                  if(!this._PlayerState.CantRise)
                  {
                     this._PlayerState.Falling = true;
                  }
                  this._PlayerAnimation.ShowAnimation("knockdown",true);
               }
            }
         }
         else
         {
            this.CheckAimDrop();
            if(!this._PlayerState.CantRise)
            {
               this._PlayerState.Falling = true;
            }
            this._PlayerAnimation.ShowAnimation("knockdown",true);
         }
      }
      
      private function BackToOldPosition() : void
      {
         this._this_x = this._old_this_x;
         this._this_y = this._old_this_y;
      }
      
      public function CanBeKnockedByFlyingPlayer() : Boolean
      {
         if(this._PlayerState.IsImmune)
         {
            return false;
         }
         if(this._PlayerState.Falling)
         {
            return false;
         }
         if(this._PlayerState.Knockdowned)
         {
            if(this._PlayerAnimation.CurrentFrame >= 10)
            {
               return true;
            }
            return false;
         }
         return true;
      }
      
      private function UpdatePlayerFallingOnPlayer() : void
      {
         var _loc1_:* = undefined;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         if(this._PlayerState.TotalAirVelocity >= 6 && Boolean(this._PlayerState.Falling))
         {
            _loc1_ = 0;
            while(_loc1_ < this._players.length)
            {
               if(_loc1_ != this.PlayerNr)
               {
                  if(this._players[_loc1_].CanBeKnockedByFlyingPlayer())
                  {
                     if(this.hitTestObject(this._players[_loc1_].MC))
                     {
                        _loc2_ = this._players[_loc1_].MidPosX() - this.MidPosX();
                        _loc3_ = this._players[_loc1_].MidPosY() - this.MidPosY();
                        if(Math.sqrt(_loc2_ * _loc2_ + _loc3_ * _loc3_) <= 12)
                        {
                           _loc4_ = Number(this._players[_loc1_].State.AirVelocityY);
                           this._players[_loc1_].State.AirVelocityY = this._PlayerState.AirVelocityY * 0.9;
                           this._PlayerState.AirVelocityY = _loc4_ * 0.9;
                           _loc4_ = Number(this._players[_loc1_].State.AirVelocityX);
                           this._players[_loc1_].State.AirVelocityX = this._PlayerState.AirVelocityX * 0.9;
                           this._PlayerState.AirVelocityX = _loc4_ * 0.9;
                           this._players[_loc1_].Fall(false);
                        }
                     }
                  }
               }
               _loc1_++;
            }
         }
      }
      
      private function Jump() : void
      {
         if(!this._PlayerState.Aiming)
         {
            if(this._PlayerState.Climbing)
            {
               this.LadderJump();
            }
            else if(!this._PlayerState.Jumping)
            {
               this.BeginJump();
            }
         }
      }
      
      private function Walljump() : void
      {
         var _loc1_:* = undefined;
         var _loc2_:int = 0;
         var _loc3_:b2Vec2 = null;
         this._edgePosition = this._this_x + this._PlayerState.PlayerEdgeDistance * this._PlayerState.LastDirX;
         _loc1_ = 0;
         while(_loc1_ < this.m_world.DynamicHitBoxObjectList.length)
         {
            this.b = this.m_world.DynamicHitBoxObjectList[_loc1_];
            _loc2_ = 0;
            while(_loc2_ <= 8)
            {
               if(this.b.GetUserData().objectData.CollisionMC.hitTestPoint(this._edgePosition,this._this_y - _loc2_,true))
               {
                  _loc3_ = new b2Vec2((this._this_x + this._PlayerState.PlayerEdgeDistance * this._PlayerState.LastDirX) / 30,this._this_y / 30);
                  this.b.ApplyImpulse(new b2Vec2(this._PlayerState.LastDirX,0),_loc3_);
                  break;
               }
               _loc2_ += 2;
            }
            _loc1_++;
         }
         this.scaleX *= -1;
         this._collision_mc.scaleX = this.scaleX;
         this._PlayerState.LastDirX *= -1;
         this._PlayerState.MovingDirectionX = this._PlayerState.LastDirX;
         this._PlayerState.Sprinting = false;
         this._PlayerState.WallJumping = true;
         this._PlayerState.AirVelocityY = this._PlayerState.PlayerWallJumpPower;
         this._PlayerAnimation.ShowAnimation("jump",true);
         this._Handler_Effects.AddParticle(new particle_data("DUST",this._this_x - this._PlayerState.LastDirX * 5,this._this_y,new b2Vec2(this._PlayerState.LastDirX,1)));
      }
      
      private function UpdateGrabbedPlayer(param1:Boolean = false) : void
      {
         if(this._PlayerState.GrabbedPlayer)
         {
            if(param1)
            {
               this._players[this._PlayerState.GrabbedPlayerNr].SetCoordinates(this._this_x,this._this_y);
            }
            else
            {
               this._players[this._PlayerState.GrabbedPlayerNr].SetCoordinates(this._this_x + this._PlayerState.LastDirX * 6,this._this_y - 2);
            }
            try
            {
               this._players[this._PlayerState.GrabbedPlayerNr].SetGrabRotation(-this._PlayerAnimation.GrabRotation);
            }
            catch(e:Error)
            {
            }
         }
      }
      
      private function DropGrabbedPlayer() : void
      {
         if(this._PlayerState.GrabbedPlayer)
         {
            this.UpdateGrabbedPlayer(true);
            this._players[this._PlayerState.GrabbedPlayerNr].GrabbedByOtherPlayer(false,this._PlayerState.LastDirX);
            this._PlayerState.GrabbedPlayer = false;
         }
      }
      
      private function CheckDivePlayerImpact() : void
      {
         var _loc1_:* = undefined;
         if(!this._PlayerState.GrabbedPlayer)
         {
            _loc1_ = 0;
            while(_loc1_ < this._players.length)
            {
               if(_loc1_ != this.PlayerNr && !this._players[_loc1_].State.IsImmune)
               {
                  if(this.hitTestObject(this._players[_loc1_].MC))
                  {
                     if(this.CheckCollisionTowardsPlayer(this.PosX(),this._players[_loc1_].PosX(),this._PlayerState.LastDirX))
                     {
                        if(Math.sqrt((this._this_x - this._players[_loc1_].MidPosX()) * (this._this_x - this._players[_loc1_].MidPosX())) <= 8)
                        {
                           if(Math.sqrt((this.MidPosY() - this._players[_loc1_].MidPosY()) * (this.MidPosY() - this._players[_loc1_].MidPosY())) <= 10)
                           {
                              if(this._players[_loc1_].State.Diving)
                              {
                                 this._Handler_Sounds.PlaySoundAt("DIVE_CATCH",this.PosX(),this.PosY());
                                 this._Handler_Effects.AddEffectAt("DIVE_IMPACT",this.MidPosX() + this._PlayerState.LastDirX * 12,this.MidPosY() - 4);
                                 this._players[_loc1_].DiveCollision();
                                 this.DiveCollision();
                              }
                              else if(Boolean(this._players[_loc1_].CanBeCatched) && !this._PlayerState.GrabbedPlayer)
                              {
                                 this._Handler_Sounds.PlaySoundAt("DIVE_CATCH",this.PosX(),this.PosY());
                                 this._Handler_Effects.AddEffectAt("DIVE_IMPACT",this.MidPosX() + this._PlayerState.LastDirX * 12,this.MidPosY() - 4);
                                 if(this.parent.getChildIndex(this) < this._players[_loc1_].parent.getChildIndex(this._players[_loc1_]))
                                 {
                                    this.parent.swapChildren(this,this._players[_loc1_]);
                                 }
                                 this._PlayerState.GrabbedPlayerNr = _loc1_;
                                 this._PlayerState.GrabbedPlayerCharNr = this._players[this._PlayerState.GrabbedPlayerNr].State.CharNr;
                                 this._players[this._PlayerState.GrabbedPlayerNr].GrabbedByOtherPlayer(true,this._PlayerState.LastDirX);
                              }
                           }
                        }
                     }
                  }
               }
               _loc1_++;
            }
         }
      }
      
      private function UpdateDynamicMovement(param1:Boolean = false) : void
      {
         var _loc2_:Array = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:b2Vec2 = null;
         var _loc6_:b2Vec2 = null;
         var _loc7_:Number = NaN;
         if(this._PlayerState.KickingTimer > 0)
         {
            return;
         }
         if(this._PlayerState.OnGround)
         {
            _loc2_ = new Array();
            _loc3_ = 0;
            while(_loc3_ < this.m_world.DynamicHitBoxObjectList.length)
            {
               this.b = this.m_world.DynamicHitBoxObjectList[_loc3_];
               if(this.b.GetUserData().objectData.ShapeMC.hitTestObject(this._player_area_mc))
               {
                  _loc2_.push(this.b);
               }
               _loc3_++;
            }
            _loc4_ = 0;
            loop1:
            while(_loc4_ <= this._PlayerState.PlayerEdgeDistance + 2)
            {
               _loc3_ = 0;
               while(true)
               {
                  if(_loc3_ >= _loc2_.length)
                  {
                     _loc4_ += 2;
                     continue loop1;
                  }
                  this.b = _loc2_[_loc3_];
                  if(Boolean(this.b.GetUserData().objectData.ShapeMC.hitTestPoint(this._this_x + _loc4_,this._this_y + 2,true)) || Boolean(this.b.GetUserData().objectData.ShapeMC.hitTestPoint(this._this_x - _loc4_,this._this_y + 2,true)))
                  {
                     break;
                  }
                  _loc3_++;
               }
               _loc5_ = new b2Vec2(this._this_x / 30,this._this_y / 30);
               if(this.b.GetUserData().objectData.IsElevator)
               {
                  _loc6_ = this.b.GetLinearVelocity();
               }
               else
               {
                  _loc6_ = this.b.GetLinearVelocityFromWorldPoint(_loc5_);
               }
               if(param1)
               {
                  if(this.b.GetUserData().isConveyorBelt == true)
                  {
                     this._PlayerState.AirVelocityX = this.b.GetLinearVelocity().x + this.b.GetUserData().conveyorBeltSpeedX;
                     this._PlayerState.AirVelocityY = this.b.GetLinearVelocity().y + this.b.GetUserData().conveyorBeltSpeedY;
                  }
                  else
                  {
                     this._PlayerState.AirVelocityX = this.b.GetLinearVelocity().x;
                     this._PlayerState.AirVelocityY = this.b.GetLinearVelocity().y;
                  }
               }
               else
               {
                  this._PlayerState.AirVelocityX = _loc6_.x;
                  this._PlayerState.AirVelocityY = _loc6_.y;
                  if(this.b.GetUserData().objectData.ShapeMC.hitTestPoint(this._this_x,this._this_y + 2,true))
                  {
                     this.SimpleMove(_loc6_.x * this._game_speed,_loc6_.y * this._game_speed * 0.66);
                  }
                  else
                  {
                     this.SimpleMove(_loc6_.x * this._game_speed,_loc6_.y * this._game_speed * 1.01);
                  }
                  if(this._game_speed >= 0.01)
                  {
                     _loc7_ = this.b.GetMass() / 10;
                     this.b.ApplyImpulse(new b2Vec2(0,_loc7_ * this._game_speed),_loc5_);
                  }
               }
               this._standingOnObject = this.b;
               return;
            }
            this._PlayerState.AirVelocityX = 0;
            this._PlayerState.AirVelocityY = 0;
         }
         this._standingOnObject = null;
      }
      
      private function SimpleMove(param1:Number, param2:Number) : void
      {
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         this._this_x += param1;
         this._this_y += param2;
      }
      
      private function CheckCollisionTowardsPlayer(param1:Number, param2:Number, param3:int) : Boolean
      {
         if(param3 == 1 && param1 < param2 + 4)
         {
            return true;
         }
         if(param3 == -1 && param1 > param2 - 4)
         {
            return true;
         }
         return false;
      }
      
      public function GrabbedByOtherPlayer(param1:Boolean, param2:int = 0) : void
      {
         if(param2 != 0)
         {
            this._PlayerState.LastDirX = -param2;
            this.scaleX = this._PlayerState.LastDirX;
            this._collision_mc.scaleX = this.scaleX;
         }
         this._PlayerState.GrabbedByPlayer = param1;
         if(!param1)
         {
            this._PlayerState.AirVelocityY = 0;
            this._PlayerState.AirVelocityX = 0;
            this._PlayerState.Knockdowned = true;
            this._PlayerState.Jumping = true;
            if(this._PlayerState.IgnoreMe)
            {
               this.visible = false;
            }
         }
         else
         {
            this.CheckAimDrop();
            this.CancelAFS();
            this._PlayerAnimation.ShowAnimation("GRABBED");
         }
      }
      
      private function AbleToWalljump() : Boolean
      {
         var _loc1_:int = 0;
         if(!this._PlayerState.WallJumping)
         {
            if(Math.sqrt(this._PlayerState.AirVelocityY * this._PlayerState.AirVelocityY) <= 3)
            {
               this._edgePosition = this._this_x + (this._PlayerState.PlayerEdgeDistance + 1) * this._PlayerState.LastDirX;
               _loc1_ = 0;
               while(_loc1_ <= 8)
               {
                  if(this._static_world_hitbox_mc.hitTestPoint(this._edgePosition,this._this_y - _loc1_,true))
                  {
                     return true;
                  }
                  _loc1_ += 2;
               }
            }
         }
         return false;
      }
      
      private function GetClosestReachableWeapon() : b2Body
      {
         var _loc1_:b2Body = null;
         var _loc2_:Number = NaN;
         var _loc3_:int = 0;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         _loc1_ = null;
         _loc3_ = 0;
         while(_loc3_ < this.m_world.WeaponList.length)
         {
            this.b = this.m_world.WeaponList[_loc3_];
            if(this.b.GetUserData().weaponData.Ammo > 0)
            {
               _loc4_ = this.MidPosX() - this.b.GetPosition().x * 30;
               if(Math.sqrt(_loc4_ * _loc4_) <= this.b.GetUserData().weaponData.Properties.PickupRadius)
               {
                  _loc5_ = this.MidPosY() + 4 - this.b.GetPosition().y * 30;
                  if(Math.sqrt(_loc5_ * _loc5_) <= 10)
                  {
                     if(_loc1_ != null)
                     {
                        if(Math.sqrt(_loc4_ * _loc4_ + _loc5_ * _loc5_) < _loc2_)
                        {
                           _loc1_ = this.b;
                           _loc2_ = Math.sqrt(_loc4_ * _loc4_ + _loc5_ * _loc5_);
                        }
                     }
                     else
                     {
                        _loc1_ = this.b;
                        _loc2_ = Math.sqrt(_loc4_ * _loc4_ + _loc5_ * _loc5_);
                     }
                  }
               }
            }
            _loc3_++;
         }
         return _loc1_;
      }
      
      private function GrabWeapon() : Boolean
      {
         var _loc1_:b2Body = null;
         _loc1_ = this.GetClosestReachableWeapon();
         if(_loc1_ != null)
         {
            if(_loc1_.GetUserData().isRanged == true)
            {
               this._PlayerState.CurrentRangeWeapon = _loc1_.GetUserData().weaponData;
               this._Handler_Effects.AddParticle(new particle_data("PICKUP_" + _loc1_.GetUserData().weaponData.Properties.WeaponType,this.MidPosX(),this.MidPosY() - 10));
               _loc1_.GetUserData().objectData.ForceDestruction();
               this._Handler_Sounds.PlaySoundAt(this._PlayerState.CurrentRangeWeapon.Properties.PickupSound,this.PosX(),this.PosY());
               return true;
            }
            if(_loc1_.GetUserData().isThrowable == true)
            {
               this._PlayerState.CurrentThrowableWeapon = _loc1_.GetUserData().weaponData;
               this._Handler_Effects.AddParticle(new particle_data("PICKUP_" + _loc1_.GetUserData().weaponData.Properties.WeaponType,this.MidPosX(),this.MidPosY() - 10));
               _loc1_.GetUserData().objectData.ForceDestruction();
               this._Handler_Sounds.PlaySoundAt(this._PlayerState.CurrentThrowableWeapon.Properties.PickupSound,this.PosX(),this.PosY());
               return true;
            }
            if(_loc1_.GetUserData().isMelee == true)
            {
               this._PlayerState.CurrentMeleeWeapon = _loc1_.GetUserData().weaponData;
               this._Handler_Effects.AddParticle(new particle_data("PICKUP_" + _loc1_.GetUserData().weaponData.Properties.WeaponType,this.MidPosX(),this.MidPosY() - 10));
               _loc1_.GetUserData().objectData.ForceDestruction();
               this._Handler_Sounds.PlaySoundAt(this._PlayerState.GetMeleeWeapon().Properties.PickupSound,this.PosX(),this.PosY());
               return true;
            }
            if(_loc1_.GetUserData().isPowerup == true)
            {
               this._PlayerState.CurrentPowerupWeapon = _loc1_.GetUserData().weaponData;
               this._Handler_Effects.AddParticle(new particle_data("PICKUP_" + _loc1_.GetUserData().weaponData.Properties.WeaponType,this.MidPosX(),this.MidPosY() - 10));
               _loc1_.GetUserData().objectData.ForceDestruction();
               this._Handler_Sounds.PlaySoundAt(this._PlayerState.CurrentPowerupWeapon.Properties.PickupSound,this.PosX(),this.PosY());
               return true;
            }
            if(_loc1_.GetUserData().isHealth == true)
            {
               this._PlayerState.HP += _loc1_.GetUserData().weaponData.Ammo;
               this._Handler_Sounds.PlaySoundAt(_loc1_.GetUserData().weaponData.Properties.PickupSound,this.PosX(),this.PosY());
               _loc1_.GetUserData().objectData.ForceDestruction();
               this.StartFlashEffect();
               return true;
            }
         }
         return false;
      }
      
      private function CancelFireDelay() : void
      {
         clearInterval(this._PlayerState.FireDelayTimer);
         this._PlayerState.FireDelayActivated = false;
         this._PlayerState.FireDelayUpdated = false;
         this._startAimASAP = false;
      }
      
      private function FireDelay() : void
      {
         this.CancelFireDelay();
         if(this.KeyPressed(5))
         {
            if(this._PlayerState.CurrentRangeWeapon != null)
            {
               if(Boolean(this._PlayerState.ControllAble) && !this._PlayerState.Jumping)
               {
                  this._PlayerState.Aiming = true;
                  this._cancelAimingASAP = false;
                  this._PlayerState.AimMode = 0;
                  this._PlayerState.AimTurningAround = true;
                  this._Handler_Sounds.PlaySoundAt(this._PlayerState.CurrentRangeWeapon.Properties.AimSound,this.PosX(),this.PosY());
                  this._PlayerState.DrawDelay = 1;
               }
            }
         }
      }
      
      private function RangedDown() : void
      {
         if(Boolean(this._cancelAimingASAP) || this._game_speed == 0 || Boolean(this._PlayerState.StuckToRocket) || Boolean(this._PlayerState.Staggering))
         {
            return;
         }
         if(Boolean(this._PlayerState.ControllAble) && !this._PlayerState.Jumping)
         {
            if(!this._PlayerState.Throwing && !this._PlayerState.Aiming)
            {
               if(this._PlayerState.CurrentRangeWeapon != null)
               {
                  this._PlayerState.FastTrigger = true;
                  this._PlayerState.Aiming = true;
                  this._cancelAimingASAP = false;
                  this._PlayerState.AimMode = 0;
                  this._PlayerState.AimTurningAround = true;
                  this._Handler_Sounds.PlaySoundAt(this._PlayerState.CurrentRangeWeapon.Properties.AimSound,this.PosX(),this.PosY());
                  this._PlayerState.DrawDelay = 1;
               }
            }
         }
         else
         {
            this._startAimASAP = true;
         }
      }
      
      private function RangedUp() : void
      {
         if(Boolean(this._PlayerState.StuckToRocket) || Boolean(this._PlayerState.Staggering))
         {
            return;
         }
         this._startAimASAP = false;
         if(!this._PlayerState.Throwing && Boolean(this._PlayerState.Aiming) && !this._PlayerState.AimTurningAroundDelay)
         {
            if(this._PlayerState.AimMode == 0)
            {
               this._PlayerState.BackToIdleTimer = 6;
               this.FireWeapon();
            }
         }
      }
      
      private function ThrowDown() : void
      {
         if(this._game_speed == 0 || Boolean(this._PlayerState.StuckToRocket) || Boolean(this._PlayerState.Staggering))
         {
            return;
         }
         if(Boolean(this._PlayerState.ControllAble) && !this._PlayerState.Jumping)
         {
            if(!this._PlayerState.Throwing && !this._PlayerState.Aiming)
            {
               if(this._PlayerState.CurrentThrowableWeapon.Ammo > 0)
               {
                  this._PlayerState.Aiming = true;
                  this._PlayerState.AimMode = 1;
                  this._PlayerState.ThrowTimer = this._PlayerState.CurrentThrowableWeapon.Properties.ThrowTimer;
                  this._Handler_Sounds.PlaySoundAt(this._PlayerState.CurrentThrowableWeapon.Properties.AimSound,this.PosX(),this.PosY());
               }
            }
         }
         else
         {
            this._startAimASAP = true;
         }
      }
      
      private function ThrowUp() : void
      {
         if(Boolean(this._PlayerState.StuckToRocket) || Boolean(this._PlayerState.Staggering))
         {
            return;
         }
         this._startAimASAP = false;
         if(!this._PlayerState.Throwing && Boolean(this._PlayerState.Aiming) && !this._PlayerState.AimTurningAroundDelay)
         {
            if(this._PlayerState.AimMode == 1)
            {
               this._PlayerState.Throwing = true;
               this._PlayerState.Aiming = false;
               this.ReleaseThrowable();
            }
         }
      }
      
      private function FireDown() : void
      {
         if(this._game_speed == 0)
         {
            return;
         }
         if(this._PlayerState.StuckToRocket)
         {
            return;
         }
         if(this._PlayerState.Staggering)
         {
            return;
         }
         if(Boolean(this._PlayerState.ControllAble) && !this._PlayerState.Jumping)
         {
            if(!this._PlayerState.Throwing && !this._PlayerState.Aiming)
            {
               if(!this._PlayerState.FireDelayActivated)
               {
                  this._PlayerState.FireDelayActivated = true;
                  this._PlayerState.FireDelayUpdated = false;
                  this._PlayerState.FireDelayTimer = setInterval(this.FireDelay,100);
               }
               else if(this._PlayerState.CurrentThrowableWeapon.Ammo > 0)
               {
                  this.CancelFireDelay();
                  this._PlayerState.Aiming = true;
                  this._PlayerState.AimMode = 1;
                  this._PlayerState.ThrowTimer = this._PlayerState.CurrentThrowableWeapon.Properties.ThrowTimer;
                  this._Handler_Sounds.PlaySoundAt(this._PlayerState.CurrentThrowableWeapon.Properties.AimSound,this.PosX(),this.PosY());
               }
               else
               {
                  this.CancelFireDelay();
               }
            }
         }
         else
         {
            this._startAimASAP = true;
         }
      }
      
      private function FireUp() : void
      {
         if(this._PlayerState.StuckToRocket)
         {
            return;
         }
         if(this._PlayerState.Staggering)
         {
            return;
         }
         this._startAimASAP = false;
         if(Boolean(this._PlayerState.FireDelayActivated) && !this._PlayerState.FireDelayUpdated)
         {
            clearInterval(this._PlayerState.FireDelayTimer);
            this._PlayerState.FireDelayUpdated = true;
            this._PlayerState.FireDelayTimer = setInterval(this.CancelFireDelay,100);
            return;
         }
         if(!this._PlayerState.Throwing && Boolean(this._PlayerState.Aiming) && !this._PlayerState.AimTurningAroundDelay)
         {
            if(this._PlayerState.AimMode == 0)
            {
               this._PlayerState.BackToIdleTimer = 6;
               this.FireWeapon();
            }
            else if(this._PlayerState.AimMode == 1)
            {
               this._PlayerState.Throwing = true;
               this._PlayerState.Aiming = false;
               this.ReleaseThrowable();
            }
         }
      }
      
      private function CheckAimDrop(param1:Boolean = false) : void
      {
         if(this._PlayerState.Aiming)
         {
            if(this._PlayerState.AimMode == 1)
            {
               this.DropThrowable();
            }
            if(this._PlayerState.AimMode == 0)
            {
               this.AbortAiming(param1);
            }
         }
      }
      
      private function ThrowTimerEnded() : void
      {
         if(Boolean(this._PlayerState.Aiming) && this._PlayerState.AimMode == 1)
         {
            this.DropThrowable();
         }
      }
      
      private function DropThrowable() : void
      {
         var _loc1_:Number = NaN;
         var _loc2_:Number = NaN;
         if(this._PlayerState.Throwing)
         {
            this._PlayerState.Aiming = false;
            this._PlayerState.Throwing = false;
            return;
         }
         _loc1_ = (this.MidPosX() - this._PlayerState.LastDirX * 6) / 30;
         _loc2_ = (this.MidPosY() - 6) / 30;
         this._Handler_Maps.Handler_WorldItems.AddPolygon(this._PlayerState.CurrentThrowableWeapon.Properties.ThrowType + "_thrown",_loc1_,_loc2_,0,new b2Vec2(),this._PlayerState.LastDirX * 10,[this._PlayerState.ThrowTimer]);
         this._PlayerState.Aiming = false;
         this._PlayerState.Throwing = false;
         this._PlayerState.ThrowTimer = 0;
         --this._PlayerState.CurrentThrowableWeapon.Ammo;
      }
      
      private function ReleaseThrowable() : void
      {
         var _loc1_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:b2Body = null;
         _loc1_ = (this.MidPosX() - this._PlayerState.LastDirX * 4.5) / 30;
         _loc2_ = (this.MidPosY() - 7.5) / 30;
         _loc3_ = this._PlayerState.CurrentAimAngle * (Math.PI / 180);
         _loc4_ = Math.cos(_loc3_) * 5.5;
         _loc5_ = Math.sin(_loc3_) * 5.5 - 2;
         _loc6_ = this._Handler_Maps.Handler_WorldItems.AddPolygon(this._PlayerState.CurrentThrowableWeapon.Properties.ThrowType + "_thrown",_loc1_,_loc2_,0,new b2Vec2(_loc4_,_loc5_),this._PlayerState.LastDirX * 10,new Array(this._PlayerState.ThrowTimer,this.PlayerNr));
         _loc6_.SetBullet(true);
         _loc6_.GetUserData().objectData.IgnoreCoverID = this._PlayerState.CoverObjectID;
         this._PlayerState.ThrowTimer = 0;
         --this._PlayerState.CurrentThrowableWeapon.Ammo;
         this.UpdateGUI();
      }
      
      private function FireWeapon() : void
      {
         if(this._PlayerState.CurrentWeaponCooldown > 0 || this._PlayerState.DrawDelay > 0)
         {
            return;
         }
         if(this._PlayerState.CurrentRangeWeapon.Ammo > 0)
         {
            this._PlayerState.CurrentWeaponCooldown = this._PlayerState.CurrentRangeWeapon.Properties.WeaponCooldown;
            this._PlayerState.CurrentFireFrame = 1;
            this.ProgressAFS(true);
         }
         else
         {
            this.WeaponEmptyRecoil();
         }
      }
      
      private function WeaponEmptyRecoil() : void
      {
         var _loc1_:Number = NaN;
         var _loc2_:Number = NaN;
         if(this._PlayerState.EmptyWeaponRecoilBack <= 0)
         {
            this._Handler_Sounds.PlaySoundAt(this._PlayerState.CurrentRangeWeapon.Properties.EmptySound,this.PosX(),this.PosY());
            this._PlayerState.CharAnimWpnX = this._char.ANIM_WPN.x;
            this._PlayerState.CharAnimWpnY = this._char.ANIM_WPN.y;
            _loc1_ = Number(this._PlayerState.CharAnimWpnX);
            _loc2_ = Number(this._PlayerState.CharAnimWpnY);
            _loc1_ -= Math.cos(this._PlayerState.CurrentAimAngle * (Math.PI / 180)) * 0.5 * this._PlayerState.LastDirX;
            _loc2_ -= Math.sin(this._PlayerState.CurrentAimAngle * (Math.PI / 180)) * 0.5;
            this._char.ANIM_WPN.x = _loc1_;
            this._char.ANIM_WPN.y = _loc2_;
            this._PlayerState.EmptyWeaponRecoilBack = 2;
         }
      }
      
      private function AimLazer() : void
      {
         var _loc1_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc3_:Point = null;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Array = null;
         var _loc8_:int = 0;
         if(this._char.ANIM_WPN == null)
         {
            return;
         }
         if(!this._bot)
         {
            _loc1_ = this._char.ANIM_WPN.x * this._PlayerState.LastDirX + this.PosX();
            _loc2_ = this._char.ANIM_WPN.y + this.PosY();
            _loc1_ += Math.cos(this._PlayerState.CurrentAimAngle * (Math.PI / 180)) * this._char.ANIM_WPN.AIM_POSITION.x;
            _loc2_ += Math.sin(this._PlayerState.CurrentAimAngle * (Math.PI / 180)) * this._char.ANIM_WPN.AIM_POSITION.x;
            _loc2_ += Math.sin((this._PlayerState.CurrentAimAngle + 90) * (Math.PI / 180)) * this._char.ANIM_WPN.AIM_POSITION.y * this._PlayerState.LastDirX;
            _loc1_ += Math.cos((this._PlayerState.CurrentAimAngle + 90) * (Math.PI / 180)) * this._char.ANIM_WPN.AIM_POSITION.y * this._PlayerState.LastDirX;
            _loc3_ = this._Handler_ProjectilesUpdater.CalculateAimSquare(new Point(_loc1_,_loc2_),this._PlayerState.CurrentAimAngle,this._PlayerState.CoverObjectID,AIM_SQUARE_DISTANCE,this.CollisionMC);
            this._aim_mc.x = _loc3_.x;
            this._aim_mc.y = _loc3_.y;
            this._aim_mc.visible = true;
         }
         if(this._PlayerState.AimMode == 0)
         {
            if(this._PlayerState.CurrentRangeWeapon.Properties.LaserSight)
            {
               this.ClearLazerPoints();
               _loc4_ = this._char.ANIM_WPN.x * this._PlayerState.LastDirX + this.PosX();
               _loc5_ = this._char.ANIM_WPN.y + this.PosY();
               _loc4_ += Math.cos(this._PlayerState.CurrentAimAngle * (Math.PI / 180)) * this._char.ANIM_WPN.LAZER_CENTER.x;
               _loc5_ += Math.sin(this._PlayerState.CurrentAimAngle * (Math.PI / 180)) * this._char.ANIM_WPN.LAZER_CENTER.x;
               _loc5_ = _loc5_ + Math.sin((this._PlayerState.CurrentAimAngle + 90) * (Math.PI / 180)) * this._char.ANIM_WPN.LAZER_CENTER.y * this._PlayerState.LastDirX;
               _loc4_ += Math.cos((this._PlayerState.CurrentAimAngle + 90) * (Math.PI / 180)) * this._char.ANIM_WPN.LAZER_CENTER.y * this._PlayerState.LastDirX;
               this._lazer_rnd = Math.random() * Math.PI * 2;
               _loc6_ = Math.sin(this._lazer_rnd) * this._PlayerState.CurrentRangeWeapon.Properties.LaserDeflection;
               _loc7_ = this._Handler_ProjectilesUpdater.CalculateLazer(new Point(_loc4_,_loc5_),this._PlayerState.CurrentAimAngle + _loc6_,this._PlayerState.CoverObjectID,this.CollisionMC);
               _loc8_ = 0;
               while(_loc8_ < _loc7_.length)
               {
                  this.AddLazerPoint(_loc7_[_loc8_]);
                  _loc8_++;
               }
               this._lazer_mc.visible = true;
            }
         }
      }
      
      private function ClearLazerPoints() : void
      {
         var _loc1_:* = 0;
         _loc1_ = int(this._lazer_mc.numChildren);
         while(_loc1_--)
         {
            this._lazer_mc.removeChildAt(_loc1_);
         }
      }
      
      private function AddLazerPoint(param1:Point) : void
      {
         var _loc2_:MovieClip = null;
         var _loc3_:Number = NaN;
         _loc2_ = new lazersight();
         _loc2_.x = param1.x;
         _loc2_.y = param1.y;
         _loc2_.alpha = 0.7;
         _loc3_ = 0.7 + 0.7 / this._dynamic_mc.scaleX;
         _loc2_.scaleX = _loc3_;
         _loc2_.scaleY = _loc3_;
         this._lazer_mc.addChild(_loc2_);
      }
      
      public function Stop() : void
      {
         this.CancelFireDelay();
         clearInterval(this._flameAwayTimer);
         clearInterval(this._downTimer);
         if(this._bot)
         {
            clearInterval(this._BotState._targetInSightTimer);
            clearInterval(this._BotState._targetChooseTimer);
            clearInterval(this._BotState._randomizTimer);
            clearInterval(this._botTimer);
         }
      }
      
      private function FlameAway() : void
      {
         var _loc1_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         if(this._PlayerState.Staggering)
         {
            clearInterval(this._flameAwayTimer);
            this._flameAwayActivated = false;
            this._flameAwayCounter = 0;
            return;
         }
         this._flameAwayCounter -= this._game_speed;
         if(this._char.ANIM_WPN == null)
         {
            return;
         }
         if(this._flameAwayCounter <= 0)
         {
            _loc1_ = this._char.ANIM_WPN.x * this._PlayerState.LastDirX + this.PosX();
            _loc2_ = this._char.ANIM_WPN.y + this.PosY();
            _loc1_ += Math.cos(this._PlayerState.CurrentAimAngle * (Math.PI / 180)) * this._char.ANIM_WPN.FIRE_CENTER.x;
            _loc2_ += Math.sin(this._PlayerState.CurrentAimAngle * (Math.PI / 180)) * this._char.ANIM_WPN.FIRE_CENTER.x;
            _loc2_ += Math.sin((this._PlayerState.CurrentAimAngle + 90) * (Math.PI / 180)) * this._char.ANIM_WPN.FIRE_CENTER.y * this._PlayerState.LastDirX;
            _loc1_ += Math.cos((this._PlayerState.CurrentAimAngle + 90) * (Math.PI / 180)) * this._char.ANIM_WPN.FIRE_CENTER.y * this._PlayerState.LastDirX;
            _loc3_ = Math.random() * this._PlayerState.CurrentRangeWeapon.Properties.AccuracyDeflection * 2 - this._PlayerState.CurrentRangeWeapon.Properties.AccuracyDeflection;
            this._Handler_Fires.AddFlame(_loc1_,_loc2_,this._PlayerState.CurrentAimAngle + _loc3_,this.PlayerNr);
            this._flameAwayCounter = 2;
         }
      }
      
      private function ProgressAFS(param1:Boolean = false) : void
      {
         var pd:particle_data = null;
         var realFrame:int = 0;
         var posX:Number = NaN;
         var posY:Number = NaN;
         var shellPosX:Number = NaN;
         var shellPosY:Number = NaN;
         var muzzlePosX:Number = NaN;
         var muzzlePosY:Number = NaN;
         var speedVec:b2Vec2 = null;
         var randomDeflection:Number = NaN;
         var i:int = 0;
         var firstUpdate:Boolean = param1;
         try
         {
            if(this._PlayerState.Staggering)
            {
               return;
            }
            if(this._startAimASAP)
            {
               if(Boolean(this._PlayerState.ControllAble) && Boolean(this._PlayerState.OnGround))
               {
                  if(this.KeyPressed(5))
                  {
                     this.RangedDown();
                  }
                  else if(this.KeyPressed(6))
                  {
                     this.ThrowDown();
                  }
               }
            }
            if(this._PlayerState.Aiming)
            {
               if(this._PlayerState.AimMode == 1)
               {
                  if(this._PlayerState.CurrentThrowableWeapon.Properties.ThrowType == "MOLOTOV")
                  {
                     if(Math.random() < 0.35)
                     {
                        pd = new particle_data("FIRE",this.MidPosX() - this._PlayerState.LastDirX * 8,this.MidPosY() - 4.5);
                        pd.ScaleX = 0.5;
                        pd.ScaleY = 0.5;
                        this._Handler_Effects.AddParticle(pd);
                     }
                  }
                  if(this._PlayerState.ThrowTimer > 0)
                  {
                     this._PlayerState.ThrowTimer -= this._game_speed;
                     if(this._PlayerState.ThrowTimer <= 0)
                     {
                        this._PlayerState.ThrowTimer = 0;
                        this.ThrowTimerEnded();
                     }
                  }
               }
            }
            if(this.AFSUpdated)
            {
               return;
            }
            this.AFSUpdated = true;
            if(this._PlayerState.CurrentFireFrame > 0)
            {
               if(!firstUpdate)
               {
                  this._PlayerState.CurrentFireFrame += this._game_speed;
               }
               if(this._char.ANIM_WPN == null)
               {
                  return;
               }
               realFrame = Math.floor(this._PlayerState.CurrentFireFrame);
               if(this._PlayerState.LastFireFrame != realFrame)
               {
                  this._PlayerState.LastFireFrame = realFrame;
                  if(this._PlayerState.CurrentRangeWeapon.Properties.FireSequence[realFrame - 1].End)
                  {
                     this._PlayerState.CurrentFireFrame = 0;
                     this._PlayerState.LastFireFrame = 0;
                     if(this._flameAwayActivated)
                     {
                        clearInterval(this._flameAwayTimer);
                        this._flameAwayActivated = false;
                     }
                  }
                  else if(this._PlayerState.BackToIdleTimer < 6)
                  {
                     this._PlayerState.BackToIdleTimer = 6;
                  }
                  this._Handler_Sounds.PlaySoundAt(this._PlayerState.CurrentRangeWeapon.Properties.FireSequence[realFrame - 1].FrameSound,this.PosX(),this.PosY());
                  posX = this._char.ANIM_WPN.x * this._PlayerState.LastDirX + this.PosX();
                  posY = this._char.ANIM_WPN.y + this.PosY();
                  if(this._PlayerState.CurrentRangeWeapon.Properties.FireSequence[realFrame - 1].UseShellEffect)
                  {
                     shellPosX = posX;
                     shellPosY = posY;
                     shellPosX += Math.cos(this._PlayerState.CurrentAimAngle * (Math.PI / 180)) * this._char.ANIM_WPN.SHELL_CENTER.x;
                     shellPosY += Math.sin(this._PlayerState.CurrentAimAngle * (Math.PI / 180)) * this._char.ANIM_WPN.SHELL_CENTER.x;
                     shellPosY += Math.sin((this._PlayerState.CurrentAimAngle + 90) * (Math.PI / 180)) * this._char.ANIM_WPN.SHELL_CENTER.y * this._PlayerState.LastDirX;
                     shellPosX += Math.cos((this._PlayerState.CurrentAimAngle + 90) * (Math.PI / 180)) * this._char.ANIM_WPN.SHELL_CENTER.y * this._PlayerState.LastDirX;
                     this._Handler_Effects.AddParticle(new particle_data(this._PlayerState.CurrentRangeWeapon.Properties.ShellEffect,shellPosX,shellPosY,new b2Vec2(-this._PlayerState.LastDirX * Math.random() * 1 - this._PlayerState.LastDirX,-Math.random() * 1 - 1),this._PlayerState.CurrentAimAngleRad));
                  }
                  if(this._PlayerState.CurrentRangeWeapon.Properties.FireSequence[realFrame - 1].UseMuzzleEffect)
                  {
                     muzzlePosX = posX;
                     muzzlePosY = posY;
                     muzzlePosX += Math.cos(this._PlayerState.CurrentAimAngle * (Math.PI / 180)) * this._char.ANIM_WPN.MUZZLE_CENTER.x;
                     muzzlePosY += Math.sin(this._PlayerState.CurrentAimAngle * (Math.PI / 180)) * this._char.ANIM_WPN.MUZZLE_CENTER.x;
                     muzzlePosY += Math.sin((this._PlayerState.CurrentAimAngle + 90) * (Math.PI / 180)) * this._char.ANIM_WPN.MUZZLE_CENTER.y * this._PlayerState.LastDirX;
                     muzzlePosX += Math.cos((this._PlayerState.CurrentAimAngle + 90) * (Math.PI / 180)) * this._char.ANIM_WPN.MUZZLE_CENTER.y * this._PlayerState.LastDirX;
                     speedVec = new b2Vec2();
                     this._Handler_Effects.AddParticle(new particle_data(this._PlayerState.CurrentRangeWeapon.Properties.MuzzleFlashEffect,muzzlePosX,muzzlePosY,speedVec,this._PlayerState.CurrentAimAngle));
                  }
                  if(this._PlayerState.CurrentRangeWeapon.Properties.FireSequence[realFrame - 1].Bullets > 0)
                  {
                     posX += Math.cos(this._PlayerState.CurrentAimAngle * (Math.PI / 180)) * this._char.ANIM_WPN.FIRE_CENTER.x;
                     posY += Math.sin(this._PlayerState.CurrentAimAngle * (Math.PI / 180)) * this._char.ANIM_WPN.FIRE_CENTER.x;
                     posY += Math.sin((this._PlayerState.CurrentAimAngle + 90) * (Math.PI / 180)) * this._char.ANIM_WPN.FIRE_CENTER.y * this._PlayerState.LastDirX;
                     posX += Math.cos((this._PlayerState.CurrentAimAngle + 90) * (Math.PI / 180)) * this._char.ANIM_WPN.FIRE_CENTER.y * this._PlayerState.LastDirX;
                     i = 0;
                     while(i < this._PlayerState.CurrentRangeWeapon.Properties.FireSequence[realFrame - 1].Bullets)
                     {
                        if(this._PlayerState.CurrentRangeWeapon.Ammo > 0)
                        {
                           randomDeflection = Math.random() * this._PlayerState.CurrentRangeWeapon.Properties.AccuracyDeflection * 2 - this._PlayerState.CurrentRangeWeapon.Properties.AccuracyDeflection;
                           switch(this._PlayerState.CurrentRangeWeapon.Properties.BulletType)
                           {
                              case "FLAME":
                                 if(!this._flameAwayActivated)
                                 {
                                    this.FlameAway();
                                    this._flameAwayTimer = setInterval(this.FlameAway,10);
                                    this._flameAwayActivated = true;
                                 }
                                 break;
                              case "BAZOOKA_ROCKET":
                                 this._Handler_ProjectilesUpdater.NewRocket("BAZOOKA_ROCKET",posX,posY,this._PlayerState.CurrentAimAngle + randomDeflection,this);
                                 break;
                              default:
                                 this._Handler_ProjectilesUpdater.NewProjectile(this._PlayerState.CurrentRangeWeapon.Properties.BulletType,posX,posY,this._PlayerState.CurrentAimAngle + randomDeflection,this);
                           }
                           --this._PlayerState.CurrentRangeWeapon.Ammo;
                        }
                        else
                        {
                           this.WeaponEmptyRecoil();
                           this._PlayerState.CurrentFireFrame = this._PlayerState.CurrentRangeWeapon.Properties.FireSequence.length - 1;
                           this._PlayerState.LastFireFrame = this._PlayerState.CurrentFireFrame;
                           i = int(this._PlayerState.CurrentRangeWeapon.Properties.FireSequence[realFrame - 1].Bullets);
                        }
                        this.UpdateGUIRanged();
                        i++;
                     }
                  }
               }
            }
            if(!this._PlayerState.AFSInProgress)
            {
               if(this._PlayerState.CurrentWeaponCooldown > 0)
               {
                  this._PlayerState.CurrentWeaponCooldown -= 1 - (1 - this._game_speed) / 2;
               }
               if(this._PlayerState.Aiming)
               {
                  if(!this.KeyPressed(5) && !this.KeyPressed(6) || Boolean(this._cancelAimingASAP))
                  {
                     if(this._PlayerState.FastTrigger)
                     {
                        if(!this._PlayerState.AimTurningAroundDelay)
                        {
                           this._PlayerState.FastTrigger = false;
                           this.AFSUpdated = false;
                           this.FireWeapon();
                        }
                     }
                     else if(this._PlayerState.BackToIdleTimer <= 0 || Boolean(this._cancelAimingASAP))
                     {
                        this._cancelAimingASAP = false;
                        this.AbortAiming();
                     }
                  }
               }
            }
         }
         catch(e:Error)
         {
         }
      }
      
      private function AbortAiming(param1:Boolean = false) : void
      {
         var _loc2_:b2Vec2 = null;
         var _loc3_:b2Body = null;
         this._PlayerState.Aiming = false;
         this._startAimASAP = false;
         this._lazer_mc.visible = false;
         this._aim_mc.visible = false;
         this.CancelAFS();
         if(this._PlayerState.CurrentRangeWeapon != null)
         {
            if(this._PlayerState.CurrentRangeWeapon.Ammo <= 0 || param1)
            {
               if(param1)
               {
                  _loc2_ = new b2Vec2(this._PlayerState.LastDirX * -2,-(2 + Math.random() * 2));
               }
               else
               {
                  _loc2_ = new b2Vec2(this._PlayerState.LastDirX * 2,-1);
               }
               _loc3_ = this._Handler_Maps.Handler_WorldItems.AddPolygon("wpn_" + this._PlayerState.CurrentRangeWeapon.Properties.WeaponType,(this.MidPosX() + this._PlayerState.LastDirX * 5) / 30,(this.MidPosY() - 3) / 30,0,_loc2_,Math.random() * 30 - 15,null,this._PlayerState.LastDirX != 1);
               _loc3_.GetUserData().weaponData = this._PlayerState.CurrentRangeWeapon;
               _loc3_.GetUserData().weaponData.Ammo = 0;
               _loc3_.GetUserData().objectData.MC.indicator.visible = false;
               _loc3_.GetUserData().objectData.MC.shine.gotoAndStop("EMPTY");
               _loc3_.GetUserData().objectData.MC.shine.visible = false;
               this._PlayerState.CurrentRangeWeapon = null;
               this.UpdateGUIRanged();
            }
         }
      }
      
      public function DiveCollision() : void
      {
         this.DropGrabbedPlayer();
         this._PlayerState.AirVelocityX = this._PlayerState.LastDirX * 3.5;
         this._PlayerState.LastDirX *= -1;
         this._PlayerState.Falling = true;
      }
      
      private function BeingKicked(param1:int, param2:Boolean = false) : void
      {
         var _loc3_:int = 0;
         this.DropGrabbedPlayer();
         _loc3_ = int(this._PlayerState.LastDirX);
         this._PlayerState.LastDirX = -param1;
         this.CheckAimDrop(true);
         if(!this._PlayerState.Burned)
         {
            this._Handler_Effects.AddParticle(new particle_data("PARTICLE_BLOOD",this.PosX(),this.PosY() - 13,new b2Vec2(param1,-0.5),0,1,[Math.floor(Math.random() * 1.99)]));
         }
         else
         {
            this._Handler_Effects.AddEffectAt("PLAYER_BURNED_HITDEFAULT",this.PosX(),this.PosY() - 13);
         }
         if(Math.random() < 0.5 || !param2)
         {
            this._PlayerState.LastDirX = _loc3_;
            this.Fall();
         }
         else
         {
            this.scaleX = this._PlayerState.LastDirX;
            this.StartStagger();
         }
         this._PlayerState.AirVelocityX = param1 * 4;
         this._PlayerState.AirVelocityY = -2;
      }
      
      public function Disarm() : void
      {
         this.CheckAimDrop(true);
      }
      
      public function SetDirection(param1:int) : void
      {
         this.scaleX = param1;
         this._collision_mc.scaleX = this.scaleX;
         this._PlayerState.LastDirX = param1;
      }
      
      public function PunchReady() : Boolean
      {
         if(this._PlayerState.Punching)
         {
            if(!this._PlayerState.PunchHitPerformed)
            {
               if(this._PlayerAnimation.NextFrame(this._game_speed) == this._PlayerState.HitPunchComboFrame)
               {
                  return true;
               }
            }
         }
         return false;
      }
      
      private function SwapDepths(param1:int) : void
      {
         if(this.parent.getChildIndex(this) < this._players[param1].parent.getChildIndex(this._players[param1]))
         {
            this.parent.swapChildren(this,this._players[param1]);
         }
      }
      
      private function DeflectBullets() : void
      {
         this._Handler_ProjectilesUpdater.DeflectBullets(this);
      }
      
      private function DeactivateSprint() : void
      {
         this._Handler_Output.Trace("Sprint Off");
         this._PlayerState.Sprinting = false;
      }
      
      private function ActivateSprint() : void
      {
         if(this._PlayerState.SprintEnergy > 0)
         {
            this._Handler_Output.Trace("Sprint On");
            this._PlayerState.Sprinting = true;
         }
      }
      
      private function MeleeStrike() : void
      {
         var _loc1_:particle_data = null;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Boolean = false;
         var _loc5_:Number = NaN;
         var _loc6_:Array = null;
         var _loc7_:Array = null;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:Boolean = false;
         var _loc11_:Array = null;
         var _loc12_:int = 0;
         var _loc13_:Number = NaN;
         this._Handler_Sounds.PlaySoundAt(this._PlayerState.MeleeSwingSound,this.MidPosX(),this.MidPosY());
         _loc1_ = new particle_data(this._PlayerState.MeleeSwingEffect,this._this_x,this._this_y);
         _loc1_.ScaleX = this._PlayerState.LastDirX;
         this._Handler_Effects.AddParticle(_loc1_);
         _loc3_ = this.MidPosY() - 4;
         _loc4_ = false;
         _loc5_ = 4;
         while(_loc5_ <= this._PlayerState.MeleeWeaponRange)
         {
            _loc2_ = this.MidPosX() + this._PlayerState.LastDirX * _loc5_;
            if(this.HitTestWorldOnly(_loc2_,_loc3_))
            {
               _loc4_ = true;
               _loc2_ = this.MidPosX() + this._PlayerState.LastDirX * (_loc5_ + 2);
               _loc5_ = this._PlayerState.MeleeWeaponRange + 1;
            }
            _loc5_++;
         }
         if(_loc4_)
         {
            this._Handler_Effects.AddParticle(new particle_data("DUST",_loc2_,_loc3_,new b2Vec2(Math.random() * 4 - 2,-Math.random() * 4)));
            this._Handler_Effects.AddEffectAt("FIST_IMPACT",_loc2_,_loc3_);
         }
         this.Kick(true);
         this._PlayerState.PunchHitPerformed = true;
         if(this._PlayerState.CurrentMeleeWeapon != null)
         {
            this.DeflectBullets();
         }
         _loc6_ = new Array();
         _loc7_ = this.EnemiesInMeleeRange();
         _loc8_ = 0;
         while(_loc8_ < _loc7_.length)
         {
            this.SwapDepths(_loc7_[_loc8_]);
            _loc10_ = false;
            if(_loc7_[_loc8_] > this.PlayerNr)
            {
               if(this._players[_loc7_[_loc8_]].PunchReady())
               {
                  _loc11_ = this._players[_loc7_[_loc8_]].EnemiesInMeleeRange();
                  _loc12_ = 0;
                  while(_loc12_ < _loc11_.length)
                  {
                     if(_loc11_[_loc12_] == this.PlayerNr)
                     {
                        _loc10_ = true;
                        _loc6_.push(_loc7_[_loc8_]);
                     }
                     _loc12_++;
                  }
               }
            }
            if(!_loc10_)
            {
               this.PunchPlayer(_loc7_[_loc8_]);
            }
            _loc8_++;
         }
         _loc9_ = 0;
         while(_loc9_ < _loc6_.length)
         {
            _loc13_ = Math.random();
            if(_loc13_ < 0.5)
            {
               this.PunchPlayer(_loc6_[_loc9_]);
            }
            else
            {
               this._PlayerState.StunTimer = 2;
               this._PlayerState.StunTimer = 2;
            }
            _loc9_++;
         }
         if(_loc7_.length > 0)
         {
            this._Handler_Sounds.PlaySoundAt(this._PlayerState.MeleeWeaponHitSound,this._this_x,this._this_y);
            this._PlayerAnimation.DelayAnimation(this._PlayerState.HitPunchComboFrame,1);
         }
         else if(this._button_in_melee_range)
         {
            this._Handler_Output.Trace("Pressing Button");
            this._Handler_Sounds.PlaySoundAt(this._button_to_activate.GetUserData().buttonData.OnActivationSound,this.MidPosX(),this.MidPosY());
            this._button_to_activate.GetUserData().buttonData.Activate();
         }
      }
      
      private function PunchPlayer(param1:int) : void
      {
         var _loc2_:Boolean = false;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         _loc2_ = false;
         if(this._players[param1].State.HP <= 0)
         {
            _loc2_ = true;
         }
         this._players[param1].SetDirection(-this._PlayerState.LastDirX);
         this._players[param1].Disarm();
         if(this._players[param1].State.Jumping)
         {
            this._players[param1].State.AirVelocityX += this._PlayerState.LastDirX * 2;
            this._players[param1].Fall();
         }
         else
         {
            this._players[param1].State.StunTimer = this._PlayerState.HitPunchStunTime;
         }
         if(this._players[param1].State.HP > 0)
         {
            this._players[param1].State.HP -= this._PlayerState.HitPunchDamage;
            if(this._players[param1].State.HP <= 0)
            {
               if(this.ActivateSlowmotion(param1))
               {
                  this._Handler_Slowmo.AddSlowmotion(new SlowmoData(0,24 * 2,24 * 1,0.2));
               }
            }
         }
         if(this._PlayerState.CurrentMeleeWeapon != null)
         {
            if(!this._players[param1].State.Burned)
            {
               _loc3_ = 0;
               while(_loc3_ < 3)
               {
                  this._Handler_Effects.AddParticle(new particle_data("PARTICLE_BLOOD",this._players[param1].PosX() - this._PlayerState.LastDirX * 2,this._players[param1].PosY() - 12 - Math.random() * 2,new b2Vec2(this._PlayerState.LastDirX,0),0,1,[Math.floor(Math.random() * 1.99)]));
                  _loc3_++;
               }
               this._Handler_Effects.AddEffectAt("BLOOD",this._players[param1].PosX() - this._PlayerState.LastDirX * 2,this._players[param1].PosY() - 12);
            }
            else
            {
               this._Handler_Effects.AddEffectAt("PLAYER_BURNED_HITDEFAULT",this._players[param1].PosX() - this._PlayerState.LastDirX * 2,this._players[param1].PosY() - 12);
            }
         }
         else
         {
            this._Handler_Effects.AddEffectAt("FIST_IMPACT",this._players[param1].PosX() - this._PlayerState.LastDirX * 2,this._players[param1].PosY() - 12);
            if(this._PlayerState.PunchComboNr >= 2)
            {
               if(!this._players[param1].State.Burned)
               {
                  _loc4_ = 0;
                  while(_loc4_ < this._PlayerState.PunchComboNr)
                  {
                     this._Handler_Effects.AddParticle(new particle_data("PARTICLE_BLOOD",this._players[param1].PosX() - this._PlayerState.LastDirX * 2,this._players[param1].PosY() - 12 - Math.random() * 2,new b2Vec2(this._PlayerState.LastDirX,0),0,1,[Math.floor(Math.random() * 1.99)]));
                     _loc4_++;
                  }
               }
               else
               {
                  this._Handler_Effects.AddEffectAt("PLAYER_BURNED_HITDEFAULT",this._players[param1].PosX() - this._PlayerState.LastDirX * 2,this._players[param1].PosY() - 12);
               }
            }
         }
         if(this._players[param1].State.HP <= 0 && !_loc2_ && (Boolean(this._players[param1].State.Running) || Boolean(this._players[param1].State.Sprinting)))
         {
            this._players[param1].State.AirVelocityX = this._players[param1].State.LastDirX * 3;
            this._players[param1].State.AirVelocityY = -2.5;
            this._players[param1].Fall();
         }
         else if(this._PlayerState.PunchComboNr == 3 || this._players[param1].State.HP <= 0)
         {
            this._players[param1].State.AirVelocityX = this._PlayerState.LastDirX * 3;
            this._players[param1].State.AirVelocityY = -2.5;
            this._players[param1].Fall();
         }
         if(this._players[param1].State.HP <= 0 && !this._players[param1].State.Knockdowned && !this._PlayerState.Falling)
         {
            this._players[param1].State.AirVelocityX = this._PlayerState.LastDirX * 2;
            this._players[param1].State.AirVelocityY = -2.5;
            this._players[param1].Fall();
         }
      }
      
      private function ButtonInMeleeRange() : Boolean
      {
         var _loc1_:int = 0;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         _loc1_ = 0;
         while(_loc1_ < this.m_world.ButtonList.length)
         {
            this.b = this.m_world.ButtonList[_loc1_];
            if(this.b.GetUserData().buttonData.Enabled)
            {
               if(this.CheckCollisionTowardsPlayer(this.MidPosX(),this.b.GetPosition().x * 30,this._PlayerState.LastDirX))
               {
                  _loc2_ = this.MidPosX() - this.b.GetPosition().x * 30;
                  _loc2_ = Math.abs(_loc2_);
                  if(_loc2_ <= 14 && _loc2_ > 4)
                  {
                     _loc3_ = this.MidPosY() - this.b.GetPosition().y * 30;
                     if(Math.abs(_loc3_) <= 10)
                     {
                        this._button_in_melee_range = true;
                        this._button_to_activate = this.m_world.ButtonList[_loc1_];
                        return true;
                     }
                  }
               }
            }
            _loc1_++;
         }
         return false;
      }
      
      public function EnemiesInMeleeRange() : Array
      {
         var _loc1_:Array = null;
         var _loc2_:* = undefined;
         _loc1_ = new Array();
         _loc2_ = 0;
         while(_loc2_ < this._players.length)
         {
            if(_loc2_ != this.PlayerNr)
            {
               if(this.Team != this._players[_loc2_].Team)
               {
                  if(this._players[_loc2_].CanBePunched)
                  {
                     if(this.CheckCollisionTowardsPlayer(this._this_x,this._players[_loc2_].PosX(),this._PlayerState.LastDirX))
                     {
                        if(this.InMeleeRange(this._players[_loc2_]))
                        {
                           _loc1_.push(_loc2_);
                        }
                     }
                  }
               }
            }
            _loc2_++;
         }
         return _loc1_;
      }
      
      private function InMeleeRange(param1:Player) : Boolean
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         _loc2_ = this._this_x - param1.PosX();
         if(Math.abs(_loc2_) <= this._PlayerState.MeleeWeaponRange + 4)
         {
            _loc3_ = this.MidPosY() - param1.MidPosY();
            if(_loc3_ >= -7 && _loc3_ <= 12.5)
            {
               return true;
            }
         }
         return false;
      }
      
      private function UsePowerup() : void
      {
         if(this._PlayerState.HP <= 0)
         {
            return;
         }
         if(this._PlayerState.CurrentPowerupWeapon != null)
         {
            this._PlayerState.SlowmotionDelay = 24;
            this._Handler_Output.Trace("Activating Slowmotion (" + this._PlayerState.CurrentPowerupWeapon.Ammo + ")");
            this._slowmotion_timer = 24 * this._PlayerState.CurrentPowerupWeapon.Ammo + 24 * 2;
            this._slowmotion_modifier = 1.2;
            this._Handler_Slowmo.AddSlowmotion(new SlowmoData(0,24 * this._PlayerState.CurrentPowerupWeapon.Ammo,24 * 1,0.2),true,this.PlayerNr);
            this._PlayerState.CurrentPowerupWeapon = null;
            this.UpdateGUI();
         }
         else if(this._PlayerState.SlowmotionDelay <= 0)
         {
            this._Handler_Slowmo.RemoveSlowmotion(this.PlayerNr);
         }
      }
      
      private function KeyPressed(param1:int) : Boolean
      {
         if(this._bot)
         {
            return this._keyPressed[param1];
         }
         return this._Handler_Keyboard.KeyIsDown(this._keys[param1]);
      }
      
      private function Melee() : void
      {
         if(this._game_speed == 0)
         {
            return;
         }
         if(this._PlayerState.AFSInProgress)
         {
            this._cancelAimingASAP = true;
            return;
         }
         if(this._PlayerState.Aiming)
         {
            this.AbortAiming();
            return;
         }
         if(this._PlayerState.CanGrabWeapon)
         {
            if(this.KeyPressed(KEY_KNEEL))
            {
               if(this.GrabWeapon())
               {
                  this.UpdateGUI();
                  return;
               }
            }
         }
         if(Boolean(this._PlayerState.ControllAble) && !this._PlayerState.Jumping)
         {
            this._button_in_melee_range = false;
            if(this.EnemiesInMeleeRange().length > 0)
            {
               this.Punch(true);
            }
            else if(this.ButtonInMeleeRange())
            {
               this.Punch();
            }
            else if(!this.Kick())
            {
               this.Punch();
            }
         }
         else if(this._PlayerState.ControllAble)
         {
            this._PlayerState.QueueJumpKick = true;
         }
         else if(this._PlayerState.Punching)
         {
            if(this._PlayerAnimation.CurrentFrame >= this._PlayerState.MinPunchComboFrame)
            {
               if(this._PlayerState.PunchComboNr < 3)
               {
                  this._PlayerState.PunchComboNr += 1;
               }
               if(this.EnemiesInMeleeRange().length > 0)
               {
                  this._button_in_melee_range = false;
               }
            }
         }
      }
      
      private function Punch(param1:Boolean = false) : void
      {
         this._PlayerState.Punching = true;
         this._PlayerAnimation.ShowAnimation(this._PlayerState.MeleeAnimation + "_0" + this._PlayerState.PunchComboNr,true);
      }
      
      private function KickHit(param1:b2Body, param2:Boolean, param3:Boolean = false) : Boolean
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         if(param2)
         {
            if(this._standingOnObject == param1)
            {
               return false;
            }
         }
         _loc6_ = int(this._PlayerState.LastDirX);
         if(param2)
         {
            _loc4_ = 0;
            loop0:
            while(_loc4_ <= this._PlayerState.MeleeWeaponRange)
            {
               _loc5_ = -16;
               while(true)
               {
                  if(_loc5_ > 0)
                  {
                     _loc4_ += 2;
                     continue loop0;
                  }
                  if(param1.m_userData.objectData.ShapeMC.hitTestPoint(this._this_x + _loc4_ * _loc6_,this._this_y + _loc5_,true))
                  {
                     break;
                  }
                  _loc5_ += 2;
               }
               return true;
            }
         }
         else if(param3)
         {
            _loc4_ = 0;
            loop2:
            while(_loc4_ <= 16)
            {
               _loc5_ = -16;
               while(true)
               {
                  if(_loc5_ > 0)
                  {
                     _loc4_ += 2;
                     continue loop2;
                  }
                  if(param1.m_userData.objectData.ShapeMC.hitTestPoint(this._this_x + _loc4_ * _loc6_,this._this_y + _loc5_,true))
                  {
                     break;
                  }
                  _loc5_ += 2;
               }
               return true;
            }
         }
         else
         {
            _loc4_ = 0;
            loop1:
            while(_loc4_ <= 8)
            {
               _loc5_ = -8;
               while(true)
               {
                  if(_loc5_ > 4)
                  {
                     _loc4_ += 2;
                     continue loop1;
                  }
                  if(param1.m_userData.objectData.ShapeMC.hitTestPoint(this._this_x + _loc4_ * _loc6_,this._this_y + _loc5_,true))
                  {
                     break;
                  }
                  _loc5_ += 2;
               }
               return true;
            }
         }
         return false;
      }
      
      private function Kick(param1:Boolean = false, param2:Boolean = false) : Boolean
      {
         var _loc3_:Boolean = false;
         var _loc4_:Number = NaN;
         var _loc5_:b2Body = null;
         var _loc6_:int = 0;
         var _loc7_:Boolean = false;
         var _loc8_:* = undefined;
         var _loc9_:b2Vec2 = null;
         var _loc10_:b2Vec2 = null;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:int = 0;
         if(!param1 && !param2)
         {
            if(this._PlayerState.KickingCooldown > 0)
            {
               return false;
            }
         }
         _loc3_ = false;
         _loc6_ = 0;
         while(_loc6_ < this.m_world.DynamicObjectList.length)
         {
            _loc5_ = this.m_world.DynamicObjectList[_loc6_];
            if(_loc5_.m_userData.objectData.Kickable)
            {
               if(this.KickHit(_loc5_,param1,param2))
               {
                  if(_loc5_.m_userData.objectData.KickPower == 0)
                  {
                     if(_loc5_.m_userData.objectData.KickWeightCalculation)
                     {
                        _loc4_ = this._PlayerState.KickPower * _loc5_.GetMass();
                     }
                     else
                     {
                        _loc4_ = Number(this._PlayerState.KickPower);
                     }
                  }
                  else if(_loc5_.m_userData.objectData.KickWeightCalculation)
                  {
                     _loc4_ = _loc5_.m_userData.objectData.KickPower * _loc5_.GetMass();
                  }
                  else
                  {
                     _loc4_ = Number(_loc5_.m_userData.objectData.KickPower);
                  }
                  _loc9_ = _loc9_ = new b2Vec2(this._PlayerState.LastDirX * _loc4_,-_loc4_);
                  _loc10_ = _loc5_.GetPosition();
                  _loc5_.ApplyImpulse(_loc9_,_loc10_);
                  _loc10_ = new b2Vec2((this._this_x + this._PlayerState.LastDirX * 4) / 30,(this._this_y - 4) / 30);
                  if(_loc5_.GetMass() < 1)
                  {
                     _loc9_ = new b2Vec2(0,-0.4 * _loc5_.GetMass());
                  }
                  else
                  {
                     _loc9_ = new b2Vec2(0,-0.4);
                  }
                  _loc5_.ApplyImpulse(_loc9_,_loc10_);
                  _loc11_ = _loc5_.GetPosition().x * 30;
                  if(Math.abs(this._this_x - _loc11_) > this._PlayerState.MeleeWeaponRange)
                  {
                     _loc11_ = this.MidPosX() + this._PlayerState.LastDirX * this._PlayerState.MeleeWeaponRange;
                  }
                  if(param1)
                  {
                     _loc5_.GetUserData().objectData.Damage_Impact(this._PlayerState.HitPunchDamage);
                     this._Handler_Sounds.PlaySoundAt(this._PlayerState.GetMeleeMaterialHitSound(_loc5_.GetUserData().material.Type),this.MidPosX(),this.MidPosY());
                     _loc12_ = 4;
                     while(_loc12_ <= this._PlayerState.MeleeWeaponRange)
                     {
                        if(_loc5_.m_userData.objectData.ShapeMC.hitTestPoint(this.MidPosX() + this._PlayerState.LastDirX * _loc12_,this._this_y - 12,true))
                        {
                           _loc11_ = this.MidPosX() + this._PlayerState.LastDirX * _loc12_;
                           _loc12_ = this._PlayerState.MeleeWeaponRange + 1;
                        }
                        _loc12_++;
                     }
                     this._Handler_Effects.AddEffectAt("FIST_IMPACT",_loc11_,this._this_y - 12);
                     this._Handler_Effects.AddEffectAt(this._PlayerState.GetMeleeMaterialHitEffect(_loc5_.GetUserData().material.Type),_loc11_,this._this_y - 12);
                  }
                  else
                  {
                     if(param2)
                     {
                        _loc5_.GetUserData().objectData.Damage_Impact(this._PlayerState.JumpKickDamage);
                     }
                     else
                     {
                        _loc5_.GetUserData().objectData.Damage_Impact(this._PlayerState.KickDamage);
                     }
                     this._Handler_Sounds.PlaySoundAt(this._PlayerState.GetKickMaterialHitSound(_loc5_.GetUserData().material.Type),this.MidPosX(),this.MidPosY());
                     _loc12_ = 4;
                     while(_loc12_ <= this._PlayerState.MeleeWeaponRange)
                     {
                        if(_loc5_.m_userData.objectData.ShapeMC.hitTestPoint(this.MidPosX() + this._PlayerState.LastDirX * _loc12_,this._this_y - 6,true))
                        {
                           _loc11_ = this.MidPosX() + this._PlayerState.LastDirX * _loc12_;
                           _loc12_ = this._PlayerState.MeleeWeaponRange + 1;
                        }
                        _loc12_++;
                     }
                     this._Handler_Effects.AddEffectAt(this._PlayerState.GetKickMaterialHitEffect(_loc5_.GetUserData().material.Type),_loc11_,this._this_y - 6);
                     this._Handler_Effects.AddEffectAt("KICK_IMPACT",_loc11_,this._this_y - 6);
                     _loc3_ = true;
                  }
               }
            }
            _loc6_++;
         }
         if(_loc3_)
         {
            if(param1)
            {
               _loc13_ = 1;
               while(_loc13_ <= 2)
               {
                  this._Handler_Effects.AddParticle(new particle_data("DUST",this._this_x + this._PlayerState.LastDirX * (6 + Math.random() * 2),this._this_y - 10 - Math.random() * 2,new b2Vec2(this._PlayerState.LastDirX * Math.random() * 4,-Math.random() * 4)));
                  _loc13_++;
               }
            }
            else
            {
               _loc13_ = 1;
               while(_loc13_ <= 2)
               {
                  this._Handler_Effects.AddParticle(new particle_data("DUST",this._this_x + this._PlayerState.LastDirX * (6 + Math.random() * 2),this._this_y - 3 - Math.random() * 2,new b2Vec2(this._PlayerState.LastDirX * Math.random() * 4,-Math.random() * 4)));
                  _loc13_++;
               }
            }
         }
         if(param1)
         {
            return false;
         }
         _loc7_ = false;
         _loc8_ = 0;
         while(_loc8_ < this._players.length)
         {
            if(_loc8_ != this.PlayerNr)
            {
               if(this.Team != this._players[_loc8_].Team)
               {
                  if(this.CanKickPlayer(this._players[_loc8_],param2))
                  {
                     _loc7_ = true;
                     this.SwapDepths(_loc8_);
                     if(this._players[_loc8_].State.HP > 0)
                     {
                        if(param2)
                        {
                           this._players[_loc8_].State.HP -= this._PlayerState.JumpKickDamage;
                        }
                        else
                        {
                           this._players[_loc8_].State.HP -= this._PlayerState.KickDamage;
                        }
                        if(this._players[_loc8_].State.HP <= 0)
                        {
                           if(this.ActivateSlowmotion(_loc8_))
                           {
                              this._Handler_Slowmo.AddSlowmotion(new SlowmoData(0,24 * 2,24 * 1,0.2));
                           }
                           this._players[_loc8_].BeingKicked(this._PlayerState.LastDirX);
                        }
                        else
                        {
                           this._players[_loc8_].BeingKicked(this._PlayerState.LastDirX,param2);
                        }
                     }
                     else
                     {
                        this._players[_loc8_].BeingKicked(this._PlayerState.LastDirX);
                     }
                  }
               }
            }
            _loc8_++;
         }
         if(_loc7_)
         {
            this._Handler_Sounds.PlaySoundAt("kick",this._this_x,this._this_y);
            this._Handler_Effects.AddEffectAt("KICK_IMPACT",this._this_x + this._PlayerState.LastDirX * 6,this._this_y - 2);
         }
         if(_loc3_ || _loc7_)
         {
            this._PlayerAnimation.ShowAnimation("kick",true);
            this._PlayerState.Kicking = true;
            if(!param1 && !param2)
            {
               this._Handler_Sounds.PlaySoundAt("KICK_SWING",this.PosX(),this.PosY());
            }
            return true;
         }
         return false;
      }
      
      private function CanKickPlayer(param1:Player, param2:Boolean = false) : Boolean
      {
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         if(param1.State.CanBeKicked)
         {
            if(this.CheckCollisionTowardsPlayer(this._this_x,param1.PosX(),this._PlayerState.LastDirX))
            {
               _loc3_ = this.PosX() - param1.PosX();
               if(Math.abs(_loc3_) <= 16)
               {
                  _loc4_ = this.PosY() - param1.PosY();
                  _loc5_ = -4;
                  _loc6_ = -16;
                  if(param1.State.Knockdowned)
                  {
                     _loc6_ = -8;
                     if(param2)
                     {
                        _loc5_ = 8;
                     }
                     else
                     {
                        _loc5_ = 2;
                     }
                  }
                  else if(param2)
                  {
                     _loc5_ = 16;
                  }
                  if(_loc4_ <= _loc5_ && _loc4_ >= _loc6_)
                  {
                     return true;
                  }
               }
            }
         }
         return false;
      }
      
      public function Fall(param1:Boolean = true) : void
      {
         if(!this._PlayerState.Falling)
         {
            this._lastBounceY = this._this_y;
            this.DropGrabbedPlayer();
            this.CheckAimDrop();
            if(this._PlayerState.Knockdowned)
            {
               if(this._PlayerState.AirVelocityY > -0.1)
               {
                  this._PlayerState.AirVelocityY = -0.1;
               }
            }
            if(param1)
            {
               if(this.PressingRight())
               {
                  this._PlayerState.AirVelocityX += this._PlayerState.RunSpeed - 1;
               }
               if(this.PressingLeft())
               {
                  this._PlayerState.AirVelocityX -= this._PlayerState.RunSpeed - 1;
               }
            }
            else if(this._PlayerState.Staggering)
            {
               this._PlayerState.AirVelocityX = -this._PlayerState.LastDirX * this._PlayerState.StaggerSpeed;
               this._PlayerState.AirVelocityY = -2;
            }
            this._PlayerState.Falling = true;
         }
      }
      
      private function CanDive() : Boolean
      {
         if(this.CollisionHead())
         {
            return false;
         }
         return true;
      }
      
      private function KeyTurnPlayer() : void
      {
         if(this.PressingLeft())
         {
            if(this._PlayerState.LastDirX != -1)
            {
               this._PlayerState.LastDirX = -1;
               this.scaleX = this._PlayerState.LastDirX;
               this._collision_mc.scaleX = this.scaleX;
            }
         }
         else if(this.PressingRight())
         {
            if(this._PlayerState.LastDirX != 1)
            {
               this._PlayerState.LastDirX = 1;
               this.scaleX = this._PlayerState.LastDirX;
               this._collision_mc.scaleX = this.scaleX;
            }
         }
      }
      
      private function Dive() : void
      {
         if(!this.CanDive())
         {
            return;
         }
         this.KeyTurnPlayer();
         if(!this._PlayerState.ShortDiveAvailable)
         {
            this._PlayerState.DiveSpeed = 3.5;
         }
         else
         {
            this._PlayerState.DiveSpeed = 1;
         }
         this._Handler_Sounds.PlaySoundAt("JUMP",this.PosX(),this.PosY());
         this._PlayerState.Diving = true;
         this._PlayerState.Jumping = true;
         this._PlayerState.AirVelocityX += this._PlayerState.LastDirX * this._PlayerState.DiveSpeed;
         this._PlayerState.AirVelocityY -= 3;
         this._this_y -= 6;
         this._this_x += this._PlayerState.MovingDirectionX;
         this.DrainEnergy("SPRINT_DIVE");
      }
      
      private function Roll() : void
      {
         this._Handler_Sounds.PlaySoundAt("ROLL",this.PosX(),this.PosY());
         this.DrainEnergy("ROLL");
         this._PlayerState.DecreaseBurnState();
         this._PlayerState.Rolling = true;
      }
      
      private function BeginJump() : void
      {
         if(Boolean(this.CheckForceKneeling()) || !this._PlayerState.ControllAble || Boolean(this.CollisionHead(-2)))
         {
            return;
         }
         if(this.PressingLeft(true))
         {
            this.scaleX = -1;
         }
         if(this.PressingRight(true))
         {
            this.scaleX = 1;
         }
         this._PlayerState.LastDirX = this.scaleX;
         this._collision_mc.scaleX = this.scaleX;
         if(this._PlayerState.SprintEnergy <= 0)
         {
            this._PlayerState.Sprinting = false;
         }
         this._Handler_Sounds.PlaySoundAt("JUMP",this.PosX(),this.PosY());
         this._PlayerAnimation.ShowAnimation("jump",true);
         this.UpdateDynamicMovement(true);
         this._PlayerState.AirVelocityY += this._PlayerState.PlayerJumpPower;
         this._PlayerState.Jumping = true;
         this._PlayerState.JumpPushTimeLeft = this._PlayerState.PlayerJumpPushTime;
         this._PlayerState.PlayerJumpPushEnabled = true;
         if(this._PlayerState.Sprinting)
         {
            this.DrainEnergy("SPRINT_JUMP");
         }
         else
         {
            this.DrainEnergy("JUMP");
         }
      }
      
      private function DrainEnergy(param1:String) : void
      {
         switch(param1)
         {
            case "SPRINT_JUMP":
               this._PlayerState.SprintEnergy -= 12;
               break;
            case "JUMP":
               this._PlayerState.SprintEnergy -= 5;
               break;
            case "SPRINT_DIVE":
               this._PlayerState.SprintEnergy -= 12;
               break;
            case "ROLL":
               this._PlayerState.SprintEnergy -= 5;
         }
      }
      
      private function KillPlayer() : void
      {
      }
      
      public function Remove() : void
      {
         this.Disarm();
         this.CancelAFS();
         this.IgnorePlayer();
         this._PlayerState.CameraIgnoreTimer = 0;
         this._PlayerState.Gone = true;
         if(this._PlayerAnimation.UseGUI)
         {
            this._char_gui.visible = false;
            this._blood_gui.visible = false;
            this._gui_mc.gib_pic.alpha = 1;
         }
         this._PlayerState.BurnState = 0;
      }
      
      public function GibPlayer() : void
      {
         if(this.ActivateSlowmotion(this.PlayerNr))
         {
            this._Handler_Slowmo.AddSlowmotion(new SlowmoData(0,24 * 2,24 * 1,0.2));
         }
         this.Disarm();
         this.CancelAFS();
         this._Handler_Maps.Handler_WorldItems.AddBox("char_gib_01",(this._this_x + Math.random() * 8 - 4) / 30,(this._this_y - 1) / 30,Math.random() * Math.PI,new b2Vec2(Math.random() * 6 - 3,-Math.random() * 4 + 3),Math.random() * Math.PI - Math.PI / 2);
         this._Handler_Maps.Handler_WorldItems.AddBox("char_gib_02",(this._this_x + Math.random() * 8 - 4) / 30,(this._this_y - 2) / 30,Math.random() * Math.PI,new b2Vec2(Math.random() * 6 - 3,-Math.random() * 4 + 3),Math.random() * Math.PI - Math.PI / 2);
         this._Handler_Maps.Handler_WorldItems.AddBox("char_gib_03",(this._this_x + Math.random() * 8 - 4) / 30,(this._this_y - 5) / 30,Math.random() * Math.PI,new b2Vec2(Math.random() * 6 - 3,-Math.random() * 4 + 3),Math.random() * Math.PI - Math.PI / 2);
         this._Handler_Maps.Handler_WorldItems.AddBox("char_gib_04",(this._this_x + Math.random() * 8 - 4) / 30,(this._this_y - 7) / 30,Math.random() * Math.PI,new b2Vec2(Math.random() * 6 - 3,-Math.random() * 4 + 3),Math.random() * Math.PI - Math.PI / 2);
         this._Handler_Maps.Handler_WorldItems.AddBox("char_gib_05",(this._this_x + Math.random() * 8 - 4) / 30,(this._this_y - 8) / 30,Math.random() * Math.PI,new b2Vec2(Math.random() * 6 - 3,-Math.random() * 4 + 3),Math.random() * Math.PI - Math.PI / 2);
         this._Handler_Effects.AddEffectAt("gib",this._this_x,this._this_y);
         this._Handler_Sounds.PlaySoundAt("gib",this._this_x,this._this_y);
         this.IgnorePlayer();
         this._PlayerState.CameraIgnoreTimer = 24 * 2;
         this._PlayerState.Gone = true;
         if(this._PlayerAnimation.UseGUI)
         {
            this._char_gui.visible = false;
            this._blood_gui.visible = false;
            this._gui_mc.gib_pic.alpha = 1;
         }
         this._PlayerState.BurnState = 0;
         this._Handler_Output.Trace("Gib player");
      }
      
      public function IgnorePlayer() : void
      {
         if(this._PlayerState.GrabbedPlayer)
         {
            this._players[this._PlayerState.GrabbedPlayerNr].SetCoordinates(this._this_x,this._this_y);
            this._players[this._PlayerState.GrabbedPlayerNr].GrabbedByOtherPlayer(false,this._PlayerState.LastDirX);
            this._PlayerState.GrabbedPlayer = false;
         }
         this._PlayerBars.Hide();
         this._PlayerState.TakingCover = false;
         this._PlayerState.CoverObjectID = -1;
         this._PlayerState.HP = 0;
         if(this._PlayerAnimation.UseGUI)
         {
            this._char_gui.visible = false;
            this._blood_gui.visible = false;
            this._gui_mc.gib_pic.alpha = 1;
         }
         this._PlayerState.CameraIgnoreTimer = 24 * 2;
         this.visible = false;
         this._collision_mc.visible = false;
         this._collision_mc.x = 9999;
         this._collision_mc.y = 9999;
         this._player_area_mc.x = 9999;
         this._player_area_mc.y = 9999;
         this._PlayerState.IgnoreMe = true;
      }
      
      public function Revive(param1:Number, param2:Number) : void
      {
         this._PlayerBars.Show();
         this.visible = true;
         this._PlayerState.ForceHP = 100;
         this._collision_mc.visible = true;
         this._collision_mc.x = param1;
         this._collision_mc.y = param2;
         this._player_area_mc.x = param1;
         this._player_area_mc.y = param2;
         this._this_x = param1;
         this._this_y = param2;
         this._PlayerState.IgnoreMe = false;
         this._char_gui.visible = true;
         this._blood_gui.visible = true;
         this._gui_mc.gib_pic.alpha = 0;
         this._PlayerState.Gone = false;
         this._PlayerState.AirVelocityX = 0;
         this._PlayerState.AirVelocityY = 0;
         this._PlayerState.Falling = false;
         this._PlayerState.Knockdowned = false;
         this._PlayerState.Jumping = true;
      }
      
      private function GetStaticBodyAt(param1:Number, param2:Number) : b2Body
      {
         if(this.HitTestWorldOnly(param1,param2))
         {
            return this.m_world.GetStaticBodyAt(param1,param2);
         }
         return null;
      }
      
      private function GetStaticCoverAt(param1:Number, param2:Number) : b2Body
      {
         if(this._static_world_hitbox_mc.hitTestPoint(param1,param2,true))
         {
            return this.m_world.GetStaticCoverAt(param1,param2);
         }
         return null;
      }
      
      private function GetDynamicBodyAt(param1:Number, param2:Number, param3:Boolean) : b2Body
      {
         if(this._static_objects_hitbox_mc.hitTestPoint(param1,param2,true))
         {
            return this.m_world.GetDynamicBodyAt(param1,param2,param3);
         }
         return null;
      }
      
      private function HitTestWorldOnly(param1:Number, param2:Number) : Boolean
      {
         if(this._static_world_hitbox_mc.hitTestPoint(param1,param2,true))
         {
            if(!this._static_objects_hitbox_mc.hitTestPoint(param1,param2,true))
            {
               return true;
            }
         }
         return false;
      }
      
      private function HitTestWorld(param1:Number, param2:Number) : Boolean
      {
         if(this._static_world_hitbox_mc.hitTestPoint(param1,param2,true))
         {
            return true;
         }
         if(this._static_world_cloud_hitbox_mc.hitTestPoint(param1,param2,true))
         {
            return true;
         }
         return false;
      }
      
      private function CheckForceKnockdown() : Boolean
      {
         return this.CheckCollisionHeight(6,12);
      }
      
      private function CheckForceKneeling() : Boolean
      {
         return this.CheckCollisionHeight(12,this._PlayerState.MaxPlayerHeight);
      }
      
      private function CheckCollisionHeight(param1:Number, param2:Number) : Boolean
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:b2Body = null;
         var _loc6_:b2Vec2 = null;
         var _loc7_:int = 0;
         this._headColl = false;
         this._sideColl = false;
         _loc3_ = param2;
         while(_loc3_ >= param1)
         {
            if(Boolean(this._static_world_hitbox_mc.hitTestPoint(this._this_x,this._this_y - _loc3_,true)) && (Boolean(this._static_world_hitbox_mc.hitTestPoint(this._this_x - this._PlayerState.PlayerEdgeDistance,this._this_y - _loc3_,true)) || Boolean(this._static_world_hitbox_mc.hitTestPoint(this._this_x + this._PlayerState.PlayerEdgeDistance,this._this_y - _loc3_,true))))
            {
               this._headColl = true;
               break;
            }
            _loc3_ -= 2;
         }
         if(!this._headColl)
         {
            _loc4_ = -this._PlayerState.PlayerEdgeDistance;
            while(_loc4_ <= this._PlayerState.PlayerEdgeDistance)
            {
               _loc5_ = this.GetDynamicBodyAt(this._this_x + _loc4_,this._this_y - param2,false);
               if(_loc5_ != null)
               {
                  if(_loc5_.GetUserData().objectData.CanGibb)
                  {
                     _loc6_ = _loc5_.GetLinearVelocity();
                     if(Math.abs(_loc6_.x) > 0.01)
                     {
                        if(this.CheckCollisionTowardsPlayer(this._this_x + _loc4_,this._this_x,this.ConvertToDirection(_loc6_.x)))
                        {
                           this._headColl = true;
                           this._sideColl = true;
                           break;
                        }
                     }
                  }
               }
               _loc4_ += this._PlayerState.PlayerEdgeDistance * 2;
            }
         }
         if(!this._sideColl)
         {
            this._edgePositionL = this._this_x - this._PlayerState.PlayerEdgeDistance;
            this._edgePositionR = this._this_x + this._PlayerState.PlayerEdgeDistance;
            _loc7_ = param2;
            while(_loc7_ >= param1)
            {
               if(Boolean(this._static_world_hitbox_mc.hitTestPoint(this._edgePositionL,this._this_y - _loc7_,true)) || Boolean(this._static_world_hitbox_mc.hitTestPoint(this._edgePositionR,this._this_y - _loc7_,true)))
               {
                  this._sideColl = true;
                  break;
               }
               _loc7_ -= 2;
            }
         }
         if(this._headColl && this._sideColl)
         {
            return true;
         }
         return false;
      }
      
      private function WorldCollisionHead() : Boolean
      {
         var _loc1_:int = 0;
         if(Boolean(this.HitTestWorldOnly(this._this_x,this._this_y - this._PlayerState.PlayerHeight)) && (Boolean(this.HitTestWorldOnly(this._this_x - this._PlayerState.PlayerEdgeDistance,this._this_y - this._PlayerState.PlayerHeight)) || Boolean(this.HitTestWorldOnly(this._this_x + this._PlayerState.PlayerEdgeDistance,this._this_y - this._PlayerState.PlayerHeight))))
         {
            return true;
         }
         _loc1_ = 4;
         while(_loc1_ <= this._PlayerState.PlayerHeight - 2)
         {
            if(Boolean(this.HitTestWorldOnly(this._this_x - this._PlayerState.PlayerEdgeDistance,this._this_y - _loc1_)) && Boolean(this.HitTestWorldOnly(this._this_x,this._this_y - _loc1_)) && Boolean(this.HitTestWorldOnly(this._this_x + this._PlayerState.PlayerEdgeDistance,this._this_y - _loc1_)))
            {
               return true;
            }
            _loc1_ += 2;
         }
         return false;
      }
      
      private function CollisionHead(param1:Number = 0) : Boolean
      {
         var _loc2_:int = 0;
         if(Boolean(this._static_world_hitbox_mc.hitTestPoint(this._this_x,this._this_y - this._PlayerState.PlayerHeight + param1,true)) && (Boolean(this._static_world_hitbox_mc.hitTestPoint(this._this_x - this._PlayerState.PlayerEdgeDistance,this._this_y - this._PlayerState.PlayerHeight + param1,true)) || Boolean(this._static_world_hitbox_mc.hitTestPoint(this._this_x + this._PlayerState.PlayerEdgeDistance,this._this_y - this._PlayerState.PlayerHeight + param1,true))))
         {
            return true;
         }
         _loc2_ = 4;
         while(_loc2_ <= this._PlayerState.PlayerHeight - 2)
         {
            if(Boolean(this._static_world_hitbox_mc.hitTestPoint(this._this_x - this._PlayerState.PlayerEdgeDistance,this._this_y - _loc2_ + param1,true)) && Boolean(this._static_world_hitbox_mc.hitTestPoint(this._this_x,this._this_y - _loc2_,true)) && Boolean(this._static_world_hitbox_mc.hitTestPoint(this._this_x + this._PlayerState.PlayerEdgeDistance,this._this_y - _loc2_ + param1,true)))
            {
               return true;
            }
            _loc2_ += 2;
         }
         return false;
      }
      
      private function CanStagger() : Boolean
      {
         if(this._PlayerState.HP <= 0 && Boolean(this._PlayerState.Knockdowned))
         {
            return false;
         }
         return !this.StaggerCollision(-this._PlayerState.LastDirX);
      }
      
      private function StaggerCollision(param1:int) : Boolean
      {
         var _loc2_:int = 0;
         _loc2_ = 2;
         while(_loc2_ <= 6)
         {
            if(this._static_world_hitbox_mc.hitTestPoint(this._this_x + (_loc2_ - 1) * param1,this._this_y - 3 - _loc2_,true))
            {
               this._staggerFragileObject = this.m_world.GetGlassAt(this._this_x + (_loc2_ - 1) * param1,this._this_y - 3 - _loc2_);
               if(this._staggerFragileObject == null)
               {
                  return true;
               }
               return false;
            }
            _loc2_ += 2;
         }
         return false;
      }
      
      private function WalkCollision(param1:int, param2:Boolean) : Boolean
      {
         var _loc3_:int = 0;
         _loc3_ = 2;
         while(_loc3_ <= 4)
         {
            if(this._static_world_hitbox_mc.hitTestPoint(this._this_x + (_loc3_ - 1) * param1,this._this_y - 2 - _loc3_,true))
            {
               return true;
            }
            _loc3_ += 2;
         }
         return false;
      }
      
      private function WorldCollisionSide(param1:Number, param2:Number = -1) : Boolean
      {
         var _loc3_:int = 0;
         if(param2 < 0)
         {
            param2 = Number(this._PlayerState.PlayerEdgeDistance);
         }
         this._edgePosition = this._this_x + param2 * this.ConvertToDirection(param1);
         _loc3_ = 4;
         while(_loc3_ <= this._PlayerState.PlayerHeight - 2)
         {
            if(this.HitTestWorldOnly(this._edgePosition,this._this_y - _loc3_))
            {
               return true;
            }
            _loc3_ += 2;
         }
         return false;
      }
      
      private function CanBounceAtDirection(param1:Number) : Boolean
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         _loc2_ = 2;
         loop0:
         while(_loc2_ <= 12)
         {
            this._edgePosition = this._this_x + param1 * _loc2_;
            _loc3_ = 2;
            while(true)
            {
               if(_loc3_ > 20)
               {
                  _loc2_ += 2;
                  continue loop0;
               }
               if(this._static_world_hitbox_mc.hitTestPoint(this._edgePosition,this._this_y - _loc3_,true))
               {
                  break;
               }
               _loc3_ += 4;
            }
            return false;
         }
         return true;
      }
      
      private function StandingOnCloud() : Boolean
      {
         var _loc1_:int = 0;
         _loc1_ = 0;
         while(_loc1_ <= 4)
         {
            if(this._static_world_cloud_hitbox_mc.hitTestPoint(this._this_x,this._this_y + _loc1_,true))
            {
               return true;
            }
            _loc1_ += 1;
         }
         return false;
      }
      
      private function CollisionSide(param1:Number, param2:Number = -1) : Boolean
      {
         var _loc3_:int = 0;
         if(param1 == 0)
         {
            return false;
         }
         if(param2 <= 0)
         {
            param2 = Number(this._PlayerState.PlayerEdgeDistance);
         }
         this._edgePosition = this._this_x + param2 * this.ConvertToDirection(param1);
         _loc3_ = 6;
         while(_loc3_ <= this._PlayerState.PlayerHeight - 2)
         {
            if(this._static_world_hitbox_mc.hitTestPoint(this._edgePosition,this._this_y - _loc3_,true))
            {
               return true;
            }
            _loc3_ += 2;
         }
         return false;
      }
      
      private function CanLandInMid() : Boolean
      {
         var _loc1_:int = 0;
         _loc1_ = 0;
         while(_loc1_ <= this._PlayerState.PlayerEdgeDistance)
         {
            if(!this._performJumpDownLevel)
            {
               if(this._static_world_cloud_hitbox_mc.hitTestPoint(this._this_x,this._this_y + _loc1_,true))
               {
                  return true;
               }
            }
            if(this._static_world_hitbox_mc.hitTestPoint(this._this_x,this._this_y + _loc1_,true))
            {
               return true;
            }
            _loc1_ += 2;
         }
         return false;
      }
      
      private function CollisionFeetMidUp(param1:Number = 0, param2:Number = 0) : Boolean
      {
         if(Boolean(this.CloudCollisionUp(this._this_x,this._this_y + param1,true)) && !this._performJumpDownLevel)
         {
            return true;
         }
         if(this._static_world_hitbox_mc.hitTestPoint(this._this_x,this._this_y + param1,true))
         {
            return true;
         }
         if(param2 != 0)
         {
            if(Boolean(this.CloudCollisionUp(this._this_x + param2,this._this_y + param1,true)) && !this._performJumpDownLevel)
            {
               return true;
            }
            if(this._static_world_hitbox_mc.hitTestPoint(this._this_x + param2,this._this_y + param1,true))
            {
               return true;
            }
            if(Boolean(this.CloudCollisionUp(this._this_x - param2,this._this_y + param1,true)) && !this._performJumpDownLevel)
            {
               return true;
            }
            if(this._static_world_hitbox_mc.hitTestPoint(this._this_x - param2,this._this_y + param1,true))
            {
               return true;
            }
         }
         return false;
      }
      
      private function CollisionFeetMid(param1:Number = 0, param2:Number = 0, param3:Boolean = false) : Boolean
      {
         if(Boolean(this._static_world_cloud_hitbox_mc.hitTestPoint(this._this_x,this._this_y + param1,true)) && !this._performJumpDownLevel)
         {
            return true;
         }
         if(this._static_world_hitbox_mc.hitTestPoint(this._this_x,this._this_y + param1,true))
         {
            return true;
         }
         if(param2 != 0)
         {
            if(Boolean(this._static_world_cloud_hitbox_mc.hitTestPoint(this._this_x + param2,this._this_y + param1,true)) && !this._performJumpDownLevel)
            {
               return true;
            }
            if(this._static_world_hitbox_mc.hitTestPoint(this._this_x + param2,this._this_y + param1,true))
            {
               return true;
            }
            if(Boolean(this._static_world_cloud_hitbox_mc.hitTestPoint(this._this_x - param2,this._this_y + param1,true)) && !this._performJumpDownLevel)
            {
               return true;
            }
            if(this._static_world_hitbox_mc.hitTestPoint(this._this_x - param2,this._this_y + param1,true))
            {
               return true;
            }
         }
         return false;
      }
      
      private function CollisionFeetBothSides() : Boolean
      {
         var _loc1_:int = 0;
         _loc1_ = 2;
         while(_loc1_ <= this._PlayerState.PlayerEdgeDistance)
         {
            if(Boolean(this._static_world_cloud_hitbox_mc.hitTestPoint(this._this_x - _loc1_,this._this_y,true)) && Boolean(this._static_world_cloud_hitbox_mc.hitTestPoint(this._this_x + _loc1_,this._this_y,true)) && !this._performJumpDownLevel)
            {
               return true;
            }
            if(Boolean(this._static_world_hitbox_mc.hitTestPoint(this._this_x - _loc1_,this._this_y,true)) && Boolean(this._static_world_hitbox_mc.hitTestPoint(this._this_x + _loc1_,this._this_y,true)))
            {
               return true;
            }
            _loc1_ += 2;
         }
         return false;
      }
      
      private function CollisionFeetSides(param1:Number = 0, param2:Number = 0) : Boolean
      {
         var _loc3_:int = 0;
         if(param2 == 0)
         {
            param2 = Number(this._PlayerState.PlayerEdgeDistance);
         }
         _loc3_ = 2;
         while(_loc3_ <= param2)
         {
            if(Boolean(this._static_world_hitbox_mc.hitTestPoint(this._this_x - _loc3_,this._this_y + param1,true)) || Boolean(this._static_world_hitbox_mc.hitTestPoint(this._this_x + _loc3_,this._this_y + param1,true)))
            {
               return true;
            }
            if(!this._performJumpDownLevel)
            {
               if(Boolean(this._static_world_cloud_hitbox_mc.hitTestPoint(this._this_x - _loc3_,this._this_y + param1,true)) || Boolean(this._static_world_cloud_hitbox_mc.hitTestPoint(this._this_x + _loc3_,this._this_y + param1,true)))
               {
                  return true;
               }
            }
            _loc3_ += 2;
         }
         return false;
      }
      
      private function CloudCollisionUp(param1:Number, param2:Number, param3:Boolean) : Boolean
      {
         var _loc4_:b2Body = null;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         if(this._static_world_cloud_hitbox_mc.hitTestPoint(param1,param2,param3))
         {
            _loc4_ = this.m_world.GetRotatedCloudAt(param1,param2);
            if(_loc4_ != null)
            {
               if(_loc4_.GetAngle() != 0)
               {
                  _loc5_ = Number(this._PlayerState.AirVelocityX);
                  _loc6_ = Number(this._PlayerState.AirVelocityY);
                  if(!this._PlayerState.Falling && !this._PlayerState.Knockdowned)
                  {
                     _loc5_ = this._PlayerState.MovingDirectionX * this._PlayerState.RunSpeed;
                  }
                  _loc7_ = Math.cos(-_loc4_.GetAngle());
                  _loc8_ = Math.sin(-_loc4_.GetAngle());
                  _loc9_ = _loc5_ * _loc7_ + _loc6_ * -_loc8_;
                  _loc10_ = _loc5_ * _loc8_ + _loc6_ * _loc7_;
                  _loc11_ = Math.atan2(_loc10_,_loc9_);
                  if(_loc11_ > 0)
                  {
                     return true;
                  }
               }
            }
         }
         return false;
      }
      
      private function PlayerOutsideLevel() : Boolean
      {
         if(this._this_x < this._MapArea.Left || this._this_x > this._MapArea.Right || this._this_y > this._MapArea.Bottom)
         {
            return true;
         }
         return false;
      }
      
      private function ConvertToDirection(param1:Number) : int
      {
         if(param1 == 0)
         {
            return 0;
         }
         return param1 / Math.sqrt(param1 * param1);
      }
      
      public function SetCoordinates(param1:Number, param2:Number, param3:Boolean = false, param4:Boolean = true) : void
      {
         if(!param4)
         {
            if(this._PlayerState.GrabbedPlayer)
            {
               if(!this._players[this._PlayerState.GrabbedPlayerNr].Bot)
               {
                  this.DropGrabbedPlayer();
               }
            }
         }
         this._this_x = param1;
         this._this_y = param2;
         this._PlayerState.PortalDirectionX = 0;
         if(param3)
         {
            this._PlayerState.AirVelocityX *= -1;
            this._PlayerState.MovingDirectionInversed = this._PlayerState.MovingDirectionX;
            this._PlayerState.MovingDirectionX *= -1;
            this._PlayerState.LastDirX *= -1;
            if(!this._PlayerState.StuckToRocket)
            {
               this.scaleX *= -1;
               this._collision_mc.scaleX = this.scaleX;
               if(this._PlayerState.GrabbedPlayer)
               {
                  this._players[this._PlayerState.GrabbedPlayerNr].SetCoordinates(this._this_x,this._this_y,param3);
               }
            }
            else
            {
               this._PlayerAnimation.ShowAnimation("ROCKET_RIDE",true);
               this._PlayerState.RocketRideProjectile.DirectionX *= -1;
            }
         }
         this._collision_mc.x = this._this_x;
         this._collision_mc.y = this._this_y;
         this._player_area_mc.x = this._this_x;
         this._player_area_mc.y = this._this_y;
         this.x = this._this_x;
         this.y = this._this_y;
         if(this._PlayerState.StuckToRocket)
         {
            this._PlayerState.RocketRideProjectile.PosX = this._this_x;
            this._PlayerState.RocketRideProjectile.PosY = this._this_y;
         }
      }
      
      public function SetGrabRotation(param1:Number) : void
      {
         this._PlayerAnimation.GrabRotation = param1;
      }
      
      public function get PortalDirectionX() : int
      {
         return this._PlayerState.PortalDirectionX;
      }
      
      public function get PortalSpeedX() : Number
      {
         return this._PlayerState.PortalSpeedX;
      }
      
      public function get CanBeCatched() : Boolean
      {
         if(this._PlayerState.IsImmune)
         {
            return false;
         }
         if(this._PlayerState.StuckToRocket)
         {
            return false;
         }
         if(this._PlayerState.Knockdowned)
         {
            if(this._PlayerAnimation.CurrentFrame < 10)
            {
               return false;
            }
         }
         if(this._PlayerState.GrabbedPlayer)
         {
            return false;
         }
         if(this._PlayerState.Gone)
         {
            return false;
         }
         return !this._PlayerState.GrabbedByPlayer;
      }
      
      public function get CanBePunched() : Boolean
      {
         if(this._PlayerState.IsImmune)
         {
            return false;
         }
         if(this._PlayerState.Gone)
         {
            return false;
         }
         if(this._PlayerState.KnockdownGrade >= 3 && Boolean(this._PlayerState.Falling))
         {
            return false;
         }
         if(Boolean(this._PlayerState.Knockdowned) && Boolean(this._PlayerState.OnGround))
         {
            if(this._PlayerAnimation.CurrentFrame < 10)
            {
               return false;
            }
         }
         return !this._PlayerState.GrabbedByPlayer;
      }
      
      public function get State() : PlayerState
      {
         return this._PlayerState;
      }
      
      public function PosX() : Number
      {
         return this.x;
      }
      
      public function PosY() : Number
      {
         return this.y;
      }
      
      public function MidPosX() : Number
      {
         return this._this_x;
      }
      
      public function MidPosY() : Number
      {
         if(this._PlayerState.Diving)
         {
            return this._this_y;
         }
         if(this._PlayerState.Knockdowned)
         {
            return this._this_y - 3;
         }
         if(Boolean(this._PlayerState.Kneeling) || Boolean(this._PlayerState.Falling))
         {
            return this._this_y - 6;
         }
         return this._this_y - 8;
      }
      
      public function ExplosionX() : Number
      {
         return this.MidPosX();
      }
      
      public function ExplosionY() : Number
      {
         return this.MidPosY();
      }
      
      public function get CollisionMC() : MovieClip
      {
         return this._collision_mc;
      }
      
      public function get AreaMC() : MovieClip
      {
         return this._player_area_mc;
      }
      
      public function get MC() : MovieClip
      {
         return this;
      }
      
      public function get Ignore() : Boolean
      {
         return this._PlayerState.IgnoreMe;
      }
      
      public function get CameraIgnore() : Boolean
      {
         if(!this.CameraFocus)
         {
            return true;
         }
         return this._PlayerState.CameraIgnoreMe;
      }
      
      public function get RemoveFromList() : Boolean
      {
         return Boolean(this._PlayerState.CameraIgnoreMe) && Boolean(this._PlayerState.Gone);
      }
      
      public function get BulletGameSpeed() : Number
      {
         return this._bullet_game_speed;
      }
      
      public function get PlayerNr() : int
      {
         return this._playerNr;
      }
      
      public function set PlayerNr(param1:int) : void
      {
         this._playerNr = param1;
      }
      
      public function get Team() : int
      {
         return this._team;
      }
      
      public function get Bot() : Boolean
      {
         return this._bot;
      }
      
      public function get CanDespawn() : Boolean
      {
         return this._despawnTimer <= 0;
      }
      
      public function ActivateSlowmotion(param1:Number) : Boolean
      {
         var _loc2_:int = 0;
         var _loc3_:Array = null;
         var _loc4_:int = 0;
         var _loc5_:Boolean = false;
         var _loc6_:int = 0;
         _loc2_ = 0;
         _loc3_ = new Array();
         _loc4_ = 0;
         while(_loc4_ < this._players.length)
         {
            if(this._players[_loc4_].State.HP > 0)
            {
               if(this._players[_loc4_].Team != this._players[param1].Team)
               {
                  _loc5_ = false;
                  _loc6_ = 0;
                  while(_loc6_ < _loc3_.length)
                  {
                     if(_loc3_[_loc6_] == this._players[_loc4_].Team)
                     {
                        _loc5_ = true;
                        _loc6_ = int(_loc3_.length);
                     }
                     _loc6_++;
                  }
                  if(!_loc5_)
                  {
                     _loc2_++;
                     _loc3_.push(this._players[_loc4_].Team);
                     if(_loc2_ >= 2)
                     {
                        return false;
                     }
                  }
               }
               else if(this._playerNr != _loc4_)
               {
                  return false;
               }
            }
            _loc4_++;
         }
         return true;
      }
   }
}

