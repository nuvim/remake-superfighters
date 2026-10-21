package Code.Data
{
   import Code.Box2D.Dynamics.b2World;
   import Code.Handler.Cam;
   import Code.Handler.Effects;
   import Code.Handler.Explosions;
   import Code.Handler.OutputTrace;
   import Code.Handler.PlayersKeeper;
   import Code.Handler.Projectiles;
   import Code.Handler.Sounds;
   import flash.display.MovieClip;
   
   public class ProjectilesUpdaterData
   {
      
      public var Handler_Output:OutputTrace;
      
      public var Handler_Projectiles:Projectiles;
      
      public var Handler_Camera:Cam;
      
      public var Handler_Players:PlayersKeeper;
      
      public var Handler_Effects:Effects;
      
      public var Handler_Explosions:Explosions;
      
      public var Handler_Sounds:Sounds;
      
      public var static_mc:MovieClip;
      
      public var object_shape_container_mc:MovieClip;
      
      public var dynamic_mc:MovieClip;
      
      public var m_world:b2World;
      
      public function ProjectilesUpdaterData()
      {
         super();
      }
   }
}

