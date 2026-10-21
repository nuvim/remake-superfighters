package Code.Handler
{
   import Code.Data.*;
   import Code.Data.Players.*;
   import flash.display.*;
   
   public class Scoreboard
   {
      
      private var _teams:Array;
      
      private var _score_graphic:MovieClip;
      
      private var _mostPlayers:int;
      
      private var _gameMode:int;
      
      private var _score_info:MovieClip;
      
      public var RoundsFinished:int;
      
      public function Scoreboard(param1:MovieClip, param2:int)
      {
         super();
         this._score_graphic = new MovieClip();
         param1.addChild(this._score_graphic);
         this._teams = new Array();
         this.RoundsFinished = 0;
         this._gameMode = param2;
      }
      
      public function get GameFinished() : Boolean
      {
         var _loc1_:int = 0;
         switch(this._gameMode)
         {
            case 1:
               return false;
            case 2:
               return this.FirstToReach(3);
            case 3:
               return this.FirstToReach(5);
            case 4:
               return this.FirstToReach(10);
            case 5:
               return this.BestOfReach(3);
            case 6:
               return this.BestOfReach(5);
            case 7:
               return this.BestOfReach(10);
            case 8:
               return this.FirstToReach(1);
            default:
               return false;
         }
      }
      
      private function BestOfReach(param1:int) : Boolean
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         if(this.RoundsFinished >= param1)
         {
            return true;
         }
         _loc2_ = 0;
         _loc4_ = 1;
         while(_loc4_ < this._teams.length)
         {
            if(this._teams[_loc4_].Wins > this._teams[_loc2_].Wins)
            {
               _loc2_ = _loc4_;
            }
            _loc4_++;
         }
         if(_loc2_ != 0)
         {
            _loc3_ = 0;
         }
         else
         {
            _loc3_ = 1;
         }
         _loc4_ = 1;
         while(_loc4_ < this._teams.length)
         {
            if(this._teams[_loc4_].Wins > this._teams[_loc3_].Wins && _loc4_ != _loc2_)
            {
               _loc3_ = _loc4_;
            }
            _loc4_++;
         }
         var _loc5_:int = this._teams[_loc2_].Wins - this._teams[_loc3_].Wins;
         var _loc6_:int = param1 - this.RoundsFinished;
         if(_loc5_ > _loc6_)
         {
            return true;
         }
         return false;
      }
      
      private function FirstToReach(param1:int) : Boolean
      {
         var _loc2_:int = 0;
         while(_loc2_ < this._teams.length)
         {
            if(this._teams[_loc2_].Wins >= param1)
            {
               return true;
            }
            _loc2_++;
         }
         return false;
      }
      
      public function AddPlayerToScore(param1:Player) : void
      {
         var _loc2_:int = 0;
         while(_loc2_ < this._teams.length)
         {
            if(this._teams[_loc2_].Team == param1.Team)
            {
               this._teams[_loc2_].AddPlayer(param1);
               return;
            }
            _loc2_++;
         }
         this._teams.push(new ScoreboardTeam(param1));
      }
      
      public function Build() : void
      {
         this._score_graphic = new MovieClip();
         this._mostPlayers = 0;
         var _loc1_:int = 0;
         while(_loc1_ < this._teams.length)
         {
            if(this._teams[_loc1_].TotalPlayers > this._mostPlayers)
            {
               this._mostPlayers = this._teams[_loc1_].TotalPlayers;
            }
            _loc1_++;
         }
         var _loc2_:int = 0;
         while(_loc2_ < this._teams.length)
         {
            this._teams[_loc2_].Build(this._mostPlayers);
            this._score_graphic.addChild(this._teams[_loc2_].MC);
            _loc2_++;
         }
         this._score_info = new score_info();
         this._score_graphic.addChild(this._score_info);
         this._score_info.game_mode.gotoAndStop(this._gameMode);
         this._score_info.rounds.text = "0";
      }
      
      public function Update() : void
      {
         var _loc1_:int = 0;
         var _loc2_:Array = null;
         var _loc4_:int = 0;
         _loc2_ = this._teams.sortOn(["Wins","Loss"],Array.NUMERIC | Array.DESCENDING | Array.RETURNINDEXEDARRAY);
         this._score_info.rounds.text = this.RoundsFinished.toString();
         var _loc3_:Number = 45;
         _loc1_ = 0;
         while(_loc1_ < _loc2_.length)
         {
            _loc4_ = int(_loc2_[_loc1_]);
            if(this._teams.length <= 4)
            {
               this._teams[_loc4_].MC.x = 400 - this.GetScoreWidth() / 2;
               this._teams[_loc4_].MC.y = 300 - 75 * this._teams.length / 2 + 75 * _loc1_ + _loc3_;
            }
            else if(_loc1_ < 4)
            {
               this._teams[_loc4_].MC.x = 400 - this.GetScoreWidth();
               this._teams[_loc4_].MC.y = 300 - 75 * 4 / 2 + 75 * _loc1_ + _loc3_;
            }
            else
            {
               this._teams[_loc4_].MC.x = 400;
               this._teams[_loc4_].MC.y = 300 - 75 * 4 / 2 + 75 * (_loc1_ - 4) + _loc3_;
            }
            _loc1_++;
         }
         this._score_info.x = this._teams[_loc2_[0]].MC.x;
         this._score_info.y = this._teams[_loc2_[0]].MC.y - 20;
         _loc1_ = 0;
         while(_loc1_ < this._teams.length)
         {
            this._teams[_loc1_].Update();
            _loc1_++;
         }
      }
      
      public function GetTeamWinner() : ScoreboardTeam
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         _loc1_ = 0;
         _loc3_ = 1;
         while(_loc3_ < this._teams.length)
         {
            if(this._teams[_loc3_].Wins > this._teams[_loc1_].Wins)
            {
               _loc1_ = _loc3_;
            }
            _loc3_++;
         }
         if(_loc1_ != 0)
         {
            _loc2_ = 0;
         }
         else
         {
            _loc2_ = 1;
         }
         _loc3_ = 1;
         while(_loc3_ < this._teams.length)
         {
            if(this._teams[_loc3_].Wins > this._teams[_loc2_].Wins && _loc3_ != _loc1_)
            {
               _loc2_ = _loc3_;
            }
            _loc3_++;
         }
         if(this._teams[_loc1_].Wins == this._teams[_loc2_].Wins)
         {
            return null;
         }
         return this._teams[_loc1_];
      }
      
      private function GetScoreWidth() : Number
      {
         switch(this._mostPlayers)
         {
            case 1:
            case 2:
            case 3:
            case 4:
               return 320;
            case 5:
               return 370;
            case 6:
               return 420;
            case 7:
               return 470;
            default:
               return 470;
         }
      }
      
      public function ScoreTeam(param1:int) : void
      {
         var _loc2_:int = 0;
         while(_loc2_ < this._teams.length)
         {
            if(this._teams[_loc2_].Team == param1)
            {
               this._teams[_loc2_].Wins += 1;
            }
            else
            {
               this._teams[_loc2_].Loss += 1;
            }
            _loc2_++;
         }
      }
      
      public function Show() : void
      {
         this._score_graphic.visible = true;
      }
      
      public function Hide() : void
      {
         this._score_graphic.visible = false;
      }
      
      public function get MC() : MovieClip
      {
         return this._score_graphic;
      }
   }
}

