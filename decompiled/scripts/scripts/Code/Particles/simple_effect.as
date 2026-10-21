package Code.Particles
{
   import flash.display.MovieClip;
   
   public class simple_effect extends particle_base
   {
      
      private var _mc:MovieClip;
      
      public function simple_effect(param1:MovieClip)
      {
         super();
         this._mc = param1;
         this.addChild(this._mc);
         SetUpdateEvent(this.UpdateParticle);
      }
      
      private function UpdateParticle() : *
      {
         ProgressAnimationFor(this._mc);
         if(CurrentFrame >= this._mc.totalFrames)
         {
            EndParticle();
         }
      }
   }
}

