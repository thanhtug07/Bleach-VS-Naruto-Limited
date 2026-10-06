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
import flash.system.Capabilities;

/**
 * 判断当前是否运行于 AIR（Desktop）环境。
 *
 * <p>依据 <code>Capabilities.playerType == 'Desktop'</code>；结果进程内缓存于函数对象。</p>
 *
 * @return 运行于 AIR 时为 <code>true</code>，否则为 <code>false</code>。
 * @example
 * <listing version="3.0">
 * if (IsAIR()) {
 *     // 桌面 AIR 分支
 * }
 * </listing>
 * @see flash.system.Capabilities#playerType
 */
public function IsAIR():Boolean {
    // 缓存挂在函数对象上，避免包级第二外部可见定义
    if (IsAIR['_c'] != null) {
        return IsAIR['_c'];
    }
    IsAIR['_c'] = Capabilities.playerType == 'Desktop';
    return IsAIR['_c'];
}
}
