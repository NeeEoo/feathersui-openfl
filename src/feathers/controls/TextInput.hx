/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.skins.IProgrammaticSkin;
import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
import feathers.core.IFocusObject;
import feathers.utils.MeasurementsUtil;
import feathers.themes.steel.components.SteelTextInputStyles;
import feathers.core.ITextControl;
import feathers.core.FeathersControl;
import feathers.core.IMeasureObject;
import feathers.core.InvalidationFlag;
import feathers.core.IStateContext;
import feathers.core.IStateObserver;
import feathers.core.IUIControl;
import feathers.core.IValidating;
import feathers.events.FeathersEvent;
import feathers.layout.VerticalAlign;
import feathers.layout.Measurements;
import openfl.display.DisplayObject;
import openfl.events.Event;
import openfl.events.FocusEvent;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFieldType;
import openfl.text.TextFormat;

/**
	A text entry control that allows users to enter and edit a single line of
	uniformly-formatted text.

	The following example sets the text in a text input, selects the text,
	and listens for when the text value changes:

	```hx
	var input = new TextInput();
	input.text = "Hello World";
	input.selectRange(0, input.text.length);
	input.addEventListener(Event.CHANGE, input_changeHandler);
	this.addChild(input);
	```

	@see [Tutorial: How to use the TextInput component](https://feathersui.com/learn/haxe-openfl/text-input/)

	@since 1.0.0
**/
@:styleContext
class TextInput extends FeathersControl implements IStateContext<TextInputState> implements ITextControl implements IFocusObject {
	/**
		Creates a new `TextInput` object.

		@since 1.0.0
	**/
	public function new() {
		initializeTextInputTheme();

		super();

		this.tabEnabled = true;
		this.tabChildren = false;
		this.focusRect = null;

		this.addEventListener(FocusEvent.FOCUS_IN, textInput_focusInHandler);
		this.addEventListener(KeyboardEvent.KEY_DOWN, textInput_keyDownHandler);
	}

	private var _editable:Bool = true;

	/**
		Indicates if the text input is editable.

		The following example disables editing:

		```hx
		textInput.editable = false;
		```

		@since 1.0.0
	**/
	@:flash.property
	public var editable(get, set):Bool;

	private function get_editable():Bool {
		return this._editable;
	}

	private function set_editable(value:Bool):Bool {
		if (this._editable == value) {
			return this._editable;
		}
		this._editable = value;
		this.setInvalid(STATE);
		return this._editable;
	}

	private var _currentState:TextInputState = ENABLED;

	/**
		The current state of the text input.

		@see `feathers.controls.TextInputState`
		@see `FeathersEvent.STATE_CHANGE`

		@since 1.0.0
	**/
	@:flash.property
	public var currentState(get, never):#if flash Dynamic #else TextInputState #end;

	private function get_currentState():#if flash Dynamic #else TextInputState #end {
		return this._currentState;
	}

	override private function set_enabled(value:Bool):Bool {
		super.enabled = value;
		if (this._enabled) {
			if (this._currentState == DISABLED) {
				this.changeState(ENABLED);
			}
		} else {
			this.changeState(DISABLED);
		}
		return this._enabled;
	}

	private var _backgroundSkinMeasurements:Measurements = null;
	private var _currentBackgroundSkin:DisplayObject = null;

	/**
		The default background skin for the text input, which is used when no
		other skin is defined for the current state with `setSkinForState()`.

		The following example passes a bitmap for the text input to use as a
		background skin:

		```hx
		input.backgroundSkin = new Bitmap(bitmapData);
		```

		@default null

		@see `TextInput.getSkinForState()`
		@see `TextInput.setSkinForState()`

		@since 1.0.0
	**/
	@:style
	public var backgroundSkin:DisplayObject = null;

	private var _stateToSkin:Map<TextInputState, DisplayObject> = new Map();

	private var textField:TextField;
	private var promptTextField:TextField;

	private var _previousText:String = null;
	private var _previousPrompt:String = null;
	private var _previousTextFormat:TextFormat = null;
	private var _previousPromptTextFormat:TextFormat = null;
	private var _updatedTextStyles = false;
	private var _updatedPromptStyles = false;

	private var _text:String = "";

	/**
		The text displayed by the text input.

		When the value of the `text` property changes, the text input will
		dispatch an event of type `Event.CHANGE`.

		The following example sets the text input's text:

		```hx
		input.text = "Good afternoon!";
		```

		@default ""

		@see `TextInput.textFormat`
		@see `openfl.events.Event.CHANGE`

		@since 1.0.0
	**/
	@:flash.property
	public var text(get, set):String;

	private function get_text():String {
		return this._text;
	}

	private function set_text(value:String):String {
		if (value == null) {
			// null gets converted to an empty string
			if (this._text.length == 0) {
				// already an empty string
				return this._text;
			}
			value = "";
		}
		if (this._text == value) {
			return this._text;
		}
		this._text = value;
		this.setInvalid(DATA);
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._text;
	}

	private var _prompt:String;

	/**
		The text displayed by the text input when the length of the `text`
		property is `0`.

		The following example sets the text input's prompt:

		```hx
		input.prompt = "Minimum 8 characters required";
		```

		@default null

		@see `TextInput.promptTextFormat`

		@since 1.0.0
	**/
	@:flash.property
	public var prompt(get, set):String;

	private function get_prompt():String {
		return this._prompt;
	}

	private function set_prompt(value:String):String {
		if (this._prompt == value) {
			return this._prompt;
		}
		this._prompt = value;
		this.setInvalid(DATA);
		return this._prompt;
	}

	// for some reason, naming this _restrict fails in hxcpp
	private var __restrict:String;

	/**
		Limits the set of characters that may be typed into the `TextInput`.

		In the following example, the text input's allowed characters are
		restricted:

		```hx
		input.restrict = "0-9";
		```

		@default null

		@see [`TextField.restrict`](https://api.openfl.org/openfl/text/TextField.html#restrict)

		@since 1.0.0
	**/
	@:flash.property
	public var restrict(get, set):String;

	private function get_restrict():String {
		return this.__restrict;
	}

	private function set_restrict(value:String):String {
		if (this.__restrict == value) {
			return this.__restrict;
		}
		this.__restrict = value;
		this.setInvalid(DATA);
		return this.__restrict;
	}

	private var _displayAsPassword:Bool = false;

	/**
		Masks the text so that it cannot be read.

		In the following example, the text input's text is displayed as a
		password:

		```hx
		input.displayAsPassword = true;
		```

		@default null

		@see [`TextField.displayAsPassword`](https://api.openfl.org/openfl/text/TextField.html#displayAsPassword)

		@since 1.0.0
	**/
	@:flash.property
	public var displayAsPassword(get, set):Bool;

	private function get_displayAsPassword():Bool {
		return this._displayAsPassword;
	}

	private function set_displayAsPassword(value:Bool):Bool {
		if (this._displayAsPassword == value) {
			return this._displayAsPassword;
		}
		this._displayAsPassword = value;
		this.setInvalid(DATA);
		return this._displayAsPassword;
	}

	/**
		The font styles used to render the text input's text.

		In the following example, the text input's formatting is customized:

		```hx
		input.textFormat = new TextFormat("Helvetica", 20, 0xcc0000);
		```

		@see `TextInput.text`
		@see `TextInput.getTextFormatForState()`
		@see `TextInput.setTextFormatForState()`
		@see `TextInput.embedFonts`

		@since 1.0.0
	**/
	@:style
	public var textFormat:TextFormat = null;

	/**
		The font styles used to render the text input's text when the text input
		is disabled.

		In the following example, the text input's disabled text formatting is
		customized:

		```hx
		input.enabled = false;
		input.disabledTextFormat = new TextFormat("Helvetica", 20, 0xee0000);
		```

		@see `TextInput.textFormat`

		@since 1.0.0
	**/
	@:style
	public var disabledTextFormat:TextFormat = null;

	/**
		The font styles used to render the text input's prompt text.

		In the following example, the text input's prompt formatting is customized:

		```hx
		input.promptTextFormat = new TextFormat("Helvetica", 20, 0xcc0000);
		```

		@see `TextInput.prompt`

		@since 1.0.0
	**/
	@:style
	public var promptTextFormat:TextFormat = null;

	/**
		Determines if an embedded font is used or not.

		In the following example, the text input uses embedded fonts:

		```hx
		input.embedFonts = true;
		```

		@see `TextInput.textFormat`

		@since 1.0.0
	**/
	@:style
	public var embedFonts:Bool = false;

	private var _stateToTextFormat:Map<TextInputState, TextFormat> = new Map();

	/**
		The minimum space, in pixels, between the text input's top edge and the
		text input's content.

		In the following example, the text input's top padding is set to 20
		pixels:

		```hx
		input.paddingTop = 20.0;
		```

		@default 0.0

		@since 1.0.0
	**/
	@:style
	public var paddingTop:Float = 0.0;

	/**
		The minimum space, in pixels, between the text input's right edge and
		the text input's content.

		In the following example, the text input's right padding is set to 20
		pixels:

		```hx
		input.paddingRight = 20.0;
		```

		@default 0.0

		@since 1.0.0
	**/
	@:style
	public var paddingRight:Float = 0.0;

	/**
		The minimum space, in pixels, between the text input's bottom edge and
		the text input's content.

		In the following example, the text input's bottom padding is set to 20
		pixels:

		```hx
		input.paddingBottom = 20.0;
		```

		@default 0.0

		@since 1.0.0
	**/
	@:style
	public var paddingBottom:Float = 0.0;

	/**
		The minimum space, in pixels, between the text input's left edge and the
		text input's content.

		In the following example, the text input's left padding is set to 20
		pixels:

		```hx
		input.paddingLeft = 20.0;
		```

		@default 0.0

		@since 1.0.0
	**/
	@:style
	public var paddingLeft:Float = 0.0;

	/**
		How the content is positioned vertically (along the y-axis) within the
		text input.

		The following example aligns the text input's content to the top:

		```hx
		input.verticalAlign = TOP;
		```

		@see `feathers.layout.VerticalAlign.TOP`
		@see `feathers.layout.VerticalAlign.MIDDLE`
		@see `feathers.layout.VerticalAlign.BOTTOM`
		@see `feathers.layout.VerticalAlign.JUSTIFY`
	**/
	@:style
	public var verticalAlign:VerticalAlign = MIDDLE;

	private var _scrollX:Float = 0.0;

	/**
		The horizontal scroll position (on the x-axis) of the text, measured in
		pixels.

		The following example changes the text input's scroll position:

		```hx
		input.scrollX = 20.0;
		```

		@since 1.0.0
	**/
	@:flash.property
	public var scrollX(get, set):Float;

	private function get_scrollX():Float {
		return this._scrollX;
	}

	private function set_scrollX(value:Float):Float {
		if (this._scrollX == value) {
			return this._scrollX;
		}
		this._scrollX = value;
		this.setInvalid(SCROLL);
		FeathersEvent.dispatch(this, Event.SCROLL);
		return this._scrollX;
	}

	private var _pendingSelectionAnchorIndex:Int = -1;

	/**
		The character position of the anchor part of the selection. If the
		selection is changed with the arrow keys, the active index changes and
		the anchor index stays fixed. If both the active index and the anchor
		index are equal, then no text is selected and both values represent the
		position of the caret.

		@see `TextInput.selectionActiveIndex`
		@see `TextInput.selectRange()`
		@see `TextInput.selectAll()`

		@since 1.0.0
	**/
	@:flash.property
	public var selectionAnchorIndex(get, never):Int;

	private function get_selectionAnchorIndex():Int {
		if (this.textField != null && this._pendingSelectionAnchorIndex == -1) {
			// return the opposite of the caret index
			if (this.textField.caretIndex == this.textField.selectionBeginIndex) {
				return this.textField.selectionEndIndex;
			}
			return this.textField.selectionBeginIndex;
		}
		return this._pendingSelectionAnchorIndex;
	}

	private var _pendingSelectionActiveIndex:Int = -1;

	/**
		The character position of the active part of the selection. If the
		selection is changed with the arrow keys, the active index changes and
		the anchor index stays fixed. If both the active index and the anchor
		index are equal, then no text is selected and both values represent the
		position of the caret.

		@see `TextInput.selectionAnchorIndex`
		@see `TextInput.selectRange()`
		@see `TextInput.selectAll()`

		@since 1.0.0
	**/
	@:flash.property
	public var selectionActiveIndex(get, never):Int;

	private function get_selectionActiveIndex():Int {
		if (this.textField != null && this._pendingSelectionActiveIndex == -1) {
			// always the same as caret index
			return this.textField.caretIndex;
		}
		return this._pendingSelectionActiveIndex;
	}

	/**
		Indicates if the text width is considered when calculating the ideal
		size of the text input.

		The following example changes the text input's auto size behavior:

		```hx
		input.autoSizeWidth = true;
		```

		@since 1.0.0
	**/
	@:style
	public var autoSizeWidth:Bool = false;

	private var _textMeasuredWidth:Float;
	private var _textMeasuredHeight:Float;
	private var _promptTextMeasuredWidth:Float;
	private var _promptTextMeasuredHeight:Float;

	/**
		Gets the skin to be used by the text input when its `currentState`
		property matches the specified state value.

		If a skin is not defined for a specific state, returns `null`.

		@see `TextInput.setSkinForState()`
		@see `TextInput.backgroundSkin`
		@see `TextInput.currentState`
		@see `feathers.controls.TextInputState`

		@since 1.0.0
	**/
	public function getSkinForState(state:TextInputState):DisplayObject {
		return this._stateToSkin.get(state);
	}

	/**
		Set the skin to be used by the text input when its `currentState`
		property matches the specified state value.

		If a skin is not defined for a specific state, the value of the
		`backgroundSkin` property will be used instead.

		@see `TextInput.getSkinForState()`
		@see `TextInput.backgroundSkin`
		@see `TextInput.currentState`
		@see `feathers.controls.TextInputState`

		@since 1.0.0
	**/
	@style
	public function setSkinForState(state:TextInputState, skin:DisplayObject):Void {
		if (!this.setStyle("setSkinForState", state)) {
			return;
		}
		var oldSkin = this._stateToSkin.get(state);
		if (oldSkin != null && oldSkin == this._currentBackgroundSkin) {
			this.removeCurrentBackgroundSkin(oldSkin);
			this._currentBackgroundSkin = null;
		}
		if (skin == null) {
			this._stateToSkin.remove(state);
		} else {
			this._stateToSkin.set(state, skin);
		}
		this.setInvalid(STYLES);
	}

	/**
		Gets the text format to be used by the text input when its `currentState`
		property matches the specified state value.

		If a text format is not defined for a specific state, returns `null`.

		@see `TextInput.setTextFormatForState()`
		@see `TextInput.textFormat`
		@see `TextInput.currentState`
		@see `feathers.controls.TextInputState`

		@since 1.0.0
	**/
	public function getTextFormatForState(state:TextInputState):TextFormat {
		return this._stateToTextFormat.get(state);
	}

	/**
		Set the text format to be used by the text input when its `currentState`
		property matches the specified state value.

		If a text format is not defined for a specific state, the value of the
		`textFormat` property will be used instead.

		@see `TextInput.getTextFormatForState()`
		@see `TextInput.textFormat`
		@see `TextInput.currentState`
		@see `feathers.controls.TextInputState`

		@since 1.0.0
	**/
	@style
	public function setTextFormatForState(state:TextInputState, textFormat:TextFormat):Void {
		if (!this.setStyle("setTextFormatForState", state)) {
			return;
		}
		if (textFormat == null) {
			this._stateToTextFormat.remove(state);
		} else {
			this._stateToTextFormat.set(state, textFormat);
		}
		this.setInvalid(STYLES);
	}

	/**
		Selects the specified range of characters.

		The following example selects the first three characters:

		```hx
		input.selectRange(0, 3);
		```

		@see `TextInput.selectAll()`
		@see `TextInput.selectionAnchorIndex`
		@see `TextInput.selectionActiveIndex`

		@since 1.0.0
	**/
	public function selectRange(anchorIndex:Int, activeIndex:Int):Void {
		// we can't call textField.setSelection() directly here because the
		// TextField may not have been updated yet
		this._pendingSelectionAnchorIndex = anchorIndex;
		this._pendingSelectionActiveIndex = activeIndex;
		this.setInvalid(SELECTION);
	}

	/**
		Selects all of the text displayed by the text input.

		@see `TextInput.selectRange()`
		@see `TextInput.selectionAnchorIndex`
		@see `TextInput.selectionActiveIndex`

		@since 1.0.0
	**/
	public function selectAll():Void {
		this.selectRange(0, this._text.length);
	}

	private function initializeTextInputTheme():Void {
		SteelTextInputStyles.initialize();
	}

	override private function initialize():Void {
		super.initialize();
		if (this.textField == null) {
			this.textField = new TextField();
			this.textField.selectable = true;
			this.textField.tabEnabled = false;
			this.textField.addEventListener(Event.CHANGE, textField_changeHandler);
			this.textField.addEventListener(Event.SCROLL, textField_scrollHandler);
			this.textField.addEventListener(FocusEvent.FOCUS_IN, textField_focusInHandler);
			this.textField.addEventListener(FocusEvent.FOCUS_OUT, textField_focusOutHandler);
			this.addChild(this.textField);
		}
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(DATA);
		var scrollInvalid = this.isInvalid(SCROLL);
		var selectionInvalid = this.isInvalid(SELECTION);
		var stateInvalid = this.isInvalid(STATE);
		var stylesInvalid = this.isInvalid(STYLES);

		this._updatedTextStyles = false;
		this._updatedPromptStyles = false;

		if (stylesInvalid || stateInvalid) {
			this.refreshBackgroundSkin();
		}

		if (dataInvalid) {
			this.refreshPrompt();
		}

		if (stylesInvalid || stateInvalid) {
			this.refreshTextStyles();
			this.refreshPromptStyles();
		}

		if (dataInvalid || stylesInvalid || stateInvalid) {
			this.refreshText();
		}

		if (dataInvalid || stylesInvalid) {
			this.refreshPromptText();
		}

		if (selectionInvalid) {
			this.refreshSelection();
		}

		if (scrollInvalid) {
			this.refreshScrollPosition();
		}

		this.measure();
		this.layoutContent();
	}

	private function refreshBackgroundSkin():Void {
		var oldSkin = this._currentBackgroundSkin;
		this._currentBackgroundSkin = this.getCurrentBackgroundSkin();
		if (this._currentBackgroundSkin == oldSkin) {
			return;
		}
		this.removeCurrentBackgroundSkin(oldSkin);
		if (this._currentBackgroundSkin == null) {
			this._backgroundSkinMeasurements = null;
			return;
		}
		if (Std.is(this._currentBackgroundSkin, IUIControl)) {
			cast(this._currentBackgroundSkin, IUIControl).initializeNow();
		}
		if (this._backgroundSkinMeasurements == null) {
			this._backgroundSkinMeasurements = new Measurements(this._currentBackgroundSkin);
		} else {
			this._backgroundSkinMeasurements.save(this._currentBackgroundSkin);
		}
		if (Std.is(this._currentBackgroundSkin, IProgrammaticSkin)) {
			cast(this._currentBackgroundSkin, IProgrammaticSkin).uiContext = this;
		}
		this.addChildAt(this._currentBackgroundSkin, 0);
	}

	private function getCurrentBackgroundSkin():DisplayObject {
		var result = this._stateToSkin.get(this._currentState);
		if (result != null) {
			return result;
		}
		return this.backgroundSkin;
	}

	private function removeCurrentBackgroundSkin(skin:DisplayObject):Void {
		if (skin == null) {
			return;
		}
		if (Std.is(skin, IProgrammaticSkin)) {
			cast(skin, IProgrammaticSkin).uiContext = null;
		}
		this._backgroundSkinMeasurements.restore(skin);
		if (skin.parent == this) {
			// we need to restore these values so that they won't be lost the
			// next time that this skin is used for measurement
			this.removeChild(skin);
		}
	}

	private function measure():Bool {
		var needsWidth = this.explicitWidth == null;
		var needsHeight = this.explicitHeight == null;
		var needsMinWidth = this.explicitMinWidth == null;
		var needsMinHeight = this.explicitMinHeight == null;
		var needsMaxWidth = this.explicitMaxWidth == null;
		var needsMaxHeight = this.explicitMaxHeight == null;
		if (!needsWidth && !needsHeight && !needsMinWidth && !needsMinHeight && !needsMaxWidth && !needsMaxHeight) {
			return false;
		}

		if (this._backgroundSkinMeasurements != null) {
			MeasurementsUtil.resetFluidlyWithParent(this._backgroundSkinMeasurements, this._currentBackgroundSkin, this);
		}

		var measureSkin:IMeasureObject = null;
		if (Std.is(this._currentBackgroundSkin, IMeasureObject)) {
			measureSkin = cast(this._currentBackgroundSkin, IMeasureObject);
		}

		if (Std.is(this._currentBackgroundSkin, IValidating)) {
			cast(this._currentBackgroundSkin, IValidating).validateNow();
		}

		var newWidth = this.explicitWidth;
		if (needsWidth) {
			if (this.autoSizeWidth) {
				newWidth = this._textMeasuredWidth;
			} else {
				newWidth = 0.0;
			}
			newWidth += this.paddingLeft + this.paddingRight;
			if (this._currentBackgroundSkin != null) {
				newWidth = Math.max(this._currentBackgroundSkin.width, newWidth);
			}
		}

		var newHeight = this.explicitHeight;
		if (needsHeight) {
			newHeight = this._textMeasuredHeight + this.paddingTop + this.paddingBottom;
			if (this._currentBackgroundSkin != null) {
				newHeight = Math.max(this._currentBackgroundSkin.height, newHeight);
			}
		}

		var newMinWidth = this.explicitMinWidth;
		if (needsMinWidth) {
			if (this.autoSizeWidth) {
				newMinWidth = this._textMeasuredWidth;
			} else {
				newMinWidth = 0.0;
			}
			newMinWidth += this.paddingLeft + this.paddingRight;
			if (measureSkin != null) {
				newMinWidth = Math.max(measureSkin.minWidth, newMinWidth);
			} else if (this._backgroundSkinMeasurements != null) {
				newMinWidth = Math.max(this._backgroundSkinMeasurements.minWidth, newMinWidth);
			}
		}

		var newMinHeight = this.explicitMinHeight;
		if (needsMinHeight) {
			newMinHeight = this._textMeasuredHeight + this.paddingTop + this.paddingBottom;
			if (measureSkin != null) {
				newMinHeight = Math.max(measureSkin.minHeight, newMinHeight);
			} else if (this._backgroundSkinMeasurements != null) {
				newMinHeight = Math.max(this._backgroundSkinMeasurements.minHeight, newMinHeight);
			}
		}
		var newMaxWidth = this.explicitMaxWidth;
		if (needsMaxWidth) {
			if (measureSkin != null) {
				newMaxWidth = measureSkin.maxWidth;
			} else if (this._backgroundSkinMeasurements != null) {
				newMaxWidth = this._backgroundSkinMeasurements.maxWidth;
			} else {
				newMaxWidth = Math.POSITIVE_INFINITY;
			}
		}

		var newMaxHeight = this.explicitMaxHeight;
		if (needsMaxHeight) {
			if (measureSkin != null) {
				newMaxHeight = measureSkin.maxHeight;
			} else if (this._backgroundSkinMeasurements != null) {
				newMaxHeight = this._backgroundSkinMeasurements.maxHeight;
			} else {
				newMaxHeight = Math.POSITIVE_INFINITY;
			}
		}

		return this.saveMeasurements(newWidth, newHeight, newMinWidth, newMinHeight, newMaxWidth, newMaxHeight);
	}

	private function refreshTextStyles():Void {
		if (this._enabled && this._editable && this.textField.type != TextFieldType.INPUT) {
			this.textField.type = TextFieldType.INPUT;
		} else if ((!this._enabled || !this._editable) && this.textField.type == TextFieldType.INPUT) {
			this.textField.type = TextFieldType.DYNAMIC;
		}
		if (this.textField.embedFonts != this.embedFonts) {
			this.textField.embedFonts = this.embedFonts;
			this._updatedTextStyles = true;
		}
		if (this.textField.displayAsPassword != this._displayAsPassword) {
			this.textField.displayAsPassword = this._displayAsPassword;
			this._updatedTextStyles = true;
		}
		var textFormat = this.getCurrentTextFormat();
		if (textFormat == this._previousTextFormat) {
			// nothing to refresh
			return;
		}
		if (textFormat != null) {
			this.textField.defaultTextFormat = textFormat;
			this._updatedTextStyles = true;
			this._previousTextFormat = textFormat;
		}
	}

	private function refreshPrompt():Void {
		if (this._prompt == null) {
			if (this.promptTextField != null) {
				this.removeChild(this.promptTextField);
				this.promptTextField = null;
			}
			return;
		}
		if (this.promptTextField == null) {
			this.promptTextField = new TextField();
			this.promptTextField.selectable = false;
			this.addChild(this.promptTextField);
		}
		this.promptTextField.visible = this._text.length == 0;
	}

	private function refreshPromptText():Void {
		if (this._prompt == null || this._prompt == this._previousPrompt && !this._updatedPromptStyles) {
			// nothing to refresh
			return;
		}
		// set autoSize before text because setting text first can trigger an
		// extra text engine reflow
		this.promptTextField.autoSize = TextFieldAutoSize.LEFT;
		var hasText = this._prompt.length > 0;
		if (hasText) {
			this.promptTextField.text = this._prompt;
		} else {
			this.promptTextField.text = "\u8203"; // zero-width space
		}
		this._promptTextMeasuredWidth = this.promptTextField.width;
		this._promptTextMeasuredHeight = this.promptTextField.height;
		this.promptTextField.autoSize = TextFieldAutoSize.NONE;
		if (!hasText) {
			this.promptTextField.text = "";
		}
		this._previousPrompt = this._prompt;
	}

	private function refreshPromptStyles():Void {
		if (this._prompt == null) {
			return;
		}
		if (this.promptTextField.embedFonts != this.embedFonts) {
			this.promptTextField.embedFonts = this.embedFonts;
			this._updatedPromptStyles = true;
		}
		var textFormat = this.promptTextFormat;
		if (textFormat == null) {
			textFormat = this.textFormat;
		}
		if (textFormat == this._previousPromptTextFormat) {
			// nothing to refresh
			return;
		}
		if (textFormat != null) {
			this.promptTextField.defaultTextFormat = textFormat;
			this._updatedPromptStyles = true;
			this._previousPromptTextFormat = textFormat;
		}
	}

	private function refreshText():Void {
		this.textField.restrict = this.__restrict;
		if (this._text == this._previousText && !this._updatedTextStyles) {
			// nothing to refresh
			return;
		}
		// set autoSize before text because setting text first can trigger an
		// extra text engine reflow
		this.textField.autoSize = TextFieldAutoSize.LEFT;
		var hasText = this._text != null && this._text.length > 0;
		if (hasText) {
			this.textField.text = this._text;
		} else {
			this.textField.text = "\u8203"; // zero-width space
		}
		this._textMeasuredWidth = this.textField.width;
		this._textMeasuredHeight = this.textField.height;
		this.textField.autoSize = TextFieldAutoSize.NONE;
		if (!hasText) {
			this.textField.text = "";
		}
		this._previousText = this._text;
	}

	private function refreshSelection():Void {
		if (this._pendingSelectionActiveIndex == -1 && this._pendingSelectionAnchorIndex == -1) {
			return;
		}
		var anchorIndex = this._pendingSelectionAnchorIndex;
		var activeIndex = this._pendingSelectionActiveIndex;
		this._pendingSelectionAnchorIndex = -1;
		this._pendingSelectionActiveIndex = -1;
		this.textField.setSelection(anchorIndex, activeIndex);
	}

	private function refreshScrollPosition():Void {
		this.textField.scrollH = Math.round(this._scrollX);
	}

	private function getCurrentTextFormat():TextFormat {
		var result = this._stateToTextFormat.get(this._currentState);
		if (result != null) {
			return result;
		}
		if (!this._enabled && this.disabledTextFormat != null) {
			return this.disabledTextFormat;
		}
		return this.textFormat;
	}

	private function layoutContent():Void {
		this.layoutBackgroundSkin();

		var textFieldWidth = this.actualWidth - this.paddingLeft - this.paddingRight;
		this.textField.width = textFieldWidth;

		var textFieldHeight = this._textMeasuredHeight;
		var maxHeight = this.actualHeight - this.paddingTop - this.paddingBottom;
		if (textFieldHeight > maxHeight || this.verticalAlign == JUSTIFY) {
			textFieldHeight = maxHeight;
		}
		this.textField.height = textFieldHeight;

		this.textField.x = this.paddingLeft;
		this.alignTextField(this.textField, textFieldHeight, maxHeight);

		if (this.promptTextField != null) {
			this.promptTextField.width = textFieldWidth;

			var textFieldHeight = this._promptTextMeasuredHeight;
			if (textFieldHeight > maxHeight || this.verticalAlign == JUSTIFY) {
				textFieldHeight = maxHeight;
			}
			this.promptTextField.height = textFieldHeight;

			this.promptTextField.x = this.paddingLeft;
			this.alignTextField(this.promptTextField, textFieldHeight, maxHeight);
		}
	}

	private inline function alignTextField(textField:TextField, textFieldHeight:Float, maxHeight:Float):Void {
		// performance: use the textFieldHeight variable instead of calling the
		// TextField height getter, which can trigger a text engine reflow
		switch (this.verticalAlign) {
			case TOP:
				textField.y = this.paddingTop;
			case BOTTOM:
				textField.y = this.actualHeight - this.paddingBottom - textFieldHeight;
			case JUSTIFY:
				textField.y = this.paddingTop;
			default: // middle or null
				textField.y = this.paddingTop + (maxHeight - textFieldHeight) / 2.0;
		}
	}

	private function layoutBackgroundSkin():Void {
		if (this._currentBackgroundSkin == null) {
			return;
		}
		this._currentBackgroundSkin.x = 0.0;
		this._currentBackgroundSkin.y = 0.0;

		// don't set the width or height explicitly unless necessary because if
		// our explicit dimensions are cleared later, the measurement may not be
		// accurate anymore
		if (this._currentBackgroundSkin.width != this.actualWidth) {
			this._currentBackgroundSkin.width = this.actualWidth;
		}
		if (this._currentBackgroundSkin.height != this.actualHeight) {
			this._currentBackgroundSkin.height = this.actualHeight;
		}
		if (Std.is(this._currentBackgroundSkin, IValidating)) {
			cast(this._currentBackgroundSkin, IValidating).validateNow();
		}
	}

	private function changeState(state:TextInputState):Void {
		if (!this._enabled) {
			state = DISABLED;
		}
		if (this._currentState == state) {
			return;
		}
		this._currentState = state;
		this.setInvalid(STATE);
		FeathersEvent.dispatch(this, FeathersEvent.STATE_CHANGE);
	}

	private function textField_changeHandler(event:Event):Void {
		// don't let this event bubble. Feathers UI components don't bubble their
		// events — especially not Event.CHANGE!
		event.stopPropagation();

		var oldText = this._text;

		// no need to invalidate here. just store the new text.
		this._text = this.textField.text;
		// ...UNLESS the prompt needs to be shown or hidden as a result of the
		// changed text
		var hasText = this._text != null && this._text.length > 0;
		var hasOldText = oldText != null && oldText.length > 0;
		var hasPrompt = this._prompt != null && this._prompt.length > 0;
		if (this.autoSizeWidth || (hasPrompt && ((!hasText && hasOldText) || (hasText && !hasOldText)))) {
			this.setInvalid(DATA);
		}
		// either way, the event still needs to be dispatched
		FeathersEvent.dispatch(this, Event.CHANGE);
	}

	private function textField_scrollHandler(event:Event):Void {
		// no need to invalidate here. just store the new scroll position.
		this._scrollX = this.textField.scrollH;
		// but the event still needs to be dispatched
		FeathersEvent.dispatch(this, Event.SCROLL);
	}

	private function textInput_focusInHandler(event:FocusEvent):Void {
		if (Reflect.compare(event.target, this) == 0) {
			this.stage.focus = this.textField;
		}
	}

	private function textInput_keyDownHandler(event:KeyboardEvent):Void {
		if (!this._enabled || event.isDefaultPrevented()) {
			return;
		}
		switch (event.keyCode) {
			case Keyboard.UP:
			case Keyboard.DOWN:
			case Keyboard.LEFT:
			case Keyboard.RIGHT:
			case Keyboard.PAGE_UP:
			case Keyboard.PAGE_DOWN:
			case Keyboard.HOME:
			case Keyboard.END:
			default:
				return;
		}
		event.stopPropagation();
	}

	private function textField_focusInHandler(event:FocusEvent):Void {
		this.changeState(FOCUSED);
	}

	private function textField_focusOutHandler(event:FocusEvent):Void {
		this.changeState(ENABLED);
	}
}
