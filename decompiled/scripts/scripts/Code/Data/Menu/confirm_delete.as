package Code.Data.Menu
{
   import Code.Handler.Sounds;
   import flash.display.*;
   
   public class confirm_delete extends submenu_base
   {
      
      private var _msgid:String = "";
      
      public function confirm_delete(param1:MovieClip, param2:Sounds, param3:String)
      {
         super();
         _this = param1;
         this._msgid = param3;
         _Handler_Sounds = param2;
         _canReturn = true;
         _marker_pos = 2;
         this.UpdateMarker();
      }
      
      public function get MsgID() : String
      {
         return this._msgid;
      }
      
      override public function UpdateMarker() : void
      {
         _this.marker_1.visible = false;
         _this.marker_2.visible = false;
         MovieClip(_this.getChildByName("marker_" + _marker_pos)).visible = true;
      }
      
      private function Toggle() : void
      {
         ++_marker_pos;
         if(_marker_pos > 2)
         {
            _marker_pos = 1;
         }
      }
      
      override public function KeyPressed(param1:int) : void
      {
         switch(param1)
         {
            case MenuKey.KEY_LEFT:
               this.Toggle();
               break;
            case MenuKey.KEY_RIGHT:
               this.Toggle();
         }
         this.UpdateMarker();
      }
      
      override public function GetChoice() : String
      {
         if(_marker_pos == 1)
         {
            return "delete_progress";
         }
         return "not_delete_progress";
      }
   }
}

