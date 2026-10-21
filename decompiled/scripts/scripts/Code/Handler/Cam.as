package Code.Handler
{
   import flash.display.MovieClip;
   import flash.geom.*;
   
   public class Cam
   {
      
      public static const sizeIncrease:Number = 40;
      
      private var _dynamic_mc:MovieClip;
      
      private var _gui_holder_mc:MovieClip;
      
      private var _menu_mc:MovieClip;
      
      private var _Handler_Output:OutputTrace;
      
      private var _Handler_Keyboard:InputKeyboard;
      
      private var _Handler_Players:PlayersKeeper;
      
      private var _speedX:Number = 0;
      
      private var _speedY:Number = 0;
      
      private var _mapArea:Rectangle;
      
      private var _stage:*;
      
      private var _scaleTarget:Number = 1;
      
      private var _posTarget:Point = new Point(0,0);
      
      private var _scaleSpeed:Number = 0;
      
      private var _posSpeed:Point = new Point(0,0);
      
      private var _zoomStepsLeft:Number = 0;
      
      private var _camArea:Rectangle = new Rectangle();
      
      private var _showAll:Boolean = false;
      
      private var _extraScreenToVanish:Number = 0;
      
      private var _fullScreenMode:Boolean = false;
      
      private var _fullScreenDivider:Number = 0;
      
      private var _screenWidth:Number;
      
      private var _screenHeight:Number;
      
      private var __cam_override_done:Boolean = true;
      
      public function Cam(param1:*, param2:MovieClip, param3:MovieClip, param4:MovieClip, param5:OutputTrace, param6:PlayersKeeper)
      {
         super();
         this._stage = param1;
         this._dynamic_mc = param2;
         this._gui_holder_mc = param3;
         this._menu_mc = param4;
         this._Handler_Output = param5;
         this._Handler_Players = param6;
      }
      
      public function get MapArea() : Rectangle
      {
         return this._mapArea;
      }
      
      public function set ShowAll(param1:Boolean) : void
      {
         this._showAll = param1;
      }
      
      public function get ShowAll() : Boolean
      {
         return this._showAll;
      }
      
      public function SetMapArea(param1:Rectangle) : void
      {
         this._mapArea = param1;
         this._Handler_Players.SetMapArea(param1);
         this.RecalculateCamArea();
      }
      
      public function SetScreenResulotion(param1:Number = 800, param2:Number = 600) : void
      {
         this._screenWidth = param1;
         this._screenHeight = param2;
         if(param2 < 768)
         {
            this._fullScreenMode = false;
         }
         else
         {
            this._fullScreenMode = true;
            switch(param2)
            {
               case 768:
                  this._fullScreenDivider = 500;
                  break;
               case 1050:
                  this._fullScreenDivider = 250;
                  break;
               default:
                  this._fullScreenDivider = 250 + (1050 - param2) * (1 / 1.128);
            }
         }
         this._extraScreenToVanish = param2 - 600;
         this._gui_holder_mc.scaleX = param1 / 800;
         this._gui_holder_mc.scaleY = param2 / 600;
         this._gui_holder_mc.x = -(param1 - 800) / 2;
         this._gui_holder_mc.y = -(param2 - 600) / 2;
         this._menu_mc.scaleX = param1 / 800;
         this._menu_mc.scaleY = param2 / 600;
         this._menu_mc.x = -(param1 - 800) / 2;
         this._menu_mc.y = -(param2 - 600) / 2;
         Achievements.Position(param1 / 800,param2 / 600,-(param1 - 800) / 2,-(param2 - 600) / 2);
         this._Handler_Output.Trace("Your resulotion: " + param1 + "x" + param2);
         this.RecalculateCamArea(1);
      }
      
      public function RecalculateCamArea(param1:int = 8, param2:Boolean = false) : void
      {
         var _loc3_:Rectangle = null;
         var _loc7_:Number = NaN;
         if(!param2)
         {
            if(!this.__cam_override_done)
            {
               return;
            }
         }
         else
         {
            this.__cam_override_done = false;
         }
         if(!this._showAll)
         {
            _loc3_ = this._Handler_Players.GetCamArea();
         }
         else
         {
            _loc3_ = new Rectangle(this._mapArea.x,this._mapArea.y,this._mapArea.width,this._mapArea.height);
         }
         var _loc4_:Number = sizeIncrease * 4;
         var _loc5_:Number = sizeIncrease * 3;
         _loc3_.x -= _loc4_ / 2;
         _loc3_.y -= _loc5_ / 2;
         _loc3_.width += _loc4_;
         _loc3_.height += _loc5_;
         if(_loc3_.width > this._mapArea.width)
         {
            _loc3_.width = this._mapArea.width;
         }
         if(_loc3_.height > this._mapArea.height)
         {
            _loc3_.height = this._mapArea.height;
         }
         if(_loc3_.x < this._mapArea.x)
         {
            _loc3_.x = this._mapArea.x;
         }
         if(_loc3_.x + _loc3_.width > this._mapArea.x + this._mapArea.width)
         {
            _loc3_.x = this._mapArea.x + this._mapArea.width - _loc3_.width;
         }
         if(_loc3_.y < this._mapArea.y)
         {
            _loc3_.y = this._mapArea.y;
         }
         if(_loc3_.y + _loc3_.height > this._mapArea.y + this._mapArea.height)
         {
            _loc3_.y = this._mapArea.y + this._mapArea.height - _loc3_.height;
         }
         var _loc6_:Number = 1 / (_loc3_.height / 600);
         if(this._fullScreenMode)
         {
            _loc7_ = this._extraScreenToVanish * (1 / _loc6_);
            _loc4_ = _loc7_ / 3 * 4;
            _loc5_ = _loc7_;
            _loc3_.x += _loc4_ / 4;
            _loc3_.y += _loc5_ / 4;
            _loc3_.width -= _loc4_;
            _loc3_.height -= _loc5_;
            _loc6_ = 1 / (_loc3_.height / this._fullScreenDivider);
         }
         this._scaleTarget = _loc6_;
         this._posTarget.x = -_loc3_.x * _loc6_;
         this._posTarget.y = -_loc3_.y * _loc6_;
         this._camArea = _loc3_;
         this._zoomStepsLeft = param1;
         this._posSpeed.x = (this._posTarget.x - this._dynamic_mc.x) / this._zoomStepsLeft;
         this._posSpeed.y = (this._posTarget.y - this._dynamic_mc.y) / this._zoomStepsLeft;
         this._scaleSpeed = (this._scaleTarget - this._dynamic_mc.scaleX) / this._zoomStepsLeft;
      }
      
      public function IsInside(param1:Point) : Boolean
      {
         return true;
      }
      
      public function Initialize() : void
      {
         this.SetScreenResulotion(this._stage.stageWidth,this._stage.stageHeight);
      }
      
      public function Update(param1:Number) : void
      {
         if(this._zoomStepsLeft > 0)
         {
            this._dynamic_mc.x += this._posSpeed.x * param1;
            this._dynamic_mc.y += this._posSpeed.y * param1;
            this._dynamic_mc.scaleX += this._scaleSpeed * param1;
            this._dynamic_mc.scaleY += this._scaleSpeed * param1;
            this._zoomStepsLeft -= 1 * param1;
            if(this._zoomStepsLeft <= 0)
            {
               this.__cam_override_done = true;
            }
         }
      }
   }
}

