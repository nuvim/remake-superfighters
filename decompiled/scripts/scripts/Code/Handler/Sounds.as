package Code.Handler
{
   import flash.events.*;
   import flash.media.*;
   
   public class Sounds
   {
      
      private var _Handler_Output:OutputTrace;
      
      private var _sounds:Array = new Array();
      
      private var _mighty_sounds:Array = new Array();
      
      private var _sound_effect_volume:Number = 0.8;
      
      private var _inMenu:Boolean = false;
      
      private var _lastSlowmo:Number = 0;
      
      private var menu_channel:SoundChannel;
      
      private var menu_channelTransform:SoundTransform;
      
      private var menu_song:Sound;
      
      private var ambient_channel:SoundChannel;
      
      private var ambient_channelTransform:SoundTransform;
      
      private var ambient_song:Sound;
      
      public function Sounds(param1:OutputTrace)
      {
         super();
         this._Handler_Output = param1;
         this.menu_song = new superfighters_theme();
         this.ambient_song = new ambient_loop_1();
         this.playAmbient();
         this.stopAmbient();
         this._sounds.push(["SHELLBOUNCE",2,[new shellbounce00(),new shellbounce01()]]);
         this._sounds.push(["BARREL_EXPLOSION",1,[new explosion00(),new explosion01(),new explosion02(),new explosion03()]]);
         this._sounds.push(["MELEE_HIT",1,[new punch00(),new punch01(),new punch02(),new punch03()]]);
         this._sounds.push(["MELEE_SWING",4,[new svisch4(),new svisch6()]]);
         this._sounds.push(["KICK_SWING",4,[new svisch4(),new svisch6()]]);
         this._sounds.push(["KATANA_HIT",1,[new cut00(),new cut01(),new cut02()]]);
         this._sounds.push(["KICK",1,[new punch00(),new punch01(),new punch02(),new punch03()]]);
         this._sounds.push(["STAIRBOUNCE",1,[new punch00(),new punch01(),new punch02(),new punch03()]]);
         this._sounds.push(["OBJECTBOUNCE",1,[new punch00(),new punch01(),new punch02(),new punch03()]]);
         this._sounds.push(["JUMP",0.06,[new jump_00()]]);
         this._sounds.push(["ROLL",0.75,[new roll()]]);
         this._sounds.push(["DIVE_CATCH",0.7,[new dive_catch()]]);
         this._sounds.push(["BODYFALL",1,[new punch00(),new punch01(),new punch02(),new punch03()]]);
         this._sounds.push(["PISTOL_AIM",1,[new aim_small()]]);
         this._sounds.push(["PISTOL_FIRE",1,[new gun00(),new gun01(),new gun02(),new gun03()]]);
         this._sounds.push(["RIFLE_AIM",1,[new rifle_draw()]]);
         this._sounds.push(["RIFLE_FIRE",1,[new rifle00(),new rifle01()]]);
         this._sounds.push(["UZI_AIM",1,[new aim_small()]]);
         this._sounds.push(["UZI_FIRE",1,[new uzi00(),new uzi01()]]);
         this._sounds.push(["MAGNUM_AIM",1,[new aim_small()]]);
         this._sounds.push(["MAGNUM_FIRE",1,[new magnum()]]);
         this._sounds.push(["BAZOOKA_AIM",1,[new bazooka_aim()]]);
         this._sounds.push(["BAZOOKA_FIRE",1,[new bazooka()]]);
         this._sounds.push(["FLAMETHROWER_AIM",1,[new bazooka_aim()]]);
         this._sounds.push(["FLAMETHROWER_FIRE",1,[new fireplosion()]]);
         this._sounds.push(["SHOTGUN_AIM",1,[new shotgun_aim()]]);
         this._sounds.push(["SHOTGUN_FIRE",1,[new shotgun00(),new shotgun01(),new shotgun02()]]);
         this._sounds.push(["SHOTGUN_PUMP_P1",1,[new shotgun_pump_p1()]]);
         this._sounds.push(["SHOTGUN_PUMP_P2",1,[new shotgun_pump_p2()]]);
         this._sounds.push(["SNIPER_AIM",1,[new rifle_draw()]]);
         this._sounds.push(["SNIPER_FIRE",1,[new sniper00(),new sniper01()]]);
         this._sounds.push(["COMP_EXPLODE",0.6,[new comp_explode_01(),new comp_explode_02()]]);
         this._sounds.push(["BULLET_HITWOOD",1,[new wood_impact00()]]);
         this._sounds.push(["BULLET_HITDEFAULT",1,[new ric00()]]);
         this._sounds.push(["BULLET_HITMETAL",0.65,[new bullet_hitmetal_01(),new bullet_hitmetal_02(),new bullet_hitmetal_03(),new bullet_hitmetal_04(),new bullet_hitmetal_05()]]);
         this._sounds.push(["BULLET_HITFLESH",0.55,[new bullet_hit_1(),new bullet_hit_2(),new bullet_hit_3()]]);
         this._sounds.push(["NOAMMO_LIGHT",1,[new outofammo_light()]]);
         this._sounds.push(["NOAMMO_HEAVY",1,[new outofammo_heavy()]]);
         this._sounds.push(["ROCKET_EXPLOSION",1,[new explosion00(),new explosion01(),new explosion02(),new explosion03()]]);
         this._sounds.push(["BUSTWOOD",1,[new bustwood_1(),new bustwood_2()]]);
         this._sounds.push(["FIREBURST",1,[new fireplosion()]]);
         this._sounds.push(["MELEE_GRAB",1,[new katana_01()]]);
         this._sounds.push(["GRENADE_SAFE",1,[new grenade_safe()]]);
         this._sounds.push(["HEARTBEAT",1.5,[new heartbeat()]]);
         this._sounds.push(["GIB",1,[new gib_00()]]);
         this._sounds.push(["GET_HEALTH",0.5,[new getHealth_00()]]);
         this._sounds.push(["BUSTGLASS",1,[new glass_1()]]);
         this._sounds.push(["BUSTMOLOTOV",1,[new glass_2()]]);
         this._sounds.push(["ELECTRIC_SPARK",0.4,[new voltage_02()]]);
         this._sounds.push(["GROOVY",0.6,[new groovy00()]]);
         this._sounds.push(["WILHELM",1,[new wilhelm()]]);
         this._mighty_sounds.push(["ACCEPT",1,[new accept_02()]]);
         this._mighty_sounds.push(["CANCEL",1,[new cancel_02()]]);
         this._mighty_sounds.push(["ACHIEVEMENT",1,[new achievement_sound()]]);
         this._Handler_Output.Trace("Sounds Created");
         this.StopAllSounds();
      }
      
      public function get InMenu() : Boolean
      {
         return this._inMenu;
      }
      
      public function set InMenu(param1:Boolean) : void
      {
         if(this._inMenu != param1)
         {
            this._inMenu = param1;
            if(param1)
            {
               this.stopAmbient();
               this.playMusic();
            }
            else
            {
               this.stopMusic();
               this.playAmbient();
            }
         }
      }
      
      private function stopMusic() : void
      {
         this.menu_channel.stop();
         this.menu_channel.removeEventListener(Event.SOUND_COMPLETE,this.loopMusic);
      }
      
      private function playMusic() : void
      {
         this.menu_channel = this.menu_song.play();
         this.menu_channel.addEventListener(Event.SOUND_COMPLETE,this.loopMusic);
         this.menu_channelTransform = this.menu_channel.soundTransform;
         this.menu_channelTransform.volume = this._sound_effect_volume;
         this.menu_channel.soundTransform = this.menu_channelTransform;
      }
      
      private function loopMusic(param1:Event) : void
      {
         this.stopMusic();
         this.playMusic();
      }
      
      private function stopAmbient() : void
      {
         this.ambient_channel.stop();
         this.ambient_channel.removeEventListener(Event.SOUND_COMPLETE,this.loopAmbient);
      }
      
      private function playAmbient() : void
      {
         this.ambient_channel = this.ambient_song.play();
         this.ambient_channel.addEventListener(Event.SOUND_COMPLETE,this.loopAmbient);
         this.setAmbientVolume();
      }
      
      private function setAmbientVolume() : void
      {
         this.ambient_channelTransform = this.ambient_channel.soundTransform;
         this.ambient_channelTransform.volume = this._sound_effect_volume * this._lastSlowmo * 0.1;
         this.ambient_channel.soundTransform = this.ambient_channelTransform;
      }
      
      private function loopAmbient(param1:Event) : void
      {
         this.stopAmbient();
         this.playAmbient();
      }
      
      public function Update(param1:Number) : void
      {
         if(!this._inMenu)
         {
            if(this._lastSlowmo != param1)
            {
               this._lastSlowmo = param1;
               this.setAmbientVolume();
            }
         }
      }
      
      public function PlaySoundAt_Box2DScale(param1:String, param2:Number, param3:Number) : void
      {
         this.PlaySoundAt(param1,param2 * 30,param3 * 30);
      }
      
      public function PlaySoundAt(param1:String, param2:Number, param3:Number) : void
      {
         this.PlaySound(param1,param2,param3);
      }
      
      public function PlaySound(param1:String, param2:Number, param3:Number) : void
      {
         var _loc4_:SoundChannel = null;
         var _loc7_:SoundTransform = null;
         if(param1 == "" || param1.toUpperCase() == "NONE" || this._sound_effect_volume <= 0 || this.InMenu)
         {
            return;
         }
         var _loc5_:String = param1.toUpperCase();
         var _loc6_:int = 0;
         while(_loc6_ < this._sounds.length)
         {
            if(this._sounds[_loc6_][0] == _loc5_)
            {
               if(this._sounds[_loc6_][2].length > 1)
               {
                  _loc4_ = this._sounds[_loc6_][2][Math.round(Math.random() * (this._sounds[_loc6_][2].length - 1))].play();
               }
               else
               {
                  _loc4_ = this._sounds[_loc6_][2][0].play();
               }
               _loc7_ = _loc4_.soundTransform;
               _loc7_.volume = this._sounds[_loc6_][1] * this._sound_effect_volume;
               _loc4_.soundTransform = _loc7_;
               return;
            }
            _loc6_++;
         }
         this._Handler_Output.Trace("Sound \'" + param1.toUpperCase() + "\' not found");
      }
      
      public function PlayMightySound(param1:String) : void
      {
         var _loc2_:SoundChannel = null;
         var _loc5_:SoundTransform = null;
         var _loc3_:String = param1.toUpperCase();
         var _loc4_:int = 0;
         while(_loc4_ < this._mighty_sounds.length)
         {
            if(this._mighty_sounds[_loc4_][0] == _loc3_)
            {
               if(this._mighty_sounds[_loc4_][2].length > 1)
               {
                  _loc2_ = this._mighty_sounds[_loc4_][2][Math.round(Math.random() * (this._mighty_sounds[_loc4_][2].length - 1))].play();
               }
               else
               {
                  _loc2_ = this._mighty_sounds[_loc4_][2][0].play();
               }
               _loc5_ = _loc2_.soundTransform;
               _loc5_.volume = this._mighty_sounds[_loc4_][1] * this._sound_effect_volume;
               _loc2_.soundTransform = _loc5_;
               return;
            }
            _loc4_++;
         }
         this._Handler_Output.Trace("MightySound \'" + param1.toUpperCase() + "\' not found");
      }
      
      public function ChangeEffectVolume(param1:Number) : void
      {
         this._sound_effect_volume += param1;
         if(this._sound_effect_volume > 1)
         {
            this._sound_effect_volume = 1;
         }
         if(this._sound_effect_volume < 0)
         {
            this._sound_effect_volume = 0;
         }
         this.menu_channelTransform = this.menu_channel.soundTransform;
         this.menu_channelTransform.volume = this._sound_effect_volume;
         this.menu_channel.soundTransform = this.menu_channelTransform;
      }
      
      public function get SoundEffectVolume() : Number
      {
         return this._sound_effect_volume;
      }
      
      public function set SoundEffectVolume(param1:Number) : void
      {
         this._sound_effect_volume = param1;
      }
      
      public function StopAllSounds() : void
      {
         SoundMixer.stopAll();
      }
      
      public function ChangeVolume(param1:Number) : void
      {
         var _loc2_:SoundTransform = new SoundTransform();
         _loc2_.volume = param1;
         SoundMixer.soundTransform = _loc2_;
      }
   }
}

