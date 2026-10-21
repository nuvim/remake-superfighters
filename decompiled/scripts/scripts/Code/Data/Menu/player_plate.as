package Code.Data.Menu
{
   import Code.Data.Players.*;
   import Code.Handler.Sounds;
   import flash.display.MovieClip;
   import flash.geom.ColorTransform;
   
   public class player_plate extends submenu_base
   {
      
      private var _allChoicesDone:Boolean = false;
      
      private var _canSelectTeam:Boolean;
      
      private var _curr_choice:int = -1;
      
      private var _character:int = 0;
      
      private var _team:int = 0;
      
      public function player_plate(param1:MovieClip, param2:Sounds, param3:int, param4:Boolean)
      {
         super();
         _this = param1;
         _Handler_Sounds = param2;
         this.UpdateMarker();
         _this.player_type.gotoAndStop(param3);
         this._canSelectTeam = param4;
         if(this._canSelectTeam)
         {
            _this.gotoAndStop(1);
         }
         else
         {
            _this.gotoAndStop(2);
            this._team = 1;
         }
         this.ShowCharacter();
         this.ShowTeam();
      }
      
      public function get Character() : int
      {
         return this._character;
      }
      
      public function get Team() : int
      {
         return this._team;
      }
      
      public function set CurrChoice(param1:int) : void
      {
         this._curr_choice = param1;
         this.UpdateMarker();
         this.ShowCharacter();
         this.ShowTeam();
      }
      
      public function get CurrChoice() : int
      {
         return this._curr_choice;
      }
      
      override public function UpdateMarker() : void
      {
         this.HideMarker();
         if(this._curr_choice == 0)
         {
            _this.marker_0.visible = true;
            _this.marker_1.visible = true;
            _this.highlight_0.visible = true;
         }
         else if(this._curr_choice == 1)
         {
            _this.marker_2.visible = true;
            _this.marker_3.visible = true;
            _this.highlight_1.visible = true;
            this.UncolorTeam();
         }
      }
      
      private function ColorTeam() : void
      {
         if(this._team == 0)
         {
            this.UncolorTeam();
            return;
         }
         var _loc1_:ColorTransform = _this.team.transform.colorTransform;
         _loc1_.redOffset = PlayerTeamColor.TEAM[this._team - 1][0] - 255;
         _loc1_.greenOffset = PlayerTeamColor.TEAM[this._team - 1][1] - 255;
         _loc1_.blueOffset = PlayerTeamColor.TEAM[this._team - 1][2] - 255;
         _this.team.transform.colorTransform = _loc1_;
      }
      
      private function UncolorTeam() : void
      {
         var _loc1_:ColorTransform = _this.team.transform.colorTransform;
         _loc1_.redOffset = PlayerTeamColor.SOLO[0] - 255;
         _loc1_.greenOffset = PlayerTeamColor.SOLO[1] - 255;
         _loc1_.blueOffset = PlayerTeamColor.SOLO[2] - 255;
         _this.team.transform.colorTransform = _loc1_;
      }
      
      private function HideMarker() : void
      {
         _this.highlight_0.visible = false;
         _this.highlight_1.visible = false;
         _this.marker_0.visible = false;
         _this.marker_1.visible = false;
         _this.marker_2.visible = false;
         _this.marker_3.visible = false;
         this.ColorTeam();
      }
      
      private function ChangeCharacter(param1:int) : void
      {
         this._character += param1;
         if(this._character < 0)
         {
            this._character = PlayerCharacter.TOTAL_CHARACTERS;
         }
         if(this._character > PlayerCharacter.TOTAL_CHARACTERS)
         {
            this._character = 0;
         }
         if(!PlayerCharacter.CharacterAvailable(this._character))
         {
            this.ChangeCharacter(param1);
         }
         this.ShowCharacter();
      }
      
      private function ShowCharacter() : void
      {
         if(this._character == 0)
         {
            _this.character_name.gotoAndStop("RANDOM");
            _this.character_pic.gotoAndStop("RANDOM");
         }
         else
         {
            _this.character_name.gotoAndStop(this._character);
            _this.character_pic.gotoAndStop(this._character);
         }
      }
      
      private function ChangeTeam(param1:int) : void
      {
         this._team += param1;
         if(this._team < 0)
         {
            this._team = 4;
         }
         if(this._team > 4)
         {
            this._team = 0;
         }
         this.ShowTeam();
      }
      
      private function ShowTeam() : void
      {
         if(this._team == 0)
         {
            _this.team.gotoAndStop("SOLO");
         }
         else
         {
            _this.team.gotoAndStop(this._team);
         }
      }
      
      override public function KeyPressed(param1:int) : void
      {
         switch(param1)
         {
            case MenuKey.KEY_LEFT:
               if(this._curr_choice == 0)
               {
                  this.ChangeCharacter(-1);
               }
               else if(this._curr_choice == 1)
               {
                  this.ChangeTeam(-1);
               }
               break;
            case MenuKey.KEY_RIGHT:
               if(this._curr_choice == 0)
               {
                  this.ChangeCharacter(1);
               }
               else if(this._curr_choice == 1)
               {
                  this.ChangeTeam(1);
               }
               break;
            case MenuKey.KEY_DOWN:
               if(!this._canSelectTeam)
               {
                  return;
               }
               if(this._curr_choice < 1)
               {
                  ++this._curr_choice;
               }
               else
               {
                  --this._curr_choice;
               }
               this.UpdateMarker();
               break;
            case MenuKey.KEY_ENTER:
               this.HideMarker();
               _canReturn = false;
               this._allChoicesDone = true;
               break;
            case MenuKey.KEY_UP:
               if(!this._canSelectTeam)
               {
                  return;
               }
               if(this._curr_choice > 0)
               {
                  --this._curr_choice;
               }
               else
               {
                  ++this._curr_choice;
               }
               this.UpdateMarker();
               break;
            case MenuKey.KEY_BACKSPACE:
               this.HideMarker();
               _canReturn = true;
               this._allChoicesDone = false;
         }
      }
      
      override public function GetChoice() : String
      {
         if(this._allChoicesDone)
         {
            return "done";
         }
         return "";
      }
   }
}

