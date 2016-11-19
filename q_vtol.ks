// autobalance a 4-engine vtol plane
// Rocket engines, not spooling jets

//Libs
copypath ("0:/kslib/lib_navball.ks", "1:/").
copypath ("0:/lib/lib_text.ks", "1:/").
runoncepath ("1:/lib_text").
runoncepath ("1:/lib_navball").

//Setup
SET want_heading  TO 0.
SET want_pitch TO 0.
set fore_left to Ship:PartsTagged("fore_left")[0].
set rear_left to Ship:PartsTagged("rear_left")[0].
set fore_right to Ship:PartsTagged("fore_right")[0].
set rear_right to Ship:PartsTagged("rear_right")[0].

lock steering to heading (want_heading, want_pitch).

SET vtolPID TO PIDLoop(2, 2, 4, -50, 50).

printHUD ("VTOL start.  AG9 to exit").


//Purpose: Set what atitude we want
function controlLoop {

	if (AG10) {
		PrintHUD ("Zeroing").
		SET want_pitch TO 0.
		AG10 OFF.

	} else {
		SET want_pitch TO (want_pitch + Ship:Control:PilotPitch).
		SET want_heading TO want_heading + (Ship:Control:PilotYaw * 2 ).
	}
}

//Purpose: Hold that atitude.
function balanceLoop {

	SET vtolPID:SetPoint TO want_pitch.
	SET pitch_correct TO vtolPID:Update(TIME:SECONDS, pitch_for(SHIP)).

	set fore_minus to 0 - pitch_correct.
	set rear_minus to 0 + pitch_correct.

	set fore_left:ThrustLimit to (100 - fore_minus).
	set fore_right:ThrustLimit to (100 - fore_minus).
	set rear_left:ThrustLimit to (100 - rear_minus).
	set rear_right:ThrustLimit to (100 - rear_minus).
}
//TODO: Add boolean for debug mode?
//Purpose: Print information.
function printLoop {
	
	clearscreen.
	
	print "pitch:            " + round(pitch_for(SHIP), 1).
	print "Pilot Pitch:      " + Ship:Control:PilotPitch.
	print "want pitch:       " + round(want_pitch, 1).
	print "pitch correction: " + round (pitch_correct, 2).

		
	print "Pilot Yaw:        " + Ship:Control:PilotPitch.
	print "want heading:     " + round(want_heading, 1).
	
	//print "Fore Engine:      " + round(fore_engine:ThrustLimit, 1).
	//print "Rear Engine:      " + round(rear_engine:ThrustLimit, 1).
}

until false {
	controlLoop().	
	balanceLoop().
	printLoop().

	wait 0.1.
}.


