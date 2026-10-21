package Code
{
   import Code.Data.*;
   import Code.Handler.*;
   import flash.display.*;
   import flash.events.*;
   import flash.net.*;
   import flash.system.*;
   import flash.utils.*;
   
   public class IDI extends MovieClip
   {
      
      public static var idnet:*;
      
      public static var UserNickname:String;
      
      public static var UserPid:String;
      
      public static var idnetUpdates:Array;
      
      private static var checkUnlockedAchievements:Boolean;
      
      private var appID:String = "576a9494e694aa76512bf0c9";
      
      private var verbose:Boolean = false;
      
      private var showPreloader:* = false;
      
      private var protection:* = false;
      
      public function IDI()
      {
         super();
         idnetUpdates = new Array();
         Security.allowInsecureDomain("*");
         Security.allowDomain("*");
         addEventListener(Event.ADDED_TO_STAGE,this.onStage);
      }
      
      public static function IDNETRefreshAchievements(param1:Boolean = false) : void
      {
         if(idnet)
         {
            checkUnlockedAchievements = param1;
            idnet.achievementsList();
         }
      }
      
      public static function IDNETIsLoggedIn() : Boolean
      {
         if(Boolean(idnet) && Boolean(idnet.isLoggedIn))
         {
            return true;
         }
         return false;
      }
      
      public static function IDNETCloseInterface() : void
      {
         if(Boolean(idnet) && Boolean(idnet.InterfaceOpen()))
         {
            idnet.toggleInterface(null);
         }
      }
      
      public static function IDNETOpen() : Boolean
      {
         if(Boolean(idnet) && Boolean(idnet.InterfaceOpen()))
         {
            return true;
         }
         return false;
      }
      
      public static function PropagateUpdates(param1:String) : void
      {
         var _loc2_:Number = NaN;
         if(idnetUpdates)
         {
            _loc2_ = 0;
            while(_loc2_ < idnetUpdates.length)
            {
               idnetUpdates[_loc2_](param1);
               _loc2_++;
            }
         }
      }
      
      private function handleIDNET(param1:Event) : *
      {
         var _loc2_:* = idnet;
         if(idnet.type == "login")
         {
            UserNickname = idnet.userData.nickname;
            UserPid = idnet.userData.pid;
            Achievements.UpdateList(null);
            idnet.achievementsList();
         }
         if(idnet.type == "achievementsList")
         {
            if(idnet.data.errorcode == 0)
            {
               Achievements.UpdateList(idnet.data.achievements);
               if(checkUnlockedAchievements)
               {
                  SaveState.CheckUnlockedAchievements();
                  checkUnlockedAchievements = false;
               }
            }
         }
         if(idnet.type == "retrieve")
         {
            if(idnet.data.hasOwnProperty("error") === false)
            {
               SaveState.OnlineDataRetrieved(idnet.data.jsondata);
            }
            else
            {
               SaveState.OnlineDataRetrieved("");
            }
         }
         PropagateUpdates(idnet.type);
      }
      
      private function onStage(param1:Event) : void
      {
         var _loc2_:LoaderContext = new LoaderContext();
         _loc2_.applicationDomain = ApplicationDomain.currentDomain;
         if(Security.sandboxType != "localTrusted")
         {
            _loc2_.securityDomain = SecurityDomain.currentDomain;
         }
         var _loc3_:String = "https://scdn.id.net/swf/idnet-client.swc";
         var _loc4_:URLRequest = new URLRequest(_loc3_);
         var _loc5_:Loader = new Loader();
         _loc5_.contentLoaderInfo.addEventListener(Event.COMPLETE,this.loadComplete,false,0,true);
         _loc5_.load(_loc4_,_loc2_);
      }
      
      internal function loadComplete(param1:Event) : void
      {
         idnet = param1.currentTarget.content;
         idnet.addEventListener("IDNET",this.handleIDNET);
         stage.addChild(idnet);
         idnet.init(stage,this.appID,"",this.verbose,this.showPreloader,this.protection);
      }
   }
}

