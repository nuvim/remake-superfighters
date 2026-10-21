package Code.Data
{
   import Code.Data.Players.*;
   import flash.display.*;
   import flash.geom.ColorTransform;
   import flash.utils.*;
   
   public class ScoreboardTeam
   {
      
      private var _team:int;
      
      private var _players:Array;
      
      private var _team_graphic:MovieClip;
      
      private var _build_timer:Number;
      
      public var Wins:int;
      
      public var Loss:int;
      
      public function ScoreboardTeam(param1:Player)
      {
         super();
         this.Wins = 0;
         this.Loss = 0;
         this._team = param1.Team;
         this._players = new Array();
         this._players.push(param1);
      }
      
      public function get Team() : int
      {
         return this._team;
      }
      
      public function get TotalPlayers() : int
      {
         return this._players.length;
      }
      
      public function get FirstPlayer() : Player
      {
         return this._players[0];
      }
      
      public function AddPlayer(param1:Player) : void
      {
         this._players.push(param1);
      }
      
      private function SetNumTo(param1:MovieClip, param2:int) : void
      {
         var _loc3_:int = param2 % 10;
         var _loc4_:int = int((param2 - _loc3_) / 10);
         if(_loc3_ == 0)
         {
            param1.dig_1.gotoAndStop(10);
         }
         else
         {
            param1.dig_1.gotoAndStop(_loc3_);
         }
         if(_loc4_ == 0)
         {
            param1.dig_10.gotoAndStop(10);
         }
         else
         {
            param1.dig_10.gotoAndStop(_loc4_);
         }
      }
      
      public function Update() : void
      {
         this.SetNumTo(this._team_graphic.score.wins,this.Wins);
         this.SetNumTo(this._team_graphic.score.loss,this.Loss);
      }
      
      public function Build(param1:int) : void
      {
         this._team_graphic = new score_team_plate();
         this._team_graphic.gotoAndStop(param1);
         this._team_graphic.pics.gotoAndStop(this.TotalPlayers);
         if(this.TotalPlayers <= 4 && param1 > 4)
         {
            this._team_graphic.pics.x = 25 * (param1 - 4);
         }
         var _loc2_:int = int(this._players[0].Team);
         if(_loc2_ < 0)
         {
            _loc2_ = 5;
         }
         this._team_graphic.pics.team.gotoAndStop(_loc2_);
         var _loc3_:ColorTransform = this._team_graphic.pics.team.transform.colorTransform;
         if(this._players[0].Team < 0)
         {
            _loc3_.redOffset = PlayerTeamColor.SOLO[0] - 255;
            _loc3_.greenOffset = PlayerTeamColor.SOLO[1] - 255;
            _loc3_.blueOffset = PlayerTeamColor.SOLO[2] - 255;
         }
         else
         {
            _loc3_.redOffset = PlayerTeamColor.TEAM[this._players[0].Team - 1][0] - 255;
            _loc3_.greenOffset = PlayerTeamColor.TEAM[this._players[0].Team - 1][1] - 255;
            _loc3_.blueOffset = PlayerTeamColor.TEAM[this._players[0].Team - 1][2] - 255;
         }
         this._team_graphic.pics.team.transform.colorTransform = _loc3_;
         this._build_timer = setInterval(this.SetPics,100);
         this.Update();
      }
      
      public function SetPics() : void
      {
         clearInterval(this._build_timer);
         var _loc1_:int = 0;
         while(_loc1_ < this.TotalPlayers)
         {
            MovieClip(this._team_graphic.pics.getChildByName("pic_" + (_loc1_ + 1))).gotoAndStop(this._players[_loc1_].State.CharNr);
            _loc1_++;
         }
      }
      
      public function get MC() : MovieClip
      {
         return this._team_graphic;
      }
   }
}

