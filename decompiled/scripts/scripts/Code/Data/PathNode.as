package Code.Data
{
   import Code.Box2D.Common.Math.*;
   import Code.Box2D.Dynamics.b2Body;
   
   public class PathNode
   {
      
      private var _binds:Array;
      
      private var _parentBody:b2Body;
      
      private var _parentBodyLocation:b2Vec2;
      
      private var _id:String;
      
      private var _activatorID:String;
      
      private var _posX:Number;
      
      private var _posY:Number;
      
      private var _listIndex:int = -1;
      
      private var _inFire:Boolean;
      
      private var _isHazard:Boolean;
      
      private var _locked:Boolean;
      
      private var _isEndNode:Boolean;
      
      public function PathNode(param1:String, param2:Number, param3:Number, param4:String, param5:b2Body)
      {
         var _loc6_:b2Vec2 = null;
         super();
         this._id = param1.toUpperCase();
         this._posX = param2;
         this._posY = param3;
         this._activatorID = param4;
         this._parentBody = param5;
         this._inFire = false;
         this._isHazard = false;
         this._locked = false;
         this._isEndNode = true;
         this._binds = new Array();
         if(this._parentBody != null)
         {
            _loc6_ = new b2Vec2(param2 / 30,param3 / 30);
            this._parentBodyLocation = this._parentBody.GetLocalPoint(_loc6_);
         }
      }
      
      public function UpdateIsEndNode() : void
      {
         this._isEndNode = false;
         var _loc1_:* = int(this._binds.length - 1);
         while(_loc1_ >= 0)
         {
            if(this._binds[_loc1_].MovementType != PathBind.PORTAL)
            {
               this._isEndNode = true;
               return;
            }
            _loc1_--;
         }
      }
      
      public function RemoveBind(param1:PathBind) : void
      {
         var _loc2_:* = int(this._binds.length - 1);
         while(_loc2_ >= 0)
         {
            if(this._binds[_loc2_] == param1)
            {
               this._binds.splice(_loc2_,1);
            }
            _loc2_--;
         }
      }
      
      public function GetBindTo(param1:PathNode) : PathBind
      {
         var _loc2_:int = 0;
         while(_loc2_ < this._binds.length)
         {
            if(this._binds[_loc2_].TargetNode == param1)
            {
               return this._binds[_loc2_];
            }
            _loc2_++;
         }
         return null;
      }
      
      public function GetDistanceTo(param1:Number, param2:Number) : Number
      {
         var _loc3_:Number = this._posX - param1;
         var _loc4_:Number = this._posY - param2;
         return Math.sqrt(_loc3_ * _loc3_ + _loc4_ * _loc4_);
      }
      
      public function get ID() : String
      {
         return this._id;
      }
      
      public function get PosX() : Number
      {
         return this._posX;
      }
      
      public function get PosY() : Number
      {
         return this._posY;
      }
      
      public function get Speed() : b2Vec2
      {
         if(this._parentBody != null)
         {
            return this._parentBody.GetLinearVelocity();
         }
         return new b2Vec2(0,0);
      }
      
      public function get SpeedX() : Number
      {
         if(this._parentBody != null)
         {
            return this._parentBody.GetLinearVelocity().x;
         }
         return 0;
      }
      
      public function get SpeedY() : Number
      {
         if(this._parentBody != null)
         {
            return this._parentBody.GetLinearVelocity().y;
         }
         return 0;
      }
      
      public function CalculateParentLocation() : void
      {
         this._posX = this._parentBody.GetWorldPoint(this._parentBodyLocation).x * 30;
         this._posY = this._parentBody.GetWorldPoint(this._parentBodyLocation).y * 30;
      }
      
      public function get Locked() : Boolean
      {
         return this._locked;
      }
      
      public function set Locked(param1:Boolean) : void
      {
         this._locked = param1;
      }
      
      public function get Avoid() : Boolean
      {
         return Boolean(this._isHazard) || Boolean(this._inFire);
      }
      
      public function get IsHazard() : Boolean
      {
         return this._isHazard;
      }
      
      public function set IsHazard(param1:Boolean) : void
      {
         this._isHazard = param1;
      }
      
      public function get InFire() : Boolean
      {
         return this._inFire;
      }
      
      public function set InFire(param1:Boolean) : void
      {
         this._inFire = param1;
      }
      
      public function get ActivatorID() : String
      {
         return this._activatorID;
      }
      
      public function set ActivatorID(param1:String) : void
      {
         this._activatorID = param1;
      }
      
      public function get Binds() : Array
      {
         return this._binds;
      }
      
      public function set Binds(param1:Array) : void
      {
         this._binds = param1;
      }
      
      public function get ParentBody() : b2Body
      {
         return this._parentBody;
      }
      
      public function set ParentBody(param1:b2Body) : void
      {
         this._parentBody = param1;
      }
      
      public function get IsEndNode() : Boolean
      {
         return this._isEndNode;
      }
      
      public function set IsEndNode(param1:Boolean) : void
      {
         this._isEndNode = param1;
      }
      
      public function set ListIndex(param1:int) : void
      {
         this._listIndex = param1;
      }
      
      public function get ListIndex() : int
      {
         return this._listIndex;
      }
   }
}

