//Boot script for Ascension SSTO.  Runs maxq.ks with craft-specific parameters.
//The Ascension can be downloaded here: http://kerbalx.com/crypto/Ascension
switch to 0.
runOncePath("lib/lib_text").

// Set craft-specific variables.
// These are available to any child program.
SET takeoffSpeed 	TO 130. // Takeoff speed in m/s.
SET takeoffAngle 	TO 12. 	// Degrees of pitch.
SET tgtQ 		TO 25.
SET minPitch 		TO 5.	// Kludge to prevent autopilot diving too much
SET boostDeg 		TO 25. 	// Pitch when switching to rocket / boost phase.

Print SHIP:STATUS.
runpath("maxq",takeoffSpeed, takeoffAngle, tgtQ, minPitch, boostDeg).
//Delete boot script (this file) from bootloader
//SET CORE:BOOTFILENAME TO "".
