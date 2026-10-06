/*
 * Copyright (C) 2021-2024, 5DPLAY Game Studio
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

package net.play5d.game.bvn.utils {
import net.play5d.game.bvn.interfaces.ILogger;

/**
 * 游戏日志门面：可注入 <code>ILogger</code>，否则 <code>trace</code>。
 *
 * @see #setLoger()
 * @see #log()
 */
public class GameLogger {

    /** @private */
    private static var _loger:ILogger;

    /**
     * 设置日志实现（如 PC 壳 <code>Loger</code>）。
     * @param v <code>ILogger</code> 或 <code>null</code> 清除。
     */
    public static function setLoger(v:Object):void {
        _loger = v as ILogger;
    }

    /**
     * 记录一条日志。
     * @param v 文本。
     */
    public static function log(v:String):void {
        if (_loger) {
            _loger.log(v);
        }
        else {
            trace(v);
        }
    }

}
}
