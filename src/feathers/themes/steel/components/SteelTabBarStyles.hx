/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.controls.TabBar;
import feathers.controls.ToggleButton;
import feathers.controls.ToggleButtonState;
import feathers.skins.RectangleSkin;
import feathers.style.Theme;
import feathers.themes.steel.BaseSteelTheme;

/**
	Initialize "steel" styles for the `TabBar` component.

	@since 1.0.0
**/
@:dox(hide)
@:access(feathers.themes.steel.BaseSteelTheme)
class SteelTabBarStyles {
	public static function initialize(?theme:BaseSteelTheme):Void {
		if (theme == null) {
			theme = Std.downcast(Theme.fallbackTheme, BaseSteelTheme);
		}
		if (theme == null) {
			return;
		}

		var styleProvider = theme.styleProvider;
		if (styleProvider.getStyleFunction(ToggleButton, TabBar.CHILD_VARIANT_TAB) == null) {
			styleProvider.setStyleFunction(ToggleButton, TabBar.CHILD_VARIANT_TAB, function(button:ToggleButton):Void {
				if (button.backgroundSkin == null) {
					var skin = new RectangleSkin();
					skin.fill = theme.getButtonFill();
					skin.selectedFill = theme.getThemeFill();
					skin.setFillForState(ToggleButtonState.DOWN(false), theme.getReversedActiveThemeFill());
					skin.setFillForState(ToggleButtonState.DISABLED(false), theme.getButtonDisabledFill());
					skin.setFillForState(ToggleButtonState.DOWN(false), theme.getReversedActiveThemeFill());
					skin.border = theme.getButtonBorder();
					skin.selectedBorder = theme.getActiveFillBorder();
					skin.setBorderForState(ToggleButtonState.DOWN(false), theme.getActiveFillBorder());
					skin.maxWidth = 100.0;
					skin.minWidth = 20.0;
					button.backgroundSkin = skin;
				}

				if (button.textFormat == null) {
					button.textFormat = theme.getTextFormat();
				}
				if (button.disabledTextFormat == null) {
					button.disabledTextFormat = theme.getDisabledTextFormat();
				}
				if (button.selectedTextFormat == null) {
					button.selectedTextFormat = theme.getActiveTextFormat();
				}

				if (button.getTextFormatForState(ToggleButtonState.DOWN(false)) == null) {
					button.setTextFormatForState(ToggleButtonState.DOWN(false), theme.getActiveTextFormat());
				}

				button.paddingTop = 4.0;
				button.paddingRight = 10.0;
				button.paddingBottom = 4.0;
				button.paddingLeft = 10.0;
				button.gap = 6.0;
			});
		}
	}
}
