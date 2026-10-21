package Code.Handler
{
   import flash.display.MovieClip;
   import flash.text.*;
   
   public class OutputTrace extends MovieClip
   {
      
      private var _trace_txt:TextField;
      
      private var _message_string:String = new String("");
      
      private var _debug:Boolean;
      
      public function OutputTrace(param1:*, param2:Boolean)
      {
         super();
         this._debug = param2;
         if(this._debug)
         {
            this._trace_txt = new TextField();
            this._trace_txt.width = 600;
            this._trace_txt.height = 600;
            this._trace_txt.selectable = false;
            this._trace_txt.multiline = true;
            this._trace_txt.textColor = 14540219;
            param1.addChild(this._trace_txt);
         }
         this.Clear();
         this.Trace("OutputTrace Created");
         this.Hide();
      }
      
      public function Clear() : void
      {
         this._message_string = "";
         var _loc1_:* = 0;
         while(_loc1_ < 39)
         {
            this._message_string += "<br>";
            _loc1_++;
         }
      }
      
      public function Selectable(param1:Boolean) : void
      {
         this.Trace("Output Selectable set to " + param1);
         if(this._debug)
         {
            this._trace_txt.selectable = param1;
         }
      }
      
      public function Hide() : void
      {
         this.Trace("Hiding Output");
         if(this._debug)
         {
            this._trace_txt.visible = false;
         }
      }
      
      public function Show() : void
      {
         this.Trace("Showing Output");
         if(this._debug)
         {
            this._trace_txt.visible = true;
         }
      }
      
      public function Trace(param1:String) : void
      {
         if(this._debug)
         {
            this._message_string = this._message_string.substr(0,this._message_string.lastIndexOf("<br>"));
            this._message_string = param1 + "<br>" + this._message_string;
            this._trace_txt.htmlText = this._message_string;
         }
      }
   }
}

