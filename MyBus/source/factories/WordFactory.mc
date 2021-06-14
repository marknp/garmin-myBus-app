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
			mWords.add(breakLatestAt(words[i]));
		}


		if(options != null) {
			mFont = options.get(:font);
		}

		if(mFont == null) {
			mFont = Gfx.FONT_LARGE;
		}
	}

	function breakLatestAt(word){
		var len = 7;
		var broken = "";
		for (var i =0; i<=word.length()/len; i++) {
			broken = broken + word.substring(i*len, i*len+len) + "\n";
		}
		var returns = broken.substring(0, broken.length()-1);
		System.println(returns);
		return returns;
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