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

package net.play5d.game.bvn.ui.fight {
import flash.display.DisplayObject;

import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.game.bvn.ui.energy.EnergyBarFill;
import net.play5d.game.bvn.ui.energy.EnergyBarLabel;

public class EnergyBar {

    public function EnergyBar(ui:$fight$MC_energyBar) {
        _ui = ui;

        _bar = new EnergyBarFill(_ui.barmc.bar);
        _txt = new EnergyBarLabel(_ui.txtmc);

    }
    private var _fighter:FighterMain;

    private var _bar:EnergyBarFill;
    private var _txt:EnergyBarLabel;

    private var _renderFlash:Boolean;
    private var _renderFlashInt:int;

    private var _ui:$fight$MC_energyBar;

    public function get ui():DisplayObject {
        return _ui;
    }

    public function destroy():void {
        _fighter = null;
    }

    public function setFighter(v:FighterMain):void {
        _fighter = v;

        if (v.data) {
            _txt.setType(v.data.comicType);
        }

    }

    public function setDirect(v:int):void {
        _txt.setDirect(v);
    }

    public function render():void {

        _bar.rate = _fighter.energy / _fighter.energyMax;

        if (_fighter.energyOverLoad) {
            _bar.overLoad();
            _txt.overLoad();
        }
        else {
            if (_bar.rate < 0.3) {
                _bar.flash();
                _txt.flash();
            }
            else {
                _bar.normal();
                _txt.normal();
            }
        }

        _bar.render();
        _txt.render();

    }

}
}
