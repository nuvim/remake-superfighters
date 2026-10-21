package Code.Handler
{
   import flash.events.*;
   import flash.geom.Point;
   
   public class InputMouse
   {
      
      private var _stage:*;
      
      private var _mouseDown:Boolean = false;
      
      private var _mouseX:Number = 0;
      
      private var _mouseY:Number = 0;
      
      public function InputMouse(param1:*)
      {
         super();
         this._stage = param1;
         this._stage.addEventListener(MouseEvent.MOUSE_DOWN,this.mouseDownHandler);
         this._stage.addEventListener(MouseEvent.MOUSE_UP,this.mouseUpHandler);
      }
      
      public function UpdateMouse(param1:Point, param2:Number) : void
      {
         var _loc3_:Number = 1 / param2;
         this._mouseX = _loc3_ * (this._stage.mouseX - param1.x);
         this._mouseY = _loc3_ * (this._stage.mouseY - param1.y);
      }
      
      private function mouseDownHandler(param1:MouseEvent) : void
      {
         this._mouseDown = true;
      }
      
      private function mouseUpHandler(param1:MouseEvent) : void
      {
         this._mouseDown = false;
      }
      
      public function MouseIsDown() : Boolean
      {
         return this._mouseDown;
      }
      
      public function MouseX() : Number
      {
         return this._mouseX;
      }
      
      public function MouseY() : Number
      {
         return this._mouseY;
      }
   }
}

