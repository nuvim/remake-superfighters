package Code.Data
{
   public class PathResultNode
   {
      
      private var _pathNode:PathNode;
      
      private var _prevBind:PathBind;
      
      private var _nextBind:PathBind;
      
      public function PathResultNode(param1:PathNode)
      {
         super();
         this._prevBind = null;
         this._pathNode = param1;
         this._nextBind = null;
      }
      
      public function get PrevBind() : PathBind
      {
         return this._prevBind;
      }
      
      public function set PrevBind(param1:PathBind) : void
      {
         this._prevBind = param1;
      }
      
      public function get NextBind() : PathBind
      {
         return this._nextBind;
      }
      
      public function set NextBind(param1:PathBind) : void
      {
         this._nextBind = param1;
      }
      
      public function get Node() : PathNode
      {
         return this._pathNode;
      }
   }
}

