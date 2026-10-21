package Code.Data
{
   import Code.Box2D.Common.Math.*;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   public class PortalData
   {
      
      private var _portal:Rectangle;
      
      private var _targetPortal:Rectangle;
      
      private var _triggerVelocity:Point;
      
      private var _inverseX:Boolean = false;
      
      private var _inverseY:Boolean = false;
      
      private var _allowPlayers:Boolean = true;
      
      public function PortalData(param1:Rectangle, param2:Rectangle, param3:Point, param4:Boolean, param5:Boolean)
      {
         super();
         this._portal = param1;
         this._targetPortal = param2;
         this._triggerVelocity = param3;
         this._inverseX = param4;
         this._inverseY = param5;
      }
      
      public function get InverseX() : Boolean
      {
         return this._inverseX;
      }
      
      public function get InverseY() : Boolean
      {
         return this._inverseY;
      }
      
      public function get TriggerVelocity() : Point
      {
         return this._triggerVelocity;
      }
      
      public function GetTargetPositionFromCurrent(param1:Number, param2:Number) : b2Vec2
      {
         return new b2Vec2((this._targetPortal.x + this._targetPortal.width / 2) / 30,(this._targetPortal.y + param2 - this._portal.y) / 30);
      }
      
      public function set AllowPlayers(param1:Boolean) : void
      {
         this._allowPlayers = param1;
      }
      
      public function get AllowPlayers() : Boolean
      {
         return this._allowPlayers;
      }
      
      public function GetSideOfPortal(param1:int) : Number
      {
         if(param1 == -1)
         {
            return this._portal.x;
         }
         return this._portal.x + this._portal.width;
      }
      
      public function PointInsidePortal(param1:Number, param2:Number) : Boolean
      {
         if(param1 > this._portal.x && param1 < this._portal.x + this._portal.width)
         {
            if(param2 > this._portal.y && param2 < this._portal.y + this._portal.height)
            {
               return true;
            }
         }
         return false;
      }
   }
}

