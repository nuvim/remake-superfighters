package Code.Handler
{
   import Code.Box2D.Common.Math.*;
   
   public class CommandList
   {
      
      private var _debug:Boolean;
      
      private var _Handler_Output:OutputTrace;
      
      private var _Handler_Maps:Maps;
      
      private var _Handler_Box2DMouse:Box2DMouse;
      
      private var _Handler_Keyboard:InputKeyboard;
      
      private var _Handler_Effects:Effects;
      
      private var _Handler_Sounds:Sounds;
      
      private var _Handler_Explosions:Explosions;
      
      private var _Handler_Fires:Fires;
      
      private var _Handler_Weapons:Weapons;
      
      private var _Handler_Players:PlayersKeeper;
      
      private var _Restart:Function;
      
      private var _curr_menu:int = 0;
      
      private var _menu:Array = new Array([["Spawn Object",function():*
      {
         this._curr_menu = 4;
         this.PrintMenu();
      }],["Spawn Weapon",function():*
      {
         this._curr_menu = 1;
         this.PrintMenu();
      }],["Trigger Explosion",function():*
      {
         this._Handler_Sounds.PlaySoundAt_Box2DScale("barrel_explosion",this._Handler_Box2DMouse.GetMouseXWorldPhys(),this._Handler_Box2DMouse.GetMouseYWorldPhys());
         this._Handler_Explosions.TriggerExplosionAt_Box2DScale("",this._Handler_Box2DMouse.GetMouseXWorldPhys(),this._Handler_Box2DMouse.GetMouseYWorldPhys());
      }],["Trigger Fire",function():*
      {
         this._Handler_Sounds.PlaySoundAt_Box2DScale("fireburst",this._Handler_Box2DMouse.GetMouseXWorldPhys(),this._Handler_Box2DMouse.GetMouseYWorldPhys());
         this._Handler_Fires.TriggerFireAt_Box2DScale("",this._Handler_Box2DMouse.GetMouseXWorldPhys(),this._Handler_Box2DMouse.GetMouseYWorldPhys());
      }],["Destroy Object",function():*
      {
         this._Handler_Box2DMouse.MouseDestroy();
      }]],[["Prev",function():*
      {
         this._curr_menu = 3;
         this.PrintMenu();
      }],["Next",function():*
      {
         this._curr_menu = 2;
         this.PrintMenu();
      }],["Pistol",function():*
      {
         var _loc1_:* = this._Handler_Maps.Handler_WorldItems.AddPolygon("wpn_pistol",this._Handler_Box2DMouse.GetMouseXWorldPhys(),this._Handler_Box2DMouse.GetMouseYWorldPhys(),0,new b2Vec2(),0);
         _loc1_.GetUserData().weaponData = this._Handler_Weapons.Pistol;
      }],["Rifle",function():*
      {
         var _loc1_:* = this._Handler_Maps.Handler_WorldItems.AddPolygon("wpn_rifle",this._Handler_Box2DMouse.GetMouseXWorldPhys(),this._Handler_Box2DMouse.GetMouseYWorldPhys(),0,new b2Vec2(),0);
         _loc1_.GetUserData().weaponData = this._Handler_Weapons.Rifle;
      }],["Shotgun",function():*
      {
         var _loc1_:* = this._Handler_Maps.Handler_WorldItems.AddPolygon("wpn_shotgun",this._Handler_Box2DMouse.GetMouseXWorldPhys(),this._Handler_Box2DMouse.GetMouseYWorldPhys(),0,new b2Vec2(),0);
         _loc1_.GetUserData().weaponData = this._Handler_Weapons.Shotgun;
      }],["Sniper",function():*
      {
         var _loc1_:* = this._Handler_Maps.Handler_WorldItems.AddPolygon("wpn_sniper",this._Handler_Box2DMouse.GetMouseXWorldPhys(),this._Handler_Box2DMouse.GetMouseYWorldPhys(),0,new b2Vec2(),0);
         _loc1_.GetUserData().weaponData = this._Handler_Weapons.Sniper;
      }],["Bazooka",function():*
      {
         var _loc1_:* = this._Handler_Maps.Handler_WorldItems.AddPolygon("wpn_bazooka",this._Handler_Box2DMouse.GetMouseXWorldPhys(),this._Handler_Box2DMouse.GetMouseYWorldPhys(),0,new b2Vec2(),0);
         _loc1_.GetUserData().weaponData = this._Handler_Weapons.Bazooka;
      }],["Flamethrower",function():*
      {
         var _loc1_:* = this._Handler_Maps.Handler_WorldItems.AddPolygon("wpn_flamethrower",this._Handler_Box2DMouse.GetMouseXWorldPhys(),this._Handler_Box2DMouse.GetMouseYWorldPhys(),0,new b2Vec2(),0);
         _loc1_.GetUserData().weaponData = this._Handler_Weapons.Flamethrower;
      }]],[["Prev",function():*
      {
         this._curr_menu = 1;
         this.PrintMenu();
      }],["Next",function():*
      {
         this._curr_menu = 3;
         this.PrintMenu();
      }],["Grenades",function():*
      {
         var _loc1_:* = this._Handler_Maps.Handler_WorldItems.AddPolygon("wpn_grenades",this._Handler_Box2DMouse.GetMouseXWorldPhys(),this._Handler_Box2DMouse.GetMouseYWorldPhys(),0,new b2Vec2(),0);
         _loc1_.GetUserData().weaponData = this._Handler_Weapons.Grenades;
      }],["Molotovs",function():*
      {
         var _loc1_:* = this._Handler_Maps.Handler_WorldItems.AddPolygon("wpn_molotovs",this._Handler_Box2DMouse.GetMouseXWorldPhys(),this._Handler_Box2DMouse.GetMouseYWorldPhys(),0,new b2Vec2(),0);
         _loc1_.GetUserData().weaponData = this._Handler_Weapons.Molotovs;
      }],["Axe",function():*
      {
         var _loc1_:* = this._Handler_Maps.Handler_WorldItems.AddPolygon("wpn_axe",this._Handler_Box2DMouse.GetMouseXWorldPhys(),this._Handler_Box2DMouse.GetMouseYWorldPhys(),0,new b2Vec2(),0);
         _loc1_.GetUserData().weaponData = this._Handler_Weapons.Axe;
      }],["Machete",function():*
      {
         var _loc1_:* = this._Handler_Maps.Handler_WorldItems.AddPolygon("wpn_machete",this._Handler_Box2DMouse.GetMouseXWorldPhys(),this._Handler_Box2DMouse.GetMouseYWorldPhys(),0,new b2Vec2(),0);
         _loc1_.GetUserData().weaponData = this._Handler_Weapons.Machete;
      }],["Sword",function():*
      {
         var _loc1_:* = this._Handler_Maps.Handler_WorldItems.AddPolygon("wpn_sword",this._Handler_Box2DMouse.GetMouseXWorldPhys(),this._Handler_Box2DMouse.GetMouseYWorldPhys(),0,new b2Vec2(),0);
         _loc1_.GetUserData().weaponData = this._Handler_Weapons.Sword;
      }],["Slowmotion (5)",function():*
      {
         var _loc1_:* = this._Handler_Maps.Handler_WorldItems.AddPolygon("wpn_slowmo_05",this._Handler_Box2DMouse.GetMouseXWorldPhys(),this._Handler_Box2DMouse.GetMouseYWorldPhys(),0,new b2Vec2(),0);
         _loc1_.GetUserData().weaponData = this._Handler_Weapons.Slowmo05;
      }],["Slowmotion (10)",function():*
      {
         var _loc1_:* = this._Handler_Maps.Handler_WorldItems.AddPolygon("wpn_slowmo_10",this._Handler_Box2DMouse.GetMouseXWorldPhys(),this._Handler_Box2DMouse.GetMouseYWorldPhys(),0,new b2Vec2(),0);
         _loc1_.GetUserData().weaponData = this._Handler_Weapons.Slowmo10;
      }]],[["Prev",function():*
      {
         this._curr_menu = 2;
         this.PrintMenu();
      }],["Next",function():*
      {
         this._curr_menu = 1;
         this.PrintMenu();
      }],["Pills",function():*
      {
         var _loc1_:* = this._Handler_Maps.Handler_WorldItems.AddPolygon("wpn_pills",this._Handler_Box2DMouse.GetMouseXWorldPhys(),this._Handler_Box2DMouse.GetMouseYWorldPhys(),0,new b2Vec2(),0);
         _loc1_.GetUserData().weaponData = this._Handler_Weapons.Pills;
      }],["Medkit",function():*
      {
         var _loc1_:* = this._Handler_Maps.Handler_WorldItems.AddPolygon("wpn_medkit",this._Handler_Box2DMouse.GetMouseXWorldPhys(),this._Handler_Box2DMouse.GetMouseYWorldPhys(),0,new b2Vec2(),0);
         _loc1_.GetUserData().weaponData = this._Handler_Weapons.Medkit;
      }],["Magnum",function():*
      {
         var _loc1_:* = this._Handler_Maps.Handler_WorldItems.AddPolygon("wpn_magnum",this._Handler_Box2DMouse.GetMouseXWorldPhys(),this._Handler_Box2DMouse.GetMouseYWorldPhys(),0,new b2Vec2(),0);
         _loc1_.GetUserData().weaponData = this._Handler_Weapons.Magnum;
      }],["Uzi",function():*
      {
         var _loc1_:* = this._Handler_Maps.Handler_WorldItems.AddPolygon("wpn_uzi",this._Handler_Box2DMouse.GetMouseXWorldPhys(),this._Handler_Box2DMouse.GetMouseYWorldPhys(),0,new b2Vec2(),0);
         _loc1_.GetUserData().weaponData = this._Handler_Weapons.Uzi;
      }]],[["Prev",function():*
      {
         this._curr_menu = 5;
         this.PrintMenu();
      }],["Next",function():*
      {
         this._curr_menu = 5;
         this.PrintMenu();
      }],["Barrel",function():*
      {
         this._Handler_Maps.Handler_WorldItems.AddObject("barrel",this._Handler_Box2DMouse.GetMouseXWorldPhys(),this._Handler_Box2DMouse.GetMouseYWorldPhys(),0,new b2Vec2(),0);
      }],["Barrel Explosive",function():*
      {
         this._Handler_Maps.Handler_WorldItems.AddObject("barrel_explosive",this._Handler_Box2DMouse.GetMouseXWorldPhys(),this._Handler_Box2DMouse.GetMouseYWorldPhys(),0,new b2Vec2(),0);
      }],["Barrel Wreck",function():*
      {
         this._Handler_Maps.Handler_WorldItems.AddObject("barrel_wreck",this._Handler_Box2DMouse.GetMouseXWorldPhys(),this._Handler_Box2DMouse.GetMouseYWorldPhys(),0,new b2Vec2(),0);
      }],["Crate",function():*
      {
         this._Handler_Maps.Handler_WorldItems.AddObject("crate",this._Handler_Box2DMouse.GetMouseXWorldPhys(),this._Handler_Box2DMouse.GetMouseYWorldPhys(),0,new b2Vec2(),0);
      }],["Table",function():*
      {
         this._Handler_Maps.Handler_WorldItems.AddObject("table",this._Handler_Box2DMouse.GetMouseXWorldPhys(),this._Handler_Box2DMouse.GetMouseYWorldPhys(),0,new b2Vec2(),0);
      }],["Comfy Chair",function():*
      {
         this._Handler_Maps.Handler_WorldItems.AddObject("comfy_chair",this._Handler_Box2DMouse.GetMouseXWorldPhys(),this._Handler_Box2DMouse.GetMouseYWorldPhys(),0,new b2Vec2(),0);
      }],["Trashcan",function():*
      {
         this._Handler_Maps.Handler_WorldItems.AddObject("Trashcan",this._Handler_Box2DMouse.GetMouseXWorldPhys(),this._Handler_Box2DMouse.GetMouseYWorldPhys(),0,new b2Vec2(),0);
      }]],[["Prev",function():*
      {
         this._curr_menu = 4;
         this.PrintMenu();
      }],["Next",function():*
      {
         this._curr_menu = 4;
         this.PrintMenu();
      }],["Gascan",function():*
      {
         this._Handler_Maps.Handler_WorldItems.AddObject("gascan",this._Handler_Box2DMouse.GetMouseXWorldPhys(),this._Handler_Box2DMouse.GetMouseYWorldPhys(),0,new b2Vec2(),0);
      }],["Filecab",function():*
      {
         this._Handler_Maps.Handler_WorldItems.AddObject("filecab",this._Handler_Box2DMouse.GetMouseXWorldPhys(),this._Handler_Box2DMouse.GetMouseYWorldPhys(),0,new b2Vec2(),0);
      }],["Pool Table",function():*
      {
         this._Handler_Maps.Handler_WorldItems.AddObject("pool_table",this._Handler_Box2DMouse.GetMouseXWorldPhys(),this._Handler_Box2DMouse.GetMouseYWorldPhys(),0,new b2Vec2(),0);
      }],["Beachball",function():*
      {
         this._Handler_Maps.Handler_WorldItems.AddObject("beachball",this._Handler_Box2DMouse.GetMouseXWorldPhys(),this._Handler_Box2DMouse.GetMouseYWorldPhys(),0,new b2Vec2(),0);
      }],["Rolling Pipe",function():*
      {
         this._Handler_Maps.Handler_WorldItems.AddObject("rolling_pipe",this._Handler_Box2DMouse.GetMouseXWorldPhys(),this._Handler_Box2DMouse.GetMouseYWorldPhys(),0,new b2Vec2(),0);
      }],["Statue Globe",function():*
      {
         var _loc1_:* = this._Handler_Maps.Handler_WorldItems.AddObject("statue_globe",this._Handler_Box2DMouse.GetMouseXWorldPhys(),this._Handler_Box2DMouse.GetMouseYWorldPhys() - 30 / 30,0,new b2Vec2(),0);
         _loc1_.PutToSleep();
         var _loc2_:* = this._Handler_Maps.Handler_WorldItems.AddObject("statue",this._Handler_Box2DMouse.GetMouseXWorldPhys(),this._Handler_Box2DMouse.GetMouseYWorldPhys() - 9 / 30,0,new b2Vec2(),0);
         _loc2_.PutToSleep();
      }]],[["Holder",function():*
      {
      }],["Holder",function():*
      {
      }]],[["Holder",function():*
      {
      }],["Holder",function():*
      {
      }]],[["Holder",function():*
      {
      }],["Holder",function():*
      {
      }]],[["Holder",function():*
      {
      }],["Holder",function():*
      {
      }]]);
      
      public function CommandList(param1:OutputTrace, param2:Boolean)
      {
         super();
         this._Handler_Output = param1;
         this._debug = param2;
      }
      
      public function LinkFunctions(param1:Function) : void
      {
         this._Restart = param1;
      }
      
      public function LinkHandlers(param1:Maps, param2:Box2DMouse, param3:InputKeyboard, param4:Effects, param5:Sounds, param6:Explosions, param7:Fires, param8:Weapons, param9:PlayersKeeper) : void
      {
         var _loc10_:int = 0;
         this._Handler_Maps = param1;
         this._Handler_Box2DMouse = param2;
         this._Handler_Keyboard = param3;
         this._Handler_Effects = param4;
         this._Handler_Sounds = param5;
         this._Handler_Explosions = param6;
         this._Handler_Fires = param7;
         this._Handler_Weapons = param8;
         this._Handler_Players = param9;
         if(this._debug)
         {
            this._Handler_Keyboard.AddHandler(16,this.ShowList,this.HideList);
            _loc10_ = 49;
            while(_loc10_ < 58)
            {
               this._Handler_Keyboard.AddHandler(_loc10_,this.CallMethod);
               _loc10_++;
            }
         }
      }
      
      private function CallMethod() : void
      {
         var _loc1_:int = 0;
         if(this._Handler_Keyboard.KeyIsDown(16))
         {
            _loc1_ = 0;
            while(_loc1_ < this._menu[this._curr_menu].length)
            {
               if(this._Handler_Keyboard.KeyIsDown(49 + _loc1_))
               {
                  this._menu[this._curr_menu][_loc1_][1]();
               }
               _loc1_++;
            }
         }
      }
      
      public function PrintMenu() : void
      {
         this._Handler_Output.Clear();
         var _loc1_:* = int(this._menu[this._curr_menu].length - 1);
         while(_loc1_ >= 0)
         {
            if(this._menu[this._curr_menu][_loc1_][0] != "")
            {
               this._Handler_Output.Trace(_loc1_ + 1 + " - " + this._menu[this._curr_menu][_loc1_][0]);
            }
            _loc1_--;
         }
      }
      
      private function ShowList() : void
      {
         this._curr_menu = 0;
         this._Handler_Output.Show();
         this.PrintMenu();
      }
      
      private function HideList() : void
      {
         this._Handler_Output.Hide();
      }
   }
}

