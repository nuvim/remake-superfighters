package Code.Handler
{
   import Code.*;
   import Code.Data.*;
   import Code.Data.Menu.*;
   import Code.Data.Players.*;
   import flash.display.*;
   import flash.events.*;
   import flash.net.*;
   
   public class MenuMain
   {
      
      private const MENU_ROOT_OFFSET:Number = 1;
      
      private var _game_mc:MovieClip;
      
      private var _stage:*;
      
      private var _Handler_Output:OutputTrace;
      
      private var _Handler_GameMain:GameMain;
      
      private var _Handler_Keyboard:InputKeyboard;
      
      private var _Handler_Options:Options;
      
      private var _Handler_Sounds:Sounds;
      
      private var _menu_overlay:MovieClip;
      
      private var _curr_menu:submenu_base;
      
      private var _menu_history:Array;
      
      private var _delay_timer:Number;
      
      private var _player_choosen_skins:Array;
      
      private var _lastChoise:String = "";
      
      public function MenuMain(param1:MenuMainData)
      {
         var menuData:MenuMainData = param1;
         super();
         this._game_mc = menuData.game_mc;
         this._stage = menuData.stage_temp;
         this._Handler_Output = menuData.Handler_Output;
         this._Handler_GameMain = menuData.Handler_GameMain;
         this._Handler_Sounds = menuData.Handler_Sounds;
         this._Handler_Options = menuData.Handler_Options;
         this._menu_overlay = new main_menu_overlay();
         this._menu_history = new Array();
         this._menu_overlay.link_4.addEventListener(MouseEvent.CLICK,this.Link4);
         this._player_choosen_skins = new Array();
         if(IDI.idnet)
         {
            IDI.idnetUpdates.push(function(param1:String):void
            {
               if(_curr_menu != null)
               {
                  _curr_menu.idnetUpdate(param1);
               }
               var _loc2_:Number = 0;
               while(_loc2_ < _menu_history.length)
               {
                  _menu_history[_loc2_].idnetUpdate(param1);
                  _loc2_++;
               }
            });
         }
      }
      
      private function Link4(param1:MouseEvent) : void
      {
         var _loc2_:URLRequest = new URLRequest("http://mythologicinteractive.com/");
         navigateToURL(_loc2_,"_blank");
      }
      
      private function OpenInstructions() : void
      {
      }
      
      public function get MenuOverlay() : MovieClip
      {
         return this._menu_overlay;
      }
      
      public function OpenMenu() : void
      {
         this._Handler_Keyboard = new InputKeyboard(this._stage);
         this.StartMenuGame();
         if(this._menu_history.length > 0)
         {
            this._curr_menu.Show();
         }
         else
         {
            this._menu_history = new Array();
            this.Hide([this._menu_overlay.vs_1p_setup,this._menu_overlay.vs_2p_setup,this._menu_overlay.map_selection,this._menu_overlay.mode_selection,this._menu_overlay.no_bots,this._menu_overlay.bot_7_setup,this._menu_overlay.bot_6_setup,this._menu_overlay.set_up,this._menu_overlay.set_up_main,this._menu_overlay.leaderboards_selection,this._menu_overlay.challenge_selection,this._menu_overlay.confirm_delete,this._menu_overlay.confirm_copy_save,this._menu_overlay.main_choise]);
            this._curr_menu = new save_selection(this._menu_overlay.save_selection,this._Handler_Sounds);
         }
         this._stage.addChild(this._menu_overlay);
         this._Handler_Keyboard.AddHandler(this._Handler_Keyboard.GetKeyCode("UP"),function():void
         {
            KeyPressed(MenuKey.KEY_UP);
         });
         this._Handler_Keyboard.AddHandler(this._Handler_Keyboard.GetKeyCode("DOWN"),function():void
         {
            KeyPressed(MenuKey.KEY_DOWN);
         });
         this._Handler_Keyboard.AddHandler(this._Handler_Keyboard.GetKeyCode("LEFT"),function():void
         {
            KeyPressed(MenuKey.KEY_LEFT);
         });
         this._Handler_Keyboard.AddHandler(this._Handler_Keyboard.GetKeyCode("RIGHT"),function():void
         {
            KeyPressed(MenuKey.KEY_RIGHT);
         });
         this._Handler_Keyboard.AddHandler(this._Handler_Keyboard.GetKeyCode("ENTER"),function():void
         {
            KeyPressed(MenuKey.KEY_ENTER);
         });
         this._Handler_Keyboard.AddHandler(this._Handler_Keyboard.GetKeyCode("SPACE"),function():void
         {
            KeyPressed(MenuKey.KEY_ENTER);
         });
         this._Handler_Keyboard.AddHandler(this._Handler_Keyboard.GetKeyCode("BACKSPACE"),function():void
         {
            KeyPressed(MenuKey.KEY_BACKSPACE);
         });
         this._Handler_Keyboard.AddHandler(27,function():void
         {
            KeyPressed(MenuKey.KEY_BACKSPACE);
            IDI.IDNETCloseInterface();
         });
      }
      
      private function KeyPressed(param1:int) : void
      {
         if(IDI.IDNETOpen())
         {
            return;
         }
         this._curr_menu.KeyPressed(param1);
         switch(param1)
         {
            case MenuKey.KEY_ENTER:
               this.CheckNextMenu();
               break;
            case MenuKey.KEY_BACKSPACE:
               this.CheckPrevMenu();
         }
      }
      
      private function CheckNextMenu() : void
      {
         var _loc2_:Boolean = false;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc1_:String = this._curr_menu.GetChoice();
         if(_loc1_ != "")
         {
            this._lastChoise = _loc1_;
            if(this._menu_history.length > 0 && this._menu_history[0] == this._curr_menu)
            {
               _loc2_ = true;
            }
            this._menu_history.push(this._curr_menu);
            switch(_loc1_)
            {
               case "save_online":
                  if(IDI.IDNETIsLoggedIn())
                  {
                     SaveState.SelectOnline();
                     Achievements.SetEnabled(true);
                     IDI.IDNETRefreshAchievements(true);
                     this._Handler_Sounds.PlayMightySound("ACCEPT");
                     this._curr_menu.Hide();
                     this._curr_menu = new main_choise(this._menu_overlay.main_choise,this._Handler_Sounds);
                     this._curr_menu.Show();
                  }
                  else
                  {
                     IDI.idnet.toggleInterface("registration");
                     this._menu_history.splice(this._menu_history.length - 1,1);
                  }
                  break;
               case "save_online_delete":
                  this._Handler_Sounds.PlayMightySound("ACCEPT");
                  this._curr_menu = new confirm_delete(MovieClip(this._menu_overlay.getChildByName("confirm_delete")),this._Handler_Sounds,"ONLINE");
                  this._curr_menu.Show();
                  break;
               case "save_offline":
                  SaveState.SelectOffline();
                  Achievements.UpdateList(null);
                  Achievements.SetEnabled(false);
                  this._Handler_Sounds.PlayMightySound("ACCEPT");
                  this._curr_menu.Hide();
                  this._curr_menu = new main_choise(this._menu_overlay.main_choise,this._Handler_Sounds);
                  this._curr_menu.Show();
                  break;
               case "save_offline_delete":
                  this._Handler_Sounds.PlayMightySound("ACCEPT");
                  this._curr_menu = new confirm_delete(MovieClip(this._menu_overlay.getChildByName("confirm_delete")),this._Handler_Sounds,"OFFLINE");
                  this._curr_menu.Show();
                  break;
               case "copy_offline_to_online":
                  this._Handler_Sounds.PlayMightySound("ACCEPT");
                  if(SaveState.OnlineDataExist())
                  {
                     this._curr_menu = new confirm_delete(MovieClip(this._menu_overlay.getChildByName("confirm_copy_save")),this._Handler_Sounds,"COPY_OFFLINE_TO_ONLINE");
                  }
                  else
                  {
                     this._curr_menu = new confirm_delete(MovieClip(this._menu_overlay.getChildByName("confirm_delete")),this._Handler_Sounds,"COPY_OFFLINE_TO_ONLINE");
                  }
                  this._curr_menu.Show();
                  break;
               case "idnet_login":
                  if(IDI.idnet)
                  {
                     if(IDI.idnet.isLoggedIn)
                     {
                        IDI.idnet.toggleInterface("login");
                     }
                     else
                     {
                        IDI.idnet.toggleInterface("registration");
                     }
                  }
                  this._menu_history.splice(this._menu_history.length - 1,1);
                  break;
               case "mode_selection":
                  this._Handler_Sounds.PlayMightySound("ACCEPT");
                  this._curr_menu = new mode_selection(this._menu_overlay.mode_selection,this._Handler_Sounds);
                  this._curr_menu.Show();
                  break;
               case "vs_mode":
                  this._menu_history[this.MENU_ROOT_OFFSET + 0].Hide();
                  this._menu_history[this.MENU_ROOT_OFFSET + 1].Hide();
                  this._Handler_Sounds.PlayMightySound("ACCEPT");
                  this._curr_menu = new vs_player_setup(MovieClip(this._menu_overlay.getChildByName("vs_" + this._menu_history[this.MENU_ROOT_OFFSET + 0].Players + "p_setup")),this._Handler_Sounds,this._menu_history[this.MENU_ROOT_OFFSET + 0].Players,0);
                  this._curr_menu.Show();
                  break;
               case "stage_mode":
                  this._menu_history[this.MENU_ROOT_OFFSET + 0].Hide();
                  this._menu_history[this.MENU_ROOT_OFFSET + 1].Hide();
                  this._Handler_Sounds.PlayMightySound("ACCEPT");
                  this._curr_menu = new vs_player_setup(MovieClip(this._menu_overlay.getChildByName("vs_" + this._menu_history[this.MENU_ROOT_OFFSET + 0].Players + "p_setup")),this._Handler_Sounds,this._menu_history[this.MENU_ROOT_OFFSET + 0].Players,1);
                  this._curr_menu.Show();
                  break;
               case "survival_mode":
                  this._menu_history[this.MENU_ROOT_OFFSET + 0].Hide();
                  this._menu_history[this.MENU_ROOT_OFFSET + 1].Hide();
                  this._Handler_Sounds.PlayMightySound("ACCEPT");
                  this._curr_menu = new vs_player_setup(MovieClip(this._menu_overlay.getChildByName("vs_" + this._menu_history[this.MENU_ROOT_OFFSET + 0].Players + "p_setup")),this._Handler_Sounds,this._menu_history[this.MENU_ROOT_OFFSET + 0].Players,2);
                  this._curr_menu.Show();
                  break;
               case "challenge_selection":
                  this._Handler_Sounds.PlayMightySound("ACCEPT");
                  this._curr_menu = new challenge_selection(MovieClip(this._menu_overlay.getChildByName("challenge_selection")),this._Handler_Sounds,this._Handler_Keyboard,this._menu_history[this.MENU_ROOT_OFFSET + 0].Players);
                  this._curr_menu.Show();
                  break;
               case "delete_progress":
                  this._Handler_Sounds.PlayMightySound("CANCEL");
                  if(this._curr_menu.MsgID == "OFFLINE")
                  {
                     SaveState.DeleteOffline();
                  }
                  else if(this._curr_menu.MsgID == "ONLINE")
                  {
                     SaveState.DeleteOnline();
                  }
                  else if(this._curr_menu.MsgID == "COPY_OFFLINE_TO_ONLINE")
                  {
                     SaveState.CopyOfflineToOnline();
                  }
                  this.KeyPressed(MenuKey.KEY_BACKSPACE);
                  this.KeyPressed(MenuKey.KEY_BACKSPACE);
                  this._lastChoise = "";
                  break;
               case "not_delete_progress":
                  this._Handler_Sounds.PlayMightySound("CANCEL");
                  this.KeyPressed(MenuKey.KEY_BACKSPACE);
                  this.KeyPressed(MenuKey.KEY_BACKSPACE);
                  this._lastChoise = "";
                  break;
               case "no_bots":
                  this._Handler_Sounds.PlayMightySound("ACCEPT");
                  _loc3_ = 0;
                  if(this._menu_history[this.MENU_ROOT_OFFSET + 0].Players == 1)
                  {
                     _loc3_ = 1;
                  }
                  else if(this._menu_history[this.MENU_ROOT_OFFSET + 2].PlayerPlateOne.Team == this._menu_history[this.MENU_ROOT_OFFSET + 2].PlayerPlateTwo.Team && this._menu_history[this.MENU_ROOT_OFFSET + 2].PlayerPlateOne.Team != 0)
                  {
                     _loc3_ = 1;
                  }
                  _loc4_ = 8 - this._menu_history[this.MENU_ROOT_OFFSET + 0].Players;
                  this._curr_menu = new no_bots(MovieClip(this._menu_overlay.getChildByName("no_bots")),this._Handler_Sounds,_loc3_,_loc4_);
                  this._curr_menu.Show();
                  break;
               case "prepare_bots":
                  _loc5_ = 0;
                  if(this._menu_history[this.MENU_ROOT_OFFSET + 0].Players == 1)
                  {
                     _loc5_ = int(this._menu_history[this.MENU_ROOT_OFFSET + 2].PlayerPlateOne.Team);
                  }
                  else if(this._menu_history[this.MENU_ROOT_OFFSET + 2].PlayerPlateOne.Team == this._menu_history[this.MENU_ROOT_OFFSET + 2].PlayerPlateTwo.Team)
                  {
                     _loc5_ = int(this._menu_history[this.MENU_ROOT_OFFSET + 2].PlayerPlateOne.Team);
                  }
                  if(this._menu_history[this.MENU_ROOT_OFFSET + 0].Players == 1)
                  {
                     this._curr_menu = new bot_setup(MovieClip(this._menu_overlay.getChildByName("bot_7_setup")),this._Handler_Sounds,this._menu_history[this.MENU_ROOT_OFFSET + 3].NoBots,_loc5_);
                  }
                  else
                  {
                     this._curr_menu = new bot_setup(MovieClip(this._menu_overlay.getChildByName("bot_6_setup")),this._Handler_Sounds,this._menu_history[this.MENU_ROOT_OFFSET + 3].NoBots,_loc5_);
                  }
                  this._curr_menu.Show();
                  if(this._menu_history[this.MENU_ROOT_OFFSET + 3].NoBots == 0)
                  {
                     this.KeyPressed(MenuKey.KEY_ENTER);
                  }
                  else
                  {
                     this._Handler_Sounds.PlayMightySound("ACCEPT");
                  }
                  break;
               case "map_selection":
                  this._Handler_Sounds.PlayMightySound("ACCEPT");
                  this._curr_menu = new map_selection(MovieClip(this._menu_overlay.getChildByName("map_selection")),this._Handler_Sounds,0);
                  this._curr_menu.Show();
                  break;
               case "survival_selection":
                  this._Handler_Sounds.PlayMightySound("ACCEPT");
                  this._curr_menu = new map_selection(MovieClip(this._menu_overlay.getChildByName("map_selection")),this._Handler_Sounds,2);
                  this._curr_menu.Show();
                  break;
               case "reset":
                  while(this._menu_history.length > this.MENU_ROOT_OFFSET + 2)
                  {
                     this.KeyPressed(MenuKey.KEY_BACKSPACE);
                  }
                  this._Handler_Sounds.PlayMightySound("CANCEL");
                  this._lastChoise = "";
                  break;
               case "fight":
                  this.UserInpuOver();
                  this._menu_history.splice(this._menu_history.length - 1,1);
                  break;
               case "tutorial":
                  this.StartTutorial();
                  this._menu_history.splice(this._menu_history.length - 1,1);
                  this.OpenInstructions();
                  break;
               case "start_challenge":
                  this.StartChallenge();
                  this._menu_history.splice(this._menu_history.length - 1,1);
                  break;
               case "start_survival":
                  this.StartSurvival();
                  this._menu_history.splice(this._menu_history.length - 1,1);
                  break;
               case "set_up":
                  this._Handler_Sounds.PlayMightySound("ACCEPT");
                  this._curr_menu = new set_up(MovieClip(this._menu_overlay.getChildByName("set_up")),this._Handler_Sounds,this._Handler_Keyboard,this._Handler_Options);
                  this._curr_menu.Show();
                  break;
               case "set_up_main":
                  this._Handler_Sounds.PlayMightySound("ACCEPT");
                  this._curr_menu = new set_up_main(MovieClip(this._menu_overlay.getChildByName("set_up_main")),this._Handler_Sounds,this._Handler_Keyboard,this._Handler_Options);
                  this._curr_menu.Show();
                  break;
               case "achievements":
                  if(IDI.idnet)
                  {
                     IDI.idnet.toggleInterface("achievements");
                  }
                  this._menu_history.splice(this._menu_history.length - 1,1);
                  break;
               case "leaderboards_selection":
                  this._Handler_Sounds.PlayMightySound("ACCEPT");
                  this._curr_menu = new leaderboards_selection(MovieClip(this._menu_overlay.getChildByName("leaderboards_selection")),this._Handler_Sounds);
                  this._curr_menu.Show();
                  break;
               case "leaderboards_survival1p":
                  if(IDI.idnet)
                  {
                     IDI.idnet.advancedScoreList("Survival");
                  }
                  this._menu_history.splice(this._menu_history.length - 1,1);
                  break;
               case "leaderboards_survival2p":
                  if(IDI.idnet)
                  {
                     IDI.idnet.advancedScoreList("Survival Co-op");
                  }
                  this._menu_history.splice(this._menu_history.length - 1,1);
            }
         }
      }
      
      private function CheckPrevMenu() : void
      {
         if(this._menu_history.length > 0)
         {
            if(this._curr_menu.CanReturn)
            {
               this._curr_menu.Hide();
               this._curr_menu = this._menu_history[this._menu_history.length - 1];
               this._curr_menu.Show();
               this._menu_history.splice(this._menu_history.length - 1,1);
               if(this._lastChoise != "delete_progress" && this._lastChoise != "not_delete_progress")
               {
                  this._Handler_Sounds.PlayMightySound("CANCEL");
               }
               if(this._menu_history.length == 2)
               {
                  this._menu_history[1].Show();
               }
            }
         }
      }
      
      public function StartNewGame() : void
      {
         this._player_choosen_skins = new Array();
         var _loc1_:PlayerSetupData = new PlayerSetupData();
         _loc1_.ot = this._Handler_Output;
         _loc1_.keys = this._Handler_Options.GetPlayerKeys();
         _loc1_.totalPlayers = this._menu_history[this.MENU_ROOT_OFFSET + 0].Players + this._menu_history[this.MENU_ROOT_OFFSET + 3].NoBots;
         _loc1_.ai = new Array(1,0,0,0,0,0,0,0);
         _loc1_.characters = new Array(this._menu_history[this.MENU_ROOT_OFFSET + 2].PlayerPlateOne.Character,0,0,0,0,0,0,0);
         _loc1_.teams = new Array(this._menu_history[this.MENU_ROOT_OFFSET + 2].PlayerPlateOne.Team,0,0,0,0,0,0,0);
         if(_loc1_.characters[0] == 0)
         {
            _loc1_.characters[0] = this.GetRndChar();
         }
         this._player_choosen_skins.push(_loc1_.characters[0]);
         if(this._menu_history[this.MENU_ROOT_OFFSET + 0].Players == 2)
         {
            _loc1_.ai[1] = 2;
            _loc1_.characters[1] = this._menu_history[this.MENU_ROOT_OFFSET + 2].PlayerPlateTwo.Character;
            _loc1_.teams[1] = this._menu_history[this.MENU_ROOT_OFFSET + 2].PlayerPlateTwo.Team;
            if(_loc1_.characters[1] == 0)
            {
               _loc1_.characters[1] = this.GetRndChar();
            }
            this._player_choosen_skins.push(_loc1_.characters[1]);
         }
         _loc1_.aiDifficulty = new Array(0,0,0,0,0,0,0,0);
         var _loc2_:int = 0;
         var _loc3_:int = int(this._menu_history[this.MENU_ROOT_OFFSET + 0].Players);
         while(_loc3_ < _loc1_.totalPlayers)
         {
            _loc1_.characters[_loc3_] = this._menu_history[this.MENU_ROOT_OFFSET + 4].BotPlates[_loc2_].Character;
            _loc1_.teams[_loc3_] = this._menu_history[this.MENU_ROOT_OFFSET + 4].BotPlates[_loc2_].Team;
            _loc1_.aiDifficulty[_loc3_] = this._menu_history[this.MENU_ROOT_OFFSET + 4].BotPlates[_loc2_].Difficulty;
            _loc2_++;
            _loc3_++;
         }
         var _loc4_:int = 0;
         while(_loc4_ < _loc1_.characters.length)
         {
            if(_loc1_.characters[_loc4_] == 0)
            {
               _loc1_.characters[_loc4_] = this.GetRndChar();
            }
            _loc4_++;
         }
         var _loc5_:NewGameData = new NewGameData();
         _loc5_.lvl = this._menu_history[this._menu_history.length - 1].Level;
         if(_loc5_.lvl == Maps.RANDOM_MAP)
         {
            _loc5_.lvl = 2 + Math.floor(Math.random() * (Maps.RANDOM_MAP - 2.001));
         }
         _loc5_.pSetupData = _loc1_;
         _loc5_.gamePosX = 0;
         if(_loc1_.totalPlayers > 4)
         {
            _loc5_.gameScale = 1;
            _loc5_.gamePosY = 75;
         }
         else
         {
            _loc5_.gameScale = 1.05;
            _loc5_.gamePosY = 75 / 2;
         }
         _loc5_.challengeNr = -1;
         _loc5_.isMenuDemo = false;
         _loc5_.isTutorial = false;
         _loc5_.isSurvival = false;
         _loc5_.showTips = true;
         _loc5_.newScore = true;
         _loc5_.gameMode = this._menu_history[this._menu_history.length - 1].Mode;
         this._Handler_GameMain.StartNewGame(_loc5_);
      }
      
      public function UserInpuOver() : void
      {
         this._stage.removeChild(this._menu_overlay);
         this._Handler_Keyboard.Deconstruct();
         this._Handler_GameMain.Stop();
         this.StartNewGame();
      }
      
      private function StartTutorial() : void
      {
         this._stage.removeChild(this._menu_overlay);
         this._Handler_Keyboard.Deconstruct();
         this._Handler_GameMain.Stop();
         this.StartTutorialGame();
      }
      
      private function StartChallenge() : void
      {
         this._stage.removeChild(this._menu_overlay);
         this._Handler_Keyboard.Deconstruct();
         this._Handler_GameMain.Stop();
         this.StartChallengeGame();
      }
      
      private function StartSurvival() : void
      {
         this._stage.removeChild(this._menu_overlay);
         this._Handler_Keyboard.Deconstruct();
         this._Handler_GameMain.Stop();
         this.StartSurvivalGame();
      }
      
      private function StartSurvivalGame() : void
      {
         this._player_choosen_skins = new Array();
         var _loc1_:PlayerSetupData = new PlayerSetupData();
         _loc1_.ot = this._Handler_Output;
         _loc1_.keys = this._Handler_Options.GetPlayerKeys();
         _loc1_.totalPlayers = this._menu_history[this.MENU_ROOT_OFFSET + 0].Players;
         _loc1_.aiDifficulty = new Array(3,3,3,3,3,3,3,3);
         _loc1_.ai = new Array(1,0,0,0,0,0,0,0);
         _loc1_.characters = new Array(this._menu_history[this.MENU_ROOT_OFFSET + 2].PlayerPlateOne.Character,0,0,0,0,0,0,0);
         _loc1_.teams = new Array(this._menu_history[this.MENU_ROOT_OFFSET + 2].PlayerPlateOne.Team,0,0,0,0,0,0,0);
         if(_loc1_.characters[0] == 0)
         {
            _loc1_.characters[0] = this.GetRndChar();
         }
         this._player_choosen_skins.push(_loc1_.characters[0]);
         if(this._menu_history[this.MENU_ROOT_OFFSET + 0].Players == 2)
         {
            _loc1_.ai[1] = 2;
            _loc1_.characters[1] = this._menu_history[this.MENU_ROOT_OFFSET + 2].PlayerPlateTwo.Character;
            _loc1_.teams[1] = this._menu_history[this.MENU_ROOT_OFFSET + 2].PlayerPlateTwo.Team;
            if(_loc1_.characters[1] == 0)
            {
               _loc1_.characters[1] = this.GetRndChar();
            }
            this._player_choosen_skins.push(_loc1_.characters[1]);
         }
         var _loc2_:NewGameData = new NewGameData();
         _loc2_.lvl = 10;
         _loc2_.pSetupData = _loc1_;
         _loc2_.gameScale = 1;
         _loc2_.gamePosX = 0;
         _loc2_.gamePosY = 0;
         _loc2_.challengeNr = -1;
         _loc2_.isMenuDemo = false;
         _loc2_.isTutorial = false;
         _loc2_.isSurvival = true;
         _loc2_.showTips = false;
         _loc2_.newScore = true;
         _loc2_.gameMode = 1;
         this._Handler_GameMain.StartNewGame(_loc2_);
      }
      
      private function StartChallengeGame() : void
      {
         this._player_choosen_skins = new Array();
         var _loc1_:int = this._menu_history[this.MENU_ROOT_OFFSET + 3].SelectedChallenge - 1;
         var _loc2_:Array = Challenges.CHALLENGE[this._menu_history[this.MENU_ROOT_OFFSET + 0].Players - 1][_loc1_];
         var _loc3_:int = _loc2_.length - 1;
         var _loc4_:PlayerSetupData = new PlayerSetupData();
         _loc4_.ot = this._Handler_Output;
         _loc4_.keys = this._Handler_Options.GetPlayerKeys();
         _loc4_.totalPlayers = this._menu_history[this.MENU_ROOT_OFFSET + 0].Players + _loc3_;
         _loc4_.ai = new Array(1,0,0,0,0,0,0,0);
         _loc4_.characters = new Array(this._menu_history[this.MENU_ROOT_OFFSET + 2].PlayerPlateOne.Character,0,0,0,0,0,0,0);
         _loc4_.teams = new Array(this._menu_history[this.MENU_ROOT_OFFSET + 2].PlayerPlateOne.Team,0,0,0,0,0,0,0);
         if(_loc4_.characters[0] == 0)
         {
            _loc4_.characters[0] = this.GetRndChar();
         }
         this._player_choosen_skins.push(_loc4_.characters[0]);
         if(this._menu_history[this.MENU_ROOT_OFFSET + 0].Players == 2)
         {
            _loc4_.ai[1] = 2;
            _loc4_.characters[1] = this._menu_history[this.MENU_ROOT_OFFSET + 2].PlayerPlateTwo.Character;
            _loc4_.teams[1] = this._menu_history[this.MENU_ROOT_OFFSET + 2].PlayerPlateTwo.Team;
            if(_loc4_.characters[1] == 0)
            {
               _loc4_.characters[1] = this.GetRndChar();
            }
            this._player_choosen_skins.push(_loc4_.characters[1]);
         }
         _loc4_.aiDifficulty = new Array(0,0,0,0,0,0,0,0);
         var _loc5_:int = 1;
         var _loc6_:int = int(this._menu_history[this.MENU_ROOT_OFFSET + 0].Players);
         while(_loc6_ < _loc4_.totalPlayers)
         {
            _loc4_.characters[_loc6_] = 0;
            _loc4_.teams[_loc6_] = 2;
            _loc4_.aiDifficulty[_loc6_] = _loc2_[_loc5_];
            _loc5_++;
            _loc6_++;
         }
         if(_loc1_ == 11)
         {
            _loc4_.characters[this._menu_history[this.MENU_ROOT_OFFSET + 0].Players] = PlayerCharacter.FUNNYMAN;
         }
         var _loc7_:int = 0;
         while(_loc7_ < _loc4_.characters.length)
         {
            if(_loc4_.characters[_loc7_] == 0)
            {
               _loc4_.characters[_loc7_] = this.GetRndChar();
            }
            _loc7_++;
         }
         var _loc8_:NewGameData = new NewGameData();
         _loc8_.lvl = _loc2_[0];
         _loc8_.pSetupData = _loc4_;
         _loc8_.gamePosX = 0;
         if(_loc4_.totalPlayers > 4)
         {
            _loc8_.gameScale = 1;
            _loc8_.gamePosY = 75;
         }
         else
         {
            _loc8_.gameScale = 1.05;
            _loc8_.gamePosY = 75 / 2;
         }
         _loc8_.challengeNr = _loc1_;
         _loc8_.isMenuDemo = false;
         _loc8_.isTutorial = false;
         _loc8_.isSurvival = false;
         _loc8_.showTips = true;
         _loc8_.newScore = true;
         _loc8_.gameMode = 8;
         this._Handler_GameMain.StartNewGame(_loc8_);
      }
      
      private function StartTutorialGame() : void
      {
         this._player_choosen_skins = new Array();
         var _loc1_:PlayerSetupData = new PlayerSetupData();
         _loc1_.ot = this._Handler_Output;
         _loc1_.keys = this._Handler_Options.GetPlayerKeys();
         _loc1_.characters = new Array(1,2,3,3,3,3,3,3);
         _loc1_.totalPlayers = 1;
         _loc1_.teams = new Array(0,0,0,0,0,0,0,0);
         _loc1_.ai = new Array(1,2,0,0,0,0,0,0);
         _loc1_.aiDifficulty = new Array(3,3,3,3,3,3,3,3);
         var _loc2_:NewGameData = new NewGameData();
         _loc2_.lvl = 1;
         _loc2_.pSetupData = _loc1_;
         _loc2_.gameScale = 1;
         _loc2_.gamePosX = 0;
         _loc2_.gamePosY = 0;
         _loc2_.challengeNr = -1;
         _loc2_.isMenuDemo = false;
         _loc2_.isTutorial = true;
         _loc2_.isSurvival = false;
         _loc2_.showTips = false;
         _loc2_.newScore = true;
         _loc2_.gameMode = 1;
         this._Handler_GameMain.StartNewGame(_loc2_);
      }
      
      public function StartMenuGame() : void
      {
         this._player_choosen_skins = new Array();
         var _loc1_:PlayerSetupData = new PlayerSetupData();
         _loc1_.ot = this._Handler_Output;
         _loc1_.characters = new Array(this.GetRndChar(),this.GetRndChar(),this.GetRndChar(),this.GetRndChar(),this.GetRndChar(),this.GetRndChar(),this.GetRndChar(),this.GetRndChar());
         var _loc2_:int = Math.floor(Math.random() * 4.9999);
         switch(_loc2_)
         {
            case 0:
               _loc1_.totalPlayers = 3;
               _loc1_.teams = new Array(0,0,0,0,0,0,0,0);
               break;
            case 1:
               _loc1_.totalPlayers = 4;
               _loc1_.teams = new Array(1,1,2,2,0,0,0,0);
               break;
            case 2:
               _loc1_.totalPlayers = 5;
               _loc1_.teams = new Array(0,0,0,4,4,0,0,0);
               break;
            case 3:
               _loc1_.totalPlayers = 6;
               _loc1_.teams = new Array(1,1,2,2,3,3,4,4);
               break;
            default:
               _loc1_.characters = new Array(1,2,3,3,3,3,3,3);
               _loc1_.totalPlayers = 2;
               _loc1_.teams = new Array(0,0,0,0,0,0,0,0);
         }
         _loc1_.ai = new Array(0,0,0,0,0,0,0,0);
         _loc1_.aiDifficulty = new Array(3,3,3,3,3,3,3,3);
         var _loc3_:NewGameData = new NewGameData();
         _loc3_.lvl = 2 + Math.floor(Math.random() * 5.999);
         _loc3_.pSetupData = _loc1_;
         _loc3_.gameScale = 0.95;
         _loc3_.gamePosX = 80;
         _loc3_.gamePosY = 110;
         _loc3_.challengeNr = -1;
         _loc3_.isMenuDemo = true;
         _loc3_.isTutorial = false;
         _loc3_.isSurvival = false;
         _loc3_.showTips = false;
         _loc3_.newScore = true;
         _loc3_.gameMode = 1;
         this._Handler_GameMain.StartNewGame(_loc3_);
      }
      
      private function GetRndChar() : int
      {
         var _loc1_:int = 0;
         var _loc4_:int = 0;
         var _loc2_:* = false;
         _loc1_ = int(PlayerCharacter.GetRandomCharacter());
         _loc2_ = true;
         var _loc3_:int = 0;
         while(_loc3_ < this._player_choosen_skins.length)
         {
            if(_loc1_ == this._player_choosen_skins[_loc3_])
            {
               _loc2_ = false;
            }
            _loc3_++;
         }
         while(!_loc2_)
         {
            _loc1_ = int(PlayerCharacter.GetRandomCharacter());
            _loc2_ = true;
            _loc4_ = 0;
            while(_loc4_ < this._player_choosen_skins.length)
            {
               if(_loc1_ == this._player_choosen_skins[_loc4_])
               {
                  _loc2_ = false;
               }
               _loc4_++;
            }
         }
         return _loc1_;
      }
      
      private function Hide(param1:Array) : void
      {
         var _loc2_:int = 0;
         while(_loc2_ < param1.length)
         {
            MovieClip(param1[_loc2_]).visible = false;
            _loc2_++;
         }
      }
      
      private function Show(param1:Array) : void
      {
         var _loc2_:int = 0;
         while(_loc2_ < param1.length)
         {
            MovieClip(param1[_loc2_]).visible = true;
            _loc2_++;
         }
      }
   }
}

