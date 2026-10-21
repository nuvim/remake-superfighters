package Code.Data.Menu
{
   import Code.Handler.Sounds;
   import flash.display.MovieClip;
   
   public class leaderboards_selection extends submenu_base
   {
      
      public function leaderboards_selection(param1:MovieClip, param2:Sounds)
      {
         super();
         _this = param1;
         _total_markers = 2;
         _Handler_Sounds = param2;
         _canReturn = true;
         UpdateMarker();
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
               _players = 1;
               return "leaderboards_survival1p";
            case 1:
               _players = 2;
               return "leaderboards_survival2p";
            default:
               return "";
         }
      }
   }
}

