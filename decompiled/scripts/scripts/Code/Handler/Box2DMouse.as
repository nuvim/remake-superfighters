package Code.Handler
{
   import Code.Box2D.Collision.*;
   import Code.Box2D.Collision.Shapes.*;
   import Code.Box2D.Common.*;
   import Code.Box2D.Common.Math.*;
   import Code.Box2D.Dynamics.*;
   import Code.Box2D.Dynamics.Contacts.*;
   import Code.Box2D.Dynamics.Joints.*;
   import flash.display.MovieClip;
   import flash.geom.Point;
   
   public class Box2DMouse
   {
      
      private var _Handler_Mouse:InputMouse;
      
      private var m_world:b2World;
      
      private var m_timeStep:Number;
      
      private var mousePVec:b2Vec2 = new b2Vec2();
      
      private var m_mouseJoint:b2MouseJoint;
      
      private var m_body:b2Body;
      
      private var mouseXWorldPhys:Number;
      
      private var mouseYWorldPhys:Number;
      
      private var mouseXWorld:Number;
      
      private var mouseYWorld:Number;
      
      public function Box2DMouse(param1:InputMouse, param2:b2World, param3:MovieClip)
      {
         super();
         this._Handler_Mouse = param1;
         this.m_world = param2;
      }
      
      public function UpdateMouseWorld(param1:Point, param2:Number, param3:Number) : void
      {
         this.m_timeStep = param3;
         this._Handler_Mouse.UpdateMouse(param1,param2);
         this.mouseXWorldPhys = this._Handler_Mouse.MouseX() / 30;
         this.mouseYWorldPhys = this._Handler_Mouse.MouseY() / 30;
         this.mouseXWorld = this._Handler_Mouse.MouseX();
         this.mouseYWorld = this._Handler_Mouse.MouseY();
      }
      
      public function GetMouseXWorldPhys() : Number
      {
         return this.mouseXWorldPhys;
      }
      
      public function GetMouseYWorldPhys() : Number
      {
         return this.mouseYWorldPhys;
      }
      
      public function MouseDrag() : void
      {
         var _loc1_:b2MouseJointDef = null;
         var _loc2_:b2Vec2 = null;
         if(Boolean(this._Handler_Mouse.MouseIsDown()) && !this.m_mouseJoint)
         {
            this.m_body = this.GetBodyAtMouse();
            if(this.m_body)
            {
               _loc1_ = new b2MouseJointDef();
               _loc1_.body1 = this.m_world.GetGroundBody();
               _loc1_.body2 = this.m_body;
               _loc1_.target.Set(this.mouseXWorldPhys,this.mouseYWorldPhys);
               _loc1_.maxForce = 300 * this.m_body.GetMass();
               _loc1_.timeStep = this.m_timeStep;
               this.m_mouseJoint = this.m_world.CreateJoint(_loc1_) as b2MouseJoint;
               this.m_body.GetUserData().locked = true;
               this.m_body.WakeUp();
            }
         }
         if(!this._Handler_Mouse.MouseIsDown())
         {
            if(this.m_mouseJoint)
            {
               this.m_body.GetUserData().locked = false;
               this.m_world.DestroyJoint(this.m_mouseJoint);
               this.m_mouseJoint = null;
               this.m_body = null;
            }
         }
         if(this.m_mouseJoint)
         {
            _loc2_ = new b2Vec2(this.mouseXWorldPhys,this.mouseYWorldPhys);
            this.m_mouseJoint.SetTarget(_loc2_);
         }
      }
      
      public function MouseDestroy(param1:Boolean = false) : void
      {
         var _loc2_:b2Body = null;
         if(!this._Handler_Mouse.MouseIsDown())
         {
            _loc2_ = this.GetBodyAtMouse(false);
            if(_loc2_)
            {
               if(param1)
               {
                  if(_loc2_.m_userData.objectData.DrawHitBox)
                  {
                     _loc2_.m_userData.objectData.CollisionMC.parent.removeChild(_loc2_.m_userData.objectData.CollisionMC);
                  }
                  _loc2_.m_userData.parent.removeChild(_loc2_.m_userData);
                  this.m_world.DestroyBody(_loc2_);
               }
               else
               {
                  _loc2_.GetUserData().objectData.ForceDestruction();
               }
               return;
            }
         }
      }
      
      public function MouseInteract() : void
      {
         var _loc1_:b2Body = null;
         var _loc2_:b2Vec2 = null;
         var _loc3_:b2Vec2 = null;
         _loc1_ = this.GetBodyAtMouse(false);
         if(_loc1_)
         {
            _loc2_ = new b2Vec2();
            _loc3_ = new b2Vec2();
            _loc2_.Set(0,-6 * _loc1_.GetMass());
            _loc3_.x = this.GetMouseXWorldPhys();
            _loc3_.y = this.GetMouseYWorldPhys();
            _loc1_.WakeUp();
            _loc1_.ApplyImpulse(_loc2_,_loc3_);
         }
      }
      
      private function GetBodyAtMouse(param1:Boolean = false) : b2Body
      {
         var _loc8_:b2Shape = null;
         var _loc9_:Boolean = false;
         this.mousePVec.Set(this.mouseXWorldPhys,this.mouseYWorldPhys);
         var _loc2_:b2AABB = new b2AABB();
         _loc2_.lowerBound.Set(this.mouseXWorldPhys - 0.001,this.mouseYWorldPhys - 0.001);
         _loc2_.upperBound.Set(this.mouseXWorldPhys + 0.001,this.mouseYWorldPhys + 0.001);
         var _loc3_:int = 10;
         var _loc4_:Array = new Array();
         var _loc5_:int = int(this.m_world.Query(_loc2_,_loc4_,_loc3_));
         var _loc6_:b2Body = null;
         var _loc7_:int = 0;
         while(_loc7_ < _loc5_)
         {
            if(_loc4_[_loc7_].GetBody().IsStatic() == false || param1)
            {
               _loc8_ = _loc4_[_loc7_] as b2Shape;
               _loc9_ = _loc8_.TestPoint(_loc8_.GetBody().GetXForm(),this.mousePVec);
               if(_loc9_)
               {
                  _loc6_ = _loc8_.GetBody();
                  break;
               }
            }
            _loc7_++;
         }
         return _loc6_;
      }
   }
}

