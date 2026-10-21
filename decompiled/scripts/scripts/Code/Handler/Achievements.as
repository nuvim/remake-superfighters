package Code.Handler
{
   import Code.*;
   import Code.Data.*;
   import flash.display.MovieClip;
   import flash.events.*;
   import flash.utils.*;
   
   public class Achievements
   {
      
      private static var _graphic:MovieClip;
      
      private static var _stage:*;
      
      private static var _enabled:Boolean;
      
      private static var _achievements:Array;
      
      private static var _timer:Number;
      
      private static var _queuedAchievements:Array;
      
      private static var _achievementShown:AchievementData;
      
      private static var _Handler_Sounds:Sounds;
      
      public function Achievements()
      {
         super();
      }
      
      public static function Init(param1:*, param2:Sounds) : *
      {
         _queuedAchievements = new Array();
         _stage = param1;
         _Handler_Sounds = param2;
         InitGraphic();
         InitList();
         SetEnabled(false);
      }
      
      private static function InitGraphic() : void
      {
         if(!_graphic)
         {
            _graphic = new achievements_popup();
            _graphic.gotoAndStop(1);
         }
      }
      
      private static function InitList() : void
      {
         if(!_achievements)
         {
            _achievements = new Array();
            _achievements.push(new AchievementData("Bronze Fighter","f5164c4ce1a0d6e30326",false,1));
            _achievements.push(new AchievementData("Silver Fighter","9dd7513934a37182e086",false,2));
            _achievements.push(new AchievementData("Gold Fighter","417c2697140febdc0363",false,3));
            _achievements.push(new AchievementData("Bronze Survivor","f37ba8f5f0ba55d616d9",false,4));
            _achievements.push(new AchievementData("Silver Survivor","a6a3a4273b0288bb71fa",false,5));
            _achievements.push(new AchievementData("Gold Survivor","34034d9542dfd26d8e21",false,6));
            _achievements.push(new AchievementData("Superfighter","c4c481ea2b65d35b5197",false,7));
         }
      }
      
      public static function SetEnabled(param1:Boolean) : void
      {
         _enabled = param1;
      }
      
      public static function UpdateList(param1:Array) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:AchievementData = null;
         InitList();
         _loc2_ = 0;
         while(_loc2_ < _achievements.length)
         {
            _achievements[_loc2_].Earned = false;
            _loc2_++;
         }
         if(param1)
         {
            _loc2_ = 0;
            while(_loc2_ < param1.length)
            {
               _loc3_ = AchievementByName(param1[_loc2_].achievement);
               if(Boolean(_loc3_) && Boolean(param1[_loc2_].player) && param1[_loc2_].player.playerid == IDI.UserPid)
               {
                  _loc3_.Earned = true;
               }
               _loc2_++;
            }
         }
      }
      
      private static function AchievementByName(param1:String) : AchievementData
      {
         var _loc2_:Number = 0;
         while(_loc2_ < _achievements.length)
         {
            if(_achievements[_loc2_].Name == param1)
            {
               return _achievements[_loc2_];
            }
            _loc2_++;
         }
      }
      
      public static function EarnAchievement(param1:String) : void
      {
         var _loc2_:AchievementData = null;
         if(_enabled)
         {
            _loc2_ = AchievementByName(param1);
            if(Boolean(_loc2_) && _loc2_.Earned != true)
            {
               ShowAchievement(_loc2_);
               _loc2_.Earned = true;
               if(IDI.idnet)
               {
                  IDI.idnet.achievementsSave(_loc2_.Name,_loc2_.Key);
               }
               CheckSuperfighterAchievement();
            }
         }
      }
      
      private static function CheckSuperfighterAchievement() : void
      {
         var _loc1_:AchievementData = AchievementByName("Gold Fighter");
         var _loc2_:AchievementData = AchievementByName("Gold Survivor");
         if(Boolean(_loc1_ && _loc2_) && Boolean(_loc1_.Earned) && _loc2_.Earned)
         {
            EarnAchievement("Superfighter");
         }
      }
      
      private static function ShowAchievement(param1:AchievementData) : void
      {
         if(_graphic.currentFrame == 1)
         {
            _achievementShown = param1;
            _stage.addChild(_graphic);
            _graphic.gotoAndPlay(2);
            _graphic.name_txt.text = _achievementShown.Name;
            _graphic.icon.gotoAndStop(_achievementShown.IconIndex);
            _stage.addEventListener(Event.ENTER_FRAME,stageOnEnterFrame);
            _timer = setInterval(ShowAchievementOver,4000);
            if(_Handler_Sounds)
            {
               _Handler_Sounds.PlayMightySound("ACHIEVEMENT");
            }
         }
         else
         {
            _queuedAchievements.push(param1);
         }
      }
      
      public static function Position(param1:Number, param2:Number, param3:Number, param4:Number) : void
      {
         InitGraphic();
         if(param2 > 1 || param1 > 1)
         {
            _graphic.scaleX = 1;
            _graphic.scaleY = 1;
            _graphic.x = param3;
            _graphic.y = param4 - (1 - param2) * 600;
         }
         else
         {
            _graphic.scaleX = param1;
            _graphic.scaleY = param2;
            _graphic.x = param3;
            _graphic.y = param4;
         }
      }
      
      private static function stageOnEnterFrame(param1:Event) : void
      {
         if(Boolean(_graphic) && Boolean(_graphic.parent) && Boolean(_achievementShown))
         {
            _graphic.parent.setChildIndex(_graphic,_graphic.parent.numChildren - 1);
            if(_graphic.name_txt)
            {
               _graphic.name_txt.text = _achievementShown.Name;
            }
            if(_graphic.icon)
            {
               _graphic.icon.gotoAndStop(_achievementShown.IconIndex);
            }
         }
      }
      
      private static function ShowAchievementOver() : void
      {
         clearInterval(_timer);
         _stage.removeEventListener(Event.ENTER_FRAME,stageOnEnterFrame);
         _stage.removeChild(_graphic);
         _timer = setInterval(ShowAchievementPrepareNext,1000);
      }
      
      private static function ShowAchievementPrepareNext() : void
      {
         clearInterval(_timer);
         _graphic.gotoAndStop(1);
         if(_queuedAchievements.length > 0)
         {
            ShowAchievement(_queuedAchievements[0]);
            _queuedAchievements.shift();
         }
      }
   }
}

