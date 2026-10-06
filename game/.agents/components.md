# CORE_Components（AI）

何时读：改 Animate IDE 组件库、时间轴效果组件、或 `$xxx_ctrler` 注入契约相关任务。常规玩法默认不进本模块（见 [`modules.md`](modules.md)）。

---

## 定位

| 项 | 说明 |
|----|------|
| 角色 | Animate 可拖拽组件类，供 `BleachVsNaruto_FlashSrc/.../#swc/component`（`component.xfl`） |
| 不是 | 游戏内 ECS / SHELL 运行时模块 |
| 编译依赖 | Merged `CORE_Shared` + `LIB_KyoLib`；**禁止**编译期依赖 KernelLogic |
| 运行契约 | FighterMain `main_mc.initFighter` 注入动态属性；组件沿 parent 链读取 |

---

## MUST

| # | 规则 |
|---|------|
| 1 | 效果/动作/镜头等组件聚焦 **FighterMain 时间轴**：只认对应 `$xxx_ctrler` |
| 2 | 动态属性调用前做能力检查：`hasMethod` / `requireMethods`；缺注入或无方法须 `trace` 诊断，禁止静默空操作无日志 |
| 3 | 调用走对应 Base：`invokeEffect` / `invokeFighter` / `invokeMc` / `invokeCamera`（均基于 `BaseIdeCtrler.invokeCtrler`） |
| 4 | 新组件：继承对应 Base；无参效果优先 `bindNoArgCall`；保持 XFL linkage 类名稳定 |
| 5 | 注释仅标准 ASDoc（见 [`comment.md`](comment.md)）；无分区横幅、无复述式 `//` |
| 6 | 注入属性名与 KernelLogic `initFighter` 参数对齐：`$fighter_ctrler` / `$mc_ctrler` / `$effect_ctrler` / `$camera_ctrler` |

---

## NEVER

- 为 Assister / Bullet / FighterAttacker 在效果组件里加脆弱回退（当前效果路径不做）
- 让 `CORE_Components` 直接 import KernelLogic 类型
- 改玩法逻辑却先大改本模块
- 上 ECS / 组件注册表（当前效果少，过度设计）
- 无必要改 XFL linkage 类名（`ShineEffect` / `ShakeEffect` 等）

---

## 注入契约（FighterMain）

KernelLogic `FighterCtrler.initFighter` → 角色 `main_mc`：

```actionscript
var $fighter_ctrler:*;
var $mc_ctrler:*;
var $effect_ctrler:*;
var $camera_ctrler:*;
function initFighter(param:Object):void {
    $fighter_ctrler = param.fighter_ctrler;
    $mc_ctrler      = param.mc_ctrler;
    $effect_ctrler  = param.effect_ctrler;
    $camera_ctrler  = param.camera_ctrler;
}
```

时间轴等价用法：`parent.$effect_ctrler.shine()`；组件侧：`IdeRuntimeUtils.findXxxCtrler(this)`。

皮肤约定（Animate）：

```
ComponentRoot
  └── mc        // 公用「模板」实例
        ├── titleTxt
        ├── textTxt
        └── bg  // 「背景」元件实例；随预览文字自动拉宽
```

缺 `mc` 时基类回退到根节点查找同名子级。

---

## 类职责速查

| 类 | 职责 |
|----|------|
| `BaseComponent` | 一帧生命周期；`GameSpriteEntity` 仅在 `bindContext` 惰性创建 |
| `BaseIdeCtrler` | 皮肤预览 + `validateParam` / `updateCallPreview` / `invokeCtrler` |
| `BaseEffect` | `$effect_ctrler`；无参用 `bindNoArgCall` |
| `BaseFighter` | `$fighter_ctrler` + `invokeFighter` |
| `BaseMc` | `$mc_ctrler` + `invokeMc` |
| `BaseCamera` | `$camera_ctrler` + `invokeCamera` |
| 无参效果（Walk/Jump/…/End*） | `bindNoArgCall(title, method)` |
| 带参效果 | Inspectable + `refreshPreview` → `updateCallPreview`；颜色用 `ColorUtils.asLiteral` |
| `BaseIdeCtrler.validateParam` | 校验非空 / 特定值 / 枚举；失败红色完整提示 |
| `BaseIdeCtrler.updateCallPreview` | 显示 `parent.$xxx_ctrler.method(...)` |
| `IdeRuntimeUtils` | parent 链查找与动态方法校验 |
| `GameSpriteEntity` | `$self/$target/$owner`（IdeCtrler 主路径不调用） |
| `ColorUtils` | 预览用；`dec2hex`→`KyoColor.toHex`；`asLiteral`→`0x…` |

---

## 构建注意

- IDEA/`compc`：`CORE_Components.swc`（校验/库）
- Animate：另发 `shared/lib/swc/ide/component.swc`；改注入字段后角色 SWF 需重发
- 改包名字符串（`GamePKGName`）会静默断反射路径
