using Globals;

module DistanceFormat {
	
	function formatDistance(meters, kmOrMileInMeters) {
		if (meters != null && meters > 0) {
			var distanceKmOrMiles = meters / kmOrMileInMeters;
			if (distanceKmOrMiles < 100) {
				return distanceKmOrMiles.format("%.2f");
			} else {
				return distanceKmOrMiles.format("%.1f");
			}
		} else {
			return Globals.ZERO_DISTANCE;
		}
	}
	
}