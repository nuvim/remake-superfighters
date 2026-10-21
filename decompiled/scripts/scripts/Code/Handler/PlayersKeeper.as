package Code.Handler
{
   import Code.Box2D.Dynamics.b2World;
   import Code.Data.Players.*;
   import flash.display.*;
   import flash.geom.*;
   
   public class PlayersKeeper
   {
      
      private var _stage:*;
      
      private var _game_mc:MovieClip;
      
      private var _Handler_Output:OutputTrace;
      
      private var _Handler_Keyboard:InputKeyboard;
      
      private var _Handler_Camera:Cam;
      
      private var _Handler_Effects:Effects;
      
      private var _Handler_ProjectilesUpdater:ProjectilesUpdater;
      
      private var _Handler_Maps:Maps;
      
      private var _Handler_Shake:Shake;
      
      private var _Handler_Sounds:Sounds;
      
      private var _Handler_Slowmo:Slowmo;
      
      private var _Handler_Fires:Fires;
      
      private var _playerSetupData:PlayerSetupData;
      
      private var _playerSpawnPositions:Array;
      
      private var _RecalculateCamArea:Function;
      
      private var _cameraBounds:Array;
      
      private var _characters:Array;
      
      private var _cameraUpdateTimer:Number = 12;
      
      private var _MapArea:Rectangle;
      
      private var m_world:b2World;
      
      private var _pathGrid:PathGrid;
      
      private var _players_left:Array;
      
      private var _roundOverTimer:Number = 36;
      
      private var plrData:PlayersKeeperData;
      
      private var gui_holder_mc:MovieClip;
      
      private var _players:Array = new Array();
      
      private var _lastCoveredPosition:Point = new Point(0,0);
      
      private var _roundOver:Boolean = false;
      
      private var _team_winner:int = -1;
      
      private var _solo_nr_winner:int = -1;
      
      private var _playersInitialized:Boolean = false;
      
      public function PlayersKeeper(param1:PlayersKeeperData)
      {
         super();
         this.plrData = param1;
         this._stage = this.plrData.stg;
         this.m_world = this.plrData.m_world;
         this._game_mc = this.plrData.game_mc;
         this._playerSetupData = this.plrData.pSetupData;
         this._pathGrid = this.plrData.pathGrid;
         this._pathGrid.LinkPlayers(this._players);
         this.gui_holder_mc = MovieClip(this._game_mc.getChildByName("GUI_HOLDER"));
         this.gui_holder_mc.player_1.visible = false;
         this.gui_holder_mc.player_2.visible = false;
         this.gui_holder_mc.com_no_players.visible = false;
         this.gui_holder_mc.com_0.visible = false;
         this.gui_holder_mc.com_1.visible = false;
         this.gui_holder_mc.com_2.visible = false;
         this.gui_holder_mc.com_3.visible = false;
         this.gui_holder_mc.com_4.visible = false;
         this.gui_holder_mc.com_5.visible = false;
         this.gui_holder_mc.com_6.visible = false;
         this._Handler_Output = this.plrData.Handler_Output;
         this._Handler_Keyboard = this.plrData.Handler_Keyboard;
         this._Handler_Shake = this.plrData.Handler_Shake;
         this._Handler_Effects = this.plrData.Handler_Effects;
         this._Handler_ProjectilesUpdater = this.plrData.Handler_Projectiles;
         this._Handler_Maps = this.plrData.Handler_Maps;
         this._Handler_Sounds = this.plrData.Handler_Sounds;
         this._Handler_Slowmo = this.plrData.Handler_Slowmo;
         this._playerSpawnPositions = new Array();
         var _loc2_:int = 0;
         while(_loc2_ < this._playerSetupData.playerSpawnPositions.length)
         {
            this._playerSpawnPositions.push(this._playerSetupData.playerSpawnPositions[_loc2_]);
            _loc2_++;
         }
         var _loc3_:int = -1;
         var _loc4_:int = 0;
         while(_loc4_ < this._playerSetupData.totalPlayers)
         {
            this.ConstructPlayer(_loc4_,this._playerSetupData.characters[_loc4_],this._playerSetupData.teams[_loc4_]);
            if(this._playerSetupData.ai[_loc4_] != 0)
            {
               this._players[_loc4_].SetControls(this._Handler_Keyboard,this._playerSetupData.keys[_loc4_]);
               this._players[_loc4_].SetGUI(MovieClip(this.gui_holder_mc.getChildByName("player_" + this._playerSetupData.ai[_loc4_])));
               this._players[_loc4_].SetSign(this._playerSetupData.ai[_loc4_]);
               _loc3_++;
            }
            else
            {
               this._players[_loc4_].SetAI(this._playerSetupData.aiDifficulty[_loc4_]);
               if(_loc3_ == -1)
               {
                  this._players[_loc4_].SetGUI(MovieClip(this.gui_holder_mc.getChildByName("com_no_players")));
               }
               else
               {
                  this._players[_loc4_].SetGUI(MovieClip(this.gui_holder_mc.getChildByName("com_" + _loc3_)));
               }
               this._players[_loc4_].SetSign(PlayerBars.PLAYER_COM);
               _loc3_++;
            }
            this._players[_loc4_].GiveStartItems(this.plrData.rangedStartWeapon.Copy(),this.plrData.throwableStartWeapon.Copy());
            this._players[_loc4_].GiveDefaultMelee(this.plrData.defaultMeleeWeapon.Copy());
            this._players[_loc4_].UpdateGUI();
            _loc4_++;
         }
         this._players_left = new Array(false,false,false,false,false);
      }
      
      public function get Players() : Array
      {
         return this._players;
      }
      
      public function SetStartImmunity() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ < this._players.length)
         {
            this._players[_loc1_].State.ImmunityTimer = 48;
            _loc1_++;
         }
      }
      
      public function ActivatePlayers() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ < this._playerSetupData.totalPlayers)
         {
            this._players[_loc1_].Activate();
            _loc1_++;
         }
      }
      
      private function ConstructPlayer(param1:int, param2:int, param3:int) : void
      {
         var _loc4_:Player = new Player(param2,this._game_mc,this.m_world,this._Handler_Maps,this._Handler_Sounds,this._Handler_Slowmo,this._Handler_Shake,this._Handler_Effects,this._Handler_ProjectilesUpdater,this._Handler_Output,this.GetRandomSpawnPosition(),param3,param1,this.RecalculateCamArea,this._players,this._pathGrid);
         this._players.push(_loc4_);
      }
      
      public function AddBot(param1:int, param2:int, param3:int) : Player
      {
         var _loc4_:Array = this._Handler_Maps.GetPlayerSpawnPositions();
         this._playerSetupData.playerSpawnPositions = new Array();
         this._playerSpawnPositions = new Array();
         var _loc5_:int = 0;
         while(_loc5_ < _loc4_.length)
         {
            this._playerSetupData.playerSpawnPositions.push(_loc4_[_loc5_]);
            this._playerSpawnPositions.push(_loc4_[_loc5_]);
            _loc5_++;
         }
         var _loc6_:int = int(this._players.length);
         this.ConstructPlayer(_loc6_,param1,param2);
         this._players[_loc6_].NoGUI();
         this._players[_loc6_].SetAI(param3);
         var _loc7_:MovieClip = MovieClip(this.gui_holder_mc.getChildByName("com_0"));
         this._players[_loc6_].SetGUI(_loc7_);
         _loc7_.visible = false;
         this._players[_loc6_].SetSign(PlayerBars.PLAYER_COM);
         this._players[_loc6_].GiveStartItems(this.plrData.rangedStartWeapon.Copy(),this.plrData.throwableStartWeapon.Copy());
         this._players[_loc6_].GiveDefaultMelee(this.plrData.defaultMeleeWeapon.Copy());
         this._players[_loc6_].Initialize(new PlayerAreaData(this._MapArea));
         this._players[_loc6_].LinkToFire(this._Handler_Fires);
         this._players[_loc6_].Activate();
         this.RecalculateCamArea();
         return this._players[_loc6_];
      }
      
      private function GetRandomSpawnPosition() : Point
      {
         var _loc3_:int = 0;
         if(this._playerSpawnPositions.length <= 0)
         {
            _loc3_ = 0;
            while(_loc3_ < this._playerSetupData.playerSpawnPositions.length)
            {
               this._playerSpawnPositions.push(this._playerSetupData.playerSpawnPositions[_loc3_]);
               _loc3_++;
            }
         }
         var _loc1_:Number = Math.floor(Math.random() * (this._playerSpawnPositions.length * 0.99));
         var _loc2_:Point = this._playerSpawnPositions[_loc1_];
         this._playerSpawnPositions.splice(_loc1_,1);
         return _loc2_;
      }
      
      public function Stop() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ < this._players.length)
         {
            this._players[_loc1_].Stop();
            _loc1_++;
         }
      }
      
      public function SetMapArea(param1:Rectangle) : void
      {
         this._MapArea = param1;
      }
      
      public function LinkToCam(param1:Cam) : void
      {
         this._Handler_Camera = param1;
      }
      
      public function LinkToFire(param1:Fires) : void
      {
         this._Handler_Fires = param1;
         var _loc2_:int = 0;
         while(_loc2_ < this._players.length)
         {
            this._players[_loc2_].LinkToFire(this._Handler_Fires);
            _loc2_++;
         }
      }
      
      public function SetCamArea(param1:Rectangle, param2:Rectangle, param3:Rectangle, param4:Rectangle) : void
      {
         this._cameraBounds = new Array();
         this._cameraBounds.push(param1);
         this._cameraBounds.push(param2);
         this._cameraBounds.push(param3);
         this._cameraBounds.push(param4);
      }
      
      public function GetCamArea() : Rectangle
      {
         var _loc1_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc12_:* = undefined;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc5_:Number = 15;
         var _loc6_:Number = 30;
         if(this._players.length > 0)
         {
            _loc12_ = 0;
            while(_loc12_ < this._players.length)
            {
               if(!this._players[_loc12_].CameraIgnore)
               {
                  this._lastCoveredPosition.x = this._players[_loc12_].PosX();
                  this._lastCoveredPosition.y = this._players[_loc12_].PosY();
               }
               _loc12_++;
            }
         }
         _loc3_ = this._lastCoveredPosition.x - _loc5_;
         _loc4_ = this._lastCoveredPosition.x + _loc5_;
         _loc1_ = this._lastCoveredPosition.y - _loc6_;
         _loc2_ = Number(this._lastCoveredPosition.y);
         var _loc7_:* = 0;
         while(_loc7_ < this._players.length)
         {
            if(!this._players[_loc7_].CameraIgnore)
            {
               if(this._players[_loc7_].PosX() + _loc5_ > _loc4_)
               {
                  _loc4_ = this._players[_loc7_].PosX() + _loc5_;
               }
               if(this._players[_loc7_].PosX() - _loc5_ < _loc3_)
               {
                  _loc3_ = this._players[_loc7_].PosX() - _loc5_;
               }
               if(this._players[_loc7_].PosY() > _loc2_)
               {
                  _loc2_ = Number(this._players[_loc7_].PosY());
               }
               if(this._players[_loc7_].PosY() - _loc6_ < _loc1_)
               {
                  _loc1_ = this._players[_loc7_].PosY() - _loc6_;
               }
            }
            _loc7_++;
         }
         var _loc8_:Rectangle = new Rectangle(_loc3_,_loc1_,_loc4_ - _loc3_,_loc2_ - _loc1_);
         var _loc9_:Number = _loc8_.width / 4;
         var _loc10_:Number = _loc8_.height / 3;
         var _loc11_:Number = 0;
         if(_loc9_ < _loc10_)
         {
            _loc11_ = _loc10_ - _loc9_;
            _loc13_ = _loc11_ * 4;
            _loc8_.x -= _loc13_ / 2;
            _loc8_.width += _loc13_;
         }
         else if(_loc9_ > _loc10_)
         {
            _loc11_ = _loc9_ - _loc10_;
            _loc14_ = _loc11_ * 3;
            _loc8_.y -= _loc14_ / 2;
            _loc8_.height += _loc14_;
         }
         return _loc8_;
      }
      
      public function RecalculateCamArea(param1:int = 8, param2:Boolean = false) : void
      {
         this._Handler_Camera.RecalculateCamArea(param1,param2);
      }
      
      public function get RoundOver() : Boolean
      {
         return Boolean(this._roundOver) && this._roundOverTimer <= 0;
      }
      
      public function Update(param1:Number) : void
      {
         var _loc2_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         if(!this._playersInitialized)
         {
            _loc7_ = 0;
            while(_loc7_ < this._playerSetupData.totalPlayers)
            {
               this._players[_loc7_].Initialize(new PlayerAreaData(this._MapArea));
               _loc7_++;
            }
            this._Handler_Camera.Initialize();
            this._playersInitialized = true;
         }
         _loc2_ = 0;
         while(_loc2_ < this._players_left.length)
         {
            this._players_left[_loc2_] = false;
            _loc2_++;
         }
         var _loc3_:int = 0;
         var _loc4_:int = -1;
         var _loc5_:int = -1;
         var _loc6_:int = 0;
         while(_loc6_ < this._players.length)
         {
            this._players[_loc6_].Update(param1);
            if(this._players[_loc6_].State.HP > 0)
            {
               if(this._players[_loc6_].Team < 0)
               {
                  this._players_left[0] = true;
                  _loc3_++;
                  _loc5_ = 0;
                  _loc4_ = _loc6_;
               }
               else
               {
                  _loc5_ = int(this._players[_loc6_].Team);
                  this._players_left[this._players[_loc6_].Team] = true;
               }
            }
            _loc6_++;
         }
         if(!this._roundOver)
         {
            if(_loc3_ <= 1)
            {
               _loc8_ = 0;
               _loc2_ = 0;
               while(_loc2_ < this._players_left.length)
               {
                  if(this._players_left[_loc2_] == true)
                  {
                     _loc8_++;
                  }
                  _loc2_++;
               }
               if(_loc8_ <= 1)
               {
                  this._roundOver = true;
               }
            }
         }
         else if(this._roundOverTimer > 0)
         {
            this._roundOverTimer -= param1;
            if(this._roundOverTimer <= 0)
            {
               this._team_winner = _loc5_;
               this._solo_nr_winner = _loc4_;
            }
         }
         --this._cameraUpdateTimer;
         if(this._cameraUpdateTimer <= 0)
         {
            this.RecalculateCamArea();
            this._cameraUpdateTimer = 6;
         }
      }
      
      public function GetSoloWinner() : int
      {
         return this._players[this._solo_nr_winner].Team;
      }
      
      public function GetTeamWinner() : int
      {
         return this._team_winner;
      }
      
      public function GetPlayerNrWinner() : int
      {
         return this._solo_nr_winner;
      }
   }
}

