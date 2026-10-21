package Code.Handler
{
   import flash.events.*;
   
   public class InputKeyboard
   {
      
      private var _stage:*;
      
      private var _keyBuffer:Array = new Array();
      
      private var _modifierBuffer:Array = new Array();
      
      private var _functionBuffer:Array = new Array();
      
      public var KeyDownFunction:Function;
      
      public var KeyDownFunctionRepeatable:Function;
      
      public var KeyUpFunction:Function;
      
      public function InputKeyboard(param1:*)
      {
         super();
         this._stage = param1;
         this._stage.addEventListener(KeyboardEvent.KEY_DOWN,this.keyDownHandler);
         this._stage.addEventListener(KeyboardEvent.KEY_UP,this.keyUpHandler);
      }
      
      public function Deconstruct() : void
      {
         this._stage.removeEventListener(KeyboardEvent.KEY_DOWN,this.keyDownHandler);
         this._stage.removeEventListener(KeyboardEvent.KEY_UP,this.keyUpHandler);
      }
      
      private function Blank() : void
      {
      }
      
      public function AddHandler(param1:int, param2:Function, param3:Function = undefined) : void
      {
         if(param2 == null)
         {
            param2 = this.Blank;
         }
         if(param3 == null)
         {
            param3 = this.Blank;
         }
         this._functionBuffer.push([param1,param2,param3,-1]);
      }
      
      public function AddModifier(param1:int = -1) : void
      {
         this._functionBuffer[this._functionBuffer.length - 1][3] = param1;
         this.UpdateModifierBuffer();
      }
      
      public function RemoveHandler(param1:int, param2:int = -1) : void
      {
         var _loc3_:* = 0;
         while(_loc3_ < this._functionBuffer.length)
         {
            if(param1 == this._functionBuffer[_loc3_][0] && this._functionBuffer[_loc3_][3] == param2)
            {
               this._functionBuffer.splice(_loc3_,1);
            }
            _loc3_++;
         }
         this.UpdateModifierBuffer();
      }
      
      public function RemoveModifier(param1:int, param2:int) : void
      {
         var _loc3_:* = 0;
         while(_loc3_ < this._functionBuffer.length)
         {
            if(param1 == this._functionBuffer[_loc3_][0] && this._functionBuffer[_loc3_][3] == param2)
            {
               this._functionBuffer[_loc3_][3] = -1;
               this.UpdateModifierBuffer();
            }
            _loc3_++;
         }
      }
      
      public function GetKeyCode(param1:String) : int
      {
         switch(param1.toUpperCase())
         {
            case "SPACEBAR":
            case "SPACE":
               return 32;
            case "UP":
               return 38;
            case "DOWN":
               return 40;
            case "LEFT":
               return 37;
            case "RIGHT":
               return 39;
            case "SHIFT":
               return 16;
            case "CTRL":
               return 17;
            case "CAPS":
            case "CAPSLOCK":
               return 20;
            case "ENTER":
               return 13;
            case "BACKSPACE":
               return 8;
            case "ESCAPE":
               return 27;
            default:
               return param1.charCodeAt(0);
         }
      }
      
      public function GetCharFromCode(param1:int) : String
      {
         switch(param1)
         {
            case 32:
               return "SPACE";
            case 38:
               return "UP";
            case 40:
               return "DOWN";
            case 37:
               return "LEFT";
            case 39:
               return "RIGHT";
            case 16:
               return "SHIFT";
            case 17:
               return "CTRL";
            case 20:
               return "CAPS";
            case 13:
               return "ENTER";
            case 8:
               return "BACKSPACE";
            case 27:
               return "ESCAPE";
            case 188:
               return ",";
            case 190:
               return ".";
            default:
               var _loc2_:String = String.fromCharCode(param1);
               if(param1 >= 127)
               {
                  _loc2_ = "C" + param1;
               }
               return _loc2_;
         }
      }
      
      public function KeyIsDown(param1:int) : Boolean
      {
         var _loc2_:* = 0;
         while(_loc2_ < this._keyBuffer.length)
         {
            if(this._keyBuffer[_loc2_] == param1)
            {
               return true;
            }
            _loc2_++;
         }
         return false;
      }
      
      public function TraceKeys() : void
      {
         var _loc1_:String = "Keys Down: ";
         var _loc2_:* = 0;
         while(_loc2_ < this._keyBuffer.length)
         {
            _loc1_ += this._keyBuffer[_loc2_] + ", ";
            _loc2_++;
         }
      }
      
      private function UpdateModifierBuffer() : void
      {
         this._modifierBuffer = new Array();
         var _loc1_:* = 0;
         while(_loc1_ < this._functionBuffer.length)
         {
            if(this._functionBuffer[_loc1_][3] != -1)
            {
               this.AddModifierToBuffer(this._functionBuffer[_loc1_][3]);
            }
            _loc1_++;
         }
      }
      
      private function AddModifierToBuffer(param1:int) : void
      {
         var _loc2_:Boolean = true;
         var _loc3_:* = 0;
         while(_loc3_ < this._modifierBuffer.length)
         {
            if(this._modifierBuffer[_loc3_] == param1)
            {
               _loc2_ = false;
            }
            _loc3_++;
         }
         if(_loc2_)
         {
            this._modifierBuffer.push(param1);
         }
      }
      
      private function GetModifierPressed() : int
      {
         var _loc2_:* = undefined;
         var _loc1_:* = 0;
         loop0:
         while(_loc1_ < this._modifierBuffer.length)
         {
            _loc2_ = 0;
            while(true)
            {
               if(_loc2_ >= this._keyBuffer.length)
               {
                  _loc1_++;
                  continue loop0;
               }
               if(this._modifierBuffer[_loc1_] == this._keyBuffer[_loc2_])
               {
                  break;
               }
               _loc2_++;
            }
            return this._modifierBuffer[_loc1_];
         }
         return -1;
      }
      
      private function CheckKeyFunction(param1:int, param2:int) : void
      {
         var _loc3_:* = 0;
         while(_loc3_ < this._functionBuffer.length)
         {
            if(param1 == this._functionBuffer[_loc3_][0])
            {
               if(this._functionBuffer[_loc3_][3] == this.GetModifierPressed() || this.KeyIsDown(this._functionBuffer[_loc3_][3]) || param2 != 1)
               {
                  this._functionBuffer[_loc3_][param2]();
               }
            }
            _loc3_++;
         }
      }
      
      private function keyDownHandler(param1:KeyboardEvent) : void
      {
         if(this.KeyDownFunctionRepeatable != null)
         {
            this.KeyDownFunctionRepeatable(param1);
         }
         if(this.KeyIsDown(param1.keyCode) == false)
         {
            this._keyBuffer.push(param1.keyCode);
            this.CheckKeyFunction(param1.keyCode,1);
            if(this.KeyDownFunction != null)
            {
               this.KeyDownFunction(param1);
            }
         }
      }
      
      private function keyUpHandler(param1:KeyboardEvent) : void
      {
         this.RemoveKeyFromBuffer(param1.keyCode);
         this.CheckKeyFunction(param1.keyCode,2);
         if(this.KeyUpFunction != null)
         {
            this.KeyUpFunction(param1);
         }
      }
      
      private function RemoveKeyFromBuffer(param1:int) : void
      {
         var _loc2_:* = 0;
         while(_loc2_ < this._keyBuffer.length)
         {
            if(this._keyBuffer[_loc2_] == param1)
            {
               this._keyBuffer.splice(_loc2_,1);
            }
            _loc2_++;
         }
      }
   }
}

