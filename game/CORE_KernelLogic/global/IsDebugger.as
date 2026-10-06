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

import net.play5d.game.bvn.GameConfig;

/**
 * 判断当前是否处于调试环境。
 *
 * <p>播放器调试版（<code>Capabilities.isDebugger</code>）或
 * <code>GameConfig.DEBUG_MODE</code> 任一为真即返回 <code>true</code>。
 * 不缓存，以便运行期切换 <code>DEBUG_MODE</code> 仍生效。</p>
 *
 * @return 调试环境为 <code>true</code>，否则为 <code>false</code>。
 * @example
 * <listing version="3.0">
 * if (IsDebugger()) {
 *     Trace('debug only');
 * }
 * </listing>
 * @see ThrowError
 * @see net.play5d.game.bvn.GameConfig#DEBUG_MODE
 */
public function IsDebugger():Boolean {
    return Capabilities.isDebugger || GameConfig.DEBUG_MODE;
}
}
