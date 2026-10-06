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
 * 输出带多语言调试前缀的字符串。
 *
 * <p><code>params</code> 非 <code>null</code> 时先对 <code>message</code> 执行
 * <code>Format</code>；为 <code>null</code> 时视为已格式化完成。</p>
 *
 * @param message 消息模板或已格式化的完整消息。
 * @param params 占位符参数；可为 <code>null</code>。
 * @throws ArgumentError 由 <code>Format</code> 在缺键时抛出。
 * @example
 * <listing version="3.0">
 * Trace('今天是星期{weekday}，天气：{weather}', {weekday: 1, weather: '晴'});
 * // 输出形如："* 跟踪 : 今天是星期1，天气：晴"
 * </listing>
 * @see Format
 * @see TraceLang
 * @see GetLangText
 */
public function Trace(message:String, params:Object = null):void {
    if (params != null) {
        message = Format(message, params);
    }

    trace(GetLangText('debug.trace.prefix') + message);
}
}
