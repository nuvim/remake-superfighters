package Code.Handler
{
   import Code.Box2D.Common.Math.*;
   import Code.Box2D.Dynamics.b2Body;
   import Code.Box2D.Dynamics.b2World;
   import Code.Data.Players.Player;
   import Code.Data.ProjectileData;
   import Code.Data.ProjectilesUpdaterData;
   import Code.Particles.*;
   import flash.display.*;
   import flash.geom.*;
   
   public class ProjectilesUpdater
   {
      
      private var _Handler_Output:OutputTrace;
      
      private var _Handler_Camera:Cam;
      
      private var _Handler_Players:PlayersKeeper;
      
      private var _Handler_Effects:Effects;
      
      private var _Handler_Explosions:Explosions;
      
      private var _Handler_Sounds:Sounds;
      
      private var _Handler_Projectiles:Projectiles;
      
      private var _static_mc:MovieClip;
      
      private var _object_shape_container_mc:MovieClip;
      
      private var _dynamic_mc:MovieClip;
      
      private var _projectiles_mc:MovieClip;
      
      private var m_world:b2World;
      
      private var _static_world_hitbox_mc:MovieClip;
      
      private var _static_world_cloud_hitbox_mc:MovieClip;
      
      private var _static_objects_cloud_hitbox_mc:MovieClip;
      
      private var _static_ladder_hitbox_mc:MovieClip;
      
      private var _static_objects_hitbox_mc:MovieClip;
      
      private var _static_players_hitbox_mc:MovieClip;
      
      private var _projectiles_list:Array;
      
      private var _rockets_list:Array;
      
      private var b:b2Body;
      
      public function ProjectilesUpdater()
      {
         super();
      }
      
      public function BuildClass(param1:ProjectilesUpdaterData) : void
      {
         this._Handler_Output = param1.Handler_Output;
         this._Handler_Camera = param1.Handler_Camera;
         this._Handler_Players = param1.Handler_Players;
         this._Handler_Effects = param1.Handler_Effects;
         this._Handler_Explosions = param1.Handler_Explosions;
         this._Handler_Sounds = param1.Handler_Sounds;
         this._Handler_Projectiles = param1.Handler_Projectiles;
         this._static_mc = param1.static_mc;
         this._object_shape_container_mc = param1.object_shape_container_mc;
         this._dynamic_mc = param1.dynamic_mc;
         this.m_world = param1.m_world;
         this._static_world_hitbox_mc = MovieClip(this._static_mc.getChildByName("WORLD_HITBOX"));
         this._static_objects_hitbox_mc = MovieClip(this._static_world_hitbox_mc.getChildByName("OBJECTS_HITBOX"));
         this._static_world_cloud_hitbox_mc = MovieClip(this._static_mc.getChildByName("WORLD_CLOUD_HITBOX"));
         this._static_objects_cloud_hitbox_mc = MovieClip(this._static_world_cloud_hitbox_mc.getChildByName("OBJECTS_CLOUD_HITBOX"));
         this._static_ladder_hitbox_mc = MovieClip(this._static_mc.getChildByName("LADDER_HITBOX"));
         this._static_players_hitbox_mc = MovieClip(this._static_mc.getChildByName("PLAYERS_HITBOX"));
         this._projectiles_mc = MovieClip(this._dynamic_mc.getChildByName("PROJECTILES"));
         this._projectiles_list = new Array();
         this._rockets_list = new Array();
         this._Handler_Output.Trace("Projectiles Handler Created");
      }
      
      public function NewRocket(param1:String, param2:Number, param3:Number, param4:Number, param5:Player) : void
      {
         var _loc6_:ProjectileData = null;
         _loc6_ = this._Handler_Projectiles.Bazooka_Rocket;
         this._rockets_list.push(_loc6_);
         _loc6_.Angle = param4;
         _loc6_.PosX = param2;
         _loc6_.PosY = param3;
         _loc6_.Owner = param5;
         _loc6_.AddPlayerAvoided(param5.PlayerNr);
         this._projectiles_mc.addChild(_loc6_.MC);
      }
      
      public function NewProjectile(param1:String, param2:Number, param3:Number, param4:Number, param5:Player) : void
      {
         var _loc6_:ProjectileData = null;
         var _loc7_:int = 0;
         switch(param1.toUpperCase())
         {
            case "PISTOL_BULLET":
               _loc6_ = this._Handler_Projectiles.Pistol_Bullet;
               break;
            case "RIFLE_BULLET":
               _loc6_ = this._Handler_Projectiles.Rifle_Bullet;
               break;
            case "UZI_BULLET":
               _loc6_ = this._Handler_Projectiles.Uzi_Bullet;
               break;
            case "SHOTGUN_BULLET":
               _loc6_ = this._Handler_Projectiles.Shotgun_Bullet;
               break;
            case "MAGNUM_BULLET":
               _loc6_ = this._Handler_Projectiles.Magnum_Bullet;
               break;
            case "SNIPER_BULLET":
               _loc6_ = this._Handler_Projectiles.Sniper_Bullet;
               break;
            default:
               return;
         }
         this._projectiles_list.push(_loc6_);
         _loc6_.Angle = param4;
         _loc6_.PosX = param2;
         _loc6_.PosY = param3;
         _loc6_.Owner = param5;
         _loc6_.AddPlayerAvoided(param5.PlayerNr);
         if(param5.Bot)
         {
            _loc7_ = 0;
            while(_loc7_ < this._Handler_Players.Players.length)
            {
               if(this._Handler_Players.Players[_loc7_].Team == param5.Team && !this._Handler_Players.Players[_loc7_].Bot)
               {
                  _loc6_.AddPlayerAvoided(this._Handler_Players.Players[_loc7_].PlayerNr);
               }
               _loc7_++;
            }
         }
         this._projectiles_mc.addChild(_loc6_.MC);
      }
      
      public function DeflectBullets(param1:Player) : void
      {
         var _loc2_:ProjectileData = null;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc3_:* = int(this._projectiles_list.length - 1);
         while(_loc3_ >= 0)
         {
            _loc2_ = this._projectiles_list[_loc3_];
            _loc4_ = Math.abs(_loc2_.PosY - param1.MidPosY());
            if(_loc4_ < 20)
            {
               _loc5_ = _loc2_.PosX - param1.MidPosX();
               if(_loc5_ > 0 && param1.State.LastDirX == 1 || _loc5_ < 0 && param1.State.LastDirX == -1)
               {
                  if(Math.abs(_loc5_) <= param1.State.MeleeWeaponRange + _loc2_.BulletGameSpeed * _loc2_.Properties.Speed * 0.5)
                  {
                     _loc6_ = Math.sqrt(Math.pow(param1.MidPosX() + param1.State.LastDirX * 4 - _loc2_.PosX,2) + Math.pow(_loc4_,2));
                     if(_loc6_ <= param1.State.MeleeWeaponRange - 2)
                     {
                        this._Handler_Effects.AddEffectAt("BULLET_WHITE_SQUARE",_loc2_.PosX,_loc2_.PosY);
                        _loc2_.Angle = -90 + param1.State.LastDirX * 90 + (80 - Math.random() * 160);
                        _loc2_.ResetPlayersAvoided();
                        this._Handler_Sounds.PlaySound("BULLET_HITMETAL",param1.MidPosX(),param1.MidPosY());
                     }
                  }
               }
            }
            _loc3_--;
         }
      }
      
      public function CalculateAimSquare(param1:Point, param2:Number, param3:int, param4:int, param5:MovieClip) : Point
      {
         var _loc6_:Point = new Point(param1.x,param1.y);
         var _loc7_:Number = param2 * (Math.PI / 180);
         var _loc8_:Point = new Point(Math.cos(_loc7_) * 2,Math.sin(_loc7_) * 2);
         var _loc9_:Boolean = false;
         if(this.CollisionAimObject(_loc6_))
         {
            if(this.b.GetUserData().IDNumber != param3)
            {
               return _loc6_;
            }
         }
         else
         {
            if(Boolean(this.CollisionPlayer(_loc6_)) && !param5.hitTestPoint(_loc6_.x,_loc6_.y,true) || Boolean(this.OutsideTheWorld(_loc6_)))
            {
               return _loc6_;
            }
            if(this.CollisionStatic(_loc6_))
            {
               this.b = this.m_world.GetStaticCoverAt(_loc6_.x,_loc6_.y);
               if(this.b != null)
               {
                  if(param3 == this.b.GetUserData().IDNumber)
                  {
                     _loc9_ = true;
                  }
               }
               if(!_loc9_)
               {
                  return _loc6_;
               }
            }
         }
         var _loc10_:Boolean = false;
         var _loc11_:int = 1;
         while(_loc11_ <= param4)
         {
            _loc6_.x += _loc8_.x;
            _loc6_.y += _loc8_.y;
            _loc10_ = false;
            if(this.CollisionAimObject(_loc6_))
            {
               _loc10_ = true;
            }
            if(_loc10_)
            {
               if(this.b.GetUserData().IDNumber != param3)
               {
                  _loc8_.x *= 0.1;
                  _loc8_.y *= 0.1;
                  while(true)
                  {
                     _loc6_.x -= _loc8_.x;
                     _loc6_.y -= _loc8_.y;
                     if(!this.CollisionAimObject(_loc6_))
                     {
                        break;
                     }
                     if(this.b.GetUserData().IDNumber == param3)
                     {
                        return _loc6_;
                     }
                  }
                  return _loc6_;
               }
            }
            else if(Boolean(this.CollisionPlayer(_loc6_)) && !param5.hitTestPoint(_loc6_.x,_loc6_.y,true) || Boolean(this.OutsideTheWorld(_loc6_)) || Boolean(this.CollisionStatic(_loc6_)))
            {
               this.b = this.m_world.GetStaticCoverAt(_loc6_.x,_loc6_.y);
               _loc9_ = false;
               if(this.b != null)
               {
                  if(param3 == this.b.GetUserData().IDNumber)
                  {
                     _loc9_ = true;
                  }
               }
               if(!_loc9_)
               {
                  _loc8_.x *= 0.1;
                  _loc8_.y *= 0.1;
                  do
                  {
                     _loc6_.x -= _loc8_.x;
                     _loc6_.y -= _loc8_.y;
                     this.b = this.m_world.GetStaticCoverAt(_loc6_.x,_loc6_.y);
                     _loc9_ = false;
                     if(this.b != null)
                     {
                        if(param3 == this.b.GetUserData().IDNumber)
                        {
                           _loc9_ = true;
                        }
                     }
                  }
                  while(!((!this.CollisionPlayer(_loc6_) || param5.hitTestPoint(_loc6_.x,_loc6_.y,true)) && !this.OutsideTheWorld(_loc6_) && (!this.CollisionStatic(_loc6_) || _loc9_)));
                  return _loc6_;
               }
            }
            _loc11_++;
         }
         return _loc6_;
      }
      
      private function ProjectileImpactFrameTime(param1:Array, param2:Player, param3:Number, param4:Number) : Boolean
      {
         var _loc5_:ProjectileData = null;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc6_:* = int(param1.length - 1);
         while(_loc6_ >= 0)
         {
            _loc5_ = param1[_loc6_];
            if(!_loc5_.PlayerAvoided(param2.PlayerNr))
            {
               _loc7_ = param2.MidPosX() - _loc5_.PosX;
               _loc8_ = param2.MidPosY() - _loc5_.PosY;
               _loc9_ = Math.sqrt(_loc7_ * _loc7_ + _loc8_ * _loc8_);
               _loc10_ = Math.atan2(_loc8_,_loc7_);
               _loc11_ = _loc5_.AngleRad;
               if(_loc7_ < 0 && _loc8_ < 0)
               {
                  _loc10_ += Math.PI * 2;
               }
               _loc12_ = Math.atan(10 / _loc9_);
               if(_loc11_ >= _loc10_ - _loc12_ && _loc11_ <= _loc10_ + _loc12_)
               {
                  _loc13_ = _loc5_.Properties.Speed * _loc5_.BulletGameSpeed;
                  _loc14_ = _loc9_ / _loc13_;
                  if(_loc14_ >= param3 && _loc14_ <= param4)
                  {
                     return true;
                  }
               }
            }
            _loc6_--;
         }
         return false;
      }
      
      public function RocketImpactFrameTime(param1:Player, param2:Number, param3:Number) : Boolean
      {
         return this.ProjectileImpactFrameTime(this._rockets_list,param1,param2,param3);
      }
      
      public function BulletImpactFrameTime(param1:Player, param2:Number, param3:Number) : Boolean
      {
         return this.ProjectileImpactFrameTime(this._projectiles_list,param1,param2,param3);
      }
      
      public function CalculateLazer(param1:Point, param2:Number, param3:int, param4:MovieClip) : Array
      {
         var _loc13_:Point = null;
         var _loc5_:Point = new Point(param1.x,param1.y);
         var _loc6_:Array = new Array();
         var _loc7_:Number = param2 * (Math.PI / 180);
         var _loc8_:Point = new Point(Math.cos(_loc7_) * 2,Math.sin(_loc7_) * 2);
         var _loc9_:Boolean = false;
         if(this.CollisionLaserObject(_loc5_))
         {
            if(this.b.GetUserData().IDNumber != param3)
            {
               _loc6_.push(_loc5_);
               return _loc6_;
            }
         }
         else
         {
            if(Boolean(this.CollisionPlayer(_loc5_)) && !param4.hitTestPoint(_loc5_.x,_loc5_.y,true) || Boolean(this.OutsideTheWorld(_loc5_)))
            {
               _loc6_.push(_loc5_);
               return _loc6_;
            }
            if(this.CollisionStatic(_loc5_))
            {
               this.b = this.m_world.GetStaticCoverAt(_loc5_.x,_loc5_.y);
               if(this.b != null)
               {
                  if(param3 == this.b.GetUserData().IDNumber)
                  {
                     _loc9_ = true;
                  }
               }
               if(!_loc9_)
               {
                  _loc6_.push(_loc5_);
                  return _loc6_;
               }
            }
         }
         var _loc10_:Boolean = false;
         var _loc11_:Boolean = false;
         var _loc12_:Boolean = false;
         while(true)
         {
            _loc5_.x += _loc8_.x;
            _loc5_.y += _loc8_.y;
            _loc10_ = false;
            if(!_loc11_)
            {
               if(this.CollisionStaticCloud(_loc5_))
               {
                  _loc13_ = new Point(_loc5_.x,_loc5_.y);
                  _loc6_.push(new Point(_loc13_.x,_loc13_.y));
                  _loc11_ = true;
               }
            }
            else if(!this.CollisionStaticCloud(_loc5_))
            {
               _loc11_ = false;
            }
            if(this.CollisionLaserObject(_loc5_))
            {
               if(this.b.GetUserData().objectData.LaserTransparent)
               {
                  if(!_loc12_)
                  {
                     _loc12_ = true;
                     _loc6_.push(new Point(_loc5_.x,_loc5_.y));
                  }
               }
               else
               {
                  _loc10_ = true;
                  _loc12_ = false;
               }
            }
            else
            {
               _loc12_ = false;
            }
            if(_loc10_)
            {
               if(this.b.GetUserData().IDNumber != param3)
               {
                  break;
               }
            }
            else if(Boolean(this.CollisionPlayer(_loc5_)) && !param4.hitTestPoint(_loc5_.x,_loc5_.y,true) || Boolean(this.OutsideTheWorld(_loc5_)) || Boolean(this.CollisionStatic(_loc5_)))
            {
               this.b = this.m_world.GetStaticCoverAt(_loc5_.x,_loc5_.y);
               _loc9_ = false;
               if(this.b != null)
               {
                  if(param3 == this.b.GetUserData().IDNumber)
                  {
                     _loc9_ = true;
                  }
               }
               if(!_loc9_)
               {
                  _loc8_.x *= 0.1;
                  _loc8_.y *= 0.1;
                  do
                  {
                     _loc5_.x -= _loc8_.x;
                     _loc5_.y -= _loc8_.y;
                     this.b = this.m_world.GetStaticCoverAt(_loc5_.x,_loc5_.y);
                     _loc9_ = false;
                     if(this.b != null)
                     {
                        if(param3 == this.b.GetUserData().IDNumber)
                        {
                           _loc9_ = true;
                        }
                     }
                  }
                  while(!((!this.CollisionPlayer(_loc5_) || param4.hitTestPoint(_loc5_.x,_loc5_.y,true)) && !this.OutsideTheWorld(_loc5_) && (!this.CollisionStatic(_loc5_) || _loc9_)));
                  _loc6_.push(new Point(_loc5_.x,_loc5_.y));
                  return _loc6_;
               }
            }
         }
         if(this.b.GetUserData().objectData.LaserVisibleOnObject)
         {
            _loc8_.x *= 0.1;
            _loc8_.y *= 0.1;
            while(true)
            {
               _loc5_.x -= _loc8_.x;
               _loc5_.y -= _loc8_.y;
               if(!this.CollisionLaserObject(_loc5_))
               {
                  break;
               }
               if(this.b.GetUserData().IDNumber == param3)
               {
                  _loc6_.push(new Point(_loc5_.x,_loc5_.y));
                  return _loc6_;
               }
            }
            _loc6_.push(new Point(_loc5_.x,_loc5_.y));
            return _loc6_;
         }
         return _loc6_;
      }
      
      public function Update(param1:Number) : void
      {
         var _loc2_:ProjectileData = null;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Point = null;
         var _loc9_:int = 0;
         var _loc10_:Number = NaN;
         var _loc11_:Boolean = false;
         var _loc12_:Boolean = false;
         var _loc13_:Boolean = false;
         var _loc14_:int = 0;
         var _loc15_:int = 0;
         var _loc16_:Array = null;
         var _loc17_:Array = null;
         var _loc18_:Boolean = false;
         var _loc19_:particle_data = null;
         var _loc20_:Number = NaN;
         var _loc3_:Boolean = false;
         var _loc4_:* = int(this._projectiles_list.length - 1);
         while(_loc4_ >= 0)
         {
            _loc2_ = this._projectiles_list[_loc4_];
            _loc5_ = _loc2_.Properties.Speed * _loc2_.BulletGameSpeed;
            _loc6_ = _loc2_.DirectionX * _loc2_.Properties.Speed * _loc2_.BulletGameSpeed / Math.ceil(_loc5_);
            _loc7_ = _loc2_.DirectionY * _loc2_.Properties.Speed * _loc2_.BulletGameSpeed / Math.ceil(_loc5_);
            _loc8_ = new Point();
            _loc9_ = 2;
            _loc10_ = Math.sqrt(_loc6_ * _loc6_ + _loc7_ * _loc7_) * _loc9_;
            _loc2_.UpdateVisuals(_loc5_);
            _loc11_ = false;
            _loc12_ = false;
            _loc13_ = true;
            _loc14_ = 0;
            while(_loc14_ < _loc5_)
            {
               _loc2_.PosX += _loc6_ * _loc9_;
               _loc2_.PosY += _loc7_ * _loc9_;
               _loc8_.x = _loc2_.PosX;
               _loc8_.y = _loc2_.PosY;
               if(_loc2_.AddBulletTrace(_loc10_))
               {
                  this._Handler_Effects.AddParticle(new particle_data("bullet_trace_slomo",_loc2_.PosX,_loc2_.PosY,new b2Vec2(),_loc2_.Angle,0.7));
               }
               if(this.CollisionObject(_loc8_))
               {
                  if(_loc2_.Owner.State.CoverObjectID != this.b.GetUserData().IDNumber)
                  {
                     if(this.b.GetUserData().objectData.PlayerCoverLevel <= 0)
                     {
                        this.b.ApplyImpulse(new b2Vec2(_loc2_.DirectionX * _loc2_.Properties.ImpulseForce,_loc2_.DirectionY * _loc2_.Properties.ImpulseForce),new b2Vec2(_loc2_.PosX / 30,_loc2_.PosY / 30));
                     }
                     this._Handler_Sounds.PlaySoundAt(this.b.GetUserData().material.BulletHitSound,_loc2_.PosX,_loc2_.PosY);
                     if(!this.b.GetUserData().objectData.Indestructible && this.b.GetUserData().objectData.Strength <= _loc2_.StrengthLeft)
                     {
                        _loc2_.StrengthLeft -= this.b.GetUserData().objectData.Strength;
                        this.b.ApplyImpulse(new b2Vec2(_loc2_.DirectionX * _loc2_.Properties.ImpulseForce,_loc2_.DirectionY * _loc2_.Properties.ImpulseForce),new b2Vec2(_loc2_.PosX / 30,_loc2_.PosY / 30));
                        this.b.GetUserData().objectData.ForceDestruction();
                        if(_loc2_.StrengthLeft <= 0)
                        {
                           _loc11_ = true;
                        }
                     }
                     else
                     {
                        this.b.GetUserData().objectData.Damage_Bullet(_loc2_.Properties.Damage);
                        this._Handler_Effects.AddEffectAt(this.b.GetUserData().material.BulletHitEffect,_loc2_.PosX,_loc2_.PosY);
                        _loc11_ = true;
                     }
                  }
               }
               else if(this.CollisionPlayer(_loc8_))
               {
                  _loc12_ = true;
                  _loc15_ = 0;
                  while(_loc15_ < this._Handler_Players.Players.length)
                  {
                     if(this._Handler_Players.Players[_loc15_].CollisionMC.hitTestPoint(_loc8_.x,_loc8_.y,true))
                     {
                        if(!_loc2_.PlayerAvoided(_loc15_))
                        {
                           if(this._Handler_Players.Players[_loc15_].BulletWillHit())
                           {
                              this._Handler_Players.Players[_loc15_].BulletDamage(_loc2_);
                              this._Handler_Sounds.PlaySoundAt("BULLET_HITFLESH",_loc2_.PosX,_loc2_.PosY);
                              if(!this._Handler_Players.Players[_loc15_].State.Burned)
                              {
                                 this._Handler_Effects.AddEffectAt("BLOOD",_loc2_.PosX,_loc2_.PosY);
                                 _loc16_ = new Array();
                                 _loc16_.push(0);
                                 _loc17_ = new Array();
                                 _loc17_.push(1);
                                 this._Handler_Effects.AddParticle(new particle_data("PARTICLE_BLOOD",_loc2_.PosX,_loc2_.PosY,new b2Vec2(_loc2_.DirectionX,_loc2_.DirectionY),0,1,_loc16_));
                                 if(Math.random() < 0.5)
                                 {
                                    this._Handler_Effects.AddParticle(new particle_data("PARTICLE_BLOOD",_loc2_.PosX,_loc2_.PosY,new b2Vec2(_loc2_.DirectionX,_loc2_.DirectionY),0,1,_loc16_));
                                 }
                                 if(Math.random() < 0.5)
                                 {
                                    this._Handler_Effects.AddParticle(new particle_data("PARTICLE_BLOOD",_loc2_.PosX,_loc2_.PosY,new b2Vec2(_loc2_.DirectionX,_loc2_.DirectionY),0,1,_loc17_));
                                 }
                                 this._Handler_Effects.AddParticle(new particle_data("PARTICLE_BLOOD",_loc2_.PosX,_loc2_.PosY,new b2Vec2(_loc2_.DirectionX,_loc2_.DirectionY),0,1,_loc17_));
                              }
                              else
                              {
                                 this._Handler_Effects.AddEffectAt("PLAYER_BURNED_HITDEFAULT",_loc2_.PosX,_loc2_.PosY);
                              }
                              _loc11_ = true;
                           }
                           else
                           {
                              _loc2_.AddPlayerAvoided(_loc15_);
                           }
                        }
                     }
                     _loc15_++;
                  }
               }
               else if(Boolean(this.CollisionStatic(_loc8_)) || Boolean(this.CollisionStaticCloud(_loc8_)))
               {
                  this.b = this.m_world.GetStaticCoverAt(_loc8_.x,_loc8_.y);
                  _loc18_ = false;
                  if(this.b != null)
                  {
                     if(_loc2_.Owner.State.CoverObjectID == this.b.GetUserData().IDNumber)
                     {
                        _loc18_ = true;
                     }
                  }
                  if(!_loc18_)
                  {
                     if(this.CollisionStaticCloud(_loc8_))
                     {
                        if(!_loc2_.PenetratingCloud)
                        {
                           this.b = this.m_world.GetStaticBodyAt(_loc8_.x,_loc8_.y);
                           if(this.b != null)
                           {
                              this._Handler_Sounds.PlaySoundAt(this.b.GetUserData().material.BulletHitSound,_loc2_.PosX,_loc2_.PosY);
                              this._Handler_Effects.AddEffectAt(this.b.GetUserData().material.BulletHitEffect,_loc2_.PosX,_loc2_.PosY);
                           }
                           _loc2_.PenetratingCloud = true;
                        }
                     }
                     if(!_loc2_.PenetratingCloud && !_loc2_.Penetrating)
                     {
                        this.b = this.m_world.GetStaticBodyAt(_loc8_.x,_loc8_.y);
                        if(this.b != null)
                        {
                           this._Handler_Sounds.PlaySoundAt(this.b.GetUserData().material.BulletHitSound,_loc2_.PosX,_loc2_.PosY);
                           this._Handler_Effects.AddEffectAt(this.b.GetUserData().material.BulletHitEffect,_loc2_.PosX,_loc2_.PosY);
                        }
                        _loc11_ = true;
                     }
                  }
               }
               else if(this.OutsideTheWorld(_loc8_))
               {
                  _loc11_ = true;
                  _loc13_ = false;
               }
               else if(_loc2_.PenetratingCloud)
               {
                  if(!this.CollisionStaticCloud(_loc8_))
                  {
                     _loc2_.PenetratingCloud = false;
                  }
               }
               else if(_loc2_.Penetrating)
               {
                  if(!this.CollisionStatic(_loc8_))
                  {
                     _loc2_.Penetrating = false;
                  }
               }
               if(_loc11_)
               {
                  if(param1 >= 0.8)
                  {
                     _loc19_ = new particle_data("projectile_light_trace",_loc2_.PosX,_loc2_.PosY);
                     _loc19_.Rotation = _loc2_.Angle;
                     _loc19_.Alpha = 0.9 - _loc5_ / 100;
                     _loc20_ = _loc14_ / _loc5_;
                     _loc19_.ScaleX = _loc20_ * _loc5_ / 10;
                     this._Handler_Effects.AddParticle(_loc19_);
                  }
                  if(_loc13_)
                  {
                     this._Handler_Effects.AddEffectAt("BULLET_WHITE_SQUARE",_loc2_.PosX,_loc2_.PosY);
                  }
                  _loc2_.MC.parent.removeChild(_loc2_.MC);
                  this._projectiles_list.splice(_loc4_,1);
                  _loc14_ = _loc5_;
                  _loc11_ = false;
                  _loc13_ = true;
               }
               _loc14_ += _loc9_;
            }
            if(!_loc12_)
            {
               _loc2_.ResetPlayersAvoided();
            }
            _loc4_--;
         }
         this.UpdateRockets(param1);
      }
      
      private function UpdateRockets(param1:Number) : void
      {
         var _loc2_:ProjectileData = null;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Point = null;
         var _loc8_:int = 0;
         var _loc9_:Number = NaN;
         var _loc10_:Boolean = false;
         var _loc11_:Boolean = false;
         var _loc12_:Point = null;
         var _loc13_:Boolean = false;
         var _loc14_:int = 0;
         var _loc15_:Boolean = false;
         var _loc16_:int = 0;
         var _loc3_:* = int(this._rockets_list.length - 1);
         while(_loc3_ >= 0)
         {
            _loc2_ = this._rockets_list[_loc3_];
            _loc4_ = _loc2_.Properties.Speed * _loc2_.BulletGameSpeed;
            _loc2_.Angle += (Math.random() * 8 - 4) * param1;
            _loc5_ = _loc2_.DirectionX * _loc2_.Properties.Speed * _loc2_.BulletGameSpeed / Math.ceil(_loc4_);
            _loc6_ = _loc2_.DirectionY * _loc2_.Properties.Speed * _loc2_.BulletGameSpeed / Math.ceil(_loc4_);
            if(_loc2_.PlayerStuck != null)
            {
               _loc5_ *= 0.5;
               _loc6_ *= 0.5;
            }
            _loc7_ = new Point();
            _loc8_ = 2;
            _loc9_ = Math.sqrt(_loc5_ * _loc5_ + _loc6_ * _loc6_) * _loc8_;
            _loc10_ = false;
            _loc11_ = false;
            _loc12_ = new Point();
            _loc14_ = 0;
            while(_loc14_ < _loc4_)
            {
               _loc12_.x = _loc2_.PosX;
               _loc12_.y = _loc2_.PosY;
               _loc2_.PosX += _loc5_ * _loc8_;
               _loc2_.PosY += _loc6_ * _loc8_;
               _loc7_.x = _loc2_.PosX;
               _loc7_.y = _loc2_.PosY;
               if(_loc2_.PlayerStuck != null)
               {
                  _loc13_ = _loc2_.AddBulletTrace(_loc9_);
               }
               else
               {
                  _loc13_ = _loc2_.AddBulletTrace(_loc9_ * 2);
               }
               if(_loc13_)
               {
                  this._Handler_Effects.AddParticle(new particle_data("TRACE_BAZOOKA_ROCKET",_loc2_.PosX - _loc2_.DirectionX * 4,_loc2_.PosY - _loc2_.DirectionY * 4,new b2Vec2(_loc2_.DirectionX,_loc2_.DirectionY),_loc2_.Angle,0.7));
                  if(Math.random() < 0.3)
                  {
                     this._Handler_Effects.AddParticle(new particle_data("SMOKE_FIRE",_loc2_.PosX - _loc2_.DirectionX * 4,_loc2_.PosY - _loc2_.DirectionY * 4,new b2Vec2(_loc2_.DirectionX,_loc2_.DirectionY),0,0.7));
                  }
               }
               if(this.CollisionObjectRocket(_loc7_))
               {
                  if(_loc2_.Owner.State.CoverObjectID != this.b.GetUserData().IDNumber)
                  {
                     this.b.ApplyImpulse(new b2Vec2(_loc2_.DirectionX * _loc2_.Properties.ImpulseForce,_loc2_.DirectionY * _loc2_.Properties.ImpulseForce),new b2Vec2(_loc2_.PosX / 30,_loc2_.PosY / 30));
                     if(!this.b.GetUserData().objectData.Indestructible && this.b.GetUserData().objectData.Strength <= _loc2_.StrengthLeft)
                     {
                        this.b.ApplyImpulse(new b2Vec2(_loc2_.DirectionX * _loc2_.Properties.ImpulseForce,_loc2_.DirectionY * _loc2_.Properties.ImpulseForce),new b2Vec2(_loc2_.PosX / 30,_loc2_.PosY / 30));
                        this.b.GetUserData().objectData.ForceDestruction();
                     }
                     else
                     {
                        this.b.GetUserData().objectData.Damage_Bullet(_loc2_.Properties.Damage);
                        _loc10_ = true;
                        _loc11_ = true;
                     }
                  }
               }
               else if(this.CollisionStatic(_loc7_))
               {
                  this.b = this.m_world.GetStaticCoverAt(_loc7_.x,_loc7_.y);
                  _loc15_ = false;
                  if(this.b != null)
                  {
                     if(_loc2_.Owner.State.CoverObjectID == this.b.GetUserData().IDNumber)
                     {
                        _loc15_ = true;
                     }
                  }
                  if(!_loc15_)
                  {
                     _loc10_ = true;
                     _loc11_ = true;
                  }
               }
               else if(this.CollisionPlayer(_loc7_))
               {
                  _loc16_ = 0;
                  while(_loc16_ < this._Handler_Players.Players.length)
                  {
                     if(this._Handler_Players.Players[_loc16_].CollisionMC.hitTestPoint(_loc7_.x,_loc7_.y,true))
                     {
                        if(!_loc2_.PlayerAvoided(_loc16_))
                        {
                           if(this._Handler_Players.Players[_loc16_].RocketWillHit())
                           {
                              if(_loc2_.PlayerStuck != null)
                              {
                                 if(!this._Handler_Players.Players[_loc16_].State.StuckToRocket)
                                 {
                                    this._Handler_Players.Players[_loc16_].GibPlayer();
                                 }
                                 else
                                 {
                                    this._Handler_Players.Players[_loc16_].State.RocketRideProjectile.Explode();
                                 }
                                 _loc10_ = true;
                                 _loc11_ = true;
                              }
                              else
                              {
                                 _loc2_.ResetPlayersAvoided();
                                 if(this._Handler_Players.Players[_loc16_].State.HP > 0)
                                 {
                                    if(this._Handler_Players.Players[_loc16_].State.StuckToRocket)
                                    {
                                       this._Handler_Players.Players[_loc16_].State.RocketRideProjectile.PlayerStuck = null;
                                       this._Handler_Players.Players[_loc16_].State.RocketRideProjectile.Show();
                                    }
                                    this._Handler_Players.Players[_loc16_].StuckToProjectile(_loc2_);
                                    _loc2_.PlayerStuck = this._Handler_Players.Players[_loc16_];
                                    _loc2_.PosX = _loc2_.PlayerStuck.MidPosX();
                                    _loc2_.PosY = _loc2_.PlayerStuck.MidPosY();
                                    _loc2_.AddPlayerAvoided(_loc16_);
                                    _loc2_.Hide();
                                 }
                                 else
                                 {
                                    this._Handler_Players.Players[_loc16_].GibPlayer();
                                    _loc10_ = true;
                                    _loc11_ = true;
                                 }
                              }
                           }
                           else
                           {
                              _loc2_.AddPlayerAvoided(_loc16_);
                           }
                        }
                     }
                     _loc16_++;
                  }
               }
               else if(this.OutsideTheWorld(_loc7_))
               {
                  _loc10_ = true;
               }
               if(_loc2_.PlayerStuck != null)
               {
                  _loc2_.PlayerStuck.UpdatePositionToProjectile();
               }
               if(_loc10_ || _loc2_.DoExplode)
               {
                  if(_loc2_.PlayerStuck != null)
                  {
                     _loc2_.PlayerStuck.GibPlayer();
                     _loc2_.PlayerStuck = null;
                  }
                  if(_loc11_ || _loc2_.DoExplode)
                  {
                     this._Handler_Sounds.PlaySoundAt("ROCKET_EXPLOSION",_loc2_.PosX,_loc2_.PosY);
                     if(!this._Handler_Explosions.TriggerExplosionAt("BAZOOKA_ROCKET",_loc12_.x + _loc5_ * 2,_loc12_.y + _loc6_ * 2))
                     {
                        this._Handler_Explosions.TriggerExplosionAt("BAZOOKA_ROCKET",_loc12_.x - _loc5_ * 2,_loc12_.y - _loc6_ * 2);
                     }
                  }
                  _loc2_.MC.parent.removeChild(_loc2_.MC);
                  this._rockets_list.splice(_loc3_,1);
                  _loc14_ = _loc4_;
                  _loc10_ = false;
               }
               _loc14_ += _loc8_;
            }
            _loc3_--;
         }
      }
      
      private function CollisionPlayer(param1:Point) : Boolean
      {
         if(this._static_players_hitbox_mc.hitTestPoint(param1.x,param1.y,true))
         {
            return true;
         }
         return false;
      }
      
      private function CollisionLadder(param1:Point) : Boolean
      {
         if(this._static_ladder_hitbox_mc.hitTestPoint(param1.x,param1.y,true))
         {
            return true;
         }
         return false;
      }
      
      private function CollisionObjectRocket(param1:Point) : Boolean
      {
         if(this._object_shape_container_mc.hitTestPoint(param1.x,param1.y,true))
         {
            this.b = this.m_world.GetDynamicBodyAt(param1.x,param1.y,false);
            if(this.b != null)
            {
               return true;
            }
         }
         return false;
      }
      
      private function CollisionObject(param1:Point) : Boolean
      {
         if(this._object_shape_container_mc.hitTestPoint(param1.x,param1.y,true))
         {
            this.b = this.m_world.GetBulletSolidAt(param1.x,param1.y);
            if(this.b != null)
            {
               return true;
            }
         }
         return false;
      }
      
      private function CollisionLaserObject(param1:Point) : Boolean
      {
         if(this._object_shape_container_mc.hitTestPoint(param1.x,param1.y,true))
         {
            this.b = this.m_world.GetLaserSolidAt(param1.x,param1.y);
            if(this.b != null)
            {
               return true;
            }
         }
         return false;
      }
      
      private function CollisionAimObject(param1:Point) : Boolean
      {
         if(this._object_shape_container_mc.hitTestPoint(param1.x,param1.y,true))
         {
            this.b = this.m_world.GetAimSolidAt(param1.x,param1.y);
            if(this.b != null)
            {
               return true;
            }
         }
         return false;
      }
      
      private function CollisionStaticCloud(param1:Point) : Boolean
      {
         if(Boolean(this._static_world_cloud_hitbox_mc.hitTestPoint(param1.x,param1.y,true)) && !this._static_objects_cloud_hitbox_mc.hitTestPoint(param1.x,param1.y,true))
         {
            return true;
         }
         return false;
      }
      
      private function CollisionStatic(param1:Point) : Boolean
      {
         if(Boolean(this._static_world_hitbox_mc.hitTestPoint(param1.x,param1.y,true)) && !this._static_objects_hitbox_mc.hitTestPoint(param1.x,param1.y,true))
         {
            return true;
         }
         return false;
      }
      
      private function OutsideTheWorld(param1:Point) : Boolean
      {
         if(param1.x < this._Handler_Camera.MapArea.x || param1.y < this._Handler_Camera.MapArea.y || param1.x > this._Handler_Camera.MapArea.x + this._Handler_Camera.MapArea.width || param1.y > this._Handler_Camera.MapArea.y + this._Handler_Camera.MapArea.height)
         {
            return true;
         }
         return false;
      }
   }
}

