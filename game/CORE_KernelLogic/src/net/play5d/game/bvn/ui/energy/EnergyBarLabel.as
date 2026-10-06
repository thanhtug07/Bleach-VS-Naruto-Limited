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
 * 能量条文字 MC：漫画类型帧、朝向、闪烁 / 过载。
 *
 * @see EnergyBarFill
 */
public class EnergyBarLabel {

    /**
     * @param mc 文字容器；过载/闪烁作用于 <code>mc.mc</code>。
     */
    public function EnergyBarLabel(mc:MovieClip) {
        _mc = mc;
    }

    /** @private */
    private var _mc:MovieClip;
    /** @private */
    private var _isOverLoad:Boolean;
    /** @private */
    private var _isFlash:Boolean;
    /** @private */
    private var _renderFlashInt:int;
    /** @private */
    private var _renderFlashFrame:int;

    /**
     * 设置朝向（影响 <code>scaleX</code>）。
     * @param v 正数朝右，负数朝左。
     */
    public function setDirect(v:int):void {
        _mc.scaleX = v > 0 ? 1 : -1;
    }

    /**
     * 按漫画类型切帧。
     * @param v 0 / 1。
     */
    public function setType(v:int):void {
        switch (v) {
        case 0:
            _mc.gotoAndStop(1);
            break;
        case 1:
            _mc.gotoAndStop(2);
            break;
        }
    }

    /**
     * 刷新闪烁。
     */
    public function render():void {
        if (_isFlash) {
            renderFlash();
        }
    }

    /**
     * 恢复正常。
     */
    public function normal():void {
        if (!_isOverLoad && !_isFlash) {
            return;
        }
        _isOverLoad = false;
        _isFlash    = false;
        if (_mc.mc) {
            _mc.mc.gotoAndStop(1);
        }
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
        if (_mc.mc) {
            _mc.mc.gotoAndStop(2);
        }
    }

    /** @private */
    private function renderFlash():void {
        if (!_mc.mc) {
            return;
        }
        if (++_renderFlashInt > 2) {
            _renderFlashInt = 0;
            _mc.mc.gotoAndStop(_renderFlashFrame);
            _renderFlashFrame = _renderFlashFrame == 1 ? 2 : 1;
        }
    }

}
}
