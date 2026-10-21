package Code.Data.Menu
{
   import Code.Handler.Sounds;
   import flash.display.*;
   
   public class bot_setup extends submenu_base
   {
      
      private var _bots:int;
      
      private var _plates:Array;
      
      private var _curr_plate:int = 0;
      
      private var _all_plates_set:Boolean = false;
      
      private var _must_not_team:int;
      
      private var _max_plates:int;
      
      public function bot_setup(param1:MovieClip, param2:Sounds, param3:int, param4:int)
      {
         var i:int;
         var botPlate:MovieClip = null;
         var j:int = 0;
         var mc:MovieClip = param1;
         var snd:Sounds = param2;
         var nrOfBots:int = param3;
         var musntTeam:int = param4;
         super();
         _this = mc;
         _Handler_Sounds = snd;
         this._bots = nrOfBots;
         this._must_not_team = musntTeam;
         _canReturn = true;
         this._plates = new Array();
         try
         {
            _this.cp_7.visible = true;
            this._max_plates = 7;
         }
         catch(e:Error)
         {
            _max_plates = 6;
         }
         i = 1;
         while(i <= this._max_plates)
         {
            botPlate = MovieClip(_this.getChildByName("cp_" + i));
            botPlate.visible = true;
            this._plates.push(new bot_plate(botPlate,_Handler_Sounds));
            i++;
         }
         if(this._bots < this._max_plates)
         {
            j = this._bots + 1;
            while(j <= this._max_plates)
            {
               MovieClip(_this.getChildByName("cp_" + j)).visible = false;
               j++;
            }
         }
         this._plates[0].CurrChoice = 0;
         if(this._bots == 1)
         {
            this._plates[0].MusntTeam = this._must_not_team;
         }
      }
      
      public function get BotPlates() : Array
      {
         return this._plates;
      }
      
      override public function Show() : void
      {
         _this.visible = true;
         this._plates[this._curr_plate].CurrChoice = 0;
      }
      
      override public function KeyPressed(param1:int) : void
      {
         this._plates[this._curr_plate].KeyPressed(param1);
         switch(param1)
         {
            case MenuKey.KEY_ENTER:
               this.CheckNextPlate();
               break;
            case MenuKey.KEY_BACKSPACE:
               this.CheckPrevPlate();
         }
      }
      
      private function GetMustNotTeam() : int
      {
         var _loc1_:int = 0;
         if(this._must_not_team != 0)
         {
            _loc1_ = 0;
            while(_loc1_ < this._bots)
            {
               if(_loc1_ != this._curr_plate)
               {
                  if(this._plates[_loc1_].Team != this._must_not_team)
                  {
                     return 0;
                  }
               }
               _loc1_++;
            }
            return this._must_not_team;
         }
         return 0;
      }
      
      private function CheckNextPlate() : void
      {
         _canReturn = false;
         var _loc1_:String = this._plates[this._curr_plate].GetChoice();
         if(_loc1_ == "done")
         {
            if(this._curr_plate < this._bots - 1)
            {
               ++this._curr_plate;
               this._plates[this._curr_plate].MusntTeam = this.GetMustNotTeam();
               this._plates[this._curr_plate].SetStartItems(this._plates[this._curr_plate - 1].Team,this._plates[this._curr_plate - 1].Difficulty);
               this._plates[this._curr_plate].CurrChoice = 0;
               _Handler_Sounds.PlayMightySound("ACCEPT");
            }
            else
            {
               this._all_plates_set = true;
            }
         }
      }
      
      private function CheckPrevPlate() : void
      {
         this._all_plates_set = false;
         if(this._plates[this._curr_plate].CanReturn)
         {
            if(this._curr_plate > 0)
            {
               --this._curr_plate;
               this._plates[this._curr_plate].MusntTeam = this.GetMustNotTeam();
               this._plates[this._curr_plate].CurrChoice = 0;
               _Handler_Sounds.PlayMightySound("CANCEL");
            }
            else
            {
               _canReturn = true;
            }
         }
      }
      
      override public function GetChoice() : String
      {
         if(this._all_plates_set)
         {
            return "map_selection";
         }
         return "";
      }
   }
}

