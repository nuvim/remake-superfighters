package Code.Handler
{
   import Code.Data.SlowmoData;
   import fl.motion.*;
   import flash.display.MovieClip;
   import flash.events.*;
   
   public class Slowmo
   {
      
      private var _Handler_Output:OutputTrace;
      
      private var _Handler_Effects:Effects;
      
      private var _Handler_Sounds:Sounds;
      
      private var _stage:*;
      
      private var _currSlowmoFactor:Number;
      
      private var _slowmotionArray:Array;
      
      private var _slomo_rectangle:MovieClip;
      
      private var _brightness:Number = 0;
      
      private var _curve:Number = 0;
      
      private var _heartbeatTimer:int;
      
      private var _gamePaused:Boolean = false;
      
      public function Slowmo(param1:OutputTrace, param2:Effects, param3:Sounds, param4:MovieClip, param5:*)
      {
         super();
         this._Handler_Output = param1;
         this._Handler_Effects = param2;
         this._Handler_Sounds = param3;
         this._slomo_rectangle = param4;
         this._stage = param5;
         this._heartbeatTimer = 0;
         this._stage.addEventListener(Event.RESIZE,this.OnStageResize);
         this.DrawRectangle(this._stage.stageWidth,this._stage.stageHeight);
         this._slowmotionArray = new Array();
         this._currSlowmoFactor = 1;
      }
      
      public function set GamePaused(param1:Boolean) : void
      {
         this._gamePaused = param1;
         if(param1)
         {
            this._Handler_Effects.SetSlowmotion(0);
         }
         else
         {
            this._Handler_Effects.SetSlowmotion(this._currSlowmoFactor);
         }
      }
      
      public function Stop() : void
      {
         this._stage.removeEventListener(Event.RESIZE,this.OnStageResize);
      }
      
      private function OnStageResize(param1:Event) : void
      {
         this.DrawRectangle(this._stage.stageWidth,this._stage.stageHeight);
      }
      
      private function DrawRectangle(param1:Number, param2:Number) : void
      {
         this._slomo_rectangle.graphics.clear();
         this._slomo_rectangle.graphics.moveTo(0,0);
         this._slomo_rectangle.graphics.beginFill(16777215);
         this._slomo_rectangle.graphics.lineTo(param1 + 1,0);
         this._slomo_rectangle.graphics.lineTo(param1 + 1,param2 + 1);
         this._slomo_rectangle.graphics.lineTo(0,param2 + 1);
         this._slomo_rectangle.graphics.lineTo(0,0);
         this._slomo_rectangle.graphics.endFill();
         this.SetAlpha(this._slomo_rectangle,this._brightness);
         this._slomo_rectangle.x = -(param1 - 800) * 0.5;
         this._slomo_rectangle.y = -(param2 - 600) * 0.5;
      }
      
      public function AddSlowmotion(param1:SlowmoData, param2:Boolean = false, param3:int = -1) : void
      {
         this._slowmotionArray.push([param1,param2,param3]);
         if(param2)
         {
            this._brightness = 1;
         }
      }
      
      public function RemoveSlowmotion(param1:int) : void
      {
         var _loc2_:* = int(this._slowmotionArray.length - 1);
         while(_loc2_ >= 0)
         {
            if(this._slowmotionArray[_loc2_][2] == param1)
            {
               this._slowmotionArray.splice(_loc2_,1);
            }
            _loc2_--;
         }
      }
      
      public function Update() : void
      {
         if(this._gamePaused)
         {
            return;
         }
         var _loc1_:Number = Number(this._currSlowmoFactor);
         var _loc2_:* = int(this._slowmotionArray.length - 1);
         while(_loc2_ >= 0)
         {
            this._slowmotionArray[_loc2_][0].ProgressTime();
            if(this._slowmotionArray[_loc2_][0].Completed)
            {
               this._slowmotionArray.splice(_loc2_,1);
            }
            _loc2_--;
         }
         var _loc3_:Boolean = false;
         this._currSlowmoFactor = 1;
         var _loc4_:int = 0;
         while(_loc4_ < this._slowmotionArray.length)
         {
            if(this._slowmotionArray[_loc4_][0].CurrentSlowmotion < this._currSlowmoFactor)
            {
               this._currSlowmoFactor = this._slowmotionArray[_loc4_][0].CurrentSlowmotion;
            }
            if(this._slowmotionArray[_loc4_][1] == true)
            {
               _loc3_ = true;
            }
            _loc4_++;
         }
         if(_loc3_)
         {
            --this._heartbeatTimer;
            if(this._heartbeatTimer <= 0)
            {
               this._heartbeatTimer = 28;
               this._Handler_Sounds.PlaySound("HEARTBEAT",0,0);
            }
            if(this._brightness > 0.18)
            {
               this._brightness -= 0.08;
               if(this._brightness < 0.18)
               {
                  this._brightness = 0.18;
                  this._curve = Math.PI / 2;
               }
            }
            else
            {
               this._curve += 0.13;
               if(this._curve > Math.PI)
               {
                  this._curve = 0;
               }
               this._brightness = 0.12 + Math.sin(this._curve) * 0.06;
            }
            this.SetAlpha(this._slomo_rectangle,this._brightness);
         }
         else if(this._brightness != 0)
         {
            if(this._brightness > 0)
            {
               this._brightness -= 0.02;
               if(this._brightness < 0)
               {
                  this._brightness = 0;
               }
            }
            else if(this._brightness < 0)
            {
               this._brightness += 0.02;
               if(this._brightness > 0)
               {
                  this._brightness = 0;
               }
            }
            this.SetAlpha(this._slomo_rectangle,this._brightness);
         }
         if(_loc1_ != this._currSlowmoFactor)
         {
            this._Handler_Output.Trace("Slowmotion: " + Math.round(this._currSlowmoFactor * 100) / 100);
            this._Handler_Effects.SetSlowmotion(this._currSlowmoFactor);
         }
      }
      
      public function get Slowmotion() : Number
      {
         if(this._gamePaused)
         {
            return 0;
         }
         return this._currSlowmoFactor;
      }
      
      private function SetAlpha(param1:MovieClip, param2:Number) : void
      {
         param1.alpha = param2;
      }
      
      private function SetBrightness(param1:MovieClip, param2:Number) : void
      {
         var _loc3_:Color = new Color();
         _loc3_.brightness = param2;
         param1.transform.colorTransform = _loc3_;
      }
   }
}

