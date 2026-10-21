package Superfighters_y8_idnet_locked_fp12_fla
{
   import Code.*;
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
   
   [SWF(width="800", height="600", backgroundColor="#000000", frameRate="24")]
   public dynamic class MainTimeline extends MovieClip
   {
      
      public var loadTxt:TextField;
      
      public var playBtn:SimpleButton;
      
      public var idi:*;
      
      public var m_lastFrame:int;
      
      public var m_gameIsRunning:Boolean;
      
      public var _game:Main;
      
      public var myTextField:TextField;
      
      public var canStart:Boolean;
      
      public var loadingDone:Boolean;
      
      public var minWaitTimer:Number;
      
      public function MainTimeline()
      {
         super();
         addFrameScript(0,this.frame1,1,this.frame2,2,this.frame3,4,this.frame5,5,this.frame6);
      }
      
      public function onEnterFrame(param1:*) : void
      {
         var _loc2_:Array = null;
         var _loc3_:Y8Lockdown = null;
         if(this.m_lastFrame != currentFrame)
         {
            this.m_lastFrame = currentFrame;
            if(currentFrame == 6 && this.m_gameIsRunning == false)
            {
               _loc2_ = [".y8.com",".pog.com",".dollmania.com",".id.net",".gamepost.com"];
               if(!this.checkSiteLockValid(_loc2_))
               {
                  this.writeLine("SWF Locked");
                  _loc3_ = new Y8Lockdown();
                  stage.addChild(_loc3_);
               }
               else
               {
                  this.writeLine("SWF Valid");
                  this._game = new Main(stage,this);
               }
               this.m_gameIsRunning = true;
            }
            else if(this.m_gameIsRunning == true)
            {
               gotoAndStop(6);
            }
         }
      }
      
      public function writeLine(param1:String) : void
      {
      }
      
      public function checkSiteLockValid(param1:Array) : Boolean
      {
         var _loc2_:String = this.root.loaderInfo.url;
         this.writeLine("Checking rootURL");
         if(!this.checkStringMatch(param1,_loc2_))
         {
            this.writeLine("rootURL not valid");
            return false;
         }
         return true;
      }
      
      public function checkStringMatch(param1:Array, param2:String) : Boolean
      {
         param2 = param2.toLowerCase();
         var _loc3_:int = 0;
         while(_loc3_ < param1.length)
         {
            if(param2.indexOf(param1[_loc3_].toLowerCase()) != -1)
            {
               this.writeLine("Pattern \'" + param1[_loc3_].toString() + "\' passed");
               return true;
            }
            _loc3_++;
         }
         return false;
      }
      
      public function LoadingDone(param1:Event) : void
      {
         this.loadingDone = true;
         if(this.canStart)
         {
            gotoAndStop(3);
         }
         else
         {
            this.myTextField.text = "LOADING";
         }
      }
      
      public function LoadingProgress(param1:ProgressEvent) : void
      {
         this.myTextField.text = Math.round(param1.bytesLoaded / param1.bytesTotal * 100) + " %";
      }
      
      public function WaitTimeOver() : void
      {
         clearInterval(this.minWaitTimer);
         if(!IDI.idnet)
         {
            if(this.loadingDone)
            {
               this.myTextField.text = "LOADING ID.NET";
            }
            this.minWaitTimer = setInterval(this.WaitTimeOver,1000);
            return;
         }
         this.canStart = true;
         if(this.loadingDone)
         {
            gotoAndStop(3);
         }
      }
      
      public function playBtnClick(param1:MouseEvent) : void
      {
         this.playBtn.removeEventListener(MouseEvent.CLICK,this.playBtnClick);
         gotoAndStop(6);
      }
      
      internal function frame1() : *
      {
         this.idi = new IDI();
         addChild(this.idi);
         this.m_lastFrame = -1;
         this.m_gameIsRunning = false;
         this._game = null;
         addEventListener("enterFrame",this.onEnterFrame);
         stop();
         this.myTextField = this.loadTxt;
         this.canStart = false;
         this.loadingDone = false;
         this.minWaitTimer = setInterval(this.WaitTimeOver,1000);
         this.loaderInfo.addEventListener(Event.COMPLETE,this.LoadingDone);
         this.loaderInfo.addEventListener(ProgressEvent.PROGRESS,this.LoadingProgress);
      }
      
      internal function frame2() : *
      {
         gotoAndStop(1);
      }
      
      internal function frame3() : *
      {
         this.playBtn.addEventListener(MouseEvent.CLICK,this.playBtnClick);
      }
      
      internal function frame5() : *
      {
         gotoAndStop(4);
      }
      
      internal function frame6() : *
      {
         stop();
      }
   }
}

