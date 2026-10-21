package Code.Handler
{
   import Code.Box2D.Common.Math.*;
   import Code.Box2D.Dynamics.b2Body;
   import Code.Box2D.Dynamics.b2World;
   import Code.Data.*;
   import Code.Particles.*;
   import flash.display.*;
   import flash.geom.*;
   
   public class Explosions
   {
      
      private var _Handler_Output:OutputTrace;
      
      private var _Handler_Camera:Cam;
      
      private var _Handler_Shake:Shake;
      
      private var _Handler_Players:PlayersKeeper;
      
      private var _Handler_Effects:Effects;
      
      private var _Handler_Sounds:Sounds;
      
      private var _Handler_Fires:Fires;
      
      private var _Handler_Slowmo:Slowmo;
      
      private var _static_mc:MovieClip;
      
      private var _static_objects_hitbox_mc:MovieClip;
      
      private var _static_world_hitbox_mc:MovieClip;
      
      private var _static_world_cloud_hitbox_mc:MovieClip;
      
      private var _static_objects_cloud_hitbox_mc:MovieClip;
      
      private var _dynamic_mc:MovieClip;
      
      private var _object_mc:MovieClip;
      
      private var m_world:b2World;
      
      private var _explosion_mc:MovieClip = new MovieClip();
      
      private var _n:int = 36;
      
      private var _sp:Array;
      
      private var _r:Number = 0;
      
      private var _m:Number;
      
      private var _p:int;
      
      private var _powerForEachPin:Number;
      
      private var explosionPowerObjects:Number = 5;
      
      private var explosionPowerPlayers:Number = 5;
      
      private var explosionDamage:Number = 25;
      
      private var explosionDamagePlayers:Number = 20;
      
      private var explosionPosX:Number;
      
      private var explosionPosY:Number;
      
      private var explosionBuffer:Array = new Array();
      
      public function Explosions()
      {
         super();
      }
      
      public function BuildClass(param1:ExplosionData) : void
      {
         this._Handler_Output = param1.Handler_Output;
         this._Handler_Camera = param1.Handler_Camera;
         this._Handler_Shake = param1.Handler_Shake;
         this._Handler_Players = param1.Handler_Players;
         this._Handler_Effects = param1.Handler_Effects;
         this._Handler_Sounds = param1.Handler_Sounds;
         this._Handler_Slowmo = param1.Handler_Slowmo;
         this._static_mc = param1.static_mc;
         this._dynamic_mc = param1.dynamic_mc;
         this.m_world = param1.m_world;
         this._static_world_hitbox_mc = MovieClip(this._static_mc.getChildByName("WORLD_HITBOX"));
         this._static_objects_hitbox_mc = MovieClip(this._static_world_hitbox_mc.getChildByName("OBJECTS_HITBOX"));
         this._static_world_cloud_hitbox_mc = MovieClip(this._static_mc.getChildByName("WORLD_CLOUD_HITBOX"));
         this._static_objects_cloud_hitbox_mc = MovieClip(this._static_world_cloud_hitbox_mc.getChildByName("OBJECTS_CLOUD_HITBOX"));
         this._static_mc.addChild(this._explosion_mc);
         this._sp = new Array();
         var _loc2_:* = 0;
         while(_loc2_ < this._n)
         {
            this._sp.push(new Array(Math.cos(this.GradToRad(_loc2_ * (360 / this._n))),Math.sin(this.GradToRad(_loc2_ * (360 / this._n))),2,3,0,0));
            _loc2_++;
         }
         this._Handler_Output.Trace("Explosion Handler Created");
      }
      
      public function LinkToFire(param1:Fires) : void
      {
         this._Handler_Fires = param1;
      }
      
      private function GradToRad(param1:Number) : Number
      {
         return Math.PI / 180 * param1;
      }
      
      public function Update(param1:Number) : void
      {
         var _loc2_:int = 0;
         var _loc3_:b2Body = null;
         if(this.explosionBuffer.length > 0)
         {
            _loc2_ = 0;
            while(_loc2_ < this.explosionBuffer.length)
            {
               this.explosionBuffer[_loc2_][0] = this.explosionBuffer[_loc2_][0] - 1;
               if(this.explosionBuffer[_loc2_][0] <= 0)
               {
                  _loc3_ = this.explosionBuffer[_loc2_][1];
                  _loc3_.m_userData.objectData.Damage_Explosion(this.explosionBuffer[_loc2_][2]);
                  this.explosionBuffer.splice(_loc2_,1);
               }
               _loc2_++;
            }
         }
      }
      
      public function TriggerExplosionAt_Box2DScale(param1:String, param2:Number, param3:Number) : void
      {
         param2 = Math.round(param2 * 30);
         param3 = Math.round(param3 * 30);
         this.TriggerExplosionAt(param1,param2,param3);
      }
      
      public function TriggerExplosionAt(param1:String, param2:Number, param3:Number) : Boolean
      {
         var _loc5_:b2Body = null;
         var _loc6_:Number = NaN;
         var _loc7_:int = 0;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc16_:Boolean = false;
         var _loc17_:Number = NaN;
         var _loc18_:Number = NaN;
         var _loc19_:* = undefined;
         var _loc20_:int = 0;
         var _loc21_:* = undefined;
         this._Handler_Output.Trace("Explosion Triggered At (" + param2 + ", " + param3 + ")");
         if(this._static_world_hitbox_mc.hitTestPoint(param2,param3,true))
         {
            if(!this._static_objects_hitbox_mc.hitTestPoint(param2,param3,true))
            {
               _loc16_ = true;
               _loc17_ = param2 - 5;
               while(_loc17_ <= param2 + 5)
               {
                  _loc18_ = param3 - 5;
                  while(_loc18_ <= param3 + 5)
                  {
                     if(!(Boolean(this._static_world_hitbox_mc.hitTestPoint(_loc17_,_loc18_,true)) && !this._static_objects_hitbox_mc.hitTestPoint(_loc17_,_loc18_,true)))
                     {
                        param2 = _loc17_;
                        param3 = _loc18_;
                        _loc16_ = false;
                        _loc17_ = param2 + 10;
                        _loc18_ = param3 + 10;
                        this._Handler_Output.Trace("Explosion Triggered At Updated Position (" + param2 + ", " + param3 + ")");
                     }
                     _loc18_ += 5;
                  }
                  _loc17_ += 5;
               }
               if(_loc16_)
               {
                  this._Handler_Output.Trace("Explosion triggered inside a static object. Aborting explosion");
                  return false;
               }
            }
         }
         this.explosionPosX = param2;
         this.explosionPosY = param3;
         if(this._Handler_Camera.IsInside(new Point(param2,param3)))
         {
            this._Handler_Shake.Add(5,4);
         }
         this._r = 33;
         this._m = 0;
         this._p = this._n;
         var _loc4_:int = 3;
         _loc7_ = 0;
         while(_loc7_ < this._n)
         {
            this._sp[_loc7_][2] = param2;
            this._sp[_loc7_][3] = param3;
            this._sp[_loc7_][4] = 0;
            _loc19_ = 0;
            while(_loc19_ <= this._r)
            {
               this._sp[_loc7_][2] += this._sp[_loc7_][0] * _loc4_;
               this._sp[_loc7_][3] += this._sp[_loc7_][1] * _loc4_;
               if(Boolean(this._static_world_hitbox_mc.hitTestPoint(this._sp[_loc7_][2],this._sp[_loc7_][3],true)) || Boolean(this._static_world_cloud_hitbox_mc.hitTestPoint(this._sp[_loc7_][2],this._sp[_loc7_][3],true)))
               {
                  if(!this._static_objects_hitbox_mc.hitTestPoint(this._sp[_loc7_][2],this._sp[_loc7_][3],true) && !this._static_objects_cloud_hitbox_mc.hitTestPoint(this._sp[_loc7_][2],this._sp[_loc7_][3],true))
                  {
                     this._sp[_loc7_][2] += this._sp[_loc7_][0] * _loc4_;
                     this._sp[_loc7_][3] += this._sp[_loc7_][1] * _loc4_;
                     this._sp[_loc7_][4] = 1;
                     this._sp[_loc7_][5] = _loc19_;
                     this._m += this._r - _loc19_;
                     --this._p;
                     break;
                  }
                  _loc5_ = this.m_world.GetDynamicBodyAt(this._sp[_loc7_][2],this._sp[_loc7_][3],true);
                  if(_loc5_ == null)
                  {
                     this._Handler_Output.Trace("Error 2: Object \'" + _loc5_ + "\' doesn\'t exist");
                  }
                  else if(_loc5_.m_userData.objectData.CanBlockExplosions)
                  {
                     this._sp[_loc7_][2] += this._sp[_loc7_][0] * _loc4_;
                     this._sp[_loc7_][3] += this._sp[_loc7_][1] * _loc4_;
                     this._sp[_loc7_][4] = 1;
                     this._sp[_loc7_][5] = _loc19_;
                     this._m += this._r - _loc19_;
                     --this._p;
                     if(_loc5_.m_userData.objectData.AffectedByExplosions)
                     {
                        _loc6_ = 1 - _loc19_ / this._r;
                        _loc6_ = _loc6_ * 4;
                        if(_loc6_ > 1)
                        {
                           _loc6_ = 1;
                        }
                        _loc6_ *= 0.01 * _loc5_.GetMass();
                        _loc5_.ApplyImpulse(new b2Vec2((this._sp[_loc7_][2] - param2) * _loc6_,(this._sp[_loc7_][3] - param3 - 10) * _loc6_),new b2Vec2(this._sp[_loc7_][2] / 30,this._sp[_loc7_][3] / 30));
                        _loc5_.GetUserData().objectData.Damage_Explosion(this.explosionDamage * 0.1);
                     }
                     break;
                  }
               }
               _loc19_ += _loc4_;
            }
            if(this._sp[_loc7_][4] == 0)
            {
               this._sp[_loc7_][5] = this._r;
            }
            _loc7_++;
         }
         if(this._m > 0)
         {
            this._powerForEachPin = this._m / this._p * 0.25;
            if(this._powerForEachPin > this._r * 0.5)
            {
               this._powerForEachPin = this._r * 0.5;
            }
            _loc7_ = 0;
            while(_loc7_ < this._n)
            {
               if(this._sp[_loc7_][4] == 0)
               {
                  _loc21_ = 1;
                  while(_loc21_ <= this._powerForEachPin)
                  {
                     this._sp[_loc7_][2] += this._sp[_loc7_][0] * _loc4_;
                     this._sp[_loc7_][3] += this._sp[_loc7_][1] * _loc4_;
                     if(Boolean(this._static_world_hitbox_mc.hitTestPoint(this._sp[_loc7_][2],this._sp[_loc7_][3],true)) || Boolean(this._static_world_cloud_hitbox_mc.hitTestPoint(this._sp[_loc7_][2],this._sp[_loc7_][3],true)))
                     {
                        if(!this._static_objects_hitbox_mc.hitTestPoint(this._sp[_loc7_][2],this._sp[_loc7_][3],true) && !this._static_objects_cloud_hitbox_mc.hitTestPoint(this._sp[_loc7_][2],this._sp[_loc7_][3],true))
                        {
                           this._sp[_loc7_][2] += this._sp[_loc7_][0] * _loc4_;
                           this._sp[_loc7_][3] += this._sp[_loc7_][1] * _loc4_;
                           this._sp[_loc7_][4] = 1;
                           this._sp[_loc7_][5] += _loc21_;
                           break;
                        }
                        _loc5_ = this.m_world.GetDynamicBodyAt(this._sp[_loc7_][2],this._sp[_loc7_][3],true);
                        if(_loc5_ == null)
                        {
                           this._Handler_Output.Trace("Error 3: Object \'" + _loc5_ + "\' doesn\'t exist");
                        }
                        else if(_loc5_.m_userData.objectData.CanBlockExplosions)
                        {
                           this._sp[_loc7_][4] = 1;
                           this._sp[_loc7_][5] += _loc21_;
                           break;
                        }
                     }
                     _loc21_ += _loc4_;
                  }
                  if(this._sp[_loc7_][4] == 0)
                  {
                     this._sp[_loc7_][5] += this._powerForEachPin;
                  }
               }
               _loc7_++;
            }
            this._r += this._powerForEachPin;
            this._explosion_mc.graphics.clear();
            this._explosion_mc.graphics.lineStyle(1,16711680,1,false,"none");
            this._explosion_mc.graphics.beginFill(16711680,0);
            this._explosion_mc.graphics.moveTo(this._sp[0][2],this._sp[0][3]);
            _loc20_ = 1;
            while(_loc20_ < this._n)
            {
               this._explosion_mc.graphics.lineTo(this._sp[_loc20_][2],this._sp[_loc20_][3]);
               _loc20_++;
            }
            this._explosion_mc.graphics.lineTo(this._sp[0][2],this._sp[0][3]);
            this._explosion_mc.graphics.endFill();
         }
         else
         {
            this._explosion_mc.graphics.clear();
            this._explosion_mc.graphics.lineStyle(1,16711680,1,false,"none");
            this._explosion_mc.graphics.beginFill(16711680,0);
            this._explosion_mc.graphics.drawCircle(param2,param3,this._r + 1);
            this._explosion_mc.graphics.endFill();
         }
         var _loc13_:int = 0;
         var _loc14_:int = 0;
         while(_loc14_ < this._Handler_Players.Players.length)
         {
            if(!this._Handler_Players.Players[_loc14_].State.Gone)
            {
               if(this._explosion_mc.hitTestPoint(this._Handler_Players.Players[_loc14_].ExplosionX(),this._Handler_Players.Players[_loc14_].ExplosionY(),true))
               {
                  _loc10_ = this._Handler_Players.Players[_loc14_].ExplosionX() - this.explosionPosX;
                  _loc11_ = this._Handler_Players.Players[_loc14_].ExplosionY() - this.explosionPosY;
                  _loc12_ = Math.sqrt(_loc10_ * _loc10_ + _loc11_ * _loc11_);
                  if(_loc12_ <= this._r / 2)
                  {
                     _loc9_ = 1;
                  }
                  else
                  {
                     _loc9_ = 1 - (_loc12_ - this._r / 2) / (this._r / 2);
                     if(_loc9_ < 0)
                     {
                        _loc9_ = 0;
                     }
                  }
                  if(_loc9_ > 0)
                  {
                     _loc8_ = Math.atan2(_loc11_,_loc10_);
                     this._Handler_Players.Players[_loc14_].ExplosionHit(_loc8_,this.explosionPowerPlayers * _loc9_,this.explosionDamagePlayers * _loc9_);
                     if(!this._Handler_Players.Players[_loc14_].Ignore && this._Handler_Players.Players[_loc14_].State.HP > 0)
                     {
                        _loc13_ += 1;
                     }
                  }
               }
            }
            _loc14_++;
         }
         if(_loc13_ >= 2)
         {
            this._Handler_Slowmo.AddSlowmotion(new SlowmoData(0,24 * 1,24 * 0.5,0.25));
         }
         if(_loc13_ >= 1)
         {
            this._Handler_Shake.Add(2,2);
         }
         var _loc15_:b2Body = this.m_world.m_bodyList;
         while(_loc15_)
         {
            if(_loc15_.m_userData is Sprite)
            {
               if(this._explosion_mc.hitTestPoint(_loc15_.m_userData.x,_loc15_.m_userData.y,true))
               {
                  if(_loc15_.m_userData.objectData.AffectedByExplosions)
                  {
                     _loc10_ = _loc15_.m_userData.x - this.explosionPosX;
                     _loc11_ = _loc15_.m_userData.y - 4 - this.explosionPosY;
                     _loc12_ = Math.sqrt(_loc10_ * _loc10_ + _loc11_ * _loc11_);
                     if(_loc12_ <= this._r / 2)
                     {
                        _loc9_ = 1;
                     }
                     else
                     {
                        _loc9_ = 1 - (_loc12_ * 2 - this._r) / this._r;
                        if(_loc9_ < 0)
                        {
                           _loc9_ = 0;
                        }
                     }
                     if(_loc9_ > 0)
                     {
                        this._Handler_Fires.AddSmokeToObject(_loc15_,2);
                        _loc8_ = Math.atan2(_loc11_,_loc10_);
                        this.explosionBuffer.push([1,_loc15_,this.explosionDamage]);
                        _loc15_.ApplyImpulse(new b2Vec2(Math.cos(_loc8_) * _loc15_.GetMass() * this.explosionPowerObjects * _loc9_,Math.sin(_loc8_) * _loc15_.GetMass() * this.explosionPowerObjects * _loc9_),_loc15_.GetWorldPoint(new b2Vec2(-Math.cos(_loc8_) * 0.2,-Math.sin(_loc8_) * 0.1)));
                     }
                  }
               }
            }
            _loc15_ = _loc15_.m_next;
         }
         this._Handler_Effects.AddParticle(new particle_data("explosion_centrum",param2,param3));
         return true;
      }
   }
}

