package Code.Data
{
   import Code.Box2D.Dynamics.b2Body;
   
   public class WeaponSpawnData
   {
      
      private var positionX:Number;
      
      private var positionY:Number;
      
      private var weaponArray:Array;
      
      private var weaponDespawnTimer:Number;
      
      private var linkedWeapon:b2Body;
      
      private var blinkTimer:Number;
      
      private var wpnHidden:Boolean;
      
      private var startBlink:int;
      
      private var skipThisOnce:Boolean;
      
      public function WeaponSpawnData(param1:Number, param2:Number, param3:Array)
      {
         super();
         this.positionX = param1;
         this.positionY = param2;
         this.weaponArray = param3;
         this.weaponDespawnTimer = 0;
         this.blinkTimer = 0;
         this.wpnHidden = false;
         this.startBlink = 8 * 24;
         this.linkedWeapon = null;
         this.skipThisOnce = false;
      }
      
      public function Update(param1:Number) : void
      {
         if(this.linkedWeapon != null)
         {
            if(this.linkedWeapon.GetUserData().objectData.HP <= 0)
            {
               this.linkedWeapon = null;
               this.weaponDespawnTimer = 0;
               this.skipThisOnce = true;
            }
            else if(this.weaponDespawnTimer > 0)
            {
               this.weaponDespawnTimer -= param1;
               if(this.weaponDespawnTimer <= 0)
               {
                  this.linkedWeapon.GetUserData().objectData.ForceDestruction();
                  this.linkedWeapon = null;
               }
               else if(this.weaponDespawnTimer <= this.startBlink)
               {
                  --this.blinkTimer;
                  if(this.blinkTimer <= 0)
                  {
                     if(this.wpnHidden)
                     {
                        this.linkedWeapon.GetUserData().objectData.MC.gotoAndStop(1);
                     }
                     else
                     {
                        this.linkedWeapon.GetUserData().objectData.MC.gotoAndStop(2);
                     }
                     this.wpnHidden = !this.wpnHidden;
                     this.blinkTimer = 8;
                  }
               }
            }
         }
      }
      
      public function set LinkedWeapon(param1:b2Body) : void
      {
         this.linkedWeapon = param1;
         this.weaponDespawnTimer = 20 * 24;
      }
      
      public function get LinkedWeapon() : b2Body
      {
         return this.linkedWeapon;
      }
      
      public function get SkipThisOnce() : Boolean
      {
         if(this.skipThisOnce)
         {
            this.skipThisOnce = false;
            return true;
         }
         return false;
      }
      
      public function get PositionX() : Number
      {
         return this.positionX;
      }
      
      public function get PositionY() : Number
      {
         return this.positionY;
      }
      
      public function get WeaponArray() : Array
      {
         return this.weaponArray;
      }
   }
}

