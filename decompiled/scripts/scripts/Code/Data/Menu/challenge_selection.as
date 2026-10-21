package Code.Data.Menu
{
   import Code.Data.*;
   import Code.Handler.InputKeyboard;
   import Code.Handler.Sounds;
   import flash.display.*;
   
   public class challenge_selection extends submenu_base
   {
      
      private var _Handler_Keyboard:InputKeyboard;
      
      private var _stageLevelsFinished:Array;
      
      private var _nextChallenge:int;
      
      private var _skipChoiseOnce:Boolean = false;
      
      public function challenge_selection(param1:MovieClip, param2:Sounds, param3:InputKeyboard, param4:int)
      {
         var _loc6_:int = 0;
         super();
         _this = param1;
         _this.win_message.visible = false;
         _canReturn = true;
         _Handler_Sounds = param2;
         this._Handler_Keyboard = param3;
         var _loc5_:int = 0;
         while(_loc5_ < 12)
         {
            _loc6_ = int(Challenges.CHALLENGE[param4 - 1][_loc5_][0]);
            MovieClip(_this.getChildByName("c_" + (_loc5_ + 1))).map_pic.gotoAndStop(_loc6_);
            _loc5_++;
         }
         this.LoadData();
         this.UpdateMarker();
      }
      
      public function get SelectedChallenge() : int
      {
         return _marker_pos;
      }
      
      override public function Show() : void
      {
         _this.visible = true;
         this.LoadData();
         this.UpdateMarker();
         if(this._nextChallenge == 0)
         {
         }
      }
      
      public function LoadData() : void
      {
         this._stageLevelsFinished = SaveState.Data.stageLevelsFinished;
         this._nextChallenge = 0;
         _marker_pos = 1;
         var _loc1_:int = 0;
         while(_loc1_ < 12)
         {
            if(this._stageLevelsFinished[_loc1_] == false)
            {
               this._nextChallenge = _loc1_ + 1;
               _marker_pos = _loc1_ + 1;
               return;
            }
            _loc1_++;
         }
         if(this._nextChallenge == 0)
         {
            if(SaveState.Data.stageModeWinMessageShown != true)
            {
               _this.win_message.visible = true;
               _canReturn = false;
               this._skipChoiseOnce = true;
               this.SaveWinData();
            }
         }
      }
      
      public function SaveWinData() : void
      {
         SaveState.Data.stageModeWinMessageShown = true;
         SaveState.Save();
      }
      
      public function SaveData() : void
      {
         SaveState.Data.stageLevelsFinished = this._stageLevelsFinished;
         SaveState.Save();
      }
      
      override public function UpdateMarker() : void
      {
         var _loc1_:int = 1;
         while(_loc1_ <= 12)
         {
            if(this._stageLevelsFinished[_loc1_ - 1])
            {
               MovieClip(_this.getChildByName("c_" + _loc1_)).gotoAndStop(3);
            }
            else
            {
               MovieClip(_this.getChildByName("c_" + _loc1_)).gotoAndStop(1);
            }
            MovieClip(MovieClip(_this.getChildByName("c_" + _loc1_)).getChildByName("selection")).visible = false;
            _loc1_++;
         }
         if(this._nextChallenge != 0)
         {
            MovieClip(_this.getChildByName("c_" + this._nextChallenge)).gotoAndStop(2);
         }
         if(this._nextChallenge == 0)
         {
            MovieClip(_this.getChildByName("funnyman_message")).gotoAndStop(2);
         }
         else
         {
            MovieClip(_this.getChildByName("funnyman_message")).gotoAndStop(1);
         }
         if(_marker_pos <= 12)
         {
            MovieClip(MovieClip(_this.getChildByName("c_" + _marker_pos)).getChildByName("selection")).visible = true;
         }
      }
      
      private function Change(param1:int) : void
      {
         _marker_pos += param1;
         if(_marker_pos < 1)
         {
            _marker_pos += 12;
         }
         if(_marker_pos > 12)
         {
            _marker_pos -= 12;
         }
      }
      
      override public function KeyPressed(param1:int) : void
      {
         if(!_this.win_message.visible)
         {
            switch(param1)
            {
               case MenuKey.KEY_UP:
                  this.Change(-4);
                  break;
               case MenuKey.KEY_DOWN:
                  this.Change(4);
                  break;
               case MenuKey.KEY_LEFT:
                  this.Change(-1);
                  break;
               case MenuKey.KEY_RIGHT:
                  this.Change(1);
                  break;
               case MenuKey.KEY_ENTER:
               case MenuKey.KEY_BACKSPACE:
            }
            this.UpdateMarker();
         }
         else if(param1 == MenuKey.KEY_ENTER || param1 == MenuKey.KEY_BACKSPACE)
         {
            _this.win_message.visible = false;
            _canReturn = true;
         }
      }
      
      override public function GetChoice() : String
      {
         if(this._skipChoiseOnce)
         {
            this._skipChoiseOnce = false;
         }
         else if(_marker_pos <= this._nextChallenge || this._nextChallenge == 0)
         {
            return "start_challenge";
         }
         return "";
      }
   }
}

