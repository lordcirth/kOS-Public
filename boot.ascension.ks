//Boot script for Ascension SSTO.  Runs ssto.ks with craft-specific parameters.
//The Ascension can be downloaded here: http://kerbalx.com/crypto/Ascension
BRAKES ON.

copy ssto.ks from 0.
copy lib_text.ks from 0.
run once lib_text.

// Set craft-specific variables.
// These are available to any child program.
SET takeoff TO 110. // Takeoff speed in m/s.
SET climbDeg TO 25. // Pitch for initial climb in degrees
SET sprintAoA TO 6. // Pitch to maintain level flight at beginning of sprint
SET boostDeg TO 30. // Pitch when switching to rocket / boost phase.

IF SHIP:STATUS = "PRELAUNCH" {
PrintHUD("Craft ready.  Launching in 10 seconds.  Control-C to abort.").
//Print "Enter 'RUN ssto' to launch.".
WAIT 10.
}. ELSE PrintHUD ("Rebooted in flight.").
run ssto.

//Delete boot script to prevent running on reboot.
//DELETE CORE:BOOTFILENAME.
