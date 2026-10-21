package
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
   
   [Embed(source="/_assets/assets.swf", symbol="symbol2515")]
   public dynamic class external_links extends MovieClip
   {
      
      public var btn_forum:SimpleButton;
      
      public var btn_video_guide:SimpleButton;
      
      public function external_links()
      {
         super();
         addFrameScript(0,this.frame1);
      }
      
      public function video_guide_on_click(param1:MouseEvent) : *
      {
         var _loc2_:URLRequest = new URLRequest("http://www.y8.com/animation/superfighters_walkthrough");
         navigateToURL(_loc2_,"_blank");
      }
      
      public function forum_on_click(param1:MouseEvent) : *
      {
         var _loc2_:URLRequest = new URLRequest("https://forum.id.net/t/superfighters-game/1609");
         navigateToURL(_loc2_,"_blank");
      }
      
      internal function frame1() : *
      {
         this.btn_video_guide.addEventListener(MouseEvent.CLICK,this.video_guide_on_click);
         this.btn_forum.addEventListener(MouseEvent.CLICK,this.forum_on_click);
      }
   }
}

