# LIB_KyoLib 首选 API（AI）

何时读：在 `LIB_KyoLib` 新增/改工具、加载、延时、存档 IO、按钮工具，或不确定该用哪套类。包落点见下文；通用模块入口见 [`modules.md`](modules.md)。

---

## MUST

| # | 域 | 首选 | 说明 |
|---|----|------|------|
| 1 | 文本/字节 HTTP | `KyoURLLoader` | GET/POST、二进制；**不要**用 `AJAX` 写新代码 |
| 2 | 显示对象加载 | `KyoLoaderLite` | `load` / `loadLoader`；二进制可再委托 `KyoURLLoader` |
| 3 | 游戏内延时 | `KyoTimeout` | 须先 `init`；帧同步（`setFrameTimeout` / 毫秒转帧） |
| 4 | 广告/可暂停延时 | `KyoTimerUtils` | 真实 `Timer`；支持 `pauseAllTimer` / `resumeAllTimer` |
| 5 | AIR 本地文件 | `net.play5d.kyo.air.utils.FileUtils` | **仅 AIR**（`kyo.air.*`）；壳存档读写 |
| 6 | SharedObject 快照 | `net.play5d.kyo.storage.KyoSharedObject` | 简单 load/save |
| 7 | 媒体容器播放 | `net.play5d.kyo.media.SuperPlayer` | ppt/页内播放器 |

## NEVER

- 合并 `KyoTimeout` 与 `KyoTimerUtils`（时钟与暂停语义不同）
- 合并 `KyoURLLoader` 与 `KyoLoaderLite`（URLLoader ≠ Display Loader）
- 合并游戏 `BtnUtils` 与库 `KyoBtnUtils`（见下节）
- 新代码依赖 `AJAX`、未标注用途的根包杂类
- 在非 AIR 目标中引用 `net.play5d.kyo.air.*`（仅 AIR：`FileUtils` / `ProcessUtils` 等）

---

## 延时对照

| | `KyoTimeout` | `KyoTimerUtils` |
|--|--------------|-----------------|
| 驱动 | `ENTER_FRAME` | `flash.utils.Timer` |
| 典型 | 战斗/UI/关卡节奏 | Mob 广告 SDK、应用暂停需冻结 |
| 本仓 | `MainGame`、`MusouUI`、`GameOverStage`、`LANClientCtrl` | `launch`、ads |

---

## AIR 包

`net.play5d.kyo` 之后插入 `.air`，其后路径与原包一致，表示该树下类依赖 AIR API。

| 类 | 包 |
|----|-----|
| `FileUtils` | `net.play5d.kyo.air.utils` |
| `ProcessUtils` | `net.play5d.kyo.air.utils` |
| `SocketClient` / `SocketServer` / `SocketEvent` | `net.play5d.kyo.air.socket`（定长头 TCP；异于非 AIR 的 `kyo.socket.KyoSocket`） |

---

## 按钮：评估结论 — **不要合并**

| | `net.play5d.game.bvn.utils.BtnUtils` | `net.play5d.kyo.utils.KyoBtnUtils` |
|--|--------------------------------------|-----------------------------------|
| 层 | 游戏内核 | KyoLib（壳 LAN UI） |
| 能力 | 触控 + `SoundCtrl` 点击音 + 色变 | TweenLite 按下变暗/弹性；`initSampleBtn` |
| 依赖 | `GameConfig` / `SoundCtrl` | Greensock |

两套签名与依赖不同；并入会把游戏音效/触控拖进库，或让 LAN 失去 Tween 效果。**保持双轨**：玩法 UI → `BtnUtils`；Pc LAN 对话框 → `KyoBtnUtils`。

---

## 包落点（根包已归位）

| 包 | 放什么 |
|----|--------|
| `kyo.air.*` | **仅 AIR**（如 `air.utils.FileUtils` / `ProcessUtils`） |
| `kyo.loader` | URLoader / LoaderLite 等 |
| `kyo.utils` | 跨运行时静态工具（非 AIR 专用） |
| `kyo.storage` | SharedObject 相关 |
| `kyo.media` | `SuperPlayer` |
| `kyo.cache` | `KyoCacheManager` |
| `kyo.display.*` | 显示与 UI 组件 |

---

## 速查

```actionscript
// 加载
KyoURLLoader.load(url, onText);
KyoLoaderLite.loadLoader(url, onLoader, onFail, onProg);

// 延时
KyoTimeout.init(root);
KyoTimeout.setFrameTimeout(fn, frames);
KyoTimerUtils.setTimeout(fn, ms); // 可 pauseAllTimer
```
