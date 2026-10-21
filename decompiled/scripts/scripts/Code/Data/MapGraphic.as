package Code.Data
{
   import flash.display.*;
   
   public class MapGraphic
   {
      
      private var clips:Array;
      
      public function MapGraphic()
      {
         super();
         this.clips = new Array();
      }
      
      public function AddMC(param1:MovieClip) : void
      {
         this.clips.push([param1,1]);
      }
      
      public function Update(param1:Number) : void
      {
         var _loc2_:int = 0;
         while(_loc2_ < this.clips.length)
         {
            this.clips[_loc2_][1] += param1;
            if(this.clips[_loc2_][1] >= MovieClip(this.clips[_loc2_][0]).totalFrames + 1)
            {
               this.clips[_loc2_][1] -= MovieClip(this.clips[_loc2_][0]).totalFrames;
            }
            MovieClip(this.clips[_loc2_][0]).gotoAndStop(Math.floor(this.clips[_loc2_][1]));
            _loc2_++;
         }
      }
   }
}

