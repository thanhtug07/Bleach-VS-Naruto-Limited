package
{
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.geom.Rectangle;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.Socket;
   import flash.system.Security;
   import flash.text.TextField;
   import flash.text.TextFieldType;
   import flash.text.TextFormat;
   import flash.utils.getTimer;
   import flash.utils.setTimeout;
   import net.play5d.game.obvn.Debugger;
   import net.play5d.game.obvn.MainGame;
   import net.play5d.game.obvn.ctrler.GameLogic;
   import net.play5d.game.obvn.ctrler.StateCtrler;
   import net.play5d.game.obvn.ctrler.game_ctrler.GameCtrler;
   import net.play5d.game.obvn.ctrler.game_ctrler.TrainingCtrler;
   import net.play5d.game.obvn.data.GameConfig;
   import net.play5d.game.obvn.data.GameData;
   import net.play5d.game.obvn.data.GameInterface;
   import net.play5d.game.obvn.data.GameInterfaceManager;
   import net.play5d.game.obvn.data.GameMode;
   import net.play5d.game.obvn.fighter.FighterMain;
   import net.play5d.game.obvn.fighter.ctrler.FighterCtrler;
   import net.play5d.game.obvn.fighter.ctrler.FighterEffectCtrler;
   import net.play5d.game.obvn.fighter.event.FighterEventDispatcher;
   import net.play5d.game.obvn.fighter.vo.HitVO;
   import net.play5d.game.obvn.model.MapModel;
   import net.play5d.game.obvn.stage.LoadingStage;
   import net.play5d.game.obvn.vo.GameRunDataVO;
   import net.play5d.game.obvn.vo.SelectVO;
   import net.play5d.kyo.display.ui.KyoSimpButton;
   
   [SWF(width="800", height="600", backgroundColor="#000000", frameRate="30")]
   [SWF(frameRate="30",backgroundColor="#000000",width="1000",height="600")]
   public class FighterTester extends Sprite
   {
      
      private var _mainGame:MainGame;
      
      private var _gameSprite:Sprite;
      
      private var _testUI:Sprite;
      
      private var _p1InputId:TextField;
      
      private var _p2InputId:TextField;
      
      private var _p1FzInputId:TextField;
      
      private var _p2FzInputId:TextField;
      
      private var _autoReceiveHp:TextField;
      
      private var _mapInputId:TextField;
      
      private var _fpsInput:TextField;
      
      private var _debugText:TextField;
      
      public function FighterTester()
      {
         super();
         I = this;
         if(stage)
         {
            initlize();
            return;
         }
         addEventListener("addedToStage",initlize);
      }
      
      private static function loadGame() : void
      {
         var _loc1_:LoadingStage = new LoadingStage();
         MainGame.stageCtrler.goStage(_loc1_);
      }
      
      private function initlize(param1:Event = null) : void
      {
         removeEventListener("addedToStage",initlize);
         Debugger.initDebug(stage);
         Debugger.onErrorMsgCall = onDebugLog;
         _gameSprite = new Sprite();
         _gameSprite.scrollRect = new Rectangle(0,0,GameConfig.GAME_SIZE.x,GameConfig.GAME_SIZE.y);
         addChild(_gameSprite);
         GameInterface.instance = new GameInterfaceManager();
         GameData.I.config.keyInputMode = 1;
         GameData.I.config.quality = "low";
         GameData.I.config.fighterHP = 2;
         GameData.I.config.AI_level = 6;
         GameData.I.config.fightTime = -1;
         _mainGame = new MainGame();
         _mainGame.initlize(_gameSprite,stage,initBackHandler,initFailHandler);
         StateCtrler.I.transEnabled = false;
      }
      
      private function initBackHandler() : void
      {
         buildTestUI();
         _testUI.visible = false;
         _mainGame.goMenu();
      }
      
      private function initFailHandler(param1:String) : void
      {
      }
      
      private function buildTestUI() : void
      {
         _testUI = new Sprite();
         _testUI.x = 810;
         _testUI.graphics.beginFill(3355443,1);
         _testUI.graphics.drawRect(-10,0,200,600);
         _testUI.graphics.endFill();
         addChild(_testUI);
         var _loc1_:Number = 20;
         addLabel("P1      ",_loc1_);
         _loc1_ += 40;
         addLabel("ID NV   ",_loc1_);
         _p1InputId = addInput("ichigo",_loc1_,80);
         _loc1_ += 40;
         addLabel("ID TT   ",_loc1_);
         _p1FzInputId = addInput("kon",_loc1_,80);
         _loc1_ += 80;
         addLabel("P2      ",_loc1_);
         _loc1_ += 40;
         addLabel("ID NV   ",_loc1_);
         _p2InputId = addInput("naruto",_loc1_,80);
         _loc1_ += 40;
         addLabel("ID TT   ",_loc1_);
         _p2FzInputId = addInput("gaara",_loc1_,80);
         _loc1_ += 40;
         addLabel("ID Map  ",_loc1_);
         _mapInputId = addInput(MapModel.I.getAllMaps()[1].id,_loc1_,80);
         _loc1_ += 60;
         addLabel("FPS   ",_loc1_);
         _fpsInput = addInput(GameConfig.FPS_GAME.toString(),_loc1_,80);
         _loc1_ += 40;
         addLabel("H.máu",_loc1_);
         _autoReceiveHp = addInput("1",_loc1_,80);
         _loc1_ += 60;
         _debugText = addLabel("Thông báo lỗi ",_loc1_,0,{
            "font":"Times New Roman",
            "size":12
         });
         _debugText.width = 190;
         _debugText.height = 200;
         _debugText.textColor = 16711680;
         _debugText.multiline = true;
         addButton("Chạy test ",500,25,65,35,testClickHandler);
         addButton("Hien hitbox ",500,100,65,35,renderMainClickHandler);
         addButton("Xử P2  ",550,25,65,35,killP2ClickHandler);
         addButton("Nut Esc",550,100,65,35,escKeyDownClickHandler);
      }
      
      private function addLabel(param1:String, param2:Number = 0, param3:Number = 0, param4:Object = null) : TextField
      {
         if(!param4)
         {
            param4 = {};
         }
         param4.size = param4.size || 14;
         param4.color = param4.color || 16777215;
         param4.font = param4.font || "SimHei";
         var _loc5_:TextFormat = new TextFormat();
         _loc5_.size = param4.size;
         _loc5_.color = param4.color;
         _loc5_.font = param4.font;
         var _loc6_:TextField = new TextField();
         _loc6_.defaultTextFormat = _loc5_;
         _loc6_.text = param1;
         _loc6_.x = param3;
         _loc6_.y = param2;
         _loc6_.mouseEnabled = false;
         _testUI.addChild(_loc6_);
         return _loc6_;
      }
      
      private function addInput(param1:String, param2:Number = 0, param3:Number = 0) : TextField
      {
         var _loc4_:TextFormat = new TextFormat();
         _loc4_.size = 14;
         _loc4_.color = 0;
         var _loc5_:TextField = new TextField();
         _loc5_.defaultTextFormat = _loc4_;
         _loc5_.text = param1;
         _loc5_.x = param3;
         _loc5_.y = param2;
         _loc5_.width = 100;
         _loc5_.height = 20;
         _loc5_.backgroundColor = 16777215;
         _loc5_.background = true;
         _loc5_.type = "input";
         _loc5_.condenseWhite = true;
         _testUI.addChild(_loc5_);
         return _loc5_;
      }
      
      private function addButton(param1:String, param2:Number = 0, param3:Number = 0, param4:Number = 100, param5:Number = 50, param6:Function = null) : Sprite
      {
         var _loc7_:KyoSimpButton = new KyoSimpButton(param1,param4,param5);
         _loc7_.x = param3;
         _loc7_.y = param2;
         if(param6 != null)
         {
            _loc7_.onClick(param6);
         }
         _testUI.addChild(_loc7_);
         return _loc7_;
      }
      
      private function onDebugLog(param1:String) : void
      {
         if(!_debugText)
         {
            return;
         }
         _debugText.text = param1;
      }
      
      private function changeFps(... rest) : void
      {
         var _loc2_:int = int(_fpsInput.text);
         GameConfig.setGameFps(_loc2_);
         stage.frameRate = _loc2_;
      }
      
      private function testClickHandler(... rest) : void
      {
         changeFps();
         GameMode.currentMode = 40;
         TrainingCtrler.RECOVER_HP = _autoReceiveHp.text != "0";
         GameData.I.p1Select = new SelectVO();
         GameData.I.p2Select = new SelectVO();
         GameData.I.p1Select.fighter1 = _p1InputId.text;
         GameData.I.p2Select.fighter1 = _p2InputId.text;
         GameData.I.p1Select.fuzhu = _p1FzInputId.text;
         GameData.I.p2Select.fuzhu = _p2FzInputId.text;
         GameData.I.selectMap = _mapInputId.text;
         loadGame();
      }
      
      private function killP2ClickHandler(... rest) : void
      {
         var _loc4_:GameRunDataVO = GameCtrler.I.gameRunData;
         if(!_loc4_)
         {
            Debugger.errorMsg("Ko có data!         ");
            return;
         }
         if(!GameCtrler.I.actionEnable)
         {
            Debugger.errorMsg("Do may dieu khien          ");
            return;
         }
         if(GameCtrler.I.isPauseGame)
         {
            Debugger.errorMsg("Đang dừng!     ");
            return;
         }
         var _loc3_:FighterMain = _loc4_.p1FighterGroup.currentFighter;
         var _loc2_:FighterMain = _loc4_.p2FighterGroup.currentFighter;
         if(!_loc3_ || !_loc2_)
         {
            return;
         }
         if(GameMode.currentMode == 40)
         {
            Debugger.errorMsg("Chế độ tập!    ");
            return;
         }
         if(!_loc3_.isAlive || !_loc2_.isAlive)
         {
            return;
         }
         killP2(_loc3_,_loc2_);
      }
      
      private function killP2(param1:FighterMain, param2:FighterMain) : void
      {
         var _loc3_:HitVO = new HitVO();
         _loc3_.owner = param1;
         var _loc4_:Number = param2.hp;
         param2.hurtHit = _loc3_;
         param2.loseHp(_loc4_);
         var _loc6_:FighterCtrler = param2.getCtrler();
         _loc6_.getMcCtrl().idle();
         _loc6_.getMcCtrl().hurtFly(-5,0);
         _loc6_.getVoiceCtrl().playVoice(2);
         var _loc5_:FighterEffectCtrler = _loc6_.getEffectCtrl();
         _loc5_.endBisha();
         _loc5_.endGhostStep();
         _loc5_.endGlow();
         if(GameLogic.checkFighterDie(param2))
         {
            Debugger.errorMsg("Mat mau: " + _loc4_);
            FighterEventDispatcher.dispatchEvent(param2,"DIE");
            param2.isAlive = false;
            trace("Xử P2 xong!      ");
         }
      }
      
      private function escKeyDownClickHandler(... rest) : void
      {
         var params:Array = rest;
         var escKeyDownEvent:KeyboardEvent = new KeyboardEvent("keyDown");
         escKeyDownEvent.keyCode = 27;
         stage.dispatchEvent(escKeyDownEvent);
         setTimeout(function():void
         {
            var _loc1_:KeyboardEvent = new KeyboardEvent("keyUp");
            _loc1_.keyCode = 27;
            stage.dispatchEvent(_loc1_);
            trace("Đã gửi ESC!               ");
         },80);
      }
      
      private function renderMainClickHandler(param1:Event) : void
      {
         var _loc2_:KyoSimpButton = param1.target as KyoSimpButton;
         if(_loc2_.getLabel() == "Hien hitbox ")
         {
            _loc2_.setLabel("Tắt hitbox");
         }
         else
         {
            _loc2_.setLabel("Hien hitbox ");
         }
         Debugger.showMain();
      }

      public static var I:FighterTester;

      private static const NET_PUBLIC:String = "";

      private var _netHosts:Array;

      private var _netHostIdx:int = 0;

      private var _lbTouched:Boolean = false;

      private var _netSock:Socket;

      private var _netBuf:String = "";

      private var _netRole:String;

      private var _netRoom:Object;

      private var _netSending:Boolean = false;

      private var _netKeys:Object = {};

      private var _netLastSent:Object = {};

      private var _netStarted:Boolean = false;

      private var _netPending:String;

      private var _netReady:Boolean = false;

      private var _netListening:Boolean = false;

      private var _lbBox:Sprite;

      private var _lbName:TextField;

      private var _lbIp:TextField;

      private var _lbCode:TextField;

      private var _lbStatus:TextField;

      private var _lbCodeLabel:TextField;

      private var _lbP1:TextField;

      private var _lbP2:TextField;

      private var _lbFighter:TextField;

      private var _lbAssist:TextField;

      private var _lbMap:TextField;

      private var _lbMapLabel:TextField;

      private var _lbStart:KyoSimpButton;

      private var _lbWait:TextField;

      private var _lbIsHost:Boolean = false;

      private function netLabel(param1:String, param2:int, param3:uint, param4:Number, param5:Number, param6:Number = 400) : TextField
      {
         var t:TextField = new TextField();
         t.defaultTextFormat = new TextFormat("_sans",param2,param3);
         t.text = param1;
         t.x = param4;
         t.y = param5;
         t.width = param6;
         t.height = param2 + 12;
         t.mouseEnabled = false;
         return t;
      }

      private function netInput(param1:String, param2:Number, param3:Number, param4:Number = 220) : TextField
      {
         var t:TextField = new TextField();
         t.defaultTextFormat = new TextFormat("_sans",18,0);
         t.text = param1;
         t.x = param2;
         t.y = param3;
         t.width = param4;
         t.height = 28;
         t.type = TextFieldType.INPUT;
         t.border = true;
         t.background = true;
         t.backgroundColor = 16777215;
         t.textColor = 0;
         return t;
      }

      private function netButton(param1:Sprite, param2:String, param3:Number, param4:Number, param5:Function, param6:Number = 150, param7:Number = 44) : KyoSimpButton
      {
         var b:KyoSimpButton = new KyoSimpButton(param2,param6,param7);
         b.x = param3;
         b.y = param4;
         b.onClick(param5);
         param1.addChild(b);
         return b;
      }

      public function goLobby(param1:Boolean) : void
      {
         trace("FighterTester.goLobby host=" + param1);
         _lbIsHost = param1;
         netCleanup();
         _testUI.x = 0;
         _testUI.visible = true;
         _testUI.graphics.clear();
         while(_testUI.numChildren > 0)
         {
            _testUI.removeChildAt(0);
         }
         _testUI.graphics.beginFill(5,5,5,0.92);
         _testUI.graphics.drawRect(0,0,800,600);
         _testUI.graphics.endFill();
         _lbBox = new Sprite();
         _testUI.addChild(_lbBox);
         _lbBox.addChild(netLabel("ONLINE LOBBY",38,16753920,230,24));
         _lbBox.addChild(netLabel("Tên bạn:",20,16777215,180,110));
         _lbName = netInput("Player",330,106,260);
         _lbBox.addChild(_lbName);
         if(!param1)
         {
            _lbBox.addChild(netLabel("IP máy chủ:",20,16777215,180,156));
            _lbIp = netInput("127.0.0.1",330,152,260);
            _lbBox.addChild(_lbIp);
         }
         else
         {
            _lbIp = null;
         }
         var self:FighterTester = this;
         netButton(_testUI,"Tạo phòng",110,220,function(... rest) : void
         {
            self.netDoCreate();
         },170);
         netButton(_testUI,"Tìm phòng",320,220,function(... rest) : void
         {
            self.netDoFind();
         },170);
         netButton(_testUI,"Quay lại",530,220,function(... rest) : void
         {
            self.netCleanup();
            MainGame.I.goMenu();
         },130);
         _lbStatus = netLabel("",16,16711680,110,320,580);
         _lbStatus.multiline = true;
         _lbStatus.height = 120;
         _lbBox.addChild(_lbStatus);
      }

      private function netSay(param1:String) : void
      {
         if(_lbStatus != null)
         {
            _lbStatus.text = param1;
         }
      }

      private function netMyName() : String
      {
         var s:String = _lbName != null ? _lbName.text : "Player";
         s = s.replace(/^\s+|\s+$/g,"");
         return s.length > 0 ? s : "Player";
      }

      public function netCleanup() : void
      {
         _netSending = false;
         _netStarted = false;
         _netReady = false;
         _netPending = null;
         _netRoom = null;
         _netKeys = {};
         _netLastSent = {};
         if(_netSock != null)
         {
            try
            {
               _netSock.close();
            }
            catch(e:Error)
            {
            }
            _netSock = null;
         }
         _netBuf = "";
      }

      private function netDoCreate() : void
      {
         _netPending = "create";
         netSay("Đang nối tới máy chủ...");
         netConnect();
      }

      private function netDoFind() : void
      {
         _netPending = "find";
         netSay("Đang nối tới máy chủ...");
         netConnect();
      }

      private function netConnect() : void
      {
         _netHosts = [NET_PUBLIC,"127.0.0.1"];
         if(_lbIp != null && _lbIp.text.length > 0)
         {
            _netHosts = [_lbIp.text,NET_PUBLIC,"127.0.0.1"];
         }
         _netHostIdx = 0;
         netTryHost();
      }

      private function netTryNext() : void
      {
         _netHostIdx++;
         netCloseSocket();
         netTryHost();
      }

      private function netCloseSocket() : void
      {
         if(_netSock != null)
         {
            try
            {
               _netSock.close();
            }
            catch(e:Error)
            {
            }
            _netSock = null;
         }
         _netBuf = "";
      }

      private function netTryHost() : void
      {
         while(_netHostIdx < _netHosts.length && String(_netHosts[_netHostIdx]).length == 0)
         {
            _netHostIdx++;
         }
         if(_netHostIdx >= _netHosts.length)
         {
            netSay("Không nối được tới máy chủ.");
            return;
         }
         netCloseSocket();
         var host:String = String(_netHosts[_netHostIdx]);
         netSay("Đang nối tới " + host + "...");
         _netSock = new Socket();
         _netSock.timeout = 8000;
         _netSock.addEventListener(Event.CONNECT,netOnConnect);
         _netSock.addEventListener(Event.CLOSE,netOnClose);
         _netSock.addEventListener(IOErrorEvent.IO_ERROR,netOnFail);
         _netSock.addEventListener(SecurityErrorEvent.SECURITY_ERROR,netOnFail);
         _netSock.addEventListener(ProgressEvent.SOCKET_DATA,netOnData);
         Security.loadPolicyFile("xmlsocket://" + host + ":21337");
         try
         {
            _netSock.connect(host,21337);
         }
         catch(e:Error)
         {
            netTryNext();
         }
      }

      private function netSend(param1:Object) : void
      {
         if(_netSock != null && _netSock.connected)
         {
            try
            {
               _netSock.writeUTFBytes(JSON.stringify(param1) + "\n");
               _netSock.flush();
            }
            catch(e:Error)
            {
            }
         }
      }

      private function netOnConnect(param1:Event) : void
      {
         netSend({"t":"hello","username":netMyName()});
      }

      private function netOnFail(param1:Event) : void
      {
         if(!_netReady)
         {
            netTryNext();
            return;
         }
         netOnClose(null);
      }

      private function netOnClose(param1:Event) : void
      {
         if(!_netStarted)
         {
            netSay("Mất kết nối tới máy chủ.");
         }
      }

      private function netOnData(param1:ProgressEvent) : void
      {
         _netBuf = _netBuf + _netSock.readUTFBytes(_netSock.bytesAvailable);
         var idx:int = 0;
         var line:String = null;
         var msg:Object = null;
         while((idx = _netBuf.indexOf("\n")) >= 0)
         {
            line = _netBuf.substring(0,idx);
            _netBuf = _netBuf.substring(idx + 1);
            if(line.length == 0)
            {
               continue;
            }
            msg = null;
            try
            {
               msg = JSON.parse(line);
            }
            catch(e:Error)
            {
               continue;
            }
            if(msg != null)
            {
               netOnMessage(msg);
            }
         }
      }

      private function netOnMessage(param1:Object) : void
      {
         if(param1 == null || param1.t == null)
         {
            return;
         }
         var t:String = param1.t;
         if(t == "welcome")
         {
            _netReady = true;
            if(_netPending == "create")
            {
               netSend({"t":"create"});
            }
            else if(_netPending == "find")
            {
               netSend({"t":"quickjoin"});
            }
            _netPending = null;
         }
         else if(t == "room_created")
         {
            netEnterRoom();
         }
         else if(t == "room_updated")
         {
            _netRoom = param1.room;
            netRefreshRoom();
         }
         else if(t == "game_started")
         {
            netOnGameStarted(param1);
         }
         else if(t == "opponent_input")
         {
            netApplyRemote(param1.type,param1.key);
         }
         else if(t == "peer_left")
         {
            netOnPeerLeft();
         }
         else if(t == "error")
         {
            netSay(String(param1.message));
         }
      }

      private function netBox(param1:Number, param2:Number, param3:Number, param4:Number) : void
      {
         _lbBox.graphics.lineStyle(2,16753920,0.6);
         _lbBox.graphics.beginFill(20,20,20,0.55);
         _lbBox.graphics.drawRect(param1,param2,param3,param4);
         _lbBox.graphics.endFill();
      }

      private function netEnterRoom() : void
      {
         var self:FighterTester = this;
         while(_testUI.numChildren > 0)
         {
            _testUI.removeChildAt(0);
         }
         _lbBox = new Sprite();
         _testUI.addChild(_lbBox);
         _lbCodeLabel = netLabel("Mã phòng: ...",34,16753920,200,16,420);
         _lbBox.addChild(_lbCodeLabel);
         netBox(40,90,330,250);
         netBox(430,90,330,250);
         _lbBox.addChild(netLabel("P1 - CHỦ PHÒNG",20,16753920,70,100,280));
         _lbP1 = netLabel("",18,16777215,70,135,280);
         _lbP1.multiline = true;
         _lbP1.height = 150;
         _lbBox.addChild(_lbP1);
         _lbBox.addChild(netLabel("P2 - KHÁCH",20,65535,460,100,280));
         _lbP2 = netLabel("",18,16777215,460,135,280);
         _lbP2.multiline = true;
         _lbP2.height = 150;
         _lbBox.addChild(_lbP2);
         _lbBox.addChild(netLabel("NV của bạn:",18,16777215,70,360));
         _lbFighter = netInput("ichigo",250,356,180);
         _lbBox.addChild(_lbFighter);
         _lbFighter.addEventListener(Event.CHANGE,function(... rest) : void
         {
            self._lbTouched = true;
            self.netSendPick();
         });
         _lbBox.addChild(netLabel("Trợ thủ:",18,16777215,70,400));
         _lbAssist = netInput("kon",250,396,180);
         _lbBox.addChild(_lbAssist);
         _lbAssist.addEventListener(Event.CHANGE,function(... rest) : void
         {
            self._lbTouched = true;
            self.netSendPick();
         });
         _lbBox.addChild(netLabel("Bản đồ:",18,16777215,70,440));
         _lbMap = netInput("GenSe",250,436,180);
         _lbBox.addChild(_lbMap);
         _lbMap.addEventListener(Event.CHANGE,function(... rest) : void
         {
            self._lbTouched = true;
            self.netSendPick();
         });
         _lbMapLabel = netLabel("",16,10066329,460,440,300);
         _lbBox.addChild(_lbMapLabel);
         _lbStart = new KyoSimpButton("Bắt đầu",170,48);
         _lbStart.x = 180;
         _lbStart.y = 500;
         _lbStart.onClick(function(... rest) : void
         {
            self.netDoStart();
         });
         _lbBox.addChild(_lbStart);
         _lbWait = netLabel("Đang chờ chủ phòng bắt đầu...",18,16776960,180,505,460);
         _lbBox.addChild(_lbWait);
         netButton(_lbBox,"Rời phòng",480,500,function(... rest) : void
         {
            self.netCleanup();
            MainGame.I.goMenu();
         },150,44);
         _lbTouched = false;
         netSendPick();
      }

      private function netDoStart() : void
      {
         if(_netStarted)
         {
            return;
         }
         _netStarted = true;
         netSend({"t":"start"});
      }

      private function netSendPick() : void
      {
         if(_lbFighter == null || _netSock == null)
         {
            return;
         }
         var m:String = _lbMap != null ? _lbMap.text : "";
         netSend({"t":"pick","fighter":_lbFighter.text,"assist":_lbAssist.text,"map":m});
      }

      private function netPickOf(param1:String) : Object
      {
         if(_netRoom == null || _netRoom.players == null)
         {
            return null;
         }
         for each(var p:Object in _netRoom.players)
         {
            if(p.role == param1)
            {
               return p.pick;
            }
         }
         return null;
      }

      private function netRefreshRoom() : void
      {
         if(_netRoom == null || _lbBox == null)
         {
            return;
         }
         var hp:Object = netPickOf("host");
         var gp:Object = netPickOf("guest");
         var hn:String = "?";
         var gn:String = "?";
         for each(var p:Object in _netRoom.players)
         {
            if(p.role == "host")
            {
               hn = p.username;
            }
            else
            {
               gn = p.username;
            }
         }
         var hf:String = hp && hp.fighter ? hp.fighter : "-";
         var ha:String = hp && hp.assist ? hp.assist : "-";
         var gf:String = gp && gp.fighter ? gp.fighter : "-";
         var ga:String = gp && gp.assist ? gp.assist : "-";
         var myRole:String = _lbIsHost ? "host" : "guest";
         for each(var q:Object in _netRoom.players)
         {
            if(q.username == netMyName())
            {
               myRole = q.role;
            }
         }
         _netRole = myRole;
         var amHost:Boolean = myRole == "host";
         if(!_lbTouched)
         {
            if(amHost)
            {
               _lbFighter.text = "ichigo";
               _lbAssist.text = "kon";
            }
            else
            {
               _lbFighter.text = "naruto";
               _lbAssist.text = "gaara";
            }
            netSendPick();
         }
         _lbCodeLabel.text = "MÃ PHÒNG: " + _netRoom.roomCode;
         _lbP1.text = hn + "\nNV: " + hf + "\nTT: " + ha;
         _lbP2.text = (gn != "?" ? gn : "đang chờ...") + "\nNV: " + gf + "\nTT: " + ga;
         var hm:String = hp && hp.map && hp.map.length > 0 ? hp.map : "GenSe";
         if(amHost)
         {
            _lbMap.visible = true;
            _lbMapLabel.visible = false;
            if(_lbStart != null)
            {
               _lbStart.visible = true;
               var full:Boolean = _netRoom.players.length >= 2;
               _lbStart.mouseEnabled = full;
               _lbStart.alpha = full ? 1 : 0.4;
            }
            if(_lbWait != null)
            {
               _lbWait.visible = false;
            }
         }
         else
         {
            _lbMap.visible = false;
            _lbMapLabel.visible = true;
            _lbMapLabel.x = 250;
            _lbMapLabel.y = 436;
            _lbMapLabel.text = "Bản đồ: " + hm;
            if(_lbStart != null)
            {
               _lbStart.visible = false;
            }
            if(_lbWait != null)
            {
               _lbWait.visible = true;
            }
         }
      }

      private function netOnGameStarted(param1:Object) : void
      {
         var hp:Object = netPickOf("host");
         var gp:Object = netPickOf("guest");
         if(hp == null)
         {
            hp = {"fighter":"ichigo","assist":"kon","map":"GenSe"};
         }
         if(gp == null)
         {
            gp = {"fighter":"naruto","assist":"gaara","map":""};
         }
         _netRole = String(param1.youAre);
         var p1F:String = hp.fighter && hp.fighter.length > 0 ? hp.fighter : "ichigo";
         var p1Z:String = hp.assist && hp.assist.length > 0 ? hp.assist : "kon";
         var p2F:String = gp.fighter && gp.fighter.length > 0 ? gp.fighter : "naruto";
         var p2Z:String = gp.assist && gp.assist.length > 0 ? gp.assist : "gaara";
         var mapId:String = hp.map && hp.map.length > 0 ? hp.map : "GenSe";
         GameData.I.p1Select = new SelectVO();
         GameData.I.p2Select = new SelectVO();
         GameData.I.p1Select.fighter1 = p1F;
         GameData.I.p1Select.fuzhu = p1Z;
         GameData.I.p2Select.fighter1 = p2F;
         GameData.I.p2Select.fuzhu = p2Z;
         GameData.I.selectMap = mapId;
         GameMode.currentMode = 21;
         if(!_netListening)
         {
            _netListening = true;
            stage.addEventListener(KeyboardEvent.KEY_DOWN,netOnKeyDown);
            stage.addEventListener(KeyboardEvent.KEY_UP,netOnKeyUp);
         }
         _netKeys = {};
         _netLastSent = {};
         _netSending = true;
         MainGame.I.loadGame();
      }

      private function netLocalCfg() : Object
      {
         return _netRole == "host" ? GameData.I.config.key_p1 : GameData.I.config.key_p2;
      }

      private function netRemoteCfg() : Object
      {
         return _netRole == "host" ? GameData.I.config.key_p2 : GameData.I.config.key_p1;
      }

      private function netActionState() : Object
      {
         var cfg:Object = netLocalCfg();
         var st:Object = {};
         st["up"] = isNetKeyDown(cfg.up);
         st["down"] = isNetKeyDown(cfg.down);
         st["left"] = isNetKeyDown(cfg.left);
         st["right"] = isNetKeyDown(cfg.right);
         st["attack"] = isNetKeyDown(cfg.attack);
         st["jump"] = isNetKeyDown(cfg.jump);
         st["dash"] = isNetKeyDown(cfg.dash);
         st["skill"] = isNetKeyDown(cfg.skill);
         st["superKill"] = isNetKeyDown(cfg.superKill);
         st["special"] = isNetKeyDown(cfg.beckons);
         return st;
      }

      private function isNetKeyDown(param1:uint) : Boolean
      {
         return _netKeys["k" + param1] == 1;
      }

      private function netOnKeyDown(param1:KeyboardEvent) : void
      {
         _netKeys["k" + param1.keyCode] = 1;
         netSyncActions();
         if(param1.keyCode == 27)
         {
            netSendRaw("esc",true);
         }
      }

      private function netOnKeyUp(param1:KeyboardEvent) : void
      {
         _netKeys["k" + param1.keyCode] = 0;
         netSyncActions();
         if(param1.keyCode == 27)
         {
            netSendRaw("esc",false);
         }
      }

      private function netSyncActions() : void
      {
         if(!_netSending)
         {
            return;
         }
         var st:Object = netActionState();
         for(var a:String in st)
         {
            if(st[a] != _netLastSent[a])
            {
               _netLastSent[a] = st[a];
               netSendRaw(a,st[a]);
            }
         }
      }

      private function netSendRaw(param1:String, param2:Boolean) : void
      {
         if(!_netSending)
         {
            return;
         }
         netSend({"t":"input","type":param2 ? "keydown" : "keyup","key":param1,"frame":int(getTimer() / 33)});
      }

      private function netApplyRemote(param1:String, param2:String) : void
      {
         if(!_netSending)
         {
            return;
         }
         var code:uint = netRemoteCode(param2);
         if(code == 0)
         {
            return;
         }
         var down:Boolean = param1 == "keydown";
         var ev:KeyboardEvent = new KeyboardEvent(down ? "keyDown" : "keyUp");
         ev.keyCode = code;
         try
         {
            stage.dispatchEvent(ev);
         }
         catch(e:Error)
         {
         }
      }

      private function netRemoteCode(param1:String) : uint
      {
         var cfg:Object = netRemoteCfg();
         if(cfg == null)
         {
            return 0;
         }
         if(param1 == "up")
         {
            return cfg.up;
         }
         if(param1 == "down")
         {
            return cfg.down;
         }
         if(param1 == "left")
         {
            return cfg.left;
         }
         if(param1 == "right")
         {
            return cfg.right;
         }
         if(param1 == "attack")
         {
            return cfg.attack;
         }
         if(param1 == "jump")
         {
            return cfg.jump;
         }
         if(param1 == "dash")
         {
            return cfg.dash;
         }
         if(param1 == "skill")
         {
            return cfg.skill;
         }
         if(param1 == "superKill")
         {
            return cfg.superKill;
         }
         if(param1 == "special")
         {
            return cfg.beckons;
         }
         if(param1 == "esc")
         {
            return 27;
         }
         var n:Number = parseInt(param1);
         if(!isNaN(n))
         {
            return uint(n);
         }
         return 0;
      }

      private function netOnPeerLeft() : void
      {
         if(_netStarted)
         {
            netCleanup();
            MainGame.I.goMenu();
            return;
         }
         netSay("Đối thủ đã rời phòng.");
      }
   }
}

