// Script to automatically launch various SSTO spaceplanes to orbit.
// Tested with the Proton.
// File: maxq.ks  From: https://github.com/lordcirth/kOS-Public
// Made for all SSTO spaceplanes, in theory.
// The following flight path parameters, customized to craft,
// 	should be set in the script that calls this.  Or pasted in here if you really want.
// 
//Known issues:  Payload / VTOL engines will be activated.

parameter takeoffSpeed.
parameter takeoffAngle.
parameter tgtQ.
parameter minPitch.
parameter boostDeg.

//====================
// Prep & declarations
//====================

if ( Body:name <> "Kerbin" ) {
	return.
}

copypath ("0:/lib/lib_text.ks", "1:/").
copypath ("0:/kslib/lib_navball.ks", "1:/").
copypath ("0:/lib/lib_engines.ks", "1:/").

runoncepath ("1:/lib_text").
runoncepath ("1:/lib_navball").
runpath ("1:/lib_engines", "untagged"). //Ignore tagged engines (VTOL, payload)

SET jetMinThrust TO 70. //Point at which jets are considered done.
SET SHIP:Control:PilotMainThrottle TO 0.
//SET STEERINGMANAGER:MAXSTOPPINGTIME TO 5.

FUNCTION PrintAscent { //Print misc info. Called from a steering loop.
	clearscreen.
	Print "Cur Q:    " + round(SHIP:DynamicPressure * Constant:AtmTokPa,1).
	Print "Tgt Q:    " + round(DynP_PID:SETPoint * Constant:AtmTokPa ,1).
	Print "Error:    " + round((SHIP:DynamicPressure * Constant:AtmTokPa - DynP_PID:SETPoint * Constant:AtmTokPa),4).
	Print "Want Pitch:    " + round(Pitch,4).
	Print "Real Pitch:    " + round(pitch_for(SHIP),4).
	SET pitchDiff TO (Pitch - pitch_for(SHIP)).
	Print "Pitch Diff:    " + round(pitchDiff,4).
	if (abs(pitchDiff) > 5) {
		Print "ERROR: Craft cannot follow autopilot!".
	}
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


SET jetMinThrust TO 70. //Point at which jets are considered done.
SET boostDeg TO 30.

//Not used for turbos
if (rapiers:length > 0) { SET jetMaxAlt TO 25000. }.

Function Fly {
	SET Pitch TO DynP_PID:UPDATE(Time:Seconds, SHIP:Q).
	PrintAscent().
	WAIT 0.2.
}.

//====================
// Takeoff
//====================
//Check if we're on runway, otherwise skip ahead
IF (SHIP:STATUS = "PRELAUNCH" OR SHIP:STATUS = "LANDED") {
	Print("Takeoff Speed:	" + takeoffSpeed).
	Print("Target Q:	" + tgtQ).
	Print("Boost angle:	" + boostDeg).

	//Air-breathing
	RapierSet(true).
	EngineSet(rapiers, true).
	EngineSet(jets, true).

//Brakes don't have as much grip in 1.1, they slide.
//	//If we didn't reboot on runway
//	IF SHIP:GROUNDSPEED < 3 { 
//		PrintHUD("Craft ready.  Launching.  Control-C to abort.").
//		BRAKES ON.
//		WAIT 7.  //Spin up the engine
//	}.//Otherwise skip spinup

}. //End PRELAUNCH/LANDED IF
//End state:  Accelerating down runway.

LOCK THROTTLE TO 1.
SET Pitch TO 3.  //Account for wheel tilt.
LOCK STEERING TO HEADING(90,Pitch). 

IF (Alt:Radar < 70) {

	BRAKES OFF. 

	WAIT UNTIL SHIP:GROUNDSPEED > takeoffSpeed.
	PrintHUD("Takeoff speed reached, pulling up.").
	SET Pitch TO takeoffAngle * 2/3.
	WAIT 2.
	SET Pitch TO takeoffAngle.

	WAIT UNTIL ALT:RADAR >  100.  
	PrintHUD("Takeoff complete. Climbing.").
}
//End state:  Climbing off the runway, Alt:Radar > 100


IF (SHIP:STATUS = "FLYING") {
//Retract landing gear
GEAR OFF.

//Initialize PID controller, using dynamic pressure input to control pitch.
//			kP,   	kI, 	kD, 	min,	max
SET DynP_PID TO PIDLOOP(-400,	-20, 	10, 	minPitch,	40).

//SetPoint in Atm because that's what SHIP:DynamicPressure gives.
//Better to convert once than every loop.
SET DynP_PID:SetPoint TO tgtQ * Constant:kPaToAtm. 

if (rapiers:length > 0) {
	WHEN  Altitude > 20000 THEN {
		SET DynP_PID:SetPoint TO 15 * Constant:kPaToAtm.
	}.
	UNTIL (Altitude > jetMaxAlt) { Fly(). }.
}

//TODO:  Currently assumes all jets are the same (ie all whiplashes)
else if (jets:length > 0) { 
	UNTIL (jets[0]:Thrust < jetMinThrust) { Fly(). }.
}

else {Print "Error: no air-breathing engines?  ".}

PrintHUD("Air-breathing flight complete.  Beginning boost phase.").
SET Pitch TO (pitch_for(SHIP) + boostDeg)/2.  //Gentle turn in two parts
LOCK STEERING TO HEADING(90,Pitch). 
WAIT 5.  

//Jets flare out evenly now!
//Run it till it flames out!

if (jets:length > 0) { 
	when (jets[0]:thrust < 1) then {
		EngineSet(jets, false).
	}.
}

RapierSet(false). //Closed-Cycle
EngineSet(nervs, true).
EngineSet(rockets, true).

LOCK THROTTLE TO 1.
SET Pitch TO boostDeg.  //Second half of turn

WAIT UNTIL ALT:Apoapsis > 80000.
LOCK THROTTLE TO 0. //Coast to Apoapsis
LOCK STEERING TO PROGRADE.  //Minimize drag
PrintHUD("Boost phase complete.  Coasting.").

WAIT UNTIL ALTITUDE > 70500. //Out of atmosphere and past jolt

}. //End FLYING IF
//====================
// In Space
//====================


IF (SHIP:STATUS = "SUB_ORBITAL") { //Allow continuing after reboot
LOCK STEERING TO PROGRADE.  //Minimize drag

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
SET Ap TO Apoapsis.
LOCK THROTTLE TO 1.
WAIT UNTIL Periapsis > Ap - 1000.
LOCK THROTTLE TO 0.

PrintHUD("Circularization complete. Releasing controls.").


}. //End Suborbital IF
ELSE { //Skip script if not landed, for safety.
	PrintHUD("Vessel not landed.  Exiting.").
}. 

Unlock Steering. //Safely release controls
SET SHIP:Control:PilotMainthrottle TO 0.




