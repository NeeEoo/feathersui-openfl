/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.layout;

import feathers.core.IValidating;
import openfl.display.DisplayObject;
import openfl.events.EventDispatcher;

/**
	Positions and sizes items by anchoring their edges (or center points) to
	to their parent container or to other items in the same container.

	@see [Tutorial: How to use AnchorLayout with layout containers](https://feathersui.com/learn/haxe-openfl/anchor-layout/)
	@see `feathers.layout.AnchorLayoutData`

	@since 1.0.0
**/
class AnchorLayout extends EventDispatcher implements ILayout {
	/**
		Creates a new `AnchorLayout` object.

		@since 1.0.0
	**/
	public function new() {
		super();
	}

	/**
		@see `feathers.layout.ILayout.layout`
	**/
	public function layout(items:Array<DisplayObject>, measurements:Measurements, ?result:LayoutBoundsResult):LayoutBoundsResult {
		for (item in items) {
			var layoutObject:ILayoutObject = null;
			if (Std.is(item, ILayoutObject)) {
				layoutObject = cast(item, ILayoutObject);
				if (!layoutObject.includeInLayout) {
					continue;
				}
			}
			if (Std.is(item, IValidating)) {
				cast(item, IValidating).validateNow();
			}
		}

		var maxX = 0.0;
		var maxY = 0.0;
		for (item in items) {
			var layoutObject:ILayoutObject = null;
			if (Std.is(item, ILayoutObject)) {
				layoutObject = cast(item, ILayoutObject);
				if (!layoutObject.includeInLayout) {
					continue;
				}
			}
			var layoutData:AnchorLayoutData = null;
			if (layoutObject != null && Std.is(layoutObject.layoutData, AnchorLayoutData)) {
				layoutData = cast(layoutObject.layoutData, AnchorLayoutData);
			}

			if (Std.is(item, IValidating)) {
				cast(item, IValidating).validateNow();
			}

			if (layoutData == null) {
				var itemMaxX = item.x + item.width;
				if (maxX < itemMaxX) {
					maxX = itemMaxX;
				}
				var itemMaxY = item.y + item.height;
				if (maxY < itemMaxY) {
					maxY = itemMaxY;
				}
			} else // has AnchorLayoutData
			{
				if (layoutData.top != null) {
					item.y = layoutData.top;
				}
				if (layoutData.left != null) {
					item.x = layoutData.left;
				}
				if (layoutData.verticalCenter == null) {
					var itemMaxY = item.y + item.height;
					if (layoutData.bottom != null) {
						itemMaxY += layoutData.bottom;
					}
					if (maxY < itemMaxY) {
						maxY = itemMaxY;
					}
				} else {
					var itemMaxY = item.height;
					if (maxY < itemMaxY) {
						maxY = itemMaxY;
					}
				}
				if (layoutData.horizontalCenter == null) {
					var itemMaxX = item.x + item.width;
					if (layoutData.right != null) {
						itemMaxX += layoutData.right;
					}
					if (maxX < itemMaxX) {
						maxX = itemMaxX;
					}
				} else {
					var itemMaxX = item.width;
					if (maxX < itemMaxX) {
						maxX = itemMaxX;
					}
				}
			}
		}
		var viewPortWidth = maxX;
		if (measurements.width != null) {
			viewPortWidth = measurements.width;
		} else {
			if (measurements.minWidth != null && viewPortWidth < measurements.minWidth) {
				viewPortWidth = measurements.minWidth;
			} else if (measurements.maxWidth != null && viewPortWidth > measurements.maxWidth) {
				viewPortWidth = measurements.maxWidth;
			}
		}
		var viewPortHeight = maxY;
		if (measurements.height != null) {
			viewPortHeight = measurements.height;
		} else {
			if (measurements.minHeight != null && viewPortHeight < measurements.minHeight) {
				viewPortHeight = measurements.minHeight;
			} else if (measurements.maxHeight != null && viewPortHeight > measurements.maxHeight) {
				viewPortHeight = measurements.maxHeight;
			}
		}
		for (item in items) {
			var layoutObject:ILayoutObject = null;
			if (Std.is(item, ILayoutObject)) {
				layoutObject = cast(item, ILayoutObject);
				if (!layoutObject.includeInLayout) {
					continue;
				}
			}
			var layoutData:AnchorLayoutData = null;
			if (layoutObject != null && Std.is(layoutObject.layoutData, AnchorLayoutData)) {
				layoutData = cast(layoutObject.layoutData, AnchorLayoutData);
			}
			if (layoutData == null) {
				continue;
			}
			if (layoutData.bottom != null) {
				if (layoutData.top == null) {
					item.y = viewPortHeight - layoutData.bottom - item.height;
				} else {
					var itemHeight = viewPortHeight - layoutData.bottom - layoutData.top;
					if (itemHeight < 0.0) {
						itemHeight = 0.0;
					}
					if (item.height != itemHeight) {
						// to ensure that the item can continue to auto-size
						// itself, don't set the explicit size unless needed
						item.height = itemHeight;
					}
				}
			} else if (layoutData.verticalCenter != null) {
				item.y = layoutData.verticalCenter + (viewPortHeight - item.height) / 2.0;
			}
			if (layoutData.right != null) {
				if (layoutData.left == null) {
					item.x = viewPortWidth - layoutData.right - item.width;
				} else {
					var itemWidth = viewPortWidth - layoutData.right - item.x;
					if (itemWidth < 0.0) {
						itemWidth = 0.0;
					}
					if (item.width != itemWidth) {
						// to ensure that the item can continue to auto-size
						// itself, don't set the explicit size unless needed
						item.width = itemWidth;
					}
				}
			} else if (layoutData.horizontalCenter != null) {
				item.x = layoutData.horizontalCenter + (viewPortWidth - item.width) / 2.0;
			}
		}
		if (result == null) {
			result = new LayoutBoundsResult();
		}
		result.contentWidth = viewPortWidth;
		result.contentHeight = viewPortHeight;
		result.viewPortWidth = viewPortWidth;
		result.viewPortHeight = viewPortHeight;
		return result;
	}
}
