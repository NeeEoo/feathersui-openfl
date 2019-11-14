import openfl.events.Event;
import feathers.data.ArrayCollection;
import feathers.controls.PopUpList;
import feathers.controls.ListBox;
import feathers.layout.AnchorLayoutData;
import feathers.layout.AnchorLayout;
import feathers.controls.Panel;
import feathers.controls.LayoutGroup;
import feathers.controls.Application;
import com.feathersui.controls.PoweredByFeathersUI;

class Main extends Application {
	public function new() {
		super();

		// just some bootstrapping code for our app
		this.initializeView();

		// we have an array of unsorted objects
		var arrayItems = [
			{text: "Raccoon"}, {text: "Moose"}, {text: "Cheetah"}, {text: "Penguin"}, {text: "Iguana"}, {text: "Badger"}, {text: "Elephant"},
			{text: "Kangaroo"}, {text: "Dolphin"}, {text: "Yak"}, {text: "Hedgehog"}, {text: "Flamingo"}, {text: "Warthog"}, {text: "Jaguar"},
			{text: "Lobster"}, {text: "Urchin"}, {text: "Newt"}, {text: "Zebra"}, {text: "Octopus"}, {text: "X-Ray Tetra"}, {text: "Quokka"}, {text: "Gecko"},
			{text: "Starling"}, {text: "Toucan"}, {text: "Vulture"}, {text: "Aardvark"},
		];

		// we will display these items in a ListBox
		this.listBox = new ListBox();
		// ListBox expects an IFlatCollection, so we need to wrap the array in
		// an ArrayCollection
		this.listBox.dataProvider = new ArrayCollection(arrayItems);
		// the ListBox will use this function to pass text to the item renderers
		// we'll also use it in our sort comparison functions
		this.listBox.itemToText = (item:Dynamic) -> {
			return item.text;
		};
		this.listBox.layoutData = AnchorLayoutData.fill();
		this.view.addChild(this.listBox);
	}

	private var view:Panel;
	private var listBox:ListBox;

	private function initializeView():Void {
		this.layout = new AnchorLayout();

		this.view = new Panel();
		this.view.layoutData = AnchorLayoutData.fill();
		this.view.headerFactory = () -> {
			var header = new LayoutGroup();
			header.variant = LayoutGroup.VARIANT_TOOL_BAR;
			header.layout = new AnchorLayout();

			var sortPicker = new PopUpList();
			sortPicker.dataProvider = new ArrayCollection([
				// these SortItems hold references to the sort comparison
				// functions, which we'll use in sortPicker_changeHandler()
				new SortItem("Unsorted", null),
				new SortItem("Alphabetical (A-Z)", this.sortAlphabetical),
				new SortItem("Reversed (Z-A)", this.sortReversed)
			]);
			sortPicker.layoutData = AnchorLayoutData.center();
			sortPicker.addEventListener(Event.CHANGE, sortPicker_changeHandler);
			header.addChild(sortPicker);

			return header;
		};
		this.view.footerFactory = () -> {
			var footer = new LayoutGroup();

			footer.variant = LayoutGroup.VARIANT_TOOL_BAR;
			footer.layout = new AnchorLayout();
			var poweredBy = new PoweredByFeathersUI();

			poweredBy.layoutData = AnchorLayoutData.center();
			footer.addChild(poweredBy);
			return footer;
		};
		this.view.layout = new AnchorLayout();
		this.addChild(this.view);
	}

	/**
		Sorts items in the ArrayCollection in alphabetical order (A to Z)
	**/
	private function sortAlphabetical(a:Dynamic, b:Dynamic):Int {
		var aText = this.listBox.itemToText(a);
		var bText = this.listBox.itemToText(b);
		if (aText < bText) {
			return -1;
		}
		if (aText > bText) {
			return 1;
		}
		return 0;
	}

	/**
		Sorts items in the ArrayCollection in reverse alphabetical order (Z to A)
	**/
	private function sortReversed(a:Dynamic, b:Dynamic):Int {
		return -this.sortAlphabetical(a, b);
	}

	/**
		When the PopUpList's selection changes, we'll chage the
		sortCompareFunction on the ListBox's dataProvider.
	**/
	private function sortPicker_changeHandler(event:Event):Void {
		var sortPicker = cast(event.currentTarget, PopUpList);
		var sortItem = cast(sortPicker.selectedItem, SortItem);

		var dataProvider = this.listBox.dataProvider;
		dataProvider.sortCompareFunction = sortItem.sortCompareFunction;
	}
}

/**
	A custom class to hold data for the PopUpList where the user chooses how
	the ListBox's data provider should be sorted.
**/
class SortItem {
	public function new(text:String, sortCompareFunction:(Dynamic, Dynamic) -> Int) {
		this.text = text;
		this.sortCompareFunction = sortCompareFunction;
	}

	public var text:String;
	public var sortCompareFunction:(Dynamic, Dynamic) -> Int;

	@:keep
	public function toString():String {
		return this.text;
	}
}
