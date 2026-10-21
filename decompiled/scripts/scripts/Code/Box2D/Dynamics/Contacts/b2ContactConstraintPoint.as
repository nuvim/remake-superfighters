package Code.Box2D.Dynamics.Contacts
{
   import Code.Box2D.Common.Math.*;
   
   public class b2ContactConstraintPoint
   {
      
      public var localAnchor1:b2Vec2 = new b2Vec2();
      
      public var localAnchor2:b2Vec2 = new b2Vec2();
      
      public var r1:b2Vec2 = new b2Vec2();
      
      public var r2:b2Vec2 = new b2Vec2();
      
      public var normalImpulse:Number;
      
      public var tangentImpulse:Number;
      
      public var positionImpulse:Number;
      
      public var normalMass:Number;
      
      public var tangentMass:Number;
      
      public var equalizedMass:Number;
      
      public var separation:Number;
      
      public var velocityBias:Number;
      
      public function b2ContactConstraintPoint()
      {
         super();
      }
   }
}

