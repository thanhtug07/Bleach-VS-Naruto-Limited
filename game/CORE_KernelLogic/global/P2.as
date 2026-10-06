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
import net.play5d.game.bvn.ctrler.game_ctrls.GameCtrl;
import net.play5d.game.bvn.data.GameRunFighterGroup;
import net.play5d.game.bvn.fighter.FighterMain;

/**
 * 当前对局中 P2 出战角色。
 *
 * <p>队伍组或出战角色尚未就绪时返回 <code>null</code>。</p>
 *
 * @return P2 当前 <code>FighterMain</code>；不可用时为 <code>null</code>。
 * @example
 * <listing version="3.0">
 * if (P2) {
 *     trace(P2.hp);
 * }
 * </listing>
 * @see P1
 * @see net.play5d.game.bvn.ctrler.game_ctrls.GameCtrl#gameRunData
 */
public function get P2():FighterMain {
    var group:GameRunFighterGroup = GameCtrl.I.gameRunData.p2FighterGroup;
    return group ? group.currentFighter : null;
}
}
