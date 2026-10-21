package Code.Data.Players
{
   import flash.geom.Rectangle;
   
   public class PlayerAreaData
   {
      
      private var _bottom:Number;
      
      private var _top:Number;
      
      private var _left:Number;
      
      private var _right:Number;
      
      public function PlayerAreaData(param1:Rectangle)
      {
         super();
         this._top = param1.y;
         this._left = param1.x;
         this._bottom = param1.y + param1.height;
         this._right = param1.x + param1.width;
      }
      
      public function get Bottom() : Number
      {
         return this._bottom;
      }
      
      public function get Top() : Number
      {
         return this._top;
      }
      
      public function get Left() : Number
      {
         return this._left;
      }
      
      public function get Right() : Number
      {
         return this._right;
      }
   }
}

