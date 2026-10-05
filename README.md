# BVN Netplay — Bleach VS Naruto online 1vs1 (trong exe, không web)

Chơi online 2 người ngay trong game Flash, không cần trình duyệt.

## Chạy nhanh (chung nhà / chung VPN)

1. Cả 2 máy dùng đúng bản thư mục `Game` này.
2. Mỗi máy mở `ChoiGame.bat` (tự chạy server ngầm cổng 21337).
3. Máy chủ: menu `CREATE LOBBY` → nhập tên → `Tạo phòng` → gửi mã phòng cho bạn.
4. Máy khách: menu `PLAY ONLINE` → nhập tên + IP máy chủ → `Tìm phòng`.
5. Chủ phòng bấm `Bắt đầu`. Mỗi người điều khiển nhân vật của mình.

## Chơi khác nhà (internet)

- Cách dễ: cùng vào một mạng VPN LAN ảo (Radmin VPN / ZeroTier miễn phí),
  khách nhập IP VPN của máy chủ.
- Cách khác: máy chủ port-forward TCP 21337 về máy mình, khách nhập
  IP internet của máy chủ (xem tại whatismyip.com).
- Cách host server công cộng: deploy thư mục `netplay-server/` lên Fly.io
  hoặc Railway (có sẵn `Dockerfile` + `fly.toml`), rồi sửa hằng số
  `NET_PUBLIC` trong `flash/FighterTester.as` thành địa chỉ server và
  build lại SWF (xem `flash/BUILD.md`).

## Cấu trúc

- `netplay-server/server.js` — server relay TCP headless, 0 dependency.
  Protocol JSON theo dòng: hello / create / join / quickjoin / pick /
  start / input(keydown|keyup, action, frame) / leave. Policy Flash
  phục vụ ngay trên cổng game (không cần quyền admin).
- `flash/` — mã nguồn AS3 đưa vào game bằng FFDec: menu CREATE LOBBY +
  PLAY ONLINE, màn hình phòng chờ 2 bên, đồng bộ input qua fake
  KeyboardEvent (tương thích config phím tùy chỉnh mỗi máy).
- `tools/` — script quét/vá SWF, font, ảnh đã dùng cho bản Việt hóa.

## Test server

```
cd netplay-server
npm start        # hoặc: node server.js 21337
npm test         # 18 case: room, pick, relay, quickjoin, disconnect
```

## Build lại SWF sau khi sửa AS3

1. Mở FFDec, import các file trong `flash/` đè lên script cùng tên.
2. Đổi `NET_PUBLIC` rồi import lại `FighterTester.as`.
