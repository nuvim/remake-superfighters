package Code.Box2D.Collision
{
   public class b2ContactID
   {
      
      public var features:Features = new Features();
      
      public var _key:uint;
      
      public function b2ContactID()
      {
         super();
         this.features._m_id = this;
      }
      
      public function Set(param1:b2ContactID) : void
      {
         this.key = param1._key;
      }
      
      public function Copy() : b2ContactID
      {
         var _loc1_:b2ContactID = new b2ContactID();
         _loc1_.key = this.key;
         return _loc1_;
      }
      
      public function get key() : uint
      {
         return this._key;
      }
      
      public function set key(param1:uint) : void
      {
         this._key = param1;
         this.features._referenceEdge = this._key & 0xFF;
         this.features._incidentEdge = (this._key & 0xFF00) >> 8 & 0xFF;
         this.features._incidentVertex = (this._key & 0xFF0000) >> 16 & 0xFF;
         this.features._flip = (this._key & 0xFF000000) >> 24 & 0xFF;
      }
   }
}

