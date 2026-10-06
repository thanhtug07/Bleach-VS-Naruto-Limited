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

/**
 * 按语言包路径取文案（可带命名占位符），再带调试前缀输出。
 *
 * <p>等价于 <code>Trace(GetLang(tree, params))</code>。</p>
 *
 * @param tree 点分树形路径。
 * @param params 占位符名到替换值的映射；可为 <code>null</code>。
 * @throws ArgumentError 由 <code>Format</code> 在缺键时抛出。
 * @example
 * <listing version="3.0">
 * TraceLang('debug.trace.prefix');
 * TraceLang('debug.trace.data.game_ctrl.current_mode', {mode: GameMode.currentMode});
 * </listing>
 * @see GetLang
 * @see Trace
 */
public function TraceLang(tree:String, params:Object = null):void {
    Trace(GetLang(tree, params));
}
}
