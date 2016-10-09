copypath ("0:maxq.ks", "1:/").
copypath ("0:/lib/lib_text.ks", "1:/").
run once lib_text.

// Set craft-specific variables.
// These are available to any child program.
SET takeoffSpeed TO 130. // Takeoff speed in m/s.
SET takeoffAngle TO 15. // Degrees of pitch.
SET tgtQ TO 40.
SET minPitch to 15. //Minimum pitch required to not explode.  Workaround for imperfect PID.
SET boostDeg TO 30. // Pitch when switching to rocket / boost phase.

Print SHIP:STATUS.
run maxq(takeoffSpeed, takeoffAngle, tgtQ, minPitch, boostDeg).
//Delete boot script (this file) from bootloader
//SET CORE:BOOTFILENAME TO "".

