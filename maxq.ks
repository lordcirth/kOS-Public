// Script to automatically launch various SSTO spaceplanes to orbit.
// Tested with the Proton.
// File: maxq.ks  From: https://github.com/lordcirth/kOS-Public
// Made for all SSTO spaceplanes, in theory.
// The following flight path parameters, customized to craft,
// 	should be set in the script that calls this.  Or pasted in here if you really want.
//	Proton numbers given as examples
//SET takeoff 	TO 110. // Takeoff speed in m/s.
//SET tgtQ 	TO  30. // Dynamic Pressure in kPa to hold
//SET boostDeg 	TO  30  // Angle for rocket ascent

//Known issues:  Payload engines will be activated.

//====================
// Prep & declarations
//====================

COPY lib_text.ks from 0.
RUN ONCE lib_text.ks.  //Declare PrintHUD()
SET SHIP:Control:PilotMainThrottle TO 0.

COPY lib_engines.ks from 0.
RUN lib_engines.ks.

FUNCTION PrintAscent { //Print misc info. Called from a steering loop.
	clearscreen.
	Print "Cur Q:    " + round(SHIP:DynamicPressure * Constant:AtmTokPa,1).
	Print "Tgt Q:    " + round(DynP_PID:SETPoint * Constant:AtmTokPa ,1).
	Print "Error:    " + round((SHIP:DynamicPressure * Constant:AtmTokPa - DynP_PID:SETPoint * Constant:AtmTokPa),4).
	Print "Pitch:    " + round(Pitch,4).
}

FUNCTION CalcCirc {
	//Estimate final burn
	//A lot of assumed constants / fudge factors in here
	//TODO: Fancier, general solutions
	// F = m*a , so a = F / m.

	SET Accel TO SHIP:MaxThrust / SHIP:Mass. // m/s^2
	PRINT "Acceleration: " + Accel.
	SET burnDv TO 2200 - ApSpd.
	SET burnLen TO burnDv/Accel.  //Assume TWR won't change much during burn
	PRINT "Will burn for " + burnLen.
}

FUNCTION burnStart { //ETA till burn
	Return ETA:Apoapsis - ( burnLen / 2 ).
}

for r in rapiers {
	set r:autoswitch to false.
}.


SET boostDeg TO 30.

if (rapiers:length > 0) { SET jetMaxAlt TO 25000. }.
//Not used for turbos

Function EngineSet {
//Pass a list of engines, and a bool, on
parameter eList, on.
	if on {
		for e in eList {e:Activate.}.
	}.
	else {
		for e in eList {e:Shutdown.}.
	}.
}.

Function RapierSet {
//List of rapier engines, bool air
parameter air.
	for r in rapiers {
		if NOT (air = r:PrimaryMode) { r:togglemode(). }.
	}.
}.

Function Fly {
	SET Pitch TO DynP_PID:UPDATE(Time:Seconds, SHIP:Q).
	PrintAscent().
	WAIT 0.2.
}.

//====================
// Takeoff
//====================

//Check if we're landed, otherwise skip ahead
IF (SHIP:STATUS = "LANDED") OR (SHIP:STATUS = "PRELAUNCH") {
Print "Landed, taking off".
//Air-breathing
RapierSet(true).
EngineSet(rapiers, true).
EngineSet(jets, true).

LOCK THROTTLE TO 1.
//If we didn't reboot on runway
IF SHIP:GROUNDSPEED < 3 { 
	BRAKES ON.
	WAIT 7.  //Spin up the engine
}.//Otherwise skip spinup
}. //End LANDED IF

LOCK THROTTLE TO 1.

BRAKES OFF. 
SET Pitch TO 3.  //Account for wheel tilt.
LOCK STEERING TO HEADING(90,Pitch). 

WAIT UNTIL SHIP:GROUNDSPEED > takeoff.
PrintHUD("Takeoff speed reached, pulling up.").
SET Pitch TO 10.
WAIT 2.
SET Pitch TO 15.


WAIT UNTIL ALT:RADAR >  100.  
PrintHUD("Takeoff complete. Climbing.").

IF (SHIP:STATUS = "FLYING") {
//Retract landing gear
GEAR OFF.
//			kP,   kI, kD, min, max
SET DynP_PID TO PIDLOOP(-400, -20, 10, 4,   50).
SET DynP_PID:SetPoint TO tgtQ * Constant:kPaToAtm.

if (rapiers:length > 0) {
	WHEN  Altitude > 20000 THEN {
		SET DynP_PID:SetPoint TO 15 * Constant:kPaToAtm.
	}.
	UNTIL (Altitude > jetMaxAlt) { Fly(). }.
}.

//TODO:  Currently assumes all jets are the same (ie all whiplashes)
else if (jets:length > 0) { 
	UNTIL (jets[0]:Thrust < jetMinThrust) { Fly(). }.
}.

else {Print "Error: no air-breathing engines?".}.

PrintHUD("Air-breathing flight complete.  Beginning boost phase.").
SET Pitch TO (Pitch+boostDeg)/2.  //Gentle turn in two parts
WAIT 5.  //Use as much jet Isp as possible

EngineSet(jets, false).
RapierSet(false). //Closed-Cycle
EngineSet(nervs, true).
EngineSet(rockets, true).

SET Pitch TO boostDeg.  //Second half of turn

WAIT UNTIL ALT:Apoapsis > 80000.
LOCK THROTTLE TO 0. //Coast to Apoapsis
LOCK STEERING TO PROGRADE.  //Minimize drag
PrintHUD("Boost phase complete.  Coasting.").

WAIT UNTIL ALTITUDE > 70000. //Out of atmosphere

}. //End FLYING IF
//====================
// In Space
//====================


IF (SHIP:STATUS = "SUB_ORBITAL") { //Allow continuing after reboot
Print "Suborbital".
SET burnLen TO 0. //Declare global
SET Pitch TO 0.  
SET ApSpd TO velocityAt(SHIP, ETA:Apoapsis + TIME:SECONDS):ORBIT:MAG. //Scalar speed at Ap
PRINT ApSpd + "m/s at Apoapsis".

//If we have LV-N's, use only them to circularize.
IF (nervs:length > 0) {
	EngineSet(rapiers, false).
	EngineSet(rockets, false).
	Print "NERV's only:".
	CalcCirc().
	
	//If burnStart in the past, not enough TWR.
	IF (burnStart() < 0) AND (rockets:length > 0) {
		Print "Too slow!".
		//Most SSTO rockets have better Isp than Rapiers.
		Print "NERV's + rockets:".
		EngineSet(rockets, true).
		CalcCirc().
	}.
	IF (burnStart() < 0) AND (rapiers:length > 0) {
		Print "Too slow!".
		Print "All engines:".
		EngineSet(rapiers, true).
		CalcCirc().
	}.
}. 
//Otherwise, All vac engines are on already
else { CalcCirc(). }.

UNTIL burnStart() < 1 { //0 always misses and overlaps!
	clearscreen.
	Print "Burning in: " + round(burnStart(), 1) + " seconds.".
	WAIT 0.2.
}.

WAIT 2.  //Burn ~1sec late, fudge to make up for mass decrease

PrintHUD("Beginning final burn.").
LOCK THROTTLE TO 1.
WAIT UNTIL Periapsis > 79000.
LOCK THROTTLE TO 0.

PrintHUD("Circularization complete. Releasing controls.").


}. //End Suborbital IF
ELSE { //Skip script if not landed, for safety.
	PrintHUD("Vessel not landed.  Exiting.").
}. 

Unlock Steering. //Safely release controls
SET SHIP:Control:PilotMainthrottle TO 0.



