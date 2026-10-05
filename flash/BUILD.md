# Đưa code vào game (FFDec)

Công cụ: JPEXS Free Flash Decompiler (FFDec), mục CLI.

## Import 1 file đã sửa vào SWF

```
java -jar ffdec.jar -importScript Game\FighterTester.swf \
  Game\FighterTester.swf <thư-mục-chứa-file-.as>
```

Thư mục `.as` phải giữ đúng cấu trúc package, VD:

```
imp/
  FighterTester.as
  net/play5d/game/obvn/MainGame.as
  net/play5d/game/obvn/data/GameInterface.as
  net/play5d/game/obvn/ui/MenuBtnGroup.as
  net/play5d/game/obvn/stage/MenuStage.as
```

Lệnh không in gì khi thành công. Kiểm tra bằng cách export lại
(`-export script`) và so sánh nội dung.

## Đổi địa chỉ server mặc định (khi đã deploy server công cộng)

1. Sửa `NET_PUBLIC` trong `flash/swf-edits/FighterTester.as`
   (VD: `"bvn-netplay.fly.dev"`), import lại file này.
2. Client thử server công cộng trước, rớt xuống `127.0.0.1`.

## Lưu ý đã biết

- FFDec `-importScript` chỉ nhận file sửa class ĐÃ CÓ, không thêm
  class mới (đã kiểm chứng). Mọi logic online nằm gọn trong
  `FighterTester.as` (socket + lobby UI + relay input), các file khác
  chỉ thêm menu/method gọi sang.
- Giữ SWF dạng FWS (không nén) khi vá tag thủ công: Flash Player 32
  từ chối stream LZMA nén lại bằng Python.
- Khung stage hiện tại 800x600 (đã thu từ 1000 để giấu panel dev).
