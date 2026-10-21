package Code.Handler
{
   import Code.Box2D.Common.Math.b2Vec2;
   import Code.Box2D.Dynamics.*;
   import flash.geom.*;
   
   public class Portals
   {
      
      private var m_world:b2World;
      
      private var _Handler_Players:PlayersKeeper;
      
      private var _Handler_Output:OutputTrace;
      
      private var _portals:Array;
      
      private var _bodyInPortals:Array;
      
      private var tmpVel:b2Vec2;
      
      public function Portals(param1:b2World, param2:PlayersKeeper, param3:OutputTrace)
      {
         super();
         this.m_world = param1;
         this._Handler_Players = param2;
         this._Handler_Output = param3;
         this._portals = new Array();
         this._bodyInPortals = new Array();
         this._Handler_Output.Trace("Portals Handler Created");
      }
      
      public function SetMapPortals(param1:Array) : void
      {
         this._portals = param1;
      }
      
      public function CheckBodyInsidePortal(param1:b2Body) : void
      {
         var _loc2_:Rectangle = null;
         var _loc3_:* = undefined;
         if(param1.IsDynamic() == true)
         {
            if(Boolean(param1.GetUserData().objectData.DrawHitBox) || Boolean(param1.GetUserData().objectData.DrawCloudBox))
            {
               this._Handler_Output.Trace("Checking Object " + param1.GetUserData().IDNumber + " for portal overlapping");
               _loc2_ = new Rectangle(param1.GetUserData().objectData.ShapeMC.x - param1.GetUserData().objectData.ShapeMC.width / 2,param1.GetUserData().objectData.ShapeMC.y - param1.GetUserData().objectData.ShapeMC.height / 2,param1.GetUserData().objectData.ShapeMC.width,param1.GetUserData().objectData.ShapeMC.height);
               _loc3_ = 0;
               while(_loc3_ < this._portals.length)
               {
                  if(Boolean(this._portals[_loc3_].PointInsidePortal(_loc2_.x,_loc2_.y)) || Boolean(this._portals[_loc3_].PointInsidePortal(_loc2_.x + _loc2_.width,_loc2_.y)) || Boolean(this._portals[_loc3_].PointInsidePortal(_loc2_.x,_loc2_.y + _loc2_.height)) || Boolean(this._portals[_loc3_].PointInsidePortal(_loc2_.x + _loc2_.width,_loc2_.y + _loc2_.height)))
                  {
                     this._Handler_Output.Trace("Object " + param1.GetUserData().IDNumber + " is overlapping portal " + _loc3_);
                     param1.GetUserData().objectData.CollisionMC.x = 9999;
                     param1.GetUserData().objectData.CollisionMC.y = 9999;
                     param1.GetUserData().objectData.InPortal = true;
                     this._bodyInPortals.push(param1);
                     return;
                  }
                  _loc3_++;
               }
            }
         }
      }
      
      public function Update() : void
      {
         var _loc3_:Rectangle = null;
         var _loc4_:* = undefined;
         var _loc5_:* = undefined;
         var _loc6_:int = 0;
         var _loc7_:b2Body = null;
         var _loc8_:int = 0;
         var _loc9_:b2Vec2 = null;
         var _loc1_:* = int(this._bodyInPortals.length - 1);
         while(_loc1_ >= 0)
         {
            _loc7_ = this._bodyInPortals[_loc1_];
            if(!_loc7_.IsSleeping())
            {
               _loc3_ = new Rectangle(_loc7_.GetUserData().objectData.ShapeMC.x - _loc7_.GetUserData().objectData.ShapeMC.width / 2,_loc7_.GetUserData().objectData.ShapeMC.y - _loc7_.GetUserData().objectData.ShapeMC.height / 2,_loc7_.GetUserData().objectData.ShapeMC.width,_loc7_.GetUserData().objectData.ShapeMC.height);
               _loc4_ = false;
               _loc5_ = 0;
               while(_loc5_ < this._portals.length)
               {
                  if(Boolean(this._portals[_loc5_].PointInsidePortal(_loc3_.x,_loc3_.y)) || Boolean(this._portals[_loc5_].PointInsidePortal(_loc3_.x + _loc3_.width,_loc3_.y)) || Boolean(this._portals[_loc5_].PointInsidePortal(_loc3_.x,_loc3_.y + _loc3_.height)) || Boolean(this._portals[_loc5_].PointInsidePortal(_loc3_.x + _loc3_.width,_loc3_.y + _loc3_.height)))
                  {
                     _loc4_ = true;
                     _loc5_ = this._portals.length;
                  }
                  _loc5_++;
               }
               if(!_loc4_)
               {
                  _loc7_.GetUserData().objectData.InPortal = false;
                  this._bodyInPortals.splice(_loc1_,1);
               }
            }
            _loc1_--;
         }
         var _loc2_:* = 0;
         while(_loc2_ < this._portals.length)
         {
            _loc6_ = 0;
            while(_loc6_ < this._Handler_Players.Players.length)
            {
               if(this._Handler_Players.Players[_loc6_].PortalSpeedX > 0)
               {
                  if(this._portals[_loc2_].PointInsidePortal(this._Handler_Players.Players[_loc6_].PosX(),this._Handler_Players.Players[_loc6_].PosY() - 6))
                  {
                     if(this._Handler_Players.Players[_loc6_].PortalDirectionX < 0 && this._portals[_loc2_].TriggerVelocity.x < 0 || this._Handler_Players.Players[_loc6_].PortalDirectionX > 0 && this._portals[_loc2_].TriggerVelocity.x > 0)
                     {
                        if(Boolean(this._portals[_loc2_].AllowPlayers) || Boolean(this._Handler_Players.Players[_loc6_].Bot))
                        {
                           _loc9_ = this._portals[_loc2_].GetTargetPositionFromCurrent(this._Handler_Players.Players[_loc6_].PosX(),this._Handler_Players.Players[_loc6_].PosY());
                           this._Handler_Players.Players[_loc6_].SetCoordinates(_loc9_.x * 30,_loc9_.y * 30,this._portals[_loc2_].InverseX,this._portals[_loc2_].AllowPlayers);
                           this._Handler_Players.RecalculateCamArea(3,true);
                           this._Handler_Output.Trace("Portal " + _loc2_ + " Activated");
                        }
                        else
                        {
                           this._Handler_Players.Players[_loc6_].SetCoordinates(this._portals[_loc2_].GetSideOfPortal(-this._Handler_Players.Players[_loc6_].PortalDirectionX),this._Handler_Players.Players[_loc6_].PosY(),true);
                        }
                     }
                  }
               }
               _loc6_++;
            }
            _loc8_ = 0;
            while(_loc8_ < this.m_world.AllDynamicObjectList.length)
            {
               _loc7_ = this.m_world.AllDynamicObjectList[_loc8_];
               if(this._portals[_loc2_].PointInsidePortal(_loc7_.GetPosition().x * 30,_loc7_.GetPosition().y * 30))
               {
                  if(_loc7_.GetLinearVelocity().Length() > 1)
                  {
                     if(_loc7_.GetLinearVelocity().x < -0.1 && this._portals[_loc2_].TriggerVelocity.x < 0 || _loc7_.GetLinearVelocity().x > 0.1 && this._portals[_loc2_].TriggerVelocity.x > 0 || _loc7_.GetLinearVelocity().y < 0 && this._portals[_loc2_].TriggerVelocity.y < 0 || _loc7_.GetLinearVelocity().y > 0 && this._portals[_loc2_].TriggerVelocity.y > 0)
                     {
                        _loc7_.GetUserData().objectData.ThroughPortal = true;
                        _loc7_.SetXForm(this._portals[_loc2_].GetTargetPositionFromCurrent(_loc7_.GetPosition().x * 30,_loc7_.GetPosition().y * 30),_loc7_.GetAngle());
                        if(this._portals[_loc2_].InverseX)
                        {
                           this.tmpVel = _loc7_.GetLinearVelocity();
                           this.tmpVel.x *= -1;
                           _loc7_.SetLinearVelocity(this.tmpVel);
                        }
                        if(this._portals[_loc2_].InverseY)
                        {
                           this.tmpVel = _loc7_.GetLinearVelocity();
                           this.tmpVel.y *= -1;
                           _loc7_.SetLinearVelocity(this.tmpVel);
                        }
                        this._Handler_Output.Trace("Portal " + _loc2_ + " Activated");
                        if(_loc7_.GetUserData().objectData.CanGibb)
                        {
                           if(!_loc7_.GetUserData().objectData.InPortal)
                           {
                              this._Handler_Output.Trace("Object " + _loc7_.GetUserData().IDNumber + " is overlapping portal " + _loc2_);
                              _loc7_.GetUserData().objectData.CollisionMC.x = 9999;
                              _loc7_.GetUserData().objectData.CollisionMC.y = 9999;
                              _loc7_.GetUserData().objectData.InPortal = true;
                              this._bodyInPortals.push(_loc7_);
                           }
                        }
                     }
                  }
               }
               _loc8_++;
            }
            _loc2_++;
         }
      }
   }
}

