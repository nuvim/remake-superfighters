package Code.Data
{
   import Code.*;
   import Code.Handler.*;
   import flash.net.*;
   
   public class SaveState
   {
      
      public static var Data:*;
      
      private static var _mode:String;
      
      public static var LoadingOnlineData:Boolean;
      
      public static var OnlineData:*;
      
      public static var OfflineData:*;
      
      public static var SaveSlotSelectedCallback:Array;
      
      public function SaveState()
      {
         super();
      }
      
      public static function Init() : void
      {
         SaveSlotSelectedCallback = new Array();
      }
      
      private static function PropagateSaveSlotSelected() : void
      {
         var _loc1_:Number = NaN;
         if(SaveSlotSelectedCallback)
         {
            _loc1_ = 0;
            while(_loc1_ < SaveSlotSelectedCallback.length)
            {
               SaveSlotSelectedCallback[_loc1_]();
               _loc1_++;
            }
         }
      }
      
      private static function CreateEmptyData() : *
      {
         var _loc1_:Object = new Object();
         _loc1_.stageLevelsFinished = [false,false,false,false,false,false,false,false,false,false,false,false];
         _loc1_.startedBefore = false;
         _loc1_.stageModeWinMessageShown = false;
         return _loc1_;
      }
      
      public static function CheckUnlockedAchievements() : void
      {
         if(Data)
         {
            if(Data.stageLevelsFinished)
            {
               if(Boolean(Data.stageLevelsFinished[0]) && Boolean(Data.stageLevelsFinished[1]) && Boolean(Data.stageLevelsFinished[2]) && Boolean(Data.stageLevelsFinished[3]))
               {
                  Achievements.EarnAchievement("Bronze Fighter");
               }
               if(Boolean(Data.stageLevelsFinished[4]) && Boolean(Data.stageLevelsFinished[5]) && Boolean(Data.stageLevelsFinished[6]) && Boolean(Data.stageLevelsFinished[7]))
               {
                  Achievements.EarnAchievement("Silver Fighter");
               }
               if(Boolean(Data.stageLevelsFinished[8]) && Boolean(Data.stageLevelsFinished[9]) && Boolean(Data.stageLevelsFinished[10]) && Boolean(Data.stageLevelsFinished[11]))
               {
                  Achievements.EarnAchievement("Gold Fighter");
               }
            }
            if(Data.survivalBestWave)
            {
               if(Data.survivalBestWave >= 4)
               {
                  Achievements.EarnAchievement("Bronze Survivor");
               }
               if(Data.survivalBestWave >= 6)
               {
                  Achievements.EarnAchievement("Silver Survivor");
               }
               if(Data.survivalBestWave >= 8)
               {
                  Achievements.EarnAchievement("Gold Survivor");
               }
            }
         }
      }
      
      public static function SelectOnline() : void
      {
         Data = OnlineData;
         _mode = "ONLINE";
         PropagateSaveSlotSelected();
      }
      
      public static function SelectOffline() : void
      {
         Data = OfflineData;
         _mode = "OFFLINE";
         PropagateSaveSlotSelected();
      }
      
      public static function LoadData() : void
      {
         OfflineData = CreateEmptyData();
         OnlineData = CreateEmptyData();
         var _loc1_:SharedObject = SharedObject.getLocal("superfightersData_v1.0");
         if(_loc1_.data.stageLevelsFinished != undefined)
         {
            OfflineData.stageLevelsFinished = _loc1_.data.stageLevelsFinished;
            OfflineData.startedBefore = _loc1_.data.startedBefore;
            OfflineData.stageModeWinMessageShown = _loc1_.data.stageModeWinMessageShown;
            if(_loc1_.data.playerKeys)
            {
               OfflineData.playerKeys = _loc1_.data.playerKeys;
            }
            if(_loc1_.data.graphicQuality)
            {
               OfflineData.graphicQuality = _loc1_.data.graphicQuality;
            }
            if(_loc1_.data.effectLevel)
            {
               OfflineData.effectLevel = _loc1_.data.effectLevel;
            }
            OfflineData.survivalBestMins = _loc1_.data.survivalBestMins;
            OfflineData.survivalBestSecs = _loc1_.data.survivalBestSecs;
            OfflineData.survivalBestParts = _loc1_.data.survivalBestParts;
            OfflineData.survivalBestWave = _loc1_.data.survivalBestWave;
            OfflineData.survivalBestKills = _loc1_.data.survivalBestKills;
            OfflineData.survivalBestDmgBonus = _loc1_.data.survivalBestDmgBonus;
            OfflineData.survival2BestMins = _loc1_.data.survival2BestMins;
            OfflineData.survival2BestSecs = _loc1_.data.survival2BestSecs;
            OfflineData.survival2BestParts = _loc1_.data.survival2BestParts;
            OfflineData.survival2BestWave = _loc1_.data.survival2BestWave;
            OfflineData.survival2BestKills = _loc1_.data.survival2BestKills;
            OfflineData.survival2BestDmgBonus = _loc1_.data.survival2BestDmgBonus;
         }
         if(IDI.idnet)
         {
            LoadingOnlineData = true;
            IDI.idnet.retrieveUserData("gameSave1");
         }
         else
         {
            LoadingOnlineData = false;
         }
         IDI.PropagateUpdates("retrieve");
      }
      
      public static function SaveOffline() : void
      {
         var _loc1_:SharedObject = SharedObject.getLocal("superfightersData_v1.0");
         _loc1_.data.stageLevelsFinished = Data.stageLevelsFinished;
         _loc1_.data.startedBefore = Data.startedBefore;
         _loc1_.data.stageModeWinMessageShown = Data.stageModeWinMessageShown;
         if(Data.playerKeys)
         {
            _loc1_.data.playerKeys = Data.playerKeys;
         }
         if(Data.graphicQuality)
         {
            _loc1_.data.graphicQuality = Data.graphicQuality;
         }
         if(Data.effectLevel)
         {
            _loc1_.data.effectLevel = Data.effectLevel;
         }
         _loc1_.data.survivalBestMins = Data.survivalBestMins;
         _loc1_.data.survivalBestSecs = Data.survivalBestSecs;
         _loc1_.data.survivalBestParts = Data.survivalBestParts;
         _loc1_.data.survivalBestWave = Data.survivalBestWave;
         _loc1_.data.survivalBestKills = Data.survivalBestKills;
         _loc1_.data.survivalBestDmgBonus = Data.survivalBestDmgBonus;
         _loc1_.data.survival2BestMins = Data.survival2BestMins;
         _loc1_.data.survival2BestSecs = Data.survival2BestSecs;
         _loc1_.data.survival2BestParts = Data.survival2BestParts;
         _loc1_.data.survival2BestWave = Data.survival2BestWave;
         _loc1_.data.survival2BestKills = Data.survival2BestKills;
         _loc1_.data.survival2BestDmgBonus = Data.survival2BestDmgBonus;
         _loc1_.flush();
         IDI.PropagateUpdates("retrieve");
      }
      
      public static function DeleteOffline() : void
      {
         var _loc1_:SharedObject = SharedObject.getLocal("superfightersData_v1.0");
         var _loc2_:* = CreateEmptyData();
         _loc1_.data.stageLevelsFinished = _loc2_.stageLevelsFinished;
         _loc1_.data.startedBefore = _loc2_.startedBefore;
         _loc1_.data.stageModeWinMessageShown = _loc2_.stageModeWinMessageShown;
         _loc1_.data.survivalBestMins = undefined;
         _loc1_.data.survivalBestSecs = undefined;
         _loc1_.data.survivalBestParts = undefined;
         _loc1_.data.survivalBestWave = undefined;
         _loc1_.data.survivalBestKills = undefined;
         _loc1_.data.survivalBestDmgBonus = undefined;
         _loc1_.data.survival2BestMins = undefined;
         _loc1_.data.survival2BestSecs = undefined;
         _loc1_.data.survival2BestParts = undefined;
         _loc1_.data.survival2BestWave = undefined;
         _loc1_.data.survival2BestKills = undefined;
         _loc1_.data.survival2BestDmgBonus = undefined;
         _loc1_.flush();
         OfflineData.stageLevelsFinished = _loc1_.data.stageLevelsFinished;
         OfflineData.startedBefore = _loc1_.data.startedBefore;
         OfflineData.stageModeWinMessageShown = _loc1_.data.stageModeWinMessageShown;
         OfflineData.survivalBestMins = _loc1_.data.survivalBestMins;
         OfflineData.survivalBestSecs = _loc1_.data.survivalBestSecs;
         OfflineData.survivalBestParts = _loc1_.data.survivalBestParts;
         OfflineData.survivalBestWave = _loc1_.data.survivalBestWave;
         OfflineData.survivalBestKills = _loc1_.data.survivalBestKills;
         OfflineData.survivalBestDmgBonus = _loc1_.data.survivalBestDmgBonus;
         OfflineData.survival2BestMins = _loc1_.data.survival2BestMins;
         OfflineData.survival2BestSecs = _loc1_.data.survival2BestSecs;
         OfflineData.survival2BestParts = _loc1_.data.survival2BestParts;
         OfflineData.survival2BestWave = _loc1_.data.survival2BestWave;
         OfflineData.survival2BestKills = _loc1_.data.survival2BestKills;
         OfflineData.survival2BestDmgBonus = _loc1_.data.survival2BestDmgBonus;
         if(_mode == "OFFLINE")
         {
            Data = OfflineData;
         }
         IDI.PropagateUpdates("retrieve");
      }
      
      public static function SaveOnline() : void
      {
         var _loc1_:* = undefined;
         if(IDI.idnet)
         {
            _loc1_ = {
               "stageLevelsFinished":Data.stageLevelsFinished,
               "startedBefore":Data.startedBefore,
               "stageModeWinMessageShown":Data.stageModeWinMessageShown,
               "playerKeys":Data.playerKeys,
               "graphicQuality":Data.graphicQuality,
               "effectLevel":Data.effectLevel,
               "survivalBestMins":Data.survivalBestMins,
               "survivalBestSecs":Data.survivalBestSecs,
               "survivalBestParts":Data.survivalBestParts,
               "survivalBestWave":Data.survivalBestWave,
               "survivalBestKills":Data.survivalBestKills,
               "survivalBestDmgBonus":Data.survivalBestDmgBonus,
               "survival2BestMins":Data.survival2BestMins,
               "survival2BestSecs":Data.survival2BestSecs,
               "survival2BestParts":Data.survival2BestParts,
               "survival2BestWave":Data.survival2BestWave,
               "survival2BestKills":Data.survival2BestKills,
               "survival2BestDmgBonus":Data.survival2BestDmgBonus
            };
            IDI.idnet.submitUserData("gameSave1",JSON.stringify(_loc1_));
         }
      }
      
      public static function OnlineDataRetrieved(param1:String) : void
      {
         var _loc2_:Object = null;
         var _loc3_:* = undefined;
         LoadingOnlineData = false;
         if(param1)
         {
            _loc2_ = JSON.parse(param1);
            if(_loc2_.stageLevelsFinished)
            {
               OnlineData.stageLevelsFinished = _loc2_.stageLevelsFinished;
            }
            if(_loc2_.startedBefore)
            {
               OnlineData.startedBefore = _loc2_.startedBefore;
            }
            if(_loc2_.stageModeWinMessageShown)
            {
               OnlineData.stageModeWinMessageShown = _loc2_.stageModeWinMessageShown;
            }
            if(_loc2_.playerKeys)
            {
               OnlineData.playerKeys = _loc2_.playerKeys;
            }
            if(_loc2_.graphicQuality)
            {
               OnlineData.graphicQuality = _loc2_.graphicQuality;
            }
            if(_loc2_.effectLevel)
            {
               OnlineData.effectLevel = _loc2_.effectLevel;
            }
            if(_loc2_.survivalBestMins != undefined)
            {
               OnlineData.survivalBestMins = _loc2_.survivalBestMins;
            }
            if(_loc2_.survivalBestSecs != undefined)
            {
               OnlineData.survivalBestSecs = _loc2_.survivalBestSecs;
            }
            if(_loc2_.survivalBestParts != undefined)
            {
               OnlineData.survivalBestParts = _loc2_.survivalBestParts;
            }
            if(_loc2_.survivalBestWave != undefined)
            {
               OnlineData.survivalBestWave = _loc2_.survivalBestWave;
            }
            if(_loc2_.survivalBestKills != undefined)
            {
               OnlineData.survivalBestKills = _loc2_.survivalBestKills;
            }
            if(_loc2_.survivalBestDmgBonus != undefined)
            {
               OnlineData.survivalBestDmgBonus = _loc2_.survivalBestDmgBonus;
            }
            if(_loc2_.survival2BestMins != undefined)
            {
               OnlineData.survival2BestMins = _loc2_.survival2BestMins;
            }
            if(_loc2_.survival2BestSecs != undefined)
            {
               OnlineData.survival2BestSecs = _loc2_.survival2BestSecs;
            }
            if(_loc2_.survival2BestParts != undefined)
            {
               OnlineData.survival2BestParts = _loc2_.survival2BestParts;
            }
            if(_loc2_.survival2BestWave != undefined)
            {
               OnlineData.survival2BestWave = _loc2_.survival2BestWave;
            }
            if(_loc2_.survival2BestKills != undefined)
            {
               OnlineData.survival2BestKills = _loc2_.survival2BestKills;
            }
            if(_loc2_.survival2BestDmgBonus != undefined)
            {
               OnlineData.survival2BestDmgBonus = _loc2_.survival2BestDmgBonus;
            }
         }
         else
         {
            _loc3_ = CreateEmptyData();
            OnlineData.stageLevelsFinished = _loc3_.stageLevelsFinished;
            OnlineData.startedBefore = _loc3_.startedBefore;
            OnlineData.stageModeWinMessageShown = _loc3_.stageModeWinMessageShown;
            OnlineData.survivalBestMins = _loc3_.survivalBestMins;
            OnlineData.survivalBestSecs = _loc3_.survivalBestSecs;
            OnlineData.survivalBestParts = _loc3_.survivalBestParts;
            OnlineData.survivalBestWave = _loc3_.survivalBestWave;
            OnlineData.survivalBestKills = _loc3_.survivalBestKills;
            OnlineData.survivalBestDmgBonus = _loc3_.survivalBestDmgBonus;
            OnlineData.survival2BestMins = _loc3_.survival2BestMins;
            OnlineData.survival2BestSecs = _loc3_.survival2BestSecs;
            OnlineData.survival2BestParts = _loc3_.survival2BestParts;
            OnlineData.survival2BestWave = _loc3_.survival2BestWave;
            OnlineData.survival2BestKills = _loc3_.survival2BestKills;
            OnlineData.survival2BestDmgBonus = _loc3_.survival2BestDmgBonus;
            if(_mode == "ONLINE")
            {
               Data = OnlineData;
            }
         }
      }
      
      public static function DeleteOnline() : void
      {
         var _loc1_:* = undefined;
         if(IDI.idnet)
         {
            _loc1_ = CreateEmptyData();
            OnlineData.stageLevelsFinished = _loc1_.stageLevelsFinished;
            OnlineData.startedBefore = _loc1_.startedBefore;
            OnlineData.stageModeWinMessageShown = _loc1_.stageModeWinMessageShown;
            OnlineData.survivalBestMins = _loc1_.survivalBestMins;
            OnlineData.survivalBestSecs = _loc1_.survivalBestSecs;
            OnlineData.survivalBestParts = _loc1_.survivalBestParts;
            OnlineData.survivalBestWave = _loc1_.survivalBestWave;
            OnlineData.survivalBestKills = _loc1_.survivalBestKills;
            OnlineData.survivalBestDmgBonus = _loc1_.survivalBestDmgBonus;
            OnlineData.survival2BestMins = _loc1_.survival2BestMins;
            OnlineData.survival2BestSecs = _loc1_.survival2BestSecs;
            OnlineData.survival2BestParts = _loc1_.survival2BestParts;
            OnlineData.survival2BestWave = _loc1_.survival2BestWave;
            OnlineData.survival2BestKills = _loc1_.survival2BestKills;
            OnlineData.survival2BestDmgBonus = _loc1_.survival2BestDmgBonus;
            if(_mode == "ONLINE")
            {
               Data = OnlineData;
            }
            IDI.idnet.removeUserData("gameSave1");
         }
      }
      
      public static function IsStageModeCompleted() : Boolean
      {
         return GetStageModeCompleted(Data);
      }
      
      private static function GetStageModeCompleted(param1:*) : Boolean
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         if(Boolean(param1) && Boolean(param1.stageLevelsFinished))
         {
            _loc2_ = 0;
            _loc3_ = 0;
            while(_loc3_ < param1.stageLevelsFinished.length)
            {
               if(param1.stageLevelsFinished[_loc3_] == true)
               {
                  _loc2_ += 1;
               }
               _loc3_++;
            }
            return _loc2_ == param1.stageLevelsFinished.length;
         }
         return false;
      }
      
      private static function GetProgressString(param1:*) : String
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         if(Boolean(param1) && param1.startedBefore == true)
         {
            _loc2_ = 0;
            if(param1.stageLevelsFinished)
            {
               _loc3_ = 0;
               while(_loc3_ < param1.stageLevelsFinished.length)
               {
                  if(param1.stageLevelsFinished[_loc3_] == true)
                  {
                     _loc2_ += 1;
                  }
                  _loc3_++;
               }
               return "STAGE " + _loc2_.toString() + "/" + param1.stageLevelsFinished.length.toString();
            }
         }
         return "EMPTY";
      }
      
      public static function OnlineDataProgress() : String
      {
         if(Boolean(IDI.idnet) && !IDI.idnet.isLoggedIn)
         {
            return "SIGN UP";
         }
         if(LoadingOnlineData)
         {
            return "LOADING";
         }
         return GetProgressString(OnlineData).toUpperCase();
      }
      
      public static function OfflineDataProgress() : String
      {
         return GetProgressString(OfflineData).toUpperCase();
      }
      
      public static function OnlineDataExist() : Boolean
      {
         if(Boolean(IDI.idnet) && !IDI.idnet.isLoggedIn)
         {
            return false;
         }
         if(LoadingOnlineData)
         {
            return false;
         }
         if(Boolean(OnlineData) && OnlineData.startedBefore == true)
         {
            return true;
         }
         return false;
      }
      
      public static function OfflineDataExist() : Boolean
      {
         if(Boolean(OfflineData) && OfflineData.startedBefore == true)
         {
            return true;
         }
         return false;
      }
      
      public static function CopyOfflineToOnline() : void
      {
         OnlineData = CreateEmptyData();
         OnlineData.stageLevelsFinished = OfflineData.stageLevelsFinished;
         OnlineData.startedBefore = OfflineData.startedBefore;
         OnlineData.stageModeWinMessageShown = OfflineData.stageModeWinMessageShown;
         OnlineData.playerKeys = OfflineData.playerKeys;
         OnlineData.survivalBestMins = OfflineData.survivalBestMins;
         OnlineData.survivalBestSecs = OfflineData.survivalBestSecs;
         OnlineData.survivalBestParts = OfflineData.survivalBestParts;
         OnlineData.survivalBestWave = OfflineData.survivalBestWave;
         OnlineData.survivalBestKills = OfflineData.survivalBestKills;
         OnlineData.survivalBestDmgBonus = OfflineData.survivalBestDmgBonus;
         OnlineData.survival2BestMins = OfflineData.survival2BestMins;
         OnlineData.survival2BestSecs = OfflineData.survival2BestSecs;
         OnlineData.survival2BestParts = OfflineData.survival2BestParts;
         OnlineData.survival2BestWave = OfflineData.survival2BestWave;
         OnlineData.survival2BestKills = OfflineData.survival2BestKills;
         OnlineData.survival2BestDmgBonus = OfflineData.survival2BestDmgBonus;
         var _loc1_:Object = Data;
         Data = OnlineData;
         SaveOnline();
         Data = _loc1_;
      }
      
      public static function Save() : void
      {
         if(_mode == "OFFLINE")
         {
            SaveOffline();
         }
         else if(_mode == "ONLINE")
         {
            SaveOnline();
         }
      }
   }
}

