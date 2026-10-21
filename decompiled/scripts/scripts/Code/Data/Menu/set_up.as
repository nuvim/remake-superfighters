package Code.Data.Menu
{
   import Code.Data.Players.*;
   import Code.Handler.InputKeyboard;
   import Code.Handler.Options;
   import Code.Handler.Sounds;
   import flash.display.*;
   import flash.events.*;
   import flash.text.TextField;
   import flash.utils.*;
   
   public class set_up extends submenu_base
   {
      
      private static var SIMPLE:int = 0;
      
      private static var ADVANCED:int = 1;
      
      private static var TOTAL_SELECTIONS:Array = [10,13];
      
      private var _Handler_Keyboard:InputKeyboard;
      
      private var _Handler_Options:Options;
      
      private var _curr_player:int = 0;
      
      private var _config:int = SIMPLE;
      
      private var _update_marker_timer:Number;
      
      private var _update_delay:Boolean;
      
      private var _wait_for_key:Boolean = false;
      
      private var _delay_key:Boolean = true;
      
      private var _key_edit_timer:Number;
      
      private var _lockKeys:Boolean = false;
      
      public function set_up(param1:MovieClip, param2:Sounds, param3:InputKeyboard, param4:Options)
      {
         super();
         _this = param1;
         _marker_pos = 0;
         _canReturn = true;
         _Handler_Sounds = param2;
         this._Handler_Keyboard = param3;
         this._Handler_Options = param4;
         this.UpdateMarker();
         this._Handler_Keyboard.KeyDownFunction = this.keyDownHandler;
      }
      
      override public function Show() : void
      {
         _this.gotoAndStop(this._config);
         _this.visible = true;
         this.UpdateMarker();
      }
      
      private function keyDownHandler(param1:KeyboardEvent) : void
      {
         var _loc2_:Array = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         if(!this._lockKeys && Boolean(this._wait_for_key) && !this._delay_key)
         {
            this._lockKeys = true;
            _loc2_ = this.GetCurrentKeyIndex();
            _loc3_ = int(param1.keyCode);
            if(_loc3_ == 27)
            {
               _loc3_ = 0;
            }
            _loc4_ = 0;
            while(_loc4_ < _loc2_.length)
            {
               this._Handler_Options.PlayerKeys[this._curr_player][_loc2_[_loc4_]] = _loc3_;
               _loc4_++;
            }
            this._key_edit_timer = setInterval(this.ReleaseWaiting,60);
            _Handler_Sounds.PlayMightySound("ACCEPT");
            this.UpdateMarker();
         }
      }
      
      private function SetDefaultKeys() : void
      {
         if(this._curr_player == 0)
         {
            this._Handler_Options.SetDefaultP1Keys();
         }
         else
         {
            this._Handler_Options.SetDefaultP2Keys();
         }
         _Handler_Sounds.PlayMightySound("ACCEPT");
         this.PrintKeys();
      }
      
      private function ReleaseWaiting() : void
      {
         this._wait_for_key = false;
         _canReturn = true;
         this._lockKeys = false;
         clearInterval(this._key_edit_timer);
      }
      
      private function EngageWaiting() : void
      {
         this._delay_key = true;
         this._wait_for_key = true;
         _canReturn = false;
         this.GetCurrentTextField().text = "PRESS";
         MovieClip(_this.getChildByName("highlight_" + (_marker_pos + 2))).visible = true;
         this._key_edit_timer = setInterval(function():*
         {
            clearInterval(_key_edit_timer);
            _delay_key = false;
         },100);
      }
      
      private function EditKeyBind() : void
      {
         if(!this._wait_for_key)
         {
            this.EngageWaiting();
         }
      }
      
      private function GetCurrentKeyIndex() : Array
      {
         if(this._config == SIMPLE)
         {
            switch(_marker_pos)
            {
               case 2:
                  return [Player.KEY_UP,Player.KEY_JUMP];
               case 3:
                  return [Player.KEY_DOWN,Player.KEY_KNEEL];
               case 4:
                  return [Player.KEY_LEFT];
               case 5:
                  return [Player.KEY_RIGHT];
               case 6:
                  return [Player.KEY_MELEE];
               case 7:
                  return [Player.KEY_FIRE];
               case 8:
                  return [Player.KEY_THROW];
               case 9:
                  return [Player.KEY_POWERUP];
            }
         }
         else
         {
            switch(_marker_pos)
            {
               case 2:
                  return [Player.KEY_UP];
               case 3:
                  return [Player.KEY_JUMP];
               case 4:
                  return [Player.KEY_DOWN];
               case 5:
                  return [Player.KEY_KNEEL];
               case 6:
                  return [Player.KEY_LEFT];
               case 7:
                  return [Player.KEY_RIGHT];
               case 8:
                  return [Player.KEY_MELEE];
               case 9:
                  return [Player.KEY_FIRE];
               case 10:
                  return [Player.KEY_THROW];
               case 11:
                  return [Player.KEY_POWERUP];
               case 12:
                  return [Player.KEY_SPRINT];
            }
         }
         return [0];
      }
      
      private function GetCurrentTextField() : TextField
      {
         if(this._config == SIMPLE)
         {
            switch(_marker_pos)
            {
               case 2:
                  return _this.key_up;
               case 3:
                  return _this.key_down;
               case 4:
                  return _this.key_left;
               case 5:
                  return _this.key_right;
               case 6:
                  return _this.key_melee;
               case 7:
                  return _this.key_fire;
               case 8:
                  return _this.key_throw;
               case 9:
                  return _this.key_powerup;
            }
         }
         else
         {
            switch(_marker_pos)
            {
               case 2:
                  return _this.key_up;
               case 3:
                  return _this.key_jump;
               case 4:
                  return _this.key_down;
               case 5:
                  return _this.key_kneel;
               case 6:
                  return _this.key_left;
               case 7:
                  return _this.key_right;
               case 8:
                  return _this.key_melee;
               case 9:
                  return _this.key_fire;
               case 10:
                  return _this.key_throw;
               case 11:
                  return _this.key_powerup;
               case 12:
                  return _this.key_sprint;
            }
         }
         return null;
      }
      
      public function PrintKeys() : void
      {
         if(this._config == SIMPLE)
         {
            this.PrintKeyFor(_this.key_up,Player.KEY_JUMP,Player.KEY_UP);
            this.PrintKeyFor(_this.key_down,Player.KEY_KNEEL,Player.KEY_DOWN);
            this.PrintKeyFor(_this.key_left,Player.KEY_LEFT,Player.KEY_LEFT);
            this.PrintKeyFor(_this.key_right,Player.KEY_RIGHT,Player.KEY_RIGHT);
            this.PrintKeyFor(_this.key_melee,Player.KEY_MELEE,Player.KEY_MELEE);
            this.PrintKeyFor(_this.key_fire,Player.KEY_FIRE,Player.KEY_FIRE);
            this.PrintKeyFor(_this.key_throw,Player.KEY_THROW,Player.KEY_THROW);
            this.PrintKeyFor(_this.key_powerup,Player.KEY_POWERUP,Player.KEY_POWERUP);
         }
         else
         {
            this.PrintKeyFor(_this.key_up,Player.KEY_UP,Player.KEY_UP);
            this.PrintKeyFor(_this.key_jump,Player.KEY_JUMP,Player.KEY_JUMP);
            this.PrintKeyFor(_this.key_down,Player.KEY_DOWN,Player.KEY_DOWN);
            this.PrintKeyFor(_this.key_kneel,Player.KEY_KNEEL,Player.KEY_KNEEL);
            this.PrintKeyFor(_this.key_left,Player.KEY_LEFT,Player.KEY_LEFT);
            this.PrintKeyFor(_this.key_right,Player.KEY_RIGHT,Player.KEY_RIGHT);
            this.PrintKeyFor(_this.key_melee,Player.KEY_MELEE,Player.KEY_MELEE);
            this.PrintKeyFor(_this.key_fire,Player.KEY_FIRE,Player.KEY_FIRE);
            this.PrintKeyFor(_this.key_throw,Player.KEY_THROW,Player.KEY_THROW);
            this.PrintKeyFor(_this.key_powerup,Player.KEY_POWERUP,Player.KEY_POWERUP);
            this.PrintKeyFor(_this.key_sprint,Player.KEY_SPRINT,Player.KEY_SPRINT);
         }
      }
      
      private function PrintKeyFor(param1:TextField, param2:int, param3:int) : void
      {
         if(this._Handler_Options.PlayerKeys[this._curr_player][param2] == this._Handler_Options.PlayerKeys[this._curr_player][param3])
         {
            if(this._Handler_Options.PlayerKeys[this._curr_player][param2] == 0)
            {
               param1.text = "[ NONE ]";
            }
            else
            {
               param1.text = this._Handler_Keyboard.GetCharFromCode(this._Handler_Options.PlayerKeys[this._curr_player][param2]);
            }
         }
         else
         {
            param1.text = this._Handler_Keyboard.GetCharFromCode(this._Handler_Options.PlayerKeys[this._curr_player][param2]) + " / " + this._Handler_Keyboard.GetCharFromCode(this._Handler_Options.PlayerKeys[this._curr_player][param3]);
         }
      }
      
      override public function UpdateMarker() : void
      {
         try
         {
            this.UpdateMarkerTick(null);
         }
         catch(e:Error)
         {
            _update_delay = false;
            _this.removeEventListener(Event.ENTER_FRAME,UpdateMarkerTick);
            _this.addEventListener(Event.ENTER_FRAME,UpdateMarkerTick,false,0,true);
         }
      }
      
      private function UpdateMarkerTick(param1:Event) : void
      {
         var _loc2_:int = 0;
         if(!this._update_delay)
         {
            this._update_delay = true;
            return;
         }
         _this.removeEventListener(Event.ENTER_FRAME,this.UpdateMarkerTick);
         _loc2_ = 0;
         while(_loc2_ < 16)
         {
            MovieClip(_this.getChildByName("marker_" + _loc2_)).visible = false;
            _loc2_++;
         }
         _this.highlight_0.visible = false;
         _this.highlight_1.visible = false;
         _loc2_ = 4;
         while(_loc2_ < 16)
         {
            MovieClip(_this.getChildByName("highlight_" + _loc2_)).visible = false;
            _loc2_++;
         }
         switch(_marker_pos)
         {
            case 0:
               _this.highlight_0.visible = true;
               _this.marker_0.visible = true;
               _this.marker_1.visible = true;
               break;
            case 1:
               _this.highlight_1.visible = true;
               _this.marker_2.visible = true;
               _this.marker_3.visible = true;
               break;
            default:
               MovieClip(_this.getChildByName("marker_" + (_marker_pos + 2))).visible = true;
         }
         this.PrintKeys();
      }
      
      private function TogglePlayer() : void
      {
         if(this._curr_player == 0)
         {
            this._curr_player = 1;
         }
         else
         {
            this._curr_player = 0;
         }
         _this.player_nr.text = (this._curr_player + 1).toString();
      }
      
      private function ToggleConfig() : void
      {
         if(this._config == SIMPLE)
         {
            this._config = ADVANCED;
         }
         else
         {
            this._config = SIMPLE;
         }
         _this.gotoAndStop(this._config + 1);
      }
      
      override public function KeyPressed(param1:int) : void
      {
         if(this._wait_for_key)
         {
            return;
         }
         switch(param1)
         {
            case MenuKey.KEY_UP:
               --_marker_pos;
               if(_marker_pos < 0)
               {
                  _marker_pos = TOTAL_SELECTIONS[this._config];
               }
               break;
            case MenuKey.KEY_DOWN:
               ++_marker_pos;
               if(_marker_pos > TOTAL_SELECTIONS[this._config])
               {
                  _marker_pos = 0;
               }
               break;
            case MenuKey.KEY_LEFT:
               if(_marker_pos == 0)
               {
                  this.TogglePlayer();
               }
               if(_marker_pos == 1)
               {
                  this.ToggleConfig();
               }
               break;
            case MenuKey.KEY_RIGHT:
               if(_marker_pos == 0)
               {
                  this.TogglePlayer();
               }
               if(_marker_pos == 1)
               {
                  this.ToggleConfig();
               }
               break;
            case MenuKey.KEY_ENTER:
               if(_marker_pos > 1 && _marker_pos < TOTAL_SELECTIONS[this._config])
               {
                  this.EditKeyBind();
                  return;
               }
               if(_marker_pos == TOTAL_SELECTIONS[this._config])
               {
                  this.SetDefaultKeys();
               }
               break;
            case MenuKey.KEY_BACKSPACE:
               if(!this._wait_for_key)
               {
                  this._Handler_Keyboard.KeyDownFunction = null;
               }
         }
         this.UpdateMarker();
      }
      
      override public function GetChoice() : String
      {
         return "";
      }
   }
}

