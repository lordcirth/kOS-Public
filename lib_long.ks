//Provides various Longitude conversions & formats.

FUNCTION SrfLong { //Provides SHIP:Longitude converted to 0<->360 deg format
IF SHIP:Longitude < 0 {
		Return SHIP:Longitude + 360.
	}. ELSE {
		Return SHIP:Longitude.
	}.
}.

FUNCTION WatchSrfLong {
	UNTIL false { //Until canceled by user.  Mostly for debugging.
		WAIT 1.
		Print SrfLong().	
	}.
}.

//Return longitude adjusted by body:rotation, as opposed to SrfLong().
FUNCTION OrbitLong { 	//For compatibility with Orbit:LAN, etc
	DECLARE TrueLong IS SrfLong() + Body("Kerbin"):RotationAngle.
	IF TrueLong > 360 { //Wrap around 360 back to 0
		SET TrueLong TO TrueLong - 360.
	}.
	Return TrueLong.
}.

