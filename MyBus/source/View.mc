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
	var posnInfo;

	function initialize() {
		View.initialize();
	}

	function onLayout(dc) {
		mMessage = "Press start button";
	}

	function scrollUp(){
		System.println("scrolling up");
		mYOffset -= 20;
		requestUpdate();
	}


	function scrollDown(){
		System.println("scrolling down");
		mYOffset += 20;
		requestUpdate();
	}

	function onUpdate(dc) {
	 	dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
	 	dc.clear();
		// add mYOffset to every Y value you want to scroll
		dc.drawText(dc.getWidth()/2, dc.getHeight()/2 + mYOffset, Graphics.FONT_TINY, mMessage, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
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