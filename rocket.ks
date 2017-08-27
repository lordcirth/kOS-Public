// Fly a rocket to orbit

// We want pitch to equal 90 at apoapsis 0.
// And 0 at apoapsis 70.
// (0,90) to (70000,0)
parameter alt. // In km

set slope to (0 - 90) / (1000*(alt-10-alt*.05)- 0).
print "slope: " + slope.
	
lock throttle to 1.

function getPitch {
	wait 0.1.
	// y - y1 = m(x - x1)
	// pitch - 90 = slope * apoapsis
	set pitch to slope * apoapsis + 90.
	set pitch to max (pitch, 0).
	print pitch.
	return pitch.
}
SAS off.
lock steering to heading(90, getPitch() ).

// Guard against in-flight reboot
if ( ship:status = "PRELAUNCH" ) {
	wait 1.
	stage.
}

// Autostage when SRBs run out, but only if there *are* SRBs
if (ship:solidfuel > 1) {
when (ship:solidfuel < 1) then {
	wait 0.5.
	stage.
}
}

wait until apoapsis > 1000*alt.
lock throttle to 0.
set ship:control:pilotmainthrottle to 0.
SAS on.
set SASMODE to "Prograde".
