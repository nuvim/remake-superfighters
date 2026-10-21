package Code.Data
{
   import Code.Box2D.Common.Math.*;
   import Code.Box2D.Dynamics.*;
   import Code.Handler.Effects;
   import Code.Particles.*;
   
   public class SmokePackageDataDynamic
   {
      
      private var _Handler_Effects:Effects;
      
      private var _smoke_pack_done:Boolean = false;
      
      private var _smoke_timer:Number;
      
      private var _body:b2Body;
      
      private var _smokePoint:b2Vec2;
      
      private var _lastSmokePoint:b2Vec2;
      
      private var _smoke_tick:Number;
      
      private var _init_smoke_grade:int = 0;
      
      private var _speed:Number;
      
      private var _still_timer:Number = 0;
      
      private var xDiff:Number;
      
      private var yDiff:Number;
      
      public function SmokePackageDataDynamic(param1:Effects)
      {
         super();
         this._Handler_Effects = param1;
         this._smoke_timer = 72 + Math.random() * 5;
         this._smokePoint = new b2Vec2();
         this._lastSmokePoint = new b2Vec2();
      }
      
      public function Update(param1:Number) : void
      {
         if(Boolean(this._init_smoke_grade != this._body.GetUserData().objectData.ObjectSmokeGrade) || Boolean(this._body.GetUserData().objectData.ObjectOnFire) || this._body.GetUserData().destroyed == true)
         {
            this._smoke_pack_done = true;
            return;
         }
         this.UpdatePosition();
         this._smoke_tick -= param1;
         if(this._smoke_tick <= 0)
         {
            this.AddEffect();
            this._smoke_tick = 3;
         }
         else
         {
            this.xDiff = this._lastSmokePoint.x - this._smokePoint.x;
            this.yDiff = this._lastSmokePoint.y - this._smokePoint.y;
            this._speed = Math.sqrt(this.xDiff * this.xDiff + this.yDiff * this.yDiff);
            if(this._speed > 5)
            {
               this.AddEffect();
               this._smoke_tick = 3;
            }
            else if(this._speed < 0.5)
            {
               this._still_timer += param1;
               if(this._still_timer > 3)
               {
                  this._smoke_timer = 0;
               }
            }
            else
            {
               this._still_timer = 0;
            }
         }
         this._smoke_timer -= param1;
         if(this._smoke_timer <= 0)
         {
            this._body.GetUserData().objectData.ObjectSmokeGrade = 0;
            this._smoke_pack_done = true;
         }
      }
      
      public function SetSmokeElementAt(param1:b2Body) : void
      {
         this._body = param1;
         this._init_smoke_grade = param1.GetUserData().objectData.ObjectSmokeGrade;
         this.UpdatePosition();
         this._smoke_tick = Math.random() * 2;
      }
      
      private function UpdatePosition() : void
      {
         this._smokePoint.x = this._body.GetPosition().x * 30;
         this._smokePoint.y = this._body.GetPosition().y * 30;
      }
      
      private function AddEffect() : void
      {
         this._lastSmokePoint.x = this._smokePoint.x;
         this._lastSmokePoint.y = this._smokePoint.y;
         var _loc1_:Number = Math.random() * this._body.m_userData.objectData.ShapeMC.width - this._body.m_userData.objectData.ShapeMC.width / 2;
         var _loc2_:Number = Math.random() * this._body.m_userData.objectData.ShapeMC.height - this._body.m_userData.objectData.ShapeMC.height / 2;
         this._Handler_Effects.AddParticle(new particle_data("SMOKE_TRACE_EFFECT",this._smokePoint.x + _loc1_ * 0.7,this._smokePoint.y + _loc2_ * 0.7,this._body.GetLinearVelocity(),0,1,[this._init_smoke_grade]));
      }
      
      public function get SmokePackageCompleted() : Boolean
      {
         return this._smoke_pack_done;
      }
   }
}

