// autobalance a 2-engine vtol plane
// Rocket engines, not spooling jets

//Libs
copypath ("0:/kslib/lib_navball.ks", "1:/").
runoncepath ("1:/lib_navball").

copypath ("0:/lib/lib_text.ks", "1:/").
runoncepath ("1:/lib_text").

copypath ("0:/lib/lib_engines.ks", "1:/").
runoncepath ("1:/lib_engines", "all").

//Setup
SET want_heading  TO 270. //TODO: Current heading
SET want_pitch TO 0.

set fore_engines to Ship:PartsTagged("fore_engine").
set rear_engines to Ship:PartsTagged("rear_engine").

if (fore_engines:length = 0) or (rear_engines:length = 0) {
	printHUD ("Engines not properly tagged.  Exiting.").
} else { // Do the whole program


lock steering to heading (want_heading, want_pitch).

SET vtolPID TO PIDLoop(10, 2, 4, -70, 70).

printHUD ("VTOL start.  AG9 to exit").

//Purpose: Set what atitude we want
function controlLoop {

	if (AG10) {
		PrintHUD ("Zeroing").
		SET want_pitch TO 0.
		AG10 OFF.

	} else {
		SET want_pitch TO (want_pitch + Ship:Control:PilotPitch * 1).
		SET want_heading TO want_heading + (Ship:Control:PilotYaw * 1 ).

		if want_heading > 360 {
			SET want_heading TO want_heading - 360.
		}
	}
}

//Purpose: Hold that atitude by varying engine thrust
function balanceLoop {

	SET vtolPID:SetPoint TO want_pitch.
	SET pitch_correct TO vtolPID:Update(TIME:SECONDS, pitch_for(SHIP)).

	EngineLimit(fore_engines, (100 + (pitch_correct) )).
	EngineLimit(rear_engines, (100 - (pitch_correct) )).
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
	
	print "Fore Engine:      " + round(fore_engines[0]:ThrustLimit, 1).
	print "Rear Engine:      " + round(rear_engines[0]:ThrustLimit, 1).
}

until AG9 {
	controlLoop().	
	balanceLoop().
	printLoop().

	wait 0.02.
}.

}. //End engine if
