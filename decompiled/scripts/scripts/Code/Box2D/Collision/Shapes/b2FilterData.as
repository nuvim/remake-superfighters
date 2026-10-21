package Code.Box2D.Collision.Shapes
{
   import Code.Box2D.Common.Math.*;
   
   public class b2FilterData
   {
      
      public var categoryBits:uint = 1;
      
      public var maskBits:uint = 65535;
      
      public var groupIndex:int = 0;
      
      public var isCloud:Boolean = false;
      
      public var isElevator:Boolean = false;
      
      public var isGhost:Boolean = false;
      
      public function b2FilterData()
      {
         super();
      }
      
      public function Copy() : b2FilterData
      {
         var _loc1_:b2FilterData = new b2FilterData();
         _loc1_.categoryBits = this.categoryBits;
         _loc1_.maskBits = this.maskBits;
         _loc1_.groupIndex = this.groupIndex;
         _loc1_.isCloud = this.isCloud;
         _loc1_.isElevator = this.isElevator;
         _loc1_.isGhost = this.isGhost;
         return _loc1_;
      }
   }
}

