ruleset trip_store {
	meta {
		name "trip_store"
		description <<
			Single Picos assignment: trip_store
			>>
		author "Nicholas Angell"
		provides trips, long_trips, short_trips
		sharing on
	}
	
	global {
		trips = function() {
			ent:trips;
		};
		long_trips = function() {
			ent:long_trips;
		};
		short_trips = function() {
			AllTrips = trips().klog("ALL TRIPS: ");
			trips().filter(function(x) { // TEST: x is not in long_trips()
				long_trips().none(function(y) {
					x{"timestamp"} eq y{"timestamp"};
				});
			}).klog("Short trips: ");
		};
	}
	
	rule collect_trips {
		select when explicit trip_processed
		pre {
			trip = {"length" : event:attr("mileage"),
						"timestamp" : event:attr("timestamp")}
		}
		always {
			set ent:trips ent:trips.append(trip);
		}
	}
	
	rule collect_long_trips {
		select when explicit found_long_trip
		pre {
			long_trip = {"length" : event:attr("mileage"),
						"timestamp" : event:attr("timestamp")};
		}
		{
			send_directive("long_trip") with
				leng = event:attr("mileage");
		}
		always {
			set ent:long_trips ent:long_trips.append(long_trip);
		}
	}
	
	rule clear_trips {
		select when car trip_reset
		fired {
			set ent:trips [];
			set ent:long_trips [];
		}
	}
}