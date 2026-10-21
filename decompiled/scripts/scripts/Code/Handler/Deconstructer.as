package Code.Handler
{
   import Code.Box2D.Collision.*;
   import Code.Box2D.Collision.Shapes.*;
   import Code.Box2D.Common.*;
   import Code.Box2D.Common.Math.*;
   import Code.Box2D.Dynamics.*;
   import Code.Box2D.Dynamics.Contacts.*;
   
   public class Deconstructer
   {
      
      private var _deconstructListener:Array;
      
      private var m_world:b2World;
      
      public function Deconstructer()
      {
         super();
         this._deconstructListener = new Array();
      }
      
      public function Update() : void
      {
         var i:int = 0;
         if(this._deconstructListener.length > 0)
         {
            i = 0;
            while(i < this._deconstructListener.length)
            {
               try
               {
                  this._deconstructListener[i].m_userData.parent.removeChild(this._deconstructListener[i].m_userData);
                  this._deconstructListener[i].m_userData.onDestruction(this._deconstructListener[i]);
                  this.m_world.DestroyBody(this._deconstructListener[i]);
               }
               catch(e:Error)
               {
               }
               i++;
            }
            this._deconstructListener = new Array();
         }
      }
      
      public function set Setb2World(param1:b2World) : void
      {
         this.m_world = param1;
      }
      
      public function AddBody(param1:b2Body) : void
      {
         if(param1.GetUserData().destroyed != true && param1.GetUserData().locked != true)
         {
            if(Boolean(param1.m_userData.objectData.DrawHitBox) || Boolean(param1.m_userData.objectData.DrawCloudBox))
            {
               param1.m_userData.objectData.CollisionMC.parent.removeChild(param1.m_userData.objectData.CollisionMC);
            }
            if(param1.m_userData.objectData.DrawShapeMC)
            {
               param1.m_userData.objectData.ShapeMC.parent.removeChild(param1.m_userData.objectData.ShapeMC);
            }
            param1.GetUserData().destroyed = true;
            this.m_world.RemoveObjectFromLists(param1);
            this._deconstructListener.push(param1);
         }
      }
      
      public function get DeconstructList() : Array
      {
         return this._deconstructListener;
      }
      
      public function set DeconstructList(param1:Array) : void
      {
         this._deconstructListener = param1;
      }
   }
}

