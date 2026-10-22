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
        '''public function StartMenuGame() : void
      {
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
    patched_ac = os.path.join(TEMP_DIR, "Achievements.as")
    with open(patched_ac, "w", encoding="utf-8") as f:
        f.write(ac)

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

    # Streamed hitmap dumper (30 lines per tick) + tick tracing
    hitmap_method = '''
      public static var dbgTick:int = 0;
      public static var hitmapY:int = -60;
      public static var hitmapMode:int = 0; // 0: world, 1: cloud, 2: ladder, 3: done

      public function DumpHitMap() : void
      {
         if (hitmapMode >= 3) return;
         try
         {
            if (hitmapMode == 0)
            {
               if (hitmapY == -60) trace("START_HITMAP_WORLD");
               for (var i:int = 0; i < 30 && hitmapY < 700; i++, hitmapY++)
               {
                  var row:String = "";
                  for (var xx:int = 0; xx < 1050; xx++)
                  {
                     row += (this._static_world_hitbox_mc.hitTestPoint(xx * 0.5, hitmapY * 0.5, true) ? "1" : "0");
                  }
                  trace("HMW," + hitmapY + "," + row);
               }
               if (hitmapY >= 700)
               {
                  trace("END_HITMAP_WORLD");
                  hitmapMode = 1;
                  hitmapY = -60;
               }
            }
            else if (hitmapMode == 1)
            {
               if (hitmapY == -60) trace("START_HITMAP_CLOUD");
               for (var ic:int = 0; ic < 30 && hitmapY < 700; ic++, hitmapY++)
               {
                  var rowc:String = "";
                  for (var xxc:int = 0; xxc < 1050; xxc++)
                  {
                     rowc += (this._static_world_cloud_hitbox_mc.hitTestPoint(xxc * 0.5, hitmapY * 0.5, true) ? "1" : "0");
                  }
                  trace("HMC," + hitmapY + "," + rowc);
               }
               if (hitmapY >= 700)
               {
                  trace("END_HITMAP_CLOUD");
                  hitmapMode = 2;
                  hitmapY = -60;
               }
            }
            else if (hitmapMode == 2)
            {
               if (hitmapY == -60) trace("START_HITMAP_LADDER");
               for (var il:int = 0; il < 30 && hitmapY < 700; il++, hitmapY++)
               {
                  var rowl:String = "";
                  for (var xxl:int = 0; xxl < 1050; xxl++)
                  {
                     rowl += (this._static_ladder_hitbox_mc.hitTestPoint(xxl * 0.5, hitmapY * 0.5, true) ? "1" : "0");
                  }
                  trace("HML," + hitmapY + "," + rowl);
               }
               if (hitmapY >= 700)
               {
                  trace("END_HITMAP_LADDER");
                  hitmapMode = 3;
                  trace("END_HITMAP");
               }
            }
         }
         catch (e:*)
         {
            trace("HITMAP_ERR: " + e);
         }
      }
'''
    last_brace = pl.rfind("}")
    last_second_brace = pl.rfind("}", 0, last_brace)
    pl = pl[:last_second_brace] + hitmap_method + "\n" + pl[last_second_brace:]

    # Inject DumpHitMap and tick trace at the end of Player.Update
    target_str = """         this._PlayerAnimation.ProgressAnimation(this._game_speed);
         this._PlayerBars.Update(this.x,this.y,this._dynamic_mc.scaleX);"""
    trace_call = """         try { this._PlayerAnimation.ProgressAnimation(this._game_speed); } catch(e:*) {}
         try { this._PlayerBars.Update(this.x,this.y,this._dynamic_mc.scaleX); } catch(e:*) {}
         this.DumpHitMap();
         trace("T," + (Player.dbgTick++) + "," + this._this_x + "," + this._this_y + "," + this._PlayerState.AirVelocityX + "," + this._PlayerState.AirVelocityY + "," + (this._PlayerState.OnGround ? 1 : 0) + "," + (this._PlayerState.Jumping ? 1 : 0) + "," + (this._PlayerState.Falling ? 1 : 0));"""
    pl = pl.replace(target_str, trace_call)

    patched_pl = os.path.join(TEMP_DIR, "Player.as")
    with open(patched_pl, "w", encoding="utf-8") as f:
        f.write(pl)

    return patched_mt, patched_mm, patched_pk, patched_pg, patched_pb, patched_st, patched_sb, patched_ac, patched_pa, patched_pl

if __name__ == "__main__":
    mt, mm, pk, pg, pb, st, sb, ac, pa, pl = prepare_patched_scripts()
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
