package Code.Box2D.Dynamics
{
   import Code.Box2D.Collision.*;
   import Code.Box2D.Collision.Shapes.*;
   import Code.Box2D.Common.*;
   import Code.Box2D.Common.Math.*;
   import Code.Box2D.Dynamics.Contacts.*;
   import Code.Data.ContactData;
   import Code.Particles.*;
   
   public class b2ContactListener
   {
      
      private var _ContactData:ContactData;
      
      private var vec:b2Vec2;
      
      public function b2ContactListener()
      {
         super();
      }
      
      public function SetHandler(param1:ContactData) : *
      {
         this._ContactData = param1;
         this.vec = new b2Vec2();
      }
      
      public function Add(param1:b2ContactPoint) : void
      {
         var _loc2_:b2Vec2 = param1.shape1.GetBody().GetLinearVelocityFromWorldPoint(param1.position);
         var _loc3_:b2Vec2 = param1.shape2.GetBody().GetLinearVelocityFromWorldPoint(param1.position);
         this.vec = _loc2_.Copy();
         this.vec.Subtract(_loc3_);
         var _loc4_:Number = Number(this.vec.Length());
         if(_loc4_ >= 2)
         {
            this.CheckBodyImpact(param1.shape1.GetBody(),param1.shape2.GetBody(),param1,_loc2_,_loc4_);
         }
         if(!param1.shape1.GetBody().IsStatic() && !param1.shape2.GetBody().IsStatic())
         {
            if(param1.shape1.GetBody().GetUserData().objectData.IsGlass)
            {
               param1.shape1.GetBody().GetUserData().objectData.ForceDestruction();
            }
            if(param1.shape2.GetBody().GetUserData().objectData.IsGlass)
            {
               param1.shape2.GetBody().GetUserData().objectData.ForceDestruction();
            }
         }
      }
      
      public function Persist(param1:b2ContactPoint) : void
      {
         this.CheckConveyorBelt(param1);
      }
      
      public function Remove(param1:b2ContactPoint) : void
      {
      }
      
      public function Result(param1:b2ContactResult) : void
      {
      }
      
      private function CheckConveyorBelt(param1:b2ContactPoint) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         if(param1.shape1.GetBody().GetUserData().isConveyorBelt == true)
         {
            if(!param1.shape2.GetBody().IsStatic())
            {
               if(Math.abs(param1.shape2.GetBody().GetLinearVelocity().x) < Math.abs(param1.shape1.GetBody().GetUserData().conveyorBeltSpeedX))
               {
                  _loc2_ = this._ContactData.game_speed * param1.shape1.GetBody().GetUserData().conveyorBeltSpeedX * param1.shape2.GetBody().GetMass();
                  _loc3_ = this._ContactData.game_speed * param1.shape1.GetBody().GetUserData().conveyorBeltSpeedY * param1.shape2.GetBody().GetMass();
                  param1.shape2.GetBody().ApplyImpulse(new b2Vec2(_loc2_,_loc3_),new b2Vec2(param1.position.x,param1.position.y));
               }
            }
         }
      }
      
      private function CheckBodyImpact(param1:b2Body, param2:b2Body, param3:b2ContactPoint, param4:b2Vec2, param5:Number) : void
      {
         if(!param1.IsStatic())
         {
            param1.WakeUp();
            this._ContactData.Handler_Sounds.PlaySoundAt_Box2DScale(param1.GetUserData().material.BounceImpactSound,param1.GetPosition().x,param1.GetPosition().y);
            param1.GetUserData().objectData.Damage_Impact(param5);
         }
         if(!param2.IsStatic())
         {
            param2.WakeUp();
            this._ContactData.Handler_Sounds.PlaySoundAt_Box2DScale(param2.GetUserData().material.BounceImpactSound,param2.GetPosition().x,param2.GetPosition().y);
            param2.GetUserData().objectData.Damage_Impact(param5);
         }
         if(!param2.IsStatic() && !param1.IsStatic())
         {
            if(param1.GetUserData().material.ImpactEffectConditionFullfilled(param2.GetUserData().material.Type))
            {
               this._ContactData.Handler_Effects.AddParticle_Box2DScale(new particle_data(param1.GetUserData().material.ImpactEffect,param3.position.x,param3.position.y,param4));
            }
         }
         else
         {
            if(param1.GetUserData().material.ImpactEffectConditionFullfilled(param2.GetUserData().material.Type))
            {
               this._ContactData.Handler_Effects.AddParticle_Box2DScale(new particle_data(param1.GetUserData().material.ImpactEffect,param3.position.x,param3.position.y,param4));
            }
            if(param2.GetUserData().material.ImpactEffectConditionFullfilled(param1.GetUserData().material.Type))
            {
               this._ContactData.Handler_Effects.AddParticle_Box2DScale(new particle_data(param2.GetUserData().material.ImpactEffect,param3.position.x,param3.position.y,param4));
            }
         }
      }
   }
}

