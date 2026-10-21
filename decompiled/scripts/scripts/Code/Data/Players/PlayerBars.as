package Code.Data.Players
{
   import flash.display.*;
   import flash.geom.ColorTransform;
   
   public class PlayerBars
   {
      
      public static var PLAYER_COM:int = 0;
      
      public static var PLAYER_1:int = 1;
      
      public static var PLAYER_2:int = 2;
      
      private var _sprint_bar:MovieClip;
      
      private var _sprint_energy_bar:MovieClip;
      
      private var _health_bar:MovieClip;
      
      private var _health_energy_bar:MovieClip;
      
      private var _PlayerState:PlayerState;
      
      private var _player_sign:MovieClip;
      
      private var _showBars:Boolean;
      
      private var _gui_mc:MovieClip;
      
      private var _gui_bars_mc:MovieClip;
      
      private var _player_sign_text:Boolean = false;
      
      public function PlayerBars(param1:PlayerState, param2:MovieClip)
      {
         super();
         this._PlayerState = param1;
         this._health_bar = new MovieClip();
         var _loc3_:Sprite = new Sprite();
         _loc3_.graphics.lineStyle(0.25,0,0);
         _loc3_.graphics.beginFill(0,1);
         _loc3_.graphics.moveTo(-10,0);
         _loc3_.graphics.lineTo(-10,-2);
         _loc3_.graphics.lineTo(10,-2);
         _loc3_.graphics.lineTo(10,0);
         _loc3_.graphics.lineTo(-10,0);
         _loc3_.graphics.endFill();
         this._health_energy_bar = new MovieClip();
         this._health_energy_bar.graphics.lineStyle(1,this.GetColor(255,255,255),0);
         this._health_energy_bar.graphics.beginFill(this.GetColor(255,255,255),1);
         this._health_energy_bar.graphics.moveTo(0,0);
         this._health_energy_bar.graphics.lineTo(0,-2);
         this._health_energy_bar.graphics.lineTo(20,-2);
         this._health_energy_bar.graphics.lineTo(20,0);
         this._health_energy_bar.graphics.lineTo(0,0);
         this._health_energy_bar.graphics.endFill();
         this._health_energy_bar.x = -10;
         this._health_bar.addChild(_loc3_);
         this._health_bar.addChild(this._health_energy_bar);
         this._health_bar.alpha = 0.5;
         this._sprint_bar = new MovieClip();
         var _loc4_:Sprite = new Sprite();
         _loc4_.graphics.lineStyle(0.25,0,0);
         _loc4_.graphics.beginFill(0,1);
         _loc4_.graphics.moveTo(-10,0);
         _loc4_.graphics.lineTo(-10,-2);
         _loc4_.graphics.lineTo(10,-2);
         _loc4_.graphics.lineTo(10,0);
         _loc4_.graphics.lineTo(-10,0);
         _loc4_.graphics.endFill();
         this._sprint_energy_bar = new MovieClip();
         this._sprint_energy_bar.graphics.lineStyle(1,this.GetColor(255,255,255),0);
         this._sprint_energy_bar.graphics.beginFill(this.GetColor(255,255,255),1);
         this._sprint_energy_bar.graphics.moveTo(0,0);
         this._sprint_energy_bar.graphics.lineTo(0,-2);
         this._sprint_energy_bar.graphics.lineTo(20,-2);
         this._sprint_energy_bar.graphics.lineTo(20,0);
         this._sprint_energy_bar.graphics.lineTo(0,0);
         this._sprint_energy_bar.graphics.endFill();
         this._sprint_energy_bar.x = -10;
         this._sprint_bar.addChild(_loc4_);
         this._sprint_bar.addChild(this._sprint_energy_bar);
         this._sprint_bar.alpha = 0.5;
         param2.addChild(this._sprint_bar);
         param2.addChild(this._health_bar);
         this._health_bar.visible = false;
         this._player_sign = new player_sign();
         var _loc5_:ColorTransform = this._player_sign.transform.colorTransform;
         if(this._PlayerState.Team < 0)
         {
            _loc5_.redOffset = PlayerTeamColor.SOLO[0] - 255;
            _loc5_.greenOffset = PlayerTeamColor.SOLO[1] - 255;
            _loc5_.blueOffset = PlayerTeamColor.SOLO[2] - 255;
         }
         else
         {
            _loc5_.redOffset = PlayerTeamColor.TEAM[this._PlayerState.Team - 1][0] - 255;
            _loc5_.greenOffset = PlayerTeamColor.TEAM[this._PlayerState.Team - 1][1] - 255;
            _loc5_.blueOffset = PlayerTeamColor.TEAM[this._PlayerState.Team - 1][2] - 255;
         }
         this._player_sign.transform.colorTransform = _loc5_;
         param2.addChild(this._player_sign);
         this._showBars = true;
      }
      
      public function SetGUI(param1:MovieClip) : void
      {
         this._gui_mc = param1;
         this._gui_bars_mc = new MovieClip();
         this._gui_bars_mc.x = this._gui_mc.bars_start.x;
         this._gui_bars_mc.y = this._gui_mc.bars_start.y;
         this._gui_mc.addChild(this._gui_bars_mc);
      }
      
      public function DrawGUIBars() : void
      {
         var _loc1_:Number = this._gui_mc.bars_end.x - this._gui_mc.bars_start.x;
         var _loc2_:Number = 4;
         var _loc3_:Number = 6;
         var _loc4_:Number = this._PlayerState.BarHP / 100;
         this._gui_bars_mc.graphics.clear();
         this._gui_bars_mc.graphics.lineStyle(1,16777215,0);
         this._gui_bars_mc.graphics.beginFill(this.GetColor(255 - Math.round(255 * _loc4_),Math.round(255 * _loc4_),40));
         this._gui_bars_mc.graphics.moveTo(0,0);
         this._gui_bars_mc.graphics.lineTo(0,_loc2_);
         this._gui_bars_mc.graphics.lineTo(_loc1_ * _loc4_,_loc2_);
         this._gui_bars_mc.graphics.lineTo(_loc1_ * _loc4_,0);
         this._gui_bars_mc.graphics.lineTo(0,0);
         this._gui_bars_mc.graphics.endFill();
         if(_loc4_ == 0)
         {
            return;
         }
         _loc4_ = this._PlayerState.SprintEnergy / 100;
         this._gui_bars_mc.graphics.lineStyle(1,16777215,0);
         this._gui_bars_mc.graphics.beginFill(16777215);
         this._gui_bars_mc.graphics.moveTo(0,_loc3_);
         this._gui_bars_mc.graphics.lineTo(0,_loc3_ + _loc2_);
         this._gui_bars_mc.graphics.lineTo(_loc1_ * _loc4_,_loc3_ + _loc2_);
         this._gui_bars_mc.graphics.lineTo(_loc1_ * _loc4_,_loc3_);
         this._gui_bars_mc.graphics.lineTo(0,_loc3_);
         this._gui_bars_mc.graphics.endFill();
      }
      
      public function SetSign(param1:int) : void
      {
         switch(param1)
         {
            case PLAYER_COM:
               this._player_sign.gotoAndStop(3);
               this._gui_mc.sign.gotoAndStop(3);
               this._player_sign_text = false;
               break;
            case PLAYER_1:
               this._player_sign.gotoAndStop(1);
               this._gui_mc.sign.gotoAndStop(1);
               this._player_sign_text = true;
               break;
            case PLAYER_2:
               this._player_sign.gotoAndStop(2);
               this._gui_mc.sign.gotoAndStop(2);
               this._player_sign_text = true;
         }
         this._gui_mc.sign.transform.colorTransform = this._player_sign.transform.colorTransform;
      }
      
      public function Hide() : void
      {
         this._showBars = false;
         this._sprint_bar.visible = false;
         this._health_bar.visible = false;
         this._player_sign.visible = false;
         this._gui_bars_mc.visible = false;
      }
      
      public function Show() : void
      {
         this._showBars = true;
      }
      
      public function Update(param1:Number, param2:Number, param3:Number) : void
      {
         var _loc5_:Number = NaN;
         if(this._PlayerState.HP <= 0)
         {
            this._sprint_bar.visible = false;
            this._health_bar.visible = false;
            this._player_sign.visible = false;
            this._gui_bars_mc.visible = false;
            return;
         }
         this.DrawGUIBars();
         if(!this._PlayerState.ShowHealthBar && this._PlayerState.SprintEnergy >= 100 || Boolean(this._PlayerState.StuckToRocket))
         {
            this._sprint_bar.visible = false;
            this._health_bar.visible = false;
         }
         param2 += 30;
         if(this._PlayerState.Diving)
         {
            param2 -= 14;
         }
         else
         {
            param2 -= 22;
         }
         var _loc4_:Number = 0.5 + 0.5 / param3;
         this._player_sign.x = param1;
         this._player_sign.y = param2 - 30;
         if(this._player_sign_text)
         {
            this._player_sign.scaleX = _loc4_ * 1.3;
            this._player_sign.scaleY = _loc4_ * 1.3;
         }
         else
         {
            this._player_sign.scaleX = _loc4_;
            this._player_sign.scaleY = _loc4_;
         }
         this._player_sign.visible = true;
         if(!this._showBars)
         {
            return;
         }
         if(this._PlayerState.ShowHealthBar)
         {
            this._health_bar.visible = true;
            this._health_bar.scaleX = _loc4_;
            this._health_bar.scaleY = _loc4_;
            _loc5_ = this._PlayerState.BarHP / 100;
            this._health_energy_bar.graphics.clear();
            this._health_energy_bar.graphics.lineStyle(1,16777215,0);
            this._health_energy_bar.graphics.beginFill(this.GetColor(255 - Math.round(255 * _loc5_),Math.round(255 * _loc5_),40));
            this._health_energy_bar.graphics.moveTo(0,0);
            this._health_energy_bar.graphics.lineTo(0,-2);
            this._health_energy_bar.graphics.lineTo(20 * _loc5_,-2);
            this._health_energy_bar.graphics.lineTo(20 * _loc5_,0);
            this._health_energy_bar.graphics.lineTo(0,0);
            this._health_energy_bar.graphics.endFill();
            this._health_energy_bar.x = -10;
            this._health_bar.x = param1;
            this._health_bar.y = param2;
            param2 += 3;
         }
         else
         {
            this._health_bar.visible = false;
         }
         if(this._PlayerState.SprintEnergy >= 100)
         {
            this._sprint_bar.visible = false;
            return;
         }
         this._sprint_bar.visible = true;
         this._sprint_bar.scaleX = _loc4_;
         this._sprint_bar.scaleY = _loc4_;
         _loc5_ = this._PlayerState.SprintEnergy / 100;
         this._sprint_energy_bar.graphics.clear();
         this._sprint_energy_bar.graphics.lineStyle(1,16777215,0);
         this._sprint_energy_bar.graphics.beginFill(16777215);
         this._sprint_energy_bar.graphics.moveTo(0,0);
         this._sprint_energy_bar.graphics.lineTo(0,-2);
         this._sprint_energy_bar.graphics.lineTo(20 * _loc5_,-2);
         this._sprint_energy_bar.graphics.lineTo(20 * _loc5_,0);
         this._sprint_energy_bar.graphics.lineTo(0,0);
         this._sprint_energy_bar.graphics.endFill();
         this._sprint_energy_bar.x = -10;
         this._sprint_bar.x = param1;
         this._sprint_bar.y = param2;
      }
      
      private function GetColor(param1:Number, param2:Number, param3:Number) : uint
      {
         return uint(param1 << 16 | param2 << 8 | param3);
      }
   }
}

