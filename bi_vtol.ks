// autobalance a 2-engine vtol plane
// Rocket engines, not spooling jets

copypath ("0:/KSLib/lib_navball.ks", "1:/").
copypath ("0:/lib/lib_text.ks", "1:/").
runoncepath ("1:/lib_text").
runoncepath ("1:/lib_navball").


set fore_engine to Ship:PartsTagged("fore_engine")[0].
set rear_engine to Ship:PartsTagged("rear_engine")[0].
lock steering to heading (90,0).
//lock Throttle to 1.

set fore_max to fore_engine:maxthrust.
set rear_max to rear_engine:maxthrust.

set hover_thrust to Ship:Mass * 9.8.

SET vtolPID TO PIDLoop(10, 2, 4, -50, 50).

SET want_pitch TO 0.
SET want_roll  TO 0.

SET AG_state TO AG9.

//This should be more like a Heading.
//SET want_yaw to yaw_for(SHIP). // Current yaw

printHUD ("VTOL start.  AG9 to exit").

function mainLoop {
	clearscreen.
	// from 0 <-> 360 to  -180 <-> 180

	SET vtolPID:SetPoint TO want_pitch.
	SET pitch_correct TO vtolPID:Update(TIME:SECONDS, pitch_for(SHIP)).
	print "pitch: " + round(pitch_for(SHIP), 2).
	print "pitch correction: " + round (pitch_correct, 2).
		
	set fore_engine:ThrustLimit to (100 + (pitch_correct) ).
	set rear_engine:ThrustLimit to (100 - (pitch_correct) ).

	print "Fore Engine:    " + round(fore_engine:ThrustLimit, 2).
	print "Rear Engine:    " + round(rear_engine:ThrustLimit, 2).
}

until false {
//until (AG9  != AG_state) {
	mainLoop().
	wait 0.1.
}.

printHUD ("VTOL exit").
