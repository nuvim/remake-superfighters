package Code.Data.Menu
{
   import Code.Handler.Sounds;
   import flash.display.*;
   
   public class vs_player_setup extends submenu_base
   {
      
      private var _players:int;
      
      private var _plates:Array;
      
      private var _curr_plate:int = 0;
      
      private var _all_plates_set:Boolean = false;
      
      private var _mode:int;
      
      public function vs_player_setup(param1:MovieClip, param2:Sounds, param3:int, param4:int)
      {
         super();
         _this = param1;
         _Handler_Sounds = param2;
         this._players = param3;
         this._plates = new Array();
         this._mode = param4;
         var _loc5_:Boolean = true;
         if(this._mode == 1 || this._mode == 2)
         {
            _loc5_ = false;
         }
         var _loc6_:int = 1;
         while(_loc6_ <= this._players)
         {
            this._plates.push(new player_plate(MovieClip(_this.getChildByName("p" + _loc6_ + "_plate")),_Handler_Sounds,_loc6_,_loc5_));
            _loc6_++;
         }
         this._plates[0].CurrChoice = 0;
      }
      
      public function get PlayerPlateOne() : player_plate
      {
         return this._plates[0];
      }
      
      public function get PlayerPlateTwo() : player_plate
      {
         return this._plates[1];
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
      
      override public function Show() : void
      {
         _this.visible = true;
         this._plates[this._curr_plate].CurrChoice = 0;
      }
      
      private function CheckNextPlate() : void
      {
         _canReturn = false;
         var _loc1_:String = this._plates[this._curr_plate].GetChoice();
         if(_loc1_ == "done")
         {
            if(this._curr_plate < this._players - 1)
            {
               ++this._curr_plate;
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
         if(Boolean(this._all_plates_set) && this._mode == 0)
         {
            return "no_bots";
         }
         if(Boolean(this._all_plates_set) && this._mode == 1)
         {
            return "challenge_selection";
         }
         if(Boolean(this._all_plates_set) && this._mode == 2)
         {
            return "start_survival";
         }
         return "";
      }
   }
}

