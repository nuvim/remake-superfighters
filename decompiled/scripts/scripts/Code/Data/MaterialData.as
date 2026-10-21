package Code.Data
{
   public class MaterialData
   {
      
      private var _material_type:String = "";
      
      private var _density:Number = 0;
      
      private var _friction:Number = 0;
      
      private var _restitution:Number = 0;
      
      private var _impact_effect:String = "";
      
      private var _impact_conditions:Array;
      
      private var _bullet_hit_effect:String = "";
      
      private var _bullet_hit_sound:String = "";
      
      private var _bounce_impact_sound:String = "";
      
      public function MaterialData(param1:String, param2:Number, param3:Number, param4:Number, param5:String, param6:Array, param7:String, param8:String, param9:String)
      {
         super();
         this._material_type = param1.toUpperCase();
         this._density = param2;
         this._friction = param3;
         this._restitution = param4;
         this._impact_effect = param5.toUpperCase();
         this._impact_conditions = param6;
         this._bullet_hit_effect = param7.toUpperCase();
         this._bullet_hit_sound = param8.toUpperCase();
         this._bounce_impact_sound = param9.toUpperCase();
      }
      
      public function ImpactEffectConditionFullfilled(param1:String) : Boolean
      {
         if(this._impact_conditions[0] == "ANYTHING")
         {
            return true;
         }
         var _loc2_:int = 0;
         while(_loc2_ < this._impact_conditions.length)
         {
            if(this._impact_conditions[_loc2_] == param1)
            {
               return true;
            }
            _loc2_++;
         }
         return false;
      }
      
      public function get Type() : String
      {
         return this._material_type;
      }
      
      public function get Density() : Number
      {
         return this._density;
      }
      
      public function get Friction() : Number
      {
         return this._friction;
      }
      
      public function get Restitution() : Number
      {
         return this._restitution;
      }
      
      public function get ImpactEffect() : String
      {
         return this._impact_effect;
      }
      
      public function get BulletHitEffect() : String
      {
         return this._bullet_hit_effect;
      }
      
      public function get BulletHitSound() : String
      {
         return this._bullet_hit_sound;
      }
      
      public function get BounceImpactSound() : String
      {
         return this._bounce_impact_sound;
      }
      
      public function set Type(param1:String) : void
      {
         this._material_type = param1;
      }
      
      public function set Density(param1:Number) : void
      {
         this._density = param1;
      }
      
      public function set Friction(param1:Number) : void
      {
         this._friction = param1;
      }
      
      public function set Restitution(param1:Number) : void
      {
         this._restitution = param1;
      }
      
      public function set ImpactEffect(param1:String) : void
      {
         this._impact_effect = param1;
      }
      
      public function set BulletHitEffect(param1:String) : void
      {
         this._bullet_hit_effect = param1;
      }
      
      public function set BulletHitSound(param1:String) : void
      {
         this._bullet_hit_sound = param1;
      }
      
      public function set BounceImpactSound(param1:String) : void
      {
         this._bounce_impact_sound = param1;
      }
      
      public function Copy() : MaterialData
      {
         return new MaterialData(this._material_type,this._density,this._friction,this._restitution,this._impact_effect,this._impact_conditions,this._bullet_hit_effect,this._bullet_hit_sound,this._bounce_impact_sound);
      }
   }
}

