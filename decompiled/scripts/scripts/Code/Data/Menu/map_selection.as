package Code.Data.Menu
{
   import Code.Handler.*;
   import flash.display.MovieClip;
   
   public class map_selection extends submenu_base
   {
      
      public var Level:int = Maps.RANDOM_MAP;
      
      public var Mode:int = 1;
      
      private var _mode:int;
      
      public function map_selection(param1:MovieClip, param2:Sounds, param3:int)
      {
         super();
         this._mode = param3;
         _this = param1;
         _canReturn = true;
         _Handler_Sounds = param2;
         _canReturn = true;
         if(this._mode == 0)
         {
            _this.gotoAndStop(1);
         }
         else if(this._mode == 2)
         {
            _this.gotoAndStop(2);
            this.Level = 10;
         }
         this.UpdateMarker();
      }
      
      override public function UpdateMarker() : void
      {
         _this.highlight_0.visible = false;
         _this.highlight_1.visible = false;
         _this.marker_0.visible = false;
         _this.marker_1.visible = false;
         _this.marker_2.visible = false;
         _this.marker_3.visible = false;
         _this.marker_4.visible = false;
         _this.marker_5.visible = false;
         if(_marker_pos == 0)
         {
            _this.marker_0.visible = true;
         }
         else if(_marker_pos == 1)
         {
            _this.highlight_0.visible = true;
            _this.marker_1.visible = true;
            _this.marker_2.visible = true;
         }
         else if(_marker_pos == 2)
         {
            _this.highlight_1.visible = true;
            _this.marker_3.visible = true;
            _this.marker_4.visible = true;
         }
         else if(_marker_pos == 3)
         {
            _this.marker_5.visible = true;
         }
         _this.map.gotoAndStop(this.Level);
         _this.map_pic.gotoAndStop(this.Level);
         if(this._mode == 0)
         {
            _this.game_mode.gotoAndStop(this.Mode);
         }
         else if(this._mode == 2)
         {
            _this.game_mode.gotoAndStop(10);
         }
      }
      
      override public function KeyPressed(param1:int) : void
      {
         switch(param1)
         {
            case MenuKey.KEY_UP:
               --_marker_pos;
               if(this._mode == 2 && _marker_pos == 2)
               {
                  --_marker_pos;
               }
               if(_marker_pos < 0)
               {
                  _marker_pos = 3;
               }
               break;
            case MenuKey.KEY_DOWN:
               ++_marker_pos;
               if(this._mode == 2 && _marker_pos == 2)
               {
                  ++_marker_pos;
               }
               if(_marker_pos > 3)
               {
                  _marker_pos = 0;
               }
               break;
            case MenuKey.KEY_LEFT:
               if(_marker_pos == 1)
               {
                  this.ChangeLevel(-1);
               }
               if(_marker_pos == 2)
               {
                  this.ChangeMode(-1);
               }
               break;
            case MenuKey.KEY_RIGHT:
               if(_marker_pos == 1)
               {
                  this.ChangeLevel(1);
               }
               if(_marker_pos == 2)
               {
                  this.ChangeMode(1);
               }
         }
         this.UpdateMarker();
      }
      
      override public function GetChoice() : String
      {
         if(_marker_pos == 0)
         {
            if(this._mode == 0)
            {
               return "fight";
            }
            if(this._mode == 2)
            {
               return "start_survival";
            }
         }
         else if(_marker_pos == 3)
         {
            return "reset";
         }
         return "";
      }
      
      private function ChangeMode(param1:int) : void
      {
         this.Mode += param1;
         if(this.Mode < 1)
         {
            this.Mode = 7;
         }
         if(this.Mode > 7)
         {
            this.Mode = 1;
         }
      }
      
      private function ChangeLevel(param1:int) : void
      {
         if(this._mode == 0)
         {
            this.Level += param1;
            if(this.Level > Maps.TOTAL_MAPS)
            {
               this.Level = 2;
            }
            if(this.Level < 2)
            {
               this.Level = Maps.TOTAL_MAPS;
            }
         }
         else if(this._mode == 2)
         {
            this.Level += param1;
            if(this.Level - 9 > Maps.TOTAL_SURVIVAL_MAPS)
            {
               this.Level = 10;
            }
            if(this.Level - 9 < 1)
            {
               this.Level = 9 + Maps.TOTAL_SURVIVAL_MAPS;
            }
         }
      }
   }
}

