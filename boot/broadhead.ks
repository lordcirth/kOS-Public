//Boot script for Ascension SSTO.  Runs maxq.ks with craft-specific parameters.
//The Ascension can be downloaded here: http://kerbalx.com/crypto/Ascension

copy maxq.ks from 0.
copy lib_text.ks from 0.
run once lib_text.

// Set craft-specific variables.
// These are available to any child program.
SET takeoffSpeed TO 160. // Takeoff speed in m/s.
SET takeoffAngle TO 12. // Degrees of pitch.
SET tgtQ TO 35.
SET boostDeg TO 30. // Pitch when switching to rocket / boost phase.

Print SHIP:STATUS.
run maxq(takeoffSpeed, takeoffAngle, tgtQ, boostDeg).
//Delete boot script (this file) from bootloader
//SET CORE:BOOTFILENAME TO "".

