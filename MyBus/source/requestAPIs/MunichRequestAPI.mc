using Toybox.Time;
/**
* MunichRequestAPI Model Object
*
* Use this class as a blueprint to create classes
* for different APIs.
*
* This class should be a subclass of APIRequest which is
* actually making the requests and receives the responses.
*
* @author Marion Knopp
*/
class MunichRequestAPI extends APIRequest {

	var availableStops;


	/**
	* Constructor.
	*
	* The constructor will initialize the superclass's functions.
	*
	* @param handler: The handler of the application's view delegate.
	* @param stopsEndpoint (symbol): Function the returns the stops endpoint url
	* @param predictionsEndpoint (symbol): Function the returns the predictions endpoint url
	* @param stopsCallback (symbol): Function that is invoked once we have a stops response 
	* @param predictionsCallback (symbol): Function that is invoked once we have a predictions response 
	*/
	function initialize(handler) {
		stopsEndpoint = :getMunichStopsEndpoint;
		predictionsEndpoint = :getMunichPredictionsEndpoint;
		stopsCallback = :onReceiveMunichStops;
		predictionsCallback = :onReceiveMunichPredictions;
		APIRequest.initialize(handler, stopsEndpoint, predictionsEndpoint, stopsCallback, predictionsCallback);
	}

	/**
	* Generate the url, parameters and callback for a stops request.
	* 
	* @return requestInfo (dict): A dictionary with the request variables
	*/
	function getMunichStopsEndpoint() {

			var requestInfo = {
				"url" => "https://www.mvg.de/api/fahrinfo/location/nearby",
				"parameters" => null,
				"callback" => :onReceiveStops,
				"error" => null
			};

			var latitude = posnInfo.position.toDegrees()[0];
			var longitude = posnInfo.position.toDegrees()[1];

			requestInfo["parameters"] = {
				"latitude" => latitude.toString(),
				"longitude" => longitude.toString()
			};

			return requestInfo;
		}

	/**
	* Function that is invoked by the onReceiveStops callback.
	* It parses the response and works out all the stops that
	* are around the location picked up by the GPS.
	* 
	* @param data (dict): The response data of a request to the stops endpoint
	* @return responseInfo (dict): A dictionary with the response information
	*/
	function onReceiveMunichStops(data) {

		// The stopNames returned in the dictionary should be a list of strings
		// that represent the stop names around the GPS's position.
		var responseInfo = {
			"stopNames" => null,
			"error" => null
		};

		// Parse the response received by the request to the stops endpoint.
		availableStops = parseStops(data);

		var stopNames = [];
		if (availableStops.size() > 0) {
			for(var i = 0; i < availableStops.size(); i ++) {
				var stop = availableStops[i]["name"];
				if (stop != null) {
					stopNames.add(stop);
				}
			}
			responseInfo["stopNames"] = stopNames;
		} else {
			responseInfo["error"] = "No stops around";
		}

		return responseInfo;
	}

	function parseStops(data) {
		var stops = [];

		var response = data["locations"];
		for(var i = 0; i < response.size(); i ++) {
			var name = response[i]["name"];
			var products = response[i]["products"];
			var distance = response[i]["distance"];
			var id = response[i]["id"];

			var stop = {
				"name" => name,
				"products" => products,
				"distance" => distance,
				"id" => id
			};
			stops.add(stop);
		}

		System.println("Stops parsed: " + stops);
		return stops;
	}

	/**
	* Generate the url, parameters and callback for a predictions request.
	* 
	* @return requestInfo (dict): A dictionary with the request variables
	*/
	function getMunichPredictionsEndpoint() {
		var selectedStopId = getSelectedStop()["id"];
		
		var requestInfo = {
			"url" => "https://www.mvg.de/api/fahrinfo/departure/" + selectedStopId,
			"parameters" => {},
			"callback" => :onReceivePredictions
		};
		System.println("Will query " + requestInfo["url"] + " for predictions");
		return requestInfo;
	}

	function getSelectedStop() {
		for(var i = 0; i < availableStops.size(); i ++) {
			if (availableStops[i]["name"] == selectedStop) {
				return  availableStops[i];
			}
		}
		return {"id"=> null};
	}

	/**
	* Function that is invoked by the onReceivePredictions callback.
	* It parses the response and works out all the buses that pass
	* by the stop that was selected by the user.
	* 
	* @param data (dict): The response data of a request to the predictions endpoint
	* @return responseInfo (dict): A dictionary with the response information
	*/
	function onReceiveMunichPredictions(data) {
		var responseInfo = {
			"result" => null,
			"error" => null
		};

		// Parse the response received by the request to the predictions endpoint.
		var result = "Stop " + selectedStop + "\n";
		var oepnvDepartures = parseDepartures(data["departures"]);

		if (oepnvDepartures.size() > 0) {
			// Construct the string to show in the watch screen
			for(var i = 0; i < oepnvDepartures.keys().size(); i ++) {
				var key = oepnvDepartures.keys()[i];
				var departure_list_to_str = oepnvDepartures[key].toString();
				// Remove the brackets from the bus_list
				var departure_list = departure_list_to_str.substring(1, departure_list_to_str.length() - 1);
				result += key + "\n" + departure_list + "\n";
				System.println(key + " in: " + departure_list + "\n");
			}
			responseInfo["result"] = result;
		} else {
			responseInfo["error"] = "Apparently there are\nno buses running at\nbus stop " + selectedStop + "\nat the moment!";
		}

		return responseInfo;
	}


	function parseDepartures(data) {
		var oepnvDepartures = {};
		for(var i = 0; i < data.size(); i ++) {
			var destination = data[i]["destination"].toString();
			var destinationShort = (destination.find(" ") != null) ? destination.substring(0, destination.find(" ")) : destination;
			var transportLine = data[i]["label"].toString();
			var transportLabel = transportLine + " " +  destinationShort;	

			var minsTillDeparture = (data[i]["departureTime"]/1000 - Time.now().value())/60;	
			if (minsTillDeparture<60){
				if (oepnvDepartures[transportLabel] == null) {
					var transport_list = [];
					transport_list.add(minsTillDeparture);
					oepnvDepartures[transportLabel] = transport_list;
				} else {
					oepnvDepartures[transportLabel].add(minsTillDeparture);
				}
			}
		}

		return oepnvDepartures;
	}
	
}