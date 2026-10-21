package Code.Data
{
   import Code.Box2D.Common.Math.*;
   import Code.Box2D.Dynamics.b2Body;
   import flash.display.*;
   
   public class Rope
   {
      
      internal var _body1:b2Body;
      
      internal var _local1:b2Vec2;
      
      internal var _body2:b2Body;
      
      internal var _local2:b2Vec2;
      
      internal var _mc:MovieClip;
      
      internal var _removed:Boolean;
      
      public function Rope(param1:b2Body, param2:b2Body, param3:b2Vec2, param4:b2Vec2)
      {
         super();
         this.BuildRope(param1,param2,param3,param4);
      }
      
      public function BuildRope(param1:b2Body, param2:b2Body, param3:b2Vec2, param4:b2Vec2) : *
      {
         var _loc7_:rope_segment_01 = null;
         this._body1 = param1;
         this._body2 = param2;
         this._local1 = this._body1.GetLocalPoint(param3);
         this._local2 = this._body2.GetLocalPoint(param4);
         var _loc5_:Number = Math.sqrt(Math.pow(param3.x * 30 - param4.x * 30,2) + Math.pow(param3.y * 30 - param4.y * 30,2));
         this._mc = new MovieClip();
         var _loc6_:int = 0;
         while(_loc6_ < _loc5_)
         {
            _loc7_ = new rope_segment_01();
            _loc7_.y = -_loc6_;
            this._mc.addChild(_loc7_);
            _loc6_ += 3;
         }
         this._removed = false;
         this.UpdateMC();
      }
      
      public function UpdateMC() : void
      {
         if(this._removed)
         {
            return;
         }
         var _loc1_:b2Vec2 = this._body1.GetWorldPoint(this._local1);
         var _loc2_:b2Vec2 = this._body2.GetWorldPoint(this._local2);
         this._mc.x = _loc1_.x * 30;
         this._mc.y = _loc1_.y * 30;
         var _loc3_:Number = Math.atan2(_loc1_.y - _loc2_.y,_loc1_.x - _loc2_.x);
         this._mc.rotation = _loc3_ * (180 / Math.PI) - 90;
      }
      
      public function Remove() : void
      {
         if(!this._removed)
         {
            this._mc.parent.removeChild(this._mc);
            this._removed = true;
         }
      }
      
      public function get MC() : MovieClip
      {
         return this._mc;
      }
   }
}

