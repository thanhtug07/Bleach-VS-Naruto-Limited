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
import net.play5d.kyo.utils.KyoStringFormat;

/**
 * 使用命名占位符 <code>{name}</code> 格式化字符串。
 *
 * <p>委托 <code>KyoStringFormat.formatNamed</code>。字面量大括号写作 <code>{{</code> 与 <code>}}</code>。</p>
 *
 * @param format 源字符串；空或无 <code>{</code> 时原样返回。
 * @param params 占位符名到替换值的映射；可为 <code>null</code>（视为空对象）。
 * @return 格式化后的字符串。
 * @throws ArgumentError 模板含命名占位符而 <code>params</code> 缺对应键。
 * @example
 * <listing version="3.0">
 * var out:String = Format('今天是星期{weekday}，天气：{weather}', {weekday: 1, weather: '晴'});
 * </listing>
 * @see Printf
 * @see GetLang
 * @see Trace
 * @see net.play5d.kyo.utils.KyoStringFormat#formatNamed()
 */
public function Format(format:String, params:Object = null):String {
    return KyoStringFormat.formatNamed(format, params);
}
}
