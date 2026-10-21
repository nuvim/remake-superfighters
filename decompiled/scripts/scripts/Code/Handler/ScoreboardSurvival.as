package Code.Handler
{
   import Code.Data.*;
   import Code.Data.Players.*;
   import flash.display.*;
   import flash.utils.*;
   
   public class ScoreboardSurvival
   {
      
      private var _score_info:MovieClip;
      
      private var _players:Array;
      
      private var _build_timer:Number;
      
      private var _personal_best:SurvivalTimePackage;
      
      private var _marker_index:Number = 0;
      
      private var _current_total_score:Number = 0;
      
      private var _showing_final_score:Boolean = false;
      
      public function ScoreboardSurvival(param1:MovieClip)
      {
         super();
         this._players = new Array();
         this._score_info = new survival_score();
         this._score_info.gotoAndStop(1);
         param1.addChild(this._score_info);
         this.UpdateMarker();
      }
      
      public function get MarkerIndex() : Number
      {
         return this._marker_index;
      }
      
      public function get CurrentTotalScore() : Number
      {
         return this._current_total_score;
      }
      
      public function get PlayerCount() : Number
      {
         return this._players.length;
      }
      
      public function UpPressed() : void
      {
         if(this._showing_final_score)
         {
            --this._marker_index;
            if(this._marker_index < 0)
            {
               this._marker_index = 2;
            }
            this.UpdateMarker();
         }
      }
      
      public function DownPressed() : void
      {
         if(this._showing_final_score)
         {
            ++this._marker_index;
            if(this._marker_index > 2)
            {
               this._marker_index = 0;
            }
            this.UpdateMarker();
         }
      }
      
      private function UpdateMarker() : void
      {
         this._score_info.marker_0.visible = this._showing_final_score && this._marker_index == 0;
         this._score_info.marker_1.visible = this._showing_final_score && this._marker_index == 1;
         this._score_info.marker_2.visible = this._showing_final_score && this._marker_index == 2;
      }
      
      public function LoadBest() : SurvivalTimePackage
      {
         var _loc1_:SurvivalTimePackage = new SurvivalTimePackage();
         if(this._players.length == 1 && SaveState.Data.survivalBestMins != undefined && SaveState.Data.survivalBestSecs != undefined && SaveState.Data.survivalBestParts != undefined)
         {
            _loc1_.totalMins = SaveState.Data.survivalBestMins;
            _loc1_.totalSecs = SaveState.Data.survivalBestSecs;
            _loc1_.totalParts = SaveState.Data.survivalBestParts;
            if(SaveState.Data.survivalBestWave)
            {
               _loc1_.wave = SaveState.Data.survivalBestWave;
            }
            if(SaveState.Data.survivalBestKills)
            {
               _loc1_.kills = SaveState.Data.survivalBestKills;
            }
            if(SaveState.Data.survivalBestDmgBonus)
            {
               _loc1_.dmgbonus = SaveState.Data.survivalBestDmgBonus;
            }
         }
         else if(this._players.length == 2 && SaveState.Data.survival2BestMins != undefined && SaveState.Data.survival2BestSecs != undefined && SaveState.Data.survival2BestParts != undefined)
         {
            _loc1_.totalMins = SaveState.Data.survival2BestMins;
            _loc1_.totalSecs = SaveState.Data.survival2BestSecs;
            _loc1_.totalParts = SaveState.Data.survival2BestParts;
            if(SaveState.Data.survival2BestWave)
            {
               _loc1_.wave = SaveState.Data.survival2BestWave;
            }
            if(SaveState.Data.survival2BestKills)
            {
               _loc1_.kills = SaveState.Data.survival2BestKills;
            }
            if(SaveState.Data.survival2BestDmgBonus)
            {
               _loc1_.dmgbonus = SaveState.Data.survival2BestDmgBonus;
            }
         }
         else
         {
            _loc1_.totalMins = 0;
            _loc1_.totalSecs = 0;
            _loc1_.totalParts = 0;
            _loc1_.wave = 0;
            _loc1_.kills = 0;
            _loc1_.dmgbonus = 0;
         }
         return _loc1_;
      }
      
      public function SaveBest(param1:SurvivalTimePackage) : void
      {
         if(this._players.length == 1)
         {
            SaveState.Data.survivalBestMins = param1.totalMins;
            SaveState.Data.survivalBestSecs = param1.totalSecs;
            SaveState.Data.survivalBestParts = param1.totalParts;
            SaveState.Data.survivalBestWave = param1.wave;
            SaveState.Data.survivalBestKills = param1.kills;
            SaveState.Data.survivalBestDmgBonus = param1.dmgbonus;
         }
         else
         {
            SaveState.Data.survival2BestMins = param1.totalMins;
            SaveState.Data.survival2BestSecs = param1.totalSecs;
            SaveState.Data.survival2BestParts = param1.totalParts;
            SaveState.Data.survival2BestWave = param1.wave;
            SaveState.Data.survival2BestKills = param1.kills;
            SaveState.Data.survival2BestDmgBonus = param1.dmgbonus;
         }
         SaveState.Save();
      }
      
      public function BeatPersonal(param1:SurvivalTimePackage) : Boolean
      {
         var _loc2_:Number = Number(SurvivalTimePackage.CalculateTotalScore(this._personal_best));
         var _loc3_:Number = Number(SurvivalTimePackage.CalculateTotalScore(param1));
         if(_loc3_ >= _loc2_)
         {
            return true;
         }
         return false;
      }
      
      public function Build() : void
      {
         this._score_info.players_txt.text = "" + this._players.length;
         this._score_info.pics.gotoAndStop(this._players.length);
         this._personal_best = this.LoadBest();
         this.SetTimer(this._score_info.personal_best,this._personal_best);
         this._build_timer = setInterval(this.SetPics,100);
      }
      
      private function SetPics() : void
      {
         clearInterval(this._build_timer);
         var _loc1_:int = 0;
         while(_loc1_ < this._players.length)
         {
            MovieClip(this._score_info.pics.getChildByName("pic_" + (_loc1_ + 1))).gotoAndStop(this._players[_loc1_].State.CharNr);
            _loc1_++;
         }
      }
      
      public function AddPlayerToScore(param1:Player) : void
      {
         this._players.push(param1);
      }
      
      public function Update(param1:SurvivalTimePackage, param2:Boolean) : void
      {
         this._showing_final_score = param2;
         this._current_total_score = SurvivalTimePackage.CalculateTotalScore(param1);
         this.SetTimer(this._score_info.current,param1);
         if(param2 && this.BeatPersonal(param1))
         {
            this.SaveBest(param1);
            this._personal_best.totalMins = param1.totalMins;
            this._personal_best.totalSecs = param1.totalSecs;
            this._personal_best.totalParts = param1.totalParts;
            this._personal_best.wave = param1.wave;
            this._personal_best.kills = param1.kills;
            this._personal_best.dmgbonus = param1.dmgbonus;
            this._score_info.gotoAndStop(2);
            this.SetTimer(this._score_info.personal_best,this._personal_best);
         }
         this.UpdateLayout();
      }
      
      private function UpdateLayout() : void
      {
         if(this._showing_final_score)
         {
            this._score_info.btn_txt_submit.visible = true;
            this._score_info.btn_txt_highscores.visible = true;
            this._score_info.btn_txt_main_menu.visible = true;
         }
         else
         {
            this._score_info.btn_txt_submit.visible = false;
            this._score_info.btn_txt_highscores.visible = false;
            this._score_info.btn_txt_main_menu.visible = false;
         }
         this.UpdateMarker();
      }
      
      private function SetTimer(param1:MovieClip, param2:SurvivalTimePackage) : void
      {
         var _loc3_:String = param2.totalMins + "";
         var _loc4_:String = param2.totalSecs + "";
         var _loc5_:String = param2.totalParts + "";
         if(param2.totalMins < 10)
         {
            _loc3_ = "0" + _loc3_;
         }
         if(param2.totalSecs < 10)
         {
            _loc4_ = "0" + _loc4_;
         }
         if(param2.totalParts < 10)
         {
            _loc5_ = "0" + _loc5_;
         }
         param1.time_txt.text = _loc3_ + ":" + _loc4_ + ":" + _loc5_;
         if(param2.wave < 10)
         {
            param1.wave_txt.text = "0" + param2.wave;
         }
         else
         {
            param1.wave_txt.text = "" + param2.wave;
         }
         param1.kills_txt.text = param2.kills + "";
         param1.dmgbonus_txt.text = param2.dmgbonus + "";
         param1.time_score_txt.text = SurvivalTimePackage.CalculateTimeScore(param2) + "";
         param1.wave_score_txt.text = SurvivalTimePackage.CalculateWaveScore(param2) + "";
         param1.kills_score_txt.text = SurvivalTimePackage.CalculateKillsScore(param2) + "";
         param1.dmgbonus_score_txt.text = SurvivalTimePackage.CalculateDmgBonusScore(param2) + "";
         param1.total_score_txt.text = SurvivalTimePackage.CalculateTotalScore(param2) + "";
      }
      
      public function Show() : void
      {
         this._score_info.visible = true;
      }
      
      public function Hide() : void
      {
         this._score_info.visible = false;
      }
      
      public function get MC() : MovieClip
      {
         return this._score_info;
      }
   }
}

