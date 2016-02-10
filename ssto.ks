// Script to automatically launch SSTO spaceplanes to orbit. Tested with the Ascension.
// File: ssto.ks  From: https://github.com/lordcirth/kOS-Public
// Made for spaceplanes which use purely RAPIER engines to get to orbit.
// The following flight path parameters, customized to craft,
// 	should be set in the script that calls this.  Or pasted in here.
//	Ascension numbers given as examples
// takeoff   = 110 - Takeoff speed in m/s
// climbDeg  = 25  - Angle for initial climb in degrees
// sprintAoA = 6   - AoA that maintains level flight at beginning of sprint. ie 6 deg.
// boostDeg  = 30  - Angle for rocket ascent
// Accel     = 12  - Temporary hack, m/s^2 at full throttle at Ap.

COPY lib_safe.ks from 0.
RUN ONCE lib_safe.ks.  //Declare SAFE_QUIT()
COPY lib_text.ks from 0.
RUN ONCE lib_text.ks.  //Declare PrintHUD()
COPY lib_rapier.ks from 0.
RUN ONCE lib_rapier.ks.  //Import RAPIER engine handling functions

//Only do anything if we're landed
IF (SHIP:STATUS = "LANDED") OR (SHIP:STATUS = "PRELAUNCH") {
BRAKES ON.

//Make sure the engine is in air breathing mode
SetRapiersMode("AirBreathing").

//Disable gimbal - it makes the plane twitchy
SetRapiersGimbal("Off").

PrintHUD("Launching.").
LOCK THROTTLE TO 1.
SetRapiersOn().

LOCK STEERING TO HEADING(90,2). //2 deg to account for wheel tilt.

WAIT 5.  //Spin up the engine
BRAKES OFF. 

WAIT UNTIL SHIP:GROUNDSPEED > takeoff.
PrintHUD("Takeoff speed reached, pulling up.").
LOCK STEERING TO HEADING(90,10).  //Takeoff


WAIT UNTIL ALT:RADAR > 100.  //100 meters off the ground
PrintHUD("Takeoff complete. Climbing.").
LOCK STEERING TO HEADING(90,climbDeg).  //Climb

//Retract landing gear
GEAR OFF.

WAIT UNTIL ALTITUDE > 15000.
PrintHUD("15km.  Leveling off to build up speed.").
LOCK STEERING TO HEADING(90,(climbDeg+sprintAoA)/2).
WAIT 5.  //Turn in two equal parts, gentler
LOCK STEERING TO HEADING(90,sprintAoA).  //Build up speed

WAIT UNTIL ALTITUDE > 23000.  //Approx airbreathing ceiling
PrintHUD("23km. Sprint complete.  Beginning boost phase.").
LOCK STEERING TO HEADING(90,(sprintAoA+boostDeg)/2).  //Gentle turn in two parts
WAIT 10.  //Use as much jet Isp as possible

SetRapiersMode("ClosedCycle").
SetRapiersGimbal("On").  //Control surfaces will be useless soon.
LOCK STEERING TO HEADING(90,boostDeg).  //Second half of turn

WAIT UNTIL ALT:Apoapsis > 80000.
LOCK THROTTLE TO 0. //Coast to Apoapsis
LOCK STEERING TO PROGRADE.  //Minimize drag
PrintHUD("Boost phase complete.  Coasting.").

WAIT UNTIL ALTITUDE > 70000. //Out of atmosphere

}. //End Landed IF

IF (SHIP:STATUS = "SUB_ORBITAL") { //Allow continuing after reboot

LOCK STEERING TO PROGRADE.  
SET ApSpd TO velocityAt(SHIP, ETA:Apoapsis + TIME:SECONDS):ORBIT:MAG. //Scalar speed at Ap
PRINT ApSpd + "m/s at Apoapsis".

//Estimate final burn
//A lot of assumed constants / fudge factors in here
//TODO: Fancier, general solutions

// F = m*a , so a = F / m.

SET Accel TO SHIP:MaxThrust / SHIP:Mass. // m/s^2
PRINT "Acceleration: " + Accel.
SET burnDv TO 2200 - ApSpd.
SET burnLen TO burnDv/Accel.  //Assume TWR won't change during burn
PRINT "Will burn for " + burnLen.
WAIT UNTIL ETA:Apoapsis < ( burnLen / 2 ).
PrintHUD("Beginning final burn.").
LOCK THROTTLE TO 1.

WAIT UNTIL Periapsis > 79000.
LOCK THROTTLE TO 0.

PrintHUD("Circularization complete. Releasing controls.").


}. //End Suborbital IF
ELSE { //Skip script if not landed, for safety.
	PrintHUD("Vessel not landed.  Exiting.").
}. 

SAFE_QUIT(). //Safely release controls
