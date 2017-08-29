//Deorbit & landing script for SSTO spaceplanes, specifically the Ascension.
//File: deorbit.ks  From: https://github.com/lordcirth/kOS-Public

//COPY lib_safe.ks from 0.
RUNONCEPATH("0:/lib/lib_safe.ks").
//COPY lib_text.ks from 0.
RUNONCEPATH("0:/lib/lib_text.ks").
//COPY lib_rapier.ks from 0.
RUNONCEPATH("0:/lib/lib_engines.ks", "all").
//COPY zeroinc.ks from 0.
//COPY lib_long.ks from 0.
RUNONCEPATH("0:/lib/lib_long").
//COPY lib_pid.ks from 0.	//From https://github.com/gisikw/ksprogramming
RUNONCEPATH("0:/kslib/lib_pid").	//Thanks for the library!

//====================
//Functions: 
//====================

FUNCTION NewSlope { //Create a new slope and start following it.
	//We need to construct a line based on two points:
	// A(startDist,startAlt), B(finalDist,finalAlt)

	//Slope = (Y2 - Y1) / (X2 - X1)
	SET glideSlope TO (finalAlt - startAlt) / (finalLong - startLong).
	// y = m*(x-x2) + y2 .
	LOCK TgtAlt TO glideSlope * (SrfLong() - finalLong) + finalAlt. 
}.

FUNCTION PrintGlide { //Print misc info. Called from a steering loop.
	clearscreen.
	Print "Cur Alt:    " + round(SHIP:Altitude,0).
	Print "Tgt Alt:    " + round(TgtAlt,0).
	//Print "Slope:    " + round(glideSlope,4).
	Print "Error:      " + round((SHIP:Altitude - TgtAlt),4).
	Print "Pitch:      " + round(Pitch,4).
	Print " ". //Newline

	Print "Cruise Spd: " + cruiseSpd.
	Print "Rel Long:   " + (runwayLong - SrfLong()).
	Print " ". //Newline
	
	Print "Lat Err:    " + round((SHIP:Latitude - runwayLat),4).
	Print "Tgt Hdg:    " + round(TgtDir,4).
	Print " ". //Newline

	IF minAlt < 50000 { //Track closest to ground we've been.
	Print "minAlt:     " + round(minAlt,4).
	}.
}.

//Manage airbrakes found by lib_engine
FUNCTION AutoBrake { //Should be called from a loop
parameter speed.  //Speed to brake at
	IF Ship:Velocity:Surface:MAG > speed {
		AirbrakeSet(airbrakes,true).
	}. ELSE {
		AirbrakeSet(airbrakes,false).
	}.
}.

//====================
//Deorbit burn: 
//====================

SET BurnLong TO 155. //Degrees before Runway to begin deorbit.
//Measured from a craft spawned on runway
SET runwayLong TO 285.275833129883. //In 0 <-> 360 notation
SET runwayLat TO -0.048591406236738. //In -180 <-> 180 notation

SET minAlt TO 50000. //Counts lowest Radar Alt, info only

SAFE_TAKEOVER(). //Re-enable SAS

IF (SHIP:STATUS = "ORBITING") { //Ensure safe reboot / update.

RapierSet(false).  //Ensure rapiers are in rocket mode for burn

IF SHIP:ORBIT:Inclination > 0.5 { 
	run zeroinc.  //Zero our orbital inclination
}.

PrintHUD("Deorbit script loaded.").
WAIT 2.  //Don't lag into timewarp if we just loaded
SET WARPMODE TO "RAILS".
SET WARP TO 3. //50X
UNTIL abs(runwayLong - BurnLong - Ship:Longitude) < 15  {  //WARP until 15deg to deorbit
	clearscreen.
	Print  "Deorbit in: " + (runwayLong - BurnLong - Ship:Longitude).
	WAIT 5.
}.
SET WARP TO 0.  //Realtime

//Prep for deorbit burn

LOCK STEERING TO Retrograde.  
Print "Turning".
//print info until the ship is facing Retrograde.
UNTIL VAng(SHIP:Facing:Vector,Retrograde:Vector) < 0.2
AND  runwayLong - BurnLong - Ship:Longitude < 0.2 {	//And it's time to burn

	clearscreen.
	Print  "Deorbit in: " + (runwayLong - BurnLong - Ship:Longitude).
	WAIT 1.
}.

IF runwayLong - BurnLong - Ship:Longitude < -1 
	PrintHUD("Late for burn! Ship turns too slow.").

PrintHud("Oriented for burn.").
Print  "Deorbiting at: " + round((runwayLong -  Ship:Longitude),2) + "degrees from runway".
//Actual burn
LOCK THROTTLE TO 1.
WAIT UNTIL Periapsis < 0. //Intersect KSC
LOCK THROTTLE TO 0.
LOCK STEERING TO Prograde.
}. //End ORBIT IF

//====================
//Glide path steering: 
//====================

//Ensure safe reboot / update.
IF (SHIP:STATUS = "SUB_ORBITAL") OR (SHIP:STATUS = "FLYING") { 
PrintHUD("Beginning glide path.").
BRAKES OFF.

SET Pitch TO 9.
SET TgtDir TO 90. //East.  Will correct later.

//This stays in effect for the rest of the flight
//Update Pitch and TgtDir to change steering.
LOCK STEERING TO Heading(TgtDir,Pitch).

// in AJE, jets will explode if exposed to re-entry intake air
EngineSet(rapiers, false).
EngineSet(jets, false).
RapierSet(true).

AirbrakeSet(airbrakes,true).

WAIT UNTIL SHIP:Velocity:Surface:MAG < 1000. //Wait until not on fire.
EngineSet(rapiers, true).
EngineSet(jets, true).
PrintHUD("Reentry complete.  Aiming for KSC.").

// Curve that converges to runway.
// Set heading according to latitude error, and longitude left to steer in.
LOCK TgtDir TO 75/(runwayLong - SrfLong())*(SHIP:Latitude - runwayLat) + 90.

SET cruiseSpd TO 350. //Minimum speed during glide.
//Be careful of Dynamic Pressure if raising this past 350.
//Peaks at 28 kPa, Mach 1.1.

//Goal:  Descend to 6200 meters at the mountains.
//Using a linear equation to set glide path.
SET startLong TO SrfLong().  //X1 Current position
SET finalLong TO runwayLong - 4.70. //X2 Longitude to mountains

SET startAlt TO SHIP:Altitude. // Y1 Start at current Altitude.
SET finalAlt TO 6200. //Y2 just high enough to clear the mountains

NewSlope(). //Set course based on the 4 values ^

//Easiest way to manage altitude for all situations is with a PID system.
//This took forever to tune.
SET AltPID TO PID_init(0.10,0.016,0.32,-15,15). //Control pitch between -15 and 15 deg

UNTIL SrfLong() > finalLong {  //Past the mountains
	//Increase throttle based on m/s below cruiseSpd
	LOCK THROTTLE TO ((cruiseSpd - Ship:Velocity:Surface:MAG) / 50).
	SET Pitch TO PID_seek (AltPID,TgtAlt,SHIP:Altitude). //Follow slope
	PrintGlide().
	IF (SHIP:Altitude - TgtAlt) > 5000 {
		AutoBrake(500). //If we can't dive fast enough, brake hard
	}. ELSE {
		AutoBrake(max((SHIP:Altitude / 20),400)). //Just don't shatter.
	}.
	WAIT 0.2.
}.

PrintHUD ("KSC in sight.").

//New glide slope since we are past the mountains 
SET finalAlt TO 200. //As low as is safe over the last hill.
SET startAlt TO SHIP:Altitude.
SET finalLong TO runwayLong - 0.30. //End over the last hill.
SET startLong TO SrfLong().

SET AltPID TO PID_init(0.30,0.10,1.00,-15,15). //Retune PID for landing
NewSlope(). //Update course
SET cruiseSpd TO 200.

//WHEN statements run in parallel, unlike WAIT or UNTIL
WHEN runwayLong - SrfLong() < 0.7 THEN {
	SET cruiseSpd TO 110.
	GEAR OFF. //Reset
	GEAR ON.  //Landing gear down
	BRAKES OFF. //Reset
}.

PrintHUD ("On final approach.").

WHEN SrfLong() > finalLong THEN {
	LOCK TgtDir to 90. 	//Straight East, no steering
	SET landingSpd TO 2. 	//vertical speed to (try to) land at
	// y = m*(x-x2) + y2 Construct line from landing slope and point.
	LOCK TgtAlt TO (landingSpd) * 100 *(runwayLong - SrfLong() + 0.05 ) + 075. 
	PrintHUD("Landing guidance").
}.

WHEN (SrfLong() > finalLong + 0.10) THEN {
	SET landingSpd TO 1. 	//vertical speed to (try to) land at
	PrintHUD("Landing guidance 2").
}.

//Sqrt curve version
// Doesn't work yet
//WHEN SrfLong() > finalLong THEN {
//	LOCK TgtDir to 90. //Straight East, no steering
//	// y = sqrt(x + 0.33) + currentAlt
//	LOCK TgtAlt TO -05 * sqrt(10*(runwayLong - SrfLong() + 0.33)) + 100.
//}.

UNTIL  ALT:RADAR < 3.5 { //Landed/Landing
	//Increase throttle based on m/s we lack.  Gentler this time
	LOCK THROTTLE TO ((cruiseSpd - Ship:Velocity:Surface:MAG) / 75).
	//Airbrake if going 20% over cruiseSpd.
	AutoBrake(cruiseSpd * 1.2).
	SET Pitch TO PID_seek (AltPID,TgtAlt,SHIP:Altitude).
	SET minAlt TO min(minAlt,ALT:RADAR). //Constantly keep lowest record.
	PrintGlide().
	WAIT 0.2. //Fast reflexes for this part.
}.

SET Pitch TO Pitch - 3. // Don't pitch up and smash the engines
WAIT 2. //Make sure we're stably rolling
SET cruiseSpd to 0. 
BRAKES ON.
PrintHUD("Landed.  Braking.").
LOCK THROTTLE TO 0.
EngineSet(rapiers, false).  //Keeps idling otherwise
AG10 ON.//Airbrakes.
WAIT UNTIL SHIP:Velocity:Surface:MAG < 1. 
WAIT 1.  //Keep steering East until we stop.

PrintHud("Flight complete.  Exiting.").

}. //END SUB_ORBITAL / FLYING IF
ELSE {
	PrintHud("Craft not flying!  Exiting.").
}.

SAFE_QUIT(). //Release controls safely
