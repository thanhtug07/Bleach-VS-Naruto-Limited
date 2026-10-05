package net.play5d.game.obvn
{
   import flash.display.Sprite;
   import flash.display.Stage;
   import flash.events.DataEvent;
   import flash.geom.Rectangle;
   import net.play5d.game.obvn.ctrler.GameRender;
   import net.play5d.game.obvn.ctrler.game_ctrler.GameCtrler;
   import net.play5d.game.obvn.data.GameConfig;
   import net.play5d.game.obvn.data.GameData;
   import net.play5d.game.obvn.data.GameMode;
   import net.play5d.game.obvn.input.GameInputer;
   import net.play5d.game.obvn.model.EffectModel;
   import net.play5d.game.obvn.stage.CongratulateStage;
   import net.play5d.game.obvn.stage.CreditsStage;
   import net.play5d.game.obvn.stage.GameLoadingStage;
   import net.play5d.game.obvn.stage.GameOverStage;
   import net.play5d.game.obvn.stage.GameStage;
   import net.play5d.game.obvn.stage.HowToPlayStage;
   import net.play5d.game.obvn.stage.LoadingStage;
   import net.play5d.game.obvn.stage.LogoStage;
   import flash.utils.getDefinitionByName;
   import net.play5d.game.obvn.stage.MenuStage;
   import net.play5d.game.obvn.stage.SelectFighterStage;
   import net.play5d.game.obvn.stage.SettingStage;
   import net.play5d.game.obvn.stage.WinnerStage;
   import net.play5d.game.obvn.utils.GameLogger;
   import net.play5d.game.obvn.utils.ResUtils;
   import net.play5d.kyo.stage.KyoStageCtrler;
   
   public class MainGame
   {
      
      public static const VER_LABEL:String = "OpenBVN  ";
      
      public static const VERSION:String = "OpenBVN V3.x  ";
      
      public static var stageCtrler:KyoStageCtrler;
      
      public static var I:MainGame;
      
      private var _rootSprite:Sprite;
      
      private var _stage:Stage;
      
      private var _fps:Number = 60;
      
      public function MainGame()
      {
         super();
         I = this;
      }
      
      private static function resetDefault() : void
      {
         GameCtrler.I.autoEndRoundAble = true;
         GameCtrler.I.autoStartAble = true;
         SelectFighterStage.AUTO_FINISH = true;
         LoadingStage.AUTO_START_GAME = true;
         GameMode.currentMode = 0;
      }
      
      public function get root() : Sprite
      {
         return _rootSprite;
      }
      
      public function get stage() : Stage
      {
         return _stage;
      }
      
      public function initlize(param1:Sprite, param2:Stage, param3:Function = null, param4:Function = null) : void
      {
         var root:Sprite = param1;
         var stage:Stage = param2;
         var initBack:Function = param3;
         var initFail:Function = param4;
         var resInitBack:* = function():void
         {
            GameLogger.log("Tải tài nguyên xong!");
            _rootSprite = root;
            _stage = stage;
            GameLogger.log("Khởi tạo render  ");
            GameRender.initlize(stage);
            GameLogger.log("Tạo bộ nhập ");
            GameInputer.initlize(_stage);
            GameLogger.log("Tạo data game      ");
            GameData.I.loadData();
            GameLogger.log("Tao cau hinh   ");
            GameData.I.config.applyConfig();
            GameLogger.log("Cấu hình phím       ");
            GameInputer.updateConfig();
            GameLogger.log("Tạo vùng cuộn");
            root.scrollRect = new Rectangle(0,0,GameConfig.GAME_SIZE.x,GameConfig.GAME_SIZE.y);
            GameLogger.log("Bộ khiển màn       ");
            stageCtrler = new KyoStageCtrler(_rootSprite);
            stageCtrler.setChangeBack(changeBack);
            GameLogger.log("Màn tải           ");
            var _loc1_:GameLoadingStage = new GameLoadingStage();
            stageCtrler.goStage(_loc1_);
            _loc1_.loadGame(loadGameBack,initFail);
         };
         var loadGameBack:* = function():void
         {
            EffectModel.I.initlize();
            if(initBack != null)
            {
               initBack();
            }
         };
         ResUtils.I.initalize(resInitBack,initFail);
      }
      
      private function changeBack() : void
      {
         Debugger.errorMsg("");
      }
      
      public function getFPS() : Number
      {
         return _fps;
      }
      
      public function setFPS(param1:Number) : void
      {
         _fps = param1;
         _stage.frameRate = param1;
      }
      
      public function goLogo() : void
      {
         stageCtrler.goStage(new LogoStage());
         setFPS(30);
      }
      
      public function goMenu() : void
      {
         (getDefinitionByName("FighterTester") as Class)["I"].netCleanup();
         MainGame.I.stage.dispatchEvent(new DataEvent("5d_message",false,false,JSON.stringify(["go_menu_stage"])));
         resetDefault();
         stageCtrler.goStage(new MenuStage());
         setFPS(30);
      }

      public function goLobby(param1:Boolean) : void
      {
         trace("goLobby host=" + param1);
         (getDefinitionByName("FighterTester") as Class)["I"].goLobby(param1);
      }
      
      public function goHowToPlay() : void
      {
         stageCtrler.goStage(new HowToPlayStage());
         setFPS(30);
      }
      
      public function goSelect() : void
      {
         stageCtrler.goStage(new SelectFighterStage(),true);
         setFPS(30);
      }
      
      public function loadGame() : void
      {
         var _loc1_:LoadingStage = new LoadingStage();
         stageCtrler.goStage(_loc1_,true);
         setFPS(30);
      }
      
      public function goGame() : void
      {
         var _loc1_:GameStage = new GameStage();
         stageCtrler.goStage(_loc1_);
         GameCtrler.I.startGame();
         setFPS(GameConfig.FPS_GAME);
      }
      
      public function goOption() : void
      {
         stageCtrler.goStage(new SettingStage());
         setFPS(30);
      }
      
      public function goContinue() : void
      {
         var _loc1_:GameOverStage = new GameOverStage();
         _loc1_.showContinue();
         stageCtrler.goStage(_loc1_);
         setFPS(30);
      }
      
      public function goWinner() : void
      {
         var _loc1_:WinnerStage = new WinnerStage();
         stageCtrler.goStage(_loc1_);
         setFPS(30);
      }
      
      public function goCredits() : void
      {
         stageCtrler.goStage(new CreditsStage());
         setFPS(30);
      }
      
      public function goCongratulations() : void
      {
         stageCtrler.goStage(new CongratulateStage());
         setFPS(30);
      }
   }
}

