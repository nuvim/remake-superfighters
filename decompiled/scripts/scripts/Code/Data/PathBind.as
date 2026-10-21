package Code.Data
{
   public class PathBind
   {
      
      public static const STATIC:int = 0;
      
      public static const DYNAMIC:int = 1;
      
      public static const ROAD:int = 3;
      
      public static const JUMP:int = 4;
      
      public static const SPRINTJUMP:int = 5;
      
      public static const CLOUDDOWN:int = 6;
      
      public static const DIVE:int = 7;
      
      public static const LADDER:int = 8;
      
      public static const PORTAL:int = 9;
      
      public static const ROLL:int = 10;
      
      private var _bindType:int;
      
      private var _movementType:int;
      
      private var _id:String;
      
      private var _sourceNode:PathNode;
      
      private var _targetNode:PathNode;
      
      private var _distance:Number;
      
      private var _blocked:Boolean;
      
      public function PathBind(param1:String, param2:PathNode, param3:PathNode, param4:int, param5:int)
      {
         super();
         this._id = param1;
         this._sourceNode = param2;
         this._targetNode = param3;
         this._bindType = param4;
         this._movementType = param5;
         this._blocked = false;
         this.CalcDistance();
      }
      
      public function TargetNodeCloseEnough() : Boolean
      {
         if(this._bindType == STATIC)
         {
            return true;
         }
         var _loc1_:Boolean = true;
         var _loc2_:Number = Math.abs(this.SourceNode.PosX - (this.TargetNode.PosX + this.TargetNode.SpeedX * 2));
         var _loc3_:Number = Math.abs(this.SourceNode.PosY - this.TargetNode.PosY);
         if(this.TargetNode.SpeedY < 0 && this.TargetNode.PosY + 4 < this.SourceNode.PosY)
         {
            _loc1_ = false;
         }
         if(this.SourceNode.SpeedX > 0.1 && this.TargetNode.PosX < this.SourceNode.PosX || this.SourceNode.SpeedX < -0.1 && this.TargetNode.PosX > this.SourceNode.PosX)
         {
            _loc1_ = false;
         }
         switch(this._movementType)
         {
            case ROAD:
               if(!_loc1_)
               {
                  return false;
               }
               if(_loc2_ < 20 && _loc3_ < 20)
               {
                  return true;
               }
               break;
            case JUMP:
               if(!_loc1_)
               {
                  return false;
               }
               if(_loc2_ < 20 && _loc3_ <= 22)
               {
                  return true;
               }
               break;
            case SPRINTJUMP:
               if(!_loc1_)
               {
                  return false;
               }
               if(_loc2_ < 60 && _loc3_ <= 22)
               {
                  return true;
               }
               break;
            case CLOUDDOWN:
               if(_loc2_ < 20 && _loc3_ < 30)
               {
                  return true;
               }
               break;
            case DIVE:
               if(_loc2_ < 100 && _loc3_ < 100)
               {
                  return true;
               }
               break;
            case LADDER:
               if(_loc2_ < 20 && _loc3_ < 20)
               {
                  return true;
               }
               break;
            case PORTAL:
               if(_loc2_ < 20 && _loc3_ < 20)
               {
                  return true;
               }
               break;
            case ROLL:
               if(_loc2_ < 20 && _loc3_ < 20)
               {
                  return true;
               }
         }
         return false;
      }
      
      public function get Blocked() : Boolean
      {
         return this._blocked;
      }
      
      public function set Blocked(param1:Boolean) : void
      {
         this._blocked = param1;
      }
      
      public function get ID() : String
      {
         return this._id;
      }
      
      public function get MovementType() : int
      {
         return this._movementType;
      }
      
      public function set MovementType(param1:int) : void
      {
         this._movementType = param1;
      }
      
      public function get BindType() : int
      {
         return this._bindType;
      }
      
      public function set BindType(param1:int) : void
      {
         this._bindType = param1;
         if(this._bindType == STATIC)
         {
            this.CalcDistance();
         }
      }
      
      public function get SourceNode() : PathNode
      {
         return this._sourceNode;
      }
      
      public function set SourceNode(param1:PathNode) : void
      {
         this._sourceNode = param1;
         this.CalcDistance();
      }
      
      public function get TargetNode() : PathNode
      {
         return this._targetNode;
      }
      
      public function set TargetNode(param1:PathNode) : void
      {
         this._targetNode = param1;
         this.CalcDistance();
      }
      
      public function get Distance() : Number
      {
         if(this._bindType == DYNAMIC)
         {
            this.CalcDistance();
         }
         return this._distance;
      }
      
      private function CalcDistance() : void
      {
         if(this._movementType == PORTAL)
         {
            this._distance = 0;
            return;
         }
         this._distance = Math.sqrt(Math.pow(this.SourceNode.PosY - this.TargetNode.PosY,2) + Math.pow(this.SourceNode.PosX - this.TargetNode.PosX,2));
         if(this._movementType == LADDER)
         {
            this._distance *= 1.5;
         }
      }
   }
}

