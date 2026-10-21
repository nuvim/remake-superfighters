package Code.Handler
{
   import Code.Box2D.Dynamics.*;
   import Code.Data.*;
   import flash.display.*;
   import flash.geom.*;
   import flash.utils.*;
   
   public class PathGrid
   {
      
      private var _nodes:Array;
      
      private var _binds:Array;
      
      private var _debug_mc:MovieClip;
      
      private var _visitedNodes:Array;
      
      private var _ladderBinds:Array;
      
      private var _jumpBinds:Array;
      
      private var _diveBinds:Array;
      
      private var _parentalNodes:Array;
      
      private var _sprintJumpBinds:Array;
      
      private var _analyzeGridTimer:Number;
      
      private var _players:Array;
      
      private var _Handler_Fires:Fires;
      
      private var m_world:b2World;
      
      private var _seekBalance:Number = 4;
      
      public function PathGrid()
      {
         super();
         this._nodes = new Array();
         this._binds = new Array();
         this._debug_mc = new MovieClip();
         this._visitedNodes = new Array();
         this._parentalNodes = new Array();
         this._analyzeGridTimer = setInterval(function():*
         {
            clearInterval(_analyzeGridTimer);
            _analyzeGridTimer = setInterval(AnalyzeGrid,500);
         },230);
      }
      
      public function LinkPlayers(param1:Array) : void
      {
         this._players = param1;
      }
      
      public function Stop() : void
      {
         clearInterval(this._analyzeGridTimer);
      }
      
      public function UpdateHandlers(param1:Fires, param2:b2World) : void
      {
         this._Handler_Fires = param1;
         this.m_world = param2;
      }
      
      public function UpdatePathGrid() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ < this._parentalNodes.length)
         {
            this._parentalNodes[_loc1_].CalculateParentLocation();
            _loc1_++;
         }
      }
      
      public function AnalyzeGrid() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:Number = NaN;
         var _loc5_:int = 0;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         _loc1_ = 0;
         while(_loc1_ < this._ladderBinds.length)
         {
            this._ladderBinds[_loc1_][0].Blocked = false;
            _loc2_ = 0;
            while(_loc2_ <= 24)
            {
               if(this.m_world.GetDynamicBodyAt(this._ladderBinds[_loc1_][1].x - 4,this._ladderBinds[_loc1_][1].y + _loc2_,false) != null)
               {
                  this._ladderBinds[_loc1_][0].Blocked = true;
                  _loc2_ = 99;
               }
               else if(this.m_world.GetDynamicBodyAt(this._ladderBinds[_loc1_][1].x + 4,this._ladderBinds[_loc1_][1].y + _loc2_,false) != null)
               {
                  this._ladderBinds[_loc1_][0].Blocked = true;
                  _loc2_ = 99;
               }
               _loc2_ += 8;
            }
            _loc3_ = 0;
            while(_loc3_ < this._players.length)
            {
               if(!this._players[_loc3_].Bot)
               {
                  if(this._players[_loc3_].State.HP > 0)
                  {
                     if(this._players[_loc3_].PosY() < this._ladderBinds[_loc1_][1].y + 40)
                     {
                        _loc4_ = Math.pow(this._ladderBinds[_loc1_][1].x - this._players[_loc3_].PosX(),2);
                        if(_loc4_ < 4900)
                        {
                           this._ladderBinds[_loc1_][0].Blocked = true;
                        }
                     }
                  }
               }
               _loc3_++;
            }
            _loc1_++;
         }
         _loc1_ = 0;
         while(_loc1_ < this._jumpBinds.length)
         {
            this._jumpBinds[_loc1_].Blocked = false;
            if(this.JumpNodeBlocked(this._jumpBinds[_loc1_].SourceNode,this._jumpBinds[_loc1_].TargetNode))
            {
               this._jumpBinds[_loc1_].Blocked = true;
            }
            _loc1_++;
         }
         _loc1_ = 0;
         while(_loc1_ < this._diveBinds.length)
         {
            this._diveBinds[_loc1_].Blocked = false;
            if(this.NodeBlocked(this._diveBinds[_loc1_].SourceNode))
            {
               this._diveBinds[_loc1_].Blocked = true;
            }
            _loc1_++;
         }
         _loc1_ = 0;
         while(_loc1_ < this._sprintJumpBinds.length)
         {
            this._sprintJumpBinds[_loc1_].Blocked = false;
            if(this.JumpNodeBlocked(this._sprintJumpBinds[_loc1_].SourceNode,this._sprintJumpBinds[_loc1_].TargetNode))
            {
               this._sprintJumpBinds[_loc1_].Blocked = true;
            }
            else if(this.NodeBlocked(this._sprintJumpBinds[_loc1_].SourceNode))
            {
               this._sprintJumpBinds[_loc1_].Blocked = true;
            }
            _loc1_++;
         }
         _loc1_ = 0;
         while(_loc1_ < this._nodes.length)
         {
            if(this._Handler_Fires.PlayerPosInFire(this._nodes[_loc1_].PosX,this._nodes[_loc1_].PosY))
            {
               this._nodes[_loc1_].InFire = true;
            }
            else
            {
               this._nodes[_loc1_].InFire = false;
            }
            this._nodes[_loc1_].IsHazard = false;
            _loc1_++;
         }
         _loc1_ = 0;
         while(_loc1_ < this.m_world.HazardsList.length)
         {
            if(this.m_world.HazardsList[_loc1_].GetUserData().objectData.IsHazard)
            {
               _loc5_ = 0;
               while(_loc5_ < this._nodes.length)
               {
                  _loc6_ = this.m_world.HazardsList[_loc1_].GetPosition().x * 30 - this._nodes[_loc5_].PosX;
                  if(Math.abs(_loc6_) <= 40)
                  {
                     _loc7_ = this.m_world.HazardsList[_loc1_].GetPosition().y * 30 - this._nodes[_loc5_].PosY;
                     if(Math.abs(_loc7_) <= 40)
                     {
                        this._nodes[_loc5_].IsHazard = true;
                     }
                  }
                  _loc5_++;
               }
            }
            _loc1_++;
         }
      }
      
      public function JumpNodeBlocked(param1:PathNode, param2:PathNode) : Boolean
      {
         var _loc3_:b2Body = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         if(Math.abs(param1.PosX - param2.PosX) < 25)
         {
            _loc4_ = -3;
            loop0:
            while(_loc4_ <= 3)
            {
               _loc5_ = -3;
               while(true)
               {
                  if(_loc5_ > 3)
                  {
                     _loc4_ += 6;
                     continue loop0;
                  }
                  _loc3_ = this.m_world.GetDynamicBodyAt(param2.PosX + _loc4_,param2.PosY + _loc5_,false);
                  if(_loc3_ != null)
                  {
                     break;
                  }
                  _loc5_ += 6;
               }
               return true;
            }
            return false;
         }
         return this.NodeBlocked(param2);
      }
      
      public function NodeBlocked(param1:PathNode) : Boolean
      {
         var _loc2_:b2Body = null;
         var _loc4_:int = 0;
         var _loc3_:int = -3;
         loop0:
         while(_loc3_ <= 3)
         {
            _loc4_ = -3;
            while(true)
            {
               if(_loc4_ > 3)
               {
                  _loc3_ += 6;
                  continue loop0;
               }
               _loc2_ = this.m_world.GetDynamicBodyAt(param1.PosX + _loc3_,param1.PosY + _loc4_,false);
               if(_loc2_ != null)
               {
                  if(!_loc2_.GetUserData().objectData.IsGlass && !_loc2_.GetUserData().objectData.Kickable)
                  {
                     break;
                  }
               }
               _loc4_ += 6;
            }
            return true;
         }
         return false;
      }
      
      public function UpdateSpecials() : void
      {
         var _loc1_:int = 0;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         this._parentalNodes = new Array();
         _loc1_ = 0;
         while(_loc1_ < this._nodes.length)
         {
            this._nodes[_loc1_].UpdateIsEndNode();
            if(this._nodes[_loc1_].ParentBody != null)
            {
               this._parentalNodes.push(this._nodes[_loc1_]);
            }
            _loc1_++;
         }
         this._ladderBinds = new Array();
         this._jumpBinds = new Array();
         this._sprintJumpBinds = new Array();
         this._diveBinds = new Array();
         _loc1_ = 0;
         while(_loc1_ < this._binds.length)
         {
            if(this._binds[_loc1_].MovementType == PathBind.LADDER)
            {
               if(this._binds[_loc1_].SourceNode.PosY < this._binds[_loc1_].TargetNode.PosY)
               {
                  _loc2_ = Number(this._binds[_loc1_].TargetNode.PosX);
                  _loc3_ = Number(this._binds[_loc1_].SourceNode.PosY);
               }
               else
               {
                  _loc2_ = Number(this._binds[_loc1_].SourceNode.PosX);
                  _loc3_ = Number(this._binds[_loc1_].TargetNode.PosY);
               }
               this._ladderBinds.push([this._binds[_loc1_],new Point(_loc2_,_loc3_)]);
            }
            else if(this._binds[_loc1_].MovementType == PathBind.SPRINTJUMP)
            {
               this._sprintJumpBinds.push(this._binds[_loc1_]);
            }
            else if(this._binds[_loc1_].MovementType == PathBind.JUMP)
            {
               this._jumpBinds.push(this._binds[_loc1_]);
            }
            else if(this._binds[_loc1_].MovementType == PathBind.DIVE)
            {
               this._diveBinds.push(this._binds[_loc1_]);
            }
            _loc1_++;
         }
      }
      
      public function GetNode(param1:String) : PathNode
      {
         param1 = param1.toUpperCase();
         var _loc2_:* = int(this._nodes.length - 1);
         while(_loc2_ > 0)
         {
            if(this._nodes[_loc2_].ID == param1)
            {
               return this._nodes[_loc2_];
            }
            _loc2_--;
         }
         return null;
      }
      
      public function RemoveNodes(param1:String) : void
      {
         var _loc3_:* = 0;
         param1 = param1.toUpperCase();
         var _loc2_:* = int(this._nodes.length - 1);
         while(_loc2_ > 0)
         {
            if(this._nodes[_loc2_].ID == param1)
            {
               _loc3_ = int(this._binds.length - 1);
               while(_loc3_ > 0)
               {
                  if(this._binds[_loc3_].SourceNode == this._nodes[_loc2_] || this._binds[_loc3_].TargetNode == this._nodes[_loc2_])
                  {
                     this._binds[_loc3_].SourceNode.RemoveBind(this._binds[_loc3_]);
                     this._binds[_loc3_].TargetNode.RemoveBind(this._binds[_loc3_]);
                     this._binds.splice(_loc3_,1);
                  }
                  _loc3_--;
               }
               this._nodes.splice(_loc2_,1);
            }
            _loc2_--;
         }
      }
      
      public function AddNode(param1:PathNode) : void
      {
         this._nodes.push(param1);
         this._nodes[this._nodes.length - 1].ListIndex = this._nodes.length - 1;
         this._visitedNodes.push(new PathWebNode());
      }
      
      public function AddBind(param1:PathBind) : void
      {
         this._nodes[param1.SourceNode.ListIndex].Binds.push(param1);
         this._binds.push(param1);
      }
      
      public function get Nodes() : Array
      {
         return this._nodes;
      }
      
      public function set Nodes(param1:Array) : void
      {
         this._nodes = param1;
      }
      
      public function get Binds() : Array
      {
         return this._binds;
      }
      
      public function set Binds(param1:Array) : void
      {
         this._binds = param1;
      }
      
      public function GetNodeAt(param1:Number, param2:Number, param3:Number = 200) : PathNode
      {
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc4_:Number = param3;
         var _loc5_:int = -1;
         var _loc9_:int = 0;
         while(_loc9_ < this._nodes.length)
         {
            _loc7_ = this._nodes[_loc9_].PosY - param2;
            if(param2 < this._nodes[_loc9_].PosY + 20)
            {
               _loc6_ = this._nodes[_loc9_].PosX - param1;
               _loc8_ = Math.sqrt(_loc6_ * _loc6_ + _loc7_ * _loc7_);
               if(_loc8_ < _loc4_)
               {
                  _loc5_ = _loc9_;
                  _loc4_ = _loc8_;
               }
            }
            _loc9_++;
         }
         if(_loc5_ == -1)
         {
            return null;
         }
         return this._nodes[_loc5_];
      }
      
      public function GetConnectedNodes() : Array
      {
         var _loc2_:int = 0;
         var _loc1_:Array = new Array();
         _loc2_ = 0;
         while(_loc2_ < this._visitedNodes.length)
         {
            if(this._visitedNodes[_loc2_].SourceNode != null)
            {
               _loc1_.push(this._visitedNodes[_loc2_].SourceNode);
            }
            _loc2_++;
         }
         return _loc1_;
      }
      
      public function GetPath(param1:PathNode, param2:PathNode, param3:Boolean = false) : Array
      {
         var _loc5_:* = 0;
         var _loc9_:PathNode = null;
         var _loc10_:int = 0;
         var _loc11_:PathBind = null;
         var _loc12_:Number = NaN;
         var _loc13_:PathNode = null;
         var _loc14_:int = 0;
         var _loc4_:Array = new Array();
         _loc5_ = 0;
         while(_loc5_ < this._visitedNodes.length)
         {
            this._visitedNodes[_loc5_].Clear();
            _loc5_++;
         }
         if(param1 == null)
         {
            return _loc4_;
         }
         var _loc6_:Boolean = false;
         if(param1.Avoid && !param3)
         {
            _loc6_ = true;
         }
         else
         {
            if(param2 == null)
            {
               return _loc4_;
            }
            if(param1 == param2)
            {
               return _loc4_;
            }
         }
         var _loc7_:Array = new Array();
         _loc7_.push(param1);
         this._visitedNodes[param1.ListIndex].Distance = 0;
         var _loc8_:Number = 0;
         loop1:
         while(true)
         {
            _loc8_ += this._seekBalance;
            ++this._seekBalance;
            _loc5_ = int(_loc7_.length - 1);
            while(_loc5_ >= 0)
            {
               _loc9_ = _loc7_[_loc5_];
               if(this._visitedNodes[_loc9_.ListIndex].Distance <= _loc8_)
               {
                  --this._seekBalance;
                  if(this._seekBalance < 1)
                  {
                     this._seekBalance = 1;
                  }
                  _loc10_ = 0;
                  while(_loc10_ < _loc9_.Binds.length)
                  {
                     _loc11_ = _loc9_.Binds[_loc10_];
                     if(!_loc11_.Blocked)
                     {
                        _loc12_ = this._visitedNodes[_loc9_.ListIndex].Distance + _loc11_.Distance;
                        if(_loc12_ < this._visitedNodes[_loc11_.TargetNode.ListIndex].Distance)
                        {
                           if(this._visitedNodes[_loc11_.TargetNode.ListIndex].SourceNode != null)
                           {
                              this.ShortenPath(_loc11_.TargetNode,this._visitedNodes[_loc11_.TargetNode.ListIndex].Distance - _loc12_,_loc9_);
                           }
                           else
                           {
                              this._visitedNodes[_loc11_.TargetNode.ListIndex].SourceNode = _loc9_;
                              this._visitedNodes[_loc11_.TargetNode.ListIndex].Distance = _loc12_;
                              if(_loc11_.TargetNode.IsEndNode && (_loc11_.TargetNode == param2 || _loc6_ && !_loc11_.TargetNode.Avoid))
                              {
                                 _loc4_.push(new PathResultNode(_loc11_.TargetNode));
                                 _loc13_ = this._visitedNodes[_loc11_.TargetNode.ListIndex].SourceNode;
                                 while(_loc13_ != null)
                                 {
                                    _loc4_.push(new PathResultNode(_loc13_));
                                    _loc13_ = this._visitedNodes[_loc13_.ListIndex].SourceNode;
                                 }
                                 _loc14_ = 0;
                                 while(_loc14_ < _loc4_.length)
                                 {
                                    if(_loc14_ + 1 < _loc4_.length)
                                    {
                                       _loc4_[_loc14_].PrevBind = _loc4_[_loc14_ + 1].Node.GetBindTo(_loc4_[_loc14_].Node);
                                    }
                                    if(_loc14_ > 0)
                                    {
                                       _loc4_[_loc14_].NextBind = _loc4_[_loc14_].Node.GetBindTo(_loc4_[_loc14_ - 1].Node);
                                    }
                                    _loc14_++;
                                 }
                                 return _loc4_;
                              }
                              if(!_loc11_.TargetNode.Avoid || _loc6_)
                              {
                                 _loc7_.push(_loc11_.TargetNode);
                              }
                           }
                        }
                     }
                     _loc10_++;
                  }
                  _loc7_.splice(_loc5_,1);
                  if(_loc7_.length <= 0)
                  {
                     break loop1;
                  }
               }
               _loc5_--;
            }
         }
         if(_loc6_)
         {
            return this.GetPath(param1,param2,true);
         }
         return _loc4_;
      }
      
      private function ShortenPath(param1:PathNode, param2:Number, param3:PathNode = null) : void
      {
         var _loc6_:PathBind = null;
         var _loc7_:Number = NaN;
         if(param3 != null)
         {
            this._visitedNodes[param1.ListIndex].SourceNode = param3;
         }
         this._visitedNodes[param1.ListIndex].Distance -= param2;
         var _loc4_:PathNode = param1;
         var _loc5_:int = 0;
         while(_loc5_ < param1.Binds.length)
         {
            _loc6_ = _loc4_.Binds[_loc5_];
            if(this._visitedNodes[_loc6_.TargetNode.ListIndex].SourceNode == _loc6_.SourceNode)
            {
               this.ShortenPath(_loc6_.TargetNode,param2);
            }
            else if(this._visitedNodes[_loc6_.TargetNode.ListIndex].SourceNode != null)
            {
               _loc7_ = this._visitedNodes[_loc4_.ListIndex].Distance + _loc6_.Distance;
               if(_loc7_ < this._visitedNodes[_loc6_.TargetNode.ListIndex].Distance)
               {
                  this.ShortenPath(_loc6_.TargetNode,this._visitedNodes[_loc6_.TargetNode.ListIndex].Distance - _loc7_,_loc4_);
               }
            }
            _loc5_++;
         }
      }
      
      public function GenerateGraphic() : void
      {
         var _loc1_:int = 0;
         this._debug_mc.graphics.clear();
         this._debug_mc.graphics.lineStyle(2,16777215,0.2);
         _loc1_ = 0;
         while(_loc1_ < this._nodes.length)
         {
            this._debug_mc.graphics.drawCircle(this._nodes[_loc1_].PosX,this._nodes[_loc1_].PosY,4);
            _loc1_++;
         }
         _loc1_ = 0;
         while(_loc1_ < this._binds.length)
         {
            this._debug_mc.graphics.moveTo(this._binds[_loc1_].SourceNode.PosX,this._binds[_loc1_].SourceNode.PosY);
            this._debug_mc.graphics.lineTo(this._binds[_loc1_].TargetNode.PosX,this._binds[_loc1_].TargetNode.PosY);
            _loc1_++;
         }
      }
      
      public function get DebugGraphic() : MovieClip
      {
         return this._debug_mc;
      }
   }
}

