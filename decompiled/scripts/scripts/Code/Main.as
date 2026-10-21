package Code
{
   import Code.Data.*;
   import Code.Handler.*;
   import flash.display.*;
   
   public class Main extends MovieClip
   {
      
      private var _game_mc:MovieClip;
      
      private var _Handler_Output:OutputTrace;
      
      private var _Handler_Options:Options;
      
      private var _Handler_MenuMain:MenuMain;
      
      private var _Handler_GameMain:GameMain;
      
      private var _Handler_Sounds:Sounds;
      
      private var _stage:*;
      
      private var _this:*;
      
      public function Main(param1:*, param2:*)
      {
         var gameData:GameMainData;
         var menuData:MenuMainData = null;
         var stg:* = param1;
         var self:* = param2;
         super();
         this._stage = stg;
         this._this = self;
         this._game_mc = new MovieClip();
         this._this.addChild(this._game_mc);
         SaveState.Init();
         this._Handler_Output = new OutputTrace(this._stage,GameMain.DEBUG_MODE);
         this._Handler_Sounds = new Sounds(this._Handler_Output);
         this._Handler_Options = new Options(this._stage,this._Handler_Output);
         this._this.contextMenu = this._Handler_Options.CustomizedContextMenu();
         gameData = new GameMainData();
         gameData.game_mc = this._game_mc;
         gameData.stage_temp = this._stage;
         gameData.Handler_Output = this._Handler_Output;
         gameData.Handler_Options = this._Handler_Options;
         gameData.Handler_Sounds = this._Handler_Sounds;
         this._Handler_GameMain = new GameMain(gameData);
         menuData = new MenuMainData();
         menuData.game_mc = this._game_mc;
         menuData.stage_temp = this._stage;
         menuData.Handler_Output = this._Handler_Output;
         menuData.Handler_GameMain = this._Handler_GameMain;
         menuData.Handler_Sounds = this._Handler_Sounds;
         menuData.Handler_Options = this._Handler_Options;
         this._Handler_MenuMain = new MenuMain(menuData);
         this._Handler_GameMain.Handler_MenuMain = this._Handler_MenuMain;
         this._Handler_MenuMain.OpenMenu();
         Achievements.Init(stg,this._Handler_Sounds);
         SaveState.LoadData();
         IDI.idnetUpdates.push(function(param1:String):void
         {
            menuData.Handler_Options.idnetUpdate(param1);
         });
         this._Handler_Output.Trace("Game Started Successfully");
         this._Handler_Output.Trace("");
      }
   }
}

