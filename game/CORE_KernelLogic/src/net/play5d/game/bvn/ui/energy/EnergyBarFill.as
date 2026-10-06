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

package net.play5d.game.bvn.ui.energy {
import flash.display.MovieClip;

/**
 * 能量条填充 MC：平滑缩放与闪烁 / 过载帧。
 *
 * @see EnergyBarLabel
 */
public class EnergyBarFill {

    /**
     * @param mc 填充条 MovieClip（用 <code>scaleX</code> 表示比率）。
     */
    public function EnergyBarFill(mc:MovieClip) {
        _mc = mc;
    }

    /** 目标比率 0–1 */
    public var rate:Number = 1;

    /** @private */
    private var _mc:MovieClip;
    /** @private */
    private var _isOverLoad:Boolean;
    /** @private */
    private var _isFlash:Boolean;
    /** @private */
    private var _renderFlashInt:int;
    /** @private */
    private var _renderFlashFrame:int = 2;

    /**
     * 每帧插值缩放并刷新闪烁。
     */
    public function render():void {
        var diff:Number = rate - _mc.scaleX;
        if (Math.abs(diff) < 0.01) {
            _mc.scaleX = rate;
        }
        else {
            _mc.scaleX += diff * 0.4;
        }

        if (_isFlash) {
            renderFlash();
        }
    }

    /**
     * 恢复正常帧。
     */
    public function normal():void {
        if (!_isOverLoad && !_isFlash) {
            return;
        }
        _isOverLoad = false;
        _isFlash    = false;
        _mc.gotoAndStop(1);
    }

    /**
     * 低能量闪烁。
     */
    public function flash():void {
        if (_isFlash) {
            return;
        }
        _isFlash          = true;
        _renderFlashInt   = 0;
        _renderFlashFrame = 2;
    }

    /**
     * 过载状态。
     */
    public function overLoad():void {
        if (_isOverLoad) {
            return;
        }
        _isOverLoad = true;
        _isFlash    = false;
        _mc.gotoAndStop(2);
    }

    /** @private */
    private function renderFlash():void {
        if (++_renderFlashInt > 2) {
            _renderFlashInt = 0;
            _mc.gotoAndStop(_renderFlashFrame);
            _renderFlashFrame = _renderFlashFrame == 1 ? 2 : 1;
        }
    }

}
}
