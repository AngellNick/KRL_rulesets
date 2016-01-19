ruleset track_trips {
	meta {
		name "track_trips"
		description <<
			Single Picos assignment: track_trips with long_trip
			>>
		author "Nicholas Angell"
	}
	
	global {
		long_trip = 50
	}

	rule process_trip {
		select when car new_trip
		pre {
			mileage = event:attr("mileage")
		}
		{
			send_directive("trip") with
				length = mileage
		}
		fired {
			raise explicit event "trip_processed" with
				attributes = event:attrs()
		}
	}
	
	rule find_long_trips {
		select when explicit trip_processed
		pre {
			mileage = event:attr("mileage")
		}
		{
			send_directive("finding_long_trips") with
				trip = (mileage > 50) => "Long" | "Short"
		}
		fired {
			raise explicit event "found_long_trip"
				if (mileage > long_trip)
		}
	}
	
	rule process_long_trip {
		select when explicit found_long_trip
		{
			send_directive("long_trip") with
				longtrip = "It was a long trip"
		}
	}
}