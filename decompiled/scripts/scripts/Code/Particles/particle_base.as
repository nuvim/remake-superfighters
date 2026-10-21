package Code.Particles
{
   import flash.display.MovieClip;
   import flash.events.*;
   import flash.utils.*;
   
   public class particle_base extends MovieClip
   {
      
      private var _game_speed:Number = 1;
      
      private var _curr_frame:Number = 1;
      
      private var updateFunc:Function;
      
      private var _updateTimer:Number;
      
      public function particle_base()
      {
         super();
      }
      
      public function SetUpdateEvent(param1:Function) : void
      {
         this.updateFunc = param1;
         this.addEventListener(Event.ENTER_FRAME,this.Update,false,0,true);
      }
      
      private function Update(param1:Event) : void
      {
         this.updateFunc();
         this.removeEventListener(Event.ENTER_FRAME,this.Update);
         this._updateTimer = setInterval(this.updateFunc,1000 / 24);
      }
      
      public function ProgressAnimation() : void
      {
         this._curr_frame += this._game_speed;
         this.gotoAndStop(this.CurrentFrame);
      }
      
      public function ProgressAnimationFor(param1:MovieClip) : void
      {
         this._curr_frame += this._game_speed;
         param1.gotoAndStop(this.CurrentFrame);
      }
      
      public function get CurrentFrame() : int
      {
         return Math.round(this._curr_frame + 0.001);
      }
      
      public function set CurrentFrame(param1:int) : void
      {
         this._curr_frame = param1;
      }
      
      public function get game_speed() : Number
      {
         return this._game_speed;
      }
      
      public function set game_speed(param1:Number) : void
      {
         this._game_speed = param1;
      }
      
      public function EndParticle() : void
      {
         if(isNaN(this._updateTimer))
         {
            this.removeEventListener(Event.ENTER_FRAME,this.Update);
         }
         else
         {
            clearInterval(this._updateTimer);
         }
         if(this.parent != null)
         {
            this.parent.removeChild(this);
         }
      }
   }
}

