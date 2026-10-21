package Code.Handler
{
   import Code.Box2D.Collision.*;
   import Code.Box2D.Common.*;
   import Code.Box2D.Common.Math.*;
   import Code.Box2D.Dynamics.*;
   import flash.display.MovieClip;
   
   public class BasicOverlays
   {
      
      private var _overlayLayer:MovieClip;
      
      private var _list:Array;
      
      public function BasicOverlays(param1:MovieClip)
      {
         super();
         this._overlayLayer = param1;
         this._list = new Array();
      }
      
      public function Update() : void
      {
         if(this._list.length <= 0)
         {
            return;
         }
         var _loc1_:* = int(this._list.length - 1);
         while(_loc1_ >= 0)
         {
            if(this._list[_loc1_][0].GetUserData().destroyed == true)
            {
               this._overlayLayer.removeChild(this._list[_loc1_][1]);
               this._list.splice(_loc1_,1);
            }
            else
            {
               this._list[_loc1_][1].x = this._list[_loc1_][0].GetPosition().x * 30;
               this._list[_loc1_][1].y = this._list[_loc1_][0].GetPosition().y * 30;
            }
            _loc1_--;
         }
      }
      
      public function AddOverlay(param1:b2Body, param2:MovieClip) : void
      {
         param2.x = param1.GetPosition().x * 30;
         param2.y = param1.GetPosition().y * 30;
         this._overlayLayer.addChild(param2);
         var _loc3_:Array = new Array();
         _loc3_.push(param1);
         _loc3_.push(param2);
         this._list.push(_loc3_);
      }
   }
}

