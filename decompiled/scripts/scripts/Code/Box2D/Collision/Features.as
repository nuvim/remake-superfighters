package Code.Box2D.Collision
{
   public class Features
   {
      
      public var _referenceEdge:int;
      
      public var _incidentEdge:int;
      
      public var _incidentVertex:int;
      
      public var _flip:int;
      
      public var _m_id:b2ContactID;
      
      public function Features()
      {
         super();
      }
      
      public function set referenceEdge(param1:int) : void
      {
         this._referenceEdge = param1;
         this._m_id._key = this._m_id._key & 0xFFFFFF00 | this._referenceEdge & 0xFF;
      }
      
      public function get referenceEdge() : int
      {
         return this._referenceEdge;
      }
      
      public function set incidentEdge(param1:int) : void
      {
         this._incidentEdge = param1;
         this._m_id._key = this._m_id._key & 0xFFFF00FF | this._incidentEdge << 8 & 0xFF00;
      }
      
      public function get incidentEdge() : int
      {
         return this._incidentEdge;
      }
      
      public function set incidentVertex(param1:int) : void
      {
         this._incidentVertex = param1;
         this._m_id._key = this._m_id._key & 0xFF00FFFF | this._incidentVertex << 16 & 0xFF0000;
      }
      
      public function get incidentVertex() : int
      {
         return this._incidentVertex;
      }
      
      public function set flip(param1:int) : void
      {
         this._flip = param1;
         this._m_id._key = this._m_id._key & 0xFFFFFF | this._flip << 24 & 0xFF000000;
      }
      
      public function get flip() : int
      {
         return this._flip;
      }
   }
}

