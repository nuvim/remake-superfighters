package Code.Handler
{
   import Code.Box2D.Common.Math.*;
   import Code.Box2D.Dynamics.b2Body;
   import Code.Data.WeaponSpawnData;
   
   public class WeaponSpawn
   {
      
      private var _Handler_Output:OutputTrace;
      
      private var _Handler_Maps:Maps;
      
      private var _Handler_Weapons:Weapons;
      
      private var _WeaponSpawns:Array;
      
      private var _weaponSpawnChance:Array;
      
      private var _spawnTimer:Number;
      
      private var _spawnInterval:Number = 72;
      
      public function WeaponSpawn(param1:OutputTrace, param2:Maps, param3:Weapons)
      {
         super();
         this._Handler_Output = param1;
         this._Handler_Maps = param2;
         this._Handler_Weapons = param3;
         this._WeaponSpawns = this._Handler_Maps.GetWeaponSpawns();
         this._spawnTimer = this._spawnInterval;
         this._weaponSpawnChance = new Array();
         this._weaponSpawnChance.push(11);
         this._weaponSpawnChance.push(9);
         this._weaponSpawnChance.push(7);
         this._weaponSpawnChance.push(2);
         this._weaponSpawnChance.push(2);
         this._weaponSpawnChance.push(4);
         this._weaponSpawnChance.push(6);
         this._weaponSpawnChance.push(5);
         this._weaponSpawnChance.push(2);
         this._weaponSpawnChance.push(3);
         this._weaponSpawnChance.push(3);
         this._weaponSpawnChance.push(4);
         this._weaponSpawnChance.push(3);
         this._weaponSpawnChance.push(2);
         this._weaponSpawnChance.push(2);
         this._weaponSpawnChance.push(2);
         this._weaponSpawnChance.push(6);
         this._Handler_Output.Trace("Weapon Spawn Created");
      }
      
      public function Update(param1:Number) : void
      {
         var tmpArr:Array = null;
         var i:int = 0;
         var rndIndex:int = 0;
         var wpnData:WeaponSpawnData = null;
         var wpnIndexes:Array = null;
         var j:int = 0;
         var wpnToSpawn:Array = null;
         var spawnValue:int = 0;
         var k:int = 0;
         var rndWeapon:int = 0;
         var wpn:b2Body = null;
         var l:int = 0;
         var game_speed:Number = param1;
         var w:int = 0;
         while(w < this._WeaponSpawns.length)
         {
            this._WeaponSpawns[w].Update(game_speed);
            w++;
         }
         this._spawnTimer -= game_speed;
         if(this._spawnTimer <= 0)
         {
            this._spawnTimer = this._spawnInterval;
            tmpArr = new Array();
            i = 0;
            while(i < this._WeaponSpawns.length)
            {
               if(this._WeaponSpawns[i].LinkedWeapon == null && !this._WeaponSpawns[i].SkipThisOnce)
               {
                  tmpArr.push(this._WeaponSpawns[i]);
               }
               i++;
            }
            if(tmpArr.length <= 0)
            {
               return;
            }
            rndIndex = Math.floor(Math.random() * tmpArr.length);
            wpnData = tmpArr[rndIndex];
            wpnIndexes = new Array();
            j = 0;
            while(j < wpnData.WeaponArray.length)
            {
               if(wpnData.WeaponArray[j] == 1)
               {
                  wpnIndexes.push(j);
               }
               j++;
            }
            if(wpnIndexes.length <= 0)
            {
               return;
            }
            wpnToSpawn = new Array();
            spawnValue = 0;
            k = 0;
            while(k < wpnIndexes.length)
            {
               spawnValue = int(this._weaponSpawnChance[wpnIndexes[k]]);
               l = 0;
               while(l < spawnValue)
               {
                  wpnToSpawn.push(wpnIndexes[k]);
                  l++;
               }
               k++;
            }
            rndWeapon = Math.floor(Math.random() * wpnToSpawn.length);
            switch(wpnToSpawn[rndWeapon])
            {
               case 0:
                  wpn = this._Handler_Maps.Handler_WorldItems.AddPolygon("wpn_pistol",wpnData.PositionX / 30,wpnData.PositionY / 30,0,new b2Vec2(),0);
                  wpn.GetUserData().weaponData = this._Handler_Weapons.Pistol;
                  break;
               case 1:
                  wpn = this._Handler_Maps.Handler_WorldItems.AddPolygon("wpn_rifle",wpnData.PositionX / 30,wpnData.PositionY / 30,0,new b2Vec2(),0);
                  wpn.GetUserData().weaponData = this._Handler_Weapons.Rifle;
                  break;
               case 2:
                  wpn = this._Handler_Maps.Handler_WorldItems.AddPolygon("wpn_shotgun",wpnData.PositionX / 30,wpnData.PositionY / 30,0,new b2Vec2(),0);
                  wpn.GetUserData().weaponData = this._Handler_Weapons.Shotgun;
                  break;
               case 3:
                  wpn = this._Handler_Maps.Handler_WorldItems.AddPolygon("wpn_sniper",wpnData.PositionX / 30,wpnData.PositionY / 30,0,new b2Vec2(),0);
                  wpn.GetUserData().weaponData = this._Handler_Weapons.Sniper;
                  break;
               case 4:
                  wpn = this._Handler_Maps.Handler_WorldItems.AddPolygon("wpn_bazooka",wpnData.PositionX / 30,wpnData.PositionY / 30,0,new b2Vec2(),0);
                  wpn.GetUserData().weaponData = this._Handler_Weapons.Bazooka;
                  break;
               case 5:
                  wpn = this._Handler_Maps.Handler_WorldItems.AddPolygon("wpn_molotovs",wpnData.PositionX / 30,wpnData.PositionY / 30,0,new b2Vec2(),0);
                  wpn.GetUserData().weaponData = this._Handler_Weapons.Molotovs;
                  break;
               case 6:
                  wpn = this._Handler_Maps.Handler_WorldItems.AddPolygon("wpn_grenades",wpnData.PositionX / 30,wpnData.PositionY / 30,0,new b2Vec2(),0);
                  wpn.GetUserData().weaponData = this._Handler_Weapons.Grenades;
                  break;
               case 7:
                  wpn = this._Handler_Maps.Handler_WorldItems.AddPolygon("wpn_flamethrower",wpnData.PositionX / 30,wpnData.PositionY / 30,0,new b2Vec2(),0);
                  wpn.GetUserData().weaponData = this._Handler_Weapons.Flamethrower;
                  break;
               case 8:
                  wpn = this._Handler_Maps.Handler_WorldItems.AddPolygon("wpn_sword",wpnData.PositionX / 30,wpnData.PositionY / 30,0,new b2Vec2(),0);
                  wpn.GetUserData().weaponData = this._Handler_Weapons.Sword;
                  break;
               case 9:
                  wpn = this._Handler_Maps.Handler_WorldItems.AddPolygon("wpn_machete",wpnData.PositionX / 30,wpnData.PositionY / 30,0,new b2Vec2(),0);
                  wpn.GetUserData().weaponData = this._Handler_Weapons.Machete;
                  break;
               case 10:
                  wpn = this._Handler_Maps.Handler_WorldItems.AddPolygon("wpn_axe",wpnData.PositionX / 30,wpnData.PositionY / 30,0,new b2Vec2(),0);
                  wpn.GetUserData().weaponData = this._Handler_Weapons.Axe;
                  break;
               case 11:
                  wpn = this._Handler_Maps.Handler_WorldItems.AddPolygon("wpn_slowmo_05",wpnData.PositionX / 30,wpnData.PositionY / 30,0,new b2Vec2(),0);
                  wpn.GetUserData().weaponData = this._Handler_Weapons.Slowmo05;
                  break;
               case 12:
                  wpn = this._Handler_Maps.Handler_WorldItems.AddPolygon("wpn_slowmo_10",wpnData.PositionX / 30,wpnData.PositionY / 30,0,new b2Vec2(),0);
                  wpn.GetUserData().weaponData = this._Handler_Weapons.Slowmo10;
                  break;
               case 13:
                  wpn = this._Handler_Maps.Handler_WorldItems.AddPolygon("wpn_pills",wpnData.PositionX / 30,wpnData.PositionY / 30,0,new b2Vec2(),0);
                  wpn.GetUserData().weaponData = this._Handler_Weapons.Pills;
                  break;
               case 14:
                  wpn = this._Handler_Maps.Handler_WorldItems.AddPolygon("wpn_medkit",wpnData.PositionX / 30,wpnData.PositionY / 30,0,new b2Vec2(),0);
                  wpn.GetUserData().weaponData = this._Handler_Weapons.Medkit;
                  break;
               case 15:
                  wpn = this._Handler_Maps.Handler_WorldItems.AddPolygon("wpn_magnum",wpnData.PositionX / 30,wpnData.PositionY / 30,0,new b2Vec2(),0);
                  wpn.GetUserData().weaponData = this._Handler_Weapons.Magnum;
                  break;
               case 16:
                  wpn = this._Handler_Maps.Handler_WorldItems.AddPolygon("wpn_uzi",wpnData.PositionX / 30,wpnData.PositionY / 30,0,new b2Vec2(),0);
                  wpn.GetUserData().weaponData = this._Handler_Weapons.Uzi;
            }
            if(wpn != null)
            {
               wpn.GetUserData().objectData.UpdateFunction = function(param1:b2Body, param2:Number):void
               {
               };
               wpn.PutToSleep();
               wpnData.LinkedWeapon = wpn;
            }
         }
      }
   }
}

