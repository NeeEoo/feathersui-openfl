/*
	Feathers UI
	Copyright 2021 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.layout;

import feathers.core.IMeasureObject;
import feathers.core.IValidating;
import feathers.events.FeathersEvent;
import feathers.layout.IVirtualLayout.VirtualLayoutRange;
import openfl.display.DisplayObject;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.geom.Point;

/**
	A simple list layout that positions items from left to right, in a single
	row, where every item fills the entire height of the container.

	@event openfl.events.Event.CHANGE

	@since 1.0.0
**/
@:event(openfl.events.Event.CHANGE)
class HorizontalListLayout extends EventDispatcher implements IVirtualLayout {
	/**
		Creates a new `HorizontalListLayout` object.

		@since 1.0.0
	**/
	public function new() {
		super();
	}

	private var _scrollX:Float = 0.0;

	/**
		@see `feathers.layout.IScrollLayout.scrollX`
	**/
	@:flash.property
	public var scrollX(get, set):Float;

	private function get_scrollX():Float {
		return this._scrollX;
	}

	private function set_scrollX(value:Float):Float {
		this._scrollX = value;
		return this._scrollX;
	}

	private var _scrollY:Float = 0.0;

	/**
		@see `feathers.layout.IScrollLayout.scrollY`
	**/
	@:flash.property
	public var scrollY(get, set):Float;

	private function get_scrollY():Float {
		return this._scrollY;
	}

	private function set_scrollY(value:Float):Float {
		this._scrollY = value;
		return this._scrollY;
	}

	private var _virtualCache:Array<Dynamic>;

	/**
		@see `feathers.layout.IVirtualLayout.virtualCache`
	**/
	@:flash.property
	public var virtualCache(get, set):Array<Dynamic>;

	private function get_virtualCache():Array<Dynamic> {
		return this._virtualCache;
	}

	private function set_virtualCache(value:Array<Dynamic>):Array<Dynamic> {
		this._virtualCache = value;
		return this._virtualCache;
	}

	/**
		@see `feathers.layout.IScrollLayout.elasticTop`
	**/
	@:flash.property
	public var elasticTop(get, never):Bool;

	private function get_elasticTop():Bool {
		return false;
	}

	/**
		@see `feathers.layout.IScrollLayout.elasticRight`
	**/
	@:flash.property
	public var elasticRight(get, never):Bool;

	private function get_elasticRight():Bool {
		return true;
	}

	/**
		@see `feathers.layout.IScrollLayout.elasticBottom`
	**/
	@:flash.property
	public var elasticBottom(get, never):Bool;

	private function get_elasticBottom():Bool {
		return false;
	}

	/**
		@see `feathers.layout.IScrollLayout.elasticLeft`
	**/
	@:flash.property
	public var elasticLeft(get, never):Bool;

	private function get_elasticLeft():Bool {
		return true;
	}

	/**
		@see `feathers.layout.IScrollLayout.requiresLayoutOnScroll`
	**/
	@:flash.property
	public var requiresLayoutOnScroll(get, never):Bool;

	private function get_requiresLayoutOnScroll():Bool {
		return true;
	}

	private var _requestedColumnCount:Null<Float> = null;

	/**
		The exact number of columns to render, if the width of the container has
		not been set explicitly. If `null`, falls back to
		`requestedMinColumnCount` and `requestedMaxColumnCount`.

		In the following example, the layout's requested column count is set to
		2 complete items:

		```hx
		layout.requestedColumnCount = 2.0;
		```

		@default 5.0

		@since 1.0.0
	**/
	@:flash.property
	public var requestedColumnCount(get, set):Null<Float>;

	private function get_requestedColumnCount():Null<Float> {
		return this._requestedColumnCount;
	}

	private function set_requestedColumnCount(value:Null<Float>):Null<Float> {
		if (this._requestedColumnCount == value) {
			return this._requestedColumnCount;
		}
		this._requestedColumnCount = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._requestedColumnCount;
	}

	private var _requestedMinColumnCount:Null<Float> = null;

	/**
		The minimum number of columns to render, if the width of the container
		has not been set explicitly. If `null`, this property is ignored.

		If `requestedColumnCount` is also set, this property is ignored.

		In the following example, the layout's requested minimum coumn count is
		set to 2 complete items:

		```hx
		layout.requestedMinColumnCount = 2.0;
		```

		@default null

		@since 1.0.0
	**/
	@:flash.property
	public var requestedMinColumnCount(get, set):Null<Float>;

	private function get_requestedMinColumnCount():Null<Float> {
		return this._requestedMinColumnCount;
	}

	private function set_requestedMinColumnCount(value:Null<Float>):Null<Float> {
		if (this._requestedMinColumnCount == value) {
			return this._requestedMinColumnCount;
		}
		this._requestedMinColumnCount = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._requestedMinColumnCount;
	}

	private var _requestedMaxColumnCount:Null<Float> = null;

	/**
		The maximum number of columns to render, if the width of the container
		has not been set explicitly. If `null`, the maximum number of columns is
		the total number of items displayed by the layout.

		If `requestedColumnCount` is also set, this property is ignored.

		In the following example, the layout's requested maximum column count is
		set to 5 complete items:

		```hx
		layout.requestedMaxColumnCount = 5.0;
		```

		@default null

		@since 1.0.0
	**/
	@:flash.property
	public var requestedMaxColumnCount(get, set):Null<Float>;

	private function get_requestedMaxColumnCount():Null<Float> {
		return this._requestedMaxColumnCount;
	}

	private function set_requestedMaxColumnCount(value:Null<Float>):Null<Float> {
		if (this._requestedMaxColumnCount == value) {
			return this._requestedMaxColumnCount;
		}
		this._requestedMaxColumnCount = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._requestedMaxColumnCount;
	}

	private var _paddingTop:Float = 0.0;

	/**
		The space, in pixels, between the parent container's top edge and its
		content.

		In the following example, the layout's top padding is set to 20 pixels:

		```hx
		layout.paddingTop = 20.0;
		```

		@default 0.0

		@since 1.0.0
	**/
	@:flash.property
	public var paddingTop(get, set):Float;

	private function get_paddingTop():Float {
		return this._paddingTop;
	}

	private function set_paddingTop(value:Float):Float {
		if (this._paddingTop == value) {
			return this._paddingTop;
		}
		this._paddingTop = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._paddingTop;
	}

	private var _paddingRight:Float = 0.0;

	/**
		The space, in pixels, between the parent container's right edge and its
		content.

		In the following example, the layout's right padding is set to 20 pixels:

		```hx
		layout.paddingRight = 20.0;
		```

		@default 0.0

		@since 1.0.0
	**/
	@:flash.property
	public var paddingRight(get, set):Float;

	private function get_paddingRight():Float {
		return this._paddingRight;
	}

	private function set_paddingRight(value:Float):Float {
		if (this._paddingRight == value) {
			return this._paddingRight;
		}
		this._paddingRight = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._paddingRight;
	}

	private var _paddingBottom:Float = 0.0;

	/**
		The space, in pixels, between the parent container's bottom edge and its
		content.

		In the following example, the layout's bottom padding is set to 20 pixels:

		```hx
		layout.paddingBottom = 20.0;
		```

		@default 0.0

		@since 1.0.0
	**/
	@:flash.property
	public var paddingBottom(get, set):Float;

	private function get_paddingBottom():Float {
		return this._paddingBottom;
	}

	private function set_paddingBottom(value:Float):Float {
		if (this._paddingBottom == value) {
			return this._paddingBottom;
		}
		this._paddingBottom = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._paddingBottom;
	}

	private var _paddingLeft:Float = 0.0;

	/**
		The space, in pixels, between the parent container's left edge and its
		content.

		In the following example, the layout's left padding is set to 20 pixels:

		```hx
		layout.paddingLeft = 20.0;
		```

		@default 0.0

		@since 1.0.0
	**/
	@:flash.property
	public var paddingLeft(get, set):Float;

	private function get_paddingLeft():Float {
		return this._paddingLeft;
	}

	private function set_paddingLeft(value:Float):Float {
		if (this._paddingLeft == value) {
			return this._paddingLeft;
		}
		this._paddingLeft = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._paddingLeft;
	}

	private var _gap:Float = 0.0;

	/**
		The space, in pixels, between each two adjacent items in the layout.

		In the following example, the layout's gap is set to 20 pixels:

		```hx
		layout.gap = 20.0;
		```

		@default 0.0

		@since 1.0.0
	**/
	@:flash.property
	public var gap(get, set):Float;

	private function get_gap():Float {
		return this._gap;
	}

	private function set_gap(value:Float):Float {
		if (this._gap == value) {
			return this._gap;
		}
		this._gap = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._gap;
	}

	private var _horizontalAlign:HorizontalAlign = LEFT;

	/**
		How the content is positioned horizontally (along the x-axis) within the
		container. If the total width of the content is larger than the
		available width within the container, then the positioning of the items
		will always start from the left.

		**Note:** The `HorizontalAlign.JUSTIFY` constant is not supported by this
		layout.

		The following example aligns the container's content to the right:

		```hx
		layout.horizontalAlign = RIGHT;
		```

		@default feathers.layout.HorizontalAlign.LEFT

		@see `feathers.layout.HorizontalAlign.LEFT`
		@see `feathers.layout.HorizontalAlign.CENTER`
		@see `feathers.layout.HorizontalAlign.RIGHT`

		@since 1.0.0
	**/
	@:flash.property
	public var horizontalAlign(get, set):HorizontalAlign;

	private function get_horizontalAlign():HorizontalAlign {
		return this._horizontalAlign;
	}

	private function set_horizontalAlign(value:HorizontalAlign):HorizontalAlign {
		if (this._horizontalAlign == value) {
			return this._horizontalAlign;
		}
		this._horizontalAlign = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._horizontalAlign;
	}

	private var _contentJustify:Bool = false;

	/**
		When `contentJustify` is `true`, the height of the items is set to
		either the explicit height of the container, or the maximum height of
		all items, whichever is larger. When `false`, the height of the items
		is set to the explicit height of the container, even if the items are
		measured to be larger.

		@since 1.0.0
	**/
	@:flash.property
	public var contentJustify(get, set):Bool;

	private function get_contentJustify():Bool {
		return this._contentJustify;
	}

	private function set_contentJustify(value:Bool):Bool {
		if (this._contentJustify == value) {
			return this._contentJustify;
		}
		this._contentJustify = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._contentJustify;
	}

	private var _heightResetEnabled:Bool = true;

	/**
		Indicates if the height of items should be reset if the explicit height
		of the parent container is not set.

		@since 1.0.0
	**/
	@:flash.property
	public var heightResetEnabled(get, set):Bool;

	private function get_heightResetEnabled():Bool {
		return this._heightResetEnabled;
	}

	private function set_heightResetEnabled(value:Bool):Bool {
		if (this._heightResetEnabled == value) {
			return this._heightResetEnabled;
		}
		this._heightResetEnabled = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._heightResetEnabled;
	}

	/**
		Sets all four padding properties to the same value.

		@see `HorizontalListLayout.paddingTop`
		@see `HorizontalListLayout.paddingRight`
		@see `HorizontalListLayout.paddingBottom`
		@see `HorizontalListLayout.paddingLeft`

		@since 1.0.0
	**/
	public function setPadding(value:Float):Void {
		this.paddingTop = value;
		this.paddingRight = value;
		this.paddingBottom = value;
		this.paddingLeft = value;
	}

	/**
		@see `feathers.layout.ILayout.layout()`
	**/
	public function layout(items:Array<DisplayObject>, measurements:Measurements, ?result:LayoutBoundsResult):LayoutBoundsResult {
		var maxItemHeight = this.calculateMaxItemHeight(items, measurements);
		var viewPortHeight = this.calculateViewPortHeight(maxItemHeight, measurements);
		var minItemHeight = viewPortHeight - this._paddingTop - this._paddingBottom;
		var itemHeight = maxItemHeight;
		if (!this._contentJustify || itemHeight < minItemHeight) {
			itemHeight = minItemHeight;
		}
		var virtualColumnWidth = this.calculateVirtualColumnWidth(items, itemHeight);
		var positionX = this._paddingLeft;
		for (i in 0...items.length) {
			var item = items[i];
			if (item == null) {
				var itemWidth = virtualColumnWidth;
				if (this._virtualCache != null) {
					var cacheItem = Std.downcast(this._virtualCache[i], VirtualCacheItem);
					if (cacheItem != null) {
						itemWidth = cacheItem.itemWidth;
					}
				}
				positionX += itemWidth + this._gap;
				continue;
			}
			if ((item is ILayoutObject)) {
				if (!cast(item, ILayoutObject).includeInLayout) {
					continue;
				}
			}
			item.x = positionX;
			item.y = this._paddingTop;
			item.height = itemHeight;
			if ((item is IValidating)) {
				cast(item, IValidating).validateNow();
			}
			var itemWidth = item.width;
			if (this._virtualCache != null) {
				var cacheItem = Std.downcast(this._virtualCache[i], VirtualCacheItem);
				if (cacheItem != null && cacheItem.itemWidth != itemWidth) {
					cacheItem.itemWidth = itemWidth;
					this._virtualCache[i] = cacheItem;
					FeathersEvent.dispatch(this, Event.CHANGE);
				}
			}
			positionX += itemWidth + this._gap;
		}
		if (items.length > 0) {
			positionX -= this._gap;
		}
		positionX += this._paddingRight;

		var viewPortWidth = positionX;
		if (measurements.height != null) {
			viewPortWidth = measurements.width;
		} else {
			if (this._requestedColumnCount != null) {
				viewPortWidth = virtualColumnWidth * this._requestedColumnCount;
			} else {
				if (this._requestedMinColumnCount != null && items.length < this._requestedMinColumnCount) {
					viewPortWidth = virtualColumnWidth * this._requestedMinColumnCount;
				} else if (this._requestedMaxColumnCount != null && items.length > this._requestedMaxColumnCount) {
					viewPortWidth = virtualColumnWidth * this._requestedMaxColumnCount;
				}
			}
			if (measurements.minWidth != null && viewPortWidth < measurements.minWidth) {
				viewPortWidth = measurements.minWidth;
			} else if (measurements.maxWidth != null && viewPortWidth > measurements.maxWidth) {
				viewPortWidth = measurements.maxWidth;
			}
		}

		this.applyHorizontalAlign(items, positionX - this._paddingLeft - this._paddingRight, viewPortWidth);

		if (result == null) {
			result = new LayoutBoundsResult();
		}
		result.contentWidth = positionX;
		result.contentHeight = itemHeight + this._paddingTop + this._paddingBottom;
		result.viewPortHeight = viewPortHeight;
		result.viewPortWidth = viewPortWidth;
		return result;
	}

	private function calculateMaxItemHeight(items:Array<DisplayObject>, measurements:Measurements):Float {
		var maxItemHeight = 0.0;
		for (i in 0...items.length) {
			var item = items[i];
			if (this._virtualCache != null && this._virtualCache.length > i) {
				var cacheItem = Std.downcast(this._virtualCache[i], VirtualCacheItem);
				if (cacheItem != null) {
					// prefer the cached height because that's the original
					// measured height and not the justified height
					var itemHeight = cacheItem.itemHeight;
					if (maxItemHeight < itemHeight) {
						maxItemHeight = itemHeight;
					}
					continue;
				}
			}
			if (item == null) {
				continue;
			}
			if ((item is ILayoutObject)) {
				if (!cast(item, ILayoutObject).includeInLayout) {
					continue;
				}
			}
			if (this._heightResetEnabled && measurements.height == null && (item is IMeasureObject)) {
				cast(item, IMeasureObject).resetHeight();
			}
			if ((item is IValidating)) {
				cast(item, IValidating).validateNow();
			}
			var itemHeight = item.height;
			if (maxItemHeight < itemHeight) {
				maxItemHeight = itemHeight;
			}
			if (this._virtualCache != null) {
				var cacheItem = Std.downcast(this._virtualCache[i], VirtualCacheItem);
				if (cacheItem == null) {
					if ((item is IValidating)) {
						cast(item, IValidating).validateNow();
					}
					// save the original measured height in the cache to be used
					// again in future calculations
					cacheItem = new VirtualCacheItem(0.0, itemHeight);
					this._virtualCache[i] = cacheItem;
				}
			}
		}
		if (measurements.maxHeight != null) {
			var maxJustifyHeight = measurements.maxHeight - this._paddingTop - this._paddingBottom;
			if (maxItemHeight > maxJustifyHeight) {
				maxItemHeight = maxJustifyHeight;
			}
		}
		return maxItemHeight;
	}

	private function calculateViewPortHeight(maxItemHeight:Float, measurements:Measurements):Float {
		if (measurements.height != null) {
			return measurements.height;
		}
		return maxItemHeight + this._paddingTop + this._paddingBottom;
	}

	private function calculateVirtualColumnWidth(items:Array<DisplayObject>, itemHeight:Float):Float {
		for (i in 0...items.length) {
			var item = items[i];
			if (item == null) {
				if (this._virtualCache == null || this._virtualCache.length <= i) {
					continue;
				}
				var cacheItem = Std.downcast(this._virtualCache[i], VirtualCacheItem);
				if (cacheItem == null) {
					continue;
				}
				// use the last known column width, if available
				return cacheItem.itemWidth;
			}
			if ((item is ILayoutObject)) {
				if (!cast(item, ILayoutObject).includeInLayout) {
					continue;
				}
			}
			item.height = itemHeight;
			if ((item is IValidating)) {
				cast(item, IValidating).validateNow();
			}
			return item.width;
		}
		return 0.0;
	}

	/**
		@see `feathers.layout.IVirtualLayout.getVisibleIndices()`
	**/
	public function getVisibleIndices(itemCount:Int, width:Float, height:Float, ?result:VirtualLayoutRange):VirtualLayoutRange {
		var startIndex = -1;
		var endIndex = -1;
		var estimatedItemWidth:Null<Float> = null;
		var positionX = this._paddingLeft;
		var scrollX = this._scrollX;
		if (scrollX < 0.0) {
			scrollX = 0.0;
		}
		var minItems = 0;
		var maxX = scrollX + width;
		for (i in 0...itemCount) {
			var itemWidth = 0.0;
			if (this._virtualCache != null) {
				var cacheItem = Std.downcast(this._virtualCache[i], VirtualCacheItem);
				if (cacheItem != null) {
					itemWidth = cacheItem.itemWidth;
					if (estimatedItemWidth == null) {
						estimatedItemWidth = itemWidth;
						minItems = Math.ceil(width / (estimatedItemWidth) + this._gap) + 1;
					}
				} else if (estimatedItemWidth != null) {
					itemWidth = estimatedItemWidth;
				}
			}
			positionX += itemWidth + this._gap;
			if (startIndex == -1 && positionX >= scrollX) {
				startIndex = i;
			}
			if (startIndex != -1) {
				endIndex = i;
				if (positionX >= maxX && (endIndex - startIndex + 1) >= minItems) {
					break;
				}
			}
		}
		if (startIndex == -1 && this._horizontalAlign != LEFT) {
			// if we're not aligned to the top, scrolling beyond the end might
			// make some items disappear prematurely, so back-fill from here
			startIndex = itemCount - 1;
			endIndex = startIndex;
		}
		// if we reached the end with extra space, try back-filling so that the
		// number of visible items remains mostly stable
		if ((positionX < maxX || (endIndex - startIndex + 1) < minItems) && startIndex > 0) {
			do {
				startIndex--;
				var itemWidth = 0.0;
				if (this._virtualCache != null) {
					var cacheItem = Std.downcast(this._virtualCache[startIndex], VirtualCacheItem);
					if (cacheItem != null) {
						itemWidth = cacheItem.itemWidth;
						if (estimatedItemWidth == null) {
							estimatedItemWidth = itemWidth;
							minItems = Math.ceil(width / (estimatedItemWidth) + this._gap) + 1;
						}
					} else if (estimatedItemWidth != null) {
						itemWidth = estimatedItemWidth;
					}
				}
				positionX += itemWidth + this._gap;
				if (positionX >= maxX && (endIndex - startIndex + 1) >= minItems) {
					break;
				}
			} while (startIndex > 0);
		}
		if (startIndex < 0) {
			startIndex = 0;
		}
		if (estimatedItemWidth == null) {
			// if we don't have a good width yet, just return one index for
			// performance reasons. this will force one item to be measured, and
			// then we'll have an estimate.
			// the alternative is making every single item visible, which is
			// terrible for performance.
			endIndex = startIndex;
		} else if (endIndex < 0) {
			endIndex = startIndex;
		}
		if (result == null) {
			return new VirtualLayoutRange(startIndex, endIndex);
		}
		result.start = startIndex;
		result.end = endIndex;
		return result;
	}

	/**
		@see `feathers.layout.IScrollLayout.getNearestScrollPositionForIndex()`
	**/
	public function getNearestScrollPositionForIndex(index:Int, itemCount:Int, width:Float, height:Float, ?result:Point):Point {
		var estimatedItemWidth:Null<Float> = null;
		var minX = 0.0;
		var maxX = 0.0;
		var positionX = this._paddingLeft;
		for (i in 0...itemCount) {
			var itemWidth = 0.0;
			if (this._virtualCache != null) {
				var cacheItem = Std.downcast(this._virtualCache[i], VirtualCacheItem);
				if (cacheItem != null) {
					itemWidth = cacheItem.itemWidth;
					if (estimatedItemWidth == null) {
						estimatedItemWidth = itemWidth;
					}
				} else if (estimatedItemWidth != null) {
					itemWidth = estimatedItemWidth;
				}
			}
			if (i == index) {
				maxX = positionX;
				minX = maxX + itemWidth - width;
				break;
			}
			positionX += itemWidth + this._gap;
		}

		var targetX = this._scrollX;
		if (targetX < minX) {
			targetX = minX;
		} else if (targetX > maxX) {
			targetX = maxX;
		}
		if (result == null) {
			result = new Point();
		}
		result.x = targetX;
		result.y = this._scrollY;
		return result;
	}

	private inline function applyHorizontalAlign(items:Array<DisplayObject>, contentWidth:Float, viewPortWidth:Float):Void {
		if (this._horizontalAlign != RIGHT && this._horizontalAlign != CENTER) {
			return;
		}
		var maxAlignmentWidth = viewPortWidth - this._paddingLeft - this._paddingRight;
		if (contentWidth >= maxAlignmentWidth) {
			return;
		}
		var horizontalOffset = 0.0;
		if (this._horizontalAlign == RIGHT) {
			horizontalOffset = maxAlignmentWidth - contentWidth;
		} else if (this._horizontalAlign == CENTER) {
			horizontalOffset = (maxAlignmentWidth - contentWidth) / 2.0;
		}
		for (item in items) {
			if (item == null) {
				continue;
			}
			var layoutObject:ILayoutObject = null;
			if ((item is ILayoutObject)) {
				layoutObject = cast(item, ILayoutObject);
				if (!layoutObject.includeInLayout) {
					continue;
				}
			}
			item.x = Math.max(this._paddingLeft, item.x + horizontalOffset);
		}
	}
}

@:dox(hide)
private class VirtualCacheItem {
	public function new(itemWidth:Float, itemHeight:Float) {
		this.itemWidth = itemWidth;
		this.itemHeight = itemHeight;
	}

	public var itemWidth:Float;
	public var itemHeight:Float;
}
