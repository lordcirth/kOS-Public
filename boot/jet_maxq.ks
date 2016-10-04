//Boot script for Ascension SSTO.  Runs ssto.ks with craft-specific parameters.
//The Ascension can be downloaded here: http://kerbalx.com/crypto/Ascension

copy maxq.ks from 0.
copy lib_text.ks from 0.
run once lib_text.

// Set craft-specific variables.
// These are available to any child program.
SET takeoff TO 130. // Takeoff speed in m/s.
SET tgtQ TO 25.
SET boostDeg TO 30. // Pitch when switching to rocket / boost phase.

Print SHIP:STATUS.
IF SHIP:GroundSpeed < 5 { //On the runway
	BRAKES ON.
	PrintHUD("Craft ready.  Launching in 10 seconds.  Control-C to abort.").
	WAIT 10.
	run maxq.
}. ELSE IF NOT (SHIP:STATUS = "ORBITING") { //If not safely in orbit
	PrintHUD ("Rebooted in flight. Resuming.").
	run maxq.
}.
//Delete boot script (this file) from craft
//SET CORE:BOOTFILENAME TO "".

