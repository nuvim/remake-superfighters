package Code.Data.Menu
{
   import Code.Data.*;
   import Code.Handler.Sounds;
   import flash.display.MovieClip;
   
   public class main_choise extends submenu_base
   {
      
      private var _players:int = 1;
      
      public function main_choise(param1:MovieClip, param2:Sounds)
      {
         super();
         _this = param1;
         _total_markers = 6;
         _Handler_Sounds = param2;
         _canReturn = true;
         this.LoadData();
         UpdateMarker();
      }
      
      public function get Players() : int
      {
         return this._players;
      }
      
      private function LoadData() : void
      {
         if(SaveState.Data.startedBefore != true)
         {
            _marker_pos = 2;
            _this.tutorial_promt.visible = true;
            SaveState.Data.startedBefore = true;
            SaveState.Save();
         }
         else
         {
            _this.tutorial_promt.visible = false;
         }
      }
      
      override public function KeyPressed(param1:int) : void
      {
         switch(param1)
         {
            case MenuKey.KEY_UP:
               --_marker_pos;
               if(_marker_pos < 0)
               {
                  _marker_pos = _total_markers - 1;
               }
               break;
            case MenuKey.KEY_DOWN:
               ++_marker_pos;
               if(_marker_pos >= _total_markers)
               {
                  _marker_pos = 0;
               }
         }
         UpdateMarker();
      }
      
      override public function GetChoice() : String
      {
         switch(_marker_pos)
         {
            case 0:
               this._players = 1;
               return "mode_selection";
            case 1:
               this._players = 2;
               return "mode_selection";
            case 2:
               this._players = 1;
               return "tutorial";
            case 3:
               return "achievements";
            case 4:
               return "leaderboards_selection";
            case 5:
               return "set_up_main";
            default:
               return "";
         }
      }
   }
}

