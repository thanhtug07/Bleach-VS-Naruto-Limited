package net.play5d.game.obvn.data
{
   import net.play5d.game.obvn.interfaces.IGameInterface;
   
   public class GameInterface
   {
      
      public static var instance:IGameInterface;
      
      public function GameInterface()
      {
         super();
      }
      
      public static function getDefaultMenu() : Array
      {
         return [{
            "txt":"CREATE LOBBY",
            "cn":"Tạo phòng"
         },{
            "txt":"PLAY ONLINE",
            "cn":"Chơi online"
         },{
            "txt":"TEAM PLAY",
            "cn":"Chơi đội",
            "children":[{
               "txt":"TEAM ACRADE",
               "cn":"Đọc màn "
            },{
               "txt":"TEAM VS PEOPLE",
               "cn":"2P dau  "
            },{
               "txt":"TEAM VS CPU",
               "cn":"Đấu máy "
            },{
               "txt":"TEAM WATCH",
               "cn":"Xem máy    "
            }]
         },{
            "txt":"SINGLE PLAY",
            "cn":"Chơi đơn ",
            "children":[{
               "txt":"SINGLE ACRADE",
               "cn":"Đọc màn "
            },{
               "txt":"SINGLE VS PEOPLE",
               "cn":"2P dau  "
            },{
               "txt":"SINGLE VS CPU",
               "cn":"Đấu máy "
            },{
               "txt":"SINGLE WATCH",
               "cn":"Xem máy    "
            }]
         },{
            "txt":"OPTION",
            "cn":"Cài đặt "
         },{
            "txt":"TRAINING",
            "cn":"Luyen tap   "
         },{
            "txt":"CREDITS",
            "cn":"Nhom game"
         },{
            "txt":"MORE GAMES",
            "cn":"Game khác  "
         }];
      }
   }
}

