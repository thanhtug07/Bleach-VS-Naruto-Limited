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

package net.play5d.game.bvn.ide.utils {
import flash.utils.getDefinitionByName;

import net.play5d.game.bvn.ide.data.GamePKGName;

/**
 * 游戏元件相关实用工具。
 *
 * <p>通过反射获取 KernelLogic 类，避免 CORE_Components 编译期依赖 KernelLogic。</p>
 *
 * @see net.play5d.game.bvn.ide.data.GamePKGName
 * @see net.play5d.game.bvn.ide.data.GameSpriteType
 */
public class GameSpriteUtils {

    /**
     * 获取游戏元件类。
     *
     * @param type 类型（见 <code>GameSpriteType</code>）。
     * @return 指定游戏元件类；找不到时返回 <code>null</code>。
     *
     * @example
     * <listing version="3.0">
     * var cls:Class = GameSpriteUtils.getGameSpriteClass('FighterMain');
     * </listing>
     *
     * @see #getGameClass()
     * @see net.play5d.game.bvn.ide.data.GameSpriteType
     */
    public static function getGameSpriteClass(type:String):Class {
        return getGameClass(GamePKGName.FIGHTER + type);
    }

    /**
     * 获取游戏类。
     *
     * @param name 类的全限定名称。
     * @return 指定类；找不到时返回 <code>null</code>。
     *
     * @example
     * <listing version="3.0">
     * var cls:Class = GameSpriteUtils.getGameClass('net.play5d.game.bvn.ctrler.game_ctrls::GameCtrl');
     * </listing>
     */
    public static function getGameClass(name:String):Class {
        try {
            return getDefinitionByName(name) as Class;
        }
        catch (e:Error) {
            trace('[GameSpriteUtils] class not found:', name);
        }
        return null;
    }
}
}
