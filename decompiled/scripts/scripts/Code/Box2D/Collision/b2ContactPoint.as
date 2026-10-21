package Code.Box2D.Collision
{
   import Code.Box2D.Collision.Shapes.*;
   import Code.Box2D.Common.Math.*;
   
   public class b2ContactPoint
   {
      
      public var shape1:b2Shape;
      
      public var shape2:b2Shape;
      
      public var position:b2Vec2 = new b2Vec2();
      
      public var velocity:b2Vec2 = new b2Vec2();
      
      public var normal:b2Vec2 = new b2Vec2();
      
      public var separation:Number;
      
      public var friction:Number;
      
      public var restitution:Number;
      
      public var id:b2ContactID = new b2ContactID();
      
      public function b2ContactPoint()
      {
         super();
      }
   }
}

