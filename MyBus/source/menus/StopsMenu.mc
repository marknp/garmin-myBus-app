using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;


class StopsMenu extends Ui.Menu2 {

	function initialize(stops) {
		System.println("init");
		var title = "Select stop";

		Ui.Menu2.initialize({:title => title});
		for (var i = 0; i<stops.size(); i++){
			var stop = stops[i];
			System.println("add item " + stop);
			addItem(
				new Ui.MenuItem(
				stop["name"],
				stop["products"].toString(),
				stop["id"],
				{}
				)
			);
		}
	}
}

class StopsMenuDelegate {
	var APIRequestInstance;

	function initialize(instance) {
		System.println("init d");

		// Allow the picker to access the request instance
		APIRequestInstance = instance;
	}

	function onSelect(item) {
		var stop = item.getLabel();
		System.println("selected " + stop);

		APIRequestInstance.setSelectedStop(stop);
		var predictionsEndpoint = APIRequestInstance.predictionsEndpoint;
		// Now that we have the stop name, make a predictions request,
		// to retrieve all the bus predictions for this stop.
		APIRequestInstance.makeWebRequest(predictionsEndpoint);
		Ui.popView(Ui.SLIDE_IMMEDIATE);
	}

	function onCancel() {
		System.println("canc");

		Ui.popView(Ui.SLIDE_IMMEDIATE);
	}
}