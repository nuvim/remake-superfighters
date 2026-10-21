package Code.Handler
{
   import Code.Data.*;
   import flash.display.*;
   import flash.events.*;
   import flash.net.*;
   import flash.ui.*;
   
   public class Options extends MovieClip
   {
      
      private var _Handler_Output:OutputTrace;
      
      private var _Handler_Keyboard:InputKeyboard;
      
      private var _Handler_Camera:Cam;
      
      private var _stage:*;
      
      private var _playerDefaultKeys:Array;
      
      private var _effectLvl:int = 3;
      
      private var _totalEffects:int = 220;
      
      private var _lastQualityLvl:String = "";
      
      public function Options(param1:*, param2:OutputTrace)
      {
         var stg:* = param1;
         var ot:OutputTrace = param2;
         super();
         this._stage = stg;
         this._Handler_Output = ot;
         this._Handler_Keyboard = new InputKeyboard(this._stage);
         this._Handler_Keyboard.AddHandler(116,this._Handler_Output.Show);
         this._Handler_Keyboard.AddHandler(117,this._Handler_Output.Hide);
         this._Handler_Keyboard.AddHandler(123,this.ToggleFullscreen);
         this._stage.quality = "HIGH";
         this._stage.scaleMode = "noScale";
         this._stage.addEventListener(Event.RESIZE,this.OnStageResize);
         this.DefaultKeys();
         SaveState.SaveSlotSelectedCallback.push(function():void
         {
            LoadData();
         });
         this.LoadData();
         this._Handler_Output.Trace("Options Created");
      }
      
      public function idnetUpdate(param1:String) : void
      {
         if(param1 == "retrieve")
         {
            this.LoadData();
         }
      }
      
      private function LoadData() : void
      {
         if(SaveState.Data)
         {
            if(SaveState.Data.playerKeys != undefined)
            {
               this._playerDefaultKeys = SaveState.Data.playerKeys;
            }
            else
            {
               this.DefaultKeys();
            }
            if(SaveState.Data.graphicQuality != undefined)
            {
               this._stage.quality = SaveState.Data.graphicQuality;
            }
            if(SaveState.Data.effectLevel != undefined)
            {
               this._effectLvl = SaveState.Data.effectLevel;
            }
            else
            {
               this._effectLvl = 3;
            }
         }
      }
      
      public function SaveData() : void
      {
         SaveState.Data.playerKeys = this._playerDefaultKeys;
         SaveState.Data.graphicQuality = this._stage.quality;
         SaveState.Data.effectLevel = this._effectLvl;
         SaveState.Save();
      }
      
      private function DefaultKeys() : void
      {
         this._playerDefaultKeys = new Array([0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0]);
         this.SetDefaultP1Keys();
         this.SetDefaultP2Keys();
      }
      
      public function SetDefaultP1Keys() : void
      {
         this._playerDefaultKeys[0][0] = this._Handler_Keyboard.GetKeyCode("UP");
         this._playerDefaultKeys[0][1] = this._Handler_Keyboard.GetKeyCode("DOWN");
         this._playerDefaultKeys[0][2] = this._Handler_Keyboard.GetKeyCode("LEFT");
         this._playerDefaultKeys[0][3] = this._Handler_Keyboard.GetKeyCode("RIGHT");
         this._playerDefaultKeys[0][4] = this._Handler_Keyboard.GetKeyCode("N");
         this._playerDefaultKeys[0][5] = this._Handler_Keyboard.GetKeyCode("M");
         this._playerDefaultKeys[0][6] = 188;
         this._playerDefaultKeys[0][7] = 190;
         this._playerDefaultKeys[0][8] = this._Handler_Keyboard.GetKeyCode("UP");
         this._playerDefaultKeys[0][9] = this._Handler_Keyboard.GetKeyCode("DOWN");
         this._playerDefaultKeys[0][10] = 0;
      }
      
      public function SetDefaultP2Keys() : void
      {
         this._playerDefaultKeys[1][0] = this._Handler_Keyboard.GetKeyCode("W");
         this._playerDefaultKeys[1][1] = this._Handler_Keyboard.GetKeyCode("S");
         this._playerDefaultKeys[1][2] = this._Handler_Keyboard.GetKeyCode("A");
         this._playerDefaultKeys[1][3] = this._Handler_Keyboard.GetKeyCode("D");
         this._playerDefaultKeys[1][4] = this._Handler_Keyboard.GetKeyCode("1");
         this._playerDefaultKeys[1][5] = this._Handler_Keyboard.GetKeyCode("2");
         this._playerDefaultKeys[1][6] = this._Handler_Keyboard.GetKeyCode("3");
         this._playerDefaultKeys[1][7] = this._Handler_Keyboard.GetKeyCode("4");
         this._playerDefaultKeys[1][8] = this._Handler_Keyboard.GetKeyCode("W");
         this._playerDefaultKeys[1][9] = this._Handler_Keyboard.GetKeyCode("S");
         this._playerDefaultKeys[1][10] = 0;
      }
      
      public function GetTotalEffects() : int
      {
         return this._totalEffects;
      }
      
      public function get PlayerKeys() : Array
      {
         return this._playerDefaultKeys;
      }
      
      public function set PlayerKeys(param1:Array) : void
      {
         this._playerDefaultKeys = param1;
      }
      
      public function GetPlayerKeys() : Array
      {
         return this._playerDefaultKeys;
      }
      
      public function LinkToCam(param1:Cam) : void
      {
         this._Handler_Camera = param1;
      }
      
      public function GetEffectLevel() : int
      {
         return this._effectLvl;
      }
      
      public function GetEffectQuality() : String
      {
         switch(this._effectLvl)
         {
            case 1:
               return "LOW";
            case 2:
               return "MEDIUM";
            case 3:
               return "HIGH";
            case 4:
               return "BEST";
            default:
               return "LOW";
         }
      }
      
      public function Update() : void
      {
         if(this._stage.quality != this._lastQualityLvl)
         {
            switch(this._stage.quality)
            {
               case "HIGH":
                  this._effectLvl = 3;
                  break;
               case "MEDIUM":
                  this._effectLvl = 2;
                  break;
               case "LOW":
                  this._effectLvl = 1;
                  break;
               case "BEST":
                  this._effectLvl = 4;
                  break;
               default:
                  this._effectLvl = 0;
            }
            this._lastQualityLvl = this._stage.quality;
         }
      }
      
      public function GetStageQuality() : String
      {
         return this._stage.quality;
      }
      
      public function ToggleGraphicQuality(param1:int = -1) : void
      {
         if(param1 < 0)
         {
            switch(this._stage.quality)
            {
               case "HIGH":
                  this._stage.quality = "MEDIUM";
                  break;
               case "MEDIUM":
                  this._stage.quality = "LOW";
                  break;
               case "LOW":
                  this._stage.quality = "HIGH";
            }
         }
         else
         {
            switch(this._stage.quality)
            {
               case "HIGH":
                  this._stage.quality = "LOW";
                  break;
               case "MEDIUM":
                  this._stage.quality = "HIGH";
                  break;
               case "LOW":
                  this._stage.quality = "MEDIUM";
            }
         }
      }
      
      public function ToggleEffectLevel(param1:int = -1) : void
      {
         this._effectLvl += param1;
         if(this._effectLvl < 1)
         {
            this._effectLvl = 4;
         }
         if(this._effectLvl > 4)
         {
            this._effectLvl = 1;
         }
         this._totalEffects = 10 + this._effectLvl * 70;
         this._Handler_Output.Trace("Effect Level: " + this._effectLvl);
      }
      
      public function ToggleFullscreen() : void
      {
         if(this._stage.displayState == StageDisplayState.FULL_SCREEN)
         {
            this.ExitFullscreen();
         }
         else
         {
            this.EnterFullscreen();
         }
      }
      
      public function EnterFullscreen() : void
      {
         this._stage.displayState = StageDisplayState.FULL_SCREEN;
         if(this._stage.displayState != StageDisplayState.FULL_SCREEN)
         {
            this._Handler_Output.Trace("<b>Error</b>: Can\'t Enter Fullscreen Mode. To allow full-screen, allowFullScreen must be true in the object/embed tags.");
         }
         else
         {
            this._Handler_Output.Trace("Fullscreen Mode");
         }
      }
      
      private function OnStageResize(param1:Event) : void
      {
         this._Handler_Camera.SetScreenResulotion(this._stage.stageWidth,this._stage.stageHeight);
      }
      
      public function ExitFullscreen() : void
      {
         this._Handler_Output.Trace("Normal Mode");
         this._stage.displayState = StageDisplayState.NORMAL;
      }
      
      public function CustomizedContextMenu() : ContextMenu
      {
         var _loc1_:ContextMenu = new ContextMenu();
         _loc1_.hideBuiltInItems();
         _loc1_.builtInItems.quality = true;
         var _loc2_:ContextMenuItem = new ContextMenuItem("Superfighters");
         _loc2_.enabled = false;
         var _loc3_:ContextMenuItem = new ContextMenuItem("MythoLogic Interactive",true,true,true);
         _loc3_.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,this.linkClick);
         var _loc4_:ContextMenuItem = new ContextMenuItem("Y8",false,true,true);
         _loc4_.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,this.linkY8Click);
         _loc1_.customItems.push(_loc3_);
         _loc1_.customItems.push(_loc4_);
         return _loc1_;
      }
      
      public function linkClick(param1:ContextMenuEvent) : void
      {
         var _loc2_:URLRequest = new URLRequest("http://mythologicinteractive.com/");
         navigateToURL(_loc2_,"_blank");
      }
      
      public function linkY8Click(param1:ContextMenuEvent) : void
      {
         var _loc2_:URLRequest = new URLRequest("http://www.y8.com/");
         navigateToURL(_loc2_,"_blank");
      }
   }
}

