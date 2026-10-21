package Code.Handler
{
   import Code.*;
   import Code.Box2D.Collision.*;
   import Code.Box2D.Collision.Shapes.*;
   import Code.Box2D.Common.*;
   import Code.Box2D.Common.Math.*;
   import Code.Box2D.Dynamics.*;
   import Code.Box2D.Dynamics.Contacts.*;
   import Code.Box2D.Dynamics.Joints.*;
   import Code.Data.*;
   import Code.Data.Players.*;
   import Code.Data.Weapons.*;
   import Code.Particles.*;
   import flash.display.*;
   import flash.events.*;
   import flash.filters.*;
   import flash.geom.*;
   import flash.ui.*;
   
   public class GameMain
   {
      
      public static var DEBUG_MODE:Boolean = false;
      
      private var _game_mc:MovieClip;
      
      private var _Handler_Output:OutputTrace;
      
      private var _Handler_MenuMain:MenuMain;
      
      private var _Handler_Maps:Maps;
      
      private var _Handler_Camera:Cam;
      
      private var _Handler_Shake:Shake;
      
      private var _Handler_Mouse:InputMouse;
      
      private var _Handler_Box2DMouse:Box2DMouse;
      
      private var _Handler_Keyboard:InputKeyboard;
      
      private var _Handler_Players:PlayersKeeper;
      
      private var _Handler_Effects:Effects;
      
      private var _Handler_Options:Options;
      
      private var _Handler_Deconstructer:Deconstructer;
      
      private var _Handler_Sounds:Sounds;
      
      private var _Handler_Portals:Portals;
      
      private var _Handler_Explosions:Explosions;
      
      private var _Handler_Fires:Fires;
      
      private var _Handler_Weapons:Weapons;
      
      private var _Handler_WeaponSpawn:WeaponSpawn;
      
      private var _Handler_Commands:CommandList;
      
      private var _Handler_Projectiles:Projectiles;
      
      private var _Handler_ProjectilesUpdater:ProjectilesUpdater;
      
      private var _Handler_BasicOverlays:BasicOverlays;
      
      private var _Handler_Slowmo:Slowmo;
      
      private var _ContactData:ContactData;
      
      private var _stage:*;
      
      private var _box2D_speed:Number = 100;
      
      private var _camera_speed:Number = 1;
      
      private var _player_speed:Number = 1;
      
      private var _countdown:int = 0;
      
      private var _countdown_mc:MovieClip;
      
      private var _game_window:MovieClip;
      
      private var _round_initialized:int;
      
      private var _press_space_indication:MovieClip;
      
      private var _external_links:MovieClip;
      
      private var _victory_text:MovieClip;
      
      private var _static_mc:MovieClip;
      
      private var _static_objects_hitbox_mc:MovieClip;
      
      private var _static_world_hitbox_mc:MovieClip;
      
      private var _static_world_cloud_hitbox_mc:MovieClip;
      
      private var _static_objects_cloud_hitbox_mc:MovieClip;
      
      private var _static_ladder_hitbox_mc:MovieClip;
      
      private var _static_players_hitbox_mc:MovieClip;
      
      private var _dynamic_mc:MovieClip;
      
      private var _dynamic_gui_mc:MovieClip;
      
      private var _object_shape_container_mc:MovieClip;
      
      private var _shake_container:MovieClip;
      
      private var _prevGameData:NewGameData;
      
      private var _tipsOver:Boolean;
      
      private var _tips:MovieClip;
      
      private var _roundOver:Boolean;
      
      private var _countdownOver:Boolean;
      
      private var _gameModeWinnerShown:Boolean;
      
      private var _bgNoise:MovieClip;
      
      private var _last_bgNoiseFrame:int = 1;
      
      private var _score:Scoreboard;
      
      private var _scoreSurvival:ScoreboardSurvival;
      
      internal var nocolour:Array = [0.213,0.715,0.072,0,0,0.213,0.715,0.072,0,0,0.213,0.715,0.072,0,0,0,0,0,1,0];
      
      internal var colour:Array = [1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,1,0];
      
      internal var greyscale:ColorMatrixFilter = new ColorMatrixFilter(this.nocolour);
      
      internal var fullcolour:ColorMatrixFilter = new ColorMatrixFilter(this.colour);
      
      private var _bodyIndex:int;
      
      public var m_world:b2World;
      
      public var m_iterations:int = 20;
      
      public var m_timeStep:Number = 0.03333333333333333;
      
      public function GameMain(param1:GameMainData)
      {
         super();
         this._game_mc = param1.game_mc;
         this._stage = param1.stage_temp;
         this._Handler_Output = param1.Handler_Output;
         this._Handler_Options = param1.Handler_Options;
         this._Handler_Sounds = param1.Handler_Sounds;
         this._Handler_Sounds.ChangeVolume(1);
         this._Handler_Weapons = new Weapons(this._Handler_Output);
         this._Handler_Projectiles = new Projectiles(this._Handler_Output);
         this._Handler_Maps = new Maps(this._Handler_Output);
         this._Handler_Mouse = new InputMouse(this._stage);
         this._Handler_Commands = new CommandList(this._Handler_Output,DEBUG_MODE);
         this._tips = new tips();
         this._tips.gotoAndStop(1);
         this._press_space_indication = new press_space();
         this._external_links = new external_links();
         this._victory_text = new round_winner();
         this._Handler_Output.Trace("Main Game Initialized");
      }
      
      private function SetBlackWhite(param1:MovieClip) : void
      {
         param1.filters = [this.greyscale];
      }
      
      public function set Handler_MenuMain(param1:MenuMain) : void
      {
         this._Handler_MenuMain = param1;
      }
      
      private function Unfocus(param1:FocusEvent) : void
      {
         this._stage.focus = null;
      }
      
      public function StartNewGame(param1:NewGameData) : void
      {
         var _static_players_area_mc:MovieClip;
         var slomo_rectangle:MovieClip;
         var gui_holder_mc:MovieClip;
         var level_mc:levels;
         var mc_effects_behind:MovieClip;
         var mc_objects:MovieClip;
         var mc_scrap:MovieClip;
         var mc_players:MovieClip;
         var mc_weapons:MovieClip;
         var mc_effects:MovieClip;
         var mc_effects2:MovieClip;
         var mc_projectiles:MovieClip;
         var mc_lazers:MovieClip;
         var level_front_mc:levels_front;
         var pData:PlayersKeeperData;
         var eData:ExplosionData;
         var puData:ProjectilesUpdaterData;
         var p:int = 0;
         var p2:int = 0;
         var gameData:NewGameData = param1;
         this._prevGameData = gameData;
         this._Handler_Keyboard = new InputKeyboard(this._stage);
         this._Handler_Keyboard.AddHandler(this._Handler_Keyboard.GetKeyCode("P"),this._Handler_Options.ToggleEffectLevel);
         this._static_mc = new MovieClip();
         this._static_mc.name = "STATIC";
         this._static_world_hitbox_mc = new MovieClip();
         this._static_world_hitbox_mc.name = "WORLD_HITBOX";
         this._static_world_cloud_hitbox_mc = new MovieClip();
         this._static_world_cloud_hitbox_mc.name = "WORLD_CLOUD_HITBOX";
         this._static_objects_cloud_hitbox_mc = new MovieClip();
         this._static_objects_cloud_hitbox_mc.name = "OBJECTS_CLOUD_HITBOX";
         this._static_ladder_hitbox_mc = new MovieClip();
         this._static_ladder_hitbox_mc.name = "LADDER_HITBOX";
         this._static_objects_hitbox_mc = new MovieClip();
         this._static_objects_hitbox_mc.name = "OBJECTS_HITBOX";
         this._static_players_hitbox_mc = new MovieClip();
         this._static_players_hitbox_mc.name = "PLAYERS_HITBOX";
         _static_players_area_mc = new MovieClip();
         _static_players_area_mc.name = "PLAYERS_AREA";
         this._static_mc.addChild(this._static_ladder_hitbox_mc);
         this._static_mc.addChild(this._static_players_hitbox_mc);
         this._static_mc.addChild(_static_players_area_mc);
         this._static_world_hitbox_mc.addChild(this._static_objects_hitbox_mc);
         this._static_mc.addChild(this._static_world_hitbox_mc);
         this._static_world_cloud_hitbox_mc.addChild(this._static_objects_cloud_hitbox_mc);
         this._static_mc.addChild(this._static_world_cloud_hitbox_mc);
         this._dynamic_mc = new MovieClip();
         this._dynamic_mc.name = "DYNAMIC";
         this._object_shape_container_mc = new MovieClip();
         this._object_shape_container_mc.name = "ALLOBJECTS";
         this.HideStatic();
         this._game_mc.addChild(this._static_mc);
         this._game_mc.addChild(this._object_shape_container_mc);
         this._shake_container = new MovieClip();
         this._shake_container.name = "DYNAMICHOLDER";
         this._shake_container.addChild(this._dynamic_mc);
         this._game_window = new MovieClip();
         this._game_window.name = "GAME_WINDOW";
         this._game_window.addChild(this._shake_container);
         this._game_mc.addChild(this._game_window);
         slomo_rectangle = new MovieClip();
         this._game_mc.addChild(slomo_rectangle);
         gui_holder_mc = new gui_holder();
         gui_holder_mc.name = "GUI_HOLDER";
         this._game_mc.addChild(gui_holder_mc);
         if(gameData.pSetupData.totalPlayers > 4)
         {
            gui_holder_mc.gotoAndStop(2);
         }
         else
         {
            gui_holder_mc.gotoAndStop(1);
         }
         this._game_mc.addChild(this._press_space_indication);
         this._game_mc.addChild(this._external_links);
         this._game_mc.addChild(this._victory_text);
         this.HideSpaceIndication();
         this.HideExternalLinks();
         this.HideVictoryText();
         level_mc = new levels();
         level_mc.name = "LEVEL";
         level_mc.gotoAndStop(gameData.lvl);
         this._dynamic_mc.addChild(level_mc);
         mc_effects_behind = new MovieClip();
         mc_effects_behind.name = "EFFECTSBEHIND";
         this._dynamic_mc.addChild(mc_effects_behind);
         mc_objects = new MovieClip();
         mc_objects.name = "OBJECTS";
         this._dynamic_mc.addChild(mc_objects);
         mc_scrap = new MovieClip();
         mc_scrap.name = "SCRAP";
         this._dynamic_mc.addChild(mc_scrap);
         mc_players = new MovieClip();
         mc_players.name = "PLAYERS";
         this._dynamic_mc.addChild(mc_players);
         mc_weapons = new MovieClip();
         mc_weapons.name = "WEAPONS";
         this._dynamic_mc.addChild(mc_weapons);
         mc_effects = new MovieClip();
         mc_effects.name = "EFFECTS";
         this._dynamic_mc.addChild(mc_effects);
         mc_effects2 = new MovieClip();
         mc_effects2.name = "EFFECTS2";
         this._dynamic_mc.addChild(mc_effects2);
         mc_projectiles = new MovieClip();
         mc_projectiles.name = "PROJECTILES";
         this._dynamic_mc.addChild(mc_projectiles);
         mc_lazers = new MovieClip();
         mc_lazers.name = "LAZERS";
         this._dynamic_mc.addChild(mc_lazers);
         level_front_mc = new levels_front();
         level_front_mc.name = "LEVEL_FRONT";
         level_front_mc.gotoAndStop(gameData.lvl);
         this._dynamic_mc.addChild(level_front_mc);
         this._dynamic_gui_mc = new MovieClip();
         this._dynamic_gui_mc.name = "GUI";
         this._game_window.addChild(this._dynamic_gui_mc);
         this._Handler_BasicOverlays = new BasicOverlays(mc_lazers);
         this._Handler_Explosions = new Explosions();
         this._Handler_Deconstructer = new Deconstructer();
         this._Handler_Effects = new Effects(this._Handler_Output,MovieClip(this._dynamic_mc.getChildByName("EFFECTSBEHIND")),MovieClip(this._dynamic_mc.getChildByName("EFFECTS")),this._Handler_Options,this._Handler_Maps);
         this._Handler_Slowmo = new Slowmo(this._Handler_Output,this._Handler_Effects,this._Handler_Sounds,slomo_rectangle,this._stage);
         this._Handler_Shake = new Shake(this._Handler_Output,this._shake_container);
         this._Handler_Maps.UpdateMCs(this._static_mc,this._dynamic_mc,this._object_shape_container_mc);
         this._Handler_Maps.UpdateHandlers(this._Handler_Effects,this._Handler_Explosions,this._Handler_Sounds,this._Handler_BasicOverlays);
         this._ContactData = new ContactData();
         this._ContactData.Handler_Output = this._Handler_Output;
         this._ContactData.Handler_Effects = this._Handler_Effects;
         this._ContactData.Handler_Sounds = this._Handler_Sounds;
         this._ContactData.Handler_Deconstructer = this._Handler_Deconstructer;
         this._Handler_Maps.ConstructContactListener(this._ContactData);
         this.m_world = this._Handler_Maps.GetMap(gameData.lvl);
         this._Handler_WeaponSpawn = new WeaponSpawn(this._Handler_Output,this._Handler_Maps,this._Handler_Weapons);
         this._Handler_ProjectilesUpdater = new ProjectilesUpdater();
         this._Handler_Deconstructer.Setb2World = this.m_world;
         this._Handler_Box2DMouse = new Box2DMouse(this._Handler_Mouse,this.m_world,this._dynamic_mc);
         pData = new PlayersKeeperData();
         pData.stg = this._stage;
         pData.game_mc = this._game_mc;
         pData.Handler_Projectiles = this._Handler_ProjectilesUpdater;
         pData.Handler_Output = this._Handler_Output;
         pData.Handler_Keyboard = this._Handler_Keyboard;
         pData.Handler_Effects = this._Handler_Effects;
         pData.Handler_Maps = this._Handler_Maps;
         pData.Handler_Shake = this._Handler_Shake;
         pData.Handler_Sounds = this._Handler_Sounds;
         pData.Handler_Slowmo = this._Handler_Slowmo;
         pData.pathGrid = this._Handler_Maps.GetPathGrid(gameData.lvl);
         pData.rangedStartWeapon = this._Handler_Weapons.Pistol;
         pData.throwableStartWeapon = this._Handler_Weapons.Grenades;
         pData.meleeStartWeapon = null;
         pData.defaultMeleeWeapon = this._Handler_Weapons.Fists;
         pData.m_world = this.m_world;
         pData.pSetupData = gameData.pSetupData;
         pData.pSetupData.playerSpawnPositions = this._Handler_Maps.GetPlayerSpawnPositions(gameData.lvl);
         this._Handler_Players = new PlayersKeeper(pData);
         this._Handler_Maps.LinkPlayers(this._Handler_Players);
         this._Handler_Maps.LinkWeapons(this._Handler_Weapons);
         this._Handler_Camera = new Cam(this._stage,this._dynamic_mc,gui_holder_mc,this._Handler_MenuMain.MenuOverlay,this._Handler_Output,this._Handler_Players);
         this._Handler_Camera.SetMapArea(this._Handler_Maps.GetMinimumMapArea(gameData.lvl));
         this._Handler_Options.LinkToCam(this._Handler_Camera);
         this._Handler_Players.LinkToCam(this._Handler_Camera);
         this._Handler_Portals = new Portals(this.m_world,this._Handler_Players,this._Handler_Output);
         this._Handler_Portals.SetMapPortals(this._Handler_Maps.GetMapPortals(gameData.lvl));
         eData = new ExplosionData();
         eData.Handler_Output = this._Handler_Output;
         eData.Handler_Camera = this._Handler_Camera;
         eData.Handler_Shake = this._Handler_Shake;
         eData.Handler_Players = this._Handler_Players;
         eData.Handler_Effects = this._Handler_Effects;
         eData.Handler_Sounds = this._Handler_Sounds;
         eData.Handler_Slowmo = this._Handler_Slowmo;
         eData.static_mc = this._static_mc;
         eData.dynamic_mc = this._dynamic_mc;
         eData.m_world = this.m_world;
         this._Handler_Explosions.BuildClass(eData);
         this._Handler_Fires = new Fires(eData,this._object_shape_container_mc);
         this._Handler_Explosions.LinkToFire(this._Handler_Fires);
         this._Handler_Players.LinkToFire(this._Handler_Fires);
         this._Handler_Maps.Handler_WorldItems.LinkToFire(this._Handler_Fires);
         puData = new ProjectilesUpdaterData();
         puData.Handler_Output = this._Handler_Output;
         puData.Handler_Projectiles = this._Handler_Projectiles;
         puData.Handler_Camera = this._Handler_Camera;
         puData.Handler_Players = this._Handler_Players;
         puData.Handler_Effects = this._Handler_Effects;
         puData.Handler_Sounds = this._Handler_Sounds;
         puData.Handler_Explosions = this._Handler_Explosions;
         puData.static_mc = this._static_mc;
         puData.dynamic_mc = this._dynamic_mc;
         puData.object_shape_container_mc = this._object_shape_container_mc;
         puData.m_world = this.m_world;
         this._Handler_ProjectilesUpdater.BuildClass(puData);
         this._stage.addEventListener(Event.ENTER_FRAME,this.Update,false,0,true);
         this.m_world.DrawDebugData();
         this.m_world.FallAsleepBody = function(param1:b2Body):void
         {
            _Handler_Portals.CheckBodyInsidePortal(param1);
         };
         this._Handler_Commands.LinkHandlers(this._Handler_Maps,this._Handler_Box2DMouse,this._Handler_Keyboard,this._Handler_Effects,this._Handler_Sounds,this._Handler_Explosions,this._Handler_Fires,this._Handler_Weapons,this._Handler_Players);
         this._Handler_Commands.LinkFunctions(this.Restart);
         this._Handler_Maps.GetPathGrid().UpdateHandlers(this._Handler_Fires,this.m_world);
         this._countdownOver = true;
         this._bgNoise = null;
         if(gameData.isSurvival)
         {
            this._countdown_mc = new get_ready_fight();
            this._countdown_mc.x = 400;
            this._countdown_mc.y = 300;
            this._countdown_mc.scaleX = 4;
            this._countdown_mc.scaleY = 4;
            this._game_window.addChild(this._countdown_mc);
            this._countdown = this._countdown_mc.totalFrames - 1;
            this._Handler_Sounds.InMenu = false;
            this._game_window.visible = false;
            this._round_initialized = 2;
            this._countdownOver = false;
            this._Handler_Keyboard.AddHandler(27,this.BackToMainMenu);
            this._Handler_Keyboard.AddHandler(this._Handler_Keyboard.GetKeyCode("SPACE"),this.SpacePressed);
            this._Handler_Keyboard.AddHandler(this._Handler_Keyboard.GetKeyCode("UP"),this.SurvivalUpPressed);
            this._Handler_Keyboard.AddHandler(this._Handler_Keyboard.GetKeyCode("DOWN"),this.SurvivalDownPressed);
            this._scoreSurvival = new ScoreboardSurvival(this._game_mc);
            p = 0;
            while(p < this._Handler_Players.Players.length)
            {
               this._scoreSurvival.AddPlayerToScore(this._Handler_Players.Players[p]);
               p++;
            }
            this._scoreSurvival.Build();
            gui_holder_mc.addChild(this._scoreSurvival.MC);
            this._scoreSurvival.Hide();
         }
         else if(gameData.isTutorial)
         {
            this._countdown = 0;
            this._Handler_Sounds.InMenu = false;
            this._game_window.visible = false;
            this._round_initialized = 2;
            this._Handler_Keyboard.AddHandler(27,this.BackToMainMenu);
            this._Handler_Keyboard.AddHandler(this._Handler_Keyboard.GetKeyCode("SPACE"),this.SpacePressed);
            this._Handler_Players.ActivatePlayers();
            this._Handler_Camera.ShowAll = true;
         }
         else if(!gameData.isMenuDemo)
         {
            this._countdown_mc = new get_ready_fight();
            this._countdown_mc.x = 400;
            this._countdown_mc.y = 300;
            this._countdown_mc.scaleX = 4;
            this._countdown_mc.scaleY = 4;
            this._game_window.addChild(this._countdown_mc);
            this._countdown = this._countdown_mc.totalFrames - 1;
            this._Handler_Sounds.InMenu = false;
            this._game_window.visible = false;
            this._round_initialized = 2;
            this._countdownOver = false;
            this._Handler_Keyboard.AddHandler(27,this.BackToMainMenu);
            this._Handler_Keyboard.AddHandler(this._Handler_Keyboard.GetKeyCode("SPACE"),this.SpacePressed);
            if(this._prevGameData.newScore)
            {
               this._prevGameData.newScore = false;
               this._score = new Scoreboard(this._game_mc,this._prevGameData.gameMode);
               p2 = 0;
               while(p2 < this._Handler_Players.Players.length)
               {
                  this._score.AddPlayerToScore(this._Handler_Players.Players[p2]);
                  p2++;
               }
               this._score.Build();
            }
            gui_holder_mc.addChild(this._score.MC);
            this._score.Hide();
         }
         else
         {
            this._countdown = 0;
            this._game_window.visible = false;
            this._round_initialized = 2;
            this._Handler_Sounds.InMenu = true;
            this._Handler_Players.ActivatePlayers();
            this._bgNoise = new bg_noise();
            this._bgNoise.EFFECT_MC.gotoAndPlay(this._last_bgNoiseFrame);
            this._game_window.addChild(this._bgNoise);
            gui_holder_mc.visible = false;
            this._game_window.removeChild(this._dynamic_gui_mc);
            this._game_window.addChild(this._dynamic_gui_mc);
         }
         if(gameData.showTips)
         {
            this._tipsOver = false;
            this._game_mc.addChild(this._tips);
            this._tips.gotoAndStop(1 + Math.floor(Math.random() * (this._tips.totalFrames - 0.001)));
            this._Handler_Keyboard.AddHandler(this._Handler_Keyboard.GetKeyCode("LEFT"),function():*
            {
               ChangeTips(-1);
            });
            this._Handler_Keyboard.AddHandler(this._Handler_Keyboard.GetKeyCode("RIGHT"),function():*
            {
               ChangeTips(1);
            });
            this._countdown_mc.gotoAndStop(1);
            this._countdown_mc.visible = false;
            this.ShowSpaceIndication();
         }
         else
         {
            this._tipsOver = true;
         }
         this._roundOver = false;
         this._gameModeWinnerShown = false;
         this._game_window.scaleX = gameData.gameScale;
         this._game_window.scaleY = gameData.gameScale;
         this._game_window.x = gameData.gamePosX;
         this._game_window.y = gameData.gamePosY;
         this._Handler_Output.Trace("New Game Created");
      }
      
      private function SurvivalUpPressed() : void
      {
         if(IDI.IDNETOpen())
         {
            return;
         }
         if(Boolean(this._roundOver) && Boolean(this._prevGameData.isSurvival) && Boolean(this._gameModeWinnerShown))
         {
            this._scoreSurvival.UpPressed();
         }
      }
      
      private function SurvivalDownPressed() : void
      {
         if(IDI.IDNETOpen())
         {
            return;
         }
         if(Boolean(this._roundOver) && Boolean(this._prevGameData.isSurvival) && Boolean(this._gameModeWinnerShown))
         {
            this._scoreSurvival.DownPressed();
         }
      }
      
      private function SurvivalEscPressed() : void
      {
         IDI.IDNETCloseInterface();
      }
      
      private function TabPressed() : void
      {
         this._Handler_Slowmo.GamePaused = true;
         if(this._prevGameData.isSurvival)
         {
            this._scoreSurvival.Update(this._Handler_Maps.SurvivalTime,this._gameModeWinnerShown);
            this._scoreSurvival.Show();
         }
         else
         {
            this._score.Update();
            this._score.Show();
         }
      }
      
      private function TabReleased() : void
      {
         this._Handler_Slowmo.GamePaused = false;
         if(this._prevGameData.isSurvival)
         {
            this._scoreSurvival.Hide();
         }
         else
         {
            this._score.Hide();
         }
      }
      
      private function HideExternalLinks() : void
      {
         this._external_links.visible = false;
      }
      
      private function ShowExternalLinks() : void
      {
         this._external_links.visible = true;
      }
      
      private function HideSpaceIndication() : void
      {
         this._press_space_indication.visible = false;
      }
      
      private function ShowSpaceIndication() : void
      {
         this._press_space_indication.visible = true;
         this._press_space_indication.gotoAndPlay(1);
      }
      
      private function HideVictoryText() : void
      {
         this._victory_text.visible = false;
      }
      
      private function ShowVictoryText() : void
      {
         this._victory_text.visible = true;
      }
      
      private function ChangeTips(param1:int) : void
      {
         var _loc2_:int = 0;
         if(!this._tipsOver)
         {
            _loc2_ = this._tips.currentFrame + param1;
            if(_loc2_ <= 0)
            {
               _loc2_ = int(this._tips.totalFrames);
            }
            if(_loc2_ > this._tips.totalFrames)
            {
               _loc2_ = 1;
            }
            this._tips.gotoAndStop(_loc2_);
         }
      }
      
      private function BackToMainMenu() : void
      {
         this._stage.removeEventListener(Event.ENTER_FRAME,this.Update);
         this.Stop();
         this._Handler_MenuMain.OpenMenu();
      }
      
      private function ShowStatic() : void
      {
         this._dynamic_mc.alpha = 0.2;
         this._object_shape_container_mc.visible = true;
         this._static_mc.visible = true;
      }
      
      private function HideStatic() : void
      {
         this._dynamic_mc.alpha = 1;
         this._object_shape_container_mc.visible = false;
         this._static_mc.visible = false;
      }
      
      public function Stop() : void
      {
         this._Handler_Output.Trace("");
         this._Handler_Output.Trace("Stopping Game...");
         this._stage.removeEventListener(Event.ENTER_FRAME,this.Update);
         this._Handler_Keyboard.Deconstruct();
         this._Handler_Effects.Stop();
         this._Handler_Maps.Stop();
         this._Handler_Slowmo.Stop();
         this._Handler_Fires.Stop();
         this._Handler_Players.Stop();
         this.ClearMC(this._game_mc);
         this._Handler_Output.Trace("Game Stopped");
      }
      
      private function Restart(param1:Boolean = false) : void
      {
         this.Stop();
         this._Handler_Output.Trace("");
         this._Handler_Output.Trace("Restarting Game...");
         if(param1)
         {
            this._prevGameData.lvl += 1;
            if(this._prevGameData.lvl > 5)
            {
               this._prevGameData.lvl = 1;
            }
         }
         this._prevGameData.showTips = false;
         this.StartNewGame(this._prevGameData);
      }
      
      private function SpacePressed() : void
      {
         var _loc1_:String = null;
         var _loc2_:ScoreboardTeam = null;
         if(IDI.IDNETOpen())
         {
            return;
         }
         if(!this._tipsOver)
         {
            this._game_mc.removeChild(this._tips);
            this._tipsOver = true;
            this._countdown_mc.visible = true;
            this._countdown_mc.gotoAndPlay(1);
            this.HideSpaceIndication();
            this.HideExternalLinks();
            return;
         }
         if(this._roundOver)
         {
            if(this._prevGameData.isSurvival)
            {
               if(!this._gameModeWinnerShown)
               {
                  this._gameModeWinnerShown = true;
                  this._Handler_Keyboard.RemoveHandler(Keyboard.TAB);
                  this._Handler_Keyboard.RemoveHandler(27);
                  this._Handler_Keyboard.AddHandler(27,this.SurvivalEscPressed);
                  this.TabPressed();
                  this._Handler_Sounds.PlaySound("GROOVY",0,0);
                  this.HideSpaceIndication();
               }
               else
               {
                  _loc1_ = "Survival";
                  if(this._scoreSurvival.PlayerCount == 2)
                  {
                     _loc1_ = "Survival Co-op";
                  }
                  if(this._scoreSurvival.MarkerIndex == 0)
                  {
                     if(IDI.idnet)
                     {
                        IDI.idnet.advancedScoreSubmitList(this._scoreSurvival.CurrentTotalScore,_loc1_);
                     }
                  }
                  else if(this._scoreSurvival.MarkerIndex == 1)
                  {
                     if(IDI.idnet)
                     {
                        IDI.idnet.advancedScoreList(_loc1_);
                     }
                  }
                  else if(this._scoreSurvival.MarkerIndex == 2)
                  {
                     this.HideExternalLinks();
                     this.BackToMainMenu();
                  }
               }
            }
            else if(this._prevGameData.isTutorial)
            {
               this.HideExternalLinks();
               this.BackToMainMenu();
            }
            else if(this._score.GameFinished)
            {
               if(!this._gameModeWinnerShown)
               {
                  this._Handler_Keyboard.RemoveHandler(Keyboard.TAB);
                  this.TabPressed();
                  _loc2_ = this._score.GetTeamWinner();
                  if(_loc2_ == null)
                  {
                     this._victory_text.gotoAndStop("DRAW");
                  }
                  else if(_loc2_.Team > 0)
                  {
                     this._victory_text.gotoAndStop(_loc2_.Team);
                  }
                  else if(_loc2_.FirstPlayer.PlayerNr == 0)
                  {
                     this._victory_text.gotoAndStop("PLAYER_1");
                  }
                  else if(_loc2_.FirstPlayer.PlayerNr == 1 && !_loc2_.FirstPlayer.Bot)
                  {
                     this._victory_text.gotoAndStop("PLAYER_2");
                  }
                  else
                  {
                     this._victory_text.gotoAndStop("COM");
                  }
                  this.ShowVictoryText();
                  this._gameModeWinnerShown = true;
                  this._Handler_Sounds.PlaySound("GROOVY",0,0);
                  if(this._prevGameData.challengeNr != -1)
                  {
                     if(_loc2_.Team == 1)
                     {
                        if(SaveState.Data.stageLevelsFinished)
                        {
                           if(SaveState.Data.stageLevelsFinished[this._prevGameData.challengeNr] != true)
                           {
                              SaveState.Data.stageLevelsFinished[this._prevGameData.challengeNr] = true;
                              SaveState.Save();
                              if(Boolean(SaveState.Data.stageLevelsFinished[0]) && Boolean(SaveState.Data.stageLevelsFinished[1]) && Boolean(SaveState.Data.stageLevelsFinished[2]) && Boolean(SaveState.Data.stageLevelsFinished[3]))
                              {
                                 Achievements.EarnAchievement("Bronze Fighter");
                              }
                              if(Boolean(SaveState.Data.stageLevelsFinished[4]) && Boolean(SaveState.Data.stageLevelsFinished[5]) && Boolean(SaveState.Data.stageLevelsFinished[6]) && Boolean(SaveState.Data.stageLevelsFinished[7]))
                              {
                                 Achievements.EarnAchievement("Silver Fighter");
                              }
                              if(Boolean(SaveState.Data.stageLevelsFinished[8]) && Boolean(SaveState.Data.stageLevelsFinished[9]) && Boolean(SaveState.Data.stageLevelsFinished[10]) && Boolean(SaveState.Data.stageLevelsFinished[11]))
                              {
                                 Achievements.EarnAchievement("Gold Fighter");
                              }
                           }
                        }
                     }
                  }
               }
               else
               {
                  this.BackToMainMenu();
               }
            }
            else
            {
               this.HideVictoryText();
               this.Restart();
            }
         }
      }
      
      private function ClearMC(param1:MovieClip) : void
      {
         var _loc2_:* = param1.numChildren;
         while(_loc2_--)
         {
            param1.removeChildAt(_loc2_);
         }
      }
      
      private function Update(param1:Event) : void
      {
         var _loc2_:b2Body = null;
         var _loc3_:int = 0;
         if(this._round_initialized <= 0)
         {
            if(this._countdown > 0 && Boolean(this._tipsOver))
            {
               --this._countdown;
               if(this._countdown <= 0)
               {
                  this._countdown_mc.stop();
                  this._game_window.removeChild(this._countdown_mc);
               }
               else if(this._countdown == 15)
               {
                  this._countdownOver = true;
                  this._Handler_Players.ActivatePlayers();
                  if(!this._prevGameData.isMenuDemo)
                  {
                     this._Handler_Players.SetStartImmunity();
                     this._Handler_Keyboard.AddHandler(Keyboard.TAB,this.TabPressed,this.TabReleased);
                  }
               }
            }
         }
         if(DEBUG_MODE)
         {
            this._Handler_Box2DMouse.UpdateMouseWorld(new Point(this._dynamic_mc.x * this._prevGameData.gameScale + this._prevGameData.gamePosX,this._dynamic_mc.y * this._prevGameData.gameScale + this._prevGameData.gamePosY),this._dynamic_mc.scaleX * this._prevGameData.gameScale,this.m_timeStep);
            this._Handler_Box2DMouse.MouseDrag();
         }
         this._Handler_Slowmo.Update();
         this.m_timeStep = 1 / (30 / this._Handler_Slowmo.Slowmotion);
         this._ContactData.game_speed = this._Handler_Slowmo.Slowmotion;
         this._Handler_Maps.Handler_WorldItems.Lock();
         this.m_world.Step(this.m_timeStep,this.m_iterations);
         this._Handler_Maps.Handler_WorldItems.Unlock();
         this._bodyIndex = 0;
         while(this._bodyIndex < this.m_world.AllDynamicObjectList.length)
         {
            _loc2_ = this.m_world.AllDynamicObjectList[this._bodyIndex];
            _loc2_.m_userData.x = _loc2_.GetPosition().x * 30;
            _loc2_.m_userData.y = _loc2_.GetPosition().y * 30;
            _loc2_.m_userData.rotation = _loc2_.GetAngle() * (180 / Math.PI);
            if(_loc2_.m_userData.objectData.DrawShapeMC)
            {
               _loc2_.m_userData.objectData.ShapeMC.x = _loc2_.GetPosition().x * 30;
               _loc2_.m_userData.objectData.ShapeMC.y = _loc2_.GetPosition().y * 30;
               _loc2_.m_userData.objectData.ShapeMC.rotation = _loc2_.GetAngle() * (180 / Math.PI);
            }
            if(!_loc2_.m_userData.objectData.InPortal)
            {
               if(Boolean(_loc2_.m_userData.objectData.DrawHitBox) || Boolean(_loc2_.m_userData.objectData.DrawCloudBox))
               {
                  _loc2_.m_userData.objectData.CollisionMC.x = _loc2_.m_userData.objectData.ShapeMC.x;
                  _loc2_.m_userData.objectData.CollisionMC.y = _loc2_.m_userData.objectData.ShapeMC.y;
                  _loc2_.m_userData.objectData.CollisionMC.rotation = _loc2_.m_userData.objectData.ShapeMC.rotation;
               }
            }
            if(_loc2_.IsFrozen())
            {
               this._Handler_Output.Trace("Object " + _loc2_.GetUserData().IDNumber + " out of bounds. Removing object");
               this.m_world.RemoveObjectFromLists(_loc2_);
               _loc2_.m_userData.destroyed = true;
               _loc2_.m_userData.objectData.HP = 0;
               if(Boolean(_loc2_.m_userData.objectData.DrawHitBox) || Boolean(_loc2_.m_userData.objectData.DrawCloudBox))
               {
                  _loc2_.m_userData.objectData.CollisionMC.parent.removeChild(_loc2_.m_userData.objectData.CollisionMC);
               }
               if(_loc2_.m_userData.objectData.DrawShapeMC)
               {
                  _loc2_.m_userData.objectData.ShapeMC.parent.removeChild(_loc2_.m_userData.objectData.ShapeMC);
               }
               _loc2_.m_userData.parent.removeChild(_loc2_.m_userData);
               this.m_world.DestroyBody(_loc2_);
            }
            else
            {
               _loc2_.m_userData.objectData.UpdateFunction(_loc2_,this._Handler_Slowmo.Slowmotion);
            }
            this._bodyIndex += 1;
         }
         this._Handler_Maps.UpdatePathGrid();
         this._Handler_Shake.Update(this._Handler_Slowmo.Slowmotion);
         if(this._countdownOver)
         {
            this._Handler_WeaponSpawn.Update(this._Handler_Slowmo.Slowmotion);
         }
         this._Handler_Players.Update(this._Handler_Slowmo.Slowmotion);
         this._Handler_ProjectilesUpdater.Update(this._Handler_Slowmo.Slowmotion);
         this._Handler_Fires.Update(this._Handler_Slowmo.Slowmotion);
         this._Handler_Explosions.Update(this._Handler_Slowmo.Slowmotion);
         this._Handler_Deconstructer.Update();
         this._Handler_Portals.Update();
         this._Handler_Camera.Update(this._camera_speed);
         this._Handler_Maps.Update(this._Handler_Slowmo.Slowmotion);
         this._Handler_BasicOverlays.Update();
         this._Handler_Sounds.Update(this._Handler_Slowmo.Slowmotion);
         this._dynamic_gui_mc.x = this._dynamic_mc.x;
         this._dynamic_gui_mc.y = this._dynamic_mc.y;
         this._dynamic_gui_mc.scaleX = this._dynamic_mc.scaleX;
         this._dynamic_gui_mc.scaleY = this._dynamic_mc.scaleY;
         this._dynamic_gui_mc.x += this._shake_container.x * (1 / this._dynamic_mc.scaleX);
         this._dynamic_gui_mc.y += this._shake_container.y * (1 / this._dynamic_mc.scaleY);
         if(this._bgNoise != null)
         {
            this._bgNoise.scaleX = 1 / this._game_window.scaleX;
            this._bgNoise.scaleY = 1 / this._game_window.scaleY;
            this._bgNoise.x = -this._game_window.x * this._bgNoise.scaleX;
            this._bgNoise.y = -this._game_window.y * this._bgNoise.scaleY;
            this._bgNoise.x -= 400 * (this._Handler_MenuMain.MenuOverlay.scaleX - 1) * this._bgNoise.scaleX;
            this._bgNoise.y -= 300 * (this._Handler_MenuMain.MenuOverlay.scaleY - 1) * this._bgNoise.scaleY;
            this._bgNoise.scaleX *= this._Handler_MenuMain.MenuOverlay.scaleX;
            this._bgNoise.scaleY *= this._Handler_MenuMain.MenuOverlay.scaleY;
            this._last_bgNoiseFrame = this._bgNoise.EFFECT_MC.currentFrame;
         }
         if(Boolean(this._external_links) && Boolean(this._external_links.visible))
         {
            if(this._Handler_MenuMain.MenuOverlay.scaleY > 1 || this._Handler_MenuMain.MenuOverlay.scaleX > 1)
            {
               this._external_links.scaleX = 1;
               this._external_links.scaleY = 1;
               this._external_links.x = this._Handler_MenuMain.MenuOverlay.x;
               this._external_links.y = this._Handler_MenuMain.MenuOverlay.y - (1 - this._Handler_MenuMain.MenuOverlay.scaleY) * 600;
            }
            else
            {
               this._external_links.scaleX = this._Handler_MenuMain.MenuOverlay.scaleX;
               this._external_links.scaleY = this._Handler_MenuMain.MenuOverlay.scaleY;
               this._external_links.x = this._Handler_MenuMain.MenuOverlay.x;
               this._external_links.y = this._Handler_MenuMain.MenuOverlay.y;
            }
         }
         if(DEBUG_MODE)
         {
            if(this._Handler_Keyboard.KeyIsDown(16))
            {
               this._Handler_Commands.PrintMenu();
            }
         }
         if(Boolean(this._Handler_Players.RoundOver) && !this._roundOver)
         {
            if(Boolean(this._prevGameData.isTutorial) || Boolean(this._prevGameData.isSurvival))
            {
               if(this._Handler_Maps.MapOver)
               {
                  this._roundOver = true;
                  if(this._prevGameData.isSurvival)
                  {
                     this.ShowSpaceIndication();
                     this.ShowExternalLinks();
                  }
                  else if(this._prevGameData.isTutorial)
                  {
                     this.ShowExternalLinks();
                  }
               }
               return;
            }
            this._roundOver = true;
            if(this._prevGameData.isMenuDemo)
            {
               this.Stop();
               this._Handler_MenuMain.StartMenuGame();
            }
            else
            {
               this._score.RoundsFinished += 1;
               _loc3_ = int(this._Handler_Players.GetTeamWinner());
               switch(_loc3_)
               {
                  case -1:
                     this._victory_text.gotoAndStop("DRAW");
                     break;
                  case 0:
                     this._score.ScoreTeam(this._Handler_Players.GetSoloWinner());
                     switch(this._Handler_Players.GetPlayerNrWinner())
                     {
                        case 0:
                           this._victory_text.gotoAndStop("PLAYER_1");
                           break;
                        case 1:
                           if(this._Handler_Players.Players[this._Handler_Players.GetPlayerNrWinner()].Bot)
                           {
                              this._victory_text.gotoAndStop("COM");
                           }
                           else
                           {
                              this._victory_text.gotoAndStop("PLAYER_2");
                           }
                           break;
                        default:
                           this._victory_text.gotoAndStop("COM");
                     }
                     break;
                  default:
                     this._score.ScoreTeam(this._Handler_Players.GetTeamWinner());
                     this._victory_text.gotoAndStop(this._Handler_Players.GetTeamWinner());
               }
               this.ShowVictoryText();
               this.ShowSpaceIndication();
               this.ShowExternalLinks();
            }
         }
         if(this._round_initialized > 0)
         {
            --this._round_initialized;
            if(this._round_initialized <= 0)
            {
               this._game_window.visible = true;
            }
         }
      }
   }
}

