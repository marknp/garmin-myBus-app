using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;


/**
* View Model Object
*
* @author Christos Liontos
*/
class View extends Ui.View {

	hidden var mYOffset = 0;
	hidden var mMessage = "Press menu button";
	hidden var mModel;
	hidden var SCROLL_AMOUNT = 50;
	var posnInfo;

	function initialize() {
		View.initialize();
	}

	function onLayout(dc) {
		mMessage = "Press start button";
	}

	function scrollUp(){
		mYOffset -= SCROLL_AMOUNT;
		requestUpdate();
	}


	function scrollDown(){
		mYOffset += SCROLL_AMOUNT;
		requestUpdate();
	}

	function onUpdate(dc) {
	 	dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
	 	dc.clear();
		var  message = splitString(dc, Graphics.FONT_TINY, mMessage, 2);
		// add mYOffset to every Y value you want to scroll
		dc.drawText(dc.getWidth()/2,  2 + mYOffset, Graphics.FONT_TINY, message, Graphics.TEXT_JUSTIFY_CENTER);
	}

	function splitString(dc, font, str, margin){
		// https://forums.garmin.com/developer/connect-iq/f/discussion/999/render-a-long-string
		var width = dc.getWidth() - margin * 2;
		var strLen = str.length();
		var firstChar = 0;
		var lastChar = 0;
		var newStr = "";

		if(strLen == 0){return "";}

		for(var i = 0; i <= strLen; i++) {
			var char = str.substring(i, i + 1);
			if(char.equals(" ") || i == strLen){
				if(dc.getTextWidthInPixels(str.substring(firstChar, i), font) < width){
					lastChar = i;
				}
				else {
					newStr += str.substring(firstChar, lastChar) + "\n";
					firstChar = lastChar + 1;
				}
			}
		}
		newStr += str.substring(firstChar, strLen);
		return newStr;
	}

	function setPosition(info) {
		posnInfo = info;
	}

	function onReceive(args) {
		if (args instanceof Lang.String) {
			mMessage = args;
		}
		else if (args instanceof Dictionary) {
			// Print the arguments duplicated and returned by jsonplaceholder.typicode.com
			var keys = args.keys();
			mMessage = "";
			for( var i = 0; i < keys.size(); i++ ) {
				mMessage += Lang.format("$1$: $2$\n", [keys[i], args[keys[i]]]);
			}
		}
		Ui.requestUpdate();
	}

}