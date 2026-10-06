/*
 * Copyright (C) 2021-2026, 5DPLAY Game Studio
 * All rights reserved.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

package {
import net.play5d.game.bvn.GameConfig;

/**
 * 判断当前构建是否按移动端（触控）模式运行。
 *
 * <p>以 <code>GameConfig.TOUCH_MODE</code> 为准，而非设备能力探测。</p>
 *
 * @return 触控模式开启时为 <code>true</code>，否则为 <code>false</code>。
 * @example
 * <listing version="3.0">
 * if (IsMobile()) {
 *     // 触控 UI / 输入分支
 * }
 * </listing>
 * @see net.play5d.game.bvn.GameConfig#TOUCH_MODE
 */
public function IsMobile():Boolean {
    return GameConfig.TOUCH_MODE;
}
}
