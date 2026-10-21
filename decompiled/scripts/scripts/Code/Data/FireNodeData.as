package Code.Data
{
   import Code.Box2D.Common.Math.*;
   import Code.Box2D.Dynamics.*;
   import Code.Data.Players.Player;
   import Code.Handler.Effects;
   import Code.Particles.*;
   import flash.display.*;
   
   public class FireNodeData
   {
      
      private var _Handler_Effects:Effects;
      
      private var _fire_node_done:Boolean = false;
      
      private var _burn_timer:Number;
      
      private var _inAir:Boolean = true;
      
      private var _fire_area_mc:MovieClip;
      
      private var _air_mc:MovieClip;
      
      private var _air_mc_removed:Boolean = false;
      
      private var _velX:Number;
      
      private var _velY:Number;
      
      private var _posX:Number;
      
      private var _posY:Number;
      
      private var _lastEffectX:Number;
      
      private var _lastEffectY:Number;
      
      private var _effect_timer:Number = 0;
      
      private var _b2Body:b2Body = null;
      
      private var _b2BodyLocalPosition:b2Vec2;
      
      private var _b2BodyBurning:b2Body = null;
      
      private var _playerBurnTarget:Player = null;
      
      private var _playerNr:int = -1;
      
      private var _playerBurnLevel:int = 0;
      
      private var _lifeSpan:Number = 10;
      
      private var _slowingDown:Boolean = true;
      
      private var _owner:int = -1;
      
      private var _fireType:int = 0;
      
      private var _ownerResetTimer:Number;
      
      private var _currentFrame:Number;
      
      private var _onlyBurnWakeTimer:Number = 0;
      
      private var _passCloud:Number = 0;
      
      public function FireNodeData(param1:Effects, param2:MovieClip, param3:Number, param4:Number, param5:Number, param6:Number, param7:Number, param8:int = -1, param9:int = 0)
      {
         super();
         this._Handler_Effects = param1;
         this._burn_timer = param3;
         this._posX = param4;
         this._posY = param5;
         this._velX = param6;
         this._velY = param7;
         this._lastEffectX = this._posX;
         this._lastEffectY = this._posY;
         this._owner = param8;
         this._ownerResetTimer = 24;
         this._fireType = param9;
         this._currentFrame = 0;
         this._effect_timer = Math.random() * 3;
         this._fire_area_mc = new MovieClip();
         this._fire_area_mc.graphics.lineStyle(1,16776960,1,false,"none");
         this._fire_area_mc.graphics.beginFill(16776960,0.4);
         this._fire_area_mc.graphics.drawCircle(0,0,5);
         this._fire_area_mc.graphics.endFill();
         param2.addChild(this._fire_area_mc);
         this._fire_area_mc.x = this._posX;
         this._fire_area_mc.y = this._posY;
         this._passCloud = 0;
         switch(this._fireType)
         {
            case 0:
               this._air_mc = new fire_effect_air();
               break;
            case 1:
               this._air_mc = new fire_effect_flamethrower_air();
               this._passCloud = 8;
               break;
            default:
               this._air_mc = new fire_effect_air();
         }
         this._Handler_Effects.EffectMCFront.addChild(this._air_mc);
         this._air_mc_removed = false;
      }
      
      public function Update(param1:Number) : void
      {
         var _loc2_:b2Vec2 = null;
         if(this._passCloud > 0)
         {
            this._passCloud -= param1;
         }
         if(this._playerBurnTarget != null)
         {
            if(this._playerBurnTarget.State.IgnoreMe)
            {
               this._burn_timer = 0;
            }
            if(this._playerBurnLevel == 1 && this._playerBurnTarget.State.BurnState < this._playerBurnTarget.State.FireRank1Minimum)
            {
               this._playerBurnTarget.State.FireRank1Attached = false;
               this._burn_timer = 0;
            }
            if(this._playerBurnLevel == 2 && this._playerBurnTarget.State.BurnState < this._playerBurnTarget.State.FireRank2Minimum)
            {
               this._playerBurnTarget.State.FireRank2Attached = false;
               this._burn_timer = 0;
            }
            if(this._playerBurnTarget.State.BurnState > 0)
            {
               this._playerBurnTarget.FireContact();
               this._posX = this._playerBurnTarget.MidPosX();
               this._posY = this._playerBurnTarget.MidPosY();
               this.UpdateMC();
               this._effect_timer -= param1;
               if(this._effect_timer <= 0)
               {
                  this.AddEffectPlayer();
                  this._effect_timer = 3;
               }
               else if(this.EffectDistancePass(4))
               {
                  this.AddEffectPlayer();
                  this._effect_timer = 3;
               }
            }
         }
         else if(this._b2BodyBurning != null)
         {
            _loc2_ = this._b2BodyBurning.GetWorldPoint(new b2Vec2(0,0));
            this._posX = _loc2_.x * 30;
            this._posY = _loc2_.y * 30;
            this.UpdateMC();
            this._lifeSpan += param1;
            this._effect_timer -= param1;
            if(this._effect_timer <= 0)
            {
               this.AddEffectDynamic();
               this._effect_timer = 2 + Math.random();
            }
            else if(this.EffectDistancePass(4))
            {
               this.AddEffectDynamic(4);
               this._effect_timer = 3 + Math.random() * 2;
            }
            if(this._b2BodyBurning.m_userData.destroyed == true)
            {
               this._burn_timer = 0;
            }
            else
            {
               this._b2BodyBurning.m_userData.objectData.Damage_Fire(param1);
               if(this._b2BodyBurning.m_userData.objectData.OnlyBurnWhileWake)
               {
                  if(this._b2BodyBurning.IsSleeping())
                  {
                     this._burn_timer = 0;
                     this._b2BodyBurning.m_userData.objectData.ObjectOnFire = false;
                  }
                  else if(this._onlyBurnWakeTimer < 10)
                  {
                     if(Math.abs(this._b2BodyBurning.GetLinearVelocity().LengthSquared()) < 0.1)
                     {
                        this._onlyBurnWakeTimer += param1;
                        if(this._onlyBurnWakeTimer >= 10)
                        {
                           this._burn_timer = 0;
                           this._b2BodyBurning.m_userData.objectData.ObjectOnFire = false;
                        }
                     }
                  }
                  else
                  {
                     this._onlyBurnWakeTimer = 0;
                  }
               }
               else if(this._lifeSpan > this._b2BodyBurning.m_userData.objectData.FireLifeSpan && this._b2BodyBurning.m_userData.objectData.FireLifeSpan > 0)
               {
                  this._burn_timer = 0;
                  this._b2BodyBurning.m_userData.objectData.ObjectOnFire = false;
               }
            }
         }
         else
         {
            this._burn_timer -= param1;
            if(this._b2Body != null)
            {
               _loc2_ = this._b2Body.GetWorldPoint(this._b2BodyLocalPosition);
               this._posX = _loc2_.x * 30;
               this._posY = _loc2_.y * 30;
               this.UpdateMC();
               this._effect_timer -= param1;
               if(this._effect_timer <= 0)
               {
                  this.AddEffectGround(!this._inAir);
                  this._effect_timer = 3 + Math.random() * 2;
               }
               else if(this.EffectDistancePass(5))
               {
                  this.AddEffectGround();
                  this._effect_timer = 3 + Math.random() * 2;
               }
            }
            else
            {
               this._effect_timer -= param1;
               if(this._effect_timer <= 0)
               {
                  this.AddEffectGround(!this._inAir);
                  this._effect_timer = 3 + Math.random() * 2;
               }
               else if(this._inAir)
               {
                  if(this.EffectDistancePass(4))
                  {
                     this.AddEffectGround();
                  }
               }
            }
         }
         if(!this._air_mc_removed)
         {
            if(!this._inAir)
            {
               this._air_mc.parent.removeChild(this._air_mc);
               this._air_mc_removed = true;
               this._fireType = 0;
               this._ownerResetTimer = 0;
               this._owner = -1;
            }
            else
            {
               this._air_mc.x = this._posX;
               this._air_mc.y = this._posY;
               if(this._fireType == 1)
               {
                  this._currentFrame += param1;
                  this._air_mc.gotoAndStop(Math.ceil(this._currentFrame));
               }
            }
         }
         else if(this._ownerResetTimer > 0)
         {
            this._ownerResetTimer -= param1;
            if(this._ownerResetTimer <= 0)
            {
               this._ownerResetTimer = 0;
               this._owner = -1;
            }
         }
         if(this._burn_timer <= 0)
         {
            this.End();
         }
      }
      
      private function EffectDistancePass(param1:Number) : Boolean
      {
         var _loc2_:Number = this._lastEffectX - this._posX;
         var _loc3_:Number = this._lastEffectY - this._posY;
         if(Math.sqrt(_loc2_ * _loc2_ + _loc3_ * _loc3_) > param1)
         {
            return true;
         }
         return false;
      }
      
      private function AddEffectGround(param1:Boolean = false) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         this._lastEffectX = this._posX;
         this._lastEffectY = this._posY;
         if(this._fireType == 1 && this._currentFrame <= this._air_mc.totalFrames - 2)
         {
            this._Handler_Effects.AddParticle(new particle_data("FIRE_FLAMETHROWER",this._posX + Math.random() * 6 - 3,this._posY + Math.random(),new b2Vec2(this._velX,this._velY)));
         }
         else
         {
            this._Handler_Effects.AddParticle(new particle_data("fire",this._posX + Math.random() * 6 - 3,this._posY + Math.random()));
         }
         if(param1)
         {
            if(Math.random() < 0.4)
            {
               _loc2_ = this._posX + Math.random() * 6 - 3;
               _loc3_ = this._posY + Math.random();
               this._Handler_Effects.AddParticle(new particle_data("fireground",_loc2_,_loc3_));
               if(Math.random() <= 0.5)
               {
                  this._Handler_Effects.AddParticle(new particle_data("smoke_fire",_loc2_,_loc3_));
               }
            }
         }
      }
      
      private function AddEffectDynamic(param1:int = 0) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:int = 0;
         if(param1 == 0)
         {
            _loc2_ = Math.random() * this._b2BodyBurning.m_userData.objectData.ShapeMC.width - this._b2BodyBurning.m_userData.objectData.ShapeMC.width / 2;
            _loc3_ = Math.random() * this._b2BodyBurning.m_userData.objectData.ShapeMC.height - this._b2BodyBurning.m_userData.objectData.ShapeMC.height / 2;
            this._Handler_Effects.AddParticle(new particle_data("fire",this._posX + _loc2_ * 0.9,this._posY + _loc3_ * 0.9));
         }
         else if(!this._b2BodyBurning.m_userData.objectData.ThroughPortal)
         {
            _loc4_ = this._posX - this._lastEffectX;
            _loc5_ = this._posY - this._lastEffectY;
            _loc6_ = Math.sqrt(_loc4_ * _loc4_ + _loc5_ * _loc5_);
            _loc7_ = _loc4_ / _loc6_;
            _loc8_ = _loc5_ / _loc6_;
            _loc9_ = param1;
            while(_loc9_ <= _loc6_)
            {
               _loc2_ = Math.random() * this._b2BodyBurning.m_userData.objectData.ShapeMC.width - this._b2BodyBurning.m_userData.objectData.ShapeMC.width / 2;
               _loc3_ = Math.random() * this._b2BodyBurning.m_userData.objectData.ShapeMC.height - this._b2BodyBurning.m_userData.objectData.ShapeMC.height / 2;
               this._Handler_Effects.AddParticle(new particle_data("fire",this._posX + _loc7_ * _loc9_ + _loc2_ * 0.9,this._posY + _loc8_ * _loc9_ + _loc3_ * 0.9));
               _loc9_ += param1;
            }
         }
         else
         {
            this._b2BodyBurning.m_userData.objectData.ThroughPortal = false;
         }
         this._lastEffectX = this._posX;
         this._lastEffectY = this._posY;
      }
      
      private function AddEffectPlayer() : void
      {
         this._lastEffectX = this._posX;
         this._lastEffectY = this._posY;
         this._Handler_Effects.AddParticle(new particle_data("fire",this._playerBurnTarget.MidPosX() + Math.random() * 8 - 4,this._playerBurnTarget.MidPosY() + Math.random() * 12 - 6));
      }
      
      public function End() : void
      {
         if(!this._air_mc_removed)
         {
            this._air_mc.parent.removeChild(this._air_mc);
            this._air_mc_removed = true;
         }
         this._fire_area_mc.parent.removeChild(this._fire_area_mc);
         this._fire_node_done = true;
      }
      
      public function BurnPlayer(param1:Player, param2:int, param3:int) : void
      {
         this._b2Body = null;
         this._b2BodyBurning = null;
         this._playerBurnTarget = param1;
         this._playerNr = param2;
         this._playerBurnLevel = param3;
         this._inAir = false;
         if(!this._air_mc_removed)
         {
            this._air_mc.parent.removeChild(this._air_mc);
            this._air_mc_removed = true;
         }
         if(this._playerBurnLevel == 1)
         {
            this._fire_area_mc.graphics.clear();
            this._fire_area_mc.graphics.lineStyle(1,16776960,1,false,"none");
            this._fire_area_mc.graphics.beginFill(16776960,0.4);
            this._fire_area_mc.graphics.moveTo(-4,8);
            this._fire_area_mc.graphics.lineTo(-4,-8);
            this._fire_area_mc.graphics.lineTo(4,-8);
            this._fire_area_mc.graphics.lineTo(4,8);
            this._fire_area_mc.graphics.lineTo(4,8);
            this._fire_area_mc.graphics.endFill();
         }
         else if(this._playerBurnLevel == 2)
         {
            this._fire_area_mc.graphics.clear();
            this._fire_area_mc.addChild(new fire_big());
         }
         this._posX = this._playerBurnTarget.MidPosX();
         this._posY = this._playerBurnTarget.MidPosY();
         this._lastEffectX = this._posX;
         this._lastEffectY = this._posY;
         this.UpdateMC();
      }
      
      public function FollowBody(param1:b2Body, param2:b2Vec2) : void
      {
         this._b2Body = param1;
         this._b2BodyLocalPosition = param2;
         this._b2BodyBurning = null;
         this._playerBurnTarget = null;
         this._playerNr = -1;
         var _loc3_:b2Vec2 = this._b2Body.GetWorldPoint(this._b2BodyLocalPosition);
         this._posX = _loc3_.x * 30;
         this._posY = _loc3_.y * 30;
         this._lastEffectX = this._posX;
         this._lastEffectY = this._posY;
         this._inAir = false;
         if(!this._air_mc_removed)
         {
            this._air_mc.parent.removeChild(this._air_mc);
            this._air_mc_removed = true;
         }
      }
      
      public function BurnBody(param1:b2Body) : void
      {
         this._b2BodyBurning = param1;
         this._b2Body = null;
         this._playerBurnTarget = null;
         this._playerNr = -1;
         var _loc2_:Number = Number(param1.m_userData.objectData.ShapeMC.width);
         var _loc3_:Number = Number(param1.m_userData.objectData.ShapeMC.height);
         var _loc4_:Number = Math.sqrt(_loc2_ * _loc2_ + _loc3_ * _loc3_) / 2;
         if(_loc4_ < 5)
         {
            _loc4_ = 5;
         }
         this._fire_area_mc.graphics.clear();
         this._fire_area_mc.graphics.lineStyle(1,16776960,1,false,"none");
         this._fire_area_mc.graphics.beginFill(16776960,0.4);
         this._fire_area_mc.graphics.drawCircle(0,0,_loc4_);
         this._fire_area_mc.graphics.endFill();
         var _loc5_:b2Vec2 = this._b2BodyBurning.GetWorldPoint(new b2Vec2(0,0));
         this._posX = _loc5_.x * 30;
         this._posY = _loc5_.y * 30;
         this._lastEffectX = this._posX;
         this._lastEffectY = this._posY;
         this.UpdateMC();
         this._lifeSpan = 0;
         this._inAir = false;
         if(!this._air_mc_removed)
         {
            this._air_mc.parent.removeChild(this._air_mc);
            this._air_mc_removed = true;
         }
      }
      
      public function UpdateMC() : void
      {
         this._fire_area_mc.x = this._posX;
         this._fire_area_mc.y = this._posY;
      }
      
      public function get CanBeMerged() : Boolean
      {
         if(this._inAir)
         {
            return false;
         }
         if(this._playerBurnTarget != null)
         {
            return false;
         }
         return true;
      }
      
      public function get IsFlamethrower() : Boolean
      {
         return this._fireType == 1;
      }
      
      public function get Owner() : int
      {
         return this._owner;
      }
      
      public function get SlowingDown() : Boolean
      {
         return this._slowingDown;
      }
      
      public function set SlowingDown(param1:Boolean) : void
      {
         this._slowingDown = param1;
      }
      
      public function get PassCloud() : Boolean
      {
         return this._passCloud > 0;
      }
      
      public function get BurnTimer() : Number
      {
         return this._burn_timer;
      }
      
      public function set BurnTimer(param1:Number) : void
      {
         this._burn_timer = param1;
      }
      
      public function get InAir() : Boolean
      {
         return this._inAir;
      }
      
      public function set InAir(param1:Boolean) : void
      {
         this._inAir = param1;
      }
      
      public function get PlayerNR() : int
      {
         return this._playerNr;
      }
      
      public function get TotalVel() : Number
      {
         return Math.sqrt(this._velY * this._velY + this._velX * this._velX);
      }
      
      public function get VelY() : Number
      {
         return this._velY;
      }
      
      public function set VelY(param1:Number) : void
      {
         this._velY = param1;
      }
      
      public function get VelX() : Number
      {
         return this._velX;
      }
      
      public function set VelX(param1:Number) : void
      {
         this._velX = param1;
      }
      
      public function get PosY() : Number
      {
         return this._posY;
      }
      
      public function set PosY(param1:Number) : void
      {
         this._posY = param1;
      }
      
      public function get PosX() : Number
      {
         return this._posX;
      }
      
      public function set PosX(param1:Number) : void
      {
         this._posX = param1;
      }
      
      public function get FireArea() : MovieClip
      {
         if(this._lifeSpan > 6)
         {
            return this._fire_area_mc;
         }
         return new MovieClip();
      }
      
      public function get FireNodeCompleted() : Boolean
      {
         return this._fire_node_done;
      }
   }
}

