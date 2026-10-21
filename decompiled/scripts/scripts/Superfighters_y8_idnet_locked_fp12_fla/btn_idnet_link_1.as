package Superfighters_y8_idnet_locked_fp12_fla
{
   import flash.accessibility.*;
   import flash.display.*;
   import flash.errors.*;
   import flash.events.*;
   import flash.filters.*;
   import flash.geom.*;
   import flash.media.*;
   import flash.net.*;
   import flash.net.drm.*;
   import flash.system.*;
   import flash.text.*;
   import flash.text.ime.*;
   import flash.ui.*;
   import flash.utils.*;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol14")]
   public dynamic class btn_idnet_link_1 extends MovieClip
   {
      
      public var btn_idnet:SimpleButton;
      
      public function btn_idnet_link_1()
      {
         super();
         addFrameScript(0,this.frame1);
      }
      
      public function on_click(param1:MouseEvent) : *
      {
         var _loc2_:URLRequest = new URLRequest("http://www.id.net");
         navigateToURL(_loc2_,"_blank");
      }
      
      internal function frame1() : *
      {
         this.btn_idnet.addEventListener(MouseEvent.CLICK,this.on_click);
      }
   }
}

