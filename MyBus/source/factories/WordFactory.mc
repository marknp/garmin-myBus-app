using Toybox.Graphics as Gfx;
using Toybox.WatchUi as Ui;


/**
* WordFactory Model Object
* 
* Picked up by the SDK samples.
*/
class WordFactory extends Ui.PickerFactory {
	var mWords = [];
	var mFont;

	function initialize(words, options) {
		PickerFactory.initialize();

		for (var i = 0; i<words.size(); i++){
			mWords.add(breakLine(words[i]));
		}


		if(options != null) {
			mFont = options.get(:font);
		}

		if(mFont == null) {
			mFont = Gfx.FONT_LARGE;
		}
	}

	function breakLine(word) {
		// TODO: alternatively break after 10 characters
		var indexOfSpace = word.find(" ");
		if (indexOfSpace == null){
			return word;
		} else {
			var endBroken = breakLine(word.substring(indexOfSpace + 1, word.length()));
			return word.substring(0, indexOfSpace) + "\n"	+ endBroken;
		}
	}

	function getSize() {
		return mWords.size();
	}

	function getValue(index) {
		return mWords[index];
	}

	function getDrawable(index, selected) {
		return new Ui.Text({:text=>mWords[index], :color=>Gfx.COLOR_WHITE, :font=>mFont, :locX=>Ui.LAYOUT_HALIGN_LEFT, :locY=>Ui.LAYOUT_VALIGN_CENTER, :width=>200});
	}
}