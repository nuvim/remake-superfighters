package Code.Data.Menu
{
   import Code.*;
   import Code.Data.*;
   import Code.Handler.Sounds;
   import flash.display.MovieClip;
   
   public class save_selection extends submenu_base
   {
      
      public function save_selection(param1:MovieClip, param2:Sounds)
      {
         super();
         _this = param1;
         _total_markers = 6;
         _Handler_Sounds = param2;
         _canReturn = false;
         this.idnetUpdate("retrieve");
         UpdateMarker();
      }
      
      override public function idnetUpdate(param1:String) : void
      {
         if(param1 == "retrieve" || param1 == "login")
         {
            if(param1 == "login")
            {
               SaveState.LoadData();
            }
            if(IDI.IDNETIsLoggedIn())
            {
               _this.idnet_logintext.text = "LOGGED IN AS";
               _this.idnet_username.text = IDI.UserNickname;
            }
            else
            {
               _this.idnet_logintext.text = "";
               _this.idnet_username.text = "";
            }
            _this.slot0_progress.text = SaveState.OnlineDataProgress();
            _this.slot1_progress.text = SaveState.OfflineDataProgress();
            if(SaveState.OnlineDataExist())
            {
               _this.slot0_delete.visible = true;
            }
            else
            {
               _this.slot0_delete.visible = false;
            }
            if(SaveState.OfflineDataExist())
            {
               _this.slot1_delete.visible = true;
               _this.slot1_copytoonline.visible = IDI.IDNETIsLoggedIn();
            }
            else
            {
               _this.slot1_delete.visible = false;
               _this.slot1_copytoonline.visible = false;
            }
            this.DeselectUnavailableDelete();
            UpdateMarker();
         }
      }
      
      override public function Show() : void
      {
         this.idnetUpdate("retrieve");
         super.Show();
      }
      
      override public function KeyPressed(param1:int) : void
      {
         var _loc2_:Array = new Array(false,false,false,false,false,false);
         _loc2_[0] = true;
         _loc2_[1] = SaveState.OnlineDataExist();
         _loc2_[2] = IDI.IDNETIsLoggedIn();
         _loc2_[3] = true;
         _loc2_[4] = SaveState.OfflineDataExist();
         _loc2_[5] = IDI.IDNETIsLoggedIn() && SaveState.OfflineDataExist();
         switch(param1)
         {
            case MenuKey.KEY_UP:
               this.MarkerPosUp(_loc2_);
               break;
            case MenuKey.KEY_DOWN:
               this.MarkerPosDown(_loc2_);
               break;
            case MenuKey.KEY_LEFT:
               if(_marker_pos >= 3)
               {
                  _marker_pos -= 3;
                  if(!_loc2_[_marker_pos])
                  {
                     this.MarkerPosUp(_loc2_);
                  }
               }
               break;
            case MenuKey.KEY_RIGHT:
               if(_marker_pos <= 2)
               {
                  _marker_pos += 3;
                  if(!_loc2_[_marker_pos])
                  {
                     this.MarkerPosUp(_loc2_);
                  }
               }
         }
         UpdateMarker();
      }
      
      private function DeselectUnavailableDelete() : void
      {
         if(_marker_pos == 4 && !SaveState.OfflineDataExist())
         {
            _marker_pos = 3;
         }
         if(_marker_pos == 5 && !SaveState.OfflineDataExist())
         {
            _marker_pos = 3;
         }
         if(_marker_pos == 1 && !SaveState.OnlineDataExist())
         {
            _marker_pos = 0;
         }
      }
      
      private function MarkerPosUp(param1:Array) : void
      {
         var _loc2_:Number = 0;
         var _loc3_:Number = 2;
         if(_marker_pos >= 3)
         {
            _loc2_ = 3;
            _loc3_ = 5;
         }
         _marker_pos = _marker_pos - 1;
         if(_marker_pos < _loc2_)
         {
            _marker_pos = _loc3_;
         }
         while(!param1[_marker_pos])
         {
            _marker_pos = _marker_pos - 1;
            if(_marker_pos < _loc2_)
            {
               _marker_pos = _loc3_;
            }
         }
      }
      
      private function MarkerPosDown(param1:Array) : void
      {
         var _loc2_:Number = 0;
         var _loc3_:Number = 2;
         if(_marker_pos >= 3)
         {
            _loc2_ = 3;
            _loc3_ = 5;
         }
         _marker_pos += 1;
         if(_marker_pos > _loc3_)
         {
            _marker_pos = _loc2_;
         }
         while(!param1[_marker_pos])
         {
            _marker_pos += 1;
            if(_marker_pos > _loc3_)
            {
               _marker_pos = _loc2_;
            }
         }
      }
      
      override public function GetChoice() : String
      {
         switch(_marker_pos)
         {
            case 0:
               return "save_online";
            case 1:
               return "save_online_delete";
            case 2:
               return "idnet_login";
            case 3:
               return "save_offline";
            case 4:
               return "save_offline_delete";
            case 5:
               return "copy_offline_to_online";
            default:
               return "";
         }
      }
   }
}

