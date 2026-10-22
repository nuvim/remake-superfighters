import os
import subprocess
import sys
import re

FFDEC = os.path.abspath("tools/ffdec/ffdec-cli.exe")
BASE_SWF = os.path.abspath("archive/superfighters-flash-game/superfighters.swf")
OUT_SWF = os.path.abspath("tools/oracle_superfighters.swf")

SCRIPTS_DIR = os.path.abspath("decompiled/scripts/scripts")
MAINTIMELINE_AS = os.path.join(SCRIPTS_DIR, "Superfighters_y8_idnet_locked_fp12_fla/MainTimeline.as")
PLAYER_AS = os.path.join(SCRIPTS_DIR, "Code/Data/Players/Player.as")
MENUMAIN_AS = os.path.join(SCRIPTS_DIR, "Code/Handler/MenuMain.as")
PLAYERSKEEPER_AS = os.path.join(SCRIPTS_DIR, "Code/Handler/PlayersKeeper.as")
PATHGRID_AS = os.path.join(SCRIPTS_DIR, "Code/Handler/PathGrid.as")
PLAYERBARS_AS = os.path.join(SCRIPTS_DIR, "Code/Data/Players/PlayerBars.as")
SCOREBOARDTEAM_AS = os.path.join(SCRIPTS_DIR, "Code/Data/ScoreboardTeam.as")
PLAYERANIMATION_AS = os.path.join(SCRIPTS_DIR, "Code/Data/Players/PlayerAnimation.as")

TEMP_DIR = os.path.abspath("tools/temp_oracle")
os.makedirs(TEMP_DIR, exist_ok=True)

def prepare_patched_scripts():
    # 1. MainTimeline.as
    with open(MAINTIMELINE_AS, "r", encoding="utf-8") as f:
        mt = f.read()

    mt = re.sub(
        r'public function checkSiteLockValid\(param1:Array\)\s*:\s*Boolean\s*\{[\s\S]*?return true;\s*\}',
        'public function checkSiteLockValid(param1:Array) : Boolean { return true; }',
        mt
    )

    mt = re.sub(
        r'internal function frame1\(\)\s*:\s*\*[\s\S]*?this\.loaderInfo\.addEventListener\(ProgressEvent\.PROGRESS,this\.LoadingProgress\);\s*\}',
        '''internal function frame1() : *
      {
         if (this._game != null || this.m_gameIsRunning)
         {
            stop();
            return;
         }
         trace("ORACLE: frame1 entered, directly instantiating Main!");
         this.m_lastFrame = -1;
         this.m_gameIsRunning = true;
         this._game = new Main(stage,this);
         stop();
      }''',
        mt
    )

    patched_mt = os.path.join(TEMP_DIR, "MainTimeline.as")
    with open(patched_mt, "w", encoding="utf-8") as f:
        f.write(mt)

    # 2. MenuMain.as
    with open(MENUMAIN_AS, "r", encoding="utf-8") as f:
        mm = f.read()

    mm = re.sub(
        r'public function StartMenuGame\(\)\s*:\s*void\s*\{[\s\S]*?this\._Handler_GameMain\.StartNewGame\(_loc3_\);\s*\}',
        '''private var _oracleGameStarted:Boolean = false;

      public function StartMenuGame() : void
      {
         if (this._oracleGameStarted)
         {
            return;
         }
         this._oracleGameStarted = true;
         this._player_choosen_skins = new Array();
         var _loc1_:PlayerSetupData = new PlayerSetupData();
         _loc1_.ot = this._Handler_Output;
         _loc1_.characters = new Array(1,0,0,0,0,0,0,0);
         _loc1_.totalPlayers = 1;
         _loc1_.teams = new Array(0,0,0,0,0,0,0,0);
         _loc1_.ai = new Array(1,0,0,0,0,0,0,0); // Human player 1
         _loc1_.keys = this._Handler_Options.GetPlayerKeys();
         _loc1_.aiDifficulty = new Array(3,3,3,3,3,3,3,3);
         var _loc3_:NewGameData = new NewGameData();
         _loc3_.lvl = 2; // STORAGE
         _loc3_.pSetupData = _loc1_;
         _loc3_.gameScale = 1.0;
         _loc3_.gamePosX = 0;
         _loc3_.gamePosY = 0;
         _loc3_.challengeNr = -1;
         _loc3_.isMenuDemo = false;
         _loc3_.isTutorial = false;
         _loc3_.isSurvival = false;
         _loc3_.showTips = false;
         _loc3_.newScore = true;
         _loc3_.gameMode = 0;
         this._Handler_GameMain.StartNewGame(_loc3_);
      }''',
        mm
    )
    mm = mm.replace('this._menu_overlay.link_4.addEventListener(MouseEvent.CLICK,this.Link4);', '// link_4 disabled')
    mm = mm.replace("this._stage.addChild(this._menu_overlay);", "// this._stage.addChild(this._menu_overlay);")
    mm = mm.replace(
        'MovieClip(param1[_loc2_]).visible = false;',
        'if(param1[_loc2_] != null) { MovieClip(param1[_loc2_]).visible = false; }'
    )
    mm = mm.replace(
        'MovieClip(param1[_loc2_]).visible = true;',
        'if(param1[_loc2_] != null) { MovieClip(param1[_loc2_]).visible = true; }'
    )

    patched_mm = os.path.join(TEMP_DIR, "MenuMain.as")
    with open(patched_mm, "w", encoding="utf-8") as f:
        f.write(mm)

    # 3. PlayersKeeper.as
    with open(PLAYERSKEEPER_AS, "r", encoding="utf-8") as f:
        pk = f.read()

    # Wrap GUI holder access in safe try-catch
    pk = re.sub(
        r'this\.gui_holder_mc\.player_1\.visible = false;[\s\S]*?this\.gui_holder_mc\.com_6\.visible = false;',
        '''if (this.gui_holder_mc != null) {
            try { this.gui_holder_mc.player_1.visible = false; } catch(e:*) {}
            try { this.gui_holder_mc.player_2.visible = false; } catch(e:*) {}
            try { this.gui_holder_mc.com_no_players.visible = false; } catch(e:*) {}
            try { this.gui_holder_mc.com_0.visible = false; } catch(e:*) {}
            try { this.gui_holder_mc.com_1.visible = false; } catch(e:*) {}
            try { this.gui_holder_mc.com_2.visible = false; } catch(e:*) {}
            try { this.gui_holder_mc.com_3.visible = false; } catch(e:*) {}
            try { this.gui_holder_mc.com_4.visible = false; } catch(e:*) {}
            try { this.gui_holder_mc.com_5.visible = false; } catch(e:*) {}
            try { this.gui_holder_mc.com_6.visible = false; } catch(e:*) {}
         }''',
        pk
    )

    pk = pk.replace(
        'this._players[_loc4_].SetGUI(MovieClip(this.gui_holder_mc.getChildByName("player_" + this._playerSetupData.ai[_loc4_])));',
        'try { this._players[_loc4_].SetGUI(MovieClip(this.gui_holder_mc.getChildByName("player_" + this._playerSetupData.ai[_loc4_]))); } catch(e:*) {}'
    )
    pk = pk.replace(
        'this._players[_loc4_].SetGUI(MovieClip(this.gui_holder_mc.getChildByName("com_no_players")));',
        'try { this._players[_loc4_].SetGUI(MovieClip(this.gui_holder_mc.getChildByName("com_no_players"))); } catch(e:*) {}'
    )
    pk = pk.replace(
        'this._players[_loc4_].SetGUI(MovieClip(this.gui_holder_mc.getChildByName("com_" + _loc3_)));',
        'try { this._players[_loc4_].SetGUI(MovieClip(this.gui_holder_mc.getChildByName("com_" + _loc3_))); } catch(e:*) {}'
    )
    pk = pk.replace(
        'this._players[_loc4_].UpdateGUI();',
        'try { this._players[_loc4_].UpdateGUI(); } catch(e:*) {}'
    )

    patched_pk = os.path.join(TEMP_DIR, "PlayersKeeper.as")
    with open(patched_pk, "w", encoding="utf-8") as f:
        f.write(pk)

    # 4. PathGrid.as
    with open(PATHGRID_AS, "r", encoding="utf-8") as f:
        pg = f.read()

    pg = pg.replace('public function AnalyzeGrid() : void\n      {', 'public function AnalyzeGrid() : void\n      {\n         if(this.m_world == null) return;')

    patched_pg = os.path.join(TEMP_DIR, "PathGrid.as")
    with open(patched_pg, "w", encoding="utf-8") as f:
        f.write(pg)

    # 5. PlayerBars.as
    with open(PLAYERBARS_AS, "r", encoding="utf-8") as f:
        pb = f.read()

    # Guard SetGUI
    pb = re.sub(
        r'public function SetGUI\(param1:MovieClip\)\s*:\s*void\s*\{[\s\S]*?this\._gui_mc\.addChild\(this\._gui_bars_mc\);\s*\}',
        '''public function SetGUI(param1:MovieClip) : void
      {
         this._gui_mc = param1;
         if(this._gui_mc == null) return;
         this._gui_bars_mc = new MovieClip();
         if(this._gui_mc.bars_start != null) {
            this._gui_bars_mc.x = this._gui_mc.bars_start.x;
            this._gui_bars_mc.y = this._gui_mc.bars_start.y;
         }
         this._gui_mc.addChild(this._gui_bars_mc);
      }''',
        pb
    )

    # Guard DrawGUIBars
    pb = pb.replace('public function DrawGUIBars() : void\n      {', 'public function DrawGUIBars() : void\n      {\n         if(this._gui_mc == null || this._gui_bars_mc == null) return;')

    # Guard SetSign
    pb = re.sub(
        r'public function SetSign\(param1:int\)\s*:\s*void\s*\{[\s\S]*?this\._gui_mc\.sign\.transform\.colorTransform = this\._player_sign\.transform\.colorTransform;\s*\}',
        '''public function SetSign(param1:int) : void
      {
         if(this._player_sign == null) return;
         switch(param1)
         {
            case PLAYER_COM:
               this._player_sign.gotoAndStop(3);
               if(this._gui_mc != null && this._gui_mc.sign != null) this._gui_mc.sign.gotoAndStop(3);
               this._player_sign_text = false;
               break;
            case PLAYER_1:
               this._player_sign.gotoAndStop(1);
               if(this._gui_mc != null && this._gui_mc.sign != null) this._gui_mc.sign.gotoAndStop(1);
               this._player_sign_text = true;
               break;
            case PLAYER_2:
               this._player_sign.gotoAndStop(2);
               if(this._gui_mc != null && this._gui_mc.sign != null) this._gui_mc.sign.gotoAndStop(2);
               this._player_sign_text = true;
         }
         if(this._gui_mc != null && this._gui_mc.sign != null) {
            this._gui_mc.sign.transform.colorTransform = this._player_sign.transform.colorTransform;
         }
      }''',
        pb
    )

    patched_pb = os.path.join(TEMP_DIR, "PlayerBars.as")
    with open(patched_pb, "w", encoding="utf-8") as f:
        f.write(pb)

    # 6. ScoreboardTeam.as
    with open(SCOREBOARDTEAM_AS, "r", encoding="utf-8") as f:
        st = f.read()

    st = st.replace(
        'public function Build(param1:int) : void\n      {',
        'public function Build(param1:int) : void\n      {\n         try {'
    )
    st = st.replace(
        'this._build_timer = setInterval(this.SetPics,100);\n         this.Update();\n      }',
        'this._build_timer = setInterval(this.SetPics,100);\n         this.Update();\n         } catch(e:*) {} }'
    )
    st = st.replace(
        'public function Update() : void\n      {',
        'public function Update() : void\n      {\n         try {'
    )
    st = st.replace(
        'this.SetNumTo(this._team_graphic.score.loss,this.Loss);\n      }',
        'this.SetNumTo(this._team_graphic.score.loss,this.Loss);\n         } catch(e:*) {} }'
    )
    st = st.replace(
        'public function SetPics() : void\n      {',
        'public function SetPics() : void\n      {\n         try {'
    )
    st = st.replace(
        '_loc1_++;\n         }\n      }',
        '_loc1_++;\n         }\n         } catch(e:*) {} }'
    )

    patched_st = os.path.join(TEMP_DIR, "ScoreboardTeam.as")
    with open(patched_st, "w", encoding="utf-8") as f:
        f.write(st)

    # 6b. Scoreboard.as
    SCOREBOARD_AS = os.path.join(SCRIPTS_DIR, "Code/Handler/Scoreboard.as")
    with open(SCOREBOARD_AS, "r", encoding="utf-8") as f:
        sb = f.read()

    sb = sb.replace(
        'this._score_info.game_mode.gotoAndStop(this._gameMode);',
        'try { this._score_info.game_mode.gotoAndStop(this._gameMode); } catch(e:*) {}'
    )
    sb = sb.replace(
        'this._score_info.rounds.text = "0";',
        'try { this._score_info.rounds.text = "0"; } catch(e:*) {}'
    )
    sb = sb.replace(
        'this._score_info.rounds.text = this.RoundsFinished.toString();',
        'try { this._score_info.rounds.text = this.RoundsFinished.toString(); } catch(e:*) {}'
    )
    patched_sb = os.path.join(TEMP_DIR, "Scoreboard.as")
    with open(patched_sb, "w", encoding="utf-8") as f:
        f.write(sb)

    # 6c. Achievements.as
    ACHIEVEMENTS_AS = os.path.join(SCRIPTS_DIR, "Code/Handler/Achievements.as")
    with open(ACHIEVEMENTS_AS, "r", encoding="utf-8") as f:
        ac = f.read()

    ac = ac.replace(
        'private static function InitGraphic() : void\n      {',
        'private static function InitGraphic() : void\n      {\n         try {'
    )
    ac = ac.replace(
        '_graphic.gotoAndStop(1);\n         }\n      }',
        '_graphic.gotoAndStop(1);\n         }\n         } catch(e:*) {} }'
    )
    ac = ac.replace(
        'public static function Position(param1:Number, param2:Number, param3:Number, param4:Number) : void\n      {',
        'public static function Position(param1:Number, param2:Number, param3:Number, param4:Number) : void\n      {\n         try {\n            if(_graphic == null) return;'
    )
    ac = ac.replace(
        '_graphic.y = param4;\n         }\n      }',
        '_graphic.y = param4;\n         }\n         } catch(e:*) {} }'
    )
    patched_ac = os.path.join(TEMP_DIR, "Achievements.as")
    with open(patched_ac, "w", encoding="utf-8") as f:
        f.write(ac)

    # 6d. GameMain.as
    GAMEMAIN_AS = os.path.join(SCRIPTS_DIR, "Code/Handler/GameMain.as")
    with open(GAMEMAIN_AS, "r", encoding="utf-8") as f:
        gm = f.read()

    gm = gm.replace(
        'public function StartNewGame(param1:NewGameData) : void\n      {',
        '''public function StartNewGame(param1:NewGameData) : void
      {
         try { if(this._stage != null) this._stage.removeEventListener(Event.ENTER_FRAME, this.Update); } catch(e:*) {}'''
    )
    patched_gm = os.path.join(TEMP_DIR, "GameMain.as")
    with open(patched_gm, "w", encoding="utf-8") as f:
        f.write(gm)

    # 7. PlayerAnimation.as
    with open(PLAYERANIMATION_AS, "r", encoding="utf-8") as f:
        pa = f.read()

    pa = pa.replace('public var UseGUI:Boolean = true;', 'public var UseGUI:Boolean = false;')

    pa = re.sub(
        r'public function ShowAnimation\(param1:String, param2:Boolean = false\)\s*:\s*void\s*\{[\s\S]*?public function ProgressAnimation\(',
        '''public function ShowAnimation(param1:String, param2:Boolean = false) : void
      {
         try
         {
            if(this._current_animation != param1.toUpperCase() || param2)
            {
               this._current_animation = param1.toUpperCase();
               if(param2)
               {
                  this._this.gotoAndStop("IDLE");
                  if(this.UseGUI)
                  {
                     this._this_gui.gotoAndStop("IDLE");
                     this._blood_gui.gotoAndStop("IDLE");
                  }
                  this._collision_mc.gotoAndStop("IDLE");
                  this._blood.gotoAndStop("IDLE");
               }
               if(param1 == "")
               {
                  param1 = "IDLE";
               }
               this._this.gotoAndStop(param1.toUpperCase());
               if(this.UseGUI)
               {
                  this._this_gui.gotoAndStop(param1.toUpperCase());
                  this._blood_gui.gotoAndStop(param1.toUpperCase());
               }
               this._collision_mc.gotoAndStop(param1.toUpperCase());
               this._blood.gotoAndStop(param1.toUpperCase());
               this._current_frame = 0;
               this._aim_animation = false;
               this._animation_done = false;
               this._loop_animation = false;
               this._help_animation = false;
               this._grabbed_player_updated = false;
               this._disable_slowmotion_modifier = false;
               this._is_rocket_ride = false;
               switch(param1.toUpperCase())
               {
                  case "ROCKET_RIDE_L":
                  case "ROCKET_RIDE_R":
                     this._is_rocket_ride = true;
                     this._loop_animation = true;
                     break;
                  case "AIM_TURN":
                     this._disable_slowmotion_modifier = true;
                     break;
                  case "CLIMB":
                  case "IDLE":
                  case "STAGGER":
                  case "SPRINT":
                  case "GRABBED":
                  case "RUN":
                     this._loop_animation = true;
                     break;
                  case "DIVE":
                     this._help_animation = true;
                     this._loop_animation = true;
                     this._rotate_speed = 1.5;
                     this._rotate_increase = 0;
                     break;
                  case "FALL_B":
                  case "FALL_F":
                     this._help_animation = true;
                     this._loop_animation = true;
                     if(param1.toUpperCase() == "FALL_B")
                     {
                        this._rotate_speed = -10;
                        this._rotate_increase = -2;
                     }
                     else
                     {
                        this._rotate_speed = 10;
                        this._rotate_increase = 2;
                     }
                     break;
                  default:
                     if(param1.toUpperCase().substr(0,3) == "AIM")
                     {
                        this._aim_animation = true;
                        this._loop_animation = true;
                     }
                     if(param1.toUpperCase().substr(0,5) == "START")
                     {
                        this._disable_slowmotion_modifier = true;
                     }
               }
            }
         }
         catch(e:*) {}
      }
      
      public function ProgressAnimation(''',
        pa
    )

    patched_pa = os.path.join(TEMP_DIR, "PlayerAnimation.as")
    with open(patched_pa, "w", encoding="utf-8") as f:
        f.write(pa)

    # 8. Player.as
    with open(PLAYER_AS, "r", encoding="utf-8") as f:
        pl = f.read()

    # Guard GUI scaleX
    pl = pl.replace(
        'this._char_gui.scaleX = this.scaleX;\n               this._blood_gui.scaleX = this.scaleX;',
        'if(this._char_gui != null) this._char_gui.scaleX = this.scaleX;\n               if(this._blood_gui != null) this._blood_gui.scaleX = this.scaleX;'
    )

    pl = pl.replace(
        'this._this_x += _loc4_ * this._game_speed;\n            if(this._PlayerState.OnGround)\n            {\n               this.UpdateSimpleGroundMovement(false);\n            }',
        '''this._this_x += _loc4_ * this._game_speed;
            if(this._PlayerState.OnGround)
            {
               this.UpdateSimpleGroundMovement(false);
            }
            if(this.playerTick == 67 || this.playerTick == 68)
            {
               trace("STEP:" + this.playerTick + "," + _loc5_ + "," + this._this_x + "," + this._this_y + ",cfm:" + this.CollisionFeetMid() + ",cfm01:" + this.CollisionFeetMid(0,1) + ",canLand:" + this.CanLandInMid());
            }'''
    )

    # Lock Player 0 spawn in Initialize
    pl = pl.replace(
        'public function Initialize(param1:PlayerAreaData) : void\n      {\n         this._MapArea = param1;',
        '''public function Initialize(param1:PlayerAreaData) : void
      {
         this._MapArea = param1;
         if (this.PlayerNr == 0)
         {
            this.x = 120;
            this.y = 255;
         }'''
    )

    # Intercept UpdateEventPC for player 0
    pl = pl.replace(
        'if(!this._bot)\n         {\n            this.UpdateEventPC();\n         }',
        '''if(!this._bot)
         {
            if(this._players != null && this._players.length > 0 && this == this._players[0])
            {
               this.ApplyScenarioInput();
            }
            else
            {
               this.UpdateEventPC();
            }
         }'''
    )

    # Instance tick variable and ApplyScenarioInput
    scenario_methods = '''
      public var playerTick:int = 0;

      public function ApplyScenarioInput() : void
      {
         var curTick:int = this.playerTick;
         for (var k:int = 0; k < this._keyPressed.length; k++) {
            this._keyPressed[k] = false;
         }

         // Scenario 1: idle (0..60) -> no keys pressed

         // Scenario 2: walk_right (60..180)
         if (curTick >= 60 && curTick < 180)
         {
            if (curTick == 60)
            {
               this.x = 120;
               this.y = 254.5;
               this._this_x = 120;
               this._this_y = 254.5;
               this._old_this_x = 120;
               this._old_this_y = 254.5;
               this._PlayerState.AirVelocityX = 0;
               this._PlayerState.AirVelocityY = 0;
               this._PlayerState.Jumping = false;
               this._PlayerState.Falling = false;
            }
            if (curTick < 160)
            {
               this._keyPressed[3] = true; // Key right
            }
         }
         // Scenario 3: jump_standing (180..260)
         else if (curTick >= 180 && curTick < 260)
         {
            if (curTick == 180)
            {
               this.x = 120;
               this.y = 254.5;
               this._this_x = 120;
               this._this_y = 254.5;
               this._old_this_x = 120;
               this._old_this_y = 254.5;
               this._PlayerState.AirVelocityX = 0;
               this._PlayerState.AirVelocityY = 0;
               this._PlayerState.Jumping = false;
               this._PlayerState.Falling = false;
            }
            if (curTick == 190)
            {
               this.Jump();
            }
            if (curTick >= 190 && curTick < 194)
            {
               this._keyPressed[0] = true; // Jump held
               this._keyPressed[8] = true;
            }
         }
         // Scenario 4: jump_run (260..380)
         else if (curTick >= 260 && curTick < 380)
         {
            if (curTick == 260)
            {
               this.x = 120;
               this.y = 254.5;
               this._this_x = 120;
               this._this_y = 254.5;
               this._old_this_x = 120;
               this._old_this_y = 254.5;
               this._PlayerState.AirVelocityX = 0;
               this._PlayerState.AirVelocityY = 0;
               this._PlayerState.Jumping = false;
               this._PlayerState.Falling = false;
            }
            if (curTick < 350)
            {
               this._keyPressed[3] = true; // Key right
            }
            if (curTick == 280)
            {
               this.Jump();
            }
            if (curTick >= 280 && curTick < 284)
            {
               this._keyPressed[0] = true; // Jump held
               this._keyPressed[8] = true;
            }
         }
         // Scenario 5: walk_stair_down (380..500)
         else if (curTick >= 380 && curTick < 500)
         {
            if (curTick == 380)
            {
               this.x = 120;
               this.y = 254.5;
               this._this_x = 120;
               this._this_y = 254.5;
               this._old_this_x = 120;
               this._old_this_y = 254.5;
               this._PlayerState.AirVelocityX = 0;
               this._PlayerState.AirVelocityY = 0;
               this._PlayerState.Jumping = false;
               this._PlayerState.Falling = false;
            }
            if (curTick < 480)
            {
               this._keyPressed[2] = true; // Key left (down stair)
            }
         }
      }
'''
    last_brace = pl.rfind("}")
    last_second_brace = pl.rfind("}", 0, last_brace)
    pl = pl[:last_second_brace] + scenario_methods + "\n" + pl[last_second_brace:]

    # Inject tick trace at the end of Player.Update
    target_str = """         this._PlayerAnimation.ProgressAnimation(this._game_speed);
         this._PlayerBars.Update(this.x,this.y,this._dynamic_mc.scaleX);"""
    trace_call = """         try { this._PlayerAnimation.ProgressAnimation(this._game_speed); } catch(e:*) {}
         try { this._PlayerBars.Update(this.x,this.y,this._dynamic_mc.scaleX); } catch(e:*) {}
         if (this._players != null && this._players.length > 0 && this == this._players[0])
         {
            var curTick:int = this.playerTick;
            var scName:String = "idle";
            if (curTick < 60) scName = "idle";
            else if (curTick < 180) scName = "walk_right";
            else if (curTick < 260) scName = "jump_standing";
            else if (curTick < 380) scName = "jump_run";
            else if (curTick < 500) scName = "walk_stair_down";
            else scName = "done";

            trace("T," + scName + "," + curTick + "," + this._this_x + "," + this._this_y + "," + this._PlayerState.AirVelocityX + "," + this._PlayerState.AirVelocityY + "," + (this._PlayerState.OnGround ? 1 : 0) + "," + (this._PlayerState.Jumping ? 1 : 0) + "," + (this._PlayerState.Falling ? 1 : 0));
            this.playerTick++;
         }"""
    pl = pl.replace(target_str, trace_call)

    patched_pl = os.path.join(TEMP_DIR, "Player.as")
    with open(patched_pl, "w", encoding="utf-8") as f:
        f.write(pl)

    return patched_mt, patched_mm, patched_pk, patched_pg, patched_pb, patched_st, patched_sb, patched_ac, patched_gm, patched_pa, patched_pl

if __name__ == "__main__":
    mt, mm, pk, pg, pb, st, sb, ac, gm, pa, pl = prepare_patched_scripts()
    print(f"Patched scripts prepared in {TEMP_DIR}")
    
    cmd = [
        FFDEC,
        "-replace",
        BASE_SWF,
        OUT_SWF,
        "Superfighters_y8_idnet_locked_fp12_fla.MainTimeline", mt,
        "Code.Handler.MenuMain", mm,
        "Code.Handler.PlayersKeeper", pk,
        "Code.Handler.PathGrid", pg,
        "Code.Data.Players.PlayerBars", pb,
        "Code.Data.ScoreboardTeam", st,
        "Code.Handler.Scoreboard", sb,
        "Code.Handler.Achievements", ac,
        "Code.Handler.GameMain", gm,
        "Code.Data.Players.PlayerAnimation", pa,
        "Code.Data.Players.Player", pl
    ]
    print("Running FFDec replacement...")
    res = subprocess.run(cmd, capture_output=True, text=True)
    print("STDOUT:", res.stdout)
    if res.stderr:
        print("STDERR:", res.stderr)
    if res.returncode == 0 and os.path.exists(OUT_SWF):
        print(f"SUCCESS: Oracle SWF created at {OUT_SWF} ({os.path.getsize(OUT_SWF)} bytes)")
    else:
        print(f"FAILED with code {res.returncode}")
        sys.exit(1)

