package Code.Data.Menu
{
   import Code.Handler.Sounds;
   import flash.display.*;
   
   public class submenu_base
   {
      
      protected var _this:MovieClip;
      
      protected var _total_markers:int = 0;
      
      protected var _marker_pos:int = 0;
      
      protected var _Handler_Sounds:Sounds;
      
      protected var _canReturn:Boolean = false;
      
      public function submenu_base()
      {
         super();
      }
      
      public function get CanReturn() : Boolean
      {
         return this._canReturn;
      }
      
      public function KeyPressed(param1:int) : void
      {
      }
      
      public function UpdateMarker() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ < this._total_markers)
         {
            MovieClip(this._this.getChildByName("marker_" + _loc1_)).visible = false;
            _loc1_++;
         }
         MovieClip(this._this.getChildByName("marker_" + this._marker_pos)).visible = true;
      }
      
      public function idnetUpdate(param1:String) : void
      {
      }
      
      public function GetChoice() : String
      {
         return "";
      }
      
      public function Hide() : void
      {
         this._this.visible = false;
      }
      
      public function Show() : void
      {
         this._this.visible = true;
      }
   }
}

