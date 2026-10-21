package Code.Particles
{
   import Code.Box2D.Common.Math.*;
   
   public class particle_data
   {
      
      public var PosX:Number;
      
      public var PosY:Number;
      
      public var ParticleVec:b2Vec2;
      
      public var Effect:String;
      
      public var Rotation:Number;
      
      public var DataArray:Array;
      
      public var Alpha:Number;
      
      public var ScaleX:Number;
      
      public var ScaleY:Number;
      
      public function particle_data(param1:String = "", param2:Number = 0, param3:Number = 0, param4:b2Vec2 = null, param5:Number = 0, param6:Number = 1, param7:Array = null)
      {
         super();
         this.Effect = param1.toUpperCase();
         this.PosX = param2;
         this.PosY = param3;
         if(param4 != null)
         {
            this.ParticleVec = param4;
         }
         else
         {
            this.ParticleVec = new b2Vec2(0,0);
         }
         this.Alpha = param6;
         this.Rotation = param5;
         this.DataArray = param7;
         this.ScaleX = 1;
         this.ScaleY = 1;
      }
   }
}

