package Code.Data
{
   public class PathWebNode
   {
      
      public var SourceNode:PathNode;
      
      public var Distance:Number;
      
      public function PathWebNode()
      {
         super();
      }
      
      public function Clear() : void
      {
         this.SourceNode = null;
         this.Distance = 9999;
      }
   }
}

