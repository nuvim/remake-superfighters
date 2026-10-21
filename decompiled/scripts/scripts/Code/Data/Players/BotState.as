package Code.Data.Players
{
   import Code.Box2D.Dynamics.b2Body;
   import Code.Data.PathResultNode;
   
   public class BotState
   {
      
      public static const EASY:int = 1;
      
      public static const MEDIUM:int = 2;
      
      public static const HARD:int = 3;
      
      public static const FOLLOW_ONLY:Boolean = false;
      
      public static const IDLE:int = 0;
      
      public static const AIM:int = 1;
      
      public static const SHOOT:int = 2;
      
      public static const CANCEL_AIM:int = 3;
      
      public static const FOLLOW_PATH:int = 4;
      
      public static const GRAB_WEAPON:int = 5;
      
      public static const MELEE:int = 6;
      
      public static const INTERRUPTED:int = -1;
      
      public static const DISTANCE_LADDER_TOLERANCE_X:Number = 2;
      
      public static const DISTANCE_LADDER_TOLERANCE_Y:Number = 5;
      
      public static const DISTANCE_WALK_TOLERANCE:Number = 4;
      
      public static const DISTANCE_NODE_TOLERANCE_X:Number = 6;
      
      public static const DISTANCE_NODE_TOLERANCE_Y_MIN:Number = 8;
      
      public static const DISTANCE_NODE_TOLERANCE_Y_MAX:Number = -22;
      
      public static const UNAVAILABLE_PLAYER_TIMER:int = 6;
      
      private var _phase:int = 0;
      
      private var _phaseDelay:int = 0;
      
      public var TargetInAim:Boolean = false;
      
      public var TargetInSight:Boolean = false;
      
      public var ActivateSprintCounter:int = 0;
      
      public var ResetTimer:int = 0;
      
      public var DoFireCheck:Boolean = false;
      
      public var DodgeBullet:Boolean = false;
      
      public var RunAwayFromHazards:Boolean = false;
      
      public var OpponentExist:Boolean = true;
      
      public var PreferJumpOverObstacle:Boolean = false;
      
      public var ActionShotFired:Boolean = true;
      
      public var IgnoreObjectCheckingTimer:int = 0;
      
      public var CancelAimSoon:Boolean = false;
      
      public var FirstRocketTurnDone:Boolean = false;
      
      public var Difficulty:int;
      
      public var RunOften:Boolean = true;
      
      public var RandomFirePosition:Boolean = true;
      
      public var RandomFireX:Number;
      
      public var RandomFireY:Number;
      
      public var UnavailablePlayers:Array = new Array();
      
      public var UnavailableWeapons:Array = new Array();
      
      public var FollowToAimMinimumDistance:Number = 50;
      
      public var MeleeToAimMinimumChance:Number = 0.2;
      
      public var IgnoreDodgeBulletWhileAiming:Boolean = false;
      
      private var _nextResNode:PathResultNode = null;
      
      public var PathGridCounter:int = 0;
      
      public var Path:Array = new Array();
      
      public var _targetInSightTimer:Number;
      
      public var _targetChooseTimer:Number;
      
      public var _randomizTimer:Number;
      
      public var TargetHazardousObject:b2Body = null;
      
      private var targetPlayer:Player = null;
      
      public var GrabWeaponTimer:int = 0;
      
      private var _targetWeapon:b2Body = null;
      
      public function BotState()
      {
         super();
      }
      
      public function SetDelay() : void
      {
         switch(this.Difficulty)
         {
            case EASY:
               this._phaseDelay = 6 + Math.floor(Math.random() * 1.99);
               break;
            case MEDIUM:
               this._phaseDelay = 3 + Math.floor(Math.random() * 1.99);
               break;
            case HARD:
               this._phaseDelay = Math.floor(Math.random() * 2.99);
         }
      }
      
      public function get Phase() : int
      {
         return this._phase;
      }
      
      public function set Phase(param1:int) : void
      {
         if(this._phase != param1)
         {
            this._phase = param1;
            if(this._phase != INTERRUPTED && this._phase != IDLE && this._phase != SHOOT && this._phase != CANCEL_AIM)
            {
               this.SetDelay();
            }
            else
            {
               this._phaseDelay = 0;
            }
         }
      }
      
      public function get PhaseDelay() : int
      {
         return this._phaseDelay;
      }
      
      public function set PhaseDelay(param1:int) : void
      {
         this._phaseDelay = param1;
      }
      
      public function get IgnoreObjectChecking() : Boolean
      {
         return this.IgnoreObjectCheckingTimer > 0;
      }
      
      public function UpdateUnavailableStuff() : void
      {
         if(this.IgnoreObjectCheckingTimer > 0)
         {
            --this.IgnoreObjectCheckingTimer;
         }
         var _loc1_:* = int(this.UnavailablePlayers.length - 1);
         while(_loc1_ >= 0)
         {
            this.UnavailablePlayers[_loc1_][1] += 1;
            if(this.UnavailablePlayers[_loc1_][1] >= UNAVAILABLE_PLAYER_TIMER)
            {
               this.UnavailablePlayers.splice(_loc1_,1);
            }
            _loc1_--;
         }
         _loc1_ = int(this.UnavailableWeapons.length - 1);
         while(_loc1_ >= 0)
         {
            this.UnavailableWeapons[_loc1_][1] += 1;
            if(this.UnavailableWeapons[_loc1_][1] >= 20)
            {
               this.UnavailableWeapons.splice(_loc1_,1);
            }
            _loc1_--;
         }
      }
      
      public function IsPlayerUnavailable(param1:Player) : Boolean
      {
         var _loc2_:int = 0;
         while(_loc2_ < this.UnavailablePlayers.length)
         {
            if(this.UnavailablePlayers[_loc2_][0] == param1)
            {
               return true;
            }
            _loc2_++;
         }
         return false;
      }
      
      public function IsWeaponUnavailable(param1:b2Body) : Boolean
      {
         var _loc2_:int = 0;
         while(_loc2_ < this.UnavailableWeapons.length)
         {
            if(this.UnavailableWeapons[_loc2_][0] == param1)
            {
               return true;
            }
            _loc2_++;
         }
         return false;
      }
      
      public function set NextResultNode(param1:PathResultNode) : void
      {
         this._nextResNode = param1;
      }
      
      public function get NextResultNode() : PathResultNode
      {
         return this._nextResNode;
      }
      
      public function get TargetPlayer() : Player
      {
         return this.targetPlayer;
      }
      
      public function set TargetPlayer(param1:Player) : void
      {
         this.targetPlayer = param1;
         if(this.targetPlayer == null)
         {
            this.TargetInAim = false;
            this.TargetInSight = false;
            this.TargetHazardousObject = null;
         }
      }
      
      public function get TargetWeapon() : b2Body
      {
         return this._targetWeapon;
      }
      
      public function set TargetWeapon(param1:b2Body) : void
      {
         this._targetWeapon = param1;
         if(this._targetWeapon == null)
         {
            this.GrabWeaponTimer = 0;
         }
      }
   }
}

