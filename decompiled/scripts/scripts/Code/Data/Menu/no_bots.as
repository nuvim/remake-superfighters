package Code.Data.Menu
{
   import Code.Handler.Sounds;
   import flash.display.MovieClip;
   
   public class no_bots extends submenu_base
   {
      
      private var _max_bots:int = 0;
      
      private var _min_bots:int = 0;
      
      private var _no_bots:int = 0;
      
      public function no_bots(param1:MovieClip, param2:Sounds, param3:int, param4:int)
      {
         super();
         this._max_bots = param4;
         this._min_bots = param3;
         _this = param1;
         var _loc5_:int = 0;
         if(this._min_bots == 1)
         {
            _loc5_ += 2;
            this._no_bots = 1;
         }
         if(this._max_bots == 7)
         {
            _loc5_ += 1;
         }
         else
         {
            _loc5_ += 2;
         }
         _this.gotoAndStop(_loc5_);
         _Handler_Sounds = param2;
         _canReturn = true;
         _total_markers = 8;
         _marker_pos = this._no_bots;
         UpdateMarker();
      }
      
      public function get NoBots() : int
      {
         return this._no_bots;
      }
      
      private function ChangeBots(param1:int) : void
      {
         this._no_bots += param1;
         if(this._no_bots < this._min_bots)
         {
            this._no_bots = this._max_bots;
         }
         if(this._no_bots > this._max_bots)
         {
            this._no_bots = this._min_bots;
         }
         _marker_pos = this._no_bots;
         UpdateMarker();
      }
      
      override public function KeyPressed(param1:int) : void
      {
         switch(param1)
         {
            case MenuKey.KEY_LEFT:
               this.ChangeBots(-1);
               break;
            case MenuKey.KEY_RIGHT:
               this.ChangeBots(1);
               break;
            case MenuKey.KEY_ENTER:
               Hide();
         }
      }
      
      override public function GetChoice() : String
      {
         return "prepare_bots";
      }
   }
}

