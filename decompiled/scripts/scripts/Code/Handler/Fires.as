package Code.Handler
{
   import Code.Box2D.Common.Math.*;
   import Code.Box2D.Dynamics.*;
   import Code.Data.*;
   import flash.display.*;
   import flash.geom.*;
   import flash.utils.*;
   
   public class Fires
   {
      
      private var _Handler_Output:OutputTrace;
      
      private var _Handler_Camera:Cam;
      
      private var _Handler_Players:PlayersKeeper;
      
      private var _Handler_Effects:Effects;
      
      private var _Handler_Sounds:Sounds;
      
      private var _static_mc:MovieClip;
      
      private var _static_objects_hitbox_mc:MovieClip;
      
      private var _static_world_hitbox_mc:MovieClip;
      
      private var _static_world_cloud_hitbox_mc:MovieClip;
      
      private var _static_objects_cloud_hitbox_mc:MovieClip;
      
      private var _dynamic_mc:MovieClip;
      
      private var _fire_mc:MovieClip;
      
      private var _object_shape_container_mc:MovieClip;
      
      private var _in_fire_test_mc:MovieClip;
      
      private var m_world:b2World;
      
      private var _smoke_packages:Array;
      
      private var _burn_timer:Number = 96;
      
      private var _update_sequence:int = 1;
      
      private var _fire_nodes:Array;
      
      private var _letFireDrop:Boolean = false;
      
      private var game_speed:Number = 1;
      
      private var _fireTimer:Number;
      
      private var _firePlayerObjectTimer:Number;
      
      private var _fireObjectFireDamageTimer:Number;
      
      public function Fires(param1:ExplosionData, param2:MovieClip)
      {
         super();
         this._Handler_Output = param1.Handler_Output;
         this._Handler_Camera = param1.Handler_Camera;
         this._Handler_Players = param1.Handler_Players;
         this._Handler_Effects = param1.Handler_Effects;
         this._Handler_Sounds = param1.Handler_Sounds;
         this._static_mc = param1.static_mc;
         this._dynamic_mc = param1.dynamic_mc;
         this.m_world = param1.m_world;
         this._object_shape_container_mc = param2;
         this._static_world_hitbox_mc = MovieClip(this._static_mc.getChildByName("WORLD_HITBOX"));
         this._static_objects_hitbox_mc = MovieClip(this._static_world_hitbox_mc.getChildByName("OBJECTS_HITBOX"));
         this._static_world_cloud_hitbox_mc = MovieClip(this._static_mc.getChildByName("WORLD_CLOUD_HITBOX"));
         this._static_objects_cloud_hitbox_mc = MovieClip(this._static_world_cloud_hitbox_mc.getChildByName("OBJECTS_CLOUD_HITBOX"));
         this._fire_mc = new MovieClip();
         this._static_mc.addChild(this._fire_mc);
         this._smoke_packages = new Array();
         this._fire_nodes = new Array();
         this._in_fire_test_mc = new MovieClip();
         this._in_fire_test_mc.graphics.lineStyle(0.5,16711680,1);
         this._in_fire_test_mc.graphics.beginFill(16711680,0.5);
         this._in_fire_test_mc.graphics.moveTo(-4,0);
         this._in_fire_test_mc.graphics.lineTo(-4,-16);
         this._in_fire_test_mc.graphics.lineTo(4,-16);
         this._in_fire_test_mc.graphics.lineTo(4,0);
         this._in_fire_test_mc.graphics.lineTo(4,0);
         this._in_fire_test_mc.graphics.endFill();
         this._fireTimer = setInterval(this.UpdateFires,1000 / 24);
         this._firePlayerObjectTimer = setInterval(this.PlayerObjectOverlap,42);
         this._fireObjectFireDamageTimer = setInterval(this.ObjectFireDamage,84);
         this._Handler_Output.Trace("Fire Handler Created");
      }
      
      public function Stop() : void
      {
         clearInterval(this._fireTimer);
         clearInterval(this._firePlayerObjectTimer);
         clearInterval(this._fireObjectFireDamageTimer);
      }
      
      private function GradToRad(param1:Number) : Number
      {
         return Math.PI / 180 * param1;
      }
      
      public function PlayerPosInFire(param1:Number, param2:Number) : Boolean
      {
         var _loc3_:* = 0;
         if(this._fire_nodes.length <= 0)
         {
            return false;
         }
         this._in_fire_test_mc.x = param1;
         this._in_fire_test_mc.y = param2;
         if(this._fire_mc.hitTestObject(this._in_fire_test_mc))
         {
            _loc3_ = int(this._fire_nodes.length - 1);
            while(_loc3_ >= 0)
            {
               if(this._fire_nodes[_loc3_].FireArea.hitTestObject(this._in_fire_test_mc))
               {
                  return true;
               }
               _loc3_--;
            }
         }
         return false;
      }
      
      private function PlayerInFire(param1:int) : void
      {
         var _loc2_:FireNodeData = null;
         if(this._Handler_Players.Players[param1].State.BurnState > 0)
         {
            if(!this._Handler_Players.Players[param1].State.FireRank1Attached && this._Handler_Players.Players[param1].State.BurnState >= this._Handler_Players.Players[param1].State.FireRank1Minimum)
            {
               _loc2_ = new FireNodeData(this._Handler_Effects,this._fire_mc,this._burn_timer,0,0,0,0);
               _loc2_.BurnPlayer(this._Handler_Players.Players[param1],param1,1);
               this._Handler_Players.Players[param1].State.FireRank1Attached = true;
               this._fire_nodes.push(_loc2_);
            }
            if(!this._Handler_Players.Players[param1].State.FireRank2Attached && this._Handler_Players.Players[param1].State.BurnState >= this._Handler_Players.Players[param1].State.FireRank2Minimum)
            {
               _loc2_ = new FireNodeData(this._Handler_Effects,MovieClip(this._dynamic_mc.getChildByName("EFFECTS2")),this._burn_timer,0,0,0,0);
               _loc2_.BurnPlayer(this._Handler_Players.Players[param1],param1,2);
               this._Handler_Players.Players[param1].State.FireRank2Attached = true;
               this._fire_nodes.push(_loc2_);
            }
         }
      }
      
      public function AddSmokeToObject(param1:b2Body, param2:Number) : void
      {
         var _loc3_:SmokePackageDataDynamic = null;
         if(param1.GetUserData().objectData.CanSmoke)
         {
            if(param2 > param1.GetUserData().objectData.ObjectSmokeGrade)
            {
               param1.GetUserData().objectData.ObjectSmokeGrade = param2;
               _loc3_ = new SmokePackageDataDynamic(this._Handler_Effects);
               _loc3_.SetSmokeElementAt(param1);
               this._smoke_packages.push(_loc3_);
            }
         }
      }
      
      public function AddFireToObject(param1:b2Body) : void
      {
         var _loc2_:FireNodeData = null;
         if(param1.GetUserData().objectData.CanBurn)
         {
            if(!param1.GetUserData().objectData.ObjectOnFire)
            {
               _loc2_ = new FireNodeData(this._Handler_Effects,this._fire_mc,this._burn_timer,0,0,0,0);
               _loc2_.BurnBody(param1);
               this._fire_nodes.push(_loc2_);
               param1.GetUserData().objectData.ObjectOnFire = true;
            }
         }
      }
      
      private function GetNearbyFireNode(param1:FireNodeData) : FireNodeData
      {
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc2_:FireNodeData = null;
         var _loc3_:Number = 3;
         var _loc4_:int = 0;
         while(_loc4_ < this._fire_nodes.length)
         {
            if(this._fire_nodes[_loc4_].CanBeMerged)
            {
               if(this._fire_nodes[_loc4_] != param1)
               {
                  _loc5_ = this._fire_nodes[_loc4_].PosX - param1.PosX;
                  _loc6_ = this._fire_nodes[_loc4_].PosY - param1.PosY;
                  _loc7_ = Math.sqrt(_loc5_ * _loc5_ + _loc6_ * _loc6_);
                  if(_loc7_ < _loc3_)
                  {
                     _loc3_ = _loc7_;
                     _loc2_ = this._fire_nodes[_loc4_];
                  }
               }
            }
            _loc4_++;
         }
         return _loc2_;
      }
      
      public function Update(param1:Number) : void
      {
         this.game_speed = param1;
      }
      
      private function UpdateFires() : void
      {
         var _loc1_:b2Body = null;
         var _loc2_:* = 0;
         var _loc3_:int = 0;
         var _loc4_:Number = NaN;
         var _loc5_:int = 0;
         var _loc6_:Boolean = false;
         var _loc7_:Point = null;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:FireNodeData = null;
         if(this._smoke_packages.length > 0)
         {
            _loc3_ = 0;
            while(_loc3_ < this._smoke_packages.length)
            {
               this._smoke_packages[_loc3_].Update(this.game_speed);
               if(this._smoke_packages[_loc3_].SmokePackageCompleted)
               {
                  this._smoke_packages.splice(_loc3_,1);
               }
               _loc3_++;
            }
         }
         _loc2_ = int(this._fire_nodes.length - 1);
         while(_loc2_ >= 0)
         {
            this._fire_nodes[_loc2_].Update(this.game_speed);
            if(this._fire_nodes[_loc2_].InAir)
            {
               if(!this._fire_nodes[_loc2_].IsFlamethrower)
               {
                  this._fire_nodes[_loc2_].VelX *= 0.9 + 0.1 * (1 - this.game_speed);
               }
               else
               {
                  this._fire_nodes[_loc2_].VelX *= 0.93 + 0.07 * (1 - this.game_speed);
               }
               if(this._fire_nodes[_loc2_].SlowingDown)
               {
                  if(!this._fire_nodes[_loc2_].IsFlamethrower)
                  {
                     this._fire_nodes[_loc2_].VelY *= 0.9 + 0.1 * (1 - this.game_speed);
                  }
                  else
                  {
                     this._fire_nodes[_loc2_].VelY *= 0.95 + 0.05 * (1 - this.game_speed);
                  }
                  if(Math.abs(this._fire_nodes[_loc2_].TotalVel) <= 2)
                  {
                     this._fire_nodes[_loc2_].SlowingDown = false;
                  }
               }
               else
               {
                  this._fire_nodes[_loc2_].VelY += 0.2 * this.game_speed;
               }
               _loc4_ = 1;
               _loc4_ = Math.round(this._fire_nodes[_loc2_].TotalVel / 4);
               if(_loc4_ < 1)
               {
                  _loc4_ = 1;
               }
               _loc5_ = 0;
               while(_loc5_ < _loc4_)
               {
                  this._fire_nodes[_loc2_].PosX += this._fire_nodes[_loc2_].VelX * this.game_speed / _loc4_;
                  this._fire_nodes[_loc2_].PosY += this._fire_nodes[_loc2_].VelY * this.game_speed / _loc4_;
                  _loc6_ = this._fire_nodes[_loc2_].VelY < 0;
                  if(this._fire_nodes[_loc2_].PassCloud)
                  {
                     _loc6_ = true;
                  }
                  _loc7_ = new Point(this._fire_nodes[_loc2_].PosX,this._fire_nodes[_loc2_].PosY);
                  if(Boolean(this.CollisionStatic(_loc7_)) || Boolean(this.CollisionStaticCloud(_loc7_)) && !_loc6_)
                  {
                     _loc8_ = 0;
                     while(_loc8_ < 10)
                     {
                        this._fire_nodes[_loc2_].PosX -= this._fire_nodes[_loc2_].VelX * this.game_speed / (_loc4_ * 4);
                        this._fire_nodes[_loc2_].PosY -= this._fire_nodes[_loc2_].VelY * this.game_speed / (_loc4_ * 4);
                        _loc7_ = new Point(this._fire_nodes[_loc2_].PosX,this._fire_nodes[_loc2_].PosY);
                        if(!this.CollisionStatic(_loc7_) && !this.CollisionStaticCloud(_loc7_))
                        {
                           _loc8_ = 10;
                        }
                        _loc8_++;
                     }
                     if(this._letFireDrop)
                     {
                        _loc7_ = new Point(this._fire_nodes[_loc2_].PosX,this._fire_nodes[_loc2_].PosY + 2);
                        if(Boolean(this.CollisionStatic(_loc7_)) || Boolean(this.CollisionStaticCloud(_loc7_)) && !_loc6_)
                        {
                           this._fire_nodes[_loc2_].InAir = false;
                        }
                        else
                        {
                           this._fire_nodes[_loc2_].VelY = 0;
                           if(this._fire_nodes[_loc2_].VelX < 0)
                           {
                              this._fire_nodes[_loc2_].VelX = 0.1;
                           }
                           else if(this._fire_nodes[_loc2_].VelX > 0)
                           {
                              this._fire_nodes[_loc2_].VelX = -0.1;
                           }
                        }
                     }
                     else
                     {
                        this._fire_nodes[_loc2_].InAir = false;
                     }
                  }
                  else if(this._object_shape_container_mc.hitTestPoint(this._fire_nodes[_loc2_].PosX,this._fire_nodes[_loc2_].PosY,true))
                  {
                     _loc1_ = this.m_world.GetFireCarrierAt(this._fire_nodes[_loc2_].PosX,this._fire_nodes[_loc2_].PosY);
                     if(_loc1_ != null)
                     {
                        _loc9_ = 0;
                        while(_loc9_ < 10)
                        {
                           this._fire_nodes[_loc2_].PosX -= this._fire_nodes[_loc2_].VelX * this.game_speed / (_loc4_ * 4);
                           this._fire_nodes[_loc2_].PosY -= this._fire_nodes[_loc2_].VelY * this.game_speed / (_loc4_ * 4);
                           if(!_loc1_.m_userData.objectData.ShapeMC.hitTestPoint(this._fire_nodes[_loc2_].PosX,this._fire_nodes[_loc2_].PosY,true))
                           {
                              _loc9_ = 10;
                           }
                           _loc9_++;
                        }
                        if(this._letFireDrop)
                        {
                           if(_loc1_.m_userData.objectData.ShapeMC.hitTestPoint(this._fire_nodes[_loc2_].PosX,this._fire_nodes[_loc2_].PosY + 2,true))
                           {
                              this._fire_nodes[_loc2_].InAir = false;
                           }
                           else
                           {
                              this._fire_nodes[_loc2_].VelY = 0;
                              if(this._fire_nodes[_loc2_].VelX < 0)
                              {
                                 this._fire_nodes[_loc2_].VelX = 0.1;
                              }
                              else if(this._fire_nodes[_loc2_].VelX > 0)
                              {
                                 this._fire_nodes[_loc2_].VelX = -0.1;
                              }
                           }
                        }
                        else
                        {
                           this._fire_nodes[_loc2_].InAir = false;
                        }
                        if(!this._fire_nodes[_loc2_].InAir)
                        {
                           this._fire_nodes[_loc2_].FollowBody(_loc1_,_loc1_.GetLocalPoint(new b2Vec2(this._fire_nodes[_loc2_].PosX / 30,this._fire_nodes[_loc2_].PosY / 30)));
                        }
                     }
                  }
                  _loc5_++;
               }
               this._fire_nodes[_loc2_].UpdateMC();
               if(!this._fire_nodes[_loc2_].InAir)
               {
                  _loc10_ = this.GetNearbyFireNode(this._fire_nodes[_loc2_]);
                  if(_loc10_ != null)
                  {
                     if(this._fire_nodes[_loc2_].BurnTimer > _loc10_.BurnTimer)
                     {
                        _loc10_.BurnTimer = this._fire_nodes[_loc2_].BurnTimer;
                     }
                     this._fire_nodes[_loc2_].End();
                  }
               }
            }
            if(this._fire_nodes[_loc2_].FireNodeCompleted)
            {
               this._fire_nodes.splice(_loc2_,1);
            }
            _loc2_--;
         }
      }
      
      private function PlayerObjectOverlap() : void
      {
         this._update_sequence += 1;
         if(this._update_sequence > 2)
         {
            this._update_sequence = 1;
         }
         if(this._update_sequence == 1)
         {
            this.ObjectOverlap();
         }
         else if(this._update_sequence == 2)
         {
            this.PlayerOverlap();
         }
      }
      
      private function ObjectFireDamage() : void
      {
         var _loc1_:b2Body = null;
         var _loc3_:* = 0;
         var _loc2_:int = 0;
         while(_loc2_ < this.m_world.CanTakeFireDamageList.length)
         {
            _loc1_ = this.m_world.CanTakeFireDamageList[_loc2_];
            if(this._fire_mc.hitTestObject(_loc1_.GetUserData().objectData.ShapeMC))
            {
               _loc3_ = int(this._fire_nodes.length - 1);
               while(_loc3_ >= 0)
               {
                  if(this._fire_nodes[_loc3_].FireArea.hitTestObject(_loc1_.GetUserData().objectData.ShapeMC))
                  {
                     if(this._fire_nodes[_loc3_].IsFlamethrower)
                     {
                        _loc1_.GetUserData().objectData.Damage_Fire(this.game_speed * 6);
                     }
                     else
                     {
                        _loc1_.GetUserData().objectData.Damage_Fire(this.game_speed * 2);
                     }
                     _loc3_ = -1;
                  }
                  _loc3_--;
               }
            }
            _loc2_++;
         }
      }
      
      private function PlayerOverlap() : void
      {
         var _loc2_:* = 0;
         var _loc1_:int = 0;
         while(_loc1_ < this._Handler_Players.Players.length)
         {
            if(!this._Handler_Players.Players[_loc1_].State.Gone)
            {
               if(this._fire_mc.hitTestObject(this._Handler_Players.Players[_loc1_].CollisionMC))
               {
                  _loc2_ = int(this._fire_nodes.length - 1);
                  while(_loc2_ >= 0)
                  {
                     if(this._fire_nodes[_loc2_].Owner != _loc1_)
                     {
                        if(this._fire_nodes[_loc2_].PlayerNR != _loc1_)
                        {
                           if(this._fire_nodes[_loc2_].FireArea.hitTestObject(this._Handler_Players.Players[_loc1_].CollisionMC))
                           {
                              if(this._fire_nodes[_loc2_].IsFlamethrower)
                              {
                                 this._Handler_Players.Players[_loc1_].State.BurnState += 20;
                              }
                              this._Handler_Players.Players[_loc1_].FireContact(true,3);
                              _loc2_ = -1;
                           }
                        }
                     }
                     _loc2_--;
                  }
               }
               this.PlayerInFire(_loc1_);
            }
            _loc1_++;
         }
      }
      
      private function ObjectOverlap() : void
      {
         var _loc1_:b2Body = null;
         var _loc3_:* = 0;
         var _loc2_:int = 0;
         while(_loc2_ < this.m_world.BurnObjectList.length)
         {
            _loc1_ = this.m_world.BurnObjectList[_loc2_];
            if(!_loc1_.GetUserData().objectData.ObjectOnFire)
            {
               if(this._fire_mc.hitTestObject(_loc1_.GetUserData().objectData.ShapeMC))
               {
                  _loc3_ = int(this._fire_nodes.length - 1);
                  while(_loc3_ >= 0)
                  {
                     if(this._fire_nodes[_loc3_].FireArea.hitTestObject(_loc1_.GetUserData().objectData.ShapeMC))
                     {
                        this.AddFireToObject(_loc1_);
                        _loc3_ = -1;
                     }
                     _loc3_--;
                  }
               }
            }
            _loc2_++;
         }
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
      
      private function CollisionFireBlock(param1:Point) : Boolean
      {
         if(Boolean(this.CollisionStatic(param1)) || Boolean(this.CollisionStaticCloud(param1)))
         {
            return true;
         }
         var _loc2_:b2Body = this.m_world.GetDynamicBodyAt(param1.x,param1.y,true);
         if(_loc2_ != null)
         {
            if(_loc2_.GetUserData().objectData.CanBlockFire)
            {
               return true;
            }
         }
         return false;
      }
      
      public function AddFlame(param1:Number, param2:Number, param3:Number, param4:int) : void
      {
         var _loc5_:Number = param3 * (Math.PI / 180);
         var _loc6_:Number = 9 + Math.random() * 1;
         var _loc7_:b2Vec2 = new b2Vec2(Math.cos(_loc5_) * _loc6_,Math.sin(_loc5_) * _loc6_);
         this._fire_nodes.push(new FireNodeData(this._Handler_Effects,this._fire_mc,this._burn_timer,param1,param2,_loc7_.x,_loc7_.y,param4,1));
      }
      
      public function TriggerFireAt_Box2DScale(param1:String, param2:Number, param3:Number) : void
      {
         param2 = Math.round(param2 * 30);
         param3 = Math.round(param3 * 30);
         this.TriggerFireAt(param1,param2,param3);
      }
      
      public function TriggerFireAt(param1:String, param2:Number, param3:Number) : void
      {
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc18_:Boolean = false;
         var _loc19_:Point = null;
         var _loc20_:int = 0;
         this._Handler_Output.Trace("Fire Triggered At (" + param2 + ", " + param3 + ")");
         if(this._static_world_hitbox_mc.hitTestPoint(param2,param3,true))
         {
            if(!this._static_objects_hitbox_mc.hitTestPoint(param2,param3,true))
            {
               this._Handler_Output.Trace("Fire triggered inside a static object. Aborting fire");
               return;
            }
         }
         var _loc8_:Number = 3;
         var _loc9_:Number = 0.5;
         var _loc10_:int = 22;
         var _loc11_:Number = 20;
         switch(param1.toUpperCase())
         {
            case "GASCAN":
            case "BARREL":
               _loc11_ = 16;
               _loc8_ = 2.2;
               _loc9_ = 0.4;
               _loc10_ = 18;
         }
         var _loc12_:Number = 0;
         while(_loc12_ < _loc10_)
         {
            _loc4_ = Math.PI / (_loc10_ / 2) * _loc12_;
            _loc7_ = _loc8_ + Math.random() * _loc9_;
            _loc5_ = Math.cos(_loc4_) * _loc7_;
            _loc6_ = Math.sin(_loc4_) * _loc7_ - Math.random() * 0.5;
            this._fire_nodes.push(new FireNodeData(this._Handler_Effects,this._fire_mc,this._burn_timer,param2 + Math.cos(_loc4_) * 3,param3 + Math.sin(_loc4_) * 3,_loc5_,_loc6_));
            _loc12_++;
         }
         var _loc17_:int = 0;
         while(_loc17_ < this._Handler_Players.Players.length)
         {
            _loc13_ = param2;
            _loc14_ = param3;
            _loc15_ = this._Handler_Players.Players[_loc17_].MidPosX() - param2;
            _loc16_ = this._Handler_Players.Players[_loc17_].MidPosY() - param3;
            if(Math.sqrt(_loc15_ * _loc15_ + _loc16_ * _loc16_) <= _loc11_)
            {
               _loc5_ = _loc15_ / _loc11_;
               _loc6_ = _loc16_ / _loc11_;
               _loc18_ = false;
               _loc19_ = new Point(param2,param3);
               _loc20_ = 1;
               while(_loc20_ <= _loc11_)
               {
                  _loc19_.x += _loc5_;
                  _loc19_.y += _loc6_;
                  if(this.CollisionFireBlock(_loc19_))
                  {
                     _loc18_ = true;
                     _loc20_ = _loc11_ + 1;
                  }
                  _loc20_++;
               }
               if(!_loc18_)
               {
                  this._Handler_Players.Players[_loc17_].State.BurnState = 100;
                  this.PlayerInFire(_loc17_);
               }
            }
            _loc17_++;
         }
      }
   }
}

