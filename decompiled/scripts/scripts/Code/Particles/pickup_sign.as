package Code.Particles
{
   [Embed(source="/_assets/assets.swf", symbol="symbol1193")]
   public class pickup_sign extends particle_base
   {
      
      internal var time:int = 0;
      
      internal var a:Number = 1;
      
      public function pickup_sign(param1:particle_data)
      {
         super();
         var _loc2_:String = param1.Effect.substr(7,param1.Effect.length - 7);
         this.gotoAndStop(_loc2_);
         SetUpdateEvent(this.UpdateParticle);
      }
      
      private function UpdateParticle() : *
      {
         this.y -= 0.5;
         this.a -= 0.04;
         this.alpha = this.a;
         ++this.time;
         if(this.time >= 24)
         {
            EndParticle();
         }
      }
   }
}

